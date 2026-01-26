package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.Favorite;

import java.util.List;

public interface FavoriteService extends IService<Favorite> {
    boolean addFavorite(Favorite favorite);
    boolean removeFavorite(String userId, Long targetId, String targetType);
    List<Favorite> getFavoritesByUserId(String userId);
    boolean isFavorite(String userId, Long targetId, String targetType);
}
