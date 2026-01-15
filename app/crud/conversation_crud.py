"""
CRUD operations for conversations.
"""
from datetime import datetime
from typing import List, Optional
from uuid import UUID
from sqlalchemy import and_, select, func, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.conversation import (
    Conversation,
    Participant,
    ConversationType,
)
from app.schemas.conversation import ConversationCreate, ConversationUpdate


class ConversationCRUD:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_conversation(
        self,
        data: ConversationCreate,
        created_by: UUID
    ) -> Conversation:
        """Create a new conversation with participants."""
        # For individual chats, check if conversation already exists
        if data.type == ConversationType.INDIVIDUAL and len(data.participant_ids) == 1:
            existing = await self.get_existing_individual_conversation(
                created_by, data.participant_ids[0]
            )
            if existing:
                return existing

        # Create conversation
        conversation = Conversation(
            type=data.type,
            name=data.name,
            avatar_url=data.avatar_url,
            created_by=created_by,
        )
        self.db.add(conversation)
        await self.db.flush()

        # Add creator as participant
        creator_participant = Participant(
            conversation_id=conversation.id,
            user_id=created_by,
            is_admin=True,
        )
        self.db.add(creator_participant)

        # Add other participants
        for user_id in data.participant_ids:
            if user_id != created_by:
                participant = Participant(
                    conversation_id=conversation.id,
                    user_id=user_id,
                    is_admin=data.type == ConversationType.INDIVIDUAL,
                )
                self.db.add(participant)

        await self.db.commit()
        
        # Re-fetch with eager loading to avoid lazy-load in async context
        return await self.get_conversation_by_id(conversation.id, created_by)

    async def get_existing_individual_conversation(
        self,
        user1_id: UUID,
        user2_id: UUID
    ) -> Optional[Conversation]:
        """Check if an individual conversation between two users exists."""
        # Find conversations where both users are participants
        query = (
            select(Conversation)
            .join(Participant, Conversation.id == Participant.conversation_id)
            .where(
                and_(
                    Conversation.type == ConversationType.INDIVIDUAL,
                    Conversation.is_deleted == False,
                    Participant.user_id.in_([user1_id, user2_id]),
                    Participant.left_at.is_(None)
                )
            )
            .group_by(Conversation.id)
            .having(func.count(Participant.id) == 2)
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_conversation_by_id(
        self,
        conversation_id: UUID,
        user_id: UUID
    ) -> Optional[Conversation]:
        """Get a conversation by ID if user is a participant."""
        query = (
            select(Conversation)
            .options(selectinload(Conversation.participants).selectinload(Participant.user))
            .join(Participant)
            .where(
                and_(
                    Conversation.id == conversation_id,
                    Participant.user_id == user_id,
                    Participant.left_at.is_(None),
                    Conversation.is_deleted == False
                )
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_user_conversations(
        self,
        user_id: UUID,
        page: int = 1,
        page_size: int = 20
    ) -> tuple[List[Conversation], int]:
        """Get all conversations for a user with pagination."""
        offset = (page - 1) * page_size

        # Count query
        count_query = (
            select(func.count(Conversation.id))
            .join(Participant)
            .where(
                and_(
                    Participant.user_id == user_id,
                    Participant.left_at.is_(None),
                    Conversation.is_deleted == False
                )
            )
        )
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        # Main query with pagination
        query = (
            select(Conversation)
            .options(selectinload(Conversation.participants).selectinload(Participant.user))
            .join(Participant)
            .where(
                and_(
                    Participant.user_id == user_id,
                    Participant.left_at.is_(None),
                    Conversation.is_deleted == False
                )
            )
            .order_by(Conversation.last_message_at.desc().nullsfirst())
            .offset(offset)
            .limit(page_size)
        )
        result = await self.db.execute(query)
        conversations = result.scalars().unique().all()

        return list(conversations), total

    async def update_conversation(
        self,
        conversation_id: UUID,
        user_id: UUID,
        data: ConversationUpdate
    ) -> Optional[Conversation]:
        """Update conversation details (admin only for groups)."""
        conversation = await self.get_conversation_by_id(conversation_id, user_id)
        if not conversation:
            return None

        # Check if user is admin for group chats
        if conversation.type == ConversationType.GROUP:
            is_admin = await self._is_user_admin(conversation_id, user_id)
            if not is_admin:
                return None

        # Update fields
        if data.name is not None:
            conversation.name = data.name
        if data.avatar_url is not None:
            conversation.avatar_url = data.avatar_url

        await self.db.commit()
        await self.db.refresh(conversation)
        return conversation

    async def _is_user_admin(self, conversation_id: UUID, user_id: UUID) -> bool:
        """Check if user is an admin of the conversation."""
        query = select(Participant).where(
            and_(
                Participant.conversation_id == conversation_id,
                Participant.user_id == user_id,
                Participant.is_admin == True,
                Participant.left_at.is_(None)
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none() is not None

    async def add_participant(
        self,
        conversation_id: UUID,
        user_id: UUID,
        added_by: UUID,
        is_admin: bool = False
    ) -> Optional[Participant]:
        """Add a participant to a group conversation."""
        # Verify adder is admin
        if not await self._is_user_admin(conversation_id, added_by):
            return None

        # Check if user is already a participant
        existing_query = select(Participant).where(
            and_(
                Participant.conversation_id == conversation_id,
                Participant.user_id == user_id
            )
        )
        existing = await self.db.execute(existing_query)
        existing_participant = existing.scalar_one_or_none()

        if existing_participant:
            if existing_participant.left_at:
                # Re-add the participant
                existing_participant.left_at = None
                existing_participant.joined_at = datetime.utcnow()
                await self.db.commit()
                return existing_participant
            return existing_participant

        # Add new participant
        participant = Participant(
            conversation_id=conversation_id,
            user_id=user_id,
            is_admin=is_admin,
        )
        self.db.add(participant)
        await self.db.commit()
        await self.db.refresh(participant)
        return participant

    async def remove_participant(
        self,
        conversation_id: UUID,
        user_id: UUID,
        removed_by: UUID
    ) -> bool:
        """Remove a participant from a group conversation."""
        # User can remove themselves or admin can remove others
        if user_id != removed_by:
            if not await self._is_user_admin(conversation_id, removed_by):
                return False

        query = (
            update(Participant)
            .where(
                and_(
                    Participant.conversation_id == conversation_id,
                    Participant.user_id == user_id,
                    Participant.left_at.is_(None)
                )
            )
            .values(left_at=datetime.utcnow())
        )
        result = await self.db.execute(query)
        await self.db.commit()
        return result.rowcount > 0

    async def get_participant(
        self,
        conversation_id: UUID,
        user_id: UUID
    ) -> Optional[Participant]:
        """Get a participant record."""
        query = select(Participant).where(
            and_(
                Participant.conversation_id == conversation_id,
                Participant.user_id == user_id,
                Participant.left_at.is_(None)
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_last_message(
        self,
        conversation_id: UUID,
        message_id: UUID,
        timestamp: datetime
    ) -> None:
        """Update the conversation's last message info."""
        query = (
            update(Conversation)
            .where(Conversation.id == conversation_id)
            .values(
                last_message_id=message_id,
                last_message_at=timestamp
            )
        )
        await self.db.execute(query)
        await self.db.commit()

    async def increment_unread_count(
        self,
        conversation_id: UUID,
        exclude_user_id: UUID
    ) -> None:
        """Increment unread count for all participants except sender."""
        query = (
            update(Participant)
            .where(
                and_(
                    Participant.conversation_id == conversation_id,
                    Participant.user_id != exclude_user_id,
                    Participant.left_at.is_(None)
                )
            )
            .values(unread_count=Participant.unread_count + 1)
        )
        await self.db.execute(query)
        await self.db.commit()

    async def reset_unread_count(
        self,
        conversation_id: UUID,
        user_id: UUID
    ) -> None:
        """Reset unread count for a user in a conversation."""
        query = (
            update(Participant)
            .where(
                and_(
                    Participant.conversation_id == conversation_id,
                    Participant.user_id == user_id
                )
            )
            .values(unread_count=0, last_read_at=datetime.utcnow())
        )
        await self.db.execute(query)
        await self.db.commit()

    async def get_conversation_participants(
        self,
        conversation_id: UUID
    ) -> List[Participant]:
        """Get all active participants in a conversation."""
        query = (
            select(Participant)
            .options(selectinload(Participant.user))
            .where(
                and_(
                    Participant.conversation_id == conversation_id,
                    Participant.left_at.is_(None)
                )
            )
        )
        result = await self.db.execute(query)
        return list(result.scalars().all())
