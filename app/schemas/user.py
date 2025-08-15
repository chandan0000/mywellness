from datetime import datetime
from pydantic import BaseModel, ConfigDict


class UserBase(BaseModel):
    id: int | None
    full_name: str
    phone_number:str | None
    email: str


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    email: str
    password: str


class UserResponse(UserBase):
    is_verified: bool 
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

