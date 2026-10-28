
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}





locals {
  
  base_cidr = "10.0.0.0/16" 

  frontend_cidr = cidrsubnet(local.base_cidr, 8, 0)
  backend_cidr  = cidrsubnet(local.base_cidr, 10, 4)
  db_cidr       = cidrsubnet(local.base_cidr, 12, 20)
  app_ip        = cidrhost(local.backend_cidr, 5)
  app_frontend_ip = cidrhost(local.frontend_cidr, 10)
  app_db_ip       = cidrhost(local.db_cidr, 10)
  proxy_ip      = cidrhost(local.frontend_cidr, 5)
  db_ip         = cidrhost(local.db_cidr, 6)
}


resource "docker_network" "frontend_net" {
  name = "frontend_net"
  ipam_config {
    subnet = local.frontend_cidr
  }
}

resource "docker_network" "backend_net" {
  name = "backend_net"
  ipam_config {
    subnet = local.backend_cidr
  }
}

resource "docker_network" "db_net" {
  name = "db_net"
  internal = true
  ipam_config {
    subnet = local.db_cidr
  }
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_image" "alpine" {
  name = "alpine"
}

resource "docker_image" "redis" {
  name = "redis:alpine"
}

resource "docker_container" "proxy" {
   name = "proxy"
   image = docker_image.nginx.image_id
   networks_advanced {
    name        = docker_network.frontend_net.id
    ipv4_address = local.proxy_ip
   }
   ports {
    internal = 80
    external = 8080
   }
}

resource "docker_container" "app" {
  name = "app"
  image = docker_image.alpine.image_id
  command = ["sleep", "infinity"]
  networks_advanced {
    name = docker_network.backend_net.id
    ipv4_address = local.app_ip
  }
  networks_advanced {
    name = docker_network.frontend_net.id
    ipv4_address = local.app_frontend_ip
  }
  networks_advanced {
    name = docker_network.db_net.id
    ipv4_address = local.app_db_ip
  }
}

resource "docker_container" "db" {
  name = "db"
  image = docker_image.redis.image_id
  networks_advanced {
    name = docker_network.db_net.id
    ipv4_address = local.db_ip
  }
}