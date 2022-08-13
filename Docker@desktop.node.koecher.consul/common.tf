terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  host     = "ssh://desktop-koecher-local"
  #ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  #host = "unix:///var/run/docker.sock"
}

resource "docker_image" "consul" {
  name = "consul:latest"
}