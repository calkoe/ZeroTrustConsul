# VENUS SERVER1 CONTAINER
resource "docker_volume" "consul-data" {
  name = "consul-data2"
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
      datacenter = "koecher"
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
      client_addr = "0.0.0.0"
      bind_addr = "192.168.1.176"
      #advertise_addr = "192.168.1.176"
      #advertise_addr_wan = "[REMOVED]"

      # SERVER
      server = true
      bootstrap_expect = 1
      #retry_join_wan = ["venus.[REMOVED]"]
      # primary_datacenter = "koecher"
      #primary_gateways = ["venus.[REMOVED]:22002"]
      enable_script_checks = true
      ui_config {
        enabled = true
      }
      connect {
        enabled = true
        enable_mesh_gateway_wan_federation = true
      }
      ports {
        dns   = 53
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
      /*telemetry {
        prometheus_retention_time = "24h"
        disable_hostname = true
      }*/
      #telemetry {
      #  dogstatsd_addr = "localhost:8125"
      #  disable_hostname = true
      #}
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
    file = "ca.pem"
    source = "consul-agent-ca.pem"
    source_hash = filemd5("consul-agent-ca.pem")
  }
  upload {
    file = "cert.pem"
    source = "koecher-server-consul-0.pem"
    source_hash = filemd5("koecher-server-consul-0.pem")
  }
  upload {
    file = "key.pem"
    source = "koecher-server-consul-0-key.pem"
    source_hash = filemd5("koecher-server-consul-0-key.pem")
  }
  volumes {
    container_path = "/consul/data"
    volume_name = "consul-data2"
  }
}