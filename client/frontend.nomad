job "frontend" {
  datacenters = ["dc1"]
  type = "service"
  meta {
    git_sha = "[[.GIT_SHA]]"
  }
  group "frontend" {
    network {
      port "http" {
        to = 3000
      }
    }
    count = 5
    update {
      max_parallel     = 3
      canary           = 5
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      auto_revert      = true
      auto_promote     = true
    }
    service {
      name = "frontend"
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
    task "frontend" {
      driver = "docker"

      config {
        image          = "patelrushabh/vir_client:latest"
        ports          = ["http"]
        force_pull     = true
      }
      resources {
        cpu    = 512
        memory = 512
      }
    }
  }
}