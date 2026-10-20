package com.m01user;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Cookie;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private FrontUserDAO userDAO = new FrontUserDAO();
    
    public AuthServlet() {
        super();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("logout".equals(action)) {
            logout(request, response);
        } else if ("register".equals(action)) {
            showRegisterPage(request, response);
        } else {
            showLoginPage(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("doregister".equals(action)) {
            register(request, response);
        } else if ("dologin".equals(action)) {
            login(request, response);
        } else {
            showLoginPage(request, response);
        }
    }
    
    // 显示登录页面
    private void showLoginPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 检查是否已登录
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // 已登录，跳转到首页
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // 检查cookie中是否有记住的用户名
        String rememberedUsername = null;
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("rememberedUsername".equals(cookie.getName())) {
                    rememberedUsername = cookie.getValue();
                    break;
                }
            }
        }
        
        if (rememberedUsername != null) {
            request.setAttribute("rememberedUsername", rememberedUsername);
        }
        
        request.getRequestDispatcher("/front/news/login.jsp").forward(request, response);
    }
    
    // 显示注册页面
    private void showRegisterPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 检查是否已登录
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // 已登录，跳转到首页
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // 获取可注册的角色列表
        request.setAttribute("availableRoles", userDAO.getAvailableRoles());
        request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
    }
    
    // 用户注册
    private void register(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String role = request.getParameter("role");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            
            // 验证必填字段
            if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
                request.setAttribute("errorMsg", "用户名和密码不能为空");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.setAttribute("availableRoles", userDAO.getAvailableRoles());
                request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
                return;
            }
            
            // 验证密码长度
            if (password.length() < 6) {
                request.setAttribute("errorMsg", "密码长度至少6位");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.setAttribute("availableRoles", userDAO.getAvailableRoles());
                request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
                return;
            }
            
            // 验证密码一致性
            if (!password.equals(confirmPassword)) {
                request.setAttribute("errorMsg", "两次输入的密码不一致");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.setAttribute("availableRoles", userDAO.getAvailableRoles());
                request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
                return;
            }
            
            // 检查用户名是否存在
            if (userDAO.checkUsernameExists(username)) {
                request.setAttribute("errorMsg", "用户名已存在，请使用其他用户名");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.setAttribute("availableRoles", userDAO.getAvailableRoles());
                request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
                return;
            }
            
            // 创建用户对象
            UserBean user = new UserBean();
            user.setFusername(username);
            user.setFpassword(password);
            user.setRole(role != null ? role : "学生");
            user.setPhone(phone);
            user.setEmail(email);
            
            // 注册用户
            boolean success = userDAO.registerUser(user);
            
            if (success) {
                // 注册成功，重定向到登录页面并显示成功消息
                response.sendRedirect(request.getContextPath() + 
                    "/auth?action=login&registerSuccess=true");
            } else {
                request.setAttribute("errorMsg", "注册失败，请重试");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.setAttribute("availableRoles", userDAO.getAvailableRoles());
                request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "系统错误：" + e.getMessage());
            request.setAttribute("availableRoles", userDAO.getAvailableRoles());
            request.getRequestDispatcher("/front/news/register.jsp").forward(request, response);
        }
    }
    
    // 用户登录
    private void login(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String remember = request.getParameter("remember");
            
            // 验证输入
            if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
                request.setAttribute("errorMsg", "用户名和密码不能为空");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/front/news/login.jsp").forward(request, response);
                return;
            }
            
            // 验证登录
            UserBean user = userDAO.login(username, password);
            
            if (user == null) {
                request.setAttribute("errorMsg", "用户名或密码错误");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/front/news/login.jsp").forward(request, response);
                return;
            }
            
            // 检查用户状态
            if ("0".equals(user.getStatus())) {
                request.setAttribute("errorMsg", "账户已被禁用，请联系管理员");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/front/news/login.jsp").forward(request, response);
                return;
            }
            
            // 更新最后登录时间
            userDAO.updateLastLogin(username);
            
            // 创建session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("username", user.getFusername());
            session.setAttribute("role", user.getRole());
            session.setMaxInactiveInterval(30 * 60); // 30分钟
            
            // 记住我功能
            if ("on".equals(remember)) {
                Cookie usernameCookie = new Cookie("rememberedUsername", username);
                usernameCookie.setMaxAge(7 * 24 * 60 * 60); // 7天
                usernameCookie.setPath("/");
                response.addCookie(usernameCookie);
            } else {
                // 清除remember me cookie
                Cookie usernameCookie = new Cookie("rememberedUsername", "");
                usernameCookie.setMaxAge(0);
                usernameCookie.setPath("/");
                response.addCookie(usernameCookie);
            }
            
            // 重定向到首页
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "登录失败：" + e.getMessage());
            request.getRequestDispatcher("/front/news/login.jsp").forward(request, response);
        }
    }
    
    // 用户登出
    private void logout(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 销毁session
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        // 清除remember me cookie
        Cookie usernameCookie = new Cookie("rememberedUsername", "");
        usernameCookie.setMaxAge(0);
        usernameCookie.setPath("/");
        response.addCookie(usernameCookie);
        
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}