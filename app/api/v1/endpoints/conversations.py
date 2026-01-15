"""
API endpoints for conversation management.
"""
from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_async_db
from app.core.security import verify_token
from app.crud.conversation_crud import ConversationCRUD
from app.crud.message_crud import MessageCRUD
from app.schemas.conversation import (
    ConversationCreate,
    ConversationUpdate,
    ConversationResponse,
    ConversationListResponse,
    MessageCreate,
    MessageResponse,
    MessageListResponse,
    MessageReadUpdate,
    ParticipantCreate,
    ParticipantResponse,
)
from app.utils.helpers import SuccessResponse, ErrorResponse

conversation_router = APIRouter()


def _build_participant_response(participant) -> ParticipantResponse:
    """Helper to build participant response with user info."""
    return ParticipantResponse(
        id=participant.id,
        user_id=participant.user_id,
        conversation_id=participant.conversation_id,
        is_admin=participant.is_admin,
        is_muted=participant.is_muted,
        unread_count=participant.unread_count,
        last_read_at=participant.last_read_at,
        joined_at=participant.joined_at,
        user_name=participant.user.full_name if participant.user else None,
        user_email=participant.user.email if participant.user else None,
        user_avatar=participant.user.profile_url if participant.user else None,
        is_online=participant.user.is_online if participant.user else False,
    )


def _build_message_response(message) -> MessageResponse:
    """Helper to build message response with sender info."""
    return MessageResponse(
        id=message.id,
        conversation_id=message.conversation_id,
        sender_id=message.sender_id,
        type=message.type,
        content=message.content,
        media_url=message.media_url,
        media_thumbnail_url=message.media_thumbnail_url,
        reply_to_id=message.reply_to_id,
        status=message.status,
        is_edited=message.is_edited,
        is_deleted=message.is_deleted,
        created_at=message.created_at,
        updated_at=message.updated_at,
        sender_name=message.sender.full_name if message.sender else None,
        sender_avatar=message.sender.profile_url if message.sender else None,
    )


def _build_conversation_response(
    conversation,
    current_user_id: UUID,
    last_message=None
) -> ConversationResponse:
    """Helper to build conversation response with computed fields."""
    participants = [
        _build_participant_response(p)
        for p in conversation.participants
        if p.left_at is None
    ]
    
    # Find current user's unread count
    unread_count = 0
    for p in conversation.participants:
        if p.user_id == current_user_id and p.left_at is None:
            unread_count = p.unread_count
            break

    return ConversationResponse(
        id=conversation.id,
        type=conversation.type,
        name=conversation.name,
        avatar_url=conversation.avatar_url,
        created_by=conversation.created_by,
        last_message_at=conversation.last_message_at,
        created_at=conversation.created_at,
        updated_at=conversation.updated_at,
        participants=participants,
        last_message=_build_message_response(last_message) if last_message else None,
        unread_count=unread_count,
    )


# ============ Conversation Endpoints ============

@conversation_router.post("", status_code=status.HTTP_201_CREATED)
async def create_conversation(
    data: ConversationCreate,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Create a new conversation."""
    if not data.participant_ids:
        raise ErrorResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one participant is required",
            message="Validation failed"
        )

    crud = ConversationCRUD(db)
    conversation = await crud.create_conversation(data, current_user_id)
    
    return SuccessResponse(
        detail=_build_conversation_response(conversation, current_user_id),
        status_code=status.HTTP_201_CREATED,
        message="Conversation created successfully"
    )


@conversation_router.get("", response_model=None)
async def get_conversations(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Get all conversations for the current user."""
    crud = ConversationCRUD(db)
    message_crud = MessageCRUD(db)
    
    conversations, total = await crud.get_user_conversations(
        current_user_id, page, page_size
    )
    
    # Build response with last messages
    conversation_responses = []
    for conv in conversations:
        last_message = await message_crud.get_last_message(conv.id)
        conversation_responses.append(
            _build_conversation_response(conv, current_user_id, last_message)
        )
    
    return SuccessResponse(
        detail=ConversationListResponse(
            conversations=conversation_responses,
            total=total,
            page=page,
            page_size=page_size,
            has_more=(page * page_size) < total
        ),
        status_code=status.HTTP_200_OK,
        message="Conversations retrieved successfully"
    )


@conversation_router.get("/{conversation_id}")
async def get_conversation(
    conversation_id: UUID,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Get a specific conversation by ID."""
    crud = ConversationCRUD(db)
    message_crud = MessageCRUD(db)
    
    conversation = await crud.get_conversation_by_id(conversation_id, current_user_id)
    if not conversation:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found",
            message="Not found"
        )
    
    last_message = await message_crud.get_last_message(conversation_id)
    
    return SuccessResponse(
        detail=_build_conversation_response(conversation, current_user_id, last_message),
        status_code=status.HTTP_200_OK,
        message="Conversation retrieved successfully"
    )


@conversation_router.patch("/{conversation_id}")
async def update_conversation(
    conversation_id: UUID,
    data: ConversationUpdate,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Update conversation details."""
    crud = ConversationCRUD(db)
    
    conversation = await crud.update_conversation(
        conversation_id, current_user_id, data
    )
    if not conversation:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found or you don't have permission",
            message="Update failed"
        )
    
    return SuccessResponse(
        detail=_build_conversation_response(conversation, current_user_id),
        status_code=status.HTTP_200_OK,
        message="Conversation updated successfully"
    )


# ============ Participant Endpoints ============

@conversation_router.post("/{conversation_id}/participants")
async def add_participant(
    conversation_id: UUID,
    data: ParticipantCreate,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Add a participant to a group conversation."""
    crud = ConversationCRUD(db)
    
    participant = await crud.add_participant(
        conversation_id, data.user_id, current_user_id, data.is_admin
    )
    if not participant:
        raise ErrorResponse(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to add participants",
            message="Permission denied"
        )
    
    return SuccessResponse(
        detail=_build_participant_response(participant),
        status_code=status.HTTP_200_OK,
        message="Participant added successfully"
    )


@conversation_router.delete("/{conversation_id}/participants/{user_id}")
async def remove_participant(
    conversation_id: UUID,
    user_id: UUID,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Remove a participant from a conversation."""
    crud = ConversationCRUD(db)
    
    success = await crud.remove_participant(
        conversation_id, user_id, current_user_id
    )
    if not success:
        raise ErrorResponse(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to remove this participant",
            message="Permission denied"
        )
    
    return SuccessResponse(
        detail=None,
        status_code=status.HTTP_200_OK,
        message="Participant removed successfully"
    )


# ============ Message Endpoints ============

@conversation_router.get("/{conversation_id}/messages")
async def get_messages(
    conversation_id: UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    before_id: Optional[UUID] = None,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Get messages for a conversation with pagination."""
    conv_crud = ConversationCRUD(db)
    
    # Verify user is a participant
    conversation = await conv_crud.get_conversation_by_id(conversation_id, current_user_id)
    if not conversation:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found",
            message="Not found"
        )
    
    message_crud = MessageCRUD(db)
    messages, total = await message_crud.get_conversation_messages(
        conversation_id, page, page_size, before_id
    )
    
    # Mark messages as delivered
    await message_crud.mark_conversation_messages_as_delivered(
        conversation_id, current_user_id
    )
    
    return SuccessResponse(
        detail=MessageListResponse(
            messages=[_build_message_response(m) for m in messages],
            total=total,
            page=page,
            page_size=page_size,
            has_more=(page * page_size) < total
        ),
        status_code=status.HTTP_200_OK,
        message="Messages retrieved successfully"
    )


@conversation_router.post("/{conversation_id}/messages", status_code=status.HTTP_201_CREATED)
async def send_message(
    conversation_id: UUID,
    data: MessageCreate,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Send a message to a conversation."""
    conv_crud = ConversationCRUD(db)
    
    # Verify user is a participant
    conversation = await conv_crud.get_conversation_by_id(conversation_id, current_user_id)
    if not conversation:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found",
            message="Not found"
        )
    
    # Override conversation_id from URL
    data.conversation_id = conversation_id
    
    message_crud = MessageCRUD(db)
    message = await message_crud.create_message(data, current_user_id)
    
    # Update conversation's last message
    await conv_crud.update_last_message(
        conversation_id, message.id, message.created_at
    )
    
    # Increment unread count for other participants
    await conv_crud.increment_unread_count(conversation_id, current_user_id)
    
    return SuccessResponse(
        detail=_build_message_response(message),
        status_code=status.HTTP_201_CREATED,
        message="Message sent successfully"
    )


@conversation_router.post("/{conversation_id}/messages/read")
async def mark_messages_read(
    conversation_id: UUID,
    data: MessageReadUpdate,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Mark messages as read."""
    conv_crud = ConversationCRUD(db)
    
    # Verify user is a participant
    conversation = await conv_crud.get_conversation_by_id(conversation_id, current_user_id)
    if not conversation:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conversation not found",
            message="Not found"
        )
    
    message_crud = MessageCRUD(db)
    count = await message_crud.mark_messages_as_read(data.message_ids, current_user_id)
    
    # Reset unread count
    await conv_crud.reset_unread_count(conversation_id, current_user_id)
    
    return SuccessResponse(
        detail={"marked_count": count},
        status_code=status.HTTP_200_OK,
        message="Messages marked as read"
    )


@conversation_router.delete("/{conversation_id}/messages/{message_id}")
async def delete_message(
    conversation_id: UUID,
    message_id: UUID,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Delete a message (soft delete)."""
    message_crud = MessageCRUD(db)
    
    success = await message_crud.delete_message(message_id, current_user_id)
    if not success:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found or you don't have permission to delete",
            message="Delete failed"
        )
    
    return SuccessResponse(
        detail=None,
        status_code=status.HTTP_200_OK,
        message="Message deleted successfully"
    )
