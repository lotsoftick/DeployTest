FROM nginx:alpine
COPY _dockerData/nginx/nginx.conf /etc/nginx/conf.d/default.conf
