import re
import phonenumbers
from typing import Optional, Any
from pydantic import BaseModel, field_validator, EmailStr
from datetime import datetime
from app.utils.helpers import ErrorResponse
from uuid import UUID

class UserBase(BaseModel):

    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None

    @field_validator("email")
    def validate_email(cls, v):
        if v is None:
            return v
        email_regex = r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
        if not re.match(email_regex, v):
            raise ErrorResponse(
                status_code=422,
                detail="Invalid email format",
                message="Please provide a valid email address"
            )
        return v

    @field_validator("phone_number")
    def validate_phone_number(cls, v):
        if v is None:
            return v
        try:
            parsed = phonenumbers.parse(v, "IN")  # 👈 fallback region if no country code
            if not phonenumbers.is_valid_number(parsed):
                raise ErrorResponse(
                    status_code=422,
                    detail="Invalid phone number",
                    message="Please provide a valid phone number"
                )
            return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)
        except phonenumbers.NumberParseException:
            raise ErrorResponse(
                status_code=422,
                detail="Invalid phone number format",
                message="Phone number must be in international format, e.g. +911234567891"
            )


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(UserBase):
    id: UUID
    profile_url: Optional[str] = None
    is_verified: bool
    created_at: datetime
    updated_at: datetime


class UserUpdate(UserBase):
    pass
