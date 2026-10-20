<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>智慧校园信息管理平台 - 登录</title>
    <link rel="stylesheet" href="css/admin/style.css">
<style>
        body {
            margin: 0;
            padding: 0;
            background-image: url("images/login_bg.jpg"); 
            background-size: 100% auto; 
            background-repeat: no-repeat; 
            background-position: center bottom;
            background-attachment: fixed; 
            background-color: #333;
            min-height: 100vh;
        }
 
        
        .login-container {
            width: 400px;
            margin: 170px auto;
            padding: 40px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            z-index: 2;
            margin-bottom: 100px;
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 30px;
            color: #2c3e50;
        }
        
        .login-header h1 {
            margin: 0;
            font-size: 28px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: 500;
        }
        
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .btn-login {
            width: 100%;
            padding: 12px;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        .btn-login:hover {
            background: #2980b9;
        }
        
        .error-msg {
            color: #e74c3c;
            margin-top: 10px;
            text-align: center;
            display: none;
        }
        
        /* 不同错误类型样式 */
        .error-password {
            background-color: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            border-left: 4px solid #c62828;
        }
        
        .error-disabled {
            background-color: #fff3e0;
            color: #ef6c00;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            border-left: 4px solid #ef6c00;
        }
        
        .error-system {
            background-color: #fce4ec;
            color: #ad1457;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            border-left: 4px solid #ad1457;
        }
        
    </style>
</head>
<body>
<% 
    // 接收错误参数
    String error = request.getParameter("error");
    
    if ("1".equals(error)) {
        // 用户名或密码错误
%>
    <div class="error-password" id="errorMsg">
        <strong>登录失败！</strong> 用户名或密码错误。
    </div>
<%
    } else if ("2".equals(error)) {
        // 用户被禁用
%>
    <div class="error-disabled" id="errorMsg">
        <strong>账号已被禁用！</strong> 请联系系统管理员启用账号。
    </div>
<%
    } else if ("3".equals(error)) {
        // 系统错误
%>
    <div class="error-system" id="errorMsg">
        <strong>系统错误！</strong> 请稍后重试或联系管理员。
    </div>
<%
    }
%>

<script>
    // 3秒后自动隐藏错误信息
    setTimeout(function() {
        var errorMsg = document.getElementById('errorMsg');
        if (errorMsg) {
            errorMsg.style.display = 'none';
        }
    }, 5000);
</script>
	<div class="back-home-btn" style="position: absolute; top: 20px; right: 20px;">
	    <a href="${pageContext.request.contextPath}/front/index.jsp" 
	       style="display: inline-flex; align-items: center;gap: 8px; 
	              background: #f14b34; color: white; text-decoration: none; 
	              padding: 8px 16px; border-radius: 5px; font-size: 16px;">
	        <i class="fas fa-home"></i> 返回首页
	    </a>
	</div>
    <div class="login-container">
        <div class="login-header">
            <h1>智慧校园信息管理平台</h1>
        </div>
        <form id="loginForm" action="LoginServlet" method="post">
            <div class="form-group">
                <label for="username">用户名:</label>
                <input type="text" id="username" name="username" placeholder="请输入用户名" required>
            </div>
            <div class="form-group">
                <label for="password">密码:</label>
                <input type="password" id="password" name="password" placeholder="请输入密码" required>
            </div>
            <div class="form-group">
                <input type="submit" value="登录" class="btn-login">
            </div>
        </form>
    </div>

</body>
</html>