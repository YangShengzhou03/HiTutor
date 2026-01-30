import { createRouter, createWebHistory } from 'vue-router';
import store from '@/utils/store.js';
import * as utils from '@/utils/utils.js';

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginPage.vue'),
    meta: {
      title: '管理员登录 - 好会帮',
      requiresAuth: false
    }
  },

  {
    path: '/',
    name: 'HomePage',
    component: () => import('@/components/IndexLayout.vue'),
    meta: {
      title: '好会帮 - 家教平台',
      requiresAuth: false
    }
  },

  {
    path: '/admin',
    component: () => import('@/components/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/DashboardPage.vue'),
        meta: {
          title: '好会帮 - 数据概览',
          requiresAuth: true
        }
      },
      {
        path: 'users',
        name: 'UserManagement',
        component: () => import('@/views/admin/UserManagement.vue'),
        meta: {
          title: '好会帮 - 用户管理',
          requiresAuth: true
        }
      },
      {
        path: 'points',
        name: 'PointManagement',
        component: () => import('@/views/admin/PointManagement.vue'),
        meta: {
          title: '好会帮 - 积分管理',
          requiresAuth: true
        }
      },
      {
        path: 'blacklist',
        name: 'BlacklistManagement',
        component: () => import('@/views/admin/BlacklistManagement.vue'),
        meta: {
          title: '好会帮 - 黑名单管理',
          requiresAuth: true
        }
      },
      {
        path: 'tutor-profiles',
        name: 'TutorProfileManagement',
        component: () => import('@/views/admin/TutorProfileManagement.vue'),
        meta: {
          title: '好会帮 - 家教信息',
          requiresAuth: true
        }
      },
      {
        path: 'tutor-certifications',
        name: 'TutorCertificationManagement',
        component: () => import('@/views/admin/TutorCertificationManagement.vue'),
        meta: {
          title: '好会帮 - 认证审核',
          requiresAuth: true
        }
      },
      {
        path: 'tutor-resumes',
        name: 'TutorResumeManagement',
        component: () => import('@/views/admin/TutorResumeManagement.vue'),
        meta: {
          title: '好会帮 - 家教简历',
          requiresAuth: true
        }
      },
      {
        path: 'student-requests',
        name: 'StudentRequestManagement',
        component: () => import('@/views/admin/StudentRequestManagement.vue'),
        meta: {
          title: '好会帮 - 学生需求',
          requiresAuth: true
        }
      },
      {
        path: 'appointments',
        name: 'AppointmentManagement',
        component: () => import('@/views/admin/AppointmentManagement.vue'),
        meta: {
          title: '好会帮 - 预约管理',
          requiresAuth: true
        }
      },
      {
        path: 'reviews',
        name: 'ReviewManagement',
        component: () => import('@/views/admin/ReviewManagement.vue'),
        meta: {
          title: '好会帮 - 评价管理',
          requiresAuth: true
        }
      },
      {
        path: 'subjects',
        name: 'SubjectManagement',
        component: () => import('@/views/admin/SubjectManagement.vue'),
        meta: {
          title: '好会帮 - 科目管理',
          requiresAuth: true
        }
      },
      {
        path: 'complaints',
        name: 'ComplaintManagement',
        component: () => import('@/views/admin/ComplaintManagement.vue'),
        meta: {
          title: '好会帮 - 投诉管理',
          requiresAuth: true
        }
      },
      {
        path: 'notifications',
        name: 'NotificationManagement',
        component: () => import('@/views/admin/NotificationManagement.vue'),
        meta: {
          title: '好会帮 - 通知管理',
          requiresAuth: true
        }
      },
      {
        path: 'profile',
        name: 'ProfilePage',
        component: () => import('@/views/admin/ProfilePage.vue'),
        meta: {
          title: '好会帮 - 个人设置',
          requiresAuth: true
        }
      }
    ]
  },

  {
    path: '/share/:id?',
    name: 'SharePage',
    component: () => import('@/components/IndexLayout.vue'),
    meta: {
      title: '好会帮 - 家教平台',
      requiresAuth: false
    }
  },

  {
    path: '/user-guide',
    name: 'UserGuidePage',
    component: () => import('@/views/index/UserGuidePage.vue'),
    meta: {
      title: '使用指南 - 好会帮',
      requiresAuth: false
    }
  },
  {
    path: '/contact-us',
    name: 'ContactUsPage',
    component: () => import('@/views/index/ContactUsPage.vue'),
    meta: {
      title: '联系我们 - 好会帮',
      requiresAuth: false
    }
  },
  {
    path: '/faq',
    name: 'FAQPage',
    component: () => import('@/views/index/FaqPage.vue'),
    meta: {
      title: '常见问题 - 好会帮',
      requiresAuth: false
    }
  },

  {
    path: '/author-info',
    name: 'AuthorInfoPage',
    component: () => import('@/views/index/AuthorInfoPage.vue'),
    meta: {
      title: '作者介绍 - 好会帮',
      requiresAuth: false
    }
  },
  {
    path: '/privacy-policy',
    name: 'PrivacyPolicyPage',
    component: () => import('@/views/index/PrivacyPolicyPage.vue'),
    meta: {
      title: '隐私保护 - 好会帮',
      requiresAuth: false
    }
  },

  { path: '/:pathMatch(.*)*', redirect: '/' }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach(async (to, from, next) => {
  if (to.meta.title) {
    document.title = to.meta.title;
  }

  if (to.meta.requiresAuth) {
    const token = utils.getToken();
    
    if (!token) {
      store.clearUser();
      next('/login');
      return;
    }

    const decoded = utils.parseJWT(token);
    
    if (!decoded || !decoded.exp || decoded.exp * 1000 < Date.now()) {
      store.clearUser();
      next('/login');
      return;
    }

    if (!store.state.user) {
      try {
        await store.fetchCurrentUser();
      } catch (error) {
        console.log('路由守卫获取用户信息失败:', error);
        // 不要立即清除用户信息，只在token确实过期时才清除
      }
    }

    next();
    return;
  }

  if (to.path === '/login' && utils.isLoggedIn()) {
    const decoded = utils.parseJWT(utils.getToken());
    
    if (decoded && decoded.exp && decoded.exp * 1000 >= Date.now()) {
      next('/admin');
      return;
    } else {
      store.clearUser();
    }
  }

  next();
});

export default router;