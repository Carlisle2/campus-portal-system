<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01news.NewsBean" %>
<%@ page import="com.m01news.CategoryBean" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 检查登录状态
    String loginUser = (String) session.getAttribute("username");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取数据
    List<NewsBean> newsList = (List<NewsBean>) request.getAttribute("newsList");
    List<CategoryBean> categories = (List<CategoryBean>) request.getAttribute("categories");
    
    // 分页参数
    Integer pageNum = (Integer) request.getAttribute("pageNum");
    Integer pageSize = (Integer) request.getAttribute("pageSize");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Integer totalPage = (Integer) request.getAttribute("totalPage");
    
    // 搜索参数
    String title = (String) request.getAttribute("title");
    String author = (String) request.getAttribute("author");
    String status = (String) request.getAttribute("status");
    Integer categoryId = (Integer) request.getAttribute("categoryId");
    
    // 设置默认值
    if (pageNum == null) pageNum = 1;
    if (pageSize == null) pageSize = 10;
    if (totalCount == null) totalCount = 0;
    if (totalPage == null) totalPage = 1;
    if (title == null) title = "";
    if (author == null) author = "";
    if (status == null) status = "";
    if (categoryId == null) categoryId = 0;
    
    // 消息提示
    String msg = request.getParameter("msg");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新闻管理 - 学生管理网站后台</title>
    <!-- 使用用户管理的样式文件 -->
    <link rel="stylesheet" href="css/news_list.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('main.jsp');
            } else {
                window.location.href = 'main.jsp';
            }
        }
        
        function clearSearch() {
            document.getElementById('searchTitle').value = '';
            document.getElementById('searchAuthor').value = '';
            document.getElementById('searchStatus').value = '';
            document.getElementById('searchCategoryId').value = '';
            document.getElementById('searchForm').submit();
        }
        
        function confirmDelete(id) {
            if (confirm('确定要删除这篇新闻吗？此操作不可恢复！')) {
                window.location.href = 'AdminNewsServlet?action=delete&id=' + id;
            }
        }
        
        function changeStatus(id, currentStatus) {
            var newStatus = currentStatus === 'published' ? 'draft' : 'published';
            var actionText = currentStatus === 'published' ? '下架' : '发布';
            
            if (confirm('确定要' + actionText + '这篇新闻吗？')) {
                window.location.href = 'AdminNewsServlet?action=changestatus&id=' + id + '&status=' + newStatus;
            }
        }
        
        function previewNews(id) {
            window.open('${pageContext.request.contextPath}/news?action=detail&id=' + id, '_blank');
        }
        
        function selectAll(checkbox) {
            var checkboxes = document.getElementsByName('ids');
            for (var i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = checkbox.checked;
            }
        }
        
        function batchDelete() {
            var checkboxes = document.getElementsByName('ids');
            var selectedIds = [];
            
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked) {
                    selectedIds.push(checkboxes[i].value);
                }
            }
            
            if (selectedIds.length === 0) {
                alert('请选择要删除的新闻！');
                return;
            }
            
            if (confirm('确定要删除选中的 ' + selectedIds.length + ' 篇新闻吗？此操作不可恢复！')) {
                var form = document.getElementById('batchForm');
                form.submit();
            }
        }
        
        function batchPublish() {
            var checkboxes = document.getElementsByName('ids');
            var selectedIds = [];
            
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked) {
                    selectedIds.push(checkboxes[i].value);
                }
            }
            
            if (selectedIds.length === 0) {
                alert('请选择要发布的新闻！');
                return;
            }
            
            if (confirm('确定要发布选中的 ' + selectedIds.length + ' 篇新闻吗？')) {
                alert('批量发布功能正在开发中...');
            }
        }
        
        // 自动隐藏消息框
        setTimeout(function() {
            var msgBox = document.getElementById('msgBox');
            if (msgBox) {
                msgBox.style.display = 'none';
            }
        }, 3000);
    </script>
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h2 class="page-title">新闻管理</h2>
        
        <%-- 显示消息 --%>
        <% if ("add_success".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">新闻添加成功！</div>
        <% } else if ("update_success".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">新闻修改成功！</div>
        <% } else if ("delete_success".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">新闻删除成功！</div>
        <% } else if ("delete_error".equals(msg)) { %>
            <div id="msgBox" class="message-box error-msg">新闻删除失败！</div>
        <% } else if ("status_changed".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">新闻状态更新成功！</div>
        <% } %>
        
        <!-- 搜索区域 -->
        <div class="query-form">
            <form action="AdminNewsServlet" method="get" id="searchForm">
                <input type="hidden" name="action" value="list">
                <input type="hidden" name="pageNum" value="1">
                <input type="hidden" name="pageSize" value="<%= pageSize %>">
                
                新闻标题：<input type="text" name="title" id="searchTitle" 
                       placeholder="请输入新闻标题" value="<%= title %>">
                作者：<input type="text" name="author" id="searchAuthor"
                       placeholder="请输入作者" value="<%= author %>">
                状态：
                <select name="status" id="searchStatus">
                    <option value="">全部状态</option>
                    <option value="draft" <%= "draft".equals(status) ? "selected" : "" %>>草稿</option>
                    <option value="published" <%= "published".equals(status) ? "selected" : "" %>>已发布</option>
                </select>
                分类：
                <select name="categoryId" id="searchCategoryId">
                    <option value="">全部分类</option>
                    <% if (categories != null) { 
                        for (CategoryBean category : categories) { %>
                        <option value="<%= category.getId() %>" 
                                <%= category.getId() == categoryId ? "selected" : "" %>>
                            <%= category.getName() %>
                        </option>
                    <% } } %>
                </select>
                <button type="submit" class="btn btn-primary">查询</button>
                <button type="button" class="btn btn-warning" onclick="clearSearch()">清空</button>
                <a href="news_add.jsp" class="btn btn-success">发布新闻</a>
            </form>
        </div>

        <% if (newsList != null) { %>
            <%-- 查询结果统计 --%>
            <div class="search-stats">
                共找到 <%= totalCount %> 条新闻记录
                <% if ((title != null && !title.trim().isEmpty()) ||
                       (author != null && !author.trim().isEmpty()) ||
                       (status != null && !status.trim().isEmpty()) ||
                       (categoryId != null && categoryId > 0)) { %>
                    （已应用查询条件）
                <% } %>
            </div>

            <% if (!newsList.isEmpty()) { %>
                <!-- 批量操作 -->
                <form id="batchForm" action="AdminNewsServlet" method="post">
                    <input type="hidden" name="action" value="batchdelete">
                    <div class="batch-actions" style="background: #f8f9fa; padding: 10px; margin-bottom: 10px; border-radius: 4px;">
                        <div class="select-all" style="display: flex; align-items: center; gap: 8px;">
                            <input type="checkbox" id="selectAll" onclick="selectAll(this)">
                            <label for="selectAll" style="margin: 0;">全选</label>
                        </div>
                        <div class="batch-buttons" style="display: flex; gap: 10px;">
                            <button type="button" class="btn btn-primary" onclick="batchPublish()">
                                <i class="fas fa-paper-plane"></i> 批量发布
                            </button>
                            <button type="button" class="btn btn-danger" onclick="batchDelete()">
                                <i class="fas fa-trash"></i> 批量删除
                            </button>
                        </div>
                    </div>
                
                <!-- 新闻列表 -->
                <table class="user-table">
                    <thead>
                        <tr>
                            <th style="width: 40px;">选择</th>
                            <th style="width: 60px;">ID</th>
                            <th style="min-width: 250px;">标题</th>
                            <th style="width: 80px;">作者</th>
                            <th style="width: 80px;">分类</th>
                            <th style="width: 80px;">状态</th>
                            <th style="width: 150px;">区域</th>
                            <th style="width: 120px;">发布时间</th>
                            <th style="width: 80px;">浏览次数</th>
                            <th style="width: 180px;">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int startNo = (pageNum - 1) * pageSize + 1;
                            for (int i = 0; i < newsList.size(); i++) { 
                                NewsBean news = newsList.get(i);
                        %>
                            <tr>
                                <td>
                                    <input type="checkbox" name="ids" value="<%= news.getId() %>">
                                </td>
                                <td><%= news.getId() %></td>
                                <td class="news-title-cell" title="<%= news.getTitle() %>">
                                    <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getId() %>" 
                                       target="_blank" title="点击预览">
                                        <%= news.getTitle() %>
                                    </a>
                                </td>
                                <td><%= news.getAuthor() %></td>
                                <td><%= news.getCategoryName() != null ? news.getCategoryName() : "未分类" %></td>
                                <td class="status-<%= news.getStatus() %>">
                                    <%= "published".equals(news.getStatus()) ? "已发布" : "草稿" %>
                                </td>
                                <td>
                                    <div class="news-region-tags">
                                        <% if (news.getIsTop()) { %>
                                            <span class="region-tag region-top">轮播</span>
                                        <% } %>
                                        <% if (news.getIsImportant()) { %>
                                            <span class="region-tag region-important">重要</span>
                                        <% } %>
                                        <% if (news.getIsStudentWork()) { %>
                                            <span class="region-tag region-student-work">学工</span>
                                        <% } %>
                                        <% if (news.getIsResource()) { %>
                                            <span class="region-tag region-resource">资源</span>
                                        <% } %>
                                        <% if (news.getIsHonor()) { %>
                                            <span class="region-tag region-honor">表彰</span>
                                        <% } %>
                                        <% if (news.getIsEvent()) { %>
                                            <span class="region-tag region-event">活动</span>
                                        <% } %>
                                        <% if (news.getIsHomeNews()) { %>
                                            <span class="region-tag region-home">首页</span>
                                        <% } %>
                                        <% if (!news.getIsTop() && !news.getIsImportant() && !news.getIsStudentWork() && 
                                               !news.getIsResource() && !news.getIsHonor() && !news.getIsEvent() && 
                                               !news.getIsHomeNews()) { %>
                                            <span class="region-tag">未分配</span>
                                        <% } %>
                                    </div>
                                </td>
                                <td>
                                    <% if (news.getPublishTime() != null) { %>
                                        <%= sdf.format(news.getPublishTime()) %>
                                    <% } else { %>
                                        未发布
                                    <% } %>
                                </td>
                                <td><%= news.getViewCount() %></td>
                                <td>
                                    <div class="news-actions">
                                        <button type="button" class="action-btn action-btn-preview" 
                                                onclick="previewNews(<%= news.getId() %>)" title="浏览">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <!-- 修改：直接链接到news_edit.jsp -->
                                        <button type="button" class="action-btn action-btn-edit" 
                                                onclick="window.location.href='AdminNewsServlet?action=edit&id=<%= news.getId() %>'" title="编辑">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button type="button" class="action-btn action-btn-delete" 
                                                onclick="confirmDelete(<%= news.getId() %>)" title="删除">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                        <button type="button" class="action-btn <%= "published".equals(news.getStatus()) ? "btn-warning" : "btn-success" %>" 
                                                onclick="changeStatus(<%= news.getId() %>, '<%= news.getStatus() %>')" 
                                                title="<%= "published".equals(news.getStatus()) ? "下架" : "发布" %>" style="background: <%= "published".equals(news.getStatus()) ? "#ffc107" : "#28a745" %>; color: <%= "published".equals(news.getStatus()) ? "#212529" : "white" %>;">
                                            <i class="fas <%= "published".equals(news.getStatus()) ? "fa-arrow-down" : "fa-paper-plane" %>"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                </form>
                
                <!-- 分页控件 -->
                <% if (totalPage > 1) { %>
                    <div class="pagination-container">
                        <div class="pagination-info">
                            共 <%= totalCount %> 条记录，第 <%= pageNum %> 页/共 <%= totalPage %> 页，每页 <%= pageSize %> 条
                        </div>
                        
                        <div class="pagination-controls">
                            <%-- 构建分页链接的基本参数 --%>
                            <% 
                                String baseParams = "";
                                if (title != null && !title.trim().isEmpty()) {
                                    baseParams += "&title=" + java.net.URLEncoder.encode(title, "UTF-8");
                                }
                                if (author != null && !author.trim().isEmpty()) {
                                    baseParams += "&author=" + java.net.URLEncoder.encode(author, "UTF-8");
                                }
                                if (status != null && !status.trim().isEmpty()) {
                                    baseParams += "&status=" + status;
                                }
                                if (categoryId != null && categoryId > 0) {
                                    baseParams += "&categoryId=" + categoryId;
                                }
                            %>
                            
                            <%-- 首页按钮 --%>
                            <% if (pageNum > 1) { %>
                                <a href="AdminNewsServlet?action=list<%= baseParams %>&pageNum=1&pageSize=<%= pageSize %>" 
                                   class="btn btn-primary btn-sm">首页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">首页</span>
                            <% } %>
                            
                            <%-- 上一页按钮 --%>
                            <% if (pageNum > 1) { %>
                                <a href="AdminNewsServlet?action=list<%= baseParams %>&pageNum=<%= pageNum-1 %>&pageSize=<%= pageSize %>" 
                                   class="btn btn-primary btn-sm">上一页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">上一页</span>
                            <% } %>
                            
                            <%-- 页码显示 --%>
                            <% 
                                int startPage = Math.max(1, pageNum - 2);
                                int endPage = Math.min(totalPage, pageNum + 2);
                                
                                if (startPage > 1) {
                            %>
                                    <span class="btn btn-primary btn-sm disabled">...</span>
                            <%  }
                                
                                for (int i = startPage; i <= endPage; i++) {
                                    if (i == pageNum) {
                            %>
                                        <span class="btn btn-primary btn-sm active"><%= i %></span>
                            <%      } else { %>
                                        <a href="AdminNewsServlet?action=list<%= baseParams %>&pageNum=<%= i %>&pageSize=<%= pageSize %>" 
                                           class="btn btn-primary btn-sm"><%= i %></a>
                            <%      }
                                }
                                
                                if (endPage < totalPage) {
                            %>
                                    <span class="btn btn-primary btn-sm disabled">...</span>
                            <%  } %>
                            
                            <%-- 下一页按钮 --%>
                            <% if (pageNum < totalPage) { %>
                                <a href="AdminNewsServlet?action=list<%= baseParams %>&pageNum=<%= pageNum+1 %>&pageSize=<%= pageSize %>" 
                                   class="btn btn-primary btn-sm">下一页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">下一页</span>
                            <% } %>
                            
                            <%-- 尾页按钮 --%>
                            <% if (pageNum < totalPage) { %>
                                <a href="AdminNewsServlet?action=list<%= baseParams %>&pageNum=<%= totalPage %>&pageSize=<%= pageSize %>" 
                                   class="btn btn-primary btn-sm">尾页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">尾页</span>
                            <% } %>
                        </div>
                        
                        <div class="page-size-selector">
                            <span>每页显示：</span>
                            <select onchange="changePageSize(this.value)">
                                <option value="5" <%= pageSize == 5 ? "selected" : "" %>>5条</option>
                                <option value="10" <%= pageSize == 10 ? "selected" : "" %>>10条</option>
                                <option value="20" <%= pageSize == 20 ? "selected" : "" %>>20条</option>
                                <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50条</option>
                            </select>
                        </div>
                    </div>
                <% } %>
                
            <% } else { %>
                <div class="no-data">
                    <% if ((title != null && !title.trim().isEmpty()) ||
                           (author != null && !author.trim().isEmpty()) ||
                           (status != null && !status.trim().isEmpty()) ||
                           (categoryId != null && categoryId > 0)) { %>
                        没有找到符合条件的新闻
                    <% } else { %>
                        还没有发布新闻，点击"发布新闻"按钮开始添加
                    <% } %>
                </div>
            <% } %>
        <% } else { %>
            <div class="no-data">
                <p>请点击查询按钮查看新闻信息</p>
            </div>
        <% } %>
    </div>
    
    <script>
        function changePageSize(pageSize) {
            var form = document.getElementById('searchForm');
            var pageSizeInput = document.createElement('input');
            pageSizeInput.type = 'hidden';
            pageSizeInput.name = 'pageSize';
            pageSizeInput.value = pageSize;
            form.appendChild(pageSizeInput);
            
            var pageNumInput = document.createElement('input');
            pageNumInput.type = 'hidden';
            pageNumInput.name = 'pageNum';
            pageNumInput.value = '1';
            form.appendChild(pageNumInput);
            
            form.submit();
        }
    </script>
</body>
</html>