<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01news.NewsBean" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    NewsBean news = (NewsBean) request.getAttribute("news");
    if (news == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy年MM月dd日 HH:mm");
    
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
    <title><%= news.getTitle() %> - 校园信息管理网站</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/front.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .news-detail {
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 0;
        }
        
        .news-header {
            text-align: center; 
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        
        .news-title {
            font-size: 28px;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
            line-height: 1.4;
        }
        
        .news-meta {
            display: flex;
            justify-content: center;
            gap: 20px;
            color: #666;
            font-size: 14px;
            flex-wrap: wrap;
        }
        
        .news-meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .news-cover {
            margin-bottom: 30px;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .news-cover img {
            width: 100%;
            max-height: 500px;
            object-fit: cover;
        }
        
        .news-content {
            font-size: 16px;
            line-height: 1.8;
            color: #333;
            padding: 0 20px;
        }
        
        .news-content p {
            margin-bottom: 20px;
            text-align: justify;
        }
        
        .news-content img {
            max-width: 100%;
            height: auto;
            margin: 20px 0;
        }
        
        .news-footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        
        .news-tags {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .news-tag {
            background-color: #f0f7ff;
            color: #0066cc;
            padding: 5px 12px;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .back-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background-color: #f8f9fa;
            color: #333;
            padding: 10px 20px;
            border-radius: 6px;
            border: 1px solid #ddd;
            transition: all 0.3s;
        }
        
        .back-button:hover {
            background-color: #e9ecef;
            text-decoration: none;
            color: #333;
        }
        
        .share-buttons {
            display: flex;
            gap: 10px;
        }
        
        .share-button {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            transition: transform 0.3s;
        }
        
        .share-button:hover {
            transform: translateY(-3px);
            text-decoration: none;
        }
        
        .share-wechat { background-color: #09bb07; }
        .share-qq { background-color: #12b7f5; }
        .share-weibo { background-color: #e6162d; }
        
        @media (max-width: 768px) {
            .news-title {
                font-size: 22px;
            }
            
            .news-meta {
                flex-direction: column;
                align-items: center;
                gap: 8px;
            }
            
            .news-content {
                padding: 0;
            }
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
                    <input type="text" name="keyword" class="search-input" placeholder="搜索新闻...">
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
            <span>新闻详情</span>
        </nav>
    </div>

    <!-- 新闻详情内容 -->
    <main class="container news-detail">
        <article>
            <!-- 新闻标题和元信息 -->
            <header class="news-header">
                <h1 class="news-title"><%= news.getTitle() %></h1>
                <div class="news-meta">
                    <div class="news-meta-item">
                        <i class="far fa-calendar"></i>
                        <span>发布时间：<%= sdf.format(news.getPublishTime()) %></span>
                    </div>
                    <div class="news-meta-item">
                        <i class="far fa-user"></i>
                        <span>作者：<%= news.getAuthor() %></span>
                    </div>
                    <div class="news-meta-item">
                        <i class="far fa-eye"></i>
                        <span>阅读：<%= news.getViewCount() %></span>
                    </div>
                    <% if (news.getCategoryName() != null && !news.getCategoryName().isEmpty()) { %>
                    <div class="news-meta-item">
                        <i class="far fa-folder"></i>
                        <span>分类：<%= news.getCategoryName() %></span>
                    </div>
                    <% } %>
                </div>
            </header>
            
			<!-- 封面图片 -->
			<% 
			int detailImageNum = news.getId();
			%>
			<div class="news-cover">
			    <img src="images/news/detail<%= detailImageNum %>.jpg" alt="<%= news.getTitle() %>">
			</div>

            <!-- 新闻摘要 -->
            <% if (news.getSummary() != null && !news.getSummary().isEmpty()) { %>
            <div class="news-summary" style="
                background-color: #f8f9fa;
                padding: 20px;
                border-left: 4px solid #0066cc;
                margin-bottom: 30px;
                border-radius: 4px;
                font-size: 16px;
                line-height: 1.6;
                color: #555;
            ">
                <strong>摘要：</strong><%= news.getSummary() %>
            </div>
            <% } %>

            <!-- 新闻内容 -->
            <div class="news-content">
                <%= news.getContent() %>
            </div>

            <!-- 标签和分享 -->
            <footer class="news-footer">
                <div class="news-tags">
                    <span class="news-tag">学生管理</span>
                    <span class="news-tag">校园新闻</span>
                    <% if (news.getCategoryName() != null) { %>
                    <span class="news-tag"><%= news.getCategoryName() %></span>
                    <% } %>
                </div>
                
                <div class="action-buttons">
                    <a href="javascript:history.back()" class="back-button">
                        <i class="fas fa-arrow-left"></i> 返回上一页
                    </a>
                    
                    <div class="share-buttons">
                        <a href="#" class="share-button share-wechat" title="分享到微信">
                            <i class="fab fa-weixin"></i>
                        </a>
                        <a href="#" class="share-button share-qq" title="分享到QQ">
                            <i class="fab fa-qq"></i>
                        </a>
                        <a href="#" class="share-button share-weibo" title="分享到微博">
                            <i class="fab fa-weibo"></i>
                        </a>
                    </div>
                </div>
            </footer>
        </article>
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