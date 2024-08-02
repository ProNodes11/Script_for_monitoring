#!/bin/bash

echo "Введите название джоба:"
read name

nohup docker logs infernet-node -f --tail 100 > logs.log &

sudo tee /root/config.yaml <<"EOF"

server:  http_listen_port: 9080
  grpc_listen_port: 9095

positions:
  filename: /var/log/promtail/positions.yaml

clients:
  - url: http://ec2-34-228-58-231.compute-1.amazonaws.com:3100/loki/api/v1/push

scrape_configs:
  - job_name: ${name}
    static_configs:
      - targets:
          - localhost
        labels:
          job: ${name}
          __path__: /etc/logs.log

EOF

docker run -d --name promtail   -v /root/config.yaml:/etc/promtail/config.yaml   -v /var/log:/var/log:ro   -v /var/log/promtail:/var/log/promtail -v /root:/etc  -p 3100:3100   grafana/promtail:latest   -config.file=/etc/promtail/config.yaml
