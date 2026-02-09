# 阿里云部署指南

## 1. 准备资源

### ECS 实例
- 推荐配置: 2核 4GB
- 地域: 杭州/上海
- 系统: Ubuntu 22.04 LTS

### 必装软件
```bash
# Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 2. 部署步骤

```bash
# 1. 克隆项目
git clone <your-repo>
cd clawd-ios/backend

# 2. 配置环境变量
cp .env.example .env
vim .env  # 编辑配置

# 3. 构建并启动
docker-compose -f docker-compose.prod.yml up -d --build

# 4. 检查状态
docker-compose -f docker-compose.prod.yml ps
docker logs clawhand-app-1
```

## 3. Nginx 配置示例

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /ws {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## 4. SSL 配置 (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

## 5. 监控与日志

```bash
# 查看日志
docker logs -f clawhand-app-1

# 资源监控
docker stats

# 日志轮转 (创建 /etc/logrotate.d/docker-logrotate)
