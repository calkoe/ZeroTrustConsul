# DASHBAORD
resource "docker_image" "hashicorp-dashboard-service" {
  name = "hashicorp/dashboard-service:0.0.4"
}

resource "docker_container" "dashboard" {
  image = docker_image.hashicorp-dashboard-service.latest
  name  = "dashboard"
  restart = "unless-stopped"
  network_mode = "host"
  env = [
    "COUNTING_SERVICE_URL=http://127.0.0.1:9003"
  ]
}

resource "docker_container" "dashboard-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "dashboard-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=dashboard",
    "-admin-bind=127.0.0.1:19000",
    "--",
    "-l trace"
  ]
}