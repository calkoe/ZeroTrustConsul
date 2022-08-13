FROM consul:latest
FROM envoyproxy/envoy:v1.20.2
COPY --from=0 /bin/consul /bin/consul
ENTRYPOINT ["consul"]
