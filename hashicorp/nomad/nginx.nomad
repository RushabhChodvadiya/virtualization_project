job "nginx" {
  datacenters = ["dc1"]
    constraint {
        operator = "distinct_hosts"
        value    = "true"
  }
  group "nginx" {
    count = 3

    network {
      port "http" {
        static = 8080
        to     = 8080
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream backend {
{{ range service "backend" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

upstream frontend {
{{ range service "frontend" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 8080;

   location /api {
      proxy_pass http://backend;
   }

    location / {
        proxy_pass http://frontend;
    }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
