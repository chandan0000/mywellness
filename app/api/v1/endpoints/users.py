from logging import log
import os
from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, status
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
from app.core.database import get_async_db
from app.crud.user_crud import UserCRUD
from app.utils.helpers import ErrorResponse, SuccessResponse
from app.core.security import verify_token
from app.schemas.user import UserResponse, UserUpdate

user_router = APIRouter()

UPLOAD_DIR = "uploads/profile_pics"

os.makedirs(UPLOAD_DIR, exist_ok=True) 

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


@user_router.put("/me", status_code=status.HTTP_200_OK, response_model=UserResponse)
async def update_user(
     user_id: uuid.UUID = Depends(verify_token),
    db: AsyncSession = Depends(get_async_db),
    full_name: Optional[str] = Form(None),
    phone_number: Optional[str] = Form(None),
    email: Optional[str] = Form(None),
    profile_picture: Optional[UploadFile] = File(None)  
):
    user_crud = UserCRUD(db)

    user_data = {
        "full_name": full_name,
        "phone_number": phone_number,
        "email": email,
    }

    
    if profile_picture:
     file_location = os.path.join(UPLOAD_DIR, f"{user_id}_{profile_picture.filename}")
     with open(file_location, "wb") as f:
         f.write(await profile_picture.read())
     user_data["profile_url"] = str(file_location)

    user = await user_crud.update_user(user_id, user_data)

    if not user:
        raise ErrorResponse(
            status_code=404,
            detail="User not found",
            message="User update failed"
        )
    return user