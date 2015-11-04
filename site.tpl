server {
        listen 80;
        server_name @DOMAIN;
        rewrite ^(.*) http://www.@DOMAIN$1 permanent;
}

server {
        listen 80;
        server_name www.@DOMAIN;

        client_max_body_size 5m;
        client_body_timeout 60;

        access_log /mnt/hdds/hdd01/public_html/@DOMAIN/logs/access.log;
        error_log /mnt/hdds/hdd01/public_html/@DOMAIN/logs/error.log error;

        root /mnt/hdds/hdd01/public_html/@DOMAIN/www;
        index  index.html index.php;

        ### root directory ###
        location / {
                try_files $uri $uri/ /index.php?$args;
        }

        ### security ###
        error_page 403 =404;
        location ~ /\. { access_log off; log_not_found off; deny all; }
        location ~ ~$ { access_log off; log_not_found off; deny all; }

        ### disable logging ###
        location = /robots.txt { access_log off; log_not_found off; }
        location = /favicon.ico { access_log off; log_not_found off; }

        ### php block ###
        location ~ \.php?$ {
                try_files $uri =404;
                include fastcgi_params;
                fastcgi_pass unix:/var/run/php-fpm-www.socket;
                fastcgi_param SCRIPT_FILENAME /@DOMAIN/www$fastcgi_script_name;
                fastcgi_intercept_errors on;
                fastcgi_split_path_info ^(.+\.php)(.*)$;
                #Prevent version info leakage
                fastcgi_hide_header X-Powered-By;
        }
}