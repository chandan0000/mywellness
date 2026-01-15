"""
Chat models for conversations, messages, and participants.
"""
from datetime import datetime
from enum import Enum as PyEnum
import uuid
from sqlalchemy import TIMESTAMP, Enum, ForeignKey, Text, text, Boolean, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db_base import Base


class ConversationType(str, PyEnum):
    INDIVIDUAL = "individual"
    GROUP = "group"


class MessageType(str, PyEnum):
    TEXT = "text"
    IMAGE = "image"
    VIDEO = "video"
    AUDIO = "audio"
    FILE = "file"
    SYSTEM = "system"


class MessageStatus(str, PyEnum):
    SENT = "sent"
    DELIVERED = "delivered"
    READ = "read"


class CallType(str, PyEnum):
    AUDIO = "audio"
    VIDEO = "video"


class CallStatus(str, PyEnum):
    INITIATED = "initiated"
    RINGING = "ringing"
    ONGOING = "ongoing"
    ENDED = "ended"
    MISSED = "missed"
    REJECTED = "rejected"


class Conversation(Base):
    """Represents a chat conversation (1-on-1 or group)."""
    __tablename__ = "conversations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()")
    )
    type: Mapped[str] = mapped_column(
        Enum(ConversationType, name="conversation_type", create_type=True),
        nullable=False,
        default=ConversationType.INDIVIDUAL
    )
    name: Mapped[str | None] = mapped_column(String(255), nullable=True)  # For group chats
    avatar_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    created_by: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )
    last_message_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        nullable=True
    )
    last_message_at: Mapped[datetime | None] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=True
    )
    is_deleted: Mapped[bool] = mapped_column(
        Boolean, 
        default=False, 
        server_default=text("false")
    )
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )
    updated_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)"),
        server_onupdate=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )

    # Relationships
    participants = relationship("Participant", back_populates="conversation", lazy="selectin")
    messages = relationship("Message", back_populates="conversation", lazy="dynamic")


class Participant(Base):
    """Links users to conversations with their role and settings."""
    __tablename__ = "participants"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()")
    )
    conversation_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("conversations.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    is_admin: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        server_default=text("false")
    )
    is_muted: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        server_default=text("false")
    )
    unread_count: Mapped[int] = mapped_column(
        Integer,
        default=0,
        server_default=text("0")
    )
    last_read_at: Mapped[datetime | None] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=True
    )
    joined_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )
    left_at: Mapped[datetime | None] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=True
    )

    # Relationships
    conversation = relationship("Conversation", back_populates="participants")
    user = relationship("User", lazy="selectin")


class Message(Base):
    """Represents a chat message."""
    __tablename__ = "messages"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()")
    )
    conversation_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("conversations.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    sender_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True
    )
    type: Mapped[str] = mapped_column(
        Enum(MessageType, name="message_type", create_type=True),
        nullable=False,
        default=MessageType.TEXT
    )
    content: Mapped[str] = mapped_column(Text, nullable=False)
    media_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    media_thumbnail_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    reply_to_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("messages.id", ondelete="SET NULL"),
        nullable=True
    )
    status: Mapped[str] = mapped_column(
        Enum(MessageStatus, name="message_status", create_type=True),
        nullable=False,
        default=MessageStatus.SENT
    )
    is_edited: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        server_default=text("false")
    )
    is_deleted: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        server_default=text("false")
    )
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )
    updated_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)"),
        server_onupdate=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )

    # Relationships
    conversation = relationship("Conversation", back_populates="messages")
    sender = relationship("User", lazy="selectin")
    reply_to = relationship("Message", remote_side=[id], lazy="selectin")


class CallSession(Base):
    """Tracks audio/video call sessions."""
    __tablename__ = "call_sessions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("gen_random_uuid()")
    )
    conversation_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("conversations.id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )
    caller_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )
    callee_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )
    type: Mapped[str] = mapped_column(
        Enum(CallType, name="call_type", create_type=True),
        nullable=False
    )
    status: Mapped[str] = mapped_column(
        Enum(CallStatus, name="call_status", create_type=True),
        nullable=False,
        default=CallStatus.INITIATED
    )
    started_at: Mapped[datetime | None] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=True
    )
    ended_at: Mapped[datetime | None] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=True
    )
    duration_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )

    # Relationships
    conversation = relationship("Conversation")
    caller = relationship("User", foreign_keys=[caller_id], lazy="selectin")
    callee = relationship("User", foreign_keys=[callee_id], lazy="selectin")
