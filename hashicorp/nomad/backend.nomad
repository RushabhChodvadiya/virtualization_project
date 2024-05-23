job "backend" {
  datacenters = ["dc1"]
  group "backend" {
    network {
      port "http" {
        to = 5000
      }
    }
    count = 9
    update {
      max_parallel     = 1
      canary           = 3
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      auto_revert      = true
      auto_promote     = true
    }
    service {
      name = "backend"
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

    task "backend" {
      driver = "docker"

      config {
        image          = "patelrushabh/vir_server:latest"
        ports          = ["http"]
        force_pull     = true

        volumes = [
          "local/.env:/usr/src/app/.env",
        ]
      }

      template {
        data = <<EOF
{{ range service "mysql" }}
MYSQL_HOST={{ .Address }}
MYSQL_PORT={{ .Port }}
{{ else }}server 127.0.0.1:65535;
{{ end }}
EOF

        destination   = "local/.env"
        change_mode   = "restart"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}