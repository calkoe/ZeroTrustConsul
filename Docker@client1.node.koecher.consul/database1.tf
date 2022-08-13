# COUNTING1
resource "docker_image" "database" {
  name = "mysql"
}

resource "docker_volume" "database1-data" {
  name = "database1-data"
}

resource "docker_container" "database1" {
  image = docker_image.database.latest
  name  = "database1"
  restart = "unless-stopped"
  network_mode = "host"
  env = [
    "MYSQL_ROOT_PASSWORD=password",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=wordpress",
  ]
  volumes {
    container_path = "/var/lib/mysql"
    volume_name = "database1-data"
  }
}

resource "docker_container" "database-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "database1-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=database1",
    "-admin-bind=127.0.0.1:19001"
  ]
}