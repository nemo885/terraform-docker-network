terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

locals {
  cidr_block = "10.10.0.0/16"

  zones      = ["zone-a", "zone-b", "zone-c"]
  zone_cidrs = { for i, name in local.zones : name => cidrsubnet(local.cidr_block, 8, i) }
}


resource "docker_network" "zone" {
  for_each = local.zone_cidrs
  name     = each.key

  ipam_config {
    subnet = each.value
  }
}

data "docker_registry_image" "ubuntu" {
  name = "ubuntu:latest"
}

resource "docker_image" "ubuntu" {
  name          = data.docker_registry_image.ubuntu.name
  pull_triggers = [data.docker_registry_image.ubuntu.sha256_digest]
}