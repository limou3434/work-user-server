package cn.com.edtechhub.workuserserver.service;

import cn.com.edtechhub.workgeneralmodule.annotation.LogParams;
import cn.com.edtechhub.workgeneralmodule.exception.CodeBindMessageEnums;
import cn.com.edtechhub.workgeneralmodule.exception.ThrowUtils;
import cn.com.edtechhub.workuserserver.api.UserService;
import cn.com.edtechhub.workuserserver.constant.UserConstant;
import cn.com.edtechhub.workuserserver.mapper.UserMapper;
import cn.com.edtechhub.workuserserver.model.entity.User;
import cn.com.edtechhub.workuserserver.model.request.userService.UserAddRequest;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.dubbo.config.annotation.DubboService;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.util.DigestUtils;

//@DubboService
@Service
@Slf4j
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    /**
     * 注入事务管理依赖
     */
    @Resource
    TransactionTemplate transactionTemplate;

    /// 服务测试 ///

    @Override
    @LogParams
    public String test() {
        ThrowUtils.throwIf(true, CodeBindMessageEnums.SUCCESS, "true");
        return "Hello work-user-server!";
    }

    /// 基本服务 ///
    @Override
    @LogParams
    public User userAdd(UserAddRequest userAddRequest) {
        // 检查参数
        ThrowUtils.throwIf(userAddRequest == null, CodeBindMessageEnums.PARAMS_ERROR, "请求体不能为空");
        String account = userAddRequest.getAccount();
        String passwd = userAddRequest.getPasswd();
        this.checkAccount(account);
        this.checkPasswd(passwd);

        // 服务实现
        return transactionTemplate.execute(status -> {
            // 创建实例
            User user = UserAddRequest.copyProperties2Entity(userAddRequest);
            user.setPasswd(this.encryptedPasswd(user.getPasswd()));
            // 操作数据库
            try {
                boolean result = this.save(user); // 保存实例的同时利用唯一键约束避免并发问题
                ThrowUtils.throwIf(!result, CodeBindMessageEnums.OPERATION_ERROR, "添加出错");
            } catch (DuplicateKeyException e) { // 无需加锁, 只需要设置唯一键就足够因对并发场景
                ThrowUtils.throwIf(true, CodeBindMessageEnums.ILLEGAL_OPERATION_ERROR, "已经存在该用户, 或者曾经被删除");
            }
            return this.getById(user.getId());
        });
    }

    /// 其他服务 ///


    /// 私有方法 ///

    /**
     * 检查账号是否符合要求
     */
    private void checkAccount(String checkAccount) {
        ThrowUtils.throwIf(StringUtils.isBlank(checkAccount), CodeBindMessageEnums.PARAMS_ERROR, "账户为空");
        ThrowUtils.throwIf(checkAccount.length() < UserConstant.ACCOUNT_LENGTH, CodeBindMessageEnums.PARAMS_ERROR, "账户不得小于" + UserConstant.ACCOUNT_LENGTH + "位字符");
        String validPattern = "^[$_-]+$";
        ThrowUtils.throwIf(checkAccount.matches(validPattern), CodeBindMessageEnums.PARAMS_ERROR, "账号不能包含特殊字符");
    }

    /**
     * 检查密码是否符合要求
     */
    private void checkPasswd(String checkPasswd) {
        ThrowUtils.throwIf(StringUtils.isBlank(checkPasswd), CodeBindMessageEnums.PARAMS_ERROR, "密码为空");
        ThrowUtils.throwIf(checkPasswd.length() < UserConstant.PASSWD_LENGTH, CodeBindMessageEnums.PARAMS_ERROR, "密码不得小于" + UserConstant.PASSWD_LENGTH + "位字符");
    }

    /**
     * 获取加密后的密码
     */
    private String encryptedPasswd(String passwd) {
        ThrowUtils.throwIf(StringUtils.isAnyBlank(passwd), CodeBindMessageEnums.PARAMS_ERROR, "需要加密的密码不能为空");
        return DigestUtils.md5DigestAsHex((UserConstant.SALT + passwd).getBytes()); // TODO: 使用 Sa-token 的加密工具
    }

}
