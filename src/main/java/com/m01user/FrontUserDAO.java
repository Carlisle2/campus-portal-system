package com.m01user;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import pub.ConnDB;

public class FrontUserDAO {
    
    // 检查用户名是否存在（注册时使用）
    public boolean checkUsernameExists(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT COUNT(*) FROM user WHERE fusername = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return false;
    }
    
    // 注册用户（前台专用）
    public boolean registerUser(UserBean user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            
            // 生成用户ID：U + 时间戳
            String roleID = "U" + System.currentTimeMillis();
            
            String sql = "INSERT INTO user(roleID, fusername, fpassword, role, status, phone, email) " +
                        "VALUES(?, ?, ?, ?, '1', ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, roleID);
            pstmt.setString(2, user.getFusername());
            pstmt.setString(3, user.getFpassword()); // 实际项目中应该加密
            pstmt.setString(4, user.getRole());
            pstmt.setString(5, user.getPhone());
            pstmt.setString(6, user.getEmail());
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
    
    // 用户登录验证
    public UserBean login(String username, String password) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, fusername, fpassword, role, status, phone, email " +
                        "FROM user WHERE fusername = ? AND fpassword = ? AND status = '1'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                UserBean user = new UserBean();
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setPhone(rs.getString("phone"));
                user.setEmail(rs.getString("email"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return null;
    }
    
    // 获取可注册的角色列表（排除管理员）
    public List<String> getAvailableRoles() {
        List<String> roles = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT DISTINCT name FROM role WHERE name != '系统管理员' AND status = '1' ORDER BY name";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                String roleName = rs.getString("name");
                if (roleName != null && !roleName.trim().isEmpty()) {
                    roles.add(roleName.trim());
                }
            }
            
            // 如果没有从数据库获取到角色，添加默认角色
            if (roles.isEmpty()) {
                roles.add("学生");
                roles.add("讲师");
                roles.add("辅导员");
                roles.add("访客");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // 数据库异常时返回默认角色
            roles.add("学生");
            roles.add("讲师");
            roles.add("辅导员");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return roles;
    }
    
    // 更新用户最后登录时间
    public boolean updateLastLogin(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "UPDATE user SET last_login = NOW() WHERE fusername = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
    
    // 根据用户名获取用户信息
    public UserBean getUserByUsername(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, fusername, fpassword, role, status, phone, email " +
                        "FROM user WHERE fusername = ? AND status = '1'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                UserBean user = new UserBean();
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                user.setPhone(rs.getString("phone"));
                user.setEmail(rs.getString("email"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return null;
    }
}