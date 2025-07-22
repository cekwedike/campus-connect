import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { tasksAPI, projectsAPI } from '../services/api';
import { 
  Plus, 
  Filter, 
  Search, 
  Calendar, 
  User, 
  FolderOpen,
  Edit,
  Trash2,
  CheckCircle,
  Clock,
  AlertCircle,
  MoreVertical
} from 'lucide-react';

const Tasks = () => {
  const [tasks, setTasks] = useState([]);
  const [projects, setProjects] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [filterStatus, setFilterStatus] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');

  const [newTask, setNewTask] = useState({
    title: '',
    description: '',
    status: 'todo',
    project_id: '',
    due_date: ''
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [tasksResponse, projectsResponse] = await Promise.all([
        tasksAPI.getTasks(),
        projectsAPI.getProjects()
      ]);
      
      setTasks(tasksResponse.data);
      setProjects(projectsResponse.data);
    } catch (error) {
      toast.error('Failed to load tasks');
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreateTask = async (e) => {
    e.preventDefault();
    try {
      // Convert the task data to match the API schema
      const taskData = {
        title: newTask.title,
        description: newTask.description,
        status: newTask.status,
        project_id: parseInt(newTask.project_id),
        due_date: newTask.due_date ? new Date(newTask.due_date).toISOString() : null
      };
      
      await tasksAPI.createTask(taskData);
      toast.success('Task created successfully!');
      setShowCreateModal(false);
      setNewTask({
        title: '',
        description: '',
        status: 'todo',
        project_id: '',
        due_date: ''
      });
      fetchData();
    } catch (error) {
      console.error('Task creation error:', error);
      toast.error('Failed to create task. Please check all required fields.');
    }
  };

  const handleStatusChange = async (taskId, newStatus) => {
    try {
      await tasksAPI.updateTask(taskId, { status: newStatus });
      toast.success('Task status updated!');
      fetchData();
    } catch (error) {
      toast.error('Failed to update task status');
    }
  };

  const handleDeleteTask = async (taskId) => {
    if (window.confirm('Are you sure you want to delete this task?')) {
      try {
        await tasksAPI.deleteTask(taskId);
        toast.success('Task deleted successfully!');
        fetchData();
      } catch (error) {
        toast.error('Failed to delete task');
      }
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'todo': return 'status-todo';
      case 'in_progress': return 'status-in-progress';
      case 'review': return 'status-review';
      case 'done': return 'status-done';
      default: return 'status-todo';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'todo': return <Clock className="h-4 w-4" />;
      case 'in_progress': return <AlertCircle className="h-4 w-4" />;
      case 'review': return <Clock className="h-4 w-4" />;
      case 'done': return <CheckCircle className="h-4 w-4" />;
      default: return <Clock className="h-4 w-4" />;
    }
  };

  const filteredTasks = tasks.filter(task => {
    const matchesStatus = filterStatus === 'all' || task.status === filterStatus;
    const matchesSearch = task.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         task.description?.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const getProjectName = (projectId) => {
    const project = projects.find(p => p.id === projectId);
    return project ? project.title : 'Unknown Project';
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
        <div className="max-w-7xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3, 4, 5, 6].map(i => (
                <div key={i} className="h-48 bg-gray-200 rounded-2xl"></div>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
          <div>
            <h1 className="text-4xl font-bold text-gray-900 mb-2">Tasks</h1>
            <p className="text-gray-600">Manage and track your project tasks</p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="btn-primary mt-4 md:mt-0 flex items-center space-x-2"
          >
            <Plus className="h-5 w-5" />
            <span>Create Task</span>
          </button>
        </div>

        {/* Filters and Search */}
        <div className="card mb-8">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Filter className="h-5 w-5 text-gray-500" />
                <select
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                  className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none"
                >
                  <option value="all">All Status</option>
                  <option value="todo">To Do</option>
                  <option value="in_progress">In Progress</option>
                  <option value="review">Review</option>
                  <option value="done">Done</option>
                </select>
              </div>
            </div>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Search tasks..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none w-full md:w-64"
              />
            </div>
          </div>
        </div>

        {/* Tasks Grid */}
        {filteredTasks.length === 0 ? (
          <div className="card text-center py-12">
            <FolderOpen className="h-16 w-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-xl font-medium text-gray-900 mb-2">No tasks found</h3>
            <p className="text-gray-500 mb-6">
              {searchTerm || filterStatus !== 'all' 
                ? 'Try adjusting your search or filters'
                : 'Create your first task to get started'
              }
            </p>
            {!searchTerm && filterStatus === 'all' && (
              <button
                onClick={() => setShowCreateModal(true)}
                className="btn-primary"
              >
                <Plus className="h-5 w-5 mr-2" />
                Create Task
              </button>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredTasks.map((task) => (
              <div key={task.id} className="card hover:scale-105 transition-transform duration-300">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900 mb-2">{task.title}</h3>
                    <p className="text-gray-600 text-sm mb-3 line-clamp-3">
                      {task.description || 'No description'}
                    </p>
                  </div>
                  <div className="ml-4">
                    <div className="dropdown relative">
                      <button className="p-1 hover:bg-gray-100 rounded">
                        <MoreVertical className="h-4 w-4 text-gray-500" />
                      </button>
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  {/* Status */}
                  <div className="flex items-center justify-between">
                    <span className={`${getStatusColor(task.status)} flex items-center space-x-1`}>
                      {getStatusIcon(task.status)}
                      <span>{task.status.replace('_', ' ')}</span>
                    </span>
                    <select
                      value={task.status}
                      onChange={(e) => handleStatusChange(task.id, e.target.value)}
                      className="text-xs border border-gray-300 rounded px-2 py-1 focus:ring-1 focus:ring-primary-500 focus:border-transparent outline-none"
                    >
                      <option value="todo">To Do</option>
                      <option value="in_progress">In Progress</option>
                      <option value="review">Review</option>
                      <option value="done">Done</option>
                    </select>
                  </div>

                  {/* Project */}
                  <div className="flex items-center space-x-2 text-sm text-gray-500">
                    <FolderOpen className="h-4 w-4" />
                    <span>{getProjectName(task.project_id)}</span>
                  </div>

                  {/* Due Date */}
                  {task.due_date && (
                    <div className="flex items-center space-x-2 text-sm text-gray-500">
                      <Calendar className="h-4 w-4" />
                      <span>Due: {new Date(task.due_date).toLocaleDateString()}</span>
                    </div>
                  )}

                  {/* Actions */}
                  <div className="flex items-center justify-between pt-3 border-t border-gray-100">
                    <Link
                      to={`/projects/${task.project_id}`}
                      className="text-primary-600 hover:text-primary-700 text-sm font-medium"
                    >
                      View Project
                    </Link>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => handleDeleteTask(task.id)}
                        className="p-1 text-red-500 hover:text-red-700 hover:bg-red-50 rounded"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Create Task Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl p-6 w-full max-w-md">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Create New Task</h2>
            <form onSubmit={handleCreateTask} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
                <input
                  type="text"
                  value={newTask.title}
                  onChange={(e) => setNewTask({...newTask, title: e.target.value})}
                  className="input-modern"
                  placeholder="Enter task title"
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
                <textarea
                  value={newTask.description}
                  onChange={(e) => setNewTask({...newTask, description: e.target.value})}
                  className="input-modern"
                  placeholder="Enter task description"
                  rows="3"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Project</label>
                <select
                  value={newTask.project_id}
                  onChange={(e) => setNewTask({...newTask, project_id: e.target.value})}
                  className="input-modern"
                  required
                >
                  <option value="">Select a project</option>
                  {projects.map(project => (
                    <option key={project.id} value={project.id}>{project.title}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
                <select
                  value={newTask.status}
                  onChange={(e) => setNewTask({...newTask, status: e.target.value})}
                  className="input-modern"
                >
                  <option value="todo">To Do</option>
                  <option value="in_progress">In Progress</option>
                  <option value="review">Review</option>
                  <option value="done">Done</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Due Date</label>
                <input
                  type="date"
                  value={newTask.due_date}
                  onChange={(e) => setNewTask({...newTask, due_date: e.target.value})}
                  className="input-modern"
                />
              </div>

              <div className="flex items-center justify-end space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800 font-medium"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="btn-primary"
                >
                  Create Task
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Tasks; 