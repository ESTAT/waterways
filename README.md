# OSRM Lua profile for waterways

This repository contains a profile for routing waterways with [OSRM](http://project-osrm.org/). This enables you to find the shortest path by waterways between 2 points and also do map matching with OSRM.
This profile is designed to filter and download waterways according to the Classification of European Inland Waterways (CEMT), a set of standards for interoperability of large navigable waterways forming part of the Trans-European Inland Waterway network. 

*Note:* travel time estimations are based on the maximum speed limit of the waterway. If not available, the default speed is set at 20 km/h.

Right now, it contains, 1 profile :

## `waterway.lua`
A basic profile for routing inland waterways.

![image](https://github.com/ESTAT/waterways/assets/84136306/6f93c7b2-ba8a-46ce-9c86-3286f1fe84b7)


Inspiration for the code taken from [Railnova OSRM train profile](https://github.com/railnova/osrm-train-profile) and the [OSRM car profile](https://github.com/Project-OSRM/osrm-backend/blob/master/profiles/car.lua)

# Files description

- **countries.wanted** : plain text document containing the countries from which data will be extracted. Each country must be in a different row.
- **filter.params** : plain text file where filters are defined to extract and retrieve objects that match at least one of the specified expressions. Use `n` (for nodes); `w` (for ways); `r` (for relations); `a` (for areas); followed by a `/`, and the osm keys. See detailed description of the filters at [osmium-tags-filter](https://docs.osmcode.org/osmium/latest/osmium-tags-filter.html).
- **world** : folder where temporarily store raw source file of a country downloaded. After the script is finished, files are deleted, and the folder is empty. Dowload source : [Geofabrik](https://download.geofabrik.de/). 
- **filtered** : folder where the filtered raw country files (in `world/*`) are stored (e.g.: belgium-latest.osm.pbf).
- **output** : folder where the combined `*-latest.osm.pbf` files for all countries are stored.
- **waterway.lua** : A basic lua profile.
- **Makefile** : file that defines set of tasks to be executed. Call the `waterway.lua` file.


# How to run this?

On linux machine:
- Install the Docker daemon and osmium (`osmium-tool` on Ubuntu) on your machine.
- Run `make all` in the console to download the OSM data, filter and combine it and finally compute the routing graph.
- Run `make serve` in the console to serve the OSRM server locally on port `5000`.
- With the server running, try making requests on your browser to verify that it is working correctly. See detailed description of the request at [OSRM HTTP requests](https://project-osrm.org/docs/v5.10.0/api/#general-options).
- To display the route in a map viewer, download [Leaflet Routing Machine](https://www.liedman.net/leaflet-routing-machine/) and replace the service URL (`serviceUrl: 'http://my-osrm/route/v1'`) with your local server (`'http://localhost:5000/route/v1'`) in the `examples/index.js` file.

# License

This code is under the Creative Commons Zero v1.0 Universal License.
