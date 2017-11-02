package com.socket.websocket.socket;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import javax.servlet.http.HttpSession;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * Created by zhaokai on 2017/10/30.
 */
@ServerEndpoint(value = "/chatServer", configurator = HttpSessionConfingtor.class)
public class Server {

    //在线人数
    private static int onlineNum = 0;
    /**
     * 所有回话的容器
     */
    private static CopyOnWriteArraySet<Server> copyOnWriteArraySet = new CopyOnWriteArraySet<>();
    //当前socketsession
    private Session session;
    //当前httpsession
    private HttpSession httpSession;

    //在线session 列表
    private static List list =new ArrayList();
    //回话session和socketsession的路由表
    private static Map map = new HashMap();

    /**
     * 建立连接
     * @param session
     * @param config
     */
    @OnOpen
    public void onOpen(Session session, EndpointConfig config){
        this.session = session;
        copyOnWriteArraySet.add(this);//加入set集合
        Server.onlineNum++;//在线人数加
        this.httpSession = (HttpSession)config.getUserProperties().get(HttpSession.class.getName());
        list.add(httpSession.getId().toString());
        map.put(httpSession.getId(),session);
        String message = getMessage(httpSession.getId()+"加入","notic",list);
        broadcast(message);
    }

    /**
     * 关闭连接
     */
    @OnClose
    public void onClose(){
        copyOnWriteArraySet.remove(this);
        Server.onlineNum--;
        list.remove(httpSession.getId());
        map.remove(httpSession.getId());
        String message = getMessage(httpSession.getId()+"离开了","notic",list);
        broadcast(message);
    }

    @OnMessage
    public void onMessage(String _message){
        JSONObject chat = JSON.parseObject(_message);
        JSONObject message = JSONObject.parseObject(chat.getString("message"));
        //to为空则为广播，否则为针对指定的用户发送
        if (message.get("to") == null || message.get("to").equals("")){
              broadcast(_message);
        }else{
            String[] userlist = message.get("to").toString().split(",");
            for (String s : userlist) {
                sendSingle(_message,(Session)map.get(s));
            }
        }
    }

    @OnError
    public void onError(Throwable error){
        error.printStackTrace();}

    /**
     * 发送消息
     * @param message
     */
    public void broadcast(String message){
        for (Server server : copyOnWriteArraySet) {
            try{
                server.session.getBasicRemote().sendText(message);
            }catch (Exception e){
                e.printStackTrace();
                continue;
            }
        }
    }

    /**
     * 单发
     * @param message
     * @param session
     */
    public void sendSingle(String message,Session session){
        try{
            session.getBasicRemote().sendText(message);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    /**
     * 组装返回给前台的消息
     * @param message   交互信息
     * @param type      信息类型
     * @param list      在线列表
     * @return
     */
    public String getMessage(String message, String type, List list){
        JSONObject member = new JSONObject();
        member.put("message", message);
        member.put("type", type);
        member.put("list", list);
        return member.toString();
    }

}
