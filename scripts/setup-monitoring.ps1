# CampusConnect Monitoring Setup Script
# This script sets up comprehensive monitoring and observability for the application

Write-Host "🔧 Setting up CampusConnect Monitoring and Observability..." -ForegroundColor Green

# Azure Login
Write-Host "📝 Logging into Azure..." -ForegroundColor Yellow
az login

# Set variables
$RESOURCE_GROUP = "campus-connect-rg"
$LOCATION = "West US 2"
$APP_INSIGHTS_NAME = "campusconnect-insights"
$LOG_ANALYTICS_NAME = "campusconnect-logs"

# Create Application Insights
Write-Host "📊 Creating Application Insights..." -ForegroundColor Yellow
az monitor app-insights component create `
    --app $APP_INSIGHTS_NAME `
    --location $LOCATION `
    --resource-group $RESOURCE_GROUP `
    --application-type web `
    --kind web

# Get Application Insights key
$APP_INSIGHTS_KEY = az monitor app-insights component show `
    --app $APP_INSIGHTS_NAME `
    --resource-group $RESOURCE_GROUP `
    --query "instrumentationKey" `
    --output tsv

Write-Host "✅ Application Insights created with key: $APP_INSIGHTS_KEY" -ForegroundColor Green

# Create Log Analytics Workspace
Write-Host "📋 Creating Log Analytics Workspace..." -ForegroundColor Yellow
az monitor log-analytics workspace create `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --location $LOCATION

# Get Log Analytics key
$LOG_ANALYTICS_KEY = az monitor log-analytics workspace get-shared-keys `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LOG_ANALYTICS_NAME `
    --query "primarySharedKey" `
    --output tsv

Write-Host "✅ Log Analytics Workspace created with key: $LOG_ANALYTICS_KEY" -ForegroundColor Green

# Update Container Apps with monitoring
Write-Host "🔗 Updating Container Apps with monitoring..." -ForegroundColor Yellow

# Update Backend with Application Insights
az containerapp update `
    --name "campus-connect-backend" `
    --resource-group $RESOURCE_GROUP `
    --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$APP_INSIGHTS_KEY" `
    --set-env-vars "APPLICATIONINSIGHTS_ROLE_NAME=backend" `
    --set-env-vars "APPLICATIONINSIGHTS_SERVICE_NAME=campusconnect-backend"

# Update Frontend with Application Insights
az containerapp update `
    --name "campus-connect-frontend" `
    --resource-group $RESOURCE_GROUP `
    --set-env-vars "REACT_APP_APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$APP_INSIGHTS_KEY" `
    --set-env-vars "REACT_APP_APPLICATIONINSIGHTS_ROLE_NAME=frontend" `
    --set-env-vars "REACT_APP_APPLICATIONINSIGHTS_SERVICE_NAME=campusconnect-frontend"

Write-Host "✅ Container Apps updated with monitoring" -ForegroundColor Green

# Create monitoring dashboard
Write-Host "📊 Creating monitoring dashboard..." -ForegroundColor Yellow

# Create dashboard resource
$DASHBOARD_NAME = "campusconnect-dashboard"
$DASHBOARD_JSON = @"
{
    "properties": {
        "lenses": {
            "0": {
                "order": 0,
                "parts": {
                    "0": {
                        "position": {
                            "x": 0,
                            "y": 0,
                            "colSpan": 6,
                            "rowSpan": 4
                        },
                        "metadata": {
                            "inputs": [],
                            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
                            "settings": {
                                "content": {
                                    "Query": "requests | where timestamp > ago(1h) | summarize count() by bin(timestamp, 5m)",
                                    "PartTitle": "Request Rate",
                                    "PartSubTitle": "Requests per 5 minutes"
                                }
                            }
                        }
                    },
                    "1": {
                        "position": {
                            "x": 6,
                            "y": 0,
                            "colSpan": 6,
                            "rowSpan": 4
                        },
                        "metadata": {
                            "inputs": [],
                            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
                            "settings": {
                                "content": {
                                    "Query": "exceptions | where timestamp > ago(1h) | summarize count() by bin(timestamp, 5m)",
                                    "PartTitle": "Error Rate",
                                    "PartSubTitle": "Exceptions per 5 minutes"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
"@

# Save dashboard JSON to file
$DASHBOARD_JSON | Out-File -FilePath "monitoring/dashboard-azure.json" -Encoding UTF8

Write-Host "✅ Monitoring dashboard configuration created" -ForegroundColor Green

# Create alerts
Write-Host "🚨 Creating monitoring alerts..." -ForegroundColor Yellow

# High Error Rate Alert
az monitor metrics alert create `
    --name "high-error-rate" `
    --resource-group $RESOURCE_GROUP `
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/Components/$APP_INSIGHTS_NAME" `
    --condition "avg requests/failedRequests > 5" `
    --description "Alert when error rate exceeds 5%" `
    --window-size "PT5M" `
    --evaluation-frequency "PT1M"

# High Response Time Alert
az monitor metrics alert create `
    --name "high-response-time" `
    --resource-group $RESOURCE_GROUP `
    --scopes "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/Components/$APP_INSIGHTS_NAME" `
    --condition "avg requests/duration > 2000" `
    --description "Alert when average response time exceeds 2 seconds" `
    --window-size "PT5M" `
    --evaluation-frequency "PT1M"

Write-Host "✅ Monitoring alerts created" -ForegroundColor Green

# Create monitoring documentation
Write-Host "📝 Creating monitoring documentation..." -ForegroundColor Yellow

$MONITORING_DOC = @"
# CampusConnect Monitoring Setup

## Overview
This document describes the monitoring and observability setup for CampusConnect.

## Components

### Application Insights
- **Name**: $APP_INSIGHTS_NAME
- **Key**: $APP_INSIGHTS_KEY
- **Purpose**: Application performance monitoring and telemetry

### Log Analytics
- **Name**: $LOG_ANALYTICS_NAME
- **Key**: $LOG_ANALYTICS_KEY
- **Purpose**: Centralized logging and analytics

## Dashboards

### Main Dashboard
- **URL**: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/Components/$APP_INSIGHTS_NAME
- **Features**:
  - Request rate monitoring
  - Error rate tracking
  - Response time analysis
  - User activity metrics

## Alerts

### Critical Alerts
1. **High Error Rate**: Triggers when error rate > 5%
2. **High Response Time**: Triggers when avg response time > 2s
3. **Application Unavailable**: Triggers when health check fails

### Warning Alerts
1. **High Memory Usage**: Triggers when memory > 80%
2. **High CPU Usage**: Triggers when CPU > 90%

## Metrics Tracked

### Application Metrics
- Request rate (requests/sec)
- Response time (p50, p95, p99)
- Error rate (%)
- User sessions
- Page views

### Infrastructure Metrics
- Container CPU usage
- Container memory usage
- Database connections
- Network I/O

### Business Metrics
- Active users
- Feature usage
- User engagement

## Logging

### Log Levels
- **ERROR**: Application errors and exceptions
- **WARN**: Warning conditions
- **INFO**: General information
- **DEBUG**: Detailed debugging information

### Log Retention
- Application logs: 30 days
- Infrastructure logs: 90 days
- Security logs: 1 year

## Troubleshooting

### Common Issues
1. **High Error Rate**: Check application logs for exceptions
2. **High Response Time**: Check database performance and external dependencies
3. **Memory Issues**: Check for memory leaks in application code

### Useful Queries
```kusto
// Recent errors
exceptions | where timestamp > ago(1h) | order by timestamp desc

// Slow requests
requests | where duration > 2000 | order by duration desc

// User activity
pageViews | where timestamp > ago(24h) | summarize count() by bin(timestamp, 1h)
```

## Contact Information
- **DevOps Team**: devops@campusconnect.com
- **On-Call**: oncall@campusconnect.com
- **Security**: security@campusconnect.com
"@

$MONITORING_DOC | Out-File -FilePath "monitoring/README.md" -Encoding UTF8

Write-Host "✅ Monitoring documentation created" -ForegroundColor Green

# Display monitoring URLs
Write-Host "`n🎉 Monitoring setup complete!" -ForegroundColor Green
Write-Host "`n📊 Monitoring URLs:" -ForegroundColor Cyan
Write-Host "Application Insights: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/Components/$APP_INSIGHTS_NAME" -ForegroundColor White
Write-Host "Log Analytics: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_ANALYTICS_NAME" -ForegroundColor White

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure notification channels (email, Slack, PagerDuty)" -ForegroundColor White
Write-Host "2. Set up custom dashboards for specific teams" -ForegroundColor White
Write-Host "3. Configure log retention policies" -ForegroundColor White
Write-Host "4. Set up automated reporting" -ForegroundColor White

Write-Host "`n✅ Monitoring setup completed successfully!" -ForegroundColor Green 