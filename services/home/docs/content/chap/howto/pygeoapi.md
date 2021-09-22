---
title: HOWTO pygeoapi
---


# HOWTO pygeoapi

`pygeoapi` is already running at https://jrc.map5.nl/pygeoapi. You can choose to
add a new Data Collection (OAFeat terminology for a "layer") 
or even add a new `pygeoapi` service endpoint.

## Adding a new Layer

In a minimal approach you can update 
the [current config file](https://github.com/justb4/ogc-api-jrc/blob/main/services/pygeoapi/local.config.yml) 
and add a new layer (Data Collection). 

See also the [official pygeoapi config docs](https://docs.pygeoapi.io/en/stable/configuration.html).

The config file starts with some general server configuration and then presents 
a list of collections under `resources:`. 
Each collection has a data store configuration referencing one 
of the available data-backends. 
A common data provider is the OGR/GDAL provider which gives access to a multitude of vector file formats.

Basically this takes two actions for a spatial file like a GeoPackage:

* add the GPKG file under [data/](https://github.com/justb4/ogc-api-jrc/tree/main/services/pygeoapi/data)
* update the [config file](https://github.com/justb4/ogc-api-jrc/blob/main/services/pygeoapi/local.config.yml) 


### Examples pygeoapi data collections

```YAML
lakes:                                                      # name of the collection, e.g. /collection/lakes/items
        type: collection 
        title:                                              # title, keywords and description support multilingual
            en: Large Lakes
            nl: Grote meren                               
        description: lakes of the world, public domain
        keywords:
            - lakes
        crs:                                                # CRS-es supported by backend
            - CRS84
        links:                                              # list of links to more info, for example metadata
            - type: text/html
              rel: canonical
              title: information
              href: http://www.naturalearthdata.com/
              hreflang: en-US
        extents:                                            # spatial and temporal extent of the layer
            spatial:
                bbox: [-180,-90,180,90]
                crs: http://www.opengis.net/def/crs/OGC/1.3/CRS84
            temporal:
                begin: 2011-11-11
                end: null  # or empty
        providers:                                          # list of backends
            - type: feature                                 # service type (e.g. features, maps, styles, records, coverages)
              name: GeoJSON                                 # type of provider (see docs for available types)
              data: tests/data/ne_110m_lakes.geojson        # link to a file (or other provider specific configuration)
              id_field: id                                  # field which contains the identifier
              title_field: name                             # field which contains the title of the element (can be multilingual)
```
 
And for the "Helsinki Address Set", note that we refer to the data dir as:

`source: data/integratedAddr_Helsinki.gpkg` 

since the `tests/data` dir is standard within the pygeoapi Docker Container.  Note also that you may even 
provide the GPKG in a projection different from standard WGS84, the `pygeoapi` GDAL/OGR Driver will
on-the-fly reproject (at some performance cost).

```YAML
    ogr_gpkg_addr:
        type: collection
        title: Addresses in Helsinki from merging OSM and INSPIRE data through OGR GPKG
        description: Outcomes of the JRC Pool of experts in data-driven innovation. Uses GeoPackage backend via OGR provider.
        keywords:
            - INSPIRE
            - OSM
            - Addresses
            - Open Street Map
            - NLS
        links:
            - type: text/html
              rel: canonical
              title: information
              href: https://www.int-arch-photogramm-remote-sens-spatial-inf-sci.net/XLVI-4-W2-2021/159/2021/
              hreflang: en-US
        extents:
            spatial:
                bbox: [24.81, 60.04, 25.26, 60.31]
                crs: http://www.opengis.net/def/crs/OGC/1.3/CRS84
            temporal:
                begin:
                end: null  # or empty
        providers:
            - type: feature
              name: OGR
              data:
                  source_type: GPKG
                  source: data/integratedAddr_Helsinki.gpkg
                  source_srs: EPSG:3035
                  target_srs: EPSG:4326
                  source_capabilities:
                      paging: True

                  gdal_ogr_options:
                      EMPTY_AS_NULL: NO
                      GDAL_CACHEMAX: 64
                      # GDAL_HTTP_PROXY: (optional proxy)
                      # GDAL_PROXY_AUTH: (optional auth for remote WFS)
                      CPL_DEBUG: NO

              id_field: fid
              layer: integratedAddr_Helsinki

```
## Adding a new Service Endpoint

Alternatively you can create a new instance by 
duplicating the [main pygeoapi service folder](https://github.com/justb4/ogc-api-jrc/blob/main/services/pygeoapi) 
under a new name and update [the main ansible orchestration](https://github.com/justb4/ogc-api-jrc/blob/main/ansible/deploy.yml) 
to add the new service. Also you have to create a new file in 
[.github/workflows](https://github.com/justb4/ogc-api-jrc/tree/main/.github/workflows), 
having the new name. This tells github to (re)deploy the service when changes are detected. 
Note that INSPIRE mandates that each dataset is exposed via a unique service endpoint and 
pygeoapi can only provide a single service endpoint. Duplicating the deployment is then a usual approach.

TO BE ELBORATED FURTHER.

