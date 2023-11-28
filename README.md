# virtualization_project
Repo to Hold files related to Humber 2023 Virtualisation Project


```bash
docker run -d \
  --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=todo \
  -e MYSQL_USER=node-app \
  -e MYSQL_PASSWORD=node-pass \
  -p 3306:3306 \
  mysql:latest
```