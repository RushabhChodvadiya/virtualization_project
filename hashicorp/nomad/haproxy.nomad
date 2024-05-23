job "haproxy" {
  datacenters = ["dc1"]
  constraint {
        operator = "distinct_hosts"
        value    = "true"
  }

  group "haproxy" {
    network {
      port "http" {
        to = 8080
        static = 8080
      }
    }
    count = 3
    update {
      max_parallel     = 1
      canary           = 3
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      auto_revert      = true
      auto_promote     = true
    }
    service {
      name = "haproxy"
      port = "http"
      tags = ["web"]
      check {
        name = "alive"
        type = "tcp"
        #path     = "/api"
        interval = "10s"
        timeout  = "30s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }
    task "haproxy" {
        driver = "docker"

            config {
                image        = "haproxy:latest"
                ports        = ["http"]
                network_mode       = "host"
                volumes = [
                    "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
                ]
            }

            template {
                data        = <<EOF
                global
                    # Enable HAProxy runtime API
                    stats socket :9999 level admin expose-fd listeners
                    log stdout format raw daemon debug

                defaults
                    mode http
                    timeout connect 5s
                    timeout client 1m
                    timeout server 1m 
                    log global

                frontend stats
                    bind *:1936
                    stats uri /
                    stats show-legends
                    no log

                frontend http_front
                    bind *:8080
                    
                    http-request set-header Origin %[req.hdr(Host)]
                    # API server with /api path
                    acl path_api path_beg -i /api
                    use_backend api_servers if path_api

                    # Default to frontend server as a fallback
                    default_backend frontend_servers

                backend api_servers
                    balance roundrobin
                    server-template api 10 _backend._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

                backend frontend_servers
                    balance roundrobin
                    server-template frontend 10 _frontend._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

                resolvers consul
                    nameserver consul 127.0.0.1:8600
                    accepted_payload_size 8192
                    hold valid 5s
                EOF
                destination = "local/haproxy.cfg"
            }
            resources {
                cpu    = 200
                memory = 200
            }
        }
  }
}