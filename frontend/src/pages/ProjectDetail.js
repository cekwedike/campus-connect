import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { projectsAPI, tasksAPI } from '../services/api';
import { toast } from 'react-hot-toast';
import { Plus, Edit, Trash2, Users, Calendar, CheckSquare, FileText } from 'lucide-react';

const ProjectDetail = () => {
  const { id } = useParams();
  const [project, setProject] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showTaskModal, setShowTaskModal] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');
  const [taskForm, setTaskForm] = useState({
    title: '',
    description: '',
    due_date: ''
  });

  useEffect(() => {
    fetchProjectData();
  }, [id]);

  const fetchProjectData = async () => {
    try {
      setLoading(true);
      
      // Get project details
      const projectRes = await projectsAPI.getProject(id);
      setProject(projectRes.data);
      
      // Get all tasks for the current user (we'll filter by project_id on frontend)
      const tasksRes = await tasksAPI.getTasks();
      const projectTasks = tasksRes.data.tasks.filter(task => task.project_id === parseInt(id));
      setTasks(projectTasks);
      
    } catch (error) {
      console.error('Error fetching project data:', error);
      toast.error('Failed to load project data');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateTask = async (e) => {
    e.preventDefault();
    try {
      await tasksAPI.createTask({
        ...taskForm,
        project_id: parseInt(id)
      });
      toast.success('Task created successfully!');
      setShowTaskModal(false);
      setTaskForm({ title: '', description: '', due_date: '' });
      fetchProjectData();
    } catch (error) {
      console.error('Error creating task:', error);
      toast.error('Failed to create task');
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'done':
        return 'bg-green-100 text-green-800';
      case 'in_progress':
        return 'bg-blue-100 text-blue-800';
      case 'review':
        return 'bg-yellow-100 text-yellow-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!project) {
    return (
      <div className="text-center py-12">
        <h3 className="text-lg font-medium text-gray-900">Project not found</h3>
        <Link to="/projects" className="text-primary-600 hover:text-primary-500">
          Back to Projects
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Project Header */}
      <div className="bg-white shadow rounded-lg p-6">
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{project.title}</h1>
            <p className="mt-2 text-gray-600">{project.description || 'No description'}</p>
            <div className="mt-4 flex items-center text-sm text-gray-500">
              <Calendar className="w-4 h-4 mr-1" />
              Created {new Date(project.created_at).toLocaleDateString()}
            </div>
          </div>
          <div className="flex space-x-2">
            <Link
              to="/projects"
              className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
            >
              Back to Projects
            </Link>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white shadow rounded-lg">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {[
              { id: 'overview', name: 'Overview', icon: '📊' },
              { id: 'tasks', name: 'Tasks', icon: '✅' }
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2 ${
                  activeTab === tab.id
                    ? 'border-primary-500 text-primary-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <span>{tab.icon}</span>
                <span>{tab.name}</span>
              </button>
            ))}
          </nav>
        </div>

        <div className="p-6">
          {/* Overview Tab */}
          {activeTab === 'overview' && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="bg-blue-50 p-4 rounded-lg">
                <h3 className="text-lg font-medium text-blue-900">Total Tasks</h3>
                <p className="text-3xl font-bold text-blue-600">{tasks.length}</p>
              </div>
              <div className="bg-green-50 p-4 rounded-lg">
                <h3 className="text-lg font-medium text-green-900">Completed</h3>
                <p className="text-3xl font-bold text-green-600">
                  {tasks.filter(task => task.status === 'done').length}
                </p>
              </div>
              <div className="bg-purple-50 p-4 rounded-lg">
                <h3 className="text-lg font-medium text-purple-900">In Progress</h3>
                <p className="text-3xl font-bold text-purple-600">
                  {tasks.filter(task => task.status === 'in_progress').length}
                </p>
              </div>
            </div>
          )}

          {/* Tasks Tab */}
          {activeTab === 'tasks' && (
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <h3 className="text-lg font-medium text-gray-900">Project Tasks</h3>
                <button
                  onClick={() => setShowTaskModal(true)}
                  className="flex items-center space-x-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                >
                  <Plus className="w-4 h-4" />
                  <span>Add Task</span>
                </button>
              </div>
              
              {tasks.length === 0 ? (
                <div className="text-center py-8">
                  <p className="text-gray-500">No tasks yet. Create your first task!</p>
                </div>
              ) : (
                <div className="grid gap-4">
                  {tasks.map((task) => (
                    <div key={task.id} className="bg-gray-50 p-4 rounded-lg">
                      <div className="flex justify-between items-start">
                        <div>
                          <h4 className="font-medium text-gray-900">{task.title}</h4>
                          <p className="text-sm text-gray-600 mt-1">{task.description}</p>
                          {task.due_date && (
                            <p className="text-xs text-gray-500 mt-1">
                              Due: {new Date(task.due_date).toLocaleDateString()}
                            </p>
                          )}
                        </div>
                        <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(task.status)}`}>
                          {task.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Task Modal */}
      {showTaskModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Create New Task</h3>
            <form onSubmit={handleCreateTask} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  value={taskForm.title}
                  onChange={(e) => setTaskForm({...taskForm, title: e.target.value})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Description</label>
                <textarea
                  value={taskForm.description}
                  onChange={(e) => setTaskForm({...taskForm, description: e.target.value})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  rows="3"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Due Date</label>
                <input
                  type="date"
                  value={taskForm.due_date}
                  onChange={(e) => setTaskForm({...taskForm, due_date: e.target.value})}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => setShowTaskModal(false)}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
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

export default ProjectDetail; 