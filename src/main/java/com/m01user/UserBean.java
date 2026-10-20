package com.m01user;

public class UserBean {
    private String fusername = "";
    private String fpassword = "";
    private String roleID = "";
    private String status = "1";
    private String role = "";
    private String phone;    
    private String email;   
    
    // Getters and Setters
    public String getFusername() {
        return fusername;
    }
    public void setFusername(String fusername) {
        this.fusername = fusername;
    } 
    public String getFpassword() {
        return fpassword;
    }
    public void setFpassword(String fpassword) {
        this.fpassword = fpassword;
    }
    public String getRoleID() {
        return roleID;
    }
    public void setRoleID(String roleID) {
        this.roleID = roleID;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public String getRole() {
        return role;
    }
    public void setRole(String role) {
        this.role = role;
    }
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
    
}