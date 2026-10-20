<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
	List<String> allRoles = (List<String>) request.getAttribute("allRoles");
	if (allRoles == null) {
	    try {
	        // 直接创建UserDAO对象获取角色列表
	        com.m01user.UserDAO userDAO = new com.m01user.UserDAO(); 
	        allRoles = userDAO.getAllRoles();
	        request.setAttribute("allRoles", allRoles);
	    } catch (Exception e) {
	        e.printStackTrace();
	        allRoles = new ArrayList<>();
	    }
	}

    String errorMsg = (String) request.getAttribute("errorMsg");
    String formRoleID = (String) request.getAttribute("formRoleID");
    String formUsername = (String) request.getAttribute("formUsername");
    String formRole = (String) request.getAttribute("formRole");
    String formStatus = (String) request.getAttribute("formStatus");
    String formPhone = (String) request.getAttribute("formPhone");    
    String formEmail = (String) request.getAttribute("formEmail");
    
    if (formRoleID == null) formRoleID = "";
    if (formUsername == null) formUsername = "";
    if (formRole == null) formRole = "";
    if (formStatus == null) formStatus = "1";
    if (formPhone == null) formPhone = "";
    if (formEmail == null) formEmail = ""; 
%>
<html> 
<head>
    <title>用户管理 - 添加</title>
    <link rel="stylesheet" href="css/user_add.css">
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('UserServlet?action=query');
            } else {
                window.location.href = 'UserServlet?action=query';
            }
        }
        
        function checkForm() {
            const roleID = document.getElementById("roleID").value.trim();
            const username = document.getElementById("username").value.trim();
            const password = document.getElementById("password").value.trim();
            const confirmPassword = document.getElementById("confirmPassword").value.trim();
            const role = document.getElementById("role").value;
            const phone = document.getElementById("phone").value.trim();
            const email = document.getElementById("email").value.trim();

            if (roleID === "") {
                alert("用户ID不能为空！");
                return false;
            }
            if (username === "") {
                alert("用户名不能为空！");
                return false;
            }
            if (password === "") {
                alert("密码不能为空！");
                return false;
            }
            if (confirmPassword === "") {
                alert("确认密码不能为空！");
                return false;
            }
            if (password !== confirmPassword) {
                alert("两次输入的密码不一致！");
                return false;
            }
            if (role === "") {
                alert("请选择用户角色！");
                return false;
            }
            if (email !== "") {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    alert("请输入有效的邮箱地址！");
                    return false;
                }
            }
            if (phone !== "") {
                const phoneRegex = /^1[3-9]\d{9}$/;
                if (!phoneRegex.test(phone)) {
                    alert("请输入有效的手机号码！");
                    return false;
                }
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h2 class="page-title">添加用户</h2>
        
        <form class="add-form" action="UserServlet" method="post" onsubmit="return checkForm()">
            <input type="hidden" name="action" value="add">
            
            <div class="form-item">
                <label>用户ID：</label>
                <input type="text" name="roleID" id="roleID" required
                       placeholder="请输入用户ID"
                       value="<%= formRoleID %>">
            </div>
            
            <div class="form-item">
                <label>用户名：</label>
                <input type="text" name="username" id="username" required
                       placeholder="请输入用户名"
                       value="<%= formUsername %>">
            </div>
            
            <div class="form-item">
                <label>密码：</label>
                <input type="password" name="password" id="password" required>
            </div>
            
            <div class="form-item">
                <label>确认密码：</label>
                <input type="password" id="confirmPassword" required>
            </div>
            
			<div class="form-item">
			    <div style="margin-bottom: 5px;">
			        <label for="phone">电话：</label>
			        <input type="tel" name="phone" id="phone" 
			               placeholder="请输入手机号码"
			               value="<%= formPhone %>"
			               style="width: 200px; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
			    </div>
			</div>
			
			<div class="form-item">
			    <div style="margin-bottom: 5px;">
			        <label for="email">邮箱：</label>
			        <input type="email" name="email" id="email" 
			               placeholder="请输入邮箱地址"
			               value="<%= formEmail %>"
			               style="width: 200px; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
			    </div>
			</div>
            
            <div class="form-item">
                <label>角色：</label>
                <select name="role" id="role" required>
                    <option value="">请选择</option>
                    <% 
                        // 动态生成角色选项
                        if (allRoles != null && !allRoles.isEmpty()) {
                            for (String roleName : allRoles) {
                                if (roleName != null && !roleName.trim().isEmpty()) {
                    %>
                        <option value="<%= roleName %>" 
                                <%= roleName.equals(formRole) ? "selected" : "" %>>
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
            </div>
            
            <div class="form-item">
                <label>状态：</label>
                <div class="radio-group">
                    <label>
                        <input type="radio" name="status" value="1" <%= "1".equals(formStatus) ? "checked" : "" %>> 启用
                    </label>
                    <label>
                        <input type="radio" name="status" value="0" <%= "0".equals(formStatus) ? "checked" : "" %>> 禁用
                    </label>
                </div>
            </div>
            
            <div class="form-btn">
                <button type="submit" class="btn btn-primary">提交添加</button>
                <button type="button" class="btn btn-default" onclick="backToMain()">返回列表</button>
            </div>
            
            <% if (errorMsg != null) { %>
                <div class="error-msg"><%= errorMsg %></div>
            <% } %>
        </form>
    </div>
</body>
</html>