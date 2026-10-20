package com.m01user;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import pub.ConnDB;

public class UserDAO {
    // 检查roleID是否存在
    public boolean checkRoleIDExists(String roleID) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT COUNT(*) FROM user WHERE roleID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, roleID);
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
    
    // 添加用户 
    public boolean addUser(UserBean user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            
            // ID由用户输入
            if (user.getRoleID() == null || user.getRoleID().trim().isEmpty()) {
                throw new IllegalArgumentException("用户ID不能为空");
            }
            
            String sql = "INSERT INTO user(roleID, fusername, fpassword, role, status, phone, email) VALUES(?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getRoleID().trim());
            pstmt.setString(2, user.getFusername());
            pstmt.setString(3, user.getFpassword());
            pstmt.setString(4, user.getRole());
            pstmt.setString(5, user.getStatus());
            pstmt.setString(6, user.getPhone());     
            pstmt.setString(7, user.getEmail());     
            
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
    
    // 更新用户
    public boolean updateUser(UserBean user) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "UPDATE user SET fusername = ?, fpassword = ?, role = ?, status = ?, phone = ?, email = ? WHERE roleID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user.getFusername());  // 用户名
            pstmt.setString(2, user.getFpassword());  // 密码
            pstmt.setString(3, user.getRole());       // 角色
            pstmt.setString(4, user.getStatus());     // 状态
            pstmt.setString(5, user.getPhone());      // 电话
            pstmt.setString(6, user.getEmail());      // 邮箱
            pstmt.setString(7, user.getRoleID());     // 用户ID
            
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
    
    // 删除用户 
    public boolean deleteUser(String roleID) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "DELETE FROM user WHERE roleID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, roleID);
            
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
    
    // 查询所有用户 
    public List<UserBean> getAllUsers() {
        List<UserBean> userList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, fusername, fpassword, role, status FROM user ORDER BY roleID";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                UserBean user = new UserBean();
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return userList;
    }
    
    // 根据条件查询用户
    public List<UserBean> queryUsers(String roleID, String username, String role) {
        List<UserBean> userList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            StringBuilder sql = new StringBuilder("SELECT roleID, fusername, fpassword, role, status FROM user WHERE 1=1");
            List<Object> params = new ArrayList<>();
            
            if (roleID != null && !roleID.trim().isEmpty()) {
                sql.append(" AND roleID LIKE ?");
                params.add("%" + roleID.trim() + "%");
            }
            if (username != null && !username.trim().isEmpty()) {
                sql.append(" AND fusername LIKE ?");
                params.add("%" + username.trim() + "%");
            }
            if (role != null && !role.trim().isEmpty()) {
                sql.append(" AND role = ?");
                params.add(role.trim());
            }
            
            sql.append(" ORDER BY roleID");
            pstmt = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                UserBean user = new UserBean();
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return userList;
    }
    
    // 根据roleID获取单个用户
    public UserBean getUserByRoleID(String roleID) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, fusername, fpassword, role, status, phone, email FROM user WHERE roleID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, roleID);
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
    
    // 根据用户名获取单个用户
    public UserBean getUserByUsername(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, fusername, fpassword, role, status, phone, email FROM user WHERE fusername = ?";
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
    
    // 检查用户名是否存在 
    public boolean isUsernameExists(String username) {
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
    
    // 获取指定角色的所有用户
    public List<UserBean> getUsersByRole(String role) {
        List<UserBean> userList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, fusername, fpassword, role, status FROM user WHERE role = ? ORDER BY fusername";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, role);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                UserBean user = new UserBean();
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return userList;
    }

    //分页查询用户 
    public List<UserBean> queryUsersByPage(String roleID, String username, String role, 
                                           int pageNum, int pageSize) {
        List<UserBean> userList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            StringBuilder sql = new StringBuilder(
                "SELECT roleID, fusername, fpassword, role, status FROM user WHERE 1=1");
            List<Object> params = new ArrayList<>();
            
            if (roleID != null && !roleID.trim().isEmpty()) {
                sql.append(" AND roleID LIKE ?");
                params.add("%" + roleID.trim() + "%");
            }
            if (username != null && !username.trim().isEmpty()) {
                sql.append(" AND fusername LIKE ?");
                params.add("%" + username.trim() + "%");
            }
            if (role != null && !role.trim().isEmpty()) {
                sql.append(" AND role = ?");
                params.add(role.trim());
            }
            
            sql.append(" ORDER BY roleID LIMIT ?, ?");
            
            pstmt = conn.prepareStatement(sql.toString());
            
            // 设置参数
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            // 计算起始位置
            int start = (pageNum - 1) * pageSize;
            pstmt.setInt(params.size() + 1, start);
            pstmt.setInt(params.size() + 2, pageSize);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                UserBean user = new UserBean();
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                userList.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return userList;
    }


    //获取总记录数 
    public int getTotalCount(String roleID, String username, String role) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int total = 0;
        
        try {
            conn = ConnDB.getConnection();
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM user WHERE 1=1");
            List<Object> params = new ArrayList<>();
            
            if (roleID != null && !roleID.trim().isEmpty()) {
                sql.append(" AND roleID LIKE ?");
                params.add("%" + roleID.trim() + "%");
            }
            if (username != null && !username.trim().isEmpty()) {
                sql.append(" AND fusername LIKE ?");
                params.add("%" + username.trim() + "%");
            }
            if (role != null && !role.trim().isEmpty()) {
                sql.append(" AND role = ?");
                params.add(role.trim());
            }
            
            pstmt = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return total;
    }

    public List<String> getAllRoles() {
        Connection conn = null;
        List<String> roles = new ArrayList<>();
        
        try {
            conn = ConnDB.getConnection();
            // 从role表获取所有启用状态的角色
            String sql = "SELECT DISTINCT name FROM role WHERE status = '1' ORDER BY name";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String roleName = rs.getString("name");
                    if (roleName != null && !roleName.trim().isEmpty()) {
                        roles.add(roleName.trim());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("获取角色列表失败：" + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        // 如果没有从数据库获取到角色，返回一个空列表
        if (roles.isEmpty()) {
            System.out.println("角色列表为空，返回默认角色");
            // 可以添加一些默认角色作为后备
            roles.add("系统管理员");
            roles.add("讲师");
            roles.add("辅导员");
        }
        
        return roles;
    }
    /**
     * 更新用户信息（包括密码、电话、邮箱）
     */
    public boolean updateUserProfile(String username, String password, String phone, String email) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            
            String sql;
            if (password != null && !password.trim().isEmpty()) {
                // 更新密码、电话、邮箱
                sql = "UPDATE user SET fpassword = ?, phone = ?, email = ? WHERE fusername = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, password.trim());
                pstmt.setString(2, phone != null ? phone.trim() : "");
                pstmt.setString(3, email != null ? email.trim() : "");
                pstmt.setString(4, username);
            } else {
                // 只更新电话、邮箱
                sql = "UPDATE user SET phone = ?, email = ? WHERE fusername = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, phone != null ? phone.trim() : "");
                pstmt.setString(2, email != null ? email.trim() : "");
                pstmt.setString(3, username);
            }
            
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
}