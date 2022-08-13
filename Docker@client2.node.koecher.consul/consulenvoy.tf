resource "local_file" "foo" {
  filename = "consulenvoy/Dockerfile"
  content     = <<-EOT
    FROM consul:latest
    FROM envoyproxy/envoy:v1.20.2
    COPY --from=0 /bin/consul /bin/consul
    ENTRYPOINT ["consul"]
  EOT
}

resource "docker_image" "consulenvoy" {
  name = "consulenvoy"
  build {
    path  = "consulenvoy"
  }
}