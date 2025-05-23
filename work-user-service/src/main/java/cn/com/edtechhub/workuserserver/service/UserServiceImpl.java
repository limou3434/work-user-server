package cn.com.edtechhub.workuserserver.service;

import cn.com.edtechhub.workgeneralmodule.exception.CodeBindMessageEnums;
import cn.com.edtechhub.workgeneralmodule.utils.ThrowUtils;
import cn.com.edtechhub.workuserserver.api.UserService;
import org.apache.dubbo.config.annotation.DubboService;

@DubboService
public class UserServiceImpl implements UserService {

    @Override
    public String test() {
        ThrowUtils.throwIf(true, CodeBindMessageEnums.SUCCESS, "true");
        return "Hello work-user-server!";
    }

}
