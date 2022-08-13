# NFS
resource "docker_image" "samba" {
  name = "dperson/samba:latest"
}

resource "docker_volume" "samba-data" {
  name = "samba-data"
}

resource "docker_container" "samba" {
  image = docker_image.samba.latest
  name  = "samba"
  restart = "unless-stopped"
  network_mode = "host"
  env = [
      "SHARE=share;/samba-data;yes;no;yes;all"
  ]
  volumes {
    container_path = "/samba-data"
    volume_name = "samba-data"
  }
}

resource "docker_container" "samba-sidecar" {
  image = docker_image.consulenvoy.latest
  name  = "samba-sidecar"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "connect",
    "envoy",
    "-sidecar-for=samba",
    "-admin-bind=127.0.0.1:19002",
    "--",
    "-l trace"
  ]
}