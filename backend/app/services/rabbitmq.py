import aio_pika
from aio_pika import Message, DeliveryMode
from typing import Callable, Optional
from app.config import settings


class RabbitMQService:
    def __init__(self):
        self.connection: Optional[aio_pika.RobustConnection] = None
        self.channel: Optional[aio_pika.Channel] = None

    async def connect(self):
        self.connection = await aio_pika.connect_robust(settings.rabbitmq_url)
        self.channel = await self.connection.channel()
        await self.channel.set_qos(prefetch_count=10)

    async def close(self):
        if self.connection:
            await self.connection.close()

    async def publish(self, queue_name: str, message: dict):
        if not self.channel:
            await self.connect()

        await self.channel.declare_queue(queue_name, durable=True)
        await self.channel.default_exchange.publish(
            Message(
                body=str(message).encode(),
                delivery_mode=DeliveryMode.PERSISTENT
            ),
            routing_key=queue_name
        )

    async def consume(self, queue_name: str, callback: Callable):
        if not self.channel:
            await self.connect()

        queue = await self.channel.declare_queue(queue_name, durable=True)
        await queue.consume(callback)


rabbitmq_service = RabbitMQService()
