user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    upstream api { # api는 arbitrary.
        server api:8080; # docker-compose.yml에서 올라가는 컨테이너명으로 작성.
        keepalive 1024;
    }
    server {
        listen 80; # nginx를 통해 외부로 노출되는 port.

        location / {
            proxy_pass         http://api/; # arbitrary한 upstream명
        }
    }
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;
    include /etc/nginx/conf.d/*.conf;
}