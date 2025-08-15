from fastapi import HTTPException,status
from sqlalchemy import select

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import  User
from app.schemas.user import  UserUpdate


class UserCRUD:

    def __init__(self, db: AsyncSession):
        self.db = db

    # get single user
    async def get_user(self, user_id: int):
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)  # This now works because db is AsyncSession
        return result.scalar_one_or_none()
    
    # list of user get
    async def get_users(self) -> list[User]:
        stmt = select(User)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())


    async def update_user(self, user_id: int, user_data: UserUpdate) -> User:
        # Fetch the user
        user = await self.get_user(user_id)
        
        # If not found, throw explicit error
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"User with ID {user_id} does not exist"
            )
        
        # Update only provided fields (exclude None and ID)
        for key, value in user_data.dict(exclude_unset=True, exclude={"id"}).items():
            if value is not None:
                setattr(user, key, value)
        
        # Commit and refresh to get latest state
        await self.db.commit()
        await self.db.refresh(user)
        
        return user

    # patch user
    async def patch_user(self, user_id: int, user_data: UserUpdate) -> User | None:
        user = await self.get_user(user_id)
        if not user:
            return None
        for key, value in user_data.dict().items():
            if value is not None:
                setattr(user, key, value)
        await self.db.commit()
        return user

    # deactivate user
    async def deactivate_user(self, user_id: int) -> User | None:
        user = await self.get_user(user_id)
        if not user:
            return None
        user.is_active = False
        await self.db.commit()
        return user
