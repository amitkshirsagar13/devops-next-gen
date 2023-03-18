### Fluentd

```

helm show chart https://fluent.github.io/helm-charts/fluentd

helm repo list
helm show repo fluent/fluentd

kubectl create namespace logging
helm uninstall --namespace logging fluentd
helm install --namespace logging fluentd fluent/fluentd -f ./fluentd/fluentd-values.yaml
helm upgrade --namespace logging fluentd fluent/fluentd -f ./fluentd/fluentd-values.yaml

sudo sysctl -w fs.inotify.max_user_instances=1024
sudo sysctl -w fs.inotify.max_user_watches=12288

```


### prometheus plugin

```
    <source>
      @type forward
      bind 0.0.0.0
      port 24224
    </source>

    # count number of incoming records per tag
    <filter company.*>
      @type prometheus
      <metric>
        name fluentd_input_status_num_records_total
        type counter
        desc The total number of incoming records
        <labels>
          tag ${tag}
          hostname ${hostname}
        </labels>
      </metric>
    </filter>

    # count number of outgoing records per tag
    <match company.*>
      @type copy
      <store>
        @type forward
        <server>
          name myserver1
          host 192.168.1.3
          port 24224
          weight 60
        </server>
      </store>
      <store>
        @type prometheus
        <metric>
          name fluentd_output_status_num_records_total
          type counter
          desc The total number of outgoing records
          <labels>
            tag ${tag}
            hostname ${hostname}
          </labels>
        </metric>
      </store>
    </match>

    # expose metrics in prometheus format
    <source>
      @type prometheus
      bind 0.0.0.0
      port 24231
      metrics_path /metrics
    </source>
    <source>
      @type prometheus_output_monitor
      interval 10
      <labels>
        hostname ${hostname}
      </labels>
    </source>


```