# COUNTING1
resource "docker_image" "database" {
  name = "mysql"
}

resource "docker_volume" "database2-data" {
  name = "database2-data"
}

resource "docker_container" "database2" {
  image = docker_image.database.latest
  name  = "database2"
  restart = "unless-stopped"
  network_mode = "host"
  env = [
    "MYSQL_ROOT_PASSWORD=password",
    "MYSQL_DATABASE=nextcloud",
    "MYSQL_USER=nextcloud",
    "MYSQL_PASSWORD=nextcloud",
  ]
  volumes {
    container_path = "/var/lib/mysql"
    volume_name = "database2-data"
  }
}

resource "docker_container" "database-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "database2-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=database2",
    "-admin-bind=127.0.0.1:19001"
  ]
}