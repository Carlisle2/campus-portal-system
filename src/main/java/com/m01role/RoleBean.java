package com.m01role;

public class RoleBean {
    private String roleID;
    private String name;
    private String description; 
    private String status;
    private String createdTime; 
    
    // 构造方法
    public RoleBean() {}
     
    // Getter和Setter方法
    public String getRoleID() {
        return roleID;
    }
    public void setRoleID(String roleID) {
        this.roleID = roleID;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public String getCreatedTime() {
        return createdTime;
    }
    public void setCreatedTime(String createdTime) {
        this.createdTime = createdTime;
    }
    
    // 状态显示文本
    public String getStatusText() {
        return "1".equals(status) ? "启用" : "禁用";
    }
}