resource "docker_container" "sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  user = "0:0"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=desktop",
    "--",
    "-l trace"
  ]
}