// RoleDAO.java
package com.m01role;

import pub.ConnDB;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {
    
    // 检查登录用户是否为系统管理员
    public boolean isSystemAdmin(String username) {
        Connection conn = null;
        boolean isAdmin = false;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT 1 FROM user WHERE fusername = ? AND role = '系统管理员'";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, username);
                try (ResultSet rs = pstmt.executeQuery()) {
                    isAdmin = rs.next();
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
        return isAdmin;
    }
    
    // 添加角色
    public boolean addRole(RoleBean role, String operator) {
        // 检查操作者是否为系统管理员
        if (!isSystemAdmin(operator)) {
            return false;
        }
        
        Connection conn = null;
        boolean success = false;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "INSERT INTO role (roleID, name, description, status) VALUES (?, ?, ?, ?)";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, role.getRoleID());
                pstmt.setString(2, role.getName());
                pstmt.setString(3, role.getDescription());
                pstmt.setString(4, role.getStatus());
                
                int rows = pstmt.executeUpdate();
                success = rows > 0;
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
        return success;
    }
    
    // 更新角色
    public boolean updateRole(RoleBean role, String operator) {
        // 检查操作者是否为系统管理员
        if (!isSystemAdmin(operator)) {
            return false;
        }
        
        Connection conn = null;
        boolean success = false;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "UPDATE role SET name = ?, description = ?, status = ? WHERE roleID = ?";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, role.getName());
                pstmt.setString(2, role.getDescription());
                pstmt.setString(3, role.getStatus());
                pstmt.setString(4, role.getRoleID());
                
                int rows = pstmt.executeUpdate();
                success = rows > 0;
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
        return success;
    }
    
    // 删除角色（删除前检查是否有用户使用）
    public boolean deleteRole(String roleID, String operator) {
        // 检查操作者是否为系统管理员
        if (!isSystemAdmin(operator)) {
            return false;
        }
        
        Connection conn = null;
        boolean success = false;
        
        try {
            conn = ConnDB.getConnection();
            
            // 检查是否有用户使用此角色
            String checkSql = "SELECT COUNT(*) as userCount FROM user WHERE role = " +
                             "(SELECT name FROM role WHERE roleID = ?)";
            boolean canDelete = true;
            
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, roleID);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt("userCount") > 0) {
                        canDelete = false; // 有用户使用，不能删除
                    }
                }
            }
            
            if (!canDelete) {
                return false;
            }
            
            // 删除角色
            String deleteSql = "DELETE FROM role WHERE roleID = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSql)) {
                pstmt.setString(1, roleID);
                int rows = pstmt.executeUpdate();
                success = rows > 0;
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
        return success;
    }
    
    // 根据roleID查询角色
    public RoleBean getRoleByID(String roleID) {
        Connection conn = null;
        RoleBean role = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, name, description, status, created_time FROM role WHERE roleID = ?";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, roleID);
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        role = new RoleBean();
                        role.setRoleID(rs.getString("roleID"));
                        role.setName(rs.getString("name"));
                        role.setDescription(rs.getString("description"));
                        role.setStatus(rs.getString("status"));
                        role.setCreatedTime(rs.getString("created_time"));
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
        return role;
    }
    
    // 检查角色ID是否已存在
    public boolean isRoleIDExists(String roleID) {
        Connection conn = null;
        boolean exists = false;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT 1 FROM role WHERE roleID = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, roleID);
                try (ResultSet rs = pstmt.executeQuery()) {
                    exists = rs.next();
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
        return exists;
    }
    
    // 检查角色名称是否已存在（排除自身）
    public boolean isRoleNameExists(String name, String excludeRoleID) {
        Connection conn = null;
        boolean exists = false;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT 1 FROM role WHERE name = ? AND roleID != ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, name);
                pstmt.setString(2, excludeRoleID != null ? excludeRoleID : "");
                try (ResultSet rs = pstmt.executeQuery()) {
                    exists = rs.next();
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
        return exists;
    }
    
    // 获取总记录数（分页用）
    public int getTotalCount(String roleID, String name, String status) {
        Connection conn = null;
        int total = 0;
        
        try {
            conn = ConnDB.getConnection();
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) as total FROM role WHERE 1=1");
            List<Object> params = new ArrayList<>();
            
            if (roleID != null && !roleID.trim().isEmpty()) {
                sql.append(" AND roleID LIKE ?");
                params.add("%" + roleID.trim() + "%");
            }
            
            if (name != null && !name.trim().isEmpty()) {
                sql.append(" AND name LIKE ?");
                params.add("%" + name.trim() + "%");
            }
            
            if (status != null && !status.trim().isEmpty() && !"all".equals(status)) {
                sql.append(" AND status = ?");
                params.add(status.trim());
            }
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        total = rs.getInt("total");
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
        return total;
    }
    
    // 条件查询角色（带分页）
    public List<RoleBean> searchRoles(String roleID, String name, String status, 
                                     int currentPage, int pageSize) {
        Connection conn = null;
        List<RoleBean> roles = new ArrayList<>();
        
        try {
            conn = ConnDB.getConnection();
            StringBuilder sql = new StringBuilder(
                "SELECT roleID, name, description, status, created_time FROM role WHERE 1=1"
            );
            List<Object> params = new ArrayList<>();
            
            if (roleID != null && !roleID.trim().isEmpty()) {
                sql.append(" AND roleID LIKE ?");
                params.add("%" + roleID.trim() + "%");
            }
            
            if (name != null && !name.trim().isEmpty()) {
                sql.append(" AND name LIKE ?");
                params.add("%" + name.trim() + "%");
            }
            
            if (status != null && !status.trim().isEmpty() && !"all".equals(status)) {
                sql.append(" AND status = ?");
                params.add(status.trim());
            }
            
            sql.append(" ORDER BY created_time DESC");
            
            // 添加分页限制
            sql.append(" LIMIT ?, ?");
            params.add((currentPage - 1) * pageSize);
            params.add(pageSize);
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        RoleBean role = new RoleBean();
                        role.setRoleID(rs.getString("roleID"));
                        role.setName(rs.getString("name"));
                        role.setDescription(rs.getString("description"));
                        role.setStatus(rs.getString("status"));
                        role.setCreatedTime(rs.getString("created_time"));
                        
                        roles.add(role);
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
        return roles;
    }

    // 获取所有角色（ID和名称）
    public List<RoleBean> getAllRoles() {
        Connection conn = null;
        List<RoleBean> roles = new ArrayList<>();
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT roleID, name FROM role ORDER BY name";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        RoleBean role = new RoleBean();
                        role.setRoleID(rs.getString("roleID"));
                        role.setName(rs.getString("name"));
                        roles.add(role);
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
        return roles;
    }
}