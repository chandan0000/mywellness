from sqlalchemy import select

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import  User
from app.schemas.user import UserCreate

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

    # update user
    async def update_user(self, user_id: int, user_data: UserCreate) -> User | None:
        user = await self.get_user(user_id)
        if not user:
            return None
        for key, value in user_data.dict().items():
            setattr(user, key, value)
        await self.db.commit()
        return user

    # patch user
    async def patch_user(self, user_id: int, user_data: UserCreate) -> User | None:
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
