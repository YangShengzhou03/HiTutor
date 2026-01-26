package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.User;
import com.hitutor.mapper.UserMapper;
import com.hitutor.service.UserService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
    @Override
    public User getUserById(String id) {
        return baseMapper.selectById(id);
    }

    @Override
    public User getUserByEmail(String email) {
        return baseMapper.selectOne(new QueryWrapper<User>().eq("email", email));
    }

    @Override
    public User getUserByPhone(String phone) {
        return baseMapper.selectOne(new QueryWrapper<User>().eq("phone", phone));
    }

    @Override
    public User getUserByUsername(String username) {
        return baseMapper.selectOne(new QueryWrapper<User>().eq("username", username));
    }

    @Override
    public boolean saveUser(User user) {
        return baseMapper.insert(user) > 0;
    }

    @Override
    public boolean updateUser(User user) {
        return baseMapper.updateById(user) > 0;
    }

    @Override
    public boolean deleteUser(String id) {
        return baseMapper.deleteById(id) > 0;
    }

    @Override
    public List<User> getTutors() {
        QueryWrapper<User> queryWrapper = new QueryWrapper<User>()
                .eq("role", "tutor")
                .eq("status", "active");
        
        return baseMapper.selectList(queryWrapper);
    }

    @Override
    public List<User> getStudents() {
        QueryWrapper<User> queryWrapper = new QueryWrapper<User>()
                .eq("role", "student")
                .eq("status", "active");
        
        return baseMapper.selectList(queryWrapper);
    }

    @Override
    public List<User> getAllUsers() {
        return baseMapper.selectList(new QueryWrapper<>());
    }

    @Override
    public int getActiveUsersCount() {
        return baseMapper.selectCount(new QueryWrapper<User>().eq("status", "active")).intValue();
    }

    @Override
    public int getTutorsCount() {
        return baseMapper.selectCount(new QueryWrapper<User>().eq("role", "tutor")).intValue();
    }

    @Override
    public int getStudentsCount() {
        return baseMapper.selectCount(new QueryWrapper<User>().eq("role", "student")).intValue();
    }

    @Override
    public List<User> searchTutors(String query, int page, int size) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<User>()
                .eq("role", "tutor")
                .eq("status", "active")
                .and(wrapper -> wrapper
                    .like("username", query)
                    .or()
                    .like("education", query)
                    .or()
                    .like("major", query)
                );
        
        Page<User> pageObj = new Page<>(page, size);
        Page<User> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        return resultPage.getRecords();
    }

    @Override
    public List<User> searchStudents(String query, int page, int size) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<User>()
                .eq("role", "student")
                .eq("status", "active")
                .and(wrapper -> wrapper
                    .like("username", query)
                    .or()
                    .like("education", query)
                    .or()
                    .like("major", query)
                );
        
        Page<User> pageObj = new Page<>(page, size);
        Page<User> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        return resultPage.getRecords();
    }

    @Override
    public List<User> getUsersByIds(List<String> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }
        return baseMapper.selectList(new QueryWrapper<User>().in("id", ids));
    }

    @Override
    public List<String> getAllUserIds() {
        QueryWrapper<User> queryWrapper = new QueryWrapper<User>()
                .eq("status", "active")
                .select("id");
        List<User> users = baseMapper.selectList(queryWrapper);
        return users.stream().map(User::getId).toList();
    }
}