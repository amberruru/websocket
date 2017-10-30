<%--
  User: zhaokai
  Date: 2017/10/30
  Time: 17:00
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>WebChat | 聊天</title>
    <script src="${ctx}/static/sockjs.js"></script>
    <script src="${ctx}/static/jquery-2.1.4.min.js"></script>
</head>
<body>
<div id="message" title="信息">

</div>
<textarea cols="8" rows="8" placeholder="输入......"></textarea>
<input type="button" value="发送" onclick="sendMessage();">
<div id="userlist" title="列表">

</div>
<script type="text/javascript">
    $.document.ready(function () {
        var server = "ws://" + location.host+"${pageContext.request.contextPath}" + "/chatServer";
        var websocket = new WebSocket(server);
        websocket.onopen = function(evt){
            alert("已连接");
        };
        websocket.onmessage = function(evt){
            analysisMessage(evt.data);  //解析后台传回的消息,并予以展示
        };
        websocket.onerror = function(evt){
            alert("error");
        };
        websocket.onclose = function(evt){
            alert("关闭连接");
        }
    });
    function sendMessage() {

    }

    function showOnline(list) {
        $("#userlist").html("");
        $.each(list,function (index, item) {
            var usera ="<a href=''>"+item+"</a><br/>";
            $("#userlist").append(usera);
        });
    }
</script>
</body>
</html>
