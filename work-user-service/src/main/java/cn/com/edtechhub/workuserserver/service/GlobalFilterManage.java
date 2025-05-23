package cn.com.edtechhub.workuserserver.service;

import cn.com.edtechhub.workgeneralmodule.exception.BusinessException;
import cn.com.edtechhub.workgeneralmodule.exception.CodeBindMessageEnums;
import cn.com.edtechhub.workgeneralmodule.response.BaseResponse;
import cn.com.edtechhub.workgeneralmodule.response.TheResult;
import cn.dev33.satoken.exception.DisableServiceException;
import cn.dev33.satoken.exception.NotLoginException;
import cn.dev33.satoken.exception.NotPermissionException;
import cn.dev33.satoken.exception.NotRoleException;
import lombok.extern.slf4j.Slf4j;
import org.apache.dubbo.common.extension.Activate;
import org.apache.dubbo.rpc.*;
import org.apache.dubbo.rpc.filter.ExceptionFilter;
import org.apache.dubbo.rpc.service.GenericService;

import java.util.Arrays;

@Activate(group = "provider")
@Slf4j
public class GlobalFilterManage extends ExceptionFilter implements Filter {

    @Override
    public Result invoke(
            Invoker<?> invoker, // 执行器
            Invocation invocation // 上下文
    ) throws RpcException {
        // 调试信息
        log.debug("=== Invoker 信息 ===");
        log.debug("接口类: {}", invoker.getInterface().getName());
        log.debug("URL: {}", invoker.getUrl());
        log.debug("=== Invocation 信息 ===");
        log.debug("方法: {}", invocation.getMethodName());
        log.debug("参数类型: {}", Arrays.toString(invocation.getParameterTypes()));
        log.debug("参数的值: {}", Arrays.toString(invocation.getArguments()));
        log.debug("附件: {}", invocation.getAttachments());
        log.debug("目标服务: {}", invocation.getTargetServiceUniqueName());

        // 获取结果
        Result result = invoker.invoke(invocation); // 获取 rpcResult
        log.debug("本次调用获取到的 PRC 结果为 {}", result);

        // 检测异常
        if (!result.hasException() || GenericService.class == invoker.getInterface()) {
            log.debug("没有出现异常");
            return result;
        }
        Throwable exception = result.getException(); // 获取抛出的异常
        log.warn("检测出现异常 {}", exception.getClass().getName());

        // 处理异常
        RpcInvocation rpcInvocation = (RpcInvocation) invocation; // 确保类型正确且非空
        return AsyncRpcResult.newDefaultAsyncResult(this.handleException(exception), rpcInvocation);
    }

    /**
     * 分类处理异常
     */
    private BaseResponse<?> handleException(Throwable exception) {
        BaseResponse<Object> response;
        if (exception instanceof BusinessException be) {
            log.warn("触发业务内部异常处理方法, {}", be.getMessage());
            printStackTraceStatus(be, 1);
            response = TheResult.error(be.getCodeBindMessageEnums(), be.getMessage());
        } else if (exception instanceof NotLoginException) {
            log.warn("触发登录认证异常处理方法, {}", exception.getMessage());
            response = TheResult.error(CodeBindMessageEnums.NO_LOGIN_ERROR, "登录请先进行登录");
        } else if (exception instanceof NotPermissionException) {
            log.warn("触发权限认证异常处理方法(权限码认证), {}", exception.getMessage());
            response = TheResult.error(CodeBindMessageEnums.NO_AUTH_ERROR, "用户当前权限不允许使用该功能");
        } else if (exception instanceof NotRoleException) {
            log.warn("触发角色认证异常处理方法, {}", exception.getMessage());
            response = TheResult.error(CodeBindMessageEnums.NO_ROLE_ERROR, "用户当前角色不允许使用该功能");
        } else if (exception instanceof DisableServiceException) {
            log.warn("触发封禁异常处理方法, {}", exception.getMessage());
            response = TheResult.error(CodeBindMessageEnums.USER_DISABLE_ERROR, "当前用户因为违规被封禁");
        } else {
            log.error("触发全局异常处理方法, {}", exception.getMessage());
            printStackTraceStatus(exception, 0);
            response = TheResult.error(CodeBindMessageEnums.SYSTEM_ERROR, "请联系管理员 89838804@qq.com");
        }
        return response;
    }

    /**
     * 打印异常堆栈定位信息
     */
    private void printStackTraceStatus(Throwable e, int tier) {
        StackTraceElement[] stack = e.getStackTrace();
        if (stack.length > tier) {
            StackTraceElement element = stack[tier];
            log.warn("异常位置: {} -> 文件: {}, 方法: {}, 码行: {}",
                    element.getFileName(),
                    element.getClassName(),
                    element.getMethodName(),
                    element.getLineNumber()
            );
        }
    }

}
