port        ENV['ATPSTAT_PORT'] || 3000
environment ENV['ATPSTAT_RACK_ENV'] || 'development'
daemonize   true
pidfile     'atp-stat.pid'
