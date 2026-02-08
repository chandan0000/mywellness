from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.schemas.user import UserCreate


class AuthCRUD:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_user_by_email(self, email: str):
        stmt = select(User).where(User.email == email)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def create_user(self, user: UserCreate) -> User:
        new_user = User(**user.dict())
        self.db.add(new_user)

        await self.db.commit()
        await self.db.refresh(new_user)
        return new_user
