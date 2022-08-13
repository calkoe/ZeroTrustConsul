# Configure the Consul provider 
# docker exec -it consul9 consul acl bootstrap
provider "consul" {
  #address    = "venus.[REMOVED]:8500"
  #datacenter = "venus"
  address    = "192.168.1.176:8500"
  datacenter = "koecher"
  #scheme = "https"
  #insecure_https = true
  #token      = "3c961a65-3adb-050f-df9f-c88b703cf5cd"
}


resource "consul_config_entry" "counting" {
  kind = "service-resolver"
  name = "counting"

/*

  config_json = jsonencode({
    Redirect = {
      Service    = "counting"
      Datacenter = "venus"
    }
  })
*/

  config_json = jsonencode({
    ConnectTimeout = "0s"
    Failover = {
      "*" = {
        Datacenters = ["venus","merkur"]
      }
    }
  })

}

resource "consul_config_entry" "ingress-gateway" {
  kind = "ingress-gateway"
  name = "ingress-gateway"

  config_json = jsonencode({
    Listeners = [
      {
        Port = 80
        Protocol = "tcp"
        Services = [
          {
            Name = "wordpress"
          }
        ]
      },
      {
        Port = 81
        Protocol = "tcp"
        Services = [
          {
            Name = "nextcloud"
          }
        ]
      },
      {
        Port = 82
        Protocol = "tcp"
        Services = [
          {
            Name = "dashboard"
          }
        ]
      },
      {
        Port = 83
        Protocol = "tcp"
        Services = [
          {
            Name = "counting"
          }
        ]
      },
      {
        Port = 445
        Protocol = "tcp"
        Services = [
          {
            Name = "samba"
          }
        ]
      }
    ]
  })

}

resource "consul_config_entry" "proxy-defaults" {
  kind = "proxy-defaults"
  name = "global"

  config_json = jsonencode({
    MeshGateway = {
      Mode = "remote"
    }
  })

}

/*
resource "consul_acl_policy" "client1" {
  name        = "client1"
  datacenters = ["koecher"]
  rules       = <<-RULE

    # Register Node
    node "client1" {
      policy = "write"
    }

    # Service
    service "counting" {
      policy = "write"
    }
    service "counting-sidecar-proxy" {
      policy = "write"
    }

    # Allow for any potential upstreams to be resolved.
    service_prefix "" {
        policy = "read"
    }
    node_prefix "" {
        policy = "read"
    }

  RULE
}

resource "consul_acl_token" "client1" {
  description = "client1"
  policies = ["client1"]
  local = true
}




resource "consul_acl_policy" "client2" {
  name        = "client2"
  datacenters = ["koecher"]
  rules       = <<-RULE

    # Register Node
    node "client2" {
      policy = "write"
    }

    # Service
    service "dashboard" {
      policy = "write"
    }
    service "dashboard-sidecar-proxy" {
      policy = "write"
    }

    # Allow for any potential upstreams to be resolved.
    service_prefix "" {
        policy = "read"
    }
    node_prefix "" {
        policy = "read"
    }

  RULE
}

resource "consul_acl_token" "client2" {
  description = "client2"
  policies = ["client2"]
  local = true
}
*/