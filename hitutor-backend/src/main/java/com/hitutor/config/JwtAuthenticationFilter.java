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
            // 对于公开接口，跳过JWT验证
            if (isPublicEndpoint(requestURI)) {
                logger.info("Public endpoint, skipping JWT validation: {}", requestURI);
                filterChain.doFilter(request, response);
                return;
            }
            
            if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
                jwtToken = requestTokenHeader.substring(7);
                
                if (jwtToken != null && !jwtToken.isEmpty()) {
                    try {
                        username = jwtUtil.getUserIdFromToken(jwtToken);
                        logger.info("JWT token validated for user: {}", username);
                    } catch (IllegalArgumentException e) {
                        logger.error("Unable to get JWT Token: {}", e.getMessage());
                        unauthorized(response, "Token无效");
                        return;
                    } catch (ExpiredJwtException e) {
                        logger.error("JWT Token has expired: {}", e.getMessage());
                        unauthorized(response, "Token过期");
                        return;
                    } catch (Exception e) {
                        logger.error("Other error getting JWT Token: {}", e.getMessage());
                        unauthorized(response, "Token无效");
                        return;
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

    private void unauthorized(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":false,\"message\":\"" + message + "\"}");
    }
    
    private boolean isPublicEndpoint(String requestURI) {
        return requestURI.startsWith("/api/auth/") ||
               requestURI.startsWith("/api/subjects/") ||
               requestURI.startsWith("/api/verifications/") ||
               requestURI.startsWith("/api/points/") ||
               requestURI.startsWith("/api/tutor-resumes/") ||
               requestURI.startsWith("/api/tutor-certifications/") ||
               requestURI.startsWith("/api/users/") ||
               requestURI.startsWith("/api/tutor-profiles/") ||
               requestURI.startsWith("/api/student-requests/") ||
               requestURI.startsWith("/api/admin/register");
    }
}
