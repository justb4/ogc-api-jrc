[![Traefik Deploy](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.traefik.yml/badge.svg)](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.traefik.yml)
[![pygeoapi Deploy](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.pygeoapi.yml/badge.svg)](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.pygeoapi.yml)
[![postgis Deploy](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.postgis.yml/badge.svg)](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.postgis.yml)
[![admin Deploy](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.admin.yml/badge.svg)](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.admin.yml)
[![home Deploy](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.home.yml/badge.svg)](https://github.com/justb4/ogc-api-jrc/actions/workflows/deploy.home.yml)
[![Gitter](https://img.shields.io/gitter/room/Geonovum/ogc-api-testbed.svg?style=flat-square)](https://gitter.im/Geonovum/ogc-api-testbed)

# Data Services for EC JRC
This repository contains the sources to realize data services based on OGC Web services for
the European Commission Joint Research Centre (Ispra).

Bootstrap and continuous integration/deployment (CI/CD) for OGC API web-service components.

Want to access the (OGC) web-services? Go to:

* Stable (production) server at [jrc.map5.nl](https://jrc.map5.nl/), includes documentation.

## Credits
This repo is generated from the [Template GitHub repo from Geonovum](https://github.com/Geonovum/ogc-api-testbed) 
that was developed for their OGC API Testbed.

See the [website apitestdocs.geonovum.nl](https://apitestdocs.geonovum.nl) for documentation and details.

## Summary

This repo contains all that is needed to bootstrap, configure and maintain (CI/CD) a remote
deployment of an OGC API web-service stack using modern "DevOps" tooling. 

The main design principles are:

* any action on the server/VM host is performed remotely from a client host
* i.e. no direct access/login to/on the server/VM is required, only maybe for problem solving
* remote actions can be performed manually or triggered by GitHub Workflows
* all credentials (passwords, SSH-keys, etc) are secured 
* operational stack instances for "production" (stable) and "sandbox" ("playground", not implemented here)

This approach is known as [GitOps](https://www.gitops.tech/), a term first coined by [Weaveworks](https://www.weave.works/technologies/gitops/). 
GitOps is *"a set of practices to manage infrastructure and application configurations using Git"*. 
"The truth is stored in Git". 
GitOps is often tied to Kubernetes, but *"...using Kubernetes is not a requirement of GitOps. GitOps is a technique that can be applied to other infrastructure and deployment pipelines."*
Refs: [Redhat](https://www.redhat.com/en/topics/devops/what-is-gitops).

The (GitOps-) components used in the setup here are:

* [Docker](https://www.docker.com/) *"...OS-level virtualization to deliver software in packages called containers..."* ([Wikipedia](https://en.wikipedia.org/wiki/Docker_(software)))
* [Docker Compose](https://docs.docker.com/compose) *"...a tool for defining and running multi-container Docker applications..."*
* [Ansible](https://www.ansible.com/) *"...an open-source software provisioning tool"* ([Wikipedia](https://en.wikipedia.org/wiki/Ansible_(software)))
* [GitHub Actions/Workflows](https://docs.github.com/en/actions) *"...Automate, customize, and execute software development workflows in a GitHub repository..."*


The Docker-components are used to run the operational stack, i.e. the OGC API web-services. 
Ansible is used to provision both the server OS-software
and the operational stack. 
Ansible is executed on a local client/desktop system to invoke operations on a remote server/VM.
These operations are bundled in so called Ansible Playbooks, YAML files that describe a desired server state.
GitHub Actions are used to construct Workflows. 
These Actions invoke these Ansible Playbooks, effectively configuring
and provisioning the operational stack on a remote server/VM. 
GitHub Actions are triggered (selectively) on commit/push to this repo.
                    
Security is enforced by the use of [Ansible-Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) 
and [GitHub Encrypted Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets).

The operational stack has the following components:

* [Traefik](https://traefik.io/) a frontend proxy/load-balancer and SSL (HTTPS) endpoint.
* [pygeoapi](https://pygeoapi.io/) a Python server implementation of the OGC API suite of standards.
* [PostgreSQL/PostGIS](https://postgis.net) - geospatial database

For administration, documentation and monitoring the following components are used:

* [mkdocs](https://www.mkdocs.org/) for live documentation and landing pages
* [PGAdmin](https://www.pgadmin.org/) - visual PostgreSQL manager  
* [GeoHealthCheck](https://geohealthcheck.org) to monitor the availability, compliance and QoS of OGC web services
* [Portainer](https://www.portainer.io/) visual Docker monitor and manager

Read more on the setup in the [documentation/website of the Geonovum project](https://apitestdocs.geonovum.nl/setup)
and for this repo at this repo's server instance at [jrc.map5.nl](https://jrc.map5.nl/).
