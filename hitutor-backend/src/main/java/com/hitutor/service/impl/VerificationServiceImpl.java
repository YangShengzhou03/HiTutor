package com.hitutor.service.impl;

import com.aliyuncs.CommonRequest;
import com.aliyuncs.CommonResponse;
import com.aliyuncs.DefaultAcsClient;
import com.aliyuncs.IAcsClient;
import com.aliyuncs.exceptions.ClientException;
import com.aliyuncs.exceptions.ServerException;
import com.aliyuncs.http.MethodType;
import com.aliyuncs.profile.DefaultProfile;
import com.hitutor.service.VerificationService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class VerificationServiceImpl implements VerificationService {

    @Value("${aliyun.access-key-id}")
    private String accessKeyId;

    @Value("${aliyun.access-key-secret}")
    private String accessKeySecret;

    @Value("${aliyun.sms.sign-name}")
    private String signName;

    @Value("${aliyun.sms.template-code}")
    private String templateCode;

    private static final int CODE_EXPIRE_MIN = 5;

    @Override
    public void sendVerificationCode(String phone) {
        DefaultProfile profile = DefaultProfile.getProfile("cn-hangzhou", accessKeyId, accessKeySecret);
        IAcsClient client = new DefaultAcsClient(profile);

        String templateParam = String.format("{\"code\":\"##code##\",\"min\":\"%d\"}", CODE_EXPIRE_MIN);

        CommonRequest request = new CommonRequest();
        request.setSysMethod(MethodType.POST);
        request.setSysDomain("dypnsapi.aliyuncs.com");
        request.setSysVersion("2017-05-25");
        request.setSysAction("SendSmsVerifyCode");
        request.putQueryParameter("PhoneNumber", phone);
        request.putQueryParameter("SignName", signName);
        request.putQueryParameter("TemplateCode", templateCode);
        request.putQueryParameter("TemplateParam", templateParam);
        request.putQueryParameter("CodeLength", "6"); // 设置验证码长度为6位

        try {
            CommonResponse response = client.getCommonResponse(request);
            String data = response.getData();
            if (data != null && data.contains("\"Code\":\"OK\"")) {
                return;
            } else {
                throw new RuntimeException("发送验证码失败: " + data);
            }
        } catch (ServerException e) {
            throw new RuntimeException("发送验证码失败: " + e.getErrCode() + " - " + e.getErrMsg());
        } catch (ClientException e) {
            throw new RuntimeException("发送验证码失败: " + e.getErrCode() + " - " + e.getErrMsg());
        }
    }

    @Override
    public boolean verifyCode(String phone, String code) {
        DefaultProfile profile = DefaultProfile.getProfile("cn-hangzhou", accessKeyId, accessKeySecret);
        IAcsClient client = new DefaultAcsClient(profile);

        CommonRequest request = new CommonRequest();
        request.setSysMethod(MethodType.POST);
        request.setSysDomain("dypnsapi.aliyuncs.com");
        request.setSysVersion("2017-05-25");
        request.setSysAction("CheckSmsVerifyCode");
        request.putQueryParameter("PhoneNumber", phone);
        request.putQueryParameter("VerifyCode", code);

        try {
            CommonResponse response = client.getCommonResponse(request);
            String data = response.getData();
            return data != null && data.contains("\"VerifyResult\":\"PASS\"");
        } catch (ServerException e) {
            throw new RuntimeException("验证码校验失败: " + e.getErrCode() + " - " + e.getErrMsg());
        } catch (ClientException e) {
            throw new RuntimeException("验证码校验失败: " + e.getErrCode() + " - " + e.getErrMsg());
        }
    }
}
