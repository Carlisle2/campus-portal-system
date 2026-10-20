<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01user.UserBean" %>
<%@ page import="com.m01news.NewsBean" %>
<%@ page import="java.util.List" %>
<%
    // 检查是否从退出登录跳转过来
    String logoutSuccess = request.getParameter("logoutSuccess");
    String fromLogout = request.getParameter("from");
    
    // 如果直接访问index.jsp，重定向到Servlet
    if (request.getAttribute("topNews") == null) {
        response.sendRedirect(request.getContextPath() + "/news");
        return;
    }

    // 从request中获取数据
    List<NewsBean> topNews = (List<NewsBean>) request.getAttribute("topNews");
    List<NewsBean> importantNews = (List<NewsBean>) request.getAttribute("importantNews");
    List<NewsBean> studentWorkNews = (List<NewsBean>) request.getAttribute("studentWorkNews");
    List<NewsBean> resourceNews = (List<NewsBean>) request.getAttribute("resourceNews");
    List<NewsBean> honorNews = (List<NewsBean>) request.getAttribute("honorNews");
    List<NewsBean> eventNews = (List<NewsBean>) request.getAttribute("eventNews");
    List<NewsBean> homeNewsList = (List<NewsBean>) request.getAttribute("homeNewsList");
    
    // 设置默认值
    if (topNews == null) topNews = new java.util.ArrayList<>();
    if (importantNews == null) importantNews = new java.util.ArrayList<>();
    if (studentWorkNews == null) studentWorkNews = new java.util.ArrayList<>();
    if (resourceNews == null) resourceNews = new java.util.ArrayList<>();
    if (honorNews == null) honorNews = new java.util.ArrayList<>();
    if (eventNews == null) eventNews = new java.util.ArrayList<>();
    if (homeNewsList == null) homeNewsList = new java.util.ArrayList<>();
    
    // 检查用户是否登录
    UserBean user = (UserBean) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园信息管理网站</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/front.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <%-- 显示退出成功消息 --%>
    <% if (fromLogout != null && fromLogout.equals("nav") && username == null) { %>
    <div class="logout-message">
        您已成功退出登录。
        <button onclick="this.parentElement.style.display='none'">×</button>
    </div>
    <style>
        .logout-message {
            background-color: #d4edda;
            color: #155724;
            padding: 12px 20px;
            border-radius: 4px;
            margin: 10px auto;
            max-width: 1200px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border: 1px solid #c3e6cb;
            animation: fadeInOut 3s ease-in-out;
        }
        
        .logout-message button {
            background: none;
            border: none;
            color: #155724;
            font-size: 18px;
            cursor: pointer;
            padding: 0 5px;
        }
        
        @keyframes fadeInOut {
            0% { opacity: 0; transform: translateY(-10px); }
            10% { opacity: 1; transform: translateY(0); }
            90% { opacity: 1; transform: translateY(0); }
            100% { opacity: 0; transform: translateY(-10px); }
        }
    </style>
    <script>
        // 3秒后自动隐藏消息
        setTimeout(function() {
            const msg = document.querySelector('.logout-message');
            if (msg) {
                msg.style.display = 'none';
            }
        }, 3000);
    </script>
    <% } %>

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

    <!-- 轮播图区域 -->
    <section class="carousel-section">
        <div class="container">
            <div class="carousel" id="mainCarousel">
                <% if (!topNews.isEmpty()) { %>
                    <% for (int i = 0; i < topNews.size(); i++) { 
                        NewsBean news = topNews.get(i);
                        int bannerIndex = (i % 3) + 1;
                    %>
                        <div class="carousel-slide <%= i == 0 ? "active" : "" %>">
                            <!-- 修改图片获取逻辑 -->
                            <img src="images/news/banner<%= bannerIndex %>.jpg" 
                                 alt="<%= news.getTitle() %>" class="carousel-image">
                            <div class="carousel-caption">
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>" class="carousel-title">
                                    <%= news.getTitle() %>
                                </a>
                                <% if (news.getSummary() != null && !news.getSummary().isEmpty()) { %>
                                    <p class="carousel-summary"><%= news.getSummary() %></p>
                                <% } %>
                            </div>
                        </div> 
                    <% } %>
                <% } else { %>
                    <div class="carousel-slide active">
                        <!-- 默认轮播图 -->
                        <img src="images/news/default-banner.jpg" alt="默认轮播图" class="carousel-image">
                        <div class="carousel-caption">
                            <h2 class="carousel-title">欢迎访问学生管理网站</h2>
                            <p class="carousel-summary">为师生提供优质的信息服务</p>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </section>

    <!-- 主要内容区域 -->
    <main class="container main-content">
        <!-- 左侧主要内容 -->
        <div class="left-content">
            <!-- 重要通知区域 -->
            <div class="content-block">
                <div class="block-header">
                    <h3 class="block-title">重要通知</h3>
                    <a href="${pageContext.request.contextPath}/news?action=list&type=important" class="more-link">更多 <i class="fas fa-angle-right"></i></a>
                </div>
                <div class="block-content">
                    <ul class="news-list">
                        <% for (NewsBean news : importantNews) { %>
                            <li class="news-item">
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>">
                                	<div class="news-title"><%= news.getTitle() %></div>
                                </a>
                                <div class="news-meta">
                                    <span><i class="far fa-calendar"></i> <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(news.getPublishTime()) %></span>
                                    <span><i class="far fa-eye"></i> <%= news.getViewCount() %></span>
                                    <span><i class="far fa-user"></i> <%= news.getAuthor() %></span>
                                </div>   
                            </li>
                        <% } %>
                        <% if (importantNews.isEmpty()) { %>
                            <li class="news-item">
                                <div class="news-title">暂无重要通知</div>
                            </li>
                        <% } %>
                    </ul>
                </div>
            </div>

            <!-- 学工动态区域 -->
            <div class="content-block">
                <div class="block-header">
                    <h3 class="block-title">学工动态</h3>
                    <a href="${pageContext.request.contextPath}/news?action=list&type=studentWork" class="more-link">更多 <i class="fas fa-angle-right"></i></a>
                </div>
                <div class="block-content">
                    <div class="carousel-list">
                        <% for (int i = 0; i < studentWorkNews.size(); i++) { 
                            NewsBean news = studentWorkNews.get(i);
                            // 根据索引选择学工动态图片 (1-5)
                            int newsIndex = (i % 5) + 1;
                        %>
                            <div class="carousel-item">
                                <!-- 修改图片获取逻辑 -->
                                <img src="images/news/news<%= newsIndex %>.jpg" 
                                     alt="<%= news.getTitle() %>">
                                <div class="carousel-item-info">
                                    <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>" class="carousel-item-title">
                                        <%= news.getTitle() %>
                                    </a>
                                    <% if (news.getSummary() != null && news.getSummary().length() > 80) { %>
                                        <p class="carousel-item-summary"><%= news.getSummary().substring(0, 80) %>...</p>
                                    <% } else if (news.getSummary() != null) { %>
                                        <p class="carousel-item-summary"><%= news.getSummary() %></p>
                                    <% } %>
                                </div>
                            </div>
                        <% } %>
                        <% if (studentWorkNews.isEmpty()) { %>
                            <div class="carousel-item">
                                <!-- 默认新闻图片 -->
                                <img src="images/news/default-news.jpg" alt="默认图片">
                                <div class="carousel-item-info">
                                    <h4 class="carousel-item-title">暂无学工动态</h4>
                                    <p class="carousel-item-summary">请等待更新...</p>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- 优秀学生展示 -->
            <div class="content-block student-showcase">
                <div class="block-header">
                    <h3 class="block-title">优秀学生展示</h3>
                </div>
                <div class="block-content">
                    <div class="student-grid">
                        <!-- 这里可以硬编码展示优秀学生，或者通过数据库查询 -->
                        <div class="student-card">
                            <img src="images/news/student1.jpg" alt="优秀学生" class="student-photo">
                            <div class="student-info">
                                <h4 class="student-name">刘若童</h4>
                                <p class="student-class">计算机科学与技术2023级</p>
                                <p class="student-achievement">获得国家奖学金，多次获得校级三好学生称号，参与多项科研项目。</p>
                            </div>
                        </div>
                        <div class="student-card">
                            <img src="images/news/student2.jpg" alt="优秀学生" class="student-photo">
                            <div class="student-info">
                                <h4 class="student-name">赵梓航</h4>
                                <p class="student-class">软件工程2024级</p>
                                <p class="student-achievement">ACM竞赛省级一等奖，参与开发多个实际项目，具有丰富的实践经验。</p>
                            </div>
                        </div>
                        <div class="student-card">
                            <img src="images/news/student3.jpg" alt="优秀学生" class="student-photo">
                            <div class="student-info">
                                <h4 class="student-name">李淑琪</h4>
                                <p class="student-class">网络工程2022级</p>
                                <p class="student-achievement">发表学术论文2篇，获得专利1项，积极参与社会实践活动。</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 学院新闻/班级动态 -->
            <div class="content-block">
                <div class="block-header">
                    <h3 class="block-title">学院新闻 / 班级动态</h3>
                    <a href="${pageContext.request.contextPath}/news?action=list" class="more-link">更多 <i class="fas fa-angle-right"></i></a>
                </div>
                <div class="block-content">
                    <ul class="news-list">
                        <% for (NewsBean news : homeNewsList) { %>
                            <li class="news-item">
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>">
                                    <div class="news-title">
                                        <span class="news-category"><%= news.getCategoryName() != null ? "[" + news.getCategoryName() + "]" : "" %></span>
                                        <%= news.getTitle() %>
                                    </div>
                                    </a>
                                    <div class="news-meta">
                                        <span><i class="far fa-calendar"></i> <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(news.getPublishTime()) %></span>
                                        <span><i class="far fa-eye"></i> <%= news.getViewCount() %></span>
                                        <span><i class="far fa-user"></i> <%= news.getAuthor() %></span>
                                    </div>
                            </li>
                        <% } %>
                        <% if (homeNewsList.isEmpty()) { %>
                            <li class="news-item">
                                <div class="news-title">暂无新闻动态</div>
                            </li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 右侧边栏 -->
        <aside class="right-content">
            <!-- 学习资源 -->
            <div class="content-block" style="margin-bottom: 30px;">
                <div class="block-header">
                    <h3 class="block-title">学习资源</h3>
                </div>
                <div class="block-content">
                    <div class="intro-block">
                        <div class="intro-icon">
                            <i class="fas fa-book-open"></i>
                        </div>
                        <h4 class="intro-title">学习资料下载</h4>
                        <p class="intro-content">
                            <% if (!resourceNews.isEmpty()) { %>
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= resourceNews.get(0).getId() %>">
                                    <%= resourceNews.get(0).getTitle() %>
                                </a>
                            <% } else { %>
                                提供各类学习资料、课件下载
                            <% } %>
                        </p>
                    </div>
                </div>
            </div>

            <!-- 学院表彰 -->
            <div class="content-block" style="margin-bottom: 30px;">
                <div class="block-header">
                    <h3 class="block-title">学院表彰</h3>
                </div>
                <div class="block-content">
                    <div class="intro-block">
                        <div class="intro-icon">
                            <i class="fas fa-award"></i>
                        </div>
                        <h4 class="intro-title">荣誉表彰</h4>
                        <p class="intro-content">
                            <% if (!honorNews.isEmpty()) { %>
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= honorNews.get(0).getId() %>">
                                    <%= honorNews.get(0).getTitle() %>
                                </a>
                            <% } else { %>
                                展示学院获得的各项荣誉和表彰
                            <% } %>
                        </p>
                    </div>
                </div>
            </div>

            <!-- 活动预告 -->
            <div class="content-block">
                <div class="block-header">
                    <h3 class="block-title">活动预告</h3>
                </div>
                <div class="block-content">
                    <div class="intro-block">
                        <div class="intro-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                        <h4 class="intro-title">近期活动</h4>
                        <p class="intro-content">
                            <% if (!eventNews.isEmpty()) { %>
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= eventNews.get(0).getId() %>">
                                    <%= eventNews.get(0).getTitle() %>
                                </a>
                            <% } else { %>
                                发布即将举办的活动信息
                            <% } %>
                        </p>
                    </div>
                </div>
            </div>
        </aside>
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

    <script>
        // 轮播图自动播放
        document.addEventListener('DOMContentLoaded', function() {
            const carousel = document.getElementById('mainCarousel');
            if (carousel) {
                const slides = carousel.querySelectorAll('.carousel-slide');
                let currentSlide = 0;
                
                function showSlide(index) {
                    slides.forEach((slide, i) => {
                        slide.classList.toggle('active', i === index);
                    });
                }
                
                function nextSlide() {
                    currentSlide = (currentSlide + 1) % slides.length;
                    showSlide(currentSlide);
                }
                
                // 每5秒切换一次
                setInterval(nextSlide, 5000);
            }
        });
    </script>
</body>
</html>