from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from datetime import datetime

from app.db.session import get_db, Message, User
from app.config import get_settings

router = APIRouter()


class MessageCreate(BaseModel):
    sender_id: int
    receiver_id: int
    content: str


class MessageResponse(BaseModel):
    id: int
    sender_id: int
    receiver_id: int
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


@router.post("/", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def create_message(msg: MessageCreate, db: AsyncSession = Depends(get_db)):
    # Verify users exist
    sender = await db.execute(select(User).where(User.id == msg.sender_id))
    if not sender.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Sender not found")

    receiver = await db.execute(select(User).where(User.id == msg.receiver_id))
    if not receiver.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Receiver not found")

    db_msg = Message(**msg.model_dump())
    db.add(db_msg)
    await db.commit()
    await db.refresh(db_msg)
    return db_msg


@router.get("/user/{user_id}", response_model=list[MessageResponse])
async def get_user_messages(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Message).where(
            (Message.sender_id == user_id) | (Message.receiver_id == user_id)
        ).order_by(Message.created_at.desc())
    )
    return result.scalars().all()
