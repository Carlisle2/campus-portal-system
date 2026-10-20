<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String errorMsg = (String) request.getAttribute("errorMsg");
    String registerSuccess = request.getParameter("registerSuccess");
    String rememberedUsername = (String) request.getAttribute("rememberedUsername");
    String username = (String) request.getAttribute("username");
    
    if (username == null) username = "";
    if (rememberedUsername != null && rememberedUsername.trim().length() > 0) {
        username = rememberedUsername;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 校园信息管理网站</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <!-- 背景图片 -->
    <img src="${pageContext.request.contextPath}/images/news/background.jpg" 
         style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: -1;
         "
         alt="背景图">

    <div class="auth-container">
         <div class="auth-form-container" style="position: relative;"> <!-- 添加相对定位 -->
            
            <!-- 返回首页按钮（表单区域左上角） -->
            <div class="auth-back-btn">
                <a href="${pageContext.request.contextPath}/index.jsp" class="back-home-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>返回首页</span>
                </a>
            </div>
            
            <div class="auth-header" style="margin-top: 20px;"> <!-- 添加上边距 -->
                <h1>欢迎回来</h1>
                <p>登录您的账户，管理您的校园信息</p>
            </div>
            
            <% if (registerSuccess != null && registerSuccess.equals("true")) { %>
                <div class="message success">
                    注册成功！请使用您的用户名和密码登录。
                </div>
            <% } %>
            
            <% if (errorMsg != null) { %>
                <div class="error-message"><%= errorMsg %></div>
            <% } %>
            
            <form class="auth-form" action="${pageContext.request.contextPath}/auth?action=dologin" method="post">
                <div class="form-group">
                    <label for="username">用户名</label>
                    <input type="text" id="username" name="username" class="form-input" 
                           placeholder="请输入用户名" required
                           value="<%= username %>">
                </div>
                
                <div class="form-group">
                    <label for="password">密码</label>
                    <input type="password" id="password" name="password" class="form-input" 
                           placeholder="请输入密码" required>
                </div>
                
                <div class="form-options">
                    <div class="remember-me">
                        <input type="checkbox" id="remember" name="remember" 
                               <%= rememberedUsername != null ? "checked" : "" %>>
                        <label for="remember">记住我</label>
                    </div>
                    <a href="#" class="forgot-password">忘记密码？</a>
                </div>
                
                <button type="submit" class="auth-button">登录</button>
                
                <div class="auth-footer">
                    还没有账户？
                    <a href="${pageContext.request.contextPath}/auth?action=register" class="auth-link">立即注册</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>