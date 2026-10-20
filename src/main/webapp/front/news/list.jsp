<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01news.NewsBean" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<NewsBean> newsList = (List<NewsBean>) request.getAttribute("newsList");
    if (newsList == null) newsList = new java.util.ArrayList<>();
    
    // 获取分页参数
    Integer pageNum = (Integer) request.getAttribute("page");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String type = (String) request.getAttribute("type");
    
    // 设置默认值
    if (pageNum == null) pageNum = 1;
    if (totalPages == null) totalPages = 1;
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
    <title>新闻中心 - 校园信息管理网站</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/front.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .news-list-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 30px 0;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .page-title {
            font-size: 28px;
            color: #333;
            margin-bottom: 10px;
        }
        
        .page-subtitle {
            color: #666;
            font-size: 16px;
        }
        
        .category-filter {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        
        .category-btn {
            padding: 8px 20px;
            background-color: #fff;
            color: #333;
            border: 1px solid #ddd;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .category-btn:hover,
        .category-btn.active {
            background-color: #0066cc;
            color: white;
            border-color: #0066cc;
        }
        
        .news-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .news-card {
            background-color: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 3px 15px rgba(0,0,0,0.08);
            transition: transform 0.3s;
            border: 1px solid #eee;
        }
        
        .news-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.12);
        }
        
        .news-card-content {
            padding: 25px;
        }
        
        .news-card-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 12px;
            line-height: 1.4;
        }
        
        .news-card-summary {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            min-height: 68px;
        }
        
        .news-card-meta {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #888;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #f0f0f0;
        }
        
        .news-card-category {
            background-color: #f0f7ff;
            color: #0066cc;
            padding: 3px 10px;
            border-radius: 3px;
            font-size: 11px;
        }
        
        .no-news {
            text-align: center;
            padding: 60px 20px;
            color: #666;
            grid-column: 1 / -1;
        }
        
        .no-news-icon {
            font-size: 60px;
            color: #ddd;
            margin-bottom: 20px;
        }
        
        .list-view-switch {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 20px;
        }
        
        .view-btn {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #fff;
            border: 1px solid #ddd;
            color: #666;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .view-btn:first-child {
            border-radius: 4px 0 0 4px;
        }
        
        .view-btn:last-child {
            border-radius: 0 4px 4px 0;
        }
        
        .view-btn:hover,
        .view-btn.active {
            background-color: #0066cc;
            color: white;
            border-color: #0066cc;
        }
        
        /* 分页样式 */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 40px;
        }
        
        .pagination-item {
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 40px;
            height: 40px;
            padding: 0 8px;
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            color: #333;
            transition: all 0.3s;
            font-size: 14px;
        }
        
        .pagination-item:hover {
            background-color: #f0f7ff;
            border-color: #0066cc;
            color: #0066cc;
            text-decoration: none;
        }
        
        .pagination-item.active {
            background-color: #0066cc;
            border-color: #0066cc;
            color: white;
        }
        
        .pagination-item.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .pagination-item.disabled:hover {
            background-color: #fff;
            border-color: #ddd;
            color: #333;
        }
        
        .list-view .news-card {
            display: flex;
            height: auto;
        }
        
        .list-view .news-card-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        @media (max-width: 768px) {
            .news-grid {
                grid-template-columns: 1fr;
            }
            
            .list-view .news-card {
                flex-direction: column;
            }
        }
    </style>
	<script>
	    document.addEventListener('DOMContentLoaded', function() {
	        // 视图切换
	        const gridViewBtn = document.getElementById('gridViewBtn');
	        const listViewBtn = document.getElementById('listViewBtn');
	        const newsGrid = document.getElementById('newsGrid');
	        
	        if (gridViewBtn && listViewBtn && newsGrid) {
	            // 网格视图
	            gridViewBtn.addEventListener('click', function() {
	                // 移除列表视图类
	                newsGrid.classList.remove('list-view');
	                // 添加网格视图样式
	                newsGrid.style.gridTemplateColumns = 'repeat(auto-fill, minmax(350px, 1fr))';
	                newsGrid.style.gap = '30px';
	                
	                // 重置所有卡片的样式
	                const newsCards = newsGrid.querySelectorAll('.news-card');
	                newsCards.forEach(card => {
	                    card.style.display = 'block';
	                    card.style.flexDirection = '';
	                    card.style.maxHeight = '';
	                    card.style.flex = '';
	                });
	                
	                // 更新按钮状态
	                gridViewBtn.classList.add('active');
	                listViewBtn.classList.remove('active');
	                localStorage.setItem('newsView', 'grid');
	            });
	            
	            // 列表视图
	            listViewBtn.addEventListener('click', function() {
	                // 添加列表视图类
	                newsGrid.classList.add('list-view');
	                // 设置列表视图样式
	                newsGrid.style.gridTemplateColumns = '1fr';
	                newsGrid.style.gap = '15px';
	                
	                // 更新所有卡片的样式
	                const newsCards = newsGrid.querySelectorAll('.news-card');
	                newsCards.forEach(card => {
	                    card.style.display = 'flex';
	                    card.style.flexDirection = 'row';
	                    card.style.maxHeight = '180px';
	                });
	                
	                // 更新按钮状态
	                listViewBtn.classList.add('active');
	                gridViewBtn.classList.remove('active');
	                localStorage.setItem('newsView', 'list');
	            });
	            
	            // 恢复上次的视图设置
	            const savedView = localStorage.getItem('newsView') || 'grid';
	            if (savedView === 'list') {
	                // 延迟执行以确保DOM已完全加载
	                setTimeout(() => listViewBtn.click(), 100);
	            } else {
	                setTimeout(() => gridViewBtn.click(), 100);
	            }
	        }
	        
	        // 分类过滤 - 保持原有逻辑
	        const categoryBtns = document.querySelectorAll('.category-btn');
	        const newsCards = document.querySelectorAll('.news-card');
	        
	        categoryBtns.forEach(btn => {
	            btn.addEventListener('click', function() {
	                const category = this.getAttribute('data-category');
	                
	                // 更新按钮状态
	                categoryBtns.forEach(b => b.classList.remove('active'));
	                this.classList.add('active');
	                
	                // 过滤新闻
	                newsCards.forEach(card => {
	                    const cardCategory = card.getAttribute('data-category');
	                    if (category === 'all' || cardCategory === category) {
	                        card.style.display = 'flex';
	                    } else {
	                        card.style.display = 'none';
	                    }
	                });
	            });
	        });
	    });
	</script>
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
                <a href="${pageContext.request.contextPath}/news?action=list" class="nav-link active">新闻中心</a>
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
            <span>新闻中心</span>
        </nav>
    </div>

    <!-- 新闻列表内容 -->
    <main class="container news-list-container">
        <!-- 页面标题 -->
        <header class="page-header">
            <h1 class="page-title">新闻中心</h1>
            <p class="page-subtitle">了解校园动态，掌握最新资讯</p>
        </header>

        <!-- 分类筛选 -->
        <div class="category-filter">
            <button class="category-btn active" data-category="all">全部新闻</button>
            <button class="category-btn" data-category="学院新闻">学院新闻</button>
            <button class="category-btn" data-category="班级动态">班级动态</button>
            <button class="category-btn" data-category="教务通知">教务通知</button>
            <button class="category-btn" data-category="学生活动">学生活动</button>
            <button class="category-btn" data-category="学习资料">学习资料</button>
        </div>

        <!-- 视图切换 -->
        <div class="list-view-switch">
            <button id="gridViewBtn" class="view-btn active" title="网格视图">
                <i class="fas fa-th-large"></i>
            </button>
            <button id="listViewBtn" class="view-btn" title="列表视图">
                <i class="fas fa-list"></i>
            </button>
        </div>

        <!-- 新闻列表 -->
        <div id="newsGrid" class="news-grid">
            <% if (!newsList.isEmpty()) { %>
                <% for (NewsBean news : newsList) { 
                    // 处理摘要
                    String summary = news.getSummary();
                    if (summary == null || summary.isEmpty()) {
                        // 如果没有摘要，从内容中截取
                        String content = news.getContent();
                        if (content != null) {
                            // 移除HTML标签
                            content = content.replaceAll("<[^>]*>", " ");
                            // 移除多余空格
                            content = content.replaceAll("\\s+", " ").trim();
                            if (content.length() > 100) {
                                summary = content.substring(0, 100) + "...";
                            } else {
                                summary = content;
                            }
                        } else {
                            summary = "暂无内容简介";
                        }
                    } else if (summary.length() > 100) {
                        summary = summary.substring(0, 100) + "...";
                    }
                    
                    // 处理分类
                    String category = news.getCategoryName();
                    if (category == null || category.isEmpty()) {
                        category = "未分类";
                    }
                %>
                <article class="news-card" data-category="<%= category %>">
                    <div class="news-card-content">
                        <h2 class="news-card-title">
                            <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>">
                                <%= news.getTitle() %>
                            </a>
                        </h2>
                        <div style="margin-bottom: 10px;">
                            <span class="news-card-category"><%= category %></span>
                            <% if (news.getAuthor() != null && !news.getAuthor().isEmpty()) { %>
                            <span style="margin-left: 10px; font-size: 13px; color: #666;">
                                <i class="far fa-user"></i> <%= news.getAuthor() %>
                            </span>
                            <% } %>
                        </div>
                        <p class="news-card-summary"><%= summary %></p>
                        <div class="news-card-meta">
                            <div>
                                <span><i class="far fa-calendar"></i> 
                                    <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(news.getPublishTime()) %>
                                </span>
                            </div>
                            <div>
                                <span><i class="far fa-eye"></i> <%= news.getViewCount() %></span>
                            </div>
                        </div>
                    </div>
                </article>
                <% } %>
            <% } else { %>
                <!-- 没有数据时的显示 -->
                <div class="no-news">
                    <div class="no-news-icon">
                        <i class="far fa-newspaper"></i>
                    </div>
                    <h3>暂无新闻</h3>
                    <p>当前还没有发布新闻，请稍后再来查看。</p>
                </div>
            <% } %>
        </div>

        <!-- 分页导航 -->
        <% if (totalPages > 1) { %>
            <nav class="pagination">
                <% 
                    // 计算分页显示范围
                    int startPage = Math.max(1, pageNum - 2);
                    int endPage = Math.min(totalPages, pageNum + 2);
                    
                    // 首页按钮
                    if (pageNum > 1) {
                %>
                    <a href="?action=list&page=1<%= type != null ? "&type=" + type : "" %>" 
                       class="pagination-item" title="首页">
                        <i class="fas fa-angle-double-left"></i>
                    </a>
                <% } else { %>
                    <span class="pagination-item disabled" title="首页">
                        <i class="fas fa-angle-double-left"></i>
                    </span>
                <% } %>
                
                <% // 显示页码
                    for (int i = startPage; i <= endPage; i++) { 
                %>
                    <a href="?action=list&page=<%= i %><%= type != null ? "&type=" + type : "" %>" 
                       class="pagination-item <%= i == pageNum ? "active" : "" %>">
                        <%= i %>
                    </a>
                <% } %>
                
                <% // 尾页按钮
                    if (pageNum < totalPages) {
                %>
                    <a href="?action=list&page=<%= totalPages %><%= type != null ? "&type=" + type : "" %>" 
                       class="pagination-item" title="尾页">
                        <i class="fas fa-angle-double-right"></i>
                    </a>
                <% } else { %>
                    <span class="pagination-item disabled" title="尾页">
                        <i class="fas fa-angle-double-right"></i>
                    </span>
                <% } %>
                
                <% // 显示总数信息
                    if (totalCount > 0) {
                %>
                    <div style="display: flex; align-items: center; margin-left: 15px; color: #666; font-size: 14px;">
                        共 <%= totalCount %> 条记录，第 <%= pageNum %> / <%= totalPages %> 页
                    </div>
                <% } %>
            </nav>
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