output "network_cidrs" {
  value = {
    frontend = local.frontend_cidr
    backend  = local.backend_cidr
    db       = local.db_cidr
  }
}

output "container_ips" {
  value = {
    proxy        = local.proxy_ip
    db           = local.db_ip
    app_backend  = local.app_ip
    app_frontend = local.app_frontend_ip
    app_db       = local.app_db_ip
  }
}