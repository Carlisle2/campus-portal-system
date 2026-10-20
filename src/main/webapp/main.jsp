<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统主页</title>
    <style>
        body {
            font-family: 'Microsoft YaHei', Arial, sans-serif;
            background: #f8f9fa;
            color: #333;
            padding: 30px;
        }
        
        .welcome-container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        
        .welcome-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .welcome-header h1 {
            color: #2c3e50;
            font-size: 36px;
            margin-bottom: 10px;
        }
        
        .welcome-header p {
            color: #7f8c8d;
            font-size: 18px;
        }
        
        .system-info {
            margin-top: 40px;
            padding: 20px;
            background: white;
            border-radius: 8px;
            border-left: 4px solid #3498db;
        }
        
        .system-info h3 {
            color: #2c3e50;
            margin-bottom: 15px;
        }
        
        .info-item {
            display: flex;
            margin-bottom: 10px;
        }
        
        .info-label {
            width: 150px;
            color: #7f8c8d;
            font-weight: 500;
        }
        
        .info-value {
            flex: 1;
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <div class="welcome-container">
        <div class="welcome-header">
            <h1>欢迎使用智慧校园信息管理平台</h1>
            <p>University Infomation Management System v1.0</p>
        </div>

        
        <div class="system-info">
            <h3>系统信息</h3>
            <div class="info-item">
                <div class="info-label">系统版本:</div>
                <div class="info-value">v1.0.0</div>
            </div>
            <div class="info-item">
                <div class="info-label">最后登录时间:</div>
                <div class="info-value" id="lastLoginTime"></div>
            </div>
            <div class="info-item">
                <div class="info-label">当前用户:</div>
                <div class="info-value" id="currentUserInfo"></div>
            </div>
        </div>
    </div>

    <script>
        // 显示系统信息
        window.onload = function() {
            const now = new Date();
            document.getElementById('lastLoginTime').textContent = 
                now.toLocaleString('zh-CN', { 
                    year: 'numeric', 
                    month: '2-digit', 
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                });
            
            const user = sessionStorage.getItem('currentUser') || '系统管理员';
            document.getElementById('currentUserInfo').textContent = user;
        };
    </script>
</body>
</html>