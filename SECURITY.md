# Security Guide for CampusConnect

## 🔐 Password Security

### Recent Security Update
- **Date**: July 24, 2025
- **Action**: Removed hardcoded passwords from codebase
- **Status**: ✅ Completed

### What Was Changed
1. **Database Password**: Replaced `Enechi_1206` with secure placeholder `YourStrongPassword123!`
2. **Terraform Variables**: Added proper variable definitions for sensitive data
3. **Scripts Updated**: All deployment scripts now use secure password variables
4. **Environment Files**: Updated templates with secure placeholders

### Current Secure Configuration
- **Database Password**: `YourStrongPassword123!` (placeholder - change this!)
- **Secret Key**: `1234567890ekwedike` (placeholder - change this!)
- **Database URL**: Uses environment variables

## 🛡️ Security Best Practices

### 1. Change Default Passwords
**IMPORTANT**: Before deploying to production, change these passwords:

```bash
# Database Password
DB_PASSWORD=YourStrongPassword123!  # Change this!

# Secret Key
SECRET_KEY=1234567890ekwedike  # Change this!
```

### 2. Use Strong Passwords
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, and symbols
- Avoid common words or patterns
- Use a password manager

### 3. Environment Variables
Never commit real passwords to version control. Use:
- `.env` files (for local development)
- Azure Key Vault (for production)
- Environment variables in deployment scripts

### 4. Azure Security
- Enable Azure Key Vault for secret management
- Use Managed Identities where possible
- Enable Azure Security Center
- Regular security audits

## 🔧 How to Update Passwords

### Option 1: Use the Update Script
```powershell
.\update-database-password.ps1
```

### Option 2: Manual Update
1. Update `env.example` with your new password
2. Update Azure database password:
   ```bash
   az postgres flexible-server update --resource-group campus-connect-rg --name campus-connect-postgres --admin-password "YourNewPassword"
   ```
3. Update backend environment variables:
   ```bash
   az containerapp update --name campus-connect-backend --resource-group campus-connect-rg --set-env-vars "DATABASE_URL=postgresql://postgres:YourNewPassword@campus-connect-postgres.postgres.database.azure.com:5432/campusconnect"
   ```

## 📋 Security Checklist

- [ ] Change database password from default
- [ ] Change secret key from default
- [ ] Enable Azure Key Vault (recommended)
- [ ] Review and update CORS settings
- [ ] Enable HTTPS everywhere
- [ ] Set up monitoring and alerts
- [ ] Regular security updates
- [ ] Backup and disaster recovery plan

## 🚨 Security Notes

1. **Never commit real passwords** to Git
2. **Use environment variables** for all sensitive data
3. **Regular password rotation** is recommended
4. **Monitor access logs** for suspicious activity
5. **Keep dependencies updated** to patch security vulnerabilities

## 📞 Security Support

If you suspect a security issue:
1. Change all passwords immediately
2. Review access logs
3. Contact your security team
4. Consider rotating all secrets

---

**Remember**: Security is everyone's responsibility. Stay vigilant and keep your application secure! 🔒 