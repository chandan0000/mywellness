"""
CRUD operations for messages.
"""
from typing import List, Optional
from uuid import UUID
from sqlalchemy import and_, select, func, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.conversation import Message, MessageStatus
from app.schemas.conversation import MessageCreate, MessageUpdate


class MessageCRUD:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_message(
        self,
        data: MessageCreate,
        sender_id: UUID
    ) -> Message:
        """Create a new message."""
        message = Message(
            conversation_id=data.conversation_id,
            sender_id=sender_id,
            type=data.type,
            content=data.content,
            media_url=data.media_url,
            media_thumbnail_url=data.media_thumbnail_url,
            reply_to_id=data.reply_to_id,
            status=MessageStatus.SENT,
        )
        self.db.add(message)
        await self.db.commit()
        await self.db.refresh(message)
        return message

    async def get_message_by_id(
        self,
        message_id: UUID
    ) -> Optional[Message]:
        """Get a message by ID."""
        query = (
            select(Message)
            .options(selectinload(Message.sender))
            .options(selectinload(Message.reply_to))
            .where(
                and_(
                    Message.id == message_id,
                    Message.is_deleted == False
                )
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_conversation_messages(
        self,
        conversation_id: UUID,
        page: int = 1,
        page_size: int = 50,
        before_id: Optional[UUID] = None
    ) -> tuple[List[Message], int]:
        """Get messages for a conversation with pagination."""
        # Count query
        count_query = (
            select(func.count(Message.id))
            .where(
                and_(
                    Message.conversation_id == conversation_id,
                    Message.is_deleted == False
                )
            )
        )
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        # Build main query
        conditions = [
            Message.conversation_id == conversation_id,
            Message.is_deleted == False
        ]

        # If before_id is provided, get messages before that message
        if before_id:
            before_message = await self.get_message_by_id(before_id)
            if before_message:
                conditions.append(Message.created_at < before_message.created_at)

        query = (
            select(Message)
            .options(selectinload(Message.sender))
            .options(selectinload(Message.reply_to))
            .where(and_(*conditions))
            .order_by(Message.created_at.desc())
            .limit(page_size)
        )

        if not before_id:
            offset = (page - 1) * page_size
            query = query.offset(offset)

        result = await self.db.execute(query)
        messages = list(result.scalars().all())

        # Return in chronological order
        messages.reverse()
        return messages, total

    async def update_message(
        self,
        message_id: UUID,
        sender_id: UUID,
        data: MessageUpdate
    ) -> Optional[Message]:
        """Update a message (only sender can edit)."""
        message = await self.get_message_by_id(message_id)
        if not message or message.sender_id != sender_id:
            return None

        if data.content is not None:
            message.content = data.content
            message.is_edited = True

        if data.is_deleted is not None:
            message.is_deleted = data.is_deleted

        await self.db.commit()
        await self.db.refresh(message)
        return message

    async def delete_message(
        self,
        message_id: UUID,
        user_id: UUID
    ) -> bool:
        """Soft delete a message (only sender can delete)."""
        query = (
            update(Message)
            .where(
                and_(
                    Message.id == message_id,
                    Message.sender_id == user_id,
                    Message.is_deleted == False
                )
            )
            .values(is_deleted=True, content="This message was deleted")
        )
        result = await self.db.execute(query)
        await self.db.commit()
        return result.rowcount > 0

    async def mark_messages_as_read(
        self,
        message_ids: List[UUID],
        user_id: UUID
    ) -> int:
        """Mark messages as read (only for messages not sent by the user)."""
        query = (
            update(Message)
            .where(
                and_(
                    Message.id.in_(message_ids),
                    Message.sender_id != user_id,
                    Message.status != MessageStatus.READ
                )
            )
            .values(status=MessageStatus.READ)
        )
        result = await self.db.execute(query)
        await self.db.commit()
        return result.rowcount

    async def mark_conversation_messages_as_delivered(
        self,
        conversation_id: UUID,
        user_id: UUID
    ) -> int:
        """Mark all undelivered messages in a conversation as delivered."""
        query = (
            update(Message)
            .where(
                and_(
                    Message.conversation_id == conversation_id,
                    Message.sender_id != user_id,
                    Message.status == MessageStatus.SENT
                )
            )
            .values(status=MessageStatus.DELIVERED)
        )
        result = await self.db.execute(query)
        await self.db.commit()
        return result.rowcount

    async def get_unread_message_count(
        self,
        conversation_id: UUID,
        user_id: UUID
    ) -> int:
        """Get count of unread messages in a conversation for a user."""
        query = (
            select(func.count(Message.id))
            .where(
                and_(
                    Message.conversation_id == conversation_id,
                    Message.sender_id != user_id,
                    Message.status != MessageStatus.READ,
                    Message.is_deleted == False
                )
            )
        )
        result = await self.db.execute(query)
        return result.scalar() or 0

    async def get_last_message(
        self,
        conversation_id: UUID
    ) -> Optional[Message]:
        """Get the last message in a conversation."""
        query = (
            select(Message)
            .options(selectinload(Message.sender))
            .where(
                and_(
                    Message.conversation_id == conversation_id,
                    Message.is_deleted == False
                )
            )
            .order_by(Message.created_at.desc())
            .limit(1)
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def search_messages(
        self,
        conversation_id: UUID,
        query_text: str,
        page: int = 1,
        page_size: int = 20
    ) -> tuple[List[Message], int]:
        """Search messages in a conversation."""
        offset = (page - 1) * page_size
        search_pattern = f"%{query_text}%"

        # Count query
        count_query = (
            select(func.count(Message.id))
            .where(
                and_(
                    Message.conversation_id == conversation_id,
                    Message.content.ilike(search_pattern),
                    Message.is_deleted == False
                )
            )
        )
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        # Main query
        query = (
            select(Message)
            .options(selectinload(Message.sender))
            .where(
                and_(
                    Message.conversation_id == conversation_id,
                    Message.content.ilike(search_pattern),
                    Message.is_deleted == False
                )
            )
            .order_by(Message.created_at.desc())
            .offset(offset)
            .limit(page_size)
        )
        result = await self.db.execute(query)
        messages = list(result.scalars().all())

        return messages, total
