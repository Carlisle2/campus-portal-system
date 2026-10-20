<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 检查登录状态
    String loginUser = (String) session.getAttribute("username");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取数据
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    List<Map<String, Object>> recentNewsData = (List<Map<String, Object>>) request.getAttribute("recentNewsData");
    List<Map<String, Object>> categoryStats = (List<Map<String, Object>>) request.getAttribute("categoryStats");
    List<Map<String, Object>> userRoleStats = (List<Map<String, Object>>) request.getAttribute("userRoleStats");
    List<Map<String, Object>> recentUsers = (List<Map<String, Object>>) request.getAttribute("recentUsers");
    Map<String, String> systemInfo = (Map<String, String>) request.getAttribute("systemInfo");
    List<Map<String, Object>> popularNews = (List<Map<String, Object>>) request.getAttribute("popularNews");
    
    // 设置默认值
    if (stats == null) stats = new HashMap<>();
    if (recentNewsData == null) recentNewsData = new java.util.ArrayList<>();
    if (categoryStats == null) categoryStats = new java.util.ArrayList<>();
    if (userRoleStats == null) userRoleStats = new java.util.ArrayList<>();
    if (recentUsers == null) recentUsers = new java.util.ArrayList<>();
    if (systemInfo == null) systemInfo = new HashMap<>();
    if (popularNews == null) popularNews = new java.util.ArrayList<>();
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统仪表盘 - 学生管理网站后台</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <!-- 引入Chart.js用于图表 -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h2 class="page-title">系统仪表盘</h2>
        
        <!-- 欢迎信息 -->
        <div class="welcome-section">
            <div class="welcome-card">
                <div class="welcome-icon">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="welcome-content">
                    <h2>欢迎回来，<%= loginUser %>！</h2>
                    <p>今天是 <%= new java.text.SimpleDateFormat("yyyy年MM月dd日 EEEE").format(new java.util.Date()) %></p>
                </div>
            </div>
        </div>
        
        <!-- 数据统计卡片 -->
        <div class="stats-grid">
            <!-- 用户统计 -->
            <div class="stats-card card-blue">
                <div class="stats-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stats-content">
                    <h3><%= stats.getOrDefault("user_count", 0) %></h3>
                    <p>用户总数</p>
                </div>
                <div class="stats-extra">
                    <span class="stats-trend">
                        <i class="fas fa-user-check"></i> 
                        活跃：<%= stats.getOrDefault("active_user_count", 0) %>
                    </span>
                </div>
            </div>
            
            <!-- 新闻统计 -->
            <div class="stats-card card-green">
                <div class="stats-icon">
                    <i class="fas fa-newspaper"></i>
                </div>
                <div class="stats-content">
                    <h3><%= stats.getOrDefault("news_count", 0) %></h3>
                    <p>新闻总数</p>
                </div>
                <div class="stats-extra">
                    <span class="stats-trend">
                        <i class="fas fa-paper-plane"></i> 
                        已发布：<%= stats.getOrDefault("published_news_count", 0) %>
                    </span>
                </div>
            </div>
            
            <!-- 今日统计 -->
            <div class="stats-card card-orange">
                <div class="stats-icon">
                    <i class="fas fa-calendar-day"></i>
                </div>
                <div class="stats-content">
                    <h3><%= stats.getOrDefault("today_news_count", 0) %></h3>
                    <p>今日新增</p>
                </div>
                <div class="stats-extra">
                    <span class="stats-trend">
                        <i class="fas fa-eye"></i> 
                        访问量：<%= stats.getOrDefault("today_visit", 0) %>
                    </span>
                </div>
            </div>
            
            <!-- 分类统计 -->
            <div class="stats-card card-purple">
                <div class="stats-icon">
                    <i class="fas fa-folder"></i>
                </div>
                <div class="stats-content">
                    <h3><%= stats.getOrDefault("category_count", 0) %></h3>
                    <p>分类数量</p>
                </div>
                <div class="stats-extra">
                    <span class="stats-trend">
                        <i class="fas fa-cogs"></i> 
                        角色：<%= stats.getOrDefault("role_count", 0) %>
                    </span>
                </div>
            </div>
        </div>
        
        <!-- 图表区域 -->
        <div class="charts-section">
            <div class="chart-row">
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-line"></i> 新闻发布趋势 (近30天)</h3>
                    </div>
                    <div class="chart-body">
                        <canvas id="newsTrendChart"></canvas>
                    </div>
                </div>
                
                <div class="chart-card">
                    <div class="chart-header">
                        <h3><i class="fas fa-chart-pie"></i> 新闻分类分布</h3>
                    </div>
                    <div class="chart-body">
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 详细信息区域 -->
        <div class="details-section">
            <div class="detail-row">
                <!-- 热门新闻 -->
                <div class="detail-card">
                    <div class="detail-header">
                        <h3><i class="fas fa-fire"></i> 热门新闻 Top 5</h3>
                        <a href="news_list.jsp" class="detail-more">更多</a>
                    </div>
                    <div class="detail-body">
                        <ul class="detail-list">
                            <% for (Map<String, Object> news : popularNews) { %>
                            <li class="detail-item">
                                <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.get("id") %>" 
                                   target="_blank" class="detail-item-title">
                                    <%= news.get("title") %>
                                </a>
                                <div class="detail-item-meta">
                                    <span><i class="far fa-eye"></i> <%= news.get("view_count") %> 阅读</span>
                                    <span><i class="far fa-calendar"></i> 
                                        <%= news.get("publish_time") != null ? 
                                            new SimpleDateFormat("MM-dd").format(news.get("publish_time")) : "" %>
                                    </span>
                                </div>
                            </li>
                            <% } %>
                            <% if (popularNews.isEmpty()) { %>
                            <li class="detail-item">
                                <div class="detail-item-title">暂无热门新闻</div>
                            </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
                
				<!-- 系统管理员 -->
				<div class="detail-card">
				    <div class="detail-header">
				        <h3><i class="fas fa-user-shield"></i> 系统管理员</h3>
				        <a href="user_query.jsp?role=系统管理员" class="detail-more">更多</a>
				    </div>
				    <div class="detail-body">
				        <ul class="detail-list">
				            <% 
				            // 注意：这里使用 adminUsers 而不是 recentUsers
				            List<Map<String, Object>> adminUsers = (List<Map<String, Object>>) request.getAttribute("adminUsers");
				            if (adminUsers == null) adminUsers = new java.util.ArrayList<>();
				            %>
				            
				            <% for (Map<String, Object> admin : adminUsers) { %>
				            <li class="detail-item">
				                <div class="detail-item-title">
				                    <i class="fas fa-user-tie"></i> <%= admin.get("username") %>
				                </div>
				                <div class="detail-item-meta">
				                    <span class="role-tag role-admin">系统管理员</span>
				                    <span><i class="fas fa-user-check"></i> 
				                        <%= "1".equals(admin.get("status")) ? "启用" : "禁用" %>
				                    </span>
				                </div>
				            </li>
				            <% } %>
				            
				            <% if (adminUsers.isEmpty()) { %>
				            <li class="detail-item">
				                <div class="detail-item-title">暂无系统管理员</div>
				            </li>
				            <% } %>
				        </ul>
				    </div>
				</div>
            </div>
            
            <!-- 快捷操作 -->
            <div class="detail-card quick-actions-card">
                <div class="detail-header">
                    <h3><i class="fas fa-bolt"></i> 快捷操作</h3>
                </div>
                <div class="detail-body">
                    <div class="quick-actions-grid">
                        <a href="news_add.jsp" class="quick-action">
                            <div class="quick-action-icon">
                                <i class="fas fa-plus-circle"></i>
                            </div>
                            <div class="quick-action-text">发布新闻</div>
                        </a>
                        
                        <a href="user_query.jsp" class="quick-action">
                            <div class="quick-action-icon">
                                <i class="fas fa-user-plus"></i>
                            </div>
                            <div class="quick-action-text">添加用户</div>
                        </a>
                        
                        <a href="role_query.jsp" class="quick-action">
                            <div class="quick-action-icon">
                                <i class="fas fa-user-tag"></i>
                            </div>
                            <div class="quick-action-text">角色管理</div>
                        </a>
                        
                        <a href="news_list.jsp" class="quick-action">
                            <div class="quick-action-icon">
                                <i class="fas fa-list"></i>
                            </div>
                            <div class="quick-action-text">新闻管理</div>
                        </a>
                        
                        <a href="#" class="quick-action">
                            <div class="quick-action-icon">
                                <i class="fas fa-chart-bar"></i>
                            </div>
                            <div class="quick-action-text">数据统计</div>
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- 系统信息 -->
            <div class="detail-card system-info-card">
                <div class="detail-header">
                    <h3><i class="fas fa-info-circle"></i> 系统信息</h3>
                </div>
                <div class="detail-body">
                    <div class="system-info-grid">
                        <div class="system-info-item">
                            <span class="info-label">数据库版本：</span>
                            <span class="info-value"><%= systemInfo.getOrDefault("db_version", "Unknown") %></span>
                        </div>
                        <div class="system-info-item">
                            <span class="info-label">数据表数量：</span>
                            <span class="info-value"><%= systemInfo.getOrDefault("table_count", "0") %></span>
                        </div>
                        <div class="system-info-item">
                            <span class="info-label">Java版本：</span>
                            <span class="info-value"><%= systemInfo.getOrDefault("java_version", "Unknown") %></span>
                        </div>
                        <div class="system-info-item">
                            <span class="info-label">操作系统：</span>
                            <span class="info-value"><%= systemInfo.getOrDefault("os_name", "Unknown") %> <%= systemInfo.getOrDefault("os_version", "") %></span>
                        </div>
                        <div class="system-info-item">
                            <span class="info-label">最早新闻：</span>
                            <span class="info-value"><%= systemInfo.getOrDefault("earliest_news_date", "N/A") %></span>
                        </div>
                        <div class="system-info-item">
                            <span class="info-label">当前时间：</span>
                            <span class="info-value"><%= sdf.format(new java.util.Date()) %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('main.jsp');
            } else {
                window.location.href = 'main.jsp';
            }
        }
        
        // 初始化图表
        document.addEventListener('DOMContentLoaded', function() {
            // 新闻发布趋势图
            const newsTrendCtx = document.getElementById('newsTrendChart').getContext('2d');
            const newsTrendData = <%= getNewsTrendData(recentNewsData) %>;
            
            new Chart(newsTrendCtx, {
                type: 'line',
                data: {
                    labels: newsTrendData.labels,
                    datasets: [{
                        label: '新闻数量',
                        data: newsTrendData.data,
                        borderColor: '#0066cc',
                        backgroundColor: 'rgba(0, 102, 204, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1
                            }
                        }
                    }
                }
            });
            
            // 新闻分类饼图
            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            const categoryData = <%= getCategoryChartData(categoryStats) %>;
            
            new Chart(categoryCtx, {
                type: 'pie',
                data: {
                    labels: categoryData.labels,
                    datasets: [{
                        data: categoryData.data,
                        backgroundColor: [
                            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', 
                            '#9966FF', '#FF9F40', '#C9CBCF', '#7CB342'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'right'
                        }
                    }
                }
            });
        });
        
        // 刷新仪表盘数据
        function refreshDashboard() {
            location.reload();
        }
        
        // 每5分钟自动刷新一次
        setInterval(refreshDashboard, 5 * 60 * 1000);
    </script>
</body>
</html>

<%!
    // JSP函数：生成新闻趋势数据
    private String getNewsTrendData(List<Map<String, Object>> recentNewsData) {
        if (recentNewsData == null || recentNewsData.isEmpty()) {
            return "{labels: [], data: []}";
        }
        
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        
        for (int i = 0; i < recentNewsData.size(); i++) {
            Map<String, Object> item = recentNewsData.get(i);
            String date = (String) item.get("date");
            Integer count = (Integer) item.get("count");
            
            // 只显示月份和日期
            String shortDate = date.substring(5);
            labels.append("\"").append(shortDate).append("\"");
            data.append(count);
            
            if (i < recentNewsData.size() - 1) {
                labels.append(", ");
                data.append(", ");
            }
        }
        
        labels.append("]");
        data.append("]");
        
        return "{labels: " + labels.toString() + ", data: " + data.toString() + "}";
    }
    
    // JSP函数：生成分类图表数据
    private String getCategoryChartData(List<Map<String, Object>> categoryStats) {
        if (categoryStats == null || categoryStats.isEmpty()) {
            return "{labels: ['无数据'], data: [1]}";
        }
        
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        
        for (int i = 0; i < categoryStats.size(); i++) {
            Map<String, Object> item = categoryStats.get(i);
            String category = (String) item.get("category");
            Integer count = (Integer) item.get("count");
            
            labels.append("\"").append(category).append("\"");
            data.append(count);
            
            if (i < categoryStats.size() - 1) {
                labels.append(", ");
                data.append(", ");
            }
        }
        
        labels.append("]");
        data.append("]");
        
        return "{labels: " + labels.toString() + ", data: " + data.toString() + "}";
    }
%>