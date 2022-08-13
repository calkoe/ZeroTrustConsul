# AGENT
resource "docker_volume" "consul-data" {
  name = "consul-data"
}

resource "docker_container" "agent" {
  image = docker_image.consul.latest
  name  = "agent"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = ["consul","agent","-config-dir=/consul/config"]
  upload {
    file = "/consul/config/config.hcl"
    content = <<-EOT
      node_name   = "client3"
      datacenter  = "koecher"
      data_dir    = "/consul/data"
      retry_join  = ["server"]
      encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
      bind_addr = "192.168.1.179"
      enable_central_service_config = true
      ports {
        dns   = 53
        grpc  = 8502
      }
      recursors = ["192.168.1.1"]
      verify_incoming = true
      verify_outgoing = true
      verify_server_hostname = true
      ca_file = "ca.pem"
      auto_encrypt {
        tls = true
      }
      acl {
        tokens {
          default  = "374fdee3-9039-ae60-b783-423ba557c19e"
        }
      }
    EOT
  }
  upload {
    file = "/consul/config/nextcloud.service.hcl"
    content = <<-EOT
      service {
          name = "nextcloud"
          id = "nextcloud"
          port = 80
          connect {
              sidecar_service {
                  proxy {
                    transparent_proxy {
                        dialed_directly = true
                    }
                     upstreams = [
                      {
                        destination_name = "database2",
                        datacenter = "venus",
                        local_bind_port  = 3306
                      }
                    ],
                  }
              }
          }
          check {
              id       = "nextcloud-check"
              http     = "http://127.0.0.1:80"
              interval = "1s"
              timeout  = "1s"
          }
      }  
    EOT
  }
  upload {
    file = "ca.pem"
    source = "consul-agent-ca.pem"
    source_hash = filemd5("consul-agent-ca.pem")
  }
  volumes {
    container_path = "/consul/data"
    volume_name = "consul-data"
  }
}