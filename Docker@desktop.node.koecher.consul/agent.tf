# AGENT
resource "docker_volume" "consul-data" {
  name = "consul-data"
}

resource "docker_container" "agent" {
  image = docker_image.consul.latest
  name  = "agent"
  restart = "unless-stopped"
  network_mode = "host"
  user = "0:0"
  privileged = true
  entrypoint = ["consul","agent","-config-dir=/consul/config"]
  upload {
    file = "/consul/config/config.hcl"
    content = <<-EOT
      node_name   = "desktop"
      datacenter  = "koecher"
      data_dir    = "/consul/data"
      retry_join  = ["server"]
      encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
      bind_addr = "192.168.1.178"
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
    file = "/consul/config/dashbaord.service.hcl"
    content = <<-EOT
      service {
          name = "desktop"
          id = "desktop"
          connect {
              sidecar_service {
                  proxy {
                      mode = "transparent"
                  }
              }
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