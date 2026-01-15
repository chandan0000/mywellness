"""
Pydantic schemas for conversation, message, and call data validation.
"""
from datetime import datetime
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel
from uuid import UUID


# Enums matching the database models
class ConversationType(str, Enum):
    INDIVIDUAL = "individual"
    GROUP = "group"


class MessageType(str, Enum):
    TEXT = "text"
    IMAGE = "image"
    VIDEO = "video"
    AUDIO = "audio"
    FILE = "file"
    SYSTEM = "system"


class MessageStatus(str, Enum):
    SENT = "sent"
    DELIVERED = "delivered"
    READ = "read"


class CallType(str, Enum):
    AUDIO = "audio"
    VIDEO = "video"


class CallStatus(str, Enum):
    INITIATED = "initiated"
    RINGING = "ringing"
    ONGOING = "ongoing"
    ENDED = "ended"
    MISSED = "missed"
    REJECTED = "rejected"


# ============ Participant Schemas ============

class ParticipantBase(BaseModel):
    user_id: UUID
    is_admin: bool = False


class ParticipantCreate(ParticipantBase):
    pass


class ParticipantResponse(ParticipantBase):
    id: UUID
    conversation_id: UUID
    is_muted: bool
    unread_count: int
    last_read_at: Optional[datetime] = None
    joined_at: datetime
    # User info
    user_name: Optional[str] = None
    user_email: Optional[str] = None
    user_avatar: Optional[str] = None
    is_online: bool = False

    class Config:
        from_attributes = True


# ============ Message Schemas ============

class MessageBase(BaseModel):
    content: str
    type: MessageType = MessageType.TEXT


class MessageCreate(MessageBase):
    conversation_id: Optional[UUID] = None  # Optional - can be provided via URL path
    reply_to_id: Optional[UUID] = None
    media_url: Optional[str] = None
    media_thumbnail_url: Optional[str] = None


class MessageUpdate(BaseModel):
    content: Optional[str] = None
    is_deleted: Optional[bool] = None


class MessageResponse(BaseModel):
    id: UUID
    conversation_id: UUID
    sender_id: Optional[UUID]
    type: MessageType
    content: str
    media_url: Optional[str] = None
    media_thumbnail_url: Optional[str] = None
    reply_to_id: Optional[UUID] = None
    status: MessageStatus
    is_edited: bool
    is_deleted: bool
    created_at: datetime
    updated_at: datetime
    # Sender info
    sender_name: Optional[str] = None
    sender_avatar: Optional[str] = None

    class Config:
        from_attributes = True


class MessageReadUpdate(BaseModel):
    message_ids: List[UUID]


# ============ Conversation Schemas ============

class ConversationBase(BaseModel):
    type: ConversationType = ConversationType.INDIVIDUAL
    name: Optional[str] = None


class ConversationCreate(BaseModel):
    type: ConversationType = ConversationType.INDIVIDUAL
    name: Optional[str] = None  # Required for group chats
    participant_ids: List[UUID]  # User IDs to add to the conversation
    avatar_url: Optional[str] = None


class ConversationUpdate(BaseModel):
    name: Optional[str] = None
    avatar_url: Optional[str] = None


class ConversationResponse(BaseModel):
    id: UUID
    type: ConversationType
    name: Optional[str] = None
    avatar_url: Optional[str] = None
    created_by: UUID
    last_message_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    # Additional computed fields
    participants: List[ParticipantResponse] = []
    last_message: Optional[MessageResponse] = None
    unread_count: int = 0

    class Config:
        from_attributes = True


class ConversationListResponse(BaseModel):
    conversations: List[ConversationResponse]
    total: int
    page: int
    page_size: int
    has_more: bool


class MessageListResponse(BaseModel):
    messages: List[MessageResponse]
    total: int
    page: int
    page_size: int
    has_more: bool


# ============ Call Schemas ============

class CallCreate(BaseModel):
    conversation_id: UUID
    callee_id: UUID
    type: CallType


class CallResponse(BaseModel):
    id: UUID
    conversation_id: UUID
    caller_id: UUID
    callee_id: UUID
    type: CallType
    status: CallStatus
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    duration_seconds: Optional[int] = None
    created_at: datetime
    # User info
    caller_name: Optional[str] = None
    caller_avatar: Optional[str] = None
    callee_name: Optional[str] = None
    callee_avatar: Optional[str] = None

    class Config:
        from_attributes = True


class CallActionRequest(BaseModel):
    call_id: UUID


# ============ WebRTC Signaling Schemas ============

class WebRTCOffer(BaseModel):
    call_id: UUID
    sdp: str
    type: str = "offer"


class WebRTCAnswer(BaseModel):
    call_id: UUID
    sdp: str
    type: str = "answer"


class ICECandidate(BaseModel):
    call_id: UUID
    candidate: str
    sdp_mid: Optional[str] = None
    sdp_m_line_index: Optional[int] = None


# ============ Typing Indicator ============

class TypingIndicator(BaseModel):
    conversation_id: UUID
    user_id: UUID
    is_typing: bool = True
