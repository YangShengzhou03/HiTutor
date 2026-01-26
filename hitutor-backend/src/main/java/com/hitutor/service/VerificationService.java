package com.hitutor.service;

public interface VerificationService {
    void sendVerificationCode(String phone);
    boolean verifyCode(String phone, String code);
}