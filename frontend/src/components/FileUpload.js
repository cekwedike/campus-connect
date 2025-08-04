import React, { useState, useRef } from 'react';
import { Upload, X, File, Download, Trash2 } from 'lucide-react';
import { useToast } from '../contexts/ToastContext';
import api from '../services/api';

// Helper functions
const getFileIcon = (mimeType) => {
  if (mimeType.startsWith('image/')) {
    return '🖼️';
  } else if (mimeType.includes('pdf')) {
    return '📄';
  } else if (mimeType.includes('word') || mimeType.includes('document')) {
    return '📝';
  } else if (mimeType.includes('excel') || mimeType.includes('spreadsheet')) {
    return '📊';
  } else if (mimeType.includes('zip') || mimeType.includes('rar')) {
    return '📦';
  } else {
    return '📎';
  }
};

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const FileUpload = ({ projectId, onFileUploaded, className = '' }) => {
  const [isUploading, setIsUploading] = useState(false);
  const [dragActive, setDragActive] = useState(false);
  const fileInputRef = useRef(null);
  const { showSuccess, showError } = useToast();

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFiles(e.dataTransfer.files);
    }
  };

  const handleFiles = async (files) => {
    setIsUploading(true);
    
    try {
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        await uploadFile(file);
      }
      showSuccess('Files uploaded successfully!');
      if (onFileUploaded) {
        onFileUploaded();
      }
    } catch (error) {
      console.error('Upload error:', error);
      showError('Failed to upload files');
    } finally {
      setIsUploading(false);
    }
  };

  const uploadFile = async (file) => {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await api.post(`/files/upload/${projectId}`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  };

  const handleFileInput = (e) => {
    if (e.target.files && e.target.files[0]) {
      handleFiles(e.target.files);
    }
  };

  const triggerFileInput = () => {
    fileInputRef.current?.click();
  };

  return (
    <div className={className}>
      {/* Upload Area */}
      <div
        className={`relative border-2 border-dashed rounded-lg p-6 text-center transition-colors ${
          dragActive
            ? 'border-primary-500 bg-primary-50'
            : 'border-gray-300 hover:border-gray-400'
        } ${isUploading ? 'opacity-50 pointer-events-none' : ''}`}
        onDragEnter={handleDrag}
        onDragLeave={handleDrag}
        onDragOver={handleDrag}
        onDrop={handleDrop}
      >
        <input
          ref={fileInputRef}
          type="file"
          multiple
          onChange={handleFileInput}
          className="hidden"
          accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.jpg,.jpeg,.png,.gif,.zip,.rar"
        />
        
        <Upload className="mx-auto h-12 w-12 text-gray-400 mb-4" />
        
        <div className="text-lg font-medium text-gray-900 mb-2">
          {isUploading ? 'Uploading...' : 'Upload Files'}
        </div>
        
        <p className="text-gray-500 mb-4">
          Drag and drop files here, or{' '}
          <button
            type="button"
            onClick={triggerFileInput}
            className="text-primary-600 hover:text-primary-700 font-medium"
          >
            browse files
          </button>
        </p>
        
        <p className="text-sm text-gray-400">
          Supported formats: PDF, Word, Excel, Text, Images, Archives (max 10MB each)
        </p>
        
        {isUploading && (
          <div className="mt-4">
            <div className="animate-spin rounded-full h-6 w-6 border-2 border-primary-500 border-t-transparent mx-auto"></div>
          </div>
        )}
      </div>
    </div>
  );
};

// File List Component
export const FileList = ({ files, onFileDeleted, className = '' }) => {
  const { showError } = useToast();

  const handleDownload = async (file) => {
    try {
      const response = await api.get(`/files/download/${file.id}`, {
        responseType: 'blob',
      });
      
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', file.original_filename);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Download error:', error);
      showError('Failed to download file');
    }
  };

  const handleDelete = async (fileId) => {
    try {
      await api.delete(`/files/${fileId}`);
      if (onFileDeleted) {
        onFileDeleted(fileId);
      }
    } catch (error) {
      console.error('Delete error:', error);
      showError('Failed to delete file');
    }
  };

  if (!files || files.length === 0) {
    return (
      <div className={`text-center text-gray-500 py-8 ${className}`}>
        <File className="mx-auto h-12 w-12 text-gray-300 mb-4" />
        <p>No files uploaded yet</p>
      </div>
    );
  }

  return (
    <div className={`space-y-2 ${className}`}>
      {files.map((file) => (
        <div
          key={file.id}
          className="flex items-center justify-between p-3 bg-white border border-gray-200 rounded-lg hover:shadow-sm transition-shadow"
        >
          <div className="flex items-center space-x-3 flex-1 min-w-0">
            <span className="text-2xl">{getFileIcon(file.mime_type)}</span>
            <div className="flex-1 min-w-0">
              <div className="font-medium text-gray-900 truncate">
                {file.original_filename}
              </div>
              <div className="text-sm text-gray-500">
                {formatFileSize(file.file_size)} • {new Date(file.created_at).toLocaleDateString()}
              </div>
              {file.description && (
                <div className="text-sm text-gray-400 truncate">
                  {file.description}
                </div>
              )}
            </div>
          </div>
          
          <div className="flex items-center space-x-2">
            <button
              onClick={() => handleDownload(file)}
              className="p-2 text-gray-400 hover:text-gray-600 transition-colors"
              title="Download"
            >
              <Download className="w-4 h-4" />
            </button>
            <button
              onClick={() => handleDelete(file.id)}
              className="p-2 text-gray-400 hover:text-red-600 transition-colors"
              title="Delete"
            >
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        </div>
      ))}
    </div>
  );
};

export default FileUpload; 