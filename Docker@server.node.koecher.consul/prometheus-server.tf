resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}
/*
resource "docker_container" "prometheus-server" {
  image = docker_image.prometheus.latest
  name  = "prometheus-server"
  restart = "unless-stopped"
  network_mode = "host"
  upload {
    file = "/etc/prometheus/prometheus.yml"
    content = <<-EOT

    global:
      scrape_interval: 10s

    scrape_configs:
      - job_name: 'prometheus'
        scrape_interval: 5s
        static_configs:
          - targets: ['localhost:9090']
      - job_name: 'envoy'
        consul_sd_configs:
          - server: '127.0.0.1:8500'
            scheme: https
            tls_config:
              insecure_skip_verify: true
            datacenter: koecher
        relabel_configs:
          - source_labels: [__meta_consul_address]
            regex: '(.*)'
            replacement: "$1:9102"
            target_label: '__address__'
            action: 'replace'
        
    EOT
  }
}*/