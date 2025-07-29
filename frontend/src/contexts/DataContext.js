import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { projectsAPI, tasksAPI } from '../services/api';
import { toast } from 'react-hot-toast';

// Initial state
const initialState = {
  projects: [],
  tasks: [],
  loading: false,
  error: null
};

// Action types
const ACTIONS = {
  SET_LOADING: 'SET_LOADING',
  SET_ERROR: 'SET_ERROR',
  SET_PROJECTS: 'SET_PROJECTS',
  SET_TASKS: 'SET_TASKS',
  ADD_PROJECT: 'ADD_PROJECT',
  UPDATE_PROJECT: 'UPDATE_PROJECT',
  DELETE_PROJECT: 'DELETE_PROJECT',
  ADD_TASK: 'ADD_TASK',
  UPDATE_TASK: 'UPDATE_TASK',
  DELETE_TASK: 'DELETE_TASK',
  CLEAR_DATA: 'CLEAR_DATA'
};

// Reducer function
const dataReducer = (state, action) => {
  switch (action.type) {
    case ACTIONS.SET_LOADING:
      return { ...state, loading: action.payload };
    case ACTIONS.SET_ERROR:
      return { ...state, error: action.payload, loading: false };
    case ACTIONS.SET_PROJECTS:
      return { ...state, projects: action.payload, loading: false };
    case ACTIONS.SET_TASKS:
      return { ...state, tasks: action.payload, loading: false };
    case ACTIONS.ADD_PROJECT:
      return { ...state, projects: [...state.projects, action.payload] };
    case ACTIONS.UPDATE_PROJECT:
      return {
        ...state,
        projects: state.projects.map(project =>
          project.id === action.payload.id ? action.payload : project
        )
      };
    case ACTIONS.DELETE_PROJECT:
      return {
        ...state,
        projects: state.projects.filter(project => project.id !== action.payload)
      };
    case ACTIONS.ADD_TASK:
      return { ...state, tasks: [...state.tasks, action.payload] };
    case ACTIONS.UPDATE_TASK:
      return {
        ...state,
        tasks: state.tasks.map(task =>
          task.id === action.payload.id ? action.payload : task
        )
      };
    case ACTIONS.DELETE_TASK:
      return {
        ...state,
        tasks: state.tasks.filter(task => task.id !== action.payload)
      };
    case ACTIONS.CLEAR_DATA:
      return initialState;
    default:
      return state;
  }
};

// Create context
const DataContext = createContext();

// Provider component
export const DataProvider = ({ children }) => {
  const [state, dispatch] = useReducer(dataReducer, initialState);

  // Load initial data
  const loadData = async () => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      
      const [projectsResponse, tasksResponse] = await Promise.all([
        projectsAPI.getProjects(),
        tasksAPI.getTasks()
      ]);

      const projects = projectsResponse.data.projects || projectsResponse.data || [];
      const tasks = tasksResponse.data.tasks || tasksResponse.data || [];

      dispatch({ type: ACTIONS.SET_PROJECTS, payload: projects });
      dispatch({ type: ACTIONS.SET_TASKS, payload: tasks });
    } catch (error) {
      console.error('Error loading data:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to load data' });
      toast.error('Failed to load data. Please try again.');
    }
  };

  // Project operations
  const createProject = async (projectData) => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      const response = await projectsAPI.createProject(projectData);
      const newProject = response.data;
      dispatch({ type: ACTIONS.ADD_PROJECT, payload: newProject });
      toast.success('Project created successfully!');
      return newProject;
    } catch (error) {
      console.error('Error creating project:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to create project' });
      toast.error('Failed to create project. Please try again.');
      throw error;
    }
  };

  const updateProject = async (id, projectData) => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      const response = await projectsAPI.updateProject(id, projectData);
      const updatedProject = response.data;
      dispatch({ type: ACTIONS.UPDATE_PROJECT, payload: updatedProject });
      toast.success('Project updated successfully!');
      return updatedProject;
    } catch (error) {
      console.error('Error updating project:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to update project' });
      toast.error('Failed to update project. Please try again.');
      throw error;
    }
  };

  const deleteProject = async (id) => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      await projectsAPI.deleteProject(id);
      dispatch({ type: ACTIONS.DELETE_PROJECT, payload: id });
      toast.success('Project deleted successfully!');
    } catch (error) {
      console.error('Error deleting project:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to delete project' });
      toast.error('Failed to delete project. Please try again.');
      throw error;
    }
  };

  // Task operations
  const createTask = async (taskData) => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      const response = await tasksAPI.createTask(taskData);
      const newTask = response.data;
      dispatch({ type: ACTIONS.ADD_TASK, payload: newTask });
      toast.success('Task created successfully!');
      return newTask;
    } catch (error) {
      console.error('Error creating task:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to create task' });
      toast.error('Failed to create task. Please try again.');
      throw error;
    }
  };

  const updateTask = async (id, taskData) => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      const response = await tasksAPI.updateTask(id, taskData);
      const updatedTask = response.data;
      dispatch({ type: ACTIONS.UPDATE_TASK, payload: updatedTask });
      toast.success('Task updated successfully!');
      return updatedTask;
    } catch (error) {
      console.error('Error updating task:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to update task' });
      toast.error('Failed to update task. Please try again.');
      throw error;
    }
  };

  const deleteTask = async (id) => {
    try {
      dispatch({ type: ACTIONS.SET_LOADING, payload: true });
      await tasksAPI.deleteTask(id);
      dispatch({ type: ACTIONS.DELETE_TASK, payload: id });
      toast.success('Task deleted successfully!');
    } catch (error) {
      console.error('Error deleting task:', error);
      dispatch({ type: ACTIONS.SET_ERROR, payload: 'Failed to delete task' });
      toast.error('Failed to delete task. Please try again.');
      throw error;
    }
  };

  // Clear data on logout
  const clearData = () => {
    dispatch({ type: ACTIONS.CLEAR_DATA });
  };

  // Load data on mount
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      loadData();
    }
  }, []);

  const value = {
    ...state,
    loadData,
    createProject,
    updateProject,
    deleteProject,
    createTask,
    updateTask,
    deleteTask,
    clearData
  };

  return (
    <DataContext.Provider value={value}>
      {children}
    </DataContext.Provider>
  );
};

// Custom hook to use the data context
export const useData = () => {
  const context = useContext(DataContext);
  if (!context) {
    throw new Error('useData must be used within a DataProvider');
  }
  return context;
}; 