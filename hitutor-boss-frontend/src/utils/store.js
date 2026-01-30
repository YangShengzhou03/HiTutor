import { reactive } from 'vue'
import * as utils from './utils.js'
import api from '@/services/api.js'

const state = reactive({
  user: null,
  isAuthenticated: utils.isLoggedIn(),
  loading: false,
  isAdmin: false,
  storageInfo: {
    totalStorageGB: 0,
    usedStorageGB: 0
  }
})

const store = {
  state,

  setUser(user) {
    if (user) {
      state.user = user
      state.isAuthenticated = true
      state.isAdmin = true
      if (user.storageInfo) {
        state.storageInfo = user.storageInfo
      }
    }
  },

  setTokens(accessToken, refreshToken) {
    if (accessToken) {
      utils.saveToken(accessToken)
    }
    if (refreshToken) {
      utils.saveRefreshToken(refreshToken)
    }
  },

  clearUser() {
    state.user = null
    state.isAuthenticated = false
    state.isAdmin = false
    utils.removeToken()
    state.storageInfo = {
      totalStorageGB: 0,
      usedStorageGB: 0
    }
  },

  updateStorageInfo(storageInfo) {
    if (storageInfo) {
      state.storageInfo = storageInfo
    }
  },

  async adminLogin(credentials) {
    state.loading = true
    try {
      const response = await api.admin.login(credentials)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess && response.data) {
          const { accessToken, refreshToken, user } = response.data

          if (accessToken) {
            this.setTokens(accessToken, refreshToken)
          }

          if (user) {
            this.setUser(user)
          } else {
            await this.fetchCurrentUser()
          }

          return { success: true, message: response.message || '登录成功', user }
        }

      return { success: false, message: response?.message || '登录失败' }
    } catch (error) {
      return { success: false, message: '登录失败，请检查网络连接' }
    } finally {
      state.loading = false
    }
  },

  async adminRegister(registerData) {
    state.loading = true
    try {
      const response = await api.admin.register(registerData);
      const isSuccess = (response && (response.code === 200 || response.success === true))
      if (isSuccess) {
        return { success: true, message: response.message || '注册成功' };
      } else {
        return { success: false, message: response?.message || '注册失败' };
      }
    } catch (error) {
      return { success: false, message: '注册失败，请检查网络连接' };
    } finally {
      state.loading = false
    }
  },

  async login(credentials) {
    state.loading = true
    try {
      const response = await api.user.login(credentials)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess && response.data) {
          const { accessToken, refreshToken, user } = response.data

          if (accessToken) {
            this.setTokens(accessToken, refreshToken)
          }

          if (user) {
            this.setUser(user)
          } else {
            await this.fetchCurrentUser()
          }

          return { success: true, message: response.message || '登录成功', user }
        }

      return { success: false, message: response?.message || '登录失败' }
    } catch (error) {
      return { success: false, message: '登录失败，请检查网络连接' }
    } finally {
      state.loading = false
    }
  },

  async updateUserProfile(userData) {
    try {
      if (!state.user || !state.user.id) {
        return { success: false, message: '用户未登录' }
      }

      const response = await api.user.updateProfile(state.user.id, userData)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess && response.data) {
        this.setUser({ ...state.user, ...response.data })
        return { success: true, message: response.message || '更新成功' }
      }

      return { success: false, message: response?.message || '更新失败' }
    } catch (error) {
      return { success: false, message: '更新失败，请重试' }
    }
  },

  async changePassword(passwordData) {
    try {
      const response = await api.user.changePassword(passwordData)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess) {
        return { success: true, message: response.message || '密码修改成功' }
      }

      return { success: false, message: response?.message || '密码修改失败' }
    } catch (error) {
      return { success: false, message: '密码修改失败，请重试' }
    }
  },

  async checkAuthStatus() {
    const token = utils.getToken()
    if (!token) {
      this.clearUser()
      return false
    }

    try {
      const decoded = utils.parseJWT(token)

      if (!decoded || !decoded.exp) {
        this.clearUser()
        return false
      }

      if (decoded.exp * 1000 < Date.now()) {
        this.clearUser()
        return false
      }

      if (!decoded.sub) {
        this.clearUser()
        return false
      }

      if (!state.user) {
        await this.fetchCurrentUser().catch((error) => {
          console.log('获取用户信息失败，但 token 仍然有效:', error)
        })
      }

      return true
    } catch (error) {
      this.clearUser()
      return false
    }
  },

  setLoading(loading) {
    state.loading = loading
  },

  getLoading() {
    return state.loading
  },

  async register(userData) {
    state.loading = true
    try {
      const response = await api.user.register(userData)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess) {
          const data = response.data || {}
          const { accessToken, user } = data

          if (accessToken) {
            utils.saveToken(accessToken)

            if (user) {
              this.setUser(user)
            } else {
              await this.fetchCurrentUser().catch(() => {
                console.log('无法获取用户信息，但token已保存')
              })
            }

            return { success: true, message: response.message || '注册成功', user, token: accessToken }
          } else {
            try {
              const loginResponse = await api.user.login({
                email: userData.email,
                password: userData.password
              })

              const isLoginSuccess = (loginResponse && (loginResponse.code === 200 || loginResponse.success === true))

              if (isLoginSuccess && loginResponse.data) {
                const { accessToken: loginToken, user: loginUser } = loginResponse.data

                if (loginToken) {
                  utils.saveToken(loginToken)

                  if (loginUser) {
                    this.setUser(loginUser)
                  } else {
                    await this.fetchCurrentUser().catch(() => {
                      console.log('无法获取用户信息，但token已保存')
                    })
                  }

                  return { success: true, message: response.message || '注册成功并自动登录', loginUser, loginToken }
                }
              }
            } catch (loginError) {
              console.log('自动登录失败', loginError)
            }

            return { success: true, message: response.message || '注册成功，请手动登录' }
          }
        }

      return { success: false, message: response?.message || '注册失败' }
    } catch (error) {
      return { success: false, message: '注册失败，请检查网络连接' }
    } finally {
      state.loading = false
    }
  },

  async fetchCurrentUser() {
    if (!utils.isLoggedIn()) {
      this.clearUser()
      return
    }

    try {
      const response = await api.user.getCurrentUser()

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess && response.data) {
        this.setUser(response.data)

        if (response.data.storageInfo) {
          this.updateStorageInfo(response.data.storageInfo)
        }
      }
    } catch (error) {
      const token = utils.getToken()
      const decoded = utils.parseJWT(token)
      
      if (!decoded || !decoded.exp || decoded.exp * 1000 < Date.now()) {
        this.clearUser()
      }
    }
  },

  async fetchStorageInfo() {
    if (!utils.isLoggedIn()) {
      return null
    }

    try {
      const response = await api.user.getStorageInfo()
      const storageData = response.data || response

      if (storageData) {
        state.storageInfo = {
          totalStorageGB: storageData.storageQuota ? (storageData.storageQuota / (1024 * 1024 * 1024)) : 0,
          usedStorageGB: storageData.usedStorage ? (storageData.usedStorage / (1024 * 1024 * 1024)) : 0,
          availableStorageGB: storageData.availableStorage ? (storageData.availableStorage / (1024 * 1024 * 1024)) : 0,
          usagePercentage: storageData.usagePercentage || 0
        }
      }
      return storageData
    } catch (error) {
      return null
    }
  },

  async updateProfile(userData) {
    state.loading = true
    try {
      const response = await api.user.updateUserInfo(userData)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess && response.data) {
        this.setUser(response.data)
        return { success: true, message: '更新成功' }
      }

      return { success: false, message: response?.message || '更新失败' }
    } catch (error) {
      return { success: false, message: '更新失败，请重试' }
    } finally {
      state.loading = false
    }
  },

  async updatePassword(passwordData) {
    state.loading = true
    try {
      const response = await api.user.changePassword(passwordData)

      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess) {
        return { success: true, message: '密码更新成功' }
      }

      return { success: false, message: response?.message || '密码更新失败' }
    } catch (error) {
      return { success: false, message: '密码更新失败，请重试' }
    } finally {
      state.loading = false
    }
  },

  async logout() {
    try {
      await api.user.logout()
    } catch (error) {
    } finally {
      this.clearUser()
    }
  },

  async refreshToken() {
    const refreshToken = utils.getRefreshToken()
    if (!refreshToken) {
      return false
    }

    try {
      const response = await api.auth.refreshToken({ refreshToken })
      const isSuccess = (response && (response.code === 200 || response.success === true))

      if (isSuccess && response.data) {
        const { accessToken, refreshToken: newRefreshToken } = response.data
        this.setTokens(accessToken, newRefreshToken)
        return true
      }

      return false
    } catch (error) {
      this.clearUser()
      return false
    }
  },

  async init() {
    if (utils.isLoggedIn()) {
      const token = utils.getToken()
      const decoded = utils.parseJWT(token)
      
      if (!decoded || !decoded.exp || decoded.exp * 1000 < Date.now()) {
        this.clearUser()
        return false
      }

      try {
        await this.fetchCurrentUser()
        await this.fetchStorageInfo()
      } catch (error) {
        console.log('初始化时获取用户信息失败，但 token 仍然有效:', error)
      }
      
      return true
    } else {
      this.clearUser()
      return false
    }
  }
}

export default store