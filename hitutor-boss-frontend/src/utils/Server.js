import axios from 'axios'
import { getToken, parseJWT } from './utils.js'

const Server = axios.create({
  baseURL: process.env.VUE_APP_API_BASE_URL || '',
  timeout: 10000
})

const pendingRequests = new Map()

function generateRequestKey(config) {
  const { method, url, params, data } = config
  return [method, url, JSON.stringify(params), JSON.stringify(data)].join('&')
}

Server.interceptors.request.use(async config => {
  const requestKey = generateRequestKey(config)
  
  if (pendingRequests.has(requestKey)) {
    return Promise.reject(new Error('请求重复'))
  }
  
  pendingRequests.set(requestKey, true)
  config.requestKey = requestKey

  const token = getToken()
  if (token) {
    const decoded = parseJWT(token)
    const isTokenExpired = decoded && decoded.exp && decoded.exp * 1000 < Date.now()

    if (isTokenExpired) {
      return Promise.reject(new Error('登录已过期，请重新登录'))
    } else {
      config.headers.Authorization = `Bearer ${token}`
    }
  }
  return config
})

Server.interceptors.response.use(
  response => {
    if (response.config.requestKey) {
      pendingRequests.delete(response.config.requestKey)
    }

    if (response.data === null || response.data === undefined) {
      return { data: null, code: 500, message: '响应数据为空' }
    }

    if (response.config.responseType === 'blob') {
      return response
    }

    const data = response.data

    if (data.success !== undefined) {
      if (data.success === true) {
        return data
      } else {
        if (data.message && (data.message.includes('Token无效') ||
          data.message.includes('Token过期') ||
          data.message.includes('未授权访问'))) {
          return Promise.reject(new Error('登录已过期，请重新登录'))
        }

        return Promise.reject(new Error(data.message || '请求失败'))
      }
    }

    if (data.code !== undefined) {
      if (data.code === 200) {
        return data
      } else {
        if (data.message && (data.message.includes('Token无效') ||
          data.message.includes('Token过期') ||
          data.message.includes('未授权访问'))) {
          return Promise.reject(new Error('登录已过期，请重新登录'))
        }

        return Promise.reject(new Error(data.message || '请求失败'))
      }
    }

    return data
  },
  error => {
    if (error.config && error.config.requestKey) {
      pendingRequests.delete(error.config.requestKey)
    }

    if (error.message === '请求重复') {
      return Promise.reject(error)
    }

    if (!error.response) {
      return Promise.reject(error)
    }

    const status = error.response.status
    const url = error.config?.url || ''
    const responseData = error.response?.data

    switch (status) {
      case 401:
        if (responseData && responseData.message) {
          return Promise.reject(new Error(responseData.message))
        } else {
          return Promise.reject(new Error('登录已过期，请重新登录'))
        }
      case 403:
        if (responseData && responseData.message) {
          return Promise.reject(new Error(responseData.message))
        } else {
          return Promise.reject(new Error('权限不足，无法访问该资源'))
        }
      case 404:
        if (url.includes('/api/card-keys/')) {
          return Promise.reject(new Error('卡密不存在或参数错误'))
        } else if (responseData && responseData.message) {
          return Promise.reject(new Error(responseData.message))
        } else {
          return Promise.reject(new Error('请求的资源不存在'))
        }
      case 409:
        if (responseData && responseData.message) {
          return Promise.reject(new Error(responseData.message))
        } else {
          return Promise.reject(new Error('资源冲突，请检查数据'))
        }
      case 500:
        if (responseData && responseData.message) {
          return Promise.reject(new Error(responseData.message))
        } else {
          return Promise.reject(new Error('服务器内部错误，请联系管理员'))
        }
      default:
        if (responseData && responseData.message) {
          return Promise.reject(new Error(responseData.message))
        } else {
          return Promise.reject(new Error('请求失败，请稍后重试'))
        }
    }
  }
)

const http = {
  get: (url, params = {}) => Server.get(url, { params }),
  post: (url, data = {}) => Server.post(url, data),
  put: (url, data = {}) => Server.put(url, data),
  delete: (url, params = {}) => Server.delete(url, { params }),
  upload: (url, formData, onUploadProgress) => {
    return Server.post(url, formData, {
      onUploadProgress
    })
  },
  request: (url, config = {}) => Server.get(url, config),
  download: (url, config = {}) => {
    return Server.get(url, {
      ...config,
      responseType: 'blob'
    })
  }
}

export default http