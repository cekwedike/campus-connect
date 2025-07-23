import React, { useState, useEffect, useRef } from 'react';
import { Search, X, Users, FolderOpen, CheckSquare } from 'lucide-react';
import { useToast } from '../contexts/ToastContext';
import api from '../services/api';

const SearchBar = ({ onResultClick, className = '' }) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const searchRef = useRef(null);
  const { showError } = useToast();

  // Close search results when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (searchRef.current && !searchRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Search function with debouncing
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (query.trim().length >= 2) {
        performSearch();
      } else {
        setResults(null);
        setIsOpen(false);
      }
    }, 300);

    return () => clearTimeout(timeoutId);
  }, [query]);

  const performSearch = async () => {
    if (!query.trim()) return;

    setIsLoading(true);
    try {
      const response = await api.get(`/search/global?q=${encodeURIComponent(query)}`);
      setResults(response.data);
      setIsOpen(true);
    } catch (error) {
      console.error('Search error:', error);
      showError('Failed to perform search');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResultClick = (type, item) => {
    setIsOpen(false);
    setQuery('');
    if (onResultClick) {
      onResultClick(type, item);
    }
  };

  const clearSearch = () => {
    setQuery('');
    setResults(null);
    setIsOpen(false);
  };

  const getIcon = (type) => {
    switch (type) {
      case 'projects':
        return <FolderOpen className="w-4 h-4" />;
      case 'tasks':
        return <CheckSquare className="w-4 h-4" />;
      case 'users':
        return <Users className="w-4 h-4" />;
      default:
        return <Search className="w-4 h-4" />;
    }
  };

  const getResultCount = () => {
    if (!results) return 0;
    return (results.projects?.length || 0) + 
           (results.tasks?.length || 0) + 
           (results.users?.length || 0);
  };

  return (
    <div className={`relative ${className}`} ref={searchRef}>
      {/* Search Input */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search projects, tasks, users..."
          className="w-full pl-10 pr-10 py-2 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 placeholder-gray-500"
        />
        {query && (
          <button
            onClick={clearSearch}
            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {/* Search Results */}
      {isOpen && (
        <div className="absolute top-full left-0 right-0 mt-2 bg-white border border-gray-200 rounded-lg shadow-lg z-50 max-h-96 overflow-y-auto">
          {isLoading ? (
            <div className="p-4 text-center text-gray-500">
              <div className="animate-spin rounded-full h-6 w-6 border-2 border-primary-500 border-t-transparent mx-auto mb-2"></div>
              Searching...
            </div>
          ) : results && getResultCount() > 0 ? (
            <div className="p-2">
              {/* Projects */}
              {results.projects && results.projects.length > 0 && (
                <div className="mb-4">
                  <div className="flex items-center gap-2 px-2 py-1 text-sm font-medium text-gray-700 bg-gray-50 rounded">
                    <FolderOpen className="w-4 h-4" />
                    Projects ({results.projects.length})
                  </div>
                  {results.projects.map((project) => (
                    <div
                      key={project.id}
                      onClick={() => handleResultClick('project', project)}
                      className="flex items-center gap-3 p-2 hover:bg-gray-50 rounded cursor-pointer transition-colors"
                    >
                      <FolderOpen className="w-4 h-4 text-blue-500 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-gray-900 truncate">{project.title}</div>
                        <div className="text-sm text-gray-500 truncate">{project.description}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* Tasks */}
              {results.tasks && results.tasks.length > 0 && (
                <div className="mb-4">
                  <div className="flex items-center gap-2 px-2 py-1 text-sm font-medium text-gray-700 bg-gray-50 rounded">
                    <CheckSquare className="w-4 h-4" />
                    Tasks ({results.tasks.length})
                  </div>
                  {results.tasks.map((task) => (
                    <div
                      key={task.id}
                      onClick={() => handleResultClick('task', task)}
                      className="flex items-center gap-3 p-2 hover:bg-gray-50 rounded cursor-pointer transition-colors"
                    >
                      <CheckSquare className="w-4 h-4 text-green-500 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-gray-900 truncate">{task.title}</div>
                        <div className="text-sm text-gray-500 truncate">{task.description}</div>
                        <div className="text-xs text-gray-400 capitalize">{task.status}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* Users */}
              {results.users && results.users.length > 0 && (
                <div className="mb-4">
                  <div className="flex items-center gap-2 px-2 py-1 text-sm font-medium text-gray-700 bg-gray-50 rounded">
                    <Users className="w-4 h-4" />
                    Users ({results.users.length})
                  </div>
                  {results.users.map((user) => (
                    <div
                      key={user.id}
                      onClick={() => handleResultClick('user', user)}
                      className="flex items-center gap-3 p-2 hover:bg-gray-50 rounded cursor-pointer transition-colors"
                    >
                      <Users className="w-4 h-4 text-purple-500 flex-shrink-0" />
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-gray-900 truncate">{user.full_name}</div>
                        <div className="text-sm text-gray-500 truncate">@{user.username}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : query && !isLoading ? (
            <div className="p-4 text-center text-gray-500">
              No results found for "{query}"
            </div>
          ) : null}
        </div>
      )}
    </div>
  );
};

export default SearchBar; 