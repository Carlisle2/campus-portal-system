package com.m01news;

import pub.ConnDB;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NewsDAO {
 
	 // 获取首页轮播图新闻
	 public List<NewsBean> getTopNews(int limit) {
	     List<NewsBean> list = new ArrayList<>();
	     String sql = "SELECT n.*, c.name as category_name FROM news n " +
	                 "LEFT JOIN categories c ON n.category_id = c.id " +
	                 "WHERE n.status = 'published' AND n.is_top = TRUE AND n.publish_time <= NOW() " +
	                 "ORDER BY n.publish_time DESC LIMIT ?";
	     
	     try (Connection conn = ConnDB.getConnection();
	          PreparedStatement pstmt = conn.prepareStatement(sql)) {
	         
	         pstmt.setInt(1, limit);
	         ResultSet rs = pstmt.executeQuery(); 
	         
	         while (rs.next()) {
	             list.add(resultSetToNews(rs));
	         }
	     } catch (SQLException e) {
	         e.printStackTrace();
	     }
	     return list;
	 }
	 
	 // 获取重要通知
	 public List<NewsBean> getImportantNews(int limit) {
	     return getNewsByRegion("is_important", limit);
	 }
	 
	 // 获取学工动态
	 public List<NewsBean> getStudentWorkNews(int limit) {
	     return getNewsByRegion("is_student_work", limit);
	 }
	 
	 // 获取学习资源
	 public List<NewsBean> getResourceNews(int limit) {
	     return getNewsByRegion("is_resource", limit);
	 }
	 
	 // 获取学院表彰
	 public List<NewsBean> getHonorNews(int limit) {
	     return getNewsByRegion("is_honor", limit);
	 }
	 
	 // 获取活动预告
	 public List<NewsBean> getEventNews(int limit) {
	     return getNewsByRegion("is_event", limit);
	 }
 
	 // 获取首页新闻/班级动态
	 public List<NewsBean> getHomeNewsList(int limit) {
	     return getNewsByRegion("is_home_news", limit);
	 }
	 
	 // 通用方法：按区域获取新闻
	 private List<NewsBean> getNewsByRegion(String regionField, int limit) {
	     List<NewsBean> list = new ArrayList<>();
	     String sql = "SELECT n.*, c.name as category_name FROM news n " +
	                 "LEFT JOIN categories c ON n.category_id = c.id " +
	                 "WHERE n.status = 'published' AND n." + regionField + " = TRUE AND n.publish_time <= NOW() " +
	                 "ORDER BY n.publish_time DESC LIMIT ?";
	     
	     try (Connection conn = ConnDB.getConnection();
	          PreparedStatement pstmt = conn.prepareStatement(sql)) {
	         
	         pstmt.setInt(1, limit);
	         ResultSet rs = pstmt.executeQuery();
	         
	         while (rs.next()) {
	             list.add(resultSetToNews(rs));
	         }
	     } catch (SQLException e) {
	         e.printStackTrace();
	     }
	     return list;
	 }
 
	 // 获取新闻详情
	 public NewsBean getNewsById(int id) {
	     NewsBean news = null;
	     String sql = "SELECT n.*, c.name as category_name FROM news n " +
	                 "LEFT JOIN categories c ON n.category_id = c.id " +
	                 "WHERE n.id = ? AND n.status = 'published'";
	     
	     try (Connection conn = ConnDB.getConnection();
	          PreparedStatement pstmt = conn.prepareStatement(sql)) {
	         
	         pstmt.setInt(1, id);
	         ResultSet rs = pstmt.executeQuery();
	         
	         if (rs.next()) {
	             news = resultSetToNews(rs);
	             // 更新浏览次数
	             updateViewCount(id);
	         }
	     } catch (SQLException e) {
	         e.printStackTrace();
	     }
	     return news;
	 }
 
	 // 搜索新闻
	 public List<NewsBean> searchNews(String keyword, int page, int pageSize) {
	     List<NewsBean> list = new ArrayList<>();
	     String sql = "SELECT n.*, c.name as category_name FROM news n " +
	                 "LEFT JOIN categories c ON n.category_id = c.id " +
	                 "WHERE n.status = 'published' AND n.publish_time <= NOW() " +
	                 "AND (n.title LIKE ? OR n.content LIKE ? OR n.summary LIKE ?) " +
	                 "ORDER BY n.publish_time DESC LIMIT ?, ?";
	     
	     try (Connection conn = ConnDB.getConnection();
	          PreparedStatement pstmt = conn.prepareStatement(sql)) {
	         
	         String likeKeyword = "%" + keyword + "%";
	         pstmt.setString(1, likeKeyword);
	         pstmt.setString(2, likeKeyword);
	         pstmt.setString(3, likeKeyword);
	         pstmt.setInt(4, (page - 1) * pageSize);
	         pstmt.setInt(5, pageSize);
	         
	         ResultSet rs = pstmt.executeQuery();
	         
	         while (rs.next()) {
	             list.add(resultSetToNews(rs));
	         }
	     } catch (SQLException e) {
	         e.printStackTrace();
	     }
	     return list;
	 }
	 
	 // 获取搜索总数
	 public int getSearchCount(String keyword) {
	     int count = 0;
	     String sql = "SELECT COUNT(*) FROM news WHERE status = 'published' AND publish_time <= NOW() " +
	                 "AND (title LIKE ? OR content LIKE ? OR summary LIKE ?)";
	     
	     try (Connection conn = ConnDB.getConnection();
	          PreparedStatement pstmt = conn.prepareStatement(sql)) {
	         
	         String likeKeyword = "%" + keyword + "%";
	         pstmt.setString(1, likeKeyword);
	         pstmt.setString(2, likeKeyword);
	         pstmt.setString(3, likeKeyword);
	         
	         ResultSet rs = pstmt.executeQuery();
	         if (rs.next()) {
	             count = rs.getInt(1);
	         }
	     } catch (SQLException e) {
	         e.printStackTrace();
	     }
	     return count;
	 }
 
	 // 更新浏览次数
	 private void updateViewCount(int id) {
	     String sql = "UPDATE news SET view_count = view_count + 1 WHERE id = ?";
	     
	     try (Connection conn = ConnDB.getConnection();
	          PreparedStatement pstmt = conn.prepareStatement(sql)) {
	         
	         pstmt.setInt(1, id);
	         pstmt.executeUpdate();
	     } catch (SQLException e) {
	         e.printStackTrace();
	     }
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
 
		//获取所有已发布的新闻（分页）
		public List<NewsBean> getAllPublishedNews(int page, int pageSize) {
		  List<NewsBean> list = new ArrayList<>();
		  String sql = "SELECT n.*, c.name as category_name FROM news n " +
		              "LEFT JOIN categories c ON n.category_id = c.id " +
		              "WHERE n.status = 'published' AND n.publish_time <= NOW() " +
		              "ORDER BY n.publish_time DESC LIMIT ?, ?";
		  
		  try (Connection conn = ConnDB.getConnection();
		       PreparedStatement pstmt = conn.prepareStatement(sql)) {
		      
		      pstmt.setInt(1, (page - 1) * pageSize);
		      pstmt.setInt(2, pageSize);
		      ResultSet rs = pstmt.executeQuery();
		      
		      while (rs.next()) {
		          list.add(resultSetToNews(rs));
		      }
		  } catch (SQLException e) {
		      e.printStackTrace();
		  }
		  return list;
		}
		
		//获取已发布新闻总数
		public int getTotalPublishedCount() {
		  int count = 0;
		  String sql = "SELECT COUNT(*) FROM news WHERE status = 'published' AND publish_time <= NOW()";
		  
		  try (Connection conn = ConnDB.getConnection();
		       PreparedStatement pstmt = conn.prepareStatement(sql)) {
		      
		      ResultSet rs = pstmt.executeQuery();
		      if (rs.next()) {
		          count = rs.getInt(1);
		      }
		  } catch (SQLException e) {
		      e.printStackTrace();
		  }
		  return count;
		}
}
