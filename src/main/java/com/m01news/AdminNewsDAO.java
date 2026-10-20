package com.m01news;

import pub.ConnDB;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminNewsDAO {
    
    // 获取新闻列表（带分页和搜索）
    public List<NewsBean> getNewsList(int pageNum, int pageSize, String title, String author, String status, Integer categoryId) {
        List<NewsBean> list = new ArrayList<>();
        
        // 构建SQL基础查询
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT n.*, c.name as category_name FROM news n ");
        sqlBuilder.append("LEFT JOIN categories c ON n.category_id = c.id ");
        sqlBuilder.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        // 添加搜索条件
        if (title != null && !title.trim().isEmpty()) {
            sqlBuilder.append("AND n.title LIKE ? ");
            params.add("%" + title + "%");
        }
        
        if (author != null && !author.trim().isEmpty()) {
            sqlBuilder.append("AND n.author LIKE ? ");
            params.add("%" + author + "%");
        }
        
        if (status != null && !status.trim().isEmpty() && !"all".equals(status)) {
            sqlBuilder.append("AND n.status = ? ");
            params.add(status);
        }
        
        if (categoryId != null && categoryId > 0) {
            sqlBuilder.append("AND n.category_id = ? ");
            params.add(categoryId);
        }
        
        // 排序和分页
        sqlBuilder.append("ORDER BY n.created_at DESC LIMIT ?, ?");
        
        // 计算分页偏移量
        int offset = (pageNum - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlBuilder.toString())) {
            
            // 设置参数
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(resultSetToNews(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // 获取新闻总数（用于分页）
    public int getNewsCount(String title, String author, String status, Integer categoryId) {
        int count = 0;
        
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT COUNT(*) FROM news n WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (title != null && !title.trim().isEmpty()) {
            sqlBuilder.append("AND n.title LIKE ? ");
            params.add("%" + title + "%");
        }
        
        if (author != null && !author.trim().isEmpty()) {
            sqlBuilder.append("AND n.author LIKE ? ");
            params.add("%" + author + "%");
        }
        
        if (status != null && !status.trim().isEmpty() && !"all".equals(status)) {
            sqlBuilder.append("AND n.status = ? ");
            params.add(status);
        }
        
        if (categoryId != null && categoryId > 0) {
            sqlBuilder.append("AND n.category_id = ? ");
            params.add(categoryId);
        }
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlBuilder.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    
    // 获取所有分类
    public List<CategoryBean> getAllCategories() {
        List<CategoryBean> categories = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY sort_order";
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                CategoryBean category = new CategoryBean();
                category.setId(rs.getInt("id"));
                category.setName(rs.getString("name"));
                category.setType(rs.getString("type"));
                category.setSortOrder(rs.getInt("sort_order"));
                categories.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }
    
    // 根据ID获取新闻（用于编辑）
    public NewsBean getNewsById(int id) {
        NewsBean news = null;
        String sql = "SELECT n.*, c.name as category_name FROM news n " +
                    "LEFT JOIN categories c ON n.category_id = c.id " +
                    "WHERE n.id = ?";
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                news = resultSetToNews(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return news;
    }
    
    // 添加新闻
    public boolean addNews(NewsBean news) {
        String sql = "INSERT INTO news (title, content, summary, author, " +
                    "is_top, is_important, is_student_work, is_resource, " +
                    "is_honor, is_event, is_home_news, category_id, " +
                    "status, publish_time, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, news.getTitle());
            pstmt.setString(2, news.getContent());
            pstmt.setString(3, news.getSummary());
            pstmt.setString(4, news.getAuthor());
            pstmt.setBoolean(5, news.getIsTop());
            pstmt.setBoolean(6, news.getIsImportant());
            pstmt.setBoolean(7, news.getIsStudentWork());
            pstmt.setBoolean(8, news.getIsResource());
            pstmt.setBoolean(9, news.getIsHonor());
            pstmt.setBoolean(10, news.getIsEvent());
            pstmt.setBoolean(11, news.getIsHomeNews());
            pstmt.setObject(12, news.getCategoryId() > 0 ? news.getCategoryId() : null);
            pstmt.setString(13, news.getStatus());
            
            // 处理发布时间
            if (news.getPublishTime() != null) {
                pstmt.setTimestamp(14, new Timestamp(news.getPublishTime().getTime()));
            } else {
                pstmt.setTimestamp(14, new Timestamp(System.currentTimeMillis()));
            }
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        news.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 更新新闻
    public boolean updateNews(NewsBean news) {
        String sql = "UPDATE news SET title=?, content=?, summary=?, author=?, " +
                    "is_top=?, is_important=?, is_student_work=?, is_resource=?, " +
                    "is_honor=?, is_event=?, is_home_news=?, category_id=?, " +
                    "status=?, publish_time=?, updated_at=NOW() WHERE id=?";
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, news.getTitle());
            pstmt.setString(2, news.getContent());
            pstmt.setString(3, news.getSummary());
            pstmt.setString(4, news.getAuthor());
            pstmt.setBoolean(5, news.getIsTop());
            pstmt.setBoolean(6, news.getIsImportant());
            pstmt.setBoolean(7, news.getIsStudentWork());
            pstmt.setBoolean(8, news.getIsResource());
            pstmt.setBoolean(9, news.getIsHonor());
            pstmt.setBoolean(10, news.getIsEvent());
            pstmt.setBoolean(11, news.getIsHomeNews());
            pstmt.setObject(12, news.getCategoryId() > 0 ? news.getCategoryId() : null);
            pstmt.setString(13, news.getStatus());
            
            // 处理发布时间
            if (news.getPublishTime() != null) {
                pstmt.setTimestamp(14, new Timestamp(news.getPublishTime().getTime()));
            } else {
                pstmt.setTimestamp(14, new Timestamp(System.currentTimeMillis()));
            }
            
            pstmt.setInt(15, news.getId());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 删除新闻
    public boolean deleteNews(int id) {
        String sql = "DELETE FROM news WHERE id = ?";
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 更新新闻状态
    public boolean updateNewsStatus(int id, String status) {
        String sql = "UPDATE news SET status = ?, updated_at = NOW() WHERE id = ?";
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setInt(2, id);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 批量删除新闻
    public boolean batchDeleteNews(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) {
            return false;
        }
        
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("DELETE FROM news WHERE id IN (");
        
        for (int i = 0; i < ids.size(); i++) {
            sqlBuilder.append("?");
            if (i < ids.size() - 1) {
                sqlBuilder.append(",");
            }
        }
        sqlBuilder.append(")");
        
        try (Connection conn = ConnDB.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlBuilder.toString())) {
            
            for (int i = 0; i < ids.size(); i++) {
                pstmt.setInt(i + 1, ids.get(i));
            }
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 将ResultSet转换为NewsBean
    private NewsBean resultSetToNews(ResultSet rs) throws SQLException {
        NewsBean news = new NewsBean();
        news.setId(rs.getInt("id"));
        news.setTitle(rs.getString("title"));
        news.setContent(rs.getString("content"));
        news.setSummary(rs.getString("summary"));
        news.setAuthor(rs.getString("author"));
        
        news.setIsTop(rs.getBoolean("is_top"));
        news.setIsImportant(rs.getBoolean("is_important"));
        news.setIsStudentWork(rs.getBoolean("is_student_work"));
        news.setIsResource(rs.getBoolean("is_resource"));
        news.setIsHonor(rs.getBoolean("is_honor"));
        news.setIsEvent(rs.getBoolean("is_event"));
        news.setIsHomeNews(rs.getBoolean("is_home_news"));
        
        news.setCategoryId(rs.getInt("category_id"));
        news.setCategoryName(rs.getString("category_name"));
        news.setStatus(rs.getString("status"));
        news.setViewCount(rs.getInt("view_count"));
        news.setPublishTime(rs.getTimestamp("publish_time"));
        news.setCreatedAt(rs.getTimestamp("created_at"));
        news.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return news;
    }
}