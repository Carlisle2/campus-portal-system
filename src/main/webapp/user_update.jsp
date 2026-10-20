<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01user.UserBean" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    UserBean user = (UserBean) request.getAttribute("user");
    String errorMsg = (String) request.getAttribute("errorMsg");
    // 获取角色列表，如果没有则从数据库获取
    List<String> allRoles = (List<String>) request.getAttribute("allRoles");
    if (allRoles == null) {
        try {
            com.m01user.UserDAO userDAO = new com.m01user.UserDAO();
            allRoles = userDAO.getAllRoles();
            request.setAttribute("allRoles", allRoles);
        } catch (Exception e) {
            e.printStackTrace();
            allRoles = new ArrayList<>();
        }
    }
    if (allRoles == null) allRoles = new ArrayList<>();
%>
<html>
<head>
    <title>用户管理 - 修改</title>
    <link rel="stylesheet" href="css/user_update.css">
    <script>
        function backToMain() { 
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('UserServlet?action=query');
            } else {
                window.location.href = 'UserServlet?action=query';
            }
        }
        
        function checkForm() { 
            const username = document.getElementById("username").value.trim();
            const password = document.getElementById("password").value.trim();
            const confirmPassword = document.getElementById("confirmPassword").value.trim();
            const role = document.getElementById("role").value;
            const phone = document.getElementById("phone").value.trim();
            const email = document.getElementById("email").value.trim();

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
                const phoneRegex = /^1[3-9]\d{9}$/;  // 简单的手机号验证
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
        <h2 class="page-title">修改用户</h2>
        
        <% if (user == null) { %>
            <div class="error-msg">用户信息不存在！</div>
            <div class="form-btn">
                <button type="button" class="btn btn-default" onclick="backToMain()">返回列表</button>
            </div>
        <% } else { %>
            <form class="edit-form" action="UserServlet" method="post" onsubmit="return checkForm()">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="roleID" value="<%= user.getRoleID() %>">
                
                <div class="form-item">
                    <label>用户ID：</label>
                    <input type="text" value="<%= user.getRoleID() %>" class="disabled-input" disabled>
                </div>
                
                <div class="form-item">
                    <label>用户名：</label>
                    <input type="text" name="username" id="username" required
                           placeholder="请输入用户名"
                           value="<%= user.getFusername() %>">
                </div>
                
                <div class="form-item">
                    <label>密码：</label>
                    <input type="password" name="password" id="password" required
                           value="<%= user.getFpassword() %>">
                </div>
                
                <div class="form-item">
                    <label>确认密码：</label>
                    <input type="password" id="confirmPassword" required>
                </div>
                
                <div class="form-item">
                    <label>电话：</label>
                    <input type="tel" name="phone" id="phone" required
                           placeholder="请输入手机号码"
                           value="<%= user.getPhone() != null ? user.getPhone() : "" %>"
                           style="width: 200px; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                
                <div class="form-item">
                    <label>邮箱：</label>
                    <input type="email" name="email" id="email" required
                           placeholder="请输入邮箱地址"
                           value="<%= user.getEmail() != null ? user.getEmail() : "" %>"
                           style="width: 200px; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px;">
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
                                    <%= roleName.equals(user.getRole()) ? "selected" : "" %>>
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
                            <input type="radio" name="status" value="1" <%= "1".equals(user.getStatus()) ? "checked" : "" %>> 启用
                        </label>
                        <label>
                            <input type="radio" name="status" value="0" <%= "0".equals(user.getStatus()) ? "checked" : "" %>> 禁用
                        </label>
                    </div>
                </div>
                
                <div class="form-btn">
                    <button type="submit" class="btn btn-primary">提交修改</button>
                    <button type="button" class="btn btn-default" onclick="backToMain()">返回列表</button>
                </div>
                
                <% if (errorMsg != null) { %>
                    <div class="error-msg"><%= errorMsg %></div>
                <% } %>
            </form>
            
            <script>
                // 密码处理函数
                function handlePasswordChange() {
                    const passwordInput = document.getElementById("password");
                    const confirmPasswordInput = document.getElementById("confirmPassword");
                    
                    if (passwordInput.value.trim() === "") {
                        // 如果密码为空，将确认密码设为可选
                        confirmPasswordInput.removeAttribute("required");
                    } else {
                        // 如果密码不为空，将确认密码设为必填
                        confirmPasswordInput.setAttribute("required", "required");
                    }
                }
                
                // 修改表单验证逻辑
                function checkForm() {
                    const username = document.getElementById("username").value.trim();
                    const password = document.getElementById("password").value.trim();
                    const confirmPassword = document.getElementById("confirmPassword").value.trim();
                    const role = document.getElementById("role").value;

                    // 用户名验证
                    if (username === "") {
                        alert("用户名不能为空！");
                        return false;
                    }
                    
                    // 密码验证
                    if (password !== "") {
                        // 如果输入了密码，需要验证确认密码
                        if (confirmPassword === "") {
                            alert("请输入确认密码！");
                            return false;
                        }
                        if (password !== confirmPassword) {
                            alert("两次输入的密码不一致！");
                            return false;
                        }
                    }
                    
                    // 角色验证
                    if (role === "") {
                        alert("请选择用户角色！");
                        return false;
                    }
                    
                    return true;
                }
                
                // 初始化页面
                window.onload = function() {
                    // 初始调用一次，设置确认密码字段的状态
                    handlePasswordChange();
                    
                    // 将原始密码保存在隐藏字段中（如果需要保持原密码）
                    const passwordInput = document.getElementById("password");
                    const originalPassword = "<%= user.getFpassword() %>";

                };
            </script>
        <% } %>
    </div>
</body>
</html>