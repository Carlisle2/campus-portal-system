
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统菜单</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft YaHei', sans-serif;
            background: #ecf0f1;
            height: 100vh;
            overflow-y: auto;
        }
        
        .menu-container {
            padding: 20px 0;
        }
        
        .menu-group {
            margin-bottom: 20px;
        }
        
        .menu-title {
            padding: 12px 20px;
            background: #3498db;
            color: white;
            font-weight: bold;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .menu-title:hover {
            background: #2980b9;
        }
        
        .menu-items {
            background: white;
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s;
        }
        
        .menu-items.expanded {
            max-height: 500px;
        }
        
        .menu-item {
            padding: 10px 30px;
            color: #555;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .menu-item:hover {
            background: #f8f9fa;
            color: #3498db;
        }
        
        .arrow {
            transition: transform 0.3s;
        }
        
        .arrow.expanded {
            transform: rotate(90deg);
        }
    </style>
</head>
<body>
    <div class="menu-container">
    	<!-- 仪表盘 -->
		<div class="menu-group">
		    <div class="menu-title" onclick="loadPage('DashboardServlet')">
		        仪表盘<i class="fas fa-tachometer-alt"></i>
		    </div>
		</div>
		
        <!-- 用户管理 -->
		<div class="menu-group">
		    <div class="menu-title" onclick="loadPage('user_query.jsp')">
		        用户管理
		    </div>
		</div>
		
		 <!-- 角色管理 -->
		<div class="menu-group">
		    <div class="menu-title" onclick="loadPage('role_query.jsp')">
		        角色管理
		    </div>
		</div>
        
        <!-- 新闻管理 -->
        <div class="menu-group">
			<div class="menu-title" onclick="loadPage('news_list.jsp')">
			新闻管理
			</div>
        </div>
    </div>

    <script>
        // 切换菜单展开/收起
        function toggleMenu(element) {
            const menuItems = element.nextElementSibling;
            const arrow = element.querySelector('.arrow');
            
            menuItems.classList.toggle('expanded');
            arrow.classList.toggle('expanded');
        }
        
        // 加载页面到主框架
        function loadPage(pageUrl) {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage(pageUrl);
            }
        }
    </script>
</body>
</html>