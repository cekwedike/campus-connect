import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api/v1';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (username, password) => api.post('/auth/login', { username, password }),
  register: (userData) => api.post('/auth/register', userData),
  setToken: (token) => {
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  },
  removeToken: () => {
    delete api.defaults.headers.common['Authorization'];
  },
};

// Users API
export const usersAPI = {
  getUsers: () => api.get('/users/'),
  getUser: (id) => api.get(`/users/${id}`),
  updateUser: (id, data) => api.put(`/users/${id}`, data),
  deleteUser: (id) => api.delete(`/users/${id}`),
};

// Projects API
export const projectsAPI = {
  getProjects: () => api.get('/projects/'),
  getProject: (id) => api.get(`/projects/${id}`),
  createProject: (data) => api.post('/projects/', data),
  updateProject: (id, data) => api.put(`/projects/${id}`, data),
  deleteProject: (id) => api.delete(`/projects/${id}`),
};

// Tasks API
export const tasksAPI = {
  getTasks: () => api.get('/tasks/'),
  getTasksByProject: (projectId) => api.get(`/tasks/project/${projectId}`),
  getTask: (id) => api.get(`/tasks/${id}`),
  createTask: (data) => api.post('/tasks/', data),
  updateTask: (id, data) => api.put(`/tasks/${id}`, data),
  deleteTask: (id) => api.delete(`/tasks/${id}`),
};

// Project Members API
export const projectMembersAPI = {
  getProjectMembers: (projectId) => api.get(`/project-members/project/${projectId}`),
  getUserProjects: (userId) => api.get(`/project-members/user/${userId}`),
  addProjectMember: (data) => api.post('/project-members/', data),
  updateProjectMember: (projectId, userId, data) => 
    api.put(`/project-members/project/${projectId}/user/${userId}`, data),
  removeProjectMember: (projectId, userId) => 
    api.delete(`/project-members/project/${projectId}/user/${userId}`),
};

export default api; 