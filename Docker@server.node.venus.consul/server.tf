# VENUS SERVER1 CONTAINER
resource "docker_volume" "consul-data" {
  name = "consul-data"
}

resource "docker_container" "server" {
  image = docker_image.consul.latest
  name  = "server"
  restart = "unless-stopped"
  network_mode = "host"
  entrypoint = [
    "consul",
    "agent",
    "-config-dir=/consul/config"
  ]
  upload {
    file = "/consul/config/config.hcl"
    content = <<-EOT
      # CLIENT
      node_name = "server"
      datacenter = "venus"
      data_dir = "/consul/data"
      log_level = "WARN"
      enable_central_service_config = true

      # ENCRYPTION
      encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
      #verify_incoming = true
      verify_outgoing = false
      verify_server_hostname = false
      ca_file = "ca.pem"
      cert_file = "cert.pem"
      key_file = "key.pem"
      auto_encrypt {
        allow_tls = true
      }

      # IPs
      #client_addr = "0.0.0.0"
      bind_addr = "[REMOVED]"
      #advertise_addr = "192.168.1.180"
      #advertise_addr_wan = "192.168.1.180"

      # SERVER
      server = true
      bootstrap_expect = 1
      #retry_join_wan = ["venus.[REMOVED]"]
      primary_datacenter = "koecher"
      primary_gateways = ["[REMOVED]:22002"]
      ui_config {
        enabled = true
      }
      connect {
        enabled = true
        enable_mesh_gateway_wan_federation = true
      }
      ports {
        http  = 8500
        https = -1
        grpc  = 8502
      }
      /*
      acl {
        enabled = true
        default_policy = "deny"
        enable_token_persistence = true
      }
      */
      EOT
  }
  // docker exec server consul config write /consul/proxy-defaults.hcl
  upload {
    file = "/consul/proxy-defaults.hcl"
    content = <<-EOT
      Kind = "proxy-defaults"
      Name = "global"
      MeshGateway {
        mode = "remote"
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
                proxy {                   
                    transparent_proxy {
                        dialed_directly = true
                    }
                }
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
    file = "/consul/config/database2.service.hcl"
    content = <<-EOT
      service {
        name = "database2"
        id = "database2"
        port = 3306
        connect {
            sidecar_service {
                proxy {                   
                    transparent_proxy {
                        dialed_directly = true
                    }
                }
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
  upload {
    file = "cert.pem"
    source = "venus-server-consul-0.pem"
    source_hash = filemd5("venus-server-consul-0.pem")
  }
  upload {
    file = "key.pem"
    source = "venus-server-consul-0-key.pem"
    source_hash = filemd5("venus-server-consul-0-key.pem")
  }
  volumes {
    container_path = "/consul/data"
    volume_name = "consul-data"
  }
}