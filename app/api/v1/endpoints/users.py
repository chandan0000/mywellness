from logging import log
from fastapi import APIRouter, Depends, HTTPException, status

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_async_db
from app.crud.user_crud import UserCRUD
from app.utils.helpers import ErrorResponse, SuccessResponse
from app.core.security import verify_token
from app.schemas.user import UserResponse

user_router = APIRouter()


@user_router.get("/me", status_code=status.HTTP_200_OK, response_model=UserResponse)
async def get_user_by_token(user_id: int=Depends(verify_token), db: AsyncSession=Depends(get_async_db)):

        user_crud = UserCRUD(db)

        user = await user_crud.get_user(user_id)

        if not user:
            raise ErrorResponse(status_code=404, detail="User not found", message="User retrieval failed")
        return user

@user_router.get("/", status_code=status.HTTP_200_OK, response_model=list[UserResponse])
async def get_all_users(db: AsyncSession=Depends(get_async_db)):
    user_crud = UserCRUD(db)
    users = await user_crud.get_users()
    return users