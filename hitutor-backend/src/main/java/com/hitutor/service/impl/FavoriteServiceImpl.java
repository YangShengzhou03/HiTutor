package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Favorite;
import com.hitutor.mapper.FavoriteMapper;
import com.hitutor.service.FavoriteService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {

    @Override
    public boolean addFavorite(Favorite favorite) {
        try {
            int result = baseMapper.insert(favorite);
            return result > 0;
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains("uk_user_target")) {
                return true;
            }
            throw new RuntimeException("添加收藏失败", e);
        }
    }

    @Override
    public boolean removeFavorite(String userId, Long targetId, String targetType) {
        QueryWrapper<Favorite> wrapper = new QueryWrapper<Favorite>()
                .eq("user_id", userId)
                .eq("target_id", targetId)
                .eq("target_type", targetType);
        return baseMapper.delete(wrapper) > 0;
    }

    @Override
    public List<Favorite> getFavoritesByUserId(String userId) {
        return baseMapper.selectList(new QueryWrapper<Favorite>().eq("user_id", userId).orderByDesc("create_time"));
    }

    @Override
    public boolean isFavorite(String userId, Long targetId, String targetType) {
        QueryWrapper<Favorite> wrapper = new QueryWrapper<Favorite>()
                .eq("user_id", userId)
                .eq("target_id", targetId)
                .eq("target_type", targetType);
        return baseMapper.selectCount(wrapper) > 0;
    }
}
