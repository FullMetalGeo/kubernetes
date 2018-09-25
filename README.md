# Pelias Kubernetes Configuration

This repository contains Kubernetes configuration files to create a production ready instance of Pelias.

This configuration is meant to be run on Kubernetes using real hardware or full sized virtual
machines in the cloud. Technically it could work on a personal computer with
[minikube](https://github.com/kubernetes/minikube) but it would require a machine with lots of RAM:
24GB or more.

**Note:** These are very early stage, and are being rapidly changed and improved. We welcome
feedback from anyone who has used them.

## Setup

Getting a Pelias cluster up and running follows a few steps outlined below, namely:

1. Setting up an Elasticsearch Cluster to store data
2. Setting up a Kubernetes cluster to run Pelias and the importers
3. Launching the Pelias application and associated services.
4. Launching the Pelias importer apps to load data into Elasticsearch

### Elasticsearch

#### Option A: AWS Elasticsearch Service

Use the Leone-Ops Elasticsearch template to create an Elasticsearch cluster.

#### Option B: Create your own Elasticsearch Cluster

Elasticsearch is used as the primary datastore for Pelias data. As a powerful database with built in
scalability and replication abilities, it is not currently well suited for running in Kubernetes.

Instead, it's preferable to create "regular" instances in your cloud provider or on your own
hardware. To help with this, the `elasticsearch/` directory in this repository contains tools for
setting up a production ready, Pelias compatible Elasticsearch cluster. It uses
[Terraform](http://terraform.io/) and [Packer](http://packer.io/) to do this. See the directory
[README](./elasticsearch/README.md) for more details.

### Kubernetes

First, set up a Kubernetes cluster however works best for you. A popular choice is to use
[kops](https://github.com/kubernetes/kops) on AWS. The [Getting Started on AWS Guide](https://github.com/kubernetes/kops/blob/master/docs/aws.md) is a good starting point.

#### Sizing the Kubernetes cluster

A working Pelias cluster contains the following services:
* Pelias API (requires about 256MB of RAM) (**required**)
* Libpostal Service (requirs about 2GB of RAM) (**required**)
* Placeholder Service (Requires 512MB of RAM) (**strongly recommended**)
* Point in Polygon (PIP) Service (Requires 6GB of RAM) (**required for reverse geocoding**)
* Interpolation Service (requires ~2GB of RAM)

Some of the following importers will additionally have to be run to initially populate data
* Who's on First (requires about 1GB of RAM)
* OpenStreetMap (requires between 0.25GB and 6GB of RAM depending on import size)
* OpenAddresses (requires 1GB of RAM)
* Geonames (requires ~0.5GB of RAM)
* Polylines (requires 1GB of RAM)

If using kops, it defaults to `t2.small` instances, which are far too small (they only have 2GB of ram).

You can edit the instance types using `kops edit ig nodes` before starting your cluster. `m4.large` is a good choice to start.

This means around 10GB of RAM is required to bring up all the services, and up to another 15GB of RAM is needed to
run all the importers at once. 2 instances with 8GB of RAM each is a good starting point just for
the services.

### Launch Pelias Service

Use the Helm chart found in `pelias-service/` to launch the Pelias service.  Make sure to update the `values.yml` file with your Elasticsearch connection info.

### Import Pelias Data

The importers require the PIP service to be running, ensure that all pods launched in the previous step are running before attempting to launch the import jobs.

Use the[data sources](https://mapzen.com/documentation/search/data-sources/) documentation to decide
which importers to be run.

Importers can be run in any order, in parallel or one at a time.

Use the chart in `pelias-import/` to launch the import jobs.  These will take awhile (4-5 days) to complete when importing the entire planet.

# debuging 'init containers'

sometimes an 'init container' fails to start, you can view the init logs:

```bash
# kubectl logs {{pod_name}} -c {{init_container_name}}
kubectl logs geonames-import-4vgq3 -c geonames-download
```

# opening a bash prompt in a running container

it can be useful to open a shell inside a running container for debugging:

```bash
# kubectl exec -it {{pod_name}} -- {{command}}
kubectl exec -it pelias-pip-3625698757-dtzmd -- /bin/bash
```
