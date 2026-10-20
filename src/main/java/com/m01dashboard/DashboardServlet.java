// DashboardServlet.java
package com.m01dashboard;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet; 
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Map;
import java.util.List;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DashboardDAO dashboardDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        dashboardDAO = new DashboardDAO();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 检查用户是否登录
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) { 
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // 获取所有统计数据0
        Map<String, Integer> stats = dashboardDAO.getSystemStats();
        List<Map<String, Object>> recentNewsData = dashboardDAO.getRecentNewsData(30);
        List<Map<String, Object>> categoryStats = dashboardDAO.getNewsCategoryStats();
        List<Map<String, Object>> userRoleStats = dashboardDAO.getUserRoleStats();
        List<Map<String, Object>> adminUsers = dashboardDAO.getAdminUsers(5);
        Map<String, String> systemInfo = dashboardDAO.getSystemInfo();
        List<Map<String, Object>> popularNews = dashboardDAO.getPopularNews(5);
        
        // 设置请求属性
        request.setAttribute("stats", stats);
        request.setAttribute("recentNewsData", recentNewsData);
        request.setAttribute("categoryStats", categoryStats);
        request.setAttribute("userRoleStats", userRoleStats);
        request.setAttribute("adminUsers", adminUsers); 
        request.setAttribute("systemInfo", systemInfo);
        request.setAttribute("popularNews", popularNews);
        
        // 转发到仪表盘页面
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}