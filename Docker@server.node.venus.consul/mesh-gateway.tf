resource "docker_container" "mesh-gateway" {
  image = docker_image.consulenvoy.latest
  name  = "mesh-gateway"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-admin-bind=127.0.0.1:19005",
    "-gateway=mesh",
    "-register",
    "-service=mesh-gateway",
    "-address=[REMOVED]:22001",
    "-wan-address=[REMOVED]:22002",
    "-expose-servers"
  ]
}