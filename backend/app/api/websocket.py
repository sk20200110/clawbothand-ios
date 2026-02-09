from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from typing import Dict, Set
import json

router = APIRouter(prefix="/ws", tags=["WebSocket"])

# Connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, Set[WebSocket]] = {}  # user_id -> connections

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)

    def disconnect(self, websocket: WebSocket, user_id: int):
        if user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def send_personal_message(self, message: dict, user_id: int):
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                await connection.send_json(message)

    async def broadcast(self, message: dict, exclude: int = None):
        for user_id, connections in self.active_connections.items():
            if user_id != exclude:
                for connection in connections:
                    await connection.send_json(message)


manager = ConnectionManager()


@router.websocket("/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            # Handle different message types
            if message.get("type") == "ping":
                await websocket.send_json({"type": "pong"})
            else:
                # Broadcast to all connected users
                await manager.broadcast({"type": "message", "from": user_id, "data": message})
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)


@router.websocket("/chat/{target_id}")
async def websocket_chat(websocket: WebSocket, target_id: int, token: str = Query(...)):
    # In production, validate token here
    await manager.connect(websocket, target_id)
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            await manager.send_personal_message(
                {"type": "chat", "from": target_id, "data": message},
                message.get("to", target_id)
            )
    except WebSocketDisconnect:
        manager.disconnect(websocket, target_id)
