package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.User;

import java.util.List;

public interface UserService extends IService<User> {
    User getUserById(String id);
    User getUserByEmail(String email);
    User getUserByPhone(String phone);
    User getUserByUsername(String username);
    boolean saveUser(User user);
    boolean updateUser(User user);
    boolean deleteUser(String id);
    List<User> getTutors();
    List<User> getStudents();
    List<User> getAllUsers();
    int getActiveUsersCount();
    int getTutorsCount();
    int getStudentsCount();
    List<User> searchTutors(String query, int page, int size);
    List<User> searchStudents(String query, int page, int size);
    List<User> getUsersByIds(List<String> ids);
    List<String> getAllUserIds();
    java.util.Map<String, Object> getUserStatistics(String userId);
}