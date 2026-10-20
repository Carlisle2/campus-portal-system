// DashboardDAO.java
package com.m01dashboard;

import pub.ConnDB;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {
    
    // 获取系统统计数据
    public Map<String, Integer> getSystemStats() {
        Map<String, Integer> stats = new HashMap<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            
            // 用户总数
            String userSql = "SELECT COUNT(*) as user_count FROM user";
            try (PreparedStatement pstmt = conn.prepareStatement(userSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("user_count", rs.getInt("user_count"));
                }
            }
            
            // 角色总数
            String roleSql = "SELECT COUNT(*) as role_count FROM role";
            try (PreparedStatement pstmt = conn.prepareStatement(roleSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("role_count", rs.getInt("role_count"));
                }
            }
            
            // 新闻总数
            String newsSql = "SELECT COUNT(*) as news_count FROM news";
            try (PreparedStatement pstmt = conn.prepareStatement(newsSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("news_count", rs.getInt("news_count"));
                }
            }
            
            // 已发布新闻数
            String publishedNewsSql = "SELECT COUNT(*) as published_news_count FROM news WHERE status = 'published'";
            try (PreparedStatement pstmt = conn.prepareStatement(publishedNewsSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("published_news_count", rs.getInt("published_news_count"));
                }
            }
            
            // 今日新增新闻数
            String todayNewsSql = "SELECT COUNT(*) as today_news_count FROM news WHERE DATE(created_at) = CURDATE()";
            try (PreparedStatement pstmt = conn.prepareStatement(todayNewsSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("today_news_count", rs.getInt("today_news_count"));
                }
            }
            
            // 启用用户数
            String activeUserSql = "SELECT COUNT(*) as active_user_count FROM user WHERE status = '1'";
            try (PreparedStatement pstmt = conn.prepareStatement(activeUserSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("active_user_count", rs.getInt("active_user_count"));
                }
            }
            
            // 分类总数
            String categorySql = "SELECT COUNT(*) as category_count FROM categories";
            try (PreparedStatement pstmt = conn.prepareStatement(categorySql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("category_count", rs.getInt("category_count"));
                }
            }
            
            // 今日访问量（模拟数据，实际需要访问日志表）
            stats.put("today_visit", 158);
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        // 设置默认值
        stats.putIfAbsent("user_count", 0);
        stats.putIfAbsent("role_count", 0);
        stats.putIfAbsent("news_count", 0);
        stats.putIfAbsent("published_news_count", 0);
        stats.putIfAbsent("today_news_count", 0);
        stats.putIfAbsent("active_user_count", 0);
        stats.putIfAbsent("category_count", 0);
        stats.putIfAbsent("today_visit", 0);
        
        return stats;
    }
    
    // 获取最近新闻数据（用于图表）
    public List<Map<String, Object>> getRecentNewsData(int days) {
        List<Map<String, Object>> data = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT DATE(created_at) as date, COUNT(*) as count " +
                        "FROM news " +
                        "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
                        "GROUP BY DATE(created_at) " +
                        "ORDER BY date";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, days);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("date", rs.getString("date"));
                        item.put("count", rs.getInt("count"));
                        data.add(item);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return data;
    }
    
    // 获取新闻分类统计
    public List<Map<String, Object>> getNewsCategoryStats() {
        List<Map<String, Object>> data = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT c.name as category, COUNT(n.id) as count " +
                        "FROM categories c " +
                        "LEFT JOIN news n ON c.id = n.category_id " +
                        "GROUP BY c.id, c.name " +
                        "ORDER BY count DESC";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("category", rs.getString("category"));
                    item.put("count", rs.getInt("count"));
                    data.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return data;
    }
    
    // 获取用户角色分布
    public List<Map<String, Object>> getUserRoleStats() {
        List<Map<String, Object>> data = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT role, COUNT(*) as count FROM user GROUP BY role ORDER BY count DESC";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("role", rs.getString("role"));
                    item.put("count", rs.getInt("count"));
                    data.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return data;
    }
    
    // 获取系统状态信息
    public Map<String, String> getSystemInfo() {
        Map<String, String> info = new HashMap<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            
            // 数据库版本
            String dbVersionSql = "SELECT VERSION() as version";
            try (PreparedStatement pstmt = conn.prepareStatement(dbVersionSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    info.put("db_version", rs.getString("version"));
                }
            }
            
            // 数据表数量
            String tableCountSql = "SELECT COUNT(*) as table_count FROM information_schema.tables " +
                                  "WHERE table_schema = DATABASE()";
            try (PreparedStatement pstmt = conn.prepareStatement(tableCountSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    info.put("table_count", rs.getString("table_count"));
                }
            }
            
            // 最早的新闻创建时间
            String earliestNewsSql = "SELECT MIN(created_at) as earliest_date FROM news";
            try (PreparedStatement pstmt = conn.prepareStatement(earliestNewsSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    info.put("earliest_news_date", rs.getString("earliest_date"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        // 添加系统信息
        info.putIfAbsent("db_version", "Unknown");
        info.putIfAbsent("table_count", "0");
        info.putIfAbsent("earliest_news_date", "N/A");
        info.put("java_version", System.getProperty("java.version"));
        info.put("os_name", System.getProperty("os.name"));
        info.put("os_version", System.getProperty("os.version"));
        
        return info;
    }
    
    // 获取热门新闻（按浏览次数）
    public List<Map<String, Object>> getPopularNews(int limit) {
        List<Map<String, Object>> newsList = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT id, title, view_count, author, publish_time " +
                        "FROM news " +
                        "WHERE status = 'published' " +
                        "ORDER BY view_count DESC " +
                        "LIMIT ?";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, limit);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> news = new HashMap<>();
                        news.put("id", rs.getInt("id"));
                        news.put("title", rs.getString("title"));
                        news.put("view_count", rs.getInt("view_count"));
                        news.put("author", rs.getString("author"));
                        news.put("publish_time", rs.getTimestamp("publish_time"));
                        newsList.add(news);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return newsList;
    }

    public List<Map<String, Object>> getAdminUsers(int limit) {
        List<Map<String, Object>> admins = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = ConnDB.getConnection();
            // 只显示角色为"系统管理员"的用户
            String sql = "SELECT fusername, role, status FROM user WHERE role = '系统管理员' ORDER BY fusername LIMIT ?";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> admin = new HashMap<>();
                admin.put("username", rs.getString("fusername"));
                admin.put("role", rs.getString("role"));
                admin.put("status", rs.getString("status"));
                admins.add(admin);
            }
            
            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return admins;
    }
}