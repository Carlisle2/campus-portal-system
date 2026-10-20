<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01user.UserBean" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    // 检查登录状态
    String loginUser = (String) session.getAttribute("username");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取请求参数
    List<UserBean> userList = (List<UserBean>) request.getAttribute("userList");
    String queryRoleID = (String) request.getAttribute("queryRoleID");
    String queryUsername = (String) request.getAttribute("queryUsername");
    String queryRole = (String) request.getAttribute("queryRole");
    String msg = (String) request.getAttribute("msg");
    
    // 分页参数
    Integer pageNum = (Integer) request.getAttribute("pageNum");
    Integer pageSize = (Integer) request.getAttribute("pageSize");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Integer totalPage = (Integer) request.getAttribute("totalPage");
    
    // 获取角色列表
    List<String> allRoles = (List<String>) request.getAttribute("allRoles");
    
    // 设置默认值
    if (queryRoleID == null) queryRoleID = ""; 
    if (queryUsername == null) queryUsername = ""; 
    if (queryRole == null) queryRole = "";
    if (pageNum == null) pageNum = 1;
    if (pageSize == null) pageSize = 10;
    if (totalCount == null) totalCount = 0;
    if (totalPage == null) totalPage = 1;
    if (allRoles == null) allRoles = new ArrayList<>();
    
    // 确保pageNum在有效范围内
    if (pageNum < 1) pageNum = 1;
    if (pageNum > totalPage && totalPage > 0) pageNum = totalPage;
%>
<html>
<head>
    <title>用户管理 - 查询</title>
    <link rel="stylesheet" href="css/user_query.css">
    <script>
        // JavaScript函数保持不变...
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('main.jsp');
            } else {
                window.location.href = 'main.jsp';
            }
        }
        
        function clearSearch() {
            document.getElementById('roleID').value = '';
            document.getElementById('username').value = '';
            document.getElementById('role').value = '';
            document.getElementById('searchForm').submit();
        }
        
        function confirmDelete(roleID, username) {
            if (confirm('确定要删除用户 "' + username + '" 吗？此操作不可恢复！')) {
                window.location.href = 'UserServlet?action=delete&roleID=' + roleID;
            }
        }
        
        // 分页相关函数（保持不变）
        function gotoPage() {
            var pageInput = document.getElementById('gotoPage');
            var pageNum = parseInt(pageInput.value);
            var totalPage = <%= totalPage %>;
            
            if (isNaN(pageNum) || pageNum < 1) {
                pageNum = 1;
            }
            if (pageNum > totalPage) {
                pageNum = totalPage;
            }
            
            // 构建URL
            var baseUrl = 'UserServlet?action=query';
            var roleID = document.getElementById('roleID') ? document.getElementById('roleID').value : '';
            var username = document.getElementById('username') ? document.getElementById('username').value : '';
            var role = document.getElementById('role') ? document.getElementById('role').value : '';
            var pageSize = document.getElementById('pageSizeSelect') ? document.getElementById('pageSizeSelect').value : '10';
            
            var params = '';
            if (roleID.trim() !== '') {
                params += '&roleID=' + encodeURIComponent(roleID);
            }
            if (username.trim() !== '') {
                params += '&username=' + encodeURIComponent(username);
            }
            if (role.trim() !== '') {
                params += '&role=' + encodeURIComponent(role);
            }
            
            window.location.href = baseUrl + params + '&pageNum=' + pageNum + '&pageSize=' + pageSize;
        }
        
        function changePageSize(pageSize) {
            var baseUrl = 'UserServlet?action=query';
            var roleID = document.getElementById('roleID') ? document.getElementById('roleID').value : '';
            var username = document.getElementById('username') ? document.getElementById('username').value : '';
            var role = document.getElementById('role') ? document.getElementById('role').value : '';
            
            var params = '';
            if (roleID.trim() !== '') {
                params += '&roleID=' + encodeURIComponent(roleID);
            }
            if (username.trim() !== '') {
                params += '&username=' + encodeURIComponent(username);
            }
            if (role.trim() !== '') {
                params += '&role=' + encodeURIComponent(role);
            }
            
            // 重置到第一页
            window.location.href = baseUrl + params + '&pageNum=1&pageSize=' + pageSize;
        }
        
        // 输入框回车跳转
        function initPageJump() {
            var gotoInput = document.getElementById('gotoPage');
            if (gotoInput) {
                gotoInput.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        gotoPage();
                    }
                });
            }
        }
        
        // 自动隐藏消息框
        setTimeout(function() {
            var msgBox = document.getElementById('msgBox');
            if (msgBox) {
                msgBox.style.display = 'none';
            }
        }, 3000);
        
        // 页面加载完成后初始化
        window.onload = function() {
            initPageJump();
            // 调试输出
            console.log('角色列表长度：<%= allRoles.size() %>');
            console.log('当前查询角色：<%= queryRole %>');
        };
    </script>
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h2 class="page-title">用户管理</h2>
        
        <%-- 显示操作结果消息 --%>
        <% if ("add_success".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">用户添加成功！</div>
        <% } else if ("update_success".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">用户修改成功！</div>
        <% } else if ("delete_success".equals(msg)) { %>
            <div id="msgBox" class="message-box success-msg">用户删除成功！</div>
        <% } else if ("delete_error".equals(msg)) { %>
            <div id="msgBox" class="message-box error-msg">用户删除失败！</div>
        <% } else if ("user_not_found".equals(msg)) { %>
            <div id="msgBox" class="message-box error-msg">用户不存在！</div>
        <% } else if ("system_error".equals(msg)) { %>
            <div id="msgBox" class="message-box error-msg">系统错误，请稍后重试！</div>
        <% } %>
        
		<%-- 查询表单 --%>
		<div class="query-form">
		    <form action="UserServlet" method="get" id="searchForm">
		        <input type="hidden" name="action" value="query">
		        <input type="hidden" name="pageNum" value="1">
		        用户ID：<input type="text" name="roleID" id="roleID" 
		               placeholder="请输入用户ID" value="<%= queryRoleID %>">
		        用户名：<input type="text" name="username" id="username" 
		               placeholder="请输入用户名" value="<%= queryUsername %>">
		        角色：
		        <select name="role" id="role">
		            <option value="">全部</option>
		            <% 
		                // 动态生成角色选项
		                if (allRoles != null && !allRoles.isEmpty()) {
		                    for (String roleName : allRoles) {
		                        if (roleName != null && !roleName.trim().isEmpty()) {
		            %>
		                <option value="<%= roleName %>" 
		                        <%= roleName.equals(queryRole) ? "selected" : "" %>>
		                    <%= roleName %>
		                </option>
		            <% 
		                        }
		                    }
		                } else {
		                    // 如果角色列表为空，显示提示
		            %>
		                <option value="">(暂无角色数据)</option>
		            <% 
		                }
		            %>
		        </select>
		        <button type="submit" class="btn btn-primary">查询</button>
		        <button type="button" class="btn btn-warning" onclick="clearSearch()">清空</button>
		        <a href="user_add.jsp" class="btn btn-success">添加用户</a>
		    </form>
		</div>

        <% if (userList != null) { %>
            <%-- 查询结果统计 --%>
            <div class="search-stats">
                共找到 <%= totalCount %> 条用户记录
                <% if ((queryRoleID != null && !queryRoleID.trim().isEmpty()) ||
                       (queryUsername != null && !queryUsername.trim().isEmpty()) ||
                       (queryRole != null && !queryRole.trim().isEmpty())) { %>
                    （已应用查询条件）
                <% } %>
            </div>

            <%-- 用户列表 --%>
            <% if (!userList.isEmpty()) { %>
                <table class="user-table">
                    <thead>
                        <tr>
                            <th>序号</th>
                            <th>用户ID</th>
                            <th>用户名</th>
                            <th>角色</th>
                            <th>状态</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int startNo = (pageNum - 1) * pageSize + 1;
                            for (int i = 0; i < userList.size(); i++) { 
                                UserBean user = userList.get(i);
                                String statusText = "1".equals(user.getStatus()) ? "启用" : "禁用";
                        %>
                            <tr>
                                <td><%= startNo + i %></td>
                                <td><%= user.getRoleID() %></td>
                                <td><%= user.getFusername() %></td>
                                <td><%= user.getRole() %></td>
                                <td class="<%= "1".equals(user.getStatus()) ? "status-enabled" : "status-disabled" %>">
                                    <%= statusText %>
                                </td>
                                <td class="operate">
                                    <a href="UserServlet?action=edit&roleID=<%= user.getRoleID() %>" class="btn btn-primary">修改</a>
                                    <a href="javascript:void(0)" onclick="confirmDelete('<%= user.getRoleID() %>', '<%= user.getFusername() %>')" 
                                       class="btn btn-danger">删除</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <%-- ========== 分页控件 ========== --%>
                <% if (totalPage > 1) { %>
                    <div class="pagination-container">
                        <div class="pagination-info">
                            共 <%= totalCount %> 条记录，第 <%= pageNum %> 页/共 <%= totalPage %> 页，每页 <%= pageSize %> 条
                        </div>
                        
                        <div class="pagination-controls">
                            <%-- 构建分页链接的基本参数 --%>
                            <% 
                                String baseParams = "";
                                if (queryRoleID != null && !queryRoleID.trim().isEmpty()) {
                                    baseParams += "&roleID=" + java.net.URLEncoder.encode(queryRoleID, "UTF-8");
                                }
                                if (queryUsername != null && !queryUsername.trim().isEmpty()) {
                                    baseParams += "&username=" + java.net.URLEncoder.encode(queryUsername, "UTF-8");
                                }
                                if (queryRole != null && !queryRole.trim().isEmpty()) {
                                    baseParams += "&role=" + java.net.URLEncoder.encode(queryRole, "UTF-8");
                                }
                                baseParams += "&pageSize=" + pageSize;
                            %>
                            
                            <%-- 首页按钮 --%>
                            <% if (pageNum > 1) { %>
                                <a href="UserServlet?action=query<%= baseParams %>&pageNum=1" 
                                   class="btn btn-primary btn-sm">首页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">首页</span>
                            <% } %>
                            
                            <%-- 上一页按钮 --%>
                            <% if (pageNum > 1) { %>
                                <a href="UserServlet?action=query<%= baseParams %>&pageNum=<%= pageNum-1 %>" 
                                   class="btn btn-primary btn-sm">上一页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">上一页</span>
                            <% } %>
                            
                            <%-- 页码显示 --%>
                            <% 
                                int startPage = Math.max(1, pageNum - 2);
                                int endPage = Math.min(totalPage, pageNum + 2);
                                
                                // 显示省略号
                                if (startPage > 1) {
                            %>
                                    <span class="btn btn-primary btn-sm disabled">...</span>
                            <%  }
                                
                                for (int i = startPage; i <= endPage; i++) {
                                    if (i == pageNum) {
                            %>
                                        <span class="btn btn-primary btn-sm active"><%= i %></span>
                            <%      } else { %>
                                        <a href="UserServlet?action=query<%= baseParams %>&pageNum=<%= i %>" 
                                           class="btn btn-primary btn-sm"><%= i %></a>
                            <%      }
                                }
                                
                                if (endPage < totalPage) {
                            %>
                                    <span class="btn btn-primary btn-sm disabled">...</span>
                            <%  } %>
                            
                            <%-- 下一页按钮 --%>
                            <% if (pageNum < totalPage) { %>
                                <a href="UserServlet?action=query<%= baseParams %>&pageNum=<%= pageNum+1 %>" 
                                   class="btn btn-primary btn-sm">下一页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">下一页</span>
                            <% } %>
                            
                            <%-- 尾页按钮 --%>
                            <% if (pageNum < totalPage) { %>
                                <a href="UserServlet?action=query<%= baseParams %>&pageNum=<%= totalPage %>" 
                                   class="btn btn-primary btn-sm">尾页</a>
                            <% } else { %>
                                <span class="btn btn-primary btn-sm disabled">尾页</span>
                            <% } %>
                            
                            <%-- 快速跳转 --%>
                            <span class="page-jump">
                                跳转到第 
                                <input type="number" id="gotoPage" min="1" max="<%= totalPage %>" 
                                       value="<%= pageNum %>" style="width: 50px; padding: 3px; text-align: center;">
                                页
                                <button onclick="gotoPage()" class="btn btn-warning btn-sm">跳转</button>
                            </span>
                        </div>
                        
                        <div class="page-size-selector">
                            <span>每页显示：</span>
                            <select id="pageSizeSelect" onchange="changePageSize(this.value)">
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
                    <% if ((queryRoleID != null && !queryRoleID.trim().isEmpty()) ||
                           (queryUsername != null && !queryUsername.trim().isEmpty()) ||
                           (queryRole != null && !queryRole.trim().isEmpty())) { %>
                        没有找到符合条件的用户
                    <% } else { %>
                        没有找到用户数据
                    <% } %>
                </div>
            <% } %>
        <% } else { %>
            <div class="no-data">
                <p>请点击查询按钮查看用户信息</p>
            </div>
        <% } %>
    </div>
</body>
</html>