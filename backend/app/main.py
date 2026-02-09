from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.db.session import engine, Base
from app.api import health, users, messages, auth, websocket
from app.services.rabbitmq import rabbitmq_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables + connect RabbitMQ
    Base.metadata.create_all(bind=engine)
    try:
        await rabbitmq_service.connect()
        print("✅ RabbitMQ connected")
    except Exception as e:
        print(f"⚠️  RabbitMQ connection failed: {e}")
    yield
    # Shutdown
    await rabbitmq_service.close()


app = FastAPI(
    title="ClawHand API",
    description="ClawHand iOS Backend Service",
    version="1.0.0",
    lifespan=lifespan
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(health.router, prefix="/api/v1/health", tags=["Health"])
app.include_router(auth.router, prefix="/api/v1", tags=["Authentication"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(messages.router, prefix="/api/v1/messages", tags=["Messages"])
app.include_router(websocket.router)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
