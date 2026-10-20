<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统logo</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            height: 80px;
            background: transparent;
        }
        
        .logo {
            display: flex;
            align-items: center;
            padding: 0 20px;
        }
        
		/* 保持原比例的核心CSS */
		.logo-icon {
		    width: 60px;       
		    height: 60px;       
		    margin-right: 15px;
		    display: flex;
		    align-items: center;
		    justify-content: center;
		}
		
		.logo-icon img {
		    max-width: 100%;    
		    max-height: 100%;  
		    width: auto;        
		    height: auto;      
		    object-fit: contain; 
		}
        
        .logo-text h2 {
            margin: 0;
            color: white;
            font-size: 20px;
            font-weight: bold;
            letter-spacing: 1px;
            text-align: center;
        }
        
    </style>
</head>
<body>
    <div class="logo">
        <div class="logo-icon">
            <img src="images/logo.png" alt="学生管理系统图标">
        </div>
        <div class="logo-text">
            <h2>智慧校园信息管理平台</h2>
        </div>
    </div>
</body>
</html>