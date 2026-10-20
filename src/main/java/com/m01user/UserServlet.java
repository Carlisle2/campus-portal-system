package com.m01user;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class UserServlet
 */
@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private UserDAO userDAO = new UserDAO();
    
    public UserServlet() {
        super();
    } 

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addUser(request, response);
        } else if ("update".equals(action)) {
            updateUser(request, response);
        } else if ("delete".equals(action)) {
            deleteUser(request, response);
        } else if ("query".equals(action)) {
            queryUsers(request, response);
        } else if ("edit".equals(action)) {
            editUser(request, response);
        } else {
            // 默认显示查询页面
            queryUsers(request, response);
        }
	}
	
    // 添加用户
	private void addUser(HttpServletRequest request, HttpServletResponse response) 
	        throws ServletException, IOException {
	    try {
	        UserBean user = new UserBean();
	        String roleID = request.getParameter("roleID");
	        String username = request.getParameter("username");
	        
	        // 验证ID非空
	        if (roleID == null || roleID.trim().isEmpty()) {
	            request.setAttribute("errorMsg", "用户ID不能为空！");
	            // 传递角色列表
	            List<String> allRoles = userDAO.getAllRoles();
	            request.setAttribute("allRoles", allRoles);
	            request.getRequestDispatcher("user_add.jsp").forward(request, response);
	            return;
	        }
	        
	        // 去除前后空格
	        roleID = roleID.trim();
	        
	        // 检查ID是否已存在
	        if (userDAO.checkRoleIDExists(roleID)) {
	            request.setAttribute("errorMsg", "用户ID \"" + roleID + "\" 已存在，请使用其他ID！");
	            request.setAttribute("formRoleID", roleID);
	            request.setAttribute("formUsername", username);
	            request.setAttribute("formRole", request.getParameter("role"));
	            request.setAttribute("formStatus", request.getParameter("status"));
	            request.setAttribute("formPhone", request.getParameter("phone"));      
	            request.setAttribute("formEmail", request.getParameter("email"));
	            // 传递角色列表
	            List<String> allRoles = userDAO.getAllRoles();
	            request.setAttribute("allRoles", allRoles);
	            request.getRequestDispatcher("user_add.jsp").forward(request, response);
	            return;
	        }
	        
	        // 检查用户名是否已存在
	        if (userDAO.isUsernameExists(username)) {
	            request.setAttribute("errorMsg", "用户名 \"" + username + "\" 已存在，请使用其他用户名！");
	            request.setAttribute("formRoleID", roleID);
	            request.setAttribute("formUsername", username);
	            request.setAttribute("formRole", request.getParameter("role"));
	            request.setAttribute("formStatus", request.getParameter("status"));
	            request.setAttribute("formPhone", request.getParameter("phone"));     
	            request.setAttribute("formEmail", request.getParameter("email")); 
	            // 传递角色列表
	            List<String> allRoles = userDAO.getAllRoles();
	            request.setAttribute("allRoles", allRoles);
	            request.getRequestDispatcher("user_add.jsp").forward(request, response);
	            return;
	        }
	        
	        user.setRoleID(roleID);
	        user.setFusername(username);
	        user.setFpassword(request.getParameter("password"));
	        user.setRole(request.getParameter("role"));
	        user.setStatus(request.getParameter("status"));
	        user.setPhone(request.getParameter("phone"));      
	        user.setEmail(request.getParameter("email")); 
	        
	        boolean success = userDAO.addUser(user);
	        if (success) {
	            response.sendRedirect("UserServlet?action=query&msg=add_success");
	        } else {
	            request.setAttribute("errorMsg", "添加用户失败，请重试！");
	            request.setAttribute("formRoleID", roleID);
	            request.setAttribute("formUsername", username);
	            request.setAttribute("formRole", request.getParameter("role"));
	            request.setAttribute("formStatus", request.getParameter("status"));
	            request.setAttribute("formPhone", request.getParameter("phone"));     
	            request.setAttribute("formEmail", request.getParameter("email"));
	            // 传递角色列表
	            List<String> allRoles = userDAO.getAllRoles();
	            request.setAttribute("allRoles", allRoles);
	            request.getRequestDispatcher("user_add.jsp").forward(request, response);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	        request.setAttribute("errorMsg", "系统错误：" + e.getMessage());
	        // 传递角色列表
	        List<String> allRoles = userDAO.getAllRoles();
	        request.setAttribute("allRoles", allRoles);
	        request.getRequestDispatcher("user_add.jsp").forward(request, response);
	    }
	}
    
    // 更新用户
	private void updateUser(HttpServletRequest request, HttpServletResponse response) 
	        throws ServletException, IOException {
	    try {
	        String roleID = request.getParameter("roleID");
	        UserBean user = userDAO.getUserByRoleID(roleID);
	        
	        if (user == null) {
	            response.sendRedirect("UserServlet?action=query&msg=user_not_found");
	            return;
	        }
	        
	        // 获取新用户名
	        String newUsername = request.getParameter("username");
	        
	        // 检查用户名是否已存在（排除当前用户）
	        if (!user.getFusername().equals(newUsername) && userDAO.isUsernameExists(newUsername)) {
	            request.setAttribute("errorMsg", "用户名 \"" + newUsername + "\" 已存在，请使用其他用户名！");
	            request.setAttribute("user", user);
	            request.getRequestDispatcher("user_update.jsp").forward(request, response);
	            return;
	        }
	        
	        // 更新用户信息
	        user.setFusername(newUsername); 
	        user.setFpassword(request.getParameter("password"));
	        user.setRole(request.getParameter("role"));
	        user.setStatus(request.getParameter("status"));
	        user.setPhone(request.getParameter("phone"));   
	        user.setEmail(request.getParameter("email")); 
	        
	        boolean success = userDAO.updateUser(user);
	        if (success) {
	            response.sendRedirect("UserServlet?action=query&msg=update_success");
	        } else {
	            request.setAttribute("errorMsg", "更新用户失败，请重试！");
	            request.setAttribute("user", user);
	            request.getRequestDispatcher("user_update.jsp").forward(request, response);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	        request.setAttribute("errorMsg", "系统错误：" + e.getMessage());
	        request.getRequestDispatcher("user_update.jsp").forward(request, response);
	    }
	}
    // 删除用户
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String roleID = request.getParameter("roleID");
            boolean success = userDAO.deleteUser(roleID);
            
            if (success) {
                response.sendRedirect("UserServlet?action=query&msg=delete_success");
            } else {
                response.sendRedirect("UserServlet?action=query&msg=delete_error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("UserServlet?action=query&msg=system_error");
        }
    }
    
    
    // 查询用户
    private void queryUsers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String roleID = request.getParameter("roleID");
            String username = request.getParameter("username");
            String role = request.getParameter("role");
            
            // 分页参数（设置默认值）
            int pageNum = 1;
            int pageSize = 10; // 每页显示10条
            
            try {
                String pageNumStr = request.getParameter("pageNum");
                if (pageNumStr != null && !pageNumStr.trim().isEmpty()) {
                    pageNum = Integer.parseInt(pageNumStr);
                    if (pageNum < 1) pageNum = 1;
                }
            } catch (NumberFormatException e) {
                pageNum = 1;
            }
            
            // 查询数据
            List<UserBean> userList = userDAO.queryUsersByPage(roleID, username, role, pageNum, pageSize);
            int totalCount = userDAO.getTotalCount(roleID, username, role);
            
            // 计算总页数
            int totalPage = (int) Math.ceil((double) totalCount / pageSize);
            if (totalPage == 0) totalPage = 1;
            
            // 确保当前页不超过总页数
            if (pageNum > totalPage) {
                pageNum = totalPage;
            }
            
            // ========== 获取所有角色列表 ==========
            List<String> allRoles = userDAO.getAllRoles();
            
            // 设置请求属性
            request.setAttribute("userList", userList);
            request.setAttribute("queryRoleID", roleID);
            request.setAttribute("queryUsername", username);
            request.setAttribute("queryRole", role);
            request.setAttribute("pageNum", pageNum);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalCount", totalCount);
            request.setAttribute("totalPage", totalPage);
            request.setAttribute("allRoles", allRoles); // 新增：传递角色列表
            
            // 处理消息
            String msg = request.getParameter("msg");
            if (msg != null) {
                request.setAttribute("msg", msg);
            }
            
            request.getRequestDispatcher("user_query.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "查询失败：" + e.getMessage());
            request.getRequestDispatcher("user_query.jsp").forward(request, response);
        }
    }
    
    // 编辑用户（获取用户信息）
    private void editUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String roleID = request.getParameter("roleID");
            UserBean user = userDAO.getUserByRoleID(roleID);
            
            if (user != null) {
                request.setAttribute("user", user);
                request.getRequestDispatcher("user_update.jsp").forward(request, response);
            } else {
                response.sendRedirect("UserServlet?action=query&msg=user_not_found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("UserServlet?action=query&msg=system_error");
        }
    }
}