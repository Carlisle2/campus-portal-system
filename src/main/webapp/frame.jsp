<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>智慧校园信息管理平台</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft YaHei', Arial, sans-serif;
            overflow: hidden;
        }
        
        .frame-container {
            display: flex;
            flex-direction: column;
            height: 100vh;
        }
        
        .header {
            height: 80px;
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            display: flex;
            align-items: center;
            padding: 0 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .logo-area {
            width: 250px;
        }
        
        .logo-area iframe {
            border: none;
        }
        
        .user-info {
            flex: 1;
            text-align: right;
        }
        
        .user-info span {
            margin-right: 20px;
        }
        
        .logout-btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .main-content {
            display: flex;
            flex: 1;
            overflow: hidden;
        }
        
        .left-menu {
            width: 250px;
            background: #ecf0f1;
            border-right: 1px solid #ddd;
        }
        
        .left-menu iframe {
            border: none;
        }
        
        .content-area {
            flex: 1;
            padding: 0;
            position: relative;
        }
        
        .content-area iframe {
            border: none;
            width: 100%;
            height: 100%;
        }
        
    </style>
</head>
<script>    
    // 退出登录
    function logout() {
        sessionStorage.clear();
        window.location.href = 'login.jsp';
    }
    
    // 新增：加载页面到主框架
    function loadPage(pageUrl) {
        const mainFrame = document.getElementById('mainFrame');
        if (mainFrame) {
            mainFrame.src = pageUrl;
        }
    }
    
    // 新增：提供给子菜单调用的函数（全局可访问）
    window.loadPage = loadPage;
</script>

<body>
	<% String username = (String)session.getAttribute("username"); %>
    <div class="frame-container">
        <div class="header">
            <div class="logo-area">
                <iframe src="logo.jsp" width="100%" height="80px"></iframe>
            </div>
            <div class="user-info">
                <span>欢迎您，用户名：<span style="color:yellow"><%= username %></span></span>   
                <a href="${pageContext.request.contextPath}/index.jsp" target="_blank" 
                   style="display: inline-block; background: #3498db; color: white; font-size: 14px;
                          text-decoration: none; padding: 8px 16px; border-radius: 4px; 
                          margin-right: 15px;">
                    网站首页
                </a>            
                <button class="logout-btn" onclick="logout()">退出登录</button>
            </div>
        </div>
        
        <div class="main-content">
            <div class="left-menu">
                <iframe src="menu.jsp" width="100%" height="100%" id="menuFrame"></iframe>
            </div>
            
            <div class="content-area">
                <!-- 内容区域 -->
                <iframe id="mainFrame" src="main.jsp" width="100%" height="100%"></iframe>
            </div>
        </div>
    </div>
 


</body>
</html>