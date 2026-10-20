<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01news.NewsBean" %>
<%@ page import="java.util.List" %>
<%
    String keyword = (String) request.getAttribute("keyword");
    List<NewsBean> newsList = (List<NewsBean>) request.getAttribute("newsList");
    Integer pageNum = (Integer) request.getAttribute("page");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    
    if (keyword == null) keyword = "";
    if (newsList == null) newsList = new java.util.ArrayList<>();
    if (pageNum == null) pageNum = 1;
    if (totalPages == null) totalPages = 0;
    if (totalCount == null) totalCount = 0;
    
    // 检查用户是否登录
    com.m01user.UserBean user = (com.m01user.UserBean) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>搜索结果 - 校园信息管理网站</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/front.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .search-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 0; 
        }
        
        .search-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .search-title {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
        }
        
        .search-form {
            max-width: 600px;
            margin: 0 auto;
        }
        
        .search-input-group {
            display: flex;
            gap: 0;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border-radius: 50px;
            overflow: hidden;
        }
        
        .search-input-large {
            flex: 1;
            padding: 15px 25px;
            border: none;
            font-size: 16px;
            outline: none;
        }
        
        .search-btn-large {
            padding: 0 30px;
            background-color: #0066cc;
            color: white;
            border: none;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .search-btn-large:hover {
            background-color: #004d99;
        }
        
        .search-result-info {
            color: #666;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .search-result-count {
            color: #0066cc;
            font-weight: bold;
        }
        
        .no-results {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .no-results-icon {
            font-size: 60px;
            color: #ddd;
            margin-bottom: 20px;
        }
        
        .search-item {
            background-color: #fff;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s;
        }
        
        .search-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }
        
        .search-item-title {
            font-size: 18px;
            color: #333;
            margin-bottom: 10px;
            line-height: 1.4;
        }
        
        .search-item-title a {
            color: #333;
        }
        
        .search-item-title a:hover {
            color: #0066cc;
        }
        
        .search-item-summary {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 15px;
        }
        
        .search-item-meta {
            display: flex;
            gap: 15px;
            font-size: 13px;
            color: #888;
        }
        
        .search-item-category {
            background-color: #f0f7ff;
            color: #0066cc;
            padding: 2px 8px;
            border-radius: 3px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 40px;
        }
        
        .pagination-item {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 4px;
            background-color: #fff;
            color: #333;
            border: 1px solid #ddd;
            transition: all 0.3s;
        }
        
        .pagination-item:hover,
        .pagination-item.active {
            background-color: #0066cc;
            color: white;
            border-color: #0066cc;
            text-decoration: none;
        }
        
        .pagination-item.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .search-suggestions {
            margin-top: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }
        
        .suggestions-title {
            font-size: 16px;
            color: #333;
            margin-bottom: 15px;
        }
        
        .suggestions-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .suggestion-tag {
            background-color: #fff;
            color: #666;
            padding: 5px 15px;
            border-radius: 20px;
            border: 1px solid #ddd;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .suggestion-tag:hover {
            background-color: #0066cc;
            color: white;
            border-color: #0066cc;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <!-- 头部导航 -->
    <header class="header">
        <div class="container header-container">
            <div class="logo">
                <i class="fas fa-graduation-cap"></i> 校园信息管理网站
            </div>
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">首页</a>
                <a href="${pageContext.request.contextPath}/news?action=list" class="nav-link">新闻中心</a>
                <a href="#" class="nav-link">通知公告</a>
                <a href="#" class="nav-link">学生服务</a>
                <a href="#" class="nav-link">下载中心</a>
                <form class="search-box" action="${pageContext.request.contextPath}/news" method="get">
                    <input type="hidden" name="action" value="search">
                    <input type="text" name="keyword" class="search-input" placeholder="搜索新闻..." value="<%= keyword %>">
                    <button type="submit" class="search-btn">
                        <i class="fas fa-search"></i>
                    </button>
                </form>
				<% if (username == null) { %>
				    <a href="${pageContext.request.contextPath}/auth?action=login" class="nav-link">登录</a>
				    <a href="${pageContext.request.contextPath}/auth?action=register" class="nav-link">注册</a>
				<% } else { %>
				    <div class="user-dropdown">
				        <a href="#" class="nav-link user-info">
				            <i class="fas fa-user-circle"></i> <%= username %> <% if (role != null) { %>(<%= role %>)<% } %>
				        </a>
				        <div class="dropdown-menu">
				            <a href="#" class="dropdown-item"><i class="fas fa-user"></i> 个人中心</a>
				            <a href="#" class="dropdown-item"><i class="fas fa-cog"></i> 账号设置</a>
				            <div class="dropdown-divider"></div>
							<a href="${pageContext.request.contextPath}/auth?action=logout&from=nav" class="dropdown-item">
							    <i class="fas fa-sign-out-alt"></i> 退出登录
							</a>
				        </div>
				    </div>
				<% } %>
            </nav>
        </div>
    </header>

    <!-- 面包屑导航 -->
    <div class="container" style="margin: 20px auto;">
        <nav style="font-size: 14px; color: #666;">
            <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
            <i class="fas fa-chevron-right" style="margin: 0 10px;"></i>
            <a href="${pageContext.request.contextPath}/news?action=list">新闻中心</a>
            <i class="fas fa-chevron-right" style="margin: 0 10px;"></i>
            <span>搜索结果</span>
        </nav>
    </div>

    <!-- 搜索区域 -->
    <main class="container search-container">
        <div class="search-header">
            <h1 class="search-title">搜索新闻</h1>
            <form class="search-form" action="${pageContext.request.contextPath}/news" method="get">
                <input type="hidden" name="action" value="search">
                <div class="search-input-group">
                    <input type="text" name="keyword" class="search-input-large" 
                           placeholder="请输入搜索关键词..." value="<%= keyword %>" required>
                    <button type="submit" class="search-btn-large">
                        <i class="fas fa-search"></i> 搜索
                    </button>
                </div>
            </form>
        </div>

        <!-- 搜索结果信息 -->
        <% if (!keyword.isEmpty()) { %>
        <div class="search-result-info">
            找到 <span class="search-result-count"><%= totalCount %></span> 条关于 "<%= keyword %>" 的结果
        </div>
        <% } %>

        <!-- 搜索结果列表 -->
        <% if (!newsList.isEmpty()) { %>
            <div class="search-results">
                <% for (NewsBean news : newsList) { 
                    String summary = news.getSummary();
                    if (summary == null || summary.isEmpty()) {
                        summary = news.getContent();
                        if (summary != null && summary.length() > 150) {
                            summary = summary.substring(0, 150) + "...";
                        }
                    } else if (summary.length() > 150) {
                        summary = summary.substring(0, 150) + "...";
                    }
                %>
                <article class="search-item">
                    <h2 class="search-item-title">
                        <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>">
                            <%= news.getTitle() %>
                        </a>
                    </h2>
                    
                    <% if (summary != null && !summary.isEmpty()) { %>
                    <div class="search-item-summary">
                        <%= summary %>
                    </div>
                    <% } %>
                    
                    <div class="search-item-meta">
                        <% if (news.getCategoryName() != null && !news.getCategoryName().isEmpty()) { %>
                        <span class="search-item-category"><%= news.getCategoryName() %></span>
                        <% } %>
                        <span><i class="far fa-calendar"></i> <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(news.getPublishTime()) %></span>
                        <span><i class="far fa-eye"></i> <%= news.getViewCount() %> 阅读</span>
                        <span><i class="far fa-user"></i> <%= news.getAuthor() %></span>
                    </div>
                </article>
                <% } %>
            </div>
            
            <!-- 分页 -->
            <% if (totalPages > 1) { %>
            <nav class="pagination">
                <% if (pageNum > 1) { %>
                <a href="${pageContext.request.contextPath}/news?action=search&keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= pageNum - 1 %>" 
                   class="pagination-item">
                    <i class="fas fa-chevron-left"></i>
                </a>
                <% } %>
                
                <% 
                int startPage = Math.max(1, pageNum - 2);
                int endPage = Math.min(totalPages, startPage + 4);
                startPage = Math.max(1, Math.min(startPage, endPage - 4));
                
                for (int i = startPage; i <= endPage; i++) { 
                %>
                <a href="${pageContext.request.contextPath}/news?action=search&keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= i %>" 
                   class="pagination-item <%= i == pageNum ? "active" : "" %>">
                    <%= i %>
                </a>
                <% } %>
                
                <% if (pageNum < totalPages) { %>
                <a href="${pageContext.request.contextPath}/news?action=search&keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>&page=<%= pageNum + 1 %>" 
                   class="pagination-item">
                    <i class="fas fa-chevron-right"></i>
                </a>
                <% } %>
            </nav>
            <% } %>
            
        <% } else if (!keyword.isEmpty()) { %>
            <!-- 无结果 -->
            <div class="no-results">
                <div class="no-results-icon">
                    <i class="fas fa-search"></i>
                </div>
                <h3>未找到相关结果</h3>
                <p>抱歉，没有找到与 "<%= keyword %>" 相关的新闻。</p>
                <p style="margin-top: 15px; font-size: 14px; color: #666;">
                    建议您：检查输入是否正确、尝试其他关键词、浏览其他分类
                </p>
            </div>
            
            <!-- 搜索建议 -->
            <div class="search-suggestions">
                <h4 class="suggestions-title">您可能想搜索：</h4>
                <div class="suggestions-list">
                    <a href="${pageContext.request.contextPath}/news?action=search&keyword=学生管理" class="suggestion-tag">学生管理</a>
                    <a href="${pageContext.request.contextPath}/news?action=search&keyword=校园活动" class="suggestion-tag">校园活动</a>
                    <a href="${pageContext.request.contextPath}/news?action=search&keyword=教学通知" class="suggestion-tag">教学通知</a>
                    <a href="${pageContext.request.contextPath}/news?action=search&keyword=学院新闻" class="suggestion-tag">学院新闻</a>
                    <a href="${pageContext.request.contextPath}/news?action=search&keyword=班级动态" class="suggestion-tag">班级动态</a>
                    <a href="${pageContext.request.contextPath}/news?action=search&keyword=学习资源" class="suggestion-tag">学习资源</a>
                </div>
            </div>
        <% } else { %>
            <!-- 未输入关键词 -->
            <div class="no-results">
                <div class="no-results-icon">
                    <i class="fas fa-search"></i>
                </div>
                <h3>请输入搜索关键词</h3>
                <p>在搜索框中输入您想要查找的内容。</p>
            </div>
        <% } %>
    </main>

    <!-- 底部 -->
    <footer class="footer">
        <div class="container footer-container">
            <div class="footer-section">
                <h3>联系方式</h3>
                <div class="contact-info">
                    <p><i class="fas fa-map-marker-alt"></i> 江苏省南京市江宁区佛城西路8号</p>
                    <p><i class="fas fa-phone"></i> 010-12345678</p>
                    <p><i class="fas fa-envelope"></i> admin@example.edu.cn</p>
                </div>
            </div>
            <div class="footer-section">
                <h3>网站地图</h3>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/index.jsp">首页</a></li>
                    <li><a href="${pageContext.request.contextPath}/news?action=list">新闻中心</a></li>
                    <li><a href="#">通知公告</a></li>
                    <li><a href="#">学生服务</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h3>友情链接</h3>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/login.jsp">后台管理</a></li>
                    <li><a href="https://www.example-university.edu.cn" target="_blank">学校官网</a></li>
                    <li><a href="https://jw.example-university.edu.cn" target="_blank">教务处</a></li>
                    <li><a href="https://lib.example-university.edu.cn" target="_blank">图书馆</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h3>快速导航</h3>
                <ul class="footer-links">
                    <li><a href="#">规章制度</a></li>
                    <li><a href="#">下载中心</a></li>
                    <li><a href="#">联系我们</a></li>
                    <li><a href="#">意见建议</a></li>
                </ul>
            </div>
        </div>
        <div class="container copyright">
            <p>© 2026 学生管理网站 版权所有 苏ICP备12345678号</p>
            <p>技术支持：学生管理网站技术部</p>
        </div>
    </footer>
</body>
</html>