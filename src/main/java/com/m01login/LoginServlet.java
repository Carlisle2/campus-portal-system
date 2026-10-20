package com.m01login;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class TestLoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}
	

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
	        throws ServletException, IOException {
		 try {
	            // 设置编码
	            request.setCharacterEncoding("UTF-8");
	            response.setCharacterEncoding("UTF-8");
	            response.setContentType("text/html;charset=UTF-8");
	            
	            // 获取登录参数
	            String username = request.getParameter("username");
	            String password = request.getParameter("password");
	            
	            // 日志输出
	            System.out.println("=== 登录请求开始 ===");
	            System.out.println("用户名: " + username);
	            System.out.println("密码长度: " + (password != null ? password.length() : 0));
	            
	            // 创建Login对象
	            Login login = new Login();
	            
	            // 1. 先进行基础验证
	            if (!login.checkLogin(username, password)) {
	                System.out.println("基础验证失败");
	                response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
	                return;
	            }
	            
	            System.out.println("基础验证通过，开始检查用户状态...");
	            
	            // 2. 检查用户状态
	            String loginResult = login.checkUser(username, password);
	            System.out.println("登录检查结果: " + loginResult);
	            
	            // 3. 根据检查结果处理
	            if ("success".equals(loginResult)) {
	                // 登录成功
	                HttpSession session = request.getSession(); 
	                session.setAttribute("username", username);
	                response.sendRedirect(request.getContextPath() + "/frame.jsp");
	                
	            } else if ("disabled".equals(loginResult)) {
	                // 用户被禁用
	                System.out.println("用户被禁用，跳转到错误页面");
	                response.sendRedirect(request.getContextPath() + "/login.jsp?error=2");
	                
	            } else if ("invalid".equals(loginResult)) {
	                // 用户名或密码错误
	                System.out.println("用户名或密码错误");
	                response.sendRedirect(request.getContextPath() + "/login.jsp?error=1");
	                
	            } else {
	                // 系统错误或其他错误
	                System.out.println("系统错误: " + loginResult);
	                response.sendRedirect(request.getContextPath() + "/login.jsp?error=3");
	            }
	            
	        } catch (Exception e) {
	            // 异常处理
	            e.printStackTrace();
	            System.out.println("登录Servlet异常: " + e.getMessage());
	            
	            try {
	                // 尝试重定向到错误页面
	                response.sendRedirect(request.getContextPath() + "/login.jsp?error=3");
	            } catch (IOException ioException) {
	                // 如果重定向失败，直接输出错误信息
	                response.getWriter().write("服务器错误: " + e.getMessage());
	            }
	        }
	    }

}
