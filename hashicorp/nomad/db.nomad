job "mysql-server" {
  datacenters = ["dc1"]
  type        = "service"
    group "database" {
    count = 1
    network {
        port "mysql" {
            to = 3306
        }
    }
    update {
        max_parallel     = 1
        canary           = 1
        min_healthy_time = "30s"
        healthy_deadline = "5m"
        auto_revert      = true
        auto_promote     = true
    }
    service {
        name = "mysql"
        port = "mysql"
        tags = ["db"]
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
    constraint {
        attribute = "${node.unique.name}"
        value     = "nomad-client-0"
    }
    task "mysql" {

            driver = "docker"
            config {
                image = "mysql:latest"
                ports = ["mysql"]

                volumes = [
                    "local/create_table.sql:/docker-entrypoint-initdb.d/create_table.sql",
                ]
            }

            template { 
                data= <<EOF
                CREATE TABLE IF NOT EXISTS tasks (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    task VARCHAR(255) NOT NULL,
                    completed BOOLEAN NOT NULL DEFAULT 0
                );
                EOF

                destination = "local/create_table.sql"
                change_mode = "noop"
            }

            env {
                MYSQL_ROOT_PASSWORD = "root"
                MYSQL_DATABASE      = "todo"
            }
            resources {
                cpu    = 500
                memory = 600
            }
            volume_mount {
                volume      = "mysql"
                destination = "/var/lib/mysql"
                read_only   = false
            }
        }
   

    volume "mysql" {
        type      = "host"
        source    = "mysql"
        read_only = false
    }
 }
}