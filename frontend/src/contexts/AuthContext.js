import React, { createContext, useContext, useState, useEffect } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in on app start
    const token = localStorage.getItem('token');
    if (token) {
      // Set token in API headers
      authAPI.setToken(token);
      // Fetch user data from backend to restore session
      const restoreSession = async () => {
        try {
          // Try to get user info from backend
          const response = await authAPI.getUserInfo();
          setUser({ ...response.data, token });
        } catch (error) {
          console.error('Failed to restore session:', error);
          // If token is invalid, clear it
          localStorage.removeItem('token');
          authAPI.removeToken();
          setUser(null);
        } finally {
          setLoading(false);
        }
      };
      restoreSession();
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (username, password) => {
    try {
      console.log('Attempting login with:', { username, password });
      const response = await authAPI.login(username, password);
      console.log('Login response:', response);
      
      const { access_token, user: userData } = response.data;
      
      localStorage.setItem('token', access_token);
      authAPI.setToken(access_token);
      
      setUser({ ...userData, token: access_token });
      return { success: true };
    } catch (error) {
      console.error('Login error:', error);
      console.error('Error response:', error.response);
      
      let errorMessage = 'Login failed';
      
      if (error.response) {
        // Server responded with error status
        if (error.response.status === 401) {
          errorMessage = 'Incorrect username or password';
        } else if (error.response.status === 400) {
          errorMessage = error.response.data?.detail || 'Invalid request';
        } else if (error.response.status >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = error.response.data?.detail || 'Login failed';
        }
      } else if (error.request) {
        // Request was made but no response received
        errorMessage = 'No response from server. Please check your connection.';
      } else {
        // Something else happened
        errorMessage = error.message || 'Login failed';
      }
      
      return { 
        success: false, 
        error: errorMessage 
      };
    }
  };

  const register = async (userData) => {
    try {
      const response = await authAPI.register(userData);
      return { success: true, data: response.data };
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.detail || 'Registration failed' 
      };
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    authAPI.removeToken();
    setUser(null);
  };

  const value = {
    user,
    login,
    register,
    logout,
    loading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}; 