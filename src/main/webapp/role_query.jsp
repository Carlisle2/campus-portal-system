<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01role.RoleBean" %>
<%@ page import="java.util.List" %>
<%
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");

    // 获取查询参数
    String roleID = request.getParameter("roleID");
    String name = request.getParameter("name");
    String status = request.getParameter("status");
    
    // 分页参数
    int currentPage = (Integer) request.getAttribute("currentPage") != null ? 
                     (Integer) request.getAttribute("currentPage") : 1;
    int pageSize = (Integer) request.getAttribute("pageSize") != null ? 
                   (Integer) request.getAttribute("pageSize") : 10;
    int totalCount = (Integer) request.getAttribute("totalCount") != null ? 
                     (Integer) request.getAttribute("totalCount") : 0;
    int totalPages = (Integer) request.getAttribute("totalPages") != null ? 
                     (Integer) request.getAttribute("totalPages") : 0;
    
    List<RoleBean> roleList = (List<RoleBean>) request.getAttribute("roleList");
    List<String> allRoleNames = (List<String>) request.getAttribute("allRoleNames");

%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>角色管理</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/role_style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/role_query.css">
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h1>角色管理</h1>
        
        <!-- 查询表单 -->
        <div class="search-form">
            <h3>角色查询</h3>
            <form method="get" action="<%= request.getContextPath() %>/RoleServlet" id="searchForm">
                <input type="hidden" name="action" value="query">
                <div class="search-row">
                    <div class="search-field">
                        <label>角色ID：</label>
                        <input type="text" id="roleID" name="roleID" 
                               value="<%= roleID != null ? roleID : "" %>" 
                               placeholder="请输入角色ID">
                    </div>

                    <div class="search-field">
                        <label>角色名称：</label>
                        <select id="name" name="name">
                            <option value="">-- 请选择角色 --</option>
                            <% 
                                if (allRoleNames != null) {
                                    for (String roleName : allRoleNames) {
                            %>
                                <option value="<%= roleName %>" 
                                        <%= roleName.equals(name) ? "selected" : "" %>>
                                    <%= roleName %>
                                </option>
                            <% 
                                    }
                                }
                            %>
                        </select>
                    </div>
                    
                    <div class="search-field">
                        <label>状态：</label>
                        <select id="status" name="status">
                            <option value="all" <%= "all".equals(status) || status == null ? "selected" : "" %>>全部</option>
                            <option value="1" <%= "1".equals(status) ? "selected" : "" %>>启用</option>
                            <option value="0" <%= "0".equals(status) ? "selected" : "" %>>禁用</option>
                        </select>
                    </div>
                    
                    <div class="search-actions">
                        <button type="submit" class="btn btn-primary">查询</button>
                        <button type="button" class="btn btn-warning" onclick="clearSearch()">清空</button>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- 查询结果统计 -->
        <% if (roleList != null) { %>
            <div class="search-stats">
                共找到 <%= totalCount %> 个角色
                <% if ((roleID != null && !roleID.trim().isEmpty()) ||
                       (name != null && !name.trim().isEmpty()) ||
                       (status != null && !"all".equals(status))) { %>
                    （已应用查询条件）
                <% } %>
            </div>
        <% } %>
        
        <div class="page-header">
            <h2>角色列表</h2>
            <div class="page-actions">
                <a href="<%= request.getContextPath() %>/RoleServlet?action=add" class="btn btn-success">新增角色</a>
            </div>
        </div>
        
        <!-- 角色列表 -->
        <div class="table-container">
            <% if (roleList != null && !roleList.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>序号</th>
                            <th>角色ID</th>
                            <th>角色名称</th>
                            <th>角色描述</th>
                            <th>状态</th>
                            <th>创建时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int index = 1;
                            for (RoleBean bean : roleList) { 
                        %>
                            <tr>
                                <td><%= (currentPage - 1) * pageSize + index++ %></td>
                                <td><strong><%= bean.getRoleID() %></strong></td>
                                <td><%= bean.getName() %></td>
                                <td><%= bean.getDescription() != null ? 
                                      (bean.getDescription().length() > 20 ? 
                                       bean.getDescription().substring(0, 20) + "..." : 
                                       bean.getDescription()) : "" %></td>
                                <td>
                                    <span class="<%= "1".equals(bean.getStatus()) ? "status-active" : "status-inactive" %>">
                                        <%= bean.getStatusText() %>
                                    </span>
                                </td>
                                <td><%= bean.getCreatedTime() != null ? 
                                      bean.getCreatedTime().substring(0, 19) : "" %></td>
                                <td class="action-cell">
                                    <a href="<%= request.getContextPath() %>/RoleServlet?action=update&roleID=<%= bean.getRoleID() %>" 
                                       class="btn btn-warning" title="修改角色信息">修改</a>
                                    <a href="#" onclick="return confirmDelete('<%= bean.getRoleID() %>', '<%= bean.getName() %>')" 
                                       class="btn btn-danger" title="删除角色">删除</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <!-- 分页 -->
                <% if (totalPages > 1) { %>
                    <div class="pagination">
                        <% if (currentPage > 1) { %>
                            <a href="<%= request.getContextPath() %>/RoleServlet?action=query&page=1&roleID=<%= roleID != null ? roleID : "" %>&name=<%= name != null ? name : "" %>&status=<%= status != null ? status : "" %>" 
                               class="btn btn-primary">首页</a>
                            <a href="<%= request.getContextPath() %>/RoleServlet?action=query&page=<%= currentPage-1 %>&roleID=<%= roleID != null ? roleID : "" %>&name=<%= name != null ? name : "" %>&status=<%= status != null ? status : "" %>" 
                               class="btn btn-primary">上一页</a>
                        <% } %>
                        
                        <% 
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);
                            for (int i = startPage; i <= endPage; i++) { 
                        %>
                            <a href="<%= request.getContextPath() %>/RoleServlet?action=query&page=<%= i %>&roleID=<%= roleID != null ? roleID : "" %>&name=<%= name != null ? name : "" %>&status=<%= status != null ? status : "" %>" 
                               class="btn <%= i == currentPage ? "disabled" : "btn-primary" %>"><%= i %></a>
                        <% } %>
                        
                        <% if (currentPage < totalPages) { %>
                            <a href="<%= request.getContextPath() %>/RoleServlet?action=query&page=<%= currentPage+1 %>&roleID=<%= roleID != null ? roleID : "" %>&name=<%= name != null ? name : "" %>&status=<%= status != null ? status : "" %>" 
                               class="btn btn-primary">下一页</a>
                            <a href="<%= request.getContextPath() %>/RoleServlet?action=query&page=<%= totalPages %>&roleID=<%= roleID != null ? roleID : "" %>&name=<%= name != null ? name : "" %>&status=<%= status != null ? status : "" %>" 
                               class="btn btn-primary">末页</a>
                        <% } %>
                        
                        <span class="page-info">
                            共 <%= totalCount %> 条记录，第 <%= currentPage %> / <%= totalPages %> 页
                            跳转到 <input type="number" id="jumpPage" min="1" max="<%= totalPages %>" 
                                    value="<%= currentPage %>" onchange="jumpToPage(this.value)" style="width: 50px;"> 页
                        </span>
                    </div>
                <% } %>
                
            <% } else if (roleList != null) { %>
                <div class="no-data">没有找到符合条件的角色</div>
            <% } else { %>
                <div class="no-data">请点击查询按钮查看角色信息</div>
            <% } %>
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
        
        // 清空查询条件
        function clearSearch() {
            document.getElementById('roleID').value = '';
            document.getElementById('name').value = '';
            document.getElementById('status').value = 'all';
        }
        
        // 确认删除
        function confirmDelete(roleID, roleName) {
            if (confirm('确定删除角色：' + roleName + '？\n注意：如果该角色已被用户使用，则无法删除。')) {
                location.href = '<%= request.getContextPath() %>/RoleServlet?action=delete&roleID=' + roleID;
            }
            return false;
        }
        
        // 跳转到指定页
        function jumpToPage(page) {
            var roleID = document.getElementById('roleID').value;
            var name = document.getElementById('name').value;
            var status = document.getElementById('status').value;
            
            var url = '<%= request.getContextPath() %>/RoleServlet?action=query&page=' + page;
            if (roleID) url += '&roleID=' + encodeURIComponent(roleID);
            if (name) url += '&name=' + encodeURIComponent(name);
            if (status && status !== 'all') url += '&status=' + encodeURIComponent(status);
            
            location.href = url;
        }
        
        // 按回车键触发查询
        function handleKeyPress(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                document.getElementById('searchForm').submit();
            }
        }
        
        // 页面加载后检查是否有消息
        window.onload = function() {
            <% if (message != null && !message.trim().isEmpty()) { %>
                // 有消息，弹出提示框
                alert("<%= message %>");
            <% } %>
        };
    </script>
</body>
</html>