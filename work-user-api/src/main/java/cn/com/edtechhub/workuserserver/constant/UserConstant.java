package cn.com.edtechhub.workuserserver.constant;

/**
 * 用户常量
 *
 * @author <a href="https://github.com/limou3434">limou3434</a>
 */
public interface UserConstant {

    /**
     * 默认盐值
     */
    String SALT = "edtechhub"; // 如果需要安全则可以进行修改

    /**
     * 默认密码
     */
    String DEFAULT_PASSWD = "123456";

    /**
     * 默认账户最小长度
     */
    Integer ACCOUNT_LENGTH = 5;

    /**
     * 默认密码最小长度
     */
    Integer PASSWD_LENGTH = 6;

    /**
     * 用户是否登录会话标识
     */
    String USER_LOGIN_STATE = "longin_user";

}