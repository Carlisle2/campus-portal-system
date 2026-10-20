<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01role.RoleBean" %>
<%
String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    RoleBean role = (RoleBean) request.getAttribute("role");
    
    if (role == null) {
        // 从参数中获取roleID并查询
        String roleID = request.getParameter("roleID");
        if (roleID != null) {
            com.m01role.RoleDAO dao = new com.m01role.RoleDAO();
            role = dao.getRoleByID(roleID);
        }
    }
    
    if (role == null) {
        response.sendRedirect(request.getContextPath() + "/RoleServlet?action=query");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>修改角色信息</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/role_style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/role_form.css">
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h1>修改角色信息</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <% if ("success".equals(messageType)) { %>
            <!-- 显示修改成功后的信息 -->
            <div class="submitted-info">
                <h3>✅ 角色信息修改成功！</h3>
                <div class="submitted-details">
                    <div class="submitted-item">
                        <div class="submitted-label">角色ID：</div>
                        <div class="submitted-value"><strong><%= role.getRoleID() %></strong></div>
                    </div>
                    <div class="submitted-item">
                        <div class="submitted-label">角色名称：</div>
                        <div class="submitted-value"><%= role.getName() %></div>
                    </div>
                    <div class="submitted-item">
                        <div class="submitted-label">角色描述：</div>
                        <div class="submitted-value"><%= role.getDescription() != null && !role.getDescription().isEmpty() ? 
                              role.getDescription() : "未填写" %></div>
                    </div>
                    <div class="submitted-item">
                        <div class="submitted-label">状态：</div>
                        <div class="submitted-value"><strong><%= "1".equals(role.getStatus()) ? "启用" : "禁用" %></strong></div>
                    </div>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-primary" onclick="backToList()">返回列表</button>
            </div>
        <% } else { %>
            <!-- 显示修改表单 -->
            <div class="form-container">
                <form method="post" action="<%= request.getContextPath() %>/RoleServlet" 
                      id="roleForm" onsubmit="return validateForm()">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="roleID" value="<%= role.getRoleID() %>">
                    
                    <!-- 角色ID显示（不可修改） -->
                    <div class="form-group">
                        <label>角色ID</label>
                        <div class="admin-id-display">
                            <%= role.getRoleID() %>
                        </div>
                        <div class="form-hint">角色ID是唯一标识，不可修改</div>
                    </div>
                    
                    <!-- 角色名称 -->
                    <div class="form-group">
                        <label class="required">角色名称</label>
                        <input type="text" id="name" name="name" 
                               value="<%= role.getName() %>"
                               placeholder="请输入角色名称" maxlength="100" required>
                        <div class="form-hint">角色名称将显示在用户角色选择中</div>
                    </div>
                    
                    <!-- 角色描述 -->
                    <div class="form-group">
                        <label>角色描述</label>
                        <textarea id="description" name="description" 
                                  placeholder="请输入角色描述，说明该角色的权限和职责"
                                  maxlength="500"><%= role.getDescription() != null ? role.getDescription() : "" %></textarea>
                        <div class="form-hint">最多500个字符</div>
                    </div>
                    
                    <!-- 状态 -->
                    <div class="form-group">
                        <label>状态</label>
                        <div class="radio-group">
                            <div class="radio-item">
                                <input type="radio" id="status_1" name="status" value="1" 
                                       <%= "1".equals(role.getStatus()) ? "checked" : "" %>>
                                <label for="status_1">启用</label>
                            </div>
                            <div class="radio-item">
                                <input type="radio" id="status_0" name="status" value="0" 
                                       <%= "0".equals(role.getStatus()) ? "checked" : "" %>>
                                <label for="status_0">禁用</label>
                            </div>
                        </div>
                        <div class="form-hint">禁用后，用户将无法选择此角色</div>
                    </div>
                    
                    <!-- 操作按钮 -->
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">保存修改</button>
                        <button type="button" class="btn btn-secondary" onclick="backToList()">取消返回</button>
                    </div>
                </form>
            </div>
        <% } %>
    </div>
    
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('role_query.jsp');
            } else {
                window.location.href = 'role_query.jsp';
            }
        }
        
        function backToList() {
            location.href = '<%= request.getContextPath() %>/RoleServlet?action=query';
        }
        
        // 表单验证
        function validateForm() {
            var name = document.getElementById('name').value.trim();
            
            if (name === '') {
                alert('请输入角色名称');
                document.getElementById('name').focus();
                return false;
            }
            
            return true;
        }
        
        // 按回车键时阻止表单提交
        function handleEnterKey(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                return false;
            }
        }
        
        // 为输入框添加回车键监听
        document.getElementById('name')?.addEventListener('keypress', handleEnterKey);
        document.getElementById('description')?.addEventListener('keypress', handleEnterKey);
    </script>
</body>
</html>