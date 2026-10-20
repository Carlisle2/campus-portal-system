<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01news.CategoryBean" %>
<%@ page import="com.m01news.AdminNewsDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 检查登录状态
    String loginUser = (String) session.getAttribute("username");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 获取分类列表
    List<CategoryBean> categories = (List<CategoryBean>) request.getAttribute("categories");
    String errorMsg = (String) request.getAttribute("errorMsg");
    com.m01news.NewsBean news = (com.m01news.NewsBean) request.getAttribute("news");
    
    // 如果分类列表为空，从数据库加载
    if (categories == null) {
        AdminNewsDAO dao = new AdminNewsDAO();
        categories = dao.getAllCategories();
    }
    
    // 设置默认值
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
    String defaultPublishTime = sdf.format(new java.util.Date());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布新闻 - 学生管理网站后台</title>
	<link rel="stylesheet" href="css/news_add.css">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.ckeditor.com/ckeditor5/34.0.0/classic/ckeditor.js"></script>
    <script>
        function backToMain() {
            window.location.href = 'news_list.jsp';
        }
        
        function checkForm() {
            var title = document.getElementById("title").value.trim();
            var categoryId = document.getElementById("categoryId").value;
            
            // 直接获取CKEditor的内容，不使用textarea
            var content = "";
            if (window.editor) {
                content = window.editor.getData().trim();
                // 同时同步到textarea（重要！）
                window.editor.updateSourceElement();
            } else {
                content = document.getElementById("content").value.trim();
            }
            
            if (title === "") {
                alert("新闻标题不能为空！");
                return false;
            }
            
            if (content === "") {
                alert("新闻内容不能为空！");
                return false;
            }
            
            if (categoryId === "") {
                alert("请选择新闻分类！");
                return false;
            }
            
            return true;
        }
        
        // 初始化CKEditor
        document.addEventListener('DOMContentLoaded', function() {
            ClassicEditor
                .create(document.querySelector('#content'), {
                    toolbar: [
                        'heading', '|', 'bold', 'italic', 'link', 'bulletedList', 'numberedList',
                        '|', 'outdent', 'indent', '|', 'imageUpload', 'blockQuote', 'insertTable',
                        'mediaEmbed', 'undo', 'redo'
                    ],
                    language: 'zh-cn',
                    image: {
                        toolbar: [
                            'imageTextAlternative', 'imageStyle:inline',
                            'imageStyle:block', 'imageStyle:side'
                        ]
                    }
                })
                .then(editor => {
                    window.editor = editor;
                })
                .catch(error => {
                    console.error(error);
                });
        });
    </script>
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h2 class="page-title">发布新闻</h2>
        
        <%-- 显示错误信息 --%>
        <% if (errorMsg != null) { %>
            <div class="error-msg"><%= errorMsg %></div>
        <% } %>
        
        <!-- 表单内容 -->
        <form class="add-form" action="AdminNewsServlet" method="post" onsubmit="return checkForm()">
            <input type="hidden" name="action" value="save">
            
            <div class="section-title">基本信息</div>
            
            <div class="form-item">
                <label for="title" class="required">新闻标题：</label>
                <input type="text" id="title" name="title" 
                       placeholder="请输入新闻标题" required
                       value="<%= news != null ? news.getTitle() : "" %>"
                       maxlength="200">
            </div>
            
            <div class="form-item">
                <label for="author" class="required">作者：</label>
                <input type="text" id="author" name="author" 
                       placeholder="请输入作者名称" required
                       value="<%= news != null ? news.getAuthor() : "管理员" %>"
                       maxlength="50">
            </div>
            
            <div class="form-item">
                <label for="categoryId" class="required">分类：</label>
                <select id="categoryId" name="categoryId" required>
                    <option value="">请选择分类</option>
                    <% if (categories != null) { 
                        for (CategoryBean category : categories) { %>
                        <option value="<%= category.getId() %>" 
                                <%= (news != null && news.getCategoryId() == category.getId()) ? "selected" : "" %>>
                            <%= category.getName() %>
                        </option>
                    <% } } %>
                </select>
            </div>
            
            <div class="form-item">
                <label for="status" class="required">状态：</label>
                <select id="status" name="status" required>
                    <option value="draft" <%= (news != null && "draft".equals(news.getStatus())) ? "selected" : "selected" %>>草稿</option>
                    <option value="published" <%= (news != null && "published".equals(news.getStatus())) ? "selected" : "" %>>立即发布</option>
                </select>
            </div>
            
            <div class="form-item">
                <label for="publishTime">发布时间：</label>
                <input type="datetime-local" id="publishTime" name="publishTime" 
                       value="<%= news != null && news.getPublishTime() != null ? 
                               new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(news.getPublishTime()) : 
                               defaultPublishTime %>">
            </div>
            
            <div class="section-title">内容摘要</div>
            <div class="form-item">
                <label for="summary">摘要/简介：</label>
                <textarea id="summary" name="summary" 
                          placeholder="请输入新闻摘要（可选，将显示在新闻列表中）"
                          rows="3"
                          maxlength="500"><%= news != null && news.getSummary() != null ? news.getSummary() : "" %></textarea>
            </div>
            
            <div class="section-title">新闻内容</div>
            <div class="form-item">
                <label for="content" class="required">内容：</label>
                <textarea id="content" name="content" ><%= news != null ? news.getContent() : "" %></textarea>
            </div>
            
            <div class="section-title">区域显示设置</div>
            <div class="checkbox-group">
                <div class="checkbox-item">
                    <input type="checkbox" id="isTop" name="isTop" 
                           <%= (news != null && news.getIsTop()) ? "checked" : "" %>>
                    <label for="isTop">顶部轮播区</label>
                </div>
                
                <div class="checkbox-item">
                    <input type="checkbox" id="isImportant" name="isImportant"
                           <%= (news != null && news.getIsImportant()) ? "checked" : "" %>>
                    <label for="isImportant">重要通知区</label>
                </div>
                
                <div class="checkbox-item">
                    <input type="checkbox" id="isStudentWork" name="isStudentWork"
                           <%= (news != null && news.getIsStudentWork()) ? "checked" : "" %>>
                    <label for="isStudentWork">学工动态区</label>
                </div>
                
                <div class="checkbox-item">
                    <input type="checkbox" id="isResource" name="isResource"
                           <%= (news != null && news.getIsResource()) ? "checked" : "" %>>
                    <label for="isResource">学习资源区</label>
                </div>
                
                <div class="checkbox-item">
                    <input type="checkbox" id="isHonor" name="isHonor"
                           <%= (news != null && news.getIsHonor()) ? "checked" : "" %>>
                    <label for="isHonor">学院表彰区</label>
                </div>
                
                <div class="checkbox-item">
                    <input type="checkbox" id="isEvent" name="isEvent"
                           <%= (news != null && news.getIsEvent()) ? "checked" : "" %>>
                    <label for="isEvent">活动预告区</label>
                </div>
                
                <div class="checkbox-item">
                    <input type="checkbox" id="isHomeNews" name="isHomeNews"
                           <%= (news != null && news.getIsHomeNews()) ? "checked" : "" %>>
                    <label for="isHomeNews">首页新闻列表</label>
                </div>
            </div>
            
            <div class="form-btn">
                <button type="submit" class="btn btn-primary">保存新闻</button>
                <button type="button" class="btn btn-default" onclick="backToMain()">取消返回</button>
            </div>
        </form>
    </div>
</body>
</html>