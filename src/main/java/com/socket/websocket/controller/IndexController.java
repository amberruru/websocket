package com.socket.websocket.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;

/**
 * Created by zhaokai on 2017/10/31.
 */
@Controller
public class IndexController {
    @RequestMapping("/index")
    public String index(HttpServletRequest request){
        request.setAttribute("userid",request.getSession().getId());
        return "/index";
    }
}
