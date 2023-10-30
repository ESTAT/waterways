.PRECIOUS: %.pbf

# File name that includes current date in format YYYY-MM-DD
FILE_NAME := routableriver-$(shell date +"%Y-%m-%d")

# List all the source countries we need. Continents may also be included (e.g.: europe)
WANTED_COUNTRIES := $(shell grep -v "\#" countries.wanted)

# Transform countries names from the list "countries.wanted" to "XXXXX-latest.osm.pbf"
COUNTRIES_PBF := $(addsuffix -latest.osm.pbf,$(addprefix world/,$(WANTED_COUNTRIES)))

# Download the raw source file from OSM Geofabrik
world/%.osm.pbf:
	wget -N -nv -P world/ https://download.geofabrik.de/$*.osm.pbf

# Filter a raw country (in world/*) to routableriver-only data (in filtered/*)
filtered/%.osm.pbf: world/%.osm.pbf filter.params
	osmium tags-filter --expressions=filter.params $< -o $@ --overwrite

# Combine all routableriver-only data (in filtered/*) into one file
output/$(FILE_NAME).osm.pbf: $(subst world,filtered,$(COUNTRIES_PBF))
	osmium merge $^ -o $@ --overwrite

# Compute the real OSRM data on the combined file
output/$(FILE_NAME).osrm: output/$(FILE_NAME).osm.pbf waterway.lua
	docker run -t -v $(shell pwd):/opt/host osrm/osrm-backend:v5.22.0 osrm-extract -p /opt/host/waterway.lua /opt/host/$<

	docker run -t -v $(shell pwd):/opt/host osrm/osrm-backend:v5.22.0 osrm-partition /opt/host/$<
	docker run -t -v $(shell pwd):/opt/host osrm/osrm-backend:v5.22.0 osrm-customize /opt/host/$<

# Execute make all in the console
all: output/$(FILE_NAME).osrm

# Execute make serve in the console
serve: output/$(FILE_NAME).osrm waterway.lua
	docker run -t -i -p 5000:5000 -v $(shell pwd):/opt/host osrm/osrm-backend:v5.22.0 osrm-routed --algorithm mld /opt/host/$<
