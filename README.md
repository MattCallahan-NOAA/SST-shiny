# SST-shiny

We present daily sea surface temperatures and marine heatwave status for each of the ecosystem regions managed by the Alaska Fisheries Science Center here https://shinyfin.psmfc.org/ak-sst-mhw/ . 
Temperatures are updated automatically using satellite data curated by NOAA's Coral Reef Watch Program (https://coralreefwatch.noaa.gov/). 
The current year's daily temperatures (black lines) are compared to the previous year (blue line), the daily average (1985-2014), and each of the individual years since 1985 (grey lines).

Marine heatwave calculations are performed on the daily SST data using the heatwaveR package (https://robwschlegel.github.io/heatwaveR/).

SST is pulled daily from the Alaska Fisheries Information Network (AKFIN) database, which stores aggregated daily SST for each of Alaska's management regions.
This shiny app is stored on the Pacific States Marine Fisheries Commission shiny server https://shinyfin.psmfc.org.

More information can be found here (https://www.fisheries.noaa.gov/feature-story/current-sea-surface-temperatures-eastern-bering-sea) or by contacting emily.lemagie@noaa.gov or matt.callahan@noaa.gov.

We developed an application to track sea surface temperature (SST) and marine heatwaves through time in Alaska ecosystem subregions https://shinyfin.psmfc.org/ak-sst-mhw/. 
Information on key ecosystem indicators is increasingly valuable as the National Marine Fisheries Service adopts more ecosystem-based fisheries management approaches. 
Sea surface temperature is an environmental parameter that influences numerous biological processes including species distribution, metabolic rates, and recruitment. 
We aggregated satellite derived SST by the subregions of large marine ecosystems used in Alaska Fisheries Science Center ecosystem status reports (Gulf of Alaska, Aleutian Islands, and Bering Sea). 
We also calculated marine heatwave status of current year SST in each subregion. 
Our visualization shows temporal progression of SST in current and past years as well as current year marine heatwave events.
