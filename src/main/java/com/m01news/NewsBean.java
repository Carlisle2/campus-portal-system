package com.m01news;

import java.util.Date;

public class NewsBean {
	 private int id;
	 private String title;
	 private String content;
	 private String summary;
	 private String author;
	 
	 // 区域控制字段
	 private boolean isTop;
	 private boolean isImportant;
	 private boolean isStudentWork;
	 private boolean isResource;
	 private boolean isHonor;
	 private boolean isEvent;
	 private boolean isHomeNews; 
	 
	 private int categoryId;
	 private String categoryName;
	 private String status;
	 private int viewCount;
	 private Date publishTime;
	 private Date createdAt;
	 private Date updatedAt;

     public int getId() { 
    	 return id; 
    }
     public void setId(int id) {
    	 this.id = id; 
    }
     
     public String getTitle() { 
    	 return title; 
    }
     public void setTitle(String title) { 
    	 this.title = title; 
    }
     
     public String getContent() { 
    	 return content; 
    }
     public void setContent(String content) { 
    	 this.content = content;
    }
     
     public String getSummary() { 
    	 return summary; 
    }
     public void setSummary(String summary) { 
    	 this.summary = summary;
    }
     
     public String getAuthor() { 
    	 return author; 
    }
     public void setAuthor(String author) { 
    	 this.author = author; 
    }
     
     public boolean getIsTop() { 
    	 return isTop; 
    }
     public void setIsTop(boolean isTop) { 
    	 this.isTop = isTop; 
    }
     
     public boolean getIsImportant() { 
    	 return isImportant; 
    }
     public void setIsImportant(boolean isImportant) { 
    	 this.isImportant = isImportant; 
    }
     
     public boolean getIsStudentWork() { 
    	 return isStudentWork; 
    }
     public void setIsStudentWork(boolean isStudentWork) { 
    	 this.isStudentWork = isStudentWork; 
    }
     
     public boolean getIsResource() { 
    	 return isResource; 
    }
     public void setIsResource(boolean isResource) { 
    	 this.isResource = isResource; 
    }
     
     public boolean getIsHonor() { 
    	 return isHonor; 
    }
     public void setIsHonor(boolean isHonor) { 
    	 this.isHonor = isHonor; 
    }
     
     public boolean getIsEvent() { 
    	 return isEvent; 
    }
     public void setIsEvent(boolean isEvent) { 
    	 this.isEvent = isEvent; 
    }
     
     public boolean getIsHomeNews() { 
    	 return isHomeNews; 
    }
     public void setIsHomeNews(boolean isHomeNews) { 
    	 this.isHomeNews = isHomeNews; 
    }
     
     public int getCategoryId() { 
    	 return categoryId; 
    }
     public void setCategoryId(int categoryId) { 
    	 this.categoryId = categoryId; 
    }
     
     public String getCategoryName() { 
    	 return categoryName; 
    }
     public void setCategoryName(String categoryName) { 
    	 this.categoryName = categoryName; 
    }
     
     public String getStatus() { 
    	 return status; 
    }
     public void setStatus(String status) { 
    	 this.status = status; 
    }
     
     public int getViewCount() { 
    	 return viewCount; 
    }
     public void setViewCount(int viewCount) { 
    	 this.viewCount = viewCount; 
    }
    
     public Date getPublishTime() { 
    	 return publishTime; 
    }
     public void setPublishTime(Date publishTime) { 
    	 this.publishTime = publishTime; 
    }
     
     public Date getCreatedAt() { 
    	 return createdAt; 
    }
     public void setCreatedAt(Date createdAt) { 
    	 this.createdAt = createdAt; 
    }
     
     public Date getUpdatedAt() { 
    	 return updatedAt; 
    }
     public void setUpdatedAt(Date updatedAt) { 
    	 this.updatedAt = updatedAt; 
    }
 }
