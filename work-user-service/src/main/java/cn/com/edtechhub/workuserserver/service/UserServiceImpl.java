package cn.com.edtechhub.workuserserver.service;

import cn.com.edtechhub.workuserserver.api.UserService;
import org.apache.dubbo.config.annotation.DubboService;

@DubboService
public class UserServiceImpl implements UserService {

    @Override
    public String test() {
        return "Hello work-user-server!";
    }

}
