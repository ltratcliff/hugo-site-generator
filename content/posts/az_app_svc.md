---
title: "Azure Application Services"
date: 2022-06-26T10:23:29-04:00
draft: false
author: "Tom Ratcliff"
toc: true
tags: ["Azure", "AKS"]
categories: ["Cloud"]
---

# Deploy An Application on Azure App Services

# Table of Contents
1. [App Creation](#create-awesome-appmodelalgo)
2. [Azure Database Setup](#azure-database-provisioning)
3. [Azure Container Registry](#azure-container-image-registry-setup)
4. [Azure App Services Creation](#azure-app-service-creation)


## Create Awesome App/Model/Algo
In this example we will be using a python (Flask) backend and a nodejs (VueJS) frontend.

There are two options within Azure (as we will see shortly) to deploy App services
 1. Source code deployment
 2. Container deployment

We will be using that latter

For this example we will not be using CI/CD :sad_face: due to our new GitLab not having the external network access
required to build container images and push externally. Will revisit once fixed :thumbs_up:

### Containerizing 
We will not cover all things containers, but want to highlight that we will be using Environment variables for
the configuration of our containers. ie:

Example docker file:
```dockerfile
FROM python:3.10.7

WORKDIR /usr/src/app

ENV FLASK_ENV="docker"
ENV FLASK_APP=app.py
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip install --upgrade pip

COPY ./requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8085

RUN pip install gunicorn

COPY . .

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8085", "app:create_app()"]

```
And example Environment file (.env) that will be used for local dev:
```shell
ENV_DATABASE_HOST=localhost
ENV_DATABASE_NAME=postgres
ENV_DATABASE_USERNAME=root
ENV_DATABASE_PASSWORD=root
ENV_DATABASE_PORT=5432
ENV_DATABASE_SCHEMA=analytic_platform
```

The above values will be overwritten with production values in Azure (shown later)

Create the container image with:
```shell
$ docker build -f Dockerfile .
```

We will re-tag and push this image later, after we set our Container Image Registry up within Azure

## Azure Database Provisioning

We will be using _Azure Database for PostgreSQL flexible servers_ 

In [Azure](https://portal.azure.us) search for "postgres" and select the "flexible servers" option.

![psql](/images/az_app_svc/postgres.png)

Select "Create"

![psql_create](/images/az_app_svc/psql_create.png)

Fill out the form (subscription, name, credentials, etc.)

![psql_form](/images/az_app_svc/db_form.png)

_Notice the costs!?_

![psql_costs](/images/az_app_svc/db_cost.png)

That's too rich for our blood. Let's resize accordingly. Back on the form, select the _Configure Server_ link

![db_config](/images/az_app_svc/db_config.png)

Configure to your liking/requirements

![db_config_ex](/images/az_app_svc/db_config_ex.png)

$34 seems more reasonable.

Select _Next_ at the bottom to move to the Network Setup

While here be sure to select _Allow public access from any Azure service within Azure to this server_ and 
the _Add current client IP address ( YOUR-IP-HERE )_

![db_access](/images/az_app_svc/db_access.png)

The last step is to tag and create

![db_create](/images/az_app_svc/db_create.png)

You newly provisioned db will be listed. You can click the [name](link) for more db settings

![db_listing](/images/az_app_svc/db_listing.png)

We're good on the DB for now :thumbs_up:

## Azure Container Image Registry setup

Search for and select _Container Registries_

![cr](/images/az_app_svc/cr.png)

Select _Create_

Fill out the form and _Create_

![cr_reg](/images/az_app_svc/cr_reg_form.png)

You can select you new registry name link

![new_cr](/images/az_app_svc/new_cr.png)

In your Container Registry View, select _Access Keys_

![cr_ak](/images/az_app_svc/cr_ak.png)

Take note of your **Login Server**, **Username** and **Password** (We will need these in the next step)

![cr_creds](/images/az_app_svc/cr_creds.png)


### Retag image and Push to Registry
Get the container image name/hash then tag with registry name
```shell
#Get image checksum
docker images
#Tag image with new registry and version
docker tag c4895ac4b118 cdaocr.azurecr.us/data-path-discovery-web-app:1.0.0
#Log into registry with Username and Password from above step
docker login cdaocr.azurecr.us
#fill in prompts
#Push image to regisry
docker push cdaocr.azurecr.us/data-path-discovery-web-app:1.0.0
```

Check out your new image in the registry

![new_img](/images/az_app_svc/new_image_cr.png)

## Azure App Service Creation

It's Timeeeeeeeeeeeeeeee!
We're finally ready for the final steps for deployment.

In the Azure Console search for **App Services**

![as](/images/az_app_svc/as.png)

Select the **Create** link

![as_create](/images/az_app_svc/as_create.png)

Fill out the form paying attention to 
1. Name - Will be the webapp URL
2. Publish - Code or Container options
3. OS - Linux vs Windows
4. Pricing - We can change later

![as1](/images/az_app_svc/as_1.png)

Select **Next: Docker**

Fill out the form, selecting the registry and container image we pushed above

![as_img](/images/az_app_svc/as_img.png)

Select **Next: Networking** and leave Defaults

**Review and Create**

We can now access our App Service View

![new_as](/images/az_app_svc/new_as.png)


There are many options worth exploring in here, but we are going to focus on the configuration

We will use this tab to inject our required ENV vars mentioned above

Select **Configuration** on the left

Notice the ENV (Specifically WEBSITES_PORT and ENV_BASE_URL) that we have set

Define any VARS needed here

![as_conf](/images/az_app_svc/as_config.png)

Navigate to __**Overview**__ and click on the __**Restart**__ button for new ENVs to take effect

> :information: Note the Application URL Endpoint

![as_fin](/images/az_app_svc/as_final.png)

That's it! We have successfully deployed our Application in Azure App Services :tada: