<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01role.RoleBean" %>
<%
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    RoleBean role = (RoleBean) request.getAttribute("role");
    
    if (role == null) {
        role = new RoleBean();
        role.setStatus("1"); // 默认启用
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新增角色</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/role_style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/role_form.css">
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h1>新增角色</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <% if ("success".equals(messageType)) { 
            // 显示成功信息
        %>
            <div class="success-info">
                <h3>✅ 角色添加成功！</h3>
                <div class="success-details">
                    <div class="success-item">
                        <div class="success-label">角色ID：</div>
                        <div class="success-value"><strong><%= role.getRoleID() %></strong></div>
                    </div>
                    <div class="success-item">
                        <div class="success-label">角色名称：</div>
                        <div class="success-value"><%= role.getName() %></div>
                    </div>
                    <div class="success-item">
                        <div class="success-label">角色描述：</div>
                        <div class="success-value"><%= role.getDescription() != null && !role.getDescription().isEmpty() ? 
                              role.getDescription() : "未填写" %></div>
                    </div>
                    <div class="success-item">
                        <div class="success-label">状态：</div>
                        <div class="success-value"><strong><%= "1".equals(role.getStatus()) ? "启用" : "禁用" %></strong></div>
                    </div>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-success" onclick="continueAdd()">继续添加</button>
                <button type="button" class="btn btn-primary" onclick="backToList()">返回列表</button>
            </div>
        <% } else { 
            // 显示表单
        %>
            <div class="form-container">
                <form method="post" action="<%= request.getContextPath() %>/RoleServlet" 
                      id="roleForm" onsubmit="return validateForm()">
                    <input type="hidden" name="action" value="save">
                    
                    <!-- 角色ID -->
                    <div class="form-group">
                        <label class="required">角色ID</label>
                        <input type="text" id="roleID" name="roleID" 
                               value="<%= role.getRoleID() != null ? role.getRoleID() : "" %>"
                               placeholder="请输入角色ID（唯一标识）" maxlength="50" required>
                        <div class="form-hint">角色ID必须唯一，建议使用英文或数字</div>
                    </div>
                    
                    <!-- 角色名称 -->
                    <div class="form-group">
                        <label class="required">角色名称</label>
                        <input type="text" id="name" name="name" 
                               value="<%= role.getName() != null ? role.getName() : "" %>"
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
                                       <%= "1".equals(role.getStatus()) ? "checked" : "checked" %>>
                                <label for="status_1">启用</label>
                            </div>
                            <div class="radio-item">
                                <input type="radio" id="status_0" name="status" value="0" 
                                       <%= "0".equals(role.getStatus()) ? "checked" : "" %>>
                                <label for="status_0">禁用</label>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 操作按钮 -->
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">提交添加</button>
                        <button type="button" class="btn btn-warning" onclick="clearForm()">重置表单</button>
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
        
        function continueAdd() {
            location.reload();
        }
        
        // 表单验证
        function validateForm() {
            var roleID = document.getElementById('roleID').value.trim();
            var name = document.getElementById('name').value.trim();
            
            if (roleID === '') {
                alert('请输入角色ID');
                document.getElementById('roleID').focus();
                return false;
            }
            
            if (name === '') {
                alert('请输入角色名称');
                document.getElementById('name').focus();
                return false;
            }
            
            // 角色ID只能包含字母、数字、下划线
            var roleIDPattern = /^[a-zA-Z0-9_]+$/;
            if (!roleIDPattern.test(roleID)) {
                alert('角色ID只能包含字母、数字和下划线');
                document.getElementById('roleID').focus();
                return false;
            }
            
            return true;
        }
        
        // 清空表单
        function clearForm() {
            if (confirm('确定要清空所有表单内容吗？')) {
                document.getElementById('roleForm').reset();
                // 设置默认状态为启用
                document.getElementById('status_1').checked = true;
            }
        }
        
        // 按回车键时阻止表单提交
        function handleEnterKey(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                return false;
            }
        }
        
        // 为输入框添加回车键监听
        document.getElementById('roleID')?.addEventListener('keypress', handleEnterKey);
        document.getElementById('name')?.addEventListener('keypress', handleEnterKey);
        document.getElementById('description')?.addEventListener('keypress', handleEnterKey);
    </script>
</body>
</html>