from app.core.celery import celery_app
from app.services.rabbitmq import rabbitmq_service
import asyncio


@celery_app.task(bind=True)
def send_notification(self, user_id: int, title: str, body: str):
    """发送推送通知任务"""
    print(f"[Task] Sending notification to user {user_id}: {title}")
    # 这里可以调用实际的推送服务（APNs / FCM）
    return {"status": "sent", "user_id": user_id}


@celery_app.task(bind=True)
def process_message(self, message_data: dict):
    """异步处理消息"""
    print(f"[Task] Processing message: {message_data}")
    # 通过 RabbitMQ 发布消息到队列
    async def publish():
        await rabbitmq_service.publish(
            queue="message_notifications",
            message={
                "type": "new_message",
                "data": message_data
            }
        )
    asyncio.run(publish())
    return {"status": "processed", "message_id": message_data.get("id")}


@celery_app.task(bind=True)
def cleanup_expired_sessions(self):
    """清理过期的用户会话"""
    print("[Task] Cleaning up expired sessions")
    # 实现会话清理逻辑
    return {"status": "completed", "cleaned_count": 0}


@celery_app.task(bind=True)
def daily_summary(self, user_id: int):
    """生成每日摘要"""
    print(f"[Task] Generating daily summary for user {user_id}")
    # 实现摘要生成逻辑
    return {"status": "generated", "user_id": user_id}


@celery_app.task(bind=True)
def send_email_task(self, email: str, subject: str, content: str):
    """发送邮件任务"""
    print(f"[Task] Sending email to {email}: {subject}")
    # 这里可以集成真实的邮件服务（SendGrid / AWS SES）
    return {"status": "sent", "to": email}


# 定时任务配置（celery beat）
@celery_app.on_after_configure.connect
def setup_periodic_tasks(sender, **kwargs):
    """设置定时任务"""
    # 每小时清理过期会话
    sender.add_periodic_task(
        3600.0,
        cleanup_expired_sessions.s(),
        name="cleanup_expired_sessions"
    )
    
    # 每天生成摘要（示例：每天早上 9 点）
    sender.add_periodic_task(
        crontab(hour=9, minute=0),
        daily_summary.s(user_id=0),  # 需要根据实际需求调整
        name="daily_summary"
    )


# Celery Beat 调度器需要的导入
from celery.schedules import crontab
