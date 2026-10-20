<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%
    String errorMsg = (String) request.getAttribute("errorMsg");
    String formUsername = (String) request.getAttribute("formUsername");
    String formPhone = (String) request.getAttribute("formPhone");
    String formEmail = (String) request.getAttribute("formEmail");
    List<String> availableRoles = (List<String>) request.getAttribute("availableRoles");
    
    if (formUsername == null) formUsername = "";
    if (formPhone == null) formPhone = "";
    if (formEmail == null) formEmail = "";
    
    if (availableRoles == null) {
        // 如果没有传递角色列表，创建一个默认列表
        availableRoles = java.util.Arrays.asList("学生", "讲师", "辅导员", "访客");
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 校园信息管理网站</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .role-select {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 16px;
            background: #f8f9fa;
            transition: all 0.3s;
        }
        
        .role-select:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .password-strength {
            margin-top: 5px;
            font-size: 12px;
        }
        
        .strength-weak { color: #e74c3c; }
        .strength-medium { color: #f39c12; }
        .strength-strong { color: #2ecc71; }
    </style>
    <script>
        function checkPasswordStrength() {
            const password = document.getElementById('password').value;
            const strengthText = document.getElementById('password-strength');
            
            if (password.length === 0) {
                strengthText.innerHTML = '';
                return;
            }
            
            let strength = 0;
            if (password.length >= 8) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[a-z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            if (strength <= 2) {
                strengthText.innerHTML = '密码强度：<span class="strength-weak">弱</span>';
            } else if (strength <= 4) {
                strengthText.innerHTML = '密码强度：<span class="strength-medium">中等</span>';
            } else {
                strengthText.innerHTML = '密码强度：<span class="strength-strong">强</span>';
            }
        }
        
        function validateForm() {
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const role = document.getElementById('role').value;
            
            // 验证用户名
            if (username.length < 3 || username.length > 20) {
                alert('用户名长度应在3-20个字符之间');
                return false;
            }
            
            // 验证密码
            if (password.length < 6) {
                alert('密码长度至少6位');
                return false;
            }
            
            if (password !== confirmPassword) {
                alert('两次输入的密码不一致');
                return false;
            }
            
            // 验证角色
            if (!role) {
                alert('请选择您的身份角色');
                return false;
            }
            
            return true;
        }
    </script>
</head>
<body >
    <!-- 背景图片 -->
    <img src="${pageContext.request.contextPath}/images/news/background.jpg" 
         style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: -1;
         "
         alt="背景图">
    
    <div class="auth-container">
    	<div class="auth-form-container" style="position: relative;"> 
    
            <!-- 返回首页按钮（表单区域左上角） -->
            <div class="auth-back-btn">
                <a href="${pageContext.request.contextPath}/index.jsp" class="back-home-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>返回首页</span>
                </a>
            </div>
            
            <div class="auth-header" style="margin-top: 20px;"> <!-- 添加上边距 -->
                <h1>创建账户</h1>
                <p>注册成为校园信息管理网站的用户</p>
            </div>
            
            <form class="auth-form" action="${pageContext.request.contextPath}/auth?action=doregister" 
                  method="post" onsubmit="return validateForm()">
                
                <div class="form-group">
                    <label for="username">用户名 *</label>
                    <input type="text" id="username" name="username" class="form-input" 
                           placeholder="请输入用户名（3-20位字符）" required
                           value="<%= formUsername %>">
                </div>
                
                <div class="form-group">
                    <label for="password">密码 *</label>
                    <input type="password" id="password" name="password" class="form-input" 
                           placeholder="请输入密码（至少6位）" required
                           oninput="checkPasswordStrength()">
                    <div id="password-strength" class="password-strength"></div>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">确认密码 *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-input" 
                           placeholder="请再次输入密码" required>
                </div>
                
                <div class="form-group">
                    <label for="role">身份角色 *</label>
                    <select id="role" name="role" class="role-select" required>
                        <option value="">请选择您的身份</option>
                        <% for (String role : availableRoles) { %>
                            <option value="<%= role %>"><%= role %></option>
                        <% } %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="phone">手机号码</label>
                    <input type="tel" id="phone" name="phone" class="form-input" 
                           placeholder="请输入手机号码（选填）"
                           value="<%= formPhone %>">
                </div>
                
                <div class="form-group">
                    <label for="email">邮箱地址</label>
                    <input type="email" id="email" name="email" class="form-input" 
                           placeholder="请输入邮箱地址（选填）"
                           value="<%= formEmail %>">
                </div>
                
                <button type="submit" class="auth-button">注册账户</button>
                
                <div class="auth-footer">
                    已有账户？
                    <a href="${pageContext.request.contextPath}/auth?action=login" class="auth-link">立即登录</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>