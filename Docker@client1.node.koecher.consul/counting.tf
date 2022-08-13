# COUNTING
resource "docker_image" "hashicorp-counting-service" {
  name = "hashicorp/counting-service:0.0.2"
}

resource "docker_container" "counting" {
  image = docker_image.hashicorp-counting-service.latest
  name  = "counting"
  restart = "unless-stopped"
  env = ["PORT=9003"]
  network_mode = "host"
}

resource "docker_container" "counting-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "counting-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=counting",
    "-admin-bind=127.0.0.1:19000"
  ]
}