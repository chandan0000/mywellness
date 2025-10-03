from datetime import datetime
import uuid
from sqlalchemy import TIMESTAMP, text, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from app.core.db_base import Base

class User(Base):
    __tablename__ = "users"


    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("uuidv7()")  # Postgres 18 new feature!
    )
    full_name: Mapped[str] = mapped_column(index=True)
    email: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)
    phone_number: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)
    profile_url: Mapped[str | None] = mapped_column(index=True, nullable=True)
    password: Mapped[str|None] = mapped_column(nullable=True)
    
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, server_default=text("true"))
    is_superuser: Mapped[bool] = mapped_column(Boolean, default=False, server_default=text("false"))
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, server_default=text("false"))
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False, server_default=text("false"))
    is_online: Mapped[bool] = mapped_column(Boolean, default=False, server_default=text("false"))
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
        server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )

    updated_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True),
        nullable=False,
    server_default=text("TIMEZONE('utc', CURRENT_TIMESTAMP)"),
    server_onupdate=text("TIMEZONE('utc', CURRENT_TIMESTAMP)")
    )


