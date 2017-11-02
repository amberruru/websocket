<%--
  User: zhaokai
  Date: 2017/10/30
  Time: 17:00
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
    <title>WebChat | 聊天</title>
    <script src="<%=basePath%>static/sockjs.js"></script>
    <script src="<%=basePath%>static/jquery-2.1.4.min.js"></script>
</head>
<body>
<div id="chat" title="信息" style="width: 100%;height: 20%;border: groove darkgrey;">
<ul id="message">

</ul>
</div>
<textarea cols="8" rows="8" placeholder="输入......" id="content"></textarea>
<h3>发送给：<span id="to">全体</span><input type="hidden" id="sendto"/> </h3>
<input type="button" value="发送" onclick="sendMessage();">
<div id="userlist" title="在线列表" style="width: 100%;height: 20%;border: groove darkgrey;">

</div>
<script type="text/javascript">
    var server = "ws://" + location.host+"${pageContext.request.contextPath}" + "/chatServer";
    var websocket = new WebSocket(server);
    $(document).ready(function () {
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
        };
    });
    function sendMessage() {
        var message = $("#content").val();
        var to = $("#sendto").val();
        websocket.send(JSON.stringify({
            message:{
                content:message,
                from:"${userid}",
                to:to,
                time:new Date()
            },
            type:"message"
        }));
    }

    function sendMessage(){
        if(websocket == null){
            alert("连接未开启!");
            return;
        }
        var message = $("#content").val();
        var to = $("#sendto").text() == "全体成员"? "": $("#sendto").text();
        if(message == null || message == ""){
            alert("请不要惜字如金!");
            return;
        }
        websocket.send(JSON.stringify({
            message : {
                content : message,
                from : '${userid}',
                to : to,      //接收人,如果没有则置空,如果有多个接收人则用,分隔
                time : new Date()
            },
            type : "message"
        }));
    }

    function analysisMessage(message) {
        message = JSON.parse(message);
        if (message.type=="message"){
            showChat(message.message);
        }
        if (message.type=="notic"){
            alert(message.message+"上线");
        }
        if (message.list != null && message.list != undefined){
            showOnline(message.list);
        }
    }

    function showChat(message) {
        var to = message.to == null || message.to=="" ? "全体员工":message.to;
        var from = message.from;
        var str = "<li>"+from+"发送给"+to+":"+message.content+"</li>";
        $("#message").append(str);
        var chat = $("#chat");
        chat.scrollTop(chat[0].scrollHeight);   //让聊天区始终滚动到最下面
    }

    function showOnline(list) {
        $("#userlist").html("");
        $.each(list,function (index, item) {
            var usera ="<a href='javascript:void(0);' onclick='touser("+item+");'>"+item+"</a><br/>";
            $("#userlist").append(usera);
        });
    }

    function touser(id) {
        $("#to").html(id);
        $("#sendto").val(id);
    }
</script>
</body>
</html>
