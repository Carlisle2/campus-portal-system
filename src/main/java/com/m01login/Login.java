package com.m01login;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import pub.ConnDB;

public class Login {
    
    /**
     * 检查用户登录（使用status字段）
     * @param uname 用户名
     * @param pword 密码
     * @return 返回状态字符串：
     *         "success" - 登录成功
     *         "disabled" - 用户被禁用
     *         "invalid" - 用户名或密码错误
     *         "error" - 系统错误
     */
    public String checkUser(String uname, String pword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            
            // 使用status字段查询用户状态
            String sql = "SELECT status FROM user WHERE fusername = ? AND fpassword = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, uname);
            pstmt.setString(2, pword);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // 获取用户状态（字段名是status）
                String status = rs.getString("status");
                System.out.println("用户 " + uname + " 的状态: " + status);
                
                // 判断用户状态（根据你的数据库实际值调整）
                if ("1".equals(status)) {
                    return "success";  // 状态正常，允许登录
                } else {
                    return "disabled"; // 用户被禁用
                } 
            } else {
                System.out.println("用户名或密码错误: " + uname);
                return "invalid"; // 用户名或密码错误
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            System.out.println("数据库查询错误: " + e.getMessage());
            return "error"; // 系统错误
        } finally {
            // 关闭资源
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * 登录基础验证
     */
    public boolean checkLogin(String username, String password) {    
        if (username == null || username.trim().isEmpty()) {
            System.out.println("用户名为空");
            return false;
        }        
        if (password == null || password.trim().isEmpty()) {
            System.out.println("密码为空");
            return false;
        }             
        if (username.trim().length() < 3) {
            System.out.println("用户名长度小于3: " + username);
            return false;
        }        
        if (password.trim().length() < 6) {
            System.out.println("密码长度小于6");
            return false;
        }        
        return true;
    }
}