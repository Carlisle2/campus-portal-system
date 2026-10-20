// RoleServlet.java
package com.m01role;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.List;

@WebServlet("/RoleServlet")
public class RoleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private RoleDAO dao = new RoleDAO();
       
    public RoleServlet() {
        super();  
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8"); 
        
        // 检查用户是否登录且为系统管理员
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username != null && !dao.isSystemAdmin(username)) {
            request.setAttribute("message", "权限不足！需要系统管理员权限才能操作角色管理。");
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("/role_query.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("query".equals(action)) {
            handleQuery(request, response);
        } else if ("update".equals(action)) {
            handleEdit(request, response);
        } else if ("add".equals(action)) {
            handleAdd(request, response);
        } else if ("delete".equals(action)) {
            handleDelete(request, response);
        } else if ("view".equals(action)) {
            handleView(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/role_query.jsp");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 检查用户是否登录且为系统管理员
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username != null && !dao.isSystemAdmin(username)) {
            request.setAttribute("message", "权限不足！需要系统管理员权限才能操作角色管理。");
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("/role_query.jsp").forward(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("save".equals(action)) {
            handleSave(request, response, username);
        } else if ("update".equals(action)) {
            handleUpdate(request, response, username);
        } else {
            doGet(request, response);
        }
    }
    
    /**
     * 处理查询请求
     */
    private void handleQuery(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String roleID = request.getParameter("roleID");
        String name = request.getParameter("name");
        String status = request.getParameter("status");
        
        // 分页参数
        int currentPage = 1;
        int pageSize = 10;
        
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
        
        // 获取总记录数
        int totalCount = dao.getTotalCount(roleID, name, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        // 确保当前页在有效范围内
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
        
        // 获取分页数据
        List<RoleBean> roleList = dao.searchRoles(roleID, name, status, currentPage, pageSize);
        
        // 获取所有角色名称（用于查询下拉框）- 使用现有方法转换
        List<RoleBean> allRoles = dao.getAllRoles();
        List<String> allRoleNames = new ArrayList<>();
        for (RoleBean role : allRoles) {
            allRoleNames.add(role.getName());
        }
        
        // 设置请求属性
        request.setAttribute("roleList", roleList);
        request.setAttribute("allRoleNames", allRoleNames);
        request.setAttribute("roleID", roleID);
        request.setAttribute("name", name);
        request.setAttribute("status", status);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPages", totalPages);
        
        request.getRequestDispatcher("/role_query.jsp").forward(request, response);
    }
    
    /**
     * 处理编辑请求
     */
    private void handleEdit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String roleID = request.getParameter("roleID");
        RoleBean role = dao.getRoleByID(roleID);
        
        if (role != null) {
            request.setAttribute("role", role);
            request.getRequestDispatcher("/role_update.jsp").forward(request, response);
        } else {
            request.setAttribute("message", "角色不存在");
            request.setAttribute("messageType", "error");
            handleQuery(request, response);
        }
    }
    
    /**
     * 处理添加页面请求
     */
    private void handleAdd(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/role_add.jsp").forward(request, response);
    }
    
    /**
     * 处理删除请求
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String roleID = request.getParameter("roleID");
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        boolean success = dao.deleteRole(roleID, username);
        
        if (success) {
            request.setAttribute("message", "删除成功");
            request.setAttribute("messageType", "success");
        } else {
            request.setAttribute("message", "删除失败，可能该角色已被用户使用或您没有权限");
            request.setAttribute("messageType", "error");
        }
        
        // 删除后返回查询页面
        handleQuery(request, response);
    }
    
    /**
     * 处理查看详情请求
     */
    private void handleView(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String roleID = request.getParameter("roleID");
        RoleBean role = dao.getRoleByID(roleID);
        
        if (role != null) {
            request.setAttribute("role", role);
            request.getRequestDispatcher("/role_update.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/RoleServlet?action=query");
        }
    }
    
    /**
     * 处理保存（新增）请求
     */
    private void handleSave(HttpServletRequest request, HttpServletResponse response, String username) 
            throws ServletException, IOException {
        try {
            RoleBean bean = new RoleBean();
            
            // 获取表单数据
            bean.setRoleID(request.getParameter("roleID"));
            bean.setName(request.getParameter("name"));
            bean.setDescription(request.getParameter("description"));
            bean.setStatus(request.getParameter("status"));
            
            // 验证数据
            if (bean.getRoleID() == null || bean.getRoleID().trim().isEmpty()) {
                request.setAttribute("message", "角色ID不能为空");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_add.jsp").forward(request, response);
                return;
            }
            
            if (bean.getName() == null || bean.getName().trim().isEmpty()) {
                request.setAttribute("message", "角色名称不能为空");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_add.jsp").forward(request, response);
                return;
            }
            
            // 检查角色ID是否已存在
            if (dao.isRoleIDExists(bean.getRoleID())) {
                request.setAttribute("message", "角色ID已存在，请使用其他ID");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_add.jsp").forward(request, response);
                return;
            }
            
            // 检查角色名称是否已存在
            if (dao.isRoleNameExists(bean.getName(), null)) {
                request.setAttribute("message", "角色名称已存在，请使用其他名称");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_add.jsp").forward(request, response);
                return;
            }
            
            // 保存到数据库
            boolean success = dao.addRole(bean, username);
            
            if (success) {
                request.setAttribute("message", "角色添加成功！");
                request.setAttribute("messageType", "success");
                request.setAttribute("role", bean);
            } else {
                request.setAttribute("message", "添加失败，请检查权限或联系管理员");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
            }
            
            request.getRequestDispatcher("/role_add.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("message", "操作失败：" + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("/role_add.jsp").forward(request, response);
        }
    }
    
    /**
     * 处理更新请求
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, String username) 
            throws ServletException, IOException {
        try {
            RoleBean bean = new RoleBean();
            
            // 获取表单数据
            bean.setRoleID(request.getParameter("roleID"));
            bean.setName(request.getParameter("name"));
            bean.setDescription(request.getParameter("description"));
            bean.setStatus(request.getParameter("status"));
            
            // 验证数据
            if (bean.getRoleID() == null || bean.getRoleID().trim().isEmpty()) {
                request.setAttribute("message", "角色ID不能为空");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_update.jsp").forward(request, response);
                return;
            }
            
            if (bean.getName() == null || bean.getName().trim().isEmpty()) {
                request.setAttribute("message", "角色名称不能为空");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_update.jsp").forward(request, response);
                return;
            }
            
            // 检查角色名称是否已存在（排除自身）
            if (dao.isRoleNameExists(bean.getName(), bean.getRoleID())) {
                request.setAttribute("message", "角色名称已存在，请使用其他名称");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
                request.getRequestDispatcher("/role_update.jsp").forward(request, response);
                return;
            }
            
            // 更新到数据库
            boolean success = dao.updateRole(bean, username);
            
            if (success) {
                request.setAttribute("message", "角色信息修改成功");
                request.setAttribute("messageType", "success");
                request.setAttribute("role", bean);
            } else {
                request.setAttribute("message", "修改失败，请检查权限或联系管理员");
                request.setAttribute("messageType", "error");
                request.setAttribute("role", bean);
            }
            
            request.getRequestDispatcher("/role_update.jsp").forward(request, response);
            
        } catch (Exception e) {
            request.setAttribute("message", "操作失败：" + e.getMessage());
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("/role_update.jsp").forward(request, response);
        }
    }
}