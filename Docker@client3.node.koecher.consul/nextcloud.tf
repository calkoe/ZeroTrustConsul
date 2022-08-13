resource "docker_image" "nextcloud" {
  name = "nextcloud:latest"
}

resource "docker_volume" "nextcloud-data" {
  name = "nextcloud-data"
}

resource "docker_container" "nextcloud" {
  image = docker_image.nextcloud.latest
  name  = "nextcloud"
  restart = "unless-stopped"
  network_mode = "host"
  volumes {
    container_path = "/var/www/html"
    volume_name = "nextcloud-data"
  }
}

resource "docker_container" "nextcloud-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "nextcloud-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=nextcloud",
    "-admin-bind=127.0.0.1:19000",
    "--",
    "-l trace"
  ]
}