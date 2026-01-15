# sockets.py
"""
Socket.IO service for real-time messaging and WebRTC signaling.
"""

import socketio
from datetime import datetime
from urllib.parse import parse_qs
from typing import Optional

# 1. Create a Socket.IO server with async_mode set to 'asgi' (needed for FastAPI/Starlette).
sio = socketio.AsyncServer(
    async_mode="asgi",
    cors_allowed_origins="*",
    logger=True,
    engineio_logger=True
)

# 2. Create an ASGI application from Socket.IO server.
socket_app = socketio.ASGIApp(sio, socketio_path='')

# 3. Bidirectional mappings for user tracking
user_socket_map = {}  # Maps userId -> set of socketIds (user can have multiple connections)
sid_to_user_id = {}  # Maps socketId -> userId

# ---------------------------
# Helper Functions
# ---------------------------

def get_user_sockets(user_id: str) -> set:
    """Get all socket IDs for a user."""
    return user_socket_map.get(user_id, set())


async def emit_to_user(user_id: str, event: str, data: dict):
    """Emit an event to all connections of a specific user."""
    sockets = get_user_sockets(user_id)
    for sid in sockets:
        await sio.emit(event, data, room=sid)


async def emit_to_users(user_ids: list, event: str, data: dict, exclude_user: Optional[str] = None):
    """Emit an event to multiple users."""
    for user_id in user_ids:
        if exclude_user and user_id == exclude_user:
            continue
        await emit_to_user(user_id, event, data)


# ---------------------------
# Socket.IO Event Handlers
# ---------------------------

@sio.event
async def connect(sid, environ):
    """Handle client connection."""
    print(f"[Socket.IO] Client connecting: {sid}")
    
    query_params = environ.get('asgi.scope', {}).get('query_string', b'').decode()
    parsed_qs = parse_qs(query_params)
    user_id = parsed_qs.get('id', [None])[0]
    
    if user_id:
        # Add socket to user's set of connections
        if user_id not in user_socket_map:
            user_socket_map[user_id] = set()
        user_socket_map[user_id].add(sid)
        sid_to_user_id[sid] = user_id
        
        # Join user to their personal room
        await sio.enter_room(sid, f"user_{user_id}")
        
        print(f"[Socket.IO] User {user_id} connected with SID {sid}")
        print(f"[Socket.IO] Active users: {list(user_socket_map.keys())}")
        
        # Notify user of successful connection
        await sio.emit('connection_success', {
            'user_id': user_id,
            'sid': sid,
            'timestamp': datetime.utcnow().isoformat()
        }, room=sid)
    else:
        print("[Socket.IO] Connection rejected - no user ID provided")
        await sio.disconnect(sid)


@sio.event
async def disconnect(sid):
    """Handle client disconnection."""
    print(f"[Socket.IO] Client disconnected: {sid}")
    
    user_id = sid_to_user_id.get(sid)
    if user_id:
        # Remove socket from user's connections
        if user_id in user_socket_map:
            user_socket_map[user_id].discard(sid)
            # Clean up if user has no more connections
            if not user_socket_map[user_id]:
                del user_socket_map[user_id]
        
        del sid_to_user_id[sid]
        print(f"[Socket.IO] User {user_id} disconnected")
    
    print(f"[Socket.IO] Active users: {list(user_socket_map.keys())}")


# ---------------------------
# Chat Room Management
# ---------------------------

@sio.event
async def join_conversation(sid, data):
    """Join a conversation room for real-time updates."""
    conversation_id = data.get('conversation_id')
    user_id = sid_to_user_id.get(sid)
    
    if not conversation_id or not user_id:
        await sio.emit('error', {'message': 'Invalid data'}, room=sid)
        return
    
    room = f"conversation_{conversation_id}"
    await sio.enter_room(sid, room)
    print(f"[Socket.IO] User {user_id} joined conversation {conversation_id}")
    
    await sio.emit('joined_conversation', {
        'conversation_id': conversation_id,
        'user_id': user_id
    }, room=sid)


@sio.event
async def leave_conversation(sid, data):
    """Leave a conversation room."""
    conversation_id = data.get('conversation_id')
    
    if conversation_id:
        room = f"conversation_{conversation_id}"
        await sio.leave_room(sid, room)
        print(f"[Socket.IO] SID {sid} left conversation {conversation_id}")


# ---------------------------
# Messaging Events
# ---------------------------

@sio.event
async def send_message(sid, data):
    """
    Handle real-time message sending.
    Expected data: {
        'conversation_id': str,
        'message': {
            'id': str,
            'content': str,
            'type': str,
            'sender_id': str,
            'sender_name': str,
            'sender_avatar': str,
            'created_at': str,
            ...
        },
        'participant_ids': [str]  # All participant user IDs
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        await sio.emit('error', {'message': 'Not authenticated'}, room=sid)
        return
    
    conversation_id = data.get('conversation_id')
    message = data.get('message', {})
    participant_ids = data.get('participant_ids', [])
    
    if not conversation_id or not message:
        await sio.emit('error', {'message': 'Invalid message data'}, room=sid)
        return
    
    # Broadcast message to all participants
    event_data = {
        'conversation_id': conversation_id,
        'message': message,
        'timestamp': datetime.utcnow().isoformat()
    }
    
    # Emit to conversation room
    room = f"conversation_{conversation_id}"
    await sio.emit('new_message', event_data, room=room, skip_sid=sid)
    
    # Also emit to users who might not be in the room (for notifications)
    for pid in participant_ids:
        if pid != user_id:
            await emit_to_user(pid, 'message_notification', {
                'conversation_id': conversation_id,
                'message': message
            })
    
    # Confirm to sender
    await sio.emit('message_sent', {
        'message_id': message.get('id'),
        'status': 'sent',
        'timestamp': datetime.utcnow().isoformat()
    }, room=sid)


@sio.event
async def typing(sid, data):
    """
    Handle typing indicator.
    Expected data: {
        'conversation_id': str,
        'is_typing': bool
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    conversation_id = data.get('conversation_id')
    is_typing = data.get('is_typing', False)
    
    if not conversation_id:
        return
    
    room = f"conversation_{conversation_id}"
    await sio.emit('user_typing', {
        'conversation_id': conversation_id,
        'user_id': user_id,
        'is_typing': is_typing,
        'timestamp': datetime.utcnow().isoformat()
    }, room=room, skip_sid=sid)


@sio.event
async def messages_read(sid, data):
    """
    Handle read receipts.
    Expected data: {
        'conversation_id': str,
        'message_ids': [str],
        'reader_id': str
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    conversation_id = data.get('conversation_id')
    message_ids = data.get('message_ids', [])
    
    if not conversation_id or not message_ids:
        return
    
    room = f"conversation_{conversation_id}"
    await sio.emit('messages_read_receipt', {
        'conversation_id': conversation_id,
        'message_ids': message_ids,
        'reader_id': user_id,
        'read_at': datetime.utcnow().isoformat()
    }, room=room, skip_sid=sid)


@sio.event
async def message_delivered(sid, data):
    """
    Handle message delivery confirmation.
    Expected data: {
        'conversation_id': str,
        'message_ids': [str]
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    conversation_id = data.get('conversation_id')
    message_ids = data.get('message_ids', [])
    
    if not conversation_id or not message_ids:
        return
    
    room = f"conversation_{conversation_id}"
    await sio.emit('messages_delivered', {
        'conversation_id': conversation_id,
        'message_ids': message_ids,
        'delivered_to': user_id,
        'delivered_at': datetime.utcnow().isoformat()
    }, room=room, skip_sid=sid)


# ---------------------------
# WebRTC Signaling Events
# ---------------------------

@sio.event
async def call_offer(sid, data):
    """
    Handle WebRTC call offer.
    Expected data: {
        'call_id': str,
        'callee_id': str,
        'caller_id': str,
        'caller_name': str,
        'caller_avatar': str,
        'call_type': 'audio' | 'video',
        'sdp': str
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        await sio.emit('error', {'message': 'Not authenticated'}, room=sid)
        return
    
    callee_id = data.get('callee_id')
    if not callee_id:
        await sio.emit('error', {'message': 'Callee ID required'}, room=sid)
        return
    
    # Send offer to callee
    await emit_to_user(callee_id, 'incoming_call', {
        'call_id': data.get('call_id'),
        'caller_id': user_id,
        'caller_name': data.get('caller_name'),
        'caller_avatar': data.get('caller_avatar'),
        'call_type': data.get('call_type'),
        'sdp': data.get('sdp'),
        'timestamp': datetime.utcnow().isoformat()
    })
    
    print(f"[Socket.IO] Call offer from {user_id} to {callee_id}")


@sio.event
async def call_answer(sid, data):
    """
    Handle WebRTC call answer.
    Expected data: {
        'call_id': str,
        'caller_id': str,
        'sdp': str
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    caller_id = data.get('caller_id')
    if not caller_id:
        return
    
    # Send answer to caller
    await emit_to_user(caller_id, 'call_answered', {
        'call_id': data.get('call_id'),
        'callee_id': user_id,
        'sdp': data.get('sdp'),
        'timestamp': datetime.utcnow().isoformat()
    })
    
    print(f"[Socket.IO] Call answer from {user_id} to {caller_id}")


@sio.event
async def ice_candidate(sid, data):
    """
    Handle ICE candidate exchange.
    Expected data: {
        'call_id': str,
        'target_user_id': str,
        'candidate': str,
        'sdp_mid': str,
        'sdp_m_line_index': int
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    target_user_id = data.get('target_user_id')
    if not target_user_id:
        return
    
    # Forward ICE candidate to target user
    await emit_to_user(target_user_id, 'ice_candidate', {
        'call_id': data.get('call_id'),
        'from_user_id': user_id,
        'candidate': data.get('candidate'),
        'sdp_mid': data.get('sdp_mid'),
        'sdp_m_line_index': data.get('sdp_m_line_index')
    })


@sio.event
async def call_reject(sid, data):
    """
    Handle call rejection.
    Expected data: {
        'call_id': str,
        'caller_id': str
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    caller_id = data.get('caller_id')
    if caller_id:
        await emit_to_user(caller_id, 'call_rejected', {
            'call_id': data.get('call_id'),
            'rejected_by': user_id,
            'timestamp': datetime.utcnow().isoformat()
        })
    
    print(f"[Socket.IO] Call rejected by {user_id}")


@sio.event
async def call_end(sid, data):
    """
    Handle call end.
    Expected data: {
        'call_id': str,
        'target_user_id': str
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    target_user_id = data.get('target_user_id')
    if target_user_id:
        await emit_to_user(target_user_id, 'call_ended', {
            'call_id': data.get('call_id'),
            'ended_by': user_id,
            'timestamp': datetime.utcnow().isoformat()
        })
    
    print(f"[Socket.IO] Call ended by {user_id}")


@sio.event
async def call_busy(sid, data):
    """
    Handle busy signal (user is in another call).
    Expected data: {
        'call_id': str,
        'caller_id': str
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    caller_id = data.get('caller_id')
    if caller_id:
        await emit_to_user(caller_id, 'user_busy', {
            'call_id': data.get('call_id'),
            'user_id': user_id,
            'timestamp': datetime.utcnow().isoformat()
        })


# ---------------------------
# Presence Events
# ---------------------------

@sio.event
async def update_presence(sid, data):
    """
    Update user presence status.
    Expected data: {
        'status': 'online' | 'away' | 'busy' | 'offline'
    }
    """
    user_id = sid_to_user_id.get(sid)
    if not user_id:
        return
    
    status = data.get('status', 'online')
    
    # Broadcast presence to user's contacts (implementation depends on your contact system)
    # For now, we'll broadcast to all connected users
    await sio.emit('presence_update', {
        'user_id': user_id,
        'status': status,
        'timestamp': datetime.utcnow().isoformat()
    }, skip_sid=sid)


@sio.event
async def get_online_users(sid, data):
    """
    Get list of online users from a list of user IDs.
    Expected data: {
        'user_ids': [str]
    }
    """
    user_ids = data.get('user_ids', [])
    online_users = [uid for uid in user_ids if uid in user_socket_map]
    
    await sio.emit('online_users', {
        'online_users': online_users,
        'timestamp': datetime.utcnow().isoformat()
    }, room=sid)

 
