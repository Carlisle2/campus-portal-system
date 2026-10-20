package com.m01news;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "NewsServlet", urlPatterns = {"/news", "/index.jsp"})
public class NewsServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private NewsDAO newsDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        newsDAO = new NewsDAO(); 
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            // 如果没有指定action，展示首页
            showHomePage(request, response);
        } else {
            switch (action) {
                case "detail":
                    showNewsDetail(request, response);
                    break;
                case "search":
                    searchNews(request, response);
                    break;
                case "list":
                    showNewsList(request, response);
                    break;
                default:
                    showHomePage(request, response);
                    break;
            }
        }
    }
    
    // 显示首页
    private void showHomePage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 获取各区域数据
        List<NewsBean> topNews = newsDAO.getTopNews(3); // 轮播图
        List<NewsBean> importantNews = newsDAO.getImportantNews(5); // 重要通知
        List<NewsBean> studentWorkNews = newsDAO.getStudentWorkNews(5); // 学工动态
        List<NewsBean> resourceNews = newsDAO.getResourceNews(3); // 学习资源
        List<NewsBean> honorNews = newsDAO.getHonorNews(3); // 学院表彰
        List<NewsBean> eventNews = newsDAO.getEventNews(3); // 活动预告
        List<NewsBean> homeNewsList = newsDAO.getHomeNewsList(10); // 首页新闻列表
        
        // 设置到request属性中
        request.setAttribute("topNews", topNews);
        request.setAttribute("importantNews", importantNews);
        request.setAttribute("studentWorkNews", studentWorkNews);
        request.setAttribute("resourceNews", resourceNews);
        request.setAttribute("honorNews", honorNews);
        request.setAttribute("eventNews", eventNews);
        request.setAttribute("homeNewsList", homeNewsList);  
        
        // 转发到首页
        RequestDispatcher dispatcher = request.getRequestDispatcher("/front/index.jsp");
        dispatcher.forward(request, response);
    }
    
    // 显示新闻详情
    private void showNewsDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                NewsBean news = newsDAO.getNewsById(id);
                
                if (news != null) {
                    request.setAttribute("news", news);
                    RequestDispatcher dispatcher = request.getRequestDispatcher("/front/news/detail.jsp");
                    dispatcher.forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "新闻不存在");
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "参数错误");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少参数");
        }
    }
    
    // 搜索新闻
    private void searchNews(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");
        
        int page = 1;
        int pageSize = 10;
        
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        List<NewsBean> newsList = null;
        int totalCount = 0;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            keyword = keyword.trim();
            newsList = newsDAO.searchNews(keyword, page, pageSize);
            totalCount = newsDAO.getSearchCount(keyword);
        } else {
            // 如果没有关键词，显示空结果
            newsList = new ArrayList<>();
            totalCount = 0;
        }
        
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        request.setAttribute("newsList", newsList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/front/news/search.jsp");
        dispatcher.forward(request, response);
    }
    
    // 显示新闻列表（按分类）
 // 显示新闻列表（按分类）
    private void showNewsList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pageStr = request.getParameter("page");
        String type = request.getParameter("type");
        
        int page = 1;
        int pageSize = 10;
        
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        List<NewsBean> newsList;
        int totalCount;
        
        if (type != null) {
            // 按类型查询
            switch (type) {
                case "important":
                    newsList = newsDAO.getImportantNews(pageSize);
                    totalCount = newsList.size();
                    break;
                case "studentWork":
                    newsList = newsDAO.getStudentWorkNews(pageSize);
                    totalCount = newsList.size();
                    break;
                case "resource":
                    newsList = newsDAO.getResourceNews(pageSize);
                    totalCount = newsList.size();
                    break;
                case "honor":
                    newsList = newsDAO.getHonorNews(pageSize);
                    totalCount = newsList.size();
                    break;
                case "event":
                    newsList = newsDAO.getEventNews(pageSize);
                    totalCount = newsList.size();
                    break;
                default:
                    // 获取所有新闻
                    newsList = newsDAO.getAllPublishedNews(page, pageSize);
                    totalCount = newsDAO.getTotalPublishedCount();
                    break;
            }
        } else {
            // 获取所有新闻
            newsList = newsDAO.getAllPublishedNews(page, pageSize);
            totalCount = newsDAO.getTotalPublishedCount();
        }
        
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        request.setAttribute("newsList", newsList);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("type", type);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/front/news/list.jsp");
        dispatcher.forward(request, response);
    }
}