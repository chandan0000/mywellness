import uuid
from fastapi import HTTPException,status
from sqlalchemy import select

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import  User
from app.schemas.user import  UserUpdate



class UserCRUD:

    def __init__(self, db: AsyncSession):
        self.db = db

    
    async def get_user(self, user_id: uuid.UUID):
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)  
        return result.scalar_one_or_none()
    
    
    async def get_users(self) -> list[User]:
        stmt = select(User)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())


    async def update_user(self, user_id: uuid.UUID, user_data: dict):
        user = await self.get_user(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} does not exist"
            )
    
        for key, value in user_data.items():
            if value is not None:
                setattr(user, key, value)
    
        await self.db.commit()
        await self.db.refresh(user)
        return user
    

    
    async def patch_user(self, user_id: uuid.UUID, user_data: UserUpdate) -> User | None:
        user = await self.get_user(user_id)
        if not user:
            return None
        for key, value in user_data.dict().items():
            if value is not None:
                setattr(user, key, value)
        await self.db.commit()
        return user

    
    async def deactivate_user(self, user_id: uuid.UUID) -> User | None:
        user = await self.get_user(user_id)
        if not user:
            return None
        user.is_active = False
        await self.db.commit()
        return user
