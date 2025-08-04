import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useData } from '../contexts/DataContext';
import { useAuth } from '../contexts/AuthContext';
import { Plus, ArrowRight, Edit, Trash2, Calendar, Users, FolderOpen } from 'lucide-react';

const Projects = () => {
  const { user } = useAuth();
  const { projects, loading, createProject, deleteProject } = useData();
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    status: 'active'
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await createProject({
        ...formData,
        owner_id: user.id
      });
      setFormData({ title: '', description: '', status: 'active' });
      setShowCreateForm(false);
    } catch (error) {
      console.error('Error creating project:', error);
    }
  };

  const handleDelete = async (projectId) => {
    if (window.confirm('Are you sure you want to delete this project?')) {
      try {
        await deleteProject(projectId);
      } catch (error) {
        console.error('Error deleting project:', error);
      }
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
        <div className="max-w-7xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3, 4, 5, 6].map(i => (
                <div key={i} className="h-64 bg-gray-200 rounded-2xl"></div>
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
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-4xl font-bold text-gray-900 mb-2">My Projects</h1>
            <p className="text-gray-600 text-lg">
              Manage and organize your collaborative projects
            </p>
          </div>
          <button
            onClick={() => setShowCreateForm(true)}
            className="btn-primary flex items-center gap-2"
          >
            <Plus className="h-5 w-5" />
            New Project
          </button>
        </div>

        {/* Create Project Modal */}
        {showCreateForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-2xl p-8 max-w-md w-full mx-4">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Create New Project</h2>
              <form onSubmit={handleSubmit}>
                <div className="mb-4">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Project Title
                  </label>
                  <input
                    type="text"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="Enter project title"
                    required
                  />
                </div>
                <div className="mb-4">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Description
                  </label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="Enter project description"
                    rows="3"
                  />
                </div>
                <div className="mb-6">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Status
                  </label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="active">Active</option>
                    <option value="planning">Planning</option>
                    <option value="completed">Completed</option>
                    <option value="on-hold">On Hold</option>
                  </select>
                </div>
                <div className="flex gap-3">
                  <button
                    type="submit"
                    className="flex-1 btn-primary"
                  >
                    Create Project
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowCreateForm(false)}
                    className="flex-1 btn-secondary"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Projects Grid */}
        {projects.length === 0 ? (
          <div className="text-center py-12">
            <div className="bg-white rounded-2xl p-8 max-w-md mx-auto">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <FolderOpen className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">No projects yet</h3>
              <p className="text-gray-500 mb-6">
                Get started by creating your first project to collaborate with others.
              </p>
              <button
                onClick={() => setShowCreateForm(true)}
                className="btn-primary flex items-center gap-2 mx-auto"
              >
                <Plus className="h-5 w-5" />
                Create Your First Project
              </button>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project) => (
              <div key={project.id} className="card hover:scale-105 transition-transform duration-300">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900 mb-2">{project.title}</h3>
                    <p className="text-gray-600 text-sm line-clamp-3 mb-3">
                      {project.description || 'No description provided'}
                    </p>
                  </div>
                  <div className="ml-4 flex gap-2">
                    <button
                      onClick={() => handleDelete(project.id)}
                      className="p-1 text-red-500 hover:text-red-700 transition-colors"
                      title="Delete project"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
                
                <div className="flex items-center justify-between text-sm text-gray-500 mb-4">
                  <span className="flex items-center gap-1">
                    <Calendar className="h-4 w-4" />
                    {new Date(project.created_at).toLocaleDateString()}
                  </span>
                  <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                    project.status === 'active' ? 'bg-green-100 text-green-800' :
                    project.status === 'planning' ? 'bg-blue-100 text-blue-800' :
                    project.status === 'completed' ? 'bg-gray-100 text-gray-800' :
                    'bg-yellow-100 text-yellow-800'
                  }`}>
                    {project.status}
                  </span>
                </div>

                <Link 
                  to={`/projects/${project.id}`}
                  className="text-primary-600 hover:text-primary-700 font-medium flex items-center justify-center w-full py-2 border border-primary-200 rounded-lg hover:bg-primary-50 transition-colors"
                >
                  View Project <ArrowRight className="h-4 w-4 ml-1" />
                </Link>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Projects; 