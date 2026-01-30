<template>
  <div class="author-info-page">
    <!-- 简洁的头部区域 -->
    <header class="page-header">
      <div class="container">
        <h1>关于作者</h1>
        <p>好会帮运营管理系统 · 独立开发者技术实践与产品探索</p>
      </div>
    </header>

    <main class="page-content">
      <div class="container">
        <div class="author-sections">
          <!-- 开发者简介 -->
          <section class="author-section">
            <div class="section-header">
              <h2>开发者简介</h2>
            </div>
            <div class="section-content">
              <div class="author-profile">
                <div class="profile-avatar">
                  <div class="avatar-circle">
                    <span class="avatar-text">Yang</span>
                  </div>
                </div>
                <div class="profile-info">
                  <div class="name-title">
                    <h3>杨圣洲</h3>
                    <span class="developer-badge">好会帮 开发者</span>
                  </div>
                  <div class="profile-title">江西科技师范大学 · 信息管理与信息系统</div>
                  <div class="profile-subtitle">籍贯：吉安县 | 2022年江西省职教高考（三校生）全省第一名（559分）</div>
                  <div class="expertise-tags">
                    <span class="tag">Vue.js</span>
                    <span class="tag">Spring Boot</span>
                    <span class="tag">MySQL</span>
                    <span class="tag">Docker</span>
                    <span class="tag">Kubernetes</span>
                    <span class="tag">Linux</span>
                    <span class="tag">DevOps</span>
                  </div>
                  <p class="profile-bio">
                    全栈独立开发者，专注于从零到一构建实用产品。2022年参加江西省职教高考（三校生），以559分获得全省第一名，考入江西科技师范大学信息管理与信息系统专业。大学期间，系统学习 Linux、Docker、K8S 等 DevOps 与运维相关技术，专注于 Windows 桌面工具、自动化解决方案及企业级系统的研发与落地。
                  </p>
                  <div class="projects-section">
                    <h4>代表项目</h4>
                    <div class="project-list">
                      <div class="project-item">
                        <span class="project-name">Jobs_helper（海投助手）</span>
                        <span class="project-desc">浏览器脚本插件，聚焦 Boss 直聘平台，具备自动化简历投递、AI 智能回复 HR 消息等功能</span>
                      </div>
                      <div class="project-item">
                        <span class="project-name">LeafSort（轻羽媒体整理）</span>
                        <span class="project-desc">融合深度学习算法与多线程处理能力，可对海量照片与视频进行整理、归类及去重，通过微软应用商店、联想应用商店分发，适配 Windows 系统</span>
                      </div>
                      <div class="project-item">
                        <span class="project-name">LeafPan</span>
                        <span class="project-desc">基于 Vue 3 + Spring Boot 3 技术栈构建，为企业级文件管理平台</span>
                      </div>
                      <div class="project-item">
                        <span class="project-name">LeafBoss</span>
                        <span class="project-desc">基于 Spring Boot 3 + Vue3 + Element Plus + MySQL + JavaScript 技术栈构建，专注于卡密全生命周期管理与安全验证服务</span>
                      </div>
                      <div class="project-item">
                        <span class="project-name">Lucky_SMS</span>
                        <span class="project-desc">教育类开源系统，基于 Vue 3 和 Spring Boot 开发，具备多角色权限控制，适用于毕业设计、商业应用及教育管理场景，后续更新了用户信息脱敏功能</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <!-- 开发历程 -->
          <section class="author-section">
            <div class="section-header">
              <h2>开发历程</h2>
            </div>
            <div class="section-content">
              <div class="timeline">
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                      <h3>项目构思 · 2024年1月</h3>
                      <p>深入分析现有卡管理系统痛点，构思打造轻量级、高可用的业务运营支撑系统</p>
                    </div>
                  </div>
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                      <h3>技术选型 · 2024年2月</h3>
                      <p>确定采用 Vue 3 + Spring Boot 3 现代化技术栈，完成系统架构设计与技术方案论证</p>
                    </div>
                  </div>
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                      <h3>核心开发 · 2024年3月-7月</h3>
                      <p>完成前后端核心功能开发，实现卡管理、用户管理、权限控制等关键模块</p>
                    </div>
                  </div>
                <div class="timeline-item">
                    <div class="timeline-marker"></div>
                    <div class="timeline-content">
                    <h3>正式发布 · 2024年10月27日</h3>
                    <p>好会帮运营管理系统正式上线，开始为用户提供稳定服务</p>
                    </div>
                  </div>
                <div class="timeline-item">
                  <div class="timeline-marker"></div>
                  <div class="timeline-content">
                    <h3>全面重构 · 2026年1月18日</h3>
                    <p>系统全面架构升级，正式更名为 好会帮，大幅提升性能与用户体验</p>
                  </div>
                </div>
              </div>
            </div>
          </section>

        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { onMounted } from 'vue';

export default {
  name: 'AuthorInfoPage',
  setup() {
    onMounted(() => {
      // 页面加载完成后的逻辑
    });
  }
}
</script>

<style scoped>
.author-info-page {
  min-height: 100vh;
  background-color: #f8fafc;
}

.page-header {
  background-color: #2d3748;
  color: white;
  padding: 40px 0;
  text-align: center;
}

.page-header h1 {
  font-size: 36px;
  margin-bottom: 16px;
  font-weight: 700;
}

.page-header p {
  font-size: 18px;
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto;
}

.page-content {
  padding: 40px 0 60px;
}

.author-sections {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.author-section {
  background: white;
  border: 1px solid #ddd;
  padding: 0;
}

.section-header {
  background-color: #2d3748;
  padding: 24px 32px;
  color: white;
}

.section-header h2 {
  font-size: 24px;
  margin: 0;
  font-weight: 600;
}

.section-content {
  padding: 32px;
}

.author-profile {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  max-width: 800px;
  margin: 0 auto;
}

.profile-avatar {
  flex-shrink: 0;
}

.avatar-circle {
  width: 120px;
  height: 120px;
  background-color: #2d3748;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 4px solid white;
}

.avatar-text {
  font-size: 36px;
  font-weight: 700;
  color: white;
}

.profile-info {
  flex: 1;
}

.name-title {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 12px;
}

.name-title h3 {
  font-size: 32px;
  margin: 0;
  color: #2c3e50;
  font-weight: 700;
}

.developer-badge {
  background-color: #ff6b6b;
  color: white;
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 600;
}

.profile-title {
  font-size: 18px;
  color: #2d3748;
  margin-bottom: 20px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.profile-bio {
  font-size: 16px;
  line-height: 1.8;
  color: #4a5568;
  margin-bottom: 24px;
  background-color: #f8fafc;
  padding: 20px;
  text-align: justify;
  text-justify: inter-ideograph;
}

.profile-subtitle {
  font-size: 16px;
  color: #718096;
  margin-bottom: 16px;
  font-weight: 500;
}

.projects-section {
  margin-top: 32px;
}

.projects-section h4 {
  font-size: 18px;
  color: #2c3e50;
  margin-bottom: 16px;
  font-weight: 600;
}

.project-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.project-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 12px;
  background-color: #f8fafc;
  border-radius: 4px;
}

.project-name {
  font-size: 15px;
  font-weight: 600;
  color: #2c3e50;
}

.project-desc {
  font-size: 14px;
  line-height: 1.6;
  color: #4a5568;
}

.expertise-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 24px;
}

.tag {
  background-color: #f7fafc;
  color: #2d3748;
  padding: 8px 16px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 600;
  border: 1px solid #cbd5e0;
}

.timeline {
  position: relative;
  padding-left: 32px;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 16px;
  top: 0;
  bottom: 0;
  width: 2px;
  background-color: #e2e8f0;
}

.timeline-item {
  position: relative;
  margin-bottom: 32px;
}

.timeline-marker {
  position: absolute;
  left: -24px;
  top: 8px;
  width: 12px;
  height: 12px;
  background-color: #2d3748;
  border-radius: 50%;
  border: 2px solid white;
}

.timeline-content h3 {
  font-size: 18px;
  margin-bottom: 8px;
  color: #2c3e50;
}

.timeline-content p {
  color: #4a5568;
  line-height: 1.6;
}

.container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 20px;
}

@media (max-width: 768px) {
  .page-header {
    padding: 40px 0;
  }
  
  .page-header h1 {
    font-size: 28px;
  }
  
  .page-header p {
    font-size: 16px;
  }
  
  .page-content {
    padding: 40px 0 60px;
  }
  
  .author-profile {
    flex-direction: column;
    text-align: center;
    gap: 24px;
  }
  
  .avatar-circle {
    width: 100px;
    height: 100px;
    margin: 0 auto;
  }
  
  .avatar-text {
    font-size: 36px;
  }
  
  .name-title {
    flex-direction: column;
    gap: 12px;
  }
  
  .name-title h3 {
    font-size: 24px;
  }
  
  .profile-title {
    font-size: 16px;
  }
  
  .profile-bio {
    font-size: 14px;
    padding: 16px;
  }
  
  .section-header {
    padding: 20px;
  }
  
  .section-header h2 {
    font-size: 20px;
  }
  
  .section-content {
    padding: 24px 20px;
  }
  
  .expertise-tags {
    justify-content: center;
  }
}
</style>