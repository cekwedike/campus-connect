import React from 'react';

// Validation rules
export const validationRules = {
  email: {
    required: 'Email is required',
    pattern: {
      value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
      message: 'Invalid email address'
    }
  },
  username: {
    required: 'Username is required',
    minLength: {
      value: 3,
      message: 'Username must be at least 3 characters'
    },
    pattern: {
      value: /^[a-zA-Z0-9_]+$/,
      message: 'Username can only contain letters, numbers, and underscores'
    }
  },
  password: {
    required: 'Password is required',
    minLength: {
      value: 8,
      message: 'Password must be at least 8 characters'
    },
    pattern: {
      value: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      message: 'Password must contain at least one uppercase letter, one lowercase letter, and one number'
    }
  },
  fullName: {
    required: 'Full name is required',
    minLength: {
      value: 2,
      message: 'Full name must be at least 2 characters'
    }
  },
  title: {
    required: 'Title is required',
    minLength: {
      value: 3,
      message: 'Title must be at least 3 characters'
    }
  },
  description: {
    required: 'Description is required',
    minLength: {
      value: 10,
      message: 'Description must be at least 10 characters'
    }
  }
};

// Validation function
export const validateField = (value, rules) => {
  if (rules.required && !value) {
    return rules.required;
  }

  if (value) {
    if (rules.minLength && value.length < rules.minLength.value) {
      return rules.minLength.message;
    }

    if (rules.maxLength && value.length > rules.maxLength.value) {
      return rules.maxLength.message;
    }

    if (rules.pattern && !rules.pattern.value.test(value)) {
      return rules.pattern.message;
    }
  }

  return null;
};

// Error message component
export const ErrorMessage = ({ error, className = '' }) => {
  if (!error) return null;

  return (
    <div className={`text-red-500 text-sm mt-1 ${className}`}>
      {error}
    </div>
  );
};

// Success message component
export const SuccessMessage = ({ message, className = '' }) => {
  if (!message) return null;

  return (
    <div className={`text-green-500 text-sm mt-1 ${className}`}>
      {message}
    </div>
  );
};

// Loading spinner component
export const LoadingSpinner = ({ size = 'md', className = '' }) => {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-6 h-6',
    lg: 'w-8 h-8'
  };

  return (
    <div className={`animate-spin rounded-full border-2 border-gray-300 border-t-primary-500 ${sizeClasses[size]} ${className}`}></div>
  );
};

// Toast notification component
export const Toast = ({ message, type = 'info', onClose, className = '' }) => {
  const typeClasses = {
    success: 'bg-green-500 text-white',
    error: 'bg-red-500 text-white',
    warning: 'bg-yellow-500 text-white',
    info: 'bg-blue-500 text-white'
  };

  return (
    <div className={`fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg ${typeClasses[type]} ${className}`}>
      <div className="flex items-center justify-between">
        <span>{message}</span>
        <button
          onClick={onClose}
          className="ml-4 text-white hover:text-gray-200 focus:outline-none"
        >
          ×
        </button>
      </div>
    </div>
  );
};

// Form field wrapper with validation
export const FormField = ({ 
  label, 
  name, 
  type = 'text', 
  placeholder, 
  value, 
  onChange, 
  onBlur, 
  error, 
  required = false,
  className = '',
  ...props 
}) => {
  return (
    <div className={`mb-4 ${className}`}>
      <label className="block text-sm font-medium text-gray-800 mb-2">
        {label}
        {required && <span className="text-red-500 ml-1">*</span>}
      </label>
      <input
        type={type}
        name={name}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
        placeholder={placeholder}
        className={`w-full px-4 py-3 bg-white border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 placeholder-gray-500 shadow-sm ${
          error ? 'border-red-500 focus:ring-red-500' : ''
        }`}
        {...props}
      />
      <ErrorMessage error={error} />
    </div>
  );
};

// Textarea field wrapper with validation
export const TextareaField = ({ 
  label, 
  name, 
  placeholder, 
  value, 
  onChange, 
  onBlur, 
  error, 
  required = false,
  rows = 4,
  className = '',
  ...props 
}) => {
  return (
    <div className={`mb-4 ${className}`}>
      <label className="block text-sm font-medium text-gray-800 mb-2">
        {label}
        {required && <span className="text-red-500 ml-1">*</span>}
      </label>
      <textarea
        name={name}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
        placeholder={placeholder}
        rows={rows}
        className={`w-full px-4 py-3 bg-white border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 placeholder-gray-500 shadow-sm resize-none ${
          error ? 'border-red-500 focus:ring-red-500' : ''
        }`}
        {...props}
      />
      <ErrorMessage error={error} />
    </div>
  );
};

// Select field wrapper with validation
export const SelectField = ({ 
  label, 
  name, 
  value, 
  onChange, 
  onBlur, 
  error, 
  required = false,
  options = [],
  placeholder,
  className = '',
  ...props 
}) => {
  return (
    <div className={`mb-4 ${className}`}>
      <label className="block text-sm font-medium text-gray-800 mb-2">
        {label}
        {required && <span className="text-red-500 ml-1">*</span>}
      </label>
      <select
        name={name}
        value={value}
        onChange={onChange}
        onBlur={onBlur}
        className={`w-full px-4 py-3 bg-white border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition-all duration-200 text-gray-900 shadow-sm ${
          error ? 'border-red-500 focus:ring-red-500' : ''
        }`}
        {...props}
      >
        {placeholder && (
          <option value="" disabled>
            {placeholder}
          </option>
        )}
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      <ErrorMessage error={error} />
    </div>
  );
}; 