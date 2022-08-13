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
      node_name   = "client2"
      datacenter  = "koecher"
      data_dir    = "/consul/data"
      retry_join  = ["server"]
      encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
      bind_addr = "192.168.1.105"
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
          name = "dashboard"
          id = "dashboard"
          port = 9002
          connect {
              sidecar_service {
                  proxy {
                    transparent_proxy {
                        dialed_directly = true
                    }
                    upstreams = [
                      {
                        destination_name = "counting",
                        datacenter = "venus",
                        local_bind_port  = 9003
                      }
                    ],
                  }
              }
          }
          check {
              id       = "dashboard-check"
              http     = "http://127.0.0.1:9002/health"
              method   = "GET"
              interval = "1s"
              timeout  = "1s"
          }
      }    
    EOT
  }
  upload {
    file = "/consul/config/wordpress.service.hcl"
    content = <<-EOT
      service {
          name = "wordpress"
          id = "wordpress"
          port = 80
          connect {
              sidecar_service {
                  proxy {
                    transparent_proxy {
                        dialed_directly = true
                    }
                    upstreams = [
                      {
                        destination_name = "database1",
                        local_bind_port  = 3306
                      }
                    ],
                  }
              }
          }
          check {
              id       = "wordpress-check"
              http     = "http://127.0.0.1:80"
              interval = "1s"
              timeout  = "1s"
          }
      }    
    EOT
  }
  upload {
    file = "/consul/config/samba.service.hcl"
    content = <<-EOT
      service {
          name = "samba"
          id = "samba"
          port = 445
          connect {
              sidecar_service {
                  proxy {}
              }
          }
          check {
              id       = "samba-check"
              tcp      = "localhost:445"
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