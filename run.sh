#!/usr/bin/env bash

#apt-get upgrade -y

apt-get install nginx python3 python3.4-venv supervisor -y

pyvenv-3.4 /opt/venv
/opt/venv/bin/pip install -r /vagrant/requirements.txt

cat <<NGINX_CONF > /etc/nginx/sites-available/ben
upstream python_app{
    server localhost:5000;
}

server {
	listen 80;
	server_name _;

	location / {
        proxy_pass http://localhost:5000;
	}
}

NGINX_CONF

cat <<SUPERVISOR > /etc/supervisor/conf.d/python_app.conf

[inet_http_server]
port = :9000

[program:python_app]
user = vagrant
environment = PORT=5000
command = /opt/venv/bin/gunicorn -w 5 --reload --chdir /vagrant run:app
SUPERVISOR

[[ -f /etc/nginx/sites-enabled/default ]] && unlink /etc/nginx/sites-enabled/default
[[ ! -f /etc/nginx/sites-enabled/ben ]] && ln -s /etc/nginx/sites-available/ben /etc/nginx/sites-enabled/ben

service nginx restart
service supervisor restart
