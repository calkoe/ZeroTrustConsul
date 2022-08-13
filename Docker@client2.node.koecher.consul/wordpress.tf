# Wordpress
resource "docker_image" "wordpress" {
  name = "wordpress:latest"
}

resource "docker_volume" "wordpress-data" {
  name = "wordpress-data"
}

resource "docker_container" "wordpress" {
  image = docker_image.wordpress.latest
  name  = "wordpress"
  restart = "unless-stopped"
  network_mode = "host"
  env = [
    "WORDPRESS_DB_HOST=127.0.0.1:3306",
    "WORDPRESS_DB_NAME=wordpress",
    "WORDPRESS_DB_USER=wordpress",
    "WORDPRESS_DB_PASSWORD=wordpress",
  ]
  volumes {
    container_path = "/var/www/html"
    volume_name = "wordpress-data"
  }
}

resource "docker_container" "wordpress-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "wordpress-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=wordpress",
    "-admin-bind=127.0.0.1:19001",
    "--",
    "-l trace"
  ]
}