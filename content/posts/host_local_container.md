---
title: "Host a Local Container Externally"
date: 2024-12-07T13:29:00-04:00
draft: false
author: "Tom Ratcliff"
toc: true
summary: Host an NGINX container locally for remote viewing
tags: ["Containers", "Podman", "Docker"]
categories: ["Web", "Containers"]
---


# Table of Contents
1. [Create Container](#create-a-simple-nginx-container)
2. [Serve Container](#serve-our-container)
3. [Open Firewall and Port Forward](#open-firewall)
4. [Forward Port on Router](#forward-ports)
5. [Register CNAME with Registrar](#register-website-cname-with-domain-registrar)
6. [Test Connectivity](#test-external-connectivity)


## Create a Simple Nginx Container
In this example we will create a React app with Vite and containerize it

> Requires Node & NPM
```shell
npm create vite@latest myAwesomeApp
```

![img.png](/images/host_local_container/img.png)

Now we'll create the Dockerfile and container

First create a nginx.conf file with a similar config:
```
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri /index.html;
    }
}
```

```dockerfile
# Stage 1: Build the React app
FROM node:alpine AS build

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json ./
RUN npm install

# Copy all files and build the app
COPY . .
RUN npm run build

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the built React app files from the previous stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy the custom Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
```

Now build container
```shell
docker build -t myawesomecontainer .
```

![img.png](/images/host_local_container/img2.png)

Check out our awesome container image!
```shell
docker images
```
![img.png](/images/host_local_container/img3.png)

Now to make and serve a container

## Serve our container

```shell
docker run --rm -it -p 8080:80 mycoolcontainer
```

![img.png](/images/host_local_container/img4.png)

Check your site out in your browser
![img.png](/images/host_local_container/img5.png)

## Open firewall
This part will vary depending on operating system. On Fedora Linux these ports are already good.
Can verify with:
```shell
sudo firewall-cmd --list-all
```
```
FedoraWorkstation (default, active)
  target: default
  ingress-priority: 0
  egress-priority: 0
  icmp-block-inversion: no
  interfaces: wlp9s0f0
  sources: 
  services: dhcpv6-client mdns samba-client ssh
  ports: 1025-65535/udp 1025-65535/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```
Open ports are shown on the "ports:" line.

If you need to open the ports, you can accomplish (on linux) with:
```shell
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

## Forward Ports

This will differ per router, but the options and configuration should be similar.

Going to show the setup on Eero (just switched from pfsense)

> A reservation is required to add a firewall rule

1. From the eero app select Settings -> Network Settings -> Reservations & Port Forwarding -> Add a reservation
2. Select the device you want to port forward to and save
3. Now select "Open a port"
4. Fill out the form with a name, port, internal port (8080) [see below]
5. Save

![img.png](/images/host_local_container/img6.png)


## Register Website CNAME with Domain Registrar

My domain _was_ managed through google domains until a few months ago when it merged over
to squarespace. I have since offloaded my DNS to Cloudflare (which is a whole seperate writeup)
But for now, will show how to setup a DNS CNAME addition in Cloudflare.

Under your Cloudflare website -> DNS select add record

![img.png](/images/host_local_container/img7.png)

> Make to point your CNAME to your A record (which is defined to your public external IP (can get this on whatismyip.com))

ie: ![img.png](/images/host_local_container/img8.png)

now mycoolapp.yourdomain.com should resolve with nslookup.

```shell
nslookup mycoolapp.ltratcliff.com
```
![img.png](/images/host_local_container/img9.png)

## Test External Connectivity

If all went well, you should be able to hit your app from your browser
![img.png](/images/host_local_container/img10.png)

[//]: # (TODO: Show screenshot of apps.ltratcliff.com)

[//]: # (## Bonus: Setup TLS)

[//]: # (TODO: scripts to create cert.key and cert.crt)
[//]: # (TODO: Show nginx edits for TLS)
[//]: # (TODO: Show Dockerfile setup)
[//]: # (TODO: Talk about port forward additions required, etc.)



:tada::tada::tada:

That's it! We have successfully deployed our Application in Azure App Services :tada:


