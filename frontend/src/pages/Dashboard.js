import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { projectsAPI, tasksAPI } from '../services/api';
import { 
  Users, 
  FolderOpen, 
  CheckCircle, 
  Clock, 
  TrendingUp, 
  Plus, 
  ArrowRight,
  Calendar,
  Target,
  Award,
  Activity
} from 'lucide-react';

const Dashboard = () => {
  const { user } = useAuth();
  const [stats, setStats] = useState({
    totalProjects: 0,
    totalTasks: 0,
    completedTasks: 0,
    pendingTasks: 0
  });
  const [recentProjects, setRecentProjects] = useState([]);
  const [recentTasks, setRecentTasks] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        toast.error('No authentication token found');
        return;
      }

      // Fetch projects and tasks using the API service
      const [projectsResponse, tasksResponse] = await Promise.all([
        projectsAPI.getProjects(),
        tasksAPI.getTasks()
      ]);

      const projects = projectsResponse.data;
      const tasks = tasksResponse.data;

      // Calculate stats
      const completedTasks = tasks.filter(task => task.status === 'done').length;
      const pendingTasks = tasks.filter(task => task.status !== 'done').length;

      setStats({
        totalProjects: projects.length,
        totalTasks: tasks.length,
        completedTasks,
        pendingTasks
      });

      setRecentProjects(projects.slice(0, 3));
      setRecentTasks(tasks.slice(0, 5));
    } catch (error) {
      console.error('Dashboard data error:', error);
      toast.error('Failed to load dashboard data. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const StatCard = ({ icon: Icon, title, value, color, gradient }) => (
    <div className={`card bg-gradient-to-br ${gradient} border-0 text-white`}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-white/80 text-sm font-medium">{title}</p>
          <p className="text-3xl font-bold mt-1">{value}</p>
        </div>
        <div className={`p-3 rounded-xl bg-white/20 backdrop-blur-sm`}>
          <Icon className="h-6 w-6" />
        </div>
      </div>
    </div>
  );

  const ProjectCard = ({ project }) => (
    <div className="card hover:scale-105 transition-transform duration-300">
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <h3 className="font-semibold text-gray-900 mb-1">{project.title}</h3>
          <p className="text-gray-600 text-sm line-clamp-2">{project.description}</p>
        </div>
        <div className="ml-4">
          <div className="w-2 h-2 bg-green-500 rounded-full"></div>
        </div>
      </div>
      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>Created {new Date(project.created_at).toLocaleDateString()}</span>
        <Link 
          to={`/projects/${project.id}`}
          className="text-primary-600 hover:text-primary-700 font-medium flex items-center"
        >
          View <ArrowRight className="h-4 w-4 ml-1" />
        </Link>
      </div>
    </div>
  );

  const TaskCard = ({ task }) => {
    const getStatusColor = (status) => {
      switch (status) {
        case 'todo': return 'status-todo';
        case 'in_progress': return 'status-in-progress';
        case 'review': return 'status-review';
        case 'done': return 'status-done';
        default: return 'status-todo';
      }
    };

    return (
      <div className="card hover:scale-105 transition-transform duration-300">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <h3 className="font-semibold text-gray-900 mb-1">{task.title}</h3>
            <p className="text-gray-600 text-sm line-clamp-2">{task.description}</p>
          </div>
          <span className={`ml-4 ${getStatusColor(task.status)}`}>
            {task.status.replace('_', ' ')}
          </span>
        </div>
        <div className="flex items-center justify-between text-sm text-gray-500">
          <span>Due: {task.due_date ? new Date(task.due_date).toLocaleDateString() : 'No due date'}</span>
          <Link 
            to={`/projects/${task.project_id}`}
            className="text-primary-600 hover:text-primary-700 font-medium flex items-center"
          >
            View Project <ArrowRight className="h-4 w-4 ml-1" />
          </Link>
        </div>
      </div>
    );
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
        <div className="max-w-7xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              {[1, 2, 3, 4].map(i => (
                <div key={i} className="h-32 bg-gray-200 rounded-2xl"></div>
              ))}
            </div>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              <div className="h-96 bg-gray-200 rounded-2xl"></div>
              <div className="h-96 bg-gray-200 rounded-2xl"></div>
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
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Welcome back, {user?.full_name || user?.username}! 👋
          </h1>
          <p className="text-gray-600 text-lg">
            Here's what's happening with your projects today
          </p>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            icon={FolderOpen}
            title="Total Projects"
            value={stats.totalProjects}
            gradient="from-blue-500 to-blue-600"
          />
          <StatCard
            icon={Target}
            title="Total Tasks"
            value={stats.totalTasks}
            gradient="from-purple-500 to-purple-600"
          />
          <StatCard
            icon={CheckCircle}
            title="Completed"
            value={stats.completedTasks}
            gradient="from-green-500 to-green-600"
          />
          <StatCard
            icon={Clock}
            title="Pending"
            value={stats.pendingTasks}
            gradient="from-orange-500 to-orange-600"
          />
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Recent Projects */}
          <div className="card">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <FolderOpen className="h-5 w-5 text-blue-600" />
                </div>
                <h2 className="text-xl font-semibold text-gray-900">Recent Projects</h2>
              </div>
              <Link
                to="/projects"
                className="btn-primary text-sm py-2 px-4"
              >
                <Plus className="h-4 w-4 mr-2" />
                New Project
              </Link>
            </div>
            
            {recentProjects.length === 0 ? (
              <div className="text-center py-12">
                <FolderOpen className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No projects yet</h3>
                <p className="text-gray-500 mb-4">Start by creating your first project</p>
                <Link to="/projects" className="btn-primary">
                  Create Project
                </Link>
              </div>
            ) : (
              <div className="space-y-4">
                {recentProjects.map(project => (
                  <ProjectCard key={project.id} project={project} />
                ))}
                <div className="text-center pt-4">
                  <Link
                    to="/projects"
                    className="text-primary-600 hover:text-primary-700 font-medium flex items-center justify-center"
                  >
                    View all projects <ArrowRight className="h-4 w-4 ml-1" />
                  </Link>
                </div>
              </div>
            )}
          </div>

          {/* Recent Tasks */}
          <div className="card">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <Activity className="h-5 w-5 text-purple-600" />
                </div>
                <h2 className="text-xl font-semibold text-gray-900">Recent Tasks</h2>
              </div>
              <Link
                to="/tasks"
                className="btn-primary text-sm py-2 px-4"
              >
                <Plus className="h-4 w-4 mr-2" />
                New Task
              </Link>
            </div>
            
            {recentTasks.length === 0 ? (
              <div className="text-center py-12">
                <Activity className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No tasks yet</h3>
                <p className="text-gray-500 mb-4">Create tasks to track your progress</p>
                <Link to="/tasks" className="btn-primary">
                  Create Task
                </Link>
              </div>
            ) : (
              <div className="space-y-4">
                {recentTasks.map(task => (
                  <TaskCard key={task.id} task={task} />
                ))}
                <div className="text-center pt-4">
                  <Link
                    to="/tasks"
                    className="text-primary-600 hover:text-primary-700 font-medium flex items-center justify-center"
                  >
                    View all tasks <ArrowRight className="h-4 w-4 ml-1" />
                  </Link>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mt-8">
          <div className="card">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">Quick Actions</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Link
                to="/projects"
                className="p-6 bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl text-white hover:from-blue-600 hover:to-blue-700 transition-all duration-200 transform hover:-translate-y-1"
              >
                <FolderOpen className="h-8 w-8 mb-3" />
                <h3 className="font-semibold mb-2">Create Project</h3>
                <p className="text-blue-100 text-sm">Start a new collaboration</p>
              </Link>
              
              <Link
                to="/tasks"
                className="p-6 bg-gradient-to-r from-purple-500 to-purple-600 rounded-xl text-white hover:from-purple-600 hover:to-purple-700 transition-all duration-200 transform hover:-translate-y-1"
              >
                <Target className="h-8 w-8 mb-3" />
                <h3 className="font-semibold mb-2">Add Task</h3>
                <p className="text-purple-100 text-sm">Track your progress</p>
              </Link>
              
              <Link
                to="/projects"
                className="p-6 bg-gradient-to-r from-green-500 to-green-600 rounded-xl text-white hover:from-green-600 hover:to-green-700 transition-all duration-200 transform hover:-translate-y-1"
              >
                <Users className="h-8 w-8 mb-3" />
                <h3 className="font-semibold mb-2">Find Team</h3>
                <p className="text-green-100 text-sm">Connect with students</p>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard; 