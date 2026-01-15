"""
API endpoints for audio/video call management.
"""
from datetime import datetime
from uuid import UUID
from fastapi import APIRouter, Depends, status
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_async_db
from app.core.security import verify_token
from app.models.conversation import CallSession, CallStatus
from app.schemas.conversation import CallCreate, CallResponse, CallActionRequest
from app.utils.helpers import SuccessResponse, ErrorResponse

call_router = APIRouter()


def _build_call_response(call: CallSession) -> CallResponse:
    """Helper to build call response with user info."""
    return CallResponse(
        id=call.id,
        conversation_id=call.conversation_id,
        caller_id=call.caller_id,
        callee_id=call.callee_id,
        type=call.type,
        status=call.status,
        started_at=call.started_at,
        ended_at=call.ended_at,
        duration_seconds=call.duration_seconds,
        created_at=call.created_at,
        caller_name=call.caller.full_name if call.caller else None,
        caller_avatar=call.caller.profile_url if call.caller else None,
        callee_name=call.callee.full_name if call.callee else None,
        callee_avatar=call.callee.profile_url if call.callee else None,
    )


@call_router.post("/initiate", status_code=status.HTTP_201_CREATED)
async def initiate_call(
    data: CallCreate,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Initiate a new audio/video call."""
    # Check if there's already an active call for this conversation
    existing_query = select(CallSession).where(
        and_(
            CallSession.conversation_id == data.conversation_id,
            CallSession.status.in_([CallStatus.INITIATED, CallStatus.RINGING, CallStatus.ONGOING])
        )
    )
    result = await db.execute(existing_query)
    existing_call = result.scalar_one_or_none()
    
    if existing_call:
        raise ErrorResponse(
            status_code=status.HTTP_409_CONFLICT,
            detail="There's already an active call in this conversation",
            message="Call initiation failed"
        )
    
    # Create new call session
    call = CallSession(
        conversation_id=data.conversation_id,
        caller_id=current_user_id,
        callee_id=data.callee_id,
        type=data.type,
        status=CallStatus.INITIATED,
    )
    db.add(call)
    await db.commit()
    await db.refresh(call)
    
    return SuccessResponse(
        detail=_build_call_response(call),
        status_code=status.HTTP_201_CREATED,
        message="Call initiated successfully"
    )


@call_router.post("/accept")
async def accept_call(
    data: CallActionRequest,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Accept an incoming call."""
    # Get the call
    query = select(CallSession).where(
        and_(
            CallSession.id == data.call_id,
            CallSession.callee_id == current_user_id,
            CallSession.status.in_([CallStatus.INITIATED, CallStatus.RINGING])
        )
    )
    result = await db.execute(query)
    call = result.scalar_one_or_none()
    
    if not call:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call not found or already handled",
            message="Accept failed"
        )
    
    # Update call status
    call.status = CallStatus.ONGOING
    call.started_at = datetime.utcnow()
    await db.commit()
    await db.refresh(call)
    
    return SuccessResponse(
        detail=_build_call_response(call),
        status_code=status.HTTP_200_OK,
        message="Call accepted successfully"
    )


@call_router.post("/reject")
async def reject_call(
    data: CallActionRequest,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Reject an incoming call."""
    query = select(CallSession).where(
        and_(
            CallSession.id == data.call_id,
            CallSession.callee_id == current_user_id,
            CallSession.status.in_([CallStatus.INITIATED, CallStatus.RINGING])
        )
    )
    result = await db.execute(query)
    call = result.scalar_one_or_none()
    
    if not call:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call not found or already handled",
            message="Reject failed"
        )
    
    call.status = CallStatus.REJECTED
    call.ended_at = datetime.utcnow()
    await db.commit()
    await db.refresh(call)
    
    return SuccessResponse(
        detail=_build_call_response(call),
        status_code=status.HTTP_200_OK,
        message="Call rejected"
    )


@call_router.post("/end")
async def end_call(
    data: CallActionRequest,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """End an ongoing call."""
    query = select(CallSession).where(
        and_(
            CallSession.id == data.call_id,
            CallSession.status.in_([CallStatus.INITIATED, CallStatus.RINGING, CallStatus.ONGOING]),
            # Either caller or callee can end
            (CallSession.caller_id == current_user_id) | (CallSession.callee_id == current_user_id)
        )
    )
    result = await db.execute(query)
    call = result.scalar_one_or_none()
    
    if not call:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call not found or already ended",
            message="End call failed"
        )
    
    # Calculate duration if call was ongoing
    duration = None
    if call.started_at:
        duration = int((datetime.utcnow() - call.started_at).total_seconds())
    
    # Mark as missed if never answered
    new_status = CallStatus.ENDED
    if call.status in [CallStatus.INITIATED, CallStatus.RINGING]:
        new_status = CallStatus.MISSED
    
    call.status = new_status
    call.ended_at = datetime.utcnow()
    call.duration_seconds = duration
    await db.commit()
    await db.refresh(call)
    
    return SuccessResponse(
        detail=_build_call_response(call),
        status_code=status.HTTP_200_OK,
        message="Call ended"
    )


@call_router.get("/{call_id}")
async def get_call(
    call_id: UUID,
    db: AsyncSession = Depends(get_async_db),
    current_user_id: UUID = Depends(verify_token),
):
    """Get call details."""
    query = select(CallSession).where(
        and_(
            CallSession.id == call_id,
            (CallSession.caller_id == current_user_id) | (CallSession.callee_id == current_user_id)
        )
    )
    result = await db.execute(query)
    call = result.scalar_one_or_none()
    
    if not call:
        raise ErrorResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Call not found",
            message="Not found"
        )
    
    return SuccessResponse(
        detail=_build_call_response(call),
        status_code=status.HTTP_200_OK,
        message="Call retrieved successfully"
    )
