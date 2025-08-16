# sockets.py

import socketio

from urllib.parse import parse_qs

# 1. Create a Socket.IO server with async_mode set to 'asgi' (needed for FastAPI/Starlette).
sio = socketio.AsyncServer(async_mode="asgi", cors_allowed_origins="*")

# 2. Create an ASGI application from Socket.IO server.
socket_app = socketio.ASGIApp(sio, socketio_path='')

# 3. Define your Socket.IO event handlers below.

# Bidirectional mappings
user_socket_map = {}  # Maps userId -> socketId
sid_to_user_id = {}  # Maps socketId -> userId
# ---------------------------
# Socket.IO Event Handlers
# ---------------------------


@sio.event
async def connect(sid, environ):
    print(f"[Socket.IO] Client connected: {sid}")
    query_params = environ.get('asgi.scope', {}).get('query_string', b'').decode()
    parsed_qs = parse_qs(query_params)
    user_id = parsed_qs.get('id', [None])[0]
    '='
    if user_id:
        user_socket_map[user_id] = sid
        sid_to_user_id[sid] = user_id
        print(f"User ID {user_id} connected with SID {sid}")
    else:
        print(f"No User ID found for SID {sid}")
    
    print(f"Connected users: {user_socket_map}")


@sio.event
async def disconnect(sid):
    print(f"[Socket.IO] Client disconnected: {sid}")
    user_id = sid_to_user_id.get(sid)
    if user_id:
        del sid_to_user_id[sid]
        del user_socket_map[user_id]
        print(f"User ID {user_id} disconnected")
    else:
        print(f"SID {sid} disconnected but no user_id was found")
    print(f"Connected users: {user_socket_map}")
 
