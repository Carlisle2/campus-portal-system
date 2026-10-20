package com.m01news;

import javax.servlet.*;
import javax.servlet.http.*;

import com.m01user.UserBean;
import com.m01user.UserDAO;

import javax.servlet.annotation.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.*;

@WebServlet(name = "AdminNewsServlet", urlPatterns = {"/AdminNewsServlet"})
public class AdminNewsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdminNewsDAO adminNewsDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        adminNewsDAO = new AdminNewsDAO();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    	request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                showNewsList(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteNews(request, response);
                break;
            case "changestatus":
                changeStatus(request, response);
                break;
            case "batchdelete":
                batchDeleteNews(request, response);
                break;
            case "login":
                showLoginPage(request, response);
                break;
            case "register":
                showRegisterPage(request, response);
                break;
            case "dologin":
                doLogin(request, response);
                break;
            case "doregister":
                register(request, response);
                break;
            case "logout":
                logout(request, response);
                break;
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    	request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        
        if ("save".equals(action)) {
            saveNews(request, response);
        } else if ("update".equals(action)) {
            updateNews(request, response);
        } else {
            showNewsList(request, response);
        }
    }
    
    // 显示新闻列表
    private void showNewsList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 获取查询参数
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String status = request.getParameter("status");
        String categoryIdStr = request.getParameter("categoryId");
        
        // 获取分页参数
        String pageNumStr = request.getParameter("pageNum");
        String pageSizeStr = request.getParameter("pageSize");
        
        int pageNum = 1;
        int pageSize = 10;
        Integer categoryId = null;
        
        try {
            pageNum = Integer.parseInt(pageNumStr);
            if (pageNum < 1) pageNum = 1;
        } catch (NumberFormatException e) {
            pageNum = 1;
        }
        
        try {
            pageSize = Integer.parseInt(pageSizeStr);
            if (pageSize < 1) pageSize = 10;
        } catch (NumberFormatException e) {
            pageSize = 10;
        }
        
        try {
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                categoryId = Integer.parseInt(categoryIdStr);
            }
        } catch (NumberFormatException e) {
            categoryId = null;
        }
        
        // 获取新闻列表
        List<NewsBean> newsList = adminNewsDAO.getNewsList(pageNum, pageSize, title, author, status, categoryId);
        int totalCount = adminNewsDAO.getNewsCount(title, author, status, categoryId);
        int totalPage = (int) Math.ceil((double) totalCount / pageSize);
        
        // 获取分类列表
        List<CategoryBean> categories = adminNewsDAO.getAllCategories();
        
        // 设置request属性
        request.setAttribute("newsList", newsList);
        request.setAttribute("categories", categories);
        request.setAttribute("pageNum", pageNum);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("title", title);
        request.setAttribute("author", author);
        request.setAttribute("status", status);
        request.setAttribute("categoryId", categoryId);
        
        // 转发到JSP页面
        RequestDispatcher dispatcher = request.getRequestDispatcher("news_list.jsp");
        dispatcher.forward(request, response);
    }
    
    // 显示添加表单
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 获取分类列表
        List<CategoryBean> categories = adminNewsDAO.getAllCategories();
        request.setAttribute("categories", categories);
        
        // 转发到添加页面
        RequestDispatcher dispatcher = request.getRequestDispatcher("news_add.jsp");
        dispatcher.forward(request, response);
    }
    
    // 显示编辑表单
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("AdminNewsServlet?action=list");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            NewsBean news = adminNewsDAO.getNewsById(id);
            
            if (news == null) {
                request.setAttribute("errorMsg", "新闻不存在！");
                response.sendRedirect("AdminNewsServlet?action=list");
                return;
            }
            
            // 获取分类列表
            List<CategoryBean> categories = adminNewsDAO.getAllCategories();
            
            request.setAttribute("news", news);
            request.setAttribute("categories", categories);
            
            // 转发到编辑页面
            RequestDispatcher dispatcher = request.getRequestDispatcher("news_edit.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("AdminNewsServlet?action=list");
        }
    }
    
    // 保存新闻
    private void saveNews(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            NewsBean news = createNewsFromRequest(request);
            
            // 保存新闻
            boolean success = adminNewsDAO.addNews(news);
            
            if (success) {
                response.sendRedirect("AdminNewsServlet?action=list&msg=add_success");
            } else {
                request.setAttribute("errorMsg", "添加新闻失败！");
                request.setAttribute("news", news);
                
                // 重新加载分类列表
                List<CategoryBean> categories = adminNewsDAO.getAllCategories();
                request.setAttribute("categories", categories);
                
                RequestDispatcher dispatcher = request.getRequestDispatcher("news_add.jsp");
                dispatcher.forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "系统错误：" + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("news_add.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    // 更新新闻
    private void updateNews(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect("AdminNewsServlet?action=list");
                return;
            }
            
            int id = Integer.parseInt(idStr);
            NewsBean news = createNewsFromRequest(request);
            news.setId(id);
            
            // 更新新闻
            boolean success = adminNewsDAO.updateNews(news);
            
            if (success) {
                response.sendRedirect("AdminNewsServlet?action=list&msg=update_success");
            } else {
                request.setAttribute("errorMsg", "更新新闻失败！");
                request.setAttribute("news", news);
                
                // 重新加载分类列表
                List<CategoryBean> categories = adminNewsDAO.getAllCategories();
                request.setAttribute("categories", categories);
                
                RequestDispatcher dispatcher = request.getRequestDispatcher("news_edit.jsp");
                dispatcher.forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "系统错误：" + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("news_edit.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    // 删除新闻
    private void deleteNews(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("AdminNewsServlet?action=list");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            boolean success = adminNewsDAO.deleteNews(id);
            
            if (success) {
                response.sendRedirect("AdminNewsServlet?action=list&msg=delete_success");
            } else {
                response.sendRedirect("AdminNewsServlet?action=list&msg=delete_error");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("AdminNewsServlet?action=list&msg=delete_error");
        }
    }
    
    // 批量删除新闻
    private void batchDeleteNews(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String[] ids = request.getParameterValues("ids");
        if (ids == null || ids.length == 0) {
            response.sendRedirect("AdminNewsServlet?action=list&msg=no_selection");
            return;
        }
        
        try {
            List<Integer> idList = new ArrayList<>();
            for (String idStr : ids) {
                if (idStr != null && !idStr.trim().isEmpty()) {
                    idList.add(Integer.parseInt(idStr));
                }
            }
            
            boolean success = adminNewsDAO.batchDeleteNews(idList);
            
            if (success) {
                response.sendRedirect("AdminNewsServlet?action=list&msg=batch_delete_success");
            } else {
                response.sendRedirect("AdminNewsServlet?action=list&msg=batch_delete_error");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("AdminNewsServlet?action=list&msg=batch_delete_error");
        }
    }
    
    // 更改新闻状态
    private void changeStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String idStr = request.getParameter("id");
        String status = request.getParameter("status");
        
        if (idStr == null || status == null) {
            response.sendRedirect("AdminNewsServlet?action=list");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            boolean success = adminNewsDAO.updateNewsStatus(id, status);
            
            if (success) {
                response.sendRedirect("AdminNewsServlet?action=list&msg=status_changed");
            } else {
                response.sendRedirect("AdminNewsServlet?action=list&msg=status_change_error");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("AdminNewsServlet?action=list&msg=status_change_error");
        }
    }
    
    // 从请求创建NewsBean对象
    private NewsBean createNewsFromRequest(HttpServletRequest request) {
        NewsBean news = new NewsBean();
        
        // 基本字段
        news.setTitle(request.getParameter("title"));
        news.setContent(request.getParameter("content"));
        news.setSummary(request.getParameter("summary"));
        news.setAuthor(request.getParameter("author"));
        
        // 分类
        String categoryIdStr = request.getParameter("categoryId");
        try {
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                news.setCategoryId(Integer.parseInt(categoryIdStr));
            }
        } catch (NumberFormatException e) {
            news.setCategoryId(0);
        }
        
        // 状态
        news.setStatus(request.getParameter("status"));
        
        // 区域控制字段
        news.setIsTop("on".equals(request.getParameter("isTop")));
        news.setIsImportant("on".equals(request.getParameter("isImportant")));
        news.setIsStudentWork("on".equals(request.getParameter("isStudentWork")));
        news.setIsResource("on".equals(request.getParameter("isResource")));
        news.setIsHonor("on".equals(request.getParameter("isHonor")));
        news.setIsEvent("on".equals(request.getParameter("isEvent")));
        news.setIsHomeNews("on".equals(request.getParameter("isHomeNews")));
        
        // 发布时间
        String publishTimeStr = request.getParameter("publishTime");
        if (publishTimeStr != null && !publishTimeStr.trim().isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                news.setPublishTime(sdf.parse(publishTimeStr));
            } catch (ParseException e) {
                news.setPublishTime(new Date());
            }
        } else {
            news.setPublishTime(new Date());
        }
        
        return news;
    }
    
    private void showLoginPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("front/news/login.jsp").forward(request, response);
    }

    private void showRegisterPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("front/news/register.jsp").forward(request, response);
    }

    private void register(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            
            // 检查用户名是否已存在
            UserDAO userDAO = new UserDAO();
            if (userDAO.isUsernameExists(username)) {
                request.setAttribute("errorMsg", "用户名已存在，请使用其他用户名");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.getRequestDispatcher("front/news/register.jsp").forward(request, response);
                return;
            }
            
            // 生成roleID（可以使用用户名+时间戳）
            String roleID = "U" + System.currentTimeMillis() % 1000000;
            
            // 创建用户对象
            UserBean user = new UserBean();
            user.setRoleID(roleID);
            user.setFusername(username);
            user.setFpassword(password); // 实际应用中应该加密
            user.setRole(role);
            user.setStatus("1");
            user.setPhone(phone);
            user.setEmail(email);
            
            // 添加用户
            boolean success = userDAO.addUser(user);
            
            if (success) {
                // 注册成功，重定向到登录页面
                response.sendRedirect(request.getContextPath() + "/news?action=login&registerSuccess=true");
            } else {
                request.setAttribute("errorMsg", "注册失败，请重试");
                request.setAttribute("formUsername", username);
                request.setAttribute("formPhone", phone);
                request.setAttribute("formEmail", email);
                request.getRequestDispatcher("front/news/register.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "系统错误：" + e.getMessage());
            request.getRequestDispatcher("front/news/register.jsp").forward(request, response);
        }
    }

    private void doLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String remember = request.getParameter("remember");
            
            UserDAO userDAO = new UserDAO();
            UserBean user = userDAO.getUserByUsername(username);
            
            if (user == null) {
                request.setAttribute("errorMsg", "用户名不存在");
                request.setAttribute("username", username);
                request.getRequestDispatcher("front/news/login.jsp").forward(request, response);
                return;
            }
            
            if (!user.getFpassword().equals(password)) {
                request.setAttribute("errorMsg", "密码错误");
                request.setAttribute("username", username);
                request.getRequestDispatcher("front/news/login.jsp").forward(request, response);
                return;
            }
            
            if ("0".equals(user.getStatus())) {
                request.setAttribute("errorMsg", "账户已被禁用，请联系管理员");
                request.getRequestDispatcher("front/news/login.jsp").forward(request, response);
                return;
            }
            
            // 登录成功，创建session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("username", user.getFusername());
            session.setAttribute("role", user.getRole());
            
            // 记住我功能
            if ("on".equals(remember)) {
                Cookie usernameCookie = new Cookie("username", username);
                usernameCookie.setMaxAge(7 * 24 * 60 * 60); // 7天
                response.addCookie(usernameCookie);
            }
            
            // 重定向到首页
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "登录失败：" + e.getMessage());
            request.getRequestDispatcher("front/news/login.jsp").forward(request, response);
        }
    }

    private void logout(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        // 清除cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("username".equals(cookie.getName())) {
                    cookie.setMaxAge(0);
                    response.addCookie(cookie);
                    break;
                }
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/news?action=login");
    }
}