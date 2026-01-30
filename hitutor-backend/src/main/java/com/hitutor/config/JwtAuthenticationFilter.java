package com.hitutor.config;

import com.hitutor.util.JwtUtil;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        
        final String requestURI = request.getRequestURI();
        final String method = request.getMethod();
        logger.info("Processing request: {} {}", method, requestURI);
        
        final String requestTokenHeader = request.getHeader("Authorization");

        String username = null;
        String jwtToken = null;

        try {
            if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
                jwtToken = requestTokenHeader.substring(7);
                
                if (jwtToken != null && !jwtToken.isEmpty()) {
                    try {
                        username = jwtUtil.getUserIdFromToken(jwtToken);
                        logger.info("JWT token validated for user: {}", username);
                    } catch (IllegalArgumentException e) {
                        logger.error("Unable to get JWT Token: {}", e.getMessage());
                    } catch (ExpiredJwtException e) {
                        logger.error("JWT Token has expired: {}", e.getMessage());
                    } catch (Exception e) {
                        logger.error("Other error getting JWT Token: {}", e.getMessage());
                    }
                }
            }

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                if (jwtUtil.validateAccessToken(jwtToken)) {
                    String role = jwtUtil.getRoleFromToken(jwtToken);
                    
                    UsernamePasswordAuthenticationToken authToken = 
                        new UsernamePasswordAuthenticationToken(username, null, 
                            Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role)));
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    logger.info("Authentication set for user: {} with role: {}", username, role);
                }
            }
        } catch (Exception e) {
            logger.error("Error processing JWT token: {}", e.getMessage(), e);
        }
        
        filterChain.doFilter(request, response);
    }
}
