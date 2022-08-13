resource "docker_container" "ingress-gateway" {
  image = docker_image.consulenvoy.latest
  name  = "ingress-gateway"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-admin-bind=127.0.0.1:19004",
    "-gateway=ingress",
    "-register",
    "-service=ingress-gateway",
    "-token=3c961a65-3adb-050f-df9f-c88b703cf5cd"
  ]
}