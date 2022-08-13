# VENUS SERVER1 CONTAINER
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
      node_name   = "client1"
      datacenter  = "koecher"
      data_dir    = "/consul/data"
      retry_join  = ["server"]
      encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
      bind_addr = "192.168.1.177"
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
          default  = "c7710b4b-2442-282d-0837-4d9a7f25b00a"
        }
      }
    EOT
  }
  upload {
    file = "/consul/config/counting.service.hcl"
    content = <<-EOT
      service {
        name = "counting"
        id = "counting"
        port = 9003
        connect {
            sidecar_service {
                proxy {}
            }
        }
        check {
            id       = "counting-check"
            http     = "http://127.0.0.1:9003/health"
            method   = "GET"
            interval = "1s"
            timeout  = "1s"
        }
      }
    EOT
  }
  upload {
    file = "/consul/config/database.service.hcl"
    content = <<-EOT
      service {
        name = "database1"
        id = "database1"
        port = 3306
        connect {
            sidecar_service {
                proxy {}
            }
        }
        check {
            id       = "database-check"
            name     = "database-check on port 3306"
            tcp      = "localhost:3306"
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