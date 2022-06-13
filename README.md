# SST-shiny

**Overview** 
We present daily sea surface temperatures and marine heatwave status for each of the ecosystem regions managed by the Alaska Fisheries Science Center https://shinyfin.psmfc.org/ak-sst-mhw/ . 

Temperatures are updated automatically using satellite data curated by NOAA's Coral Reef Watch Program (https://coralreefwatch.noaa.gov/). 

Marine heatwave calculations are performed on the daily SST data using the heatwaveR package (https://robwschlegel.github.io/heatwaveR/).

This shiny app is hosted on the Pacific States Marine Fisheries Commission shiny server https://shinyfin.psmfc.org.

The Basedata_rds_update_script.R pulls SST aggregated by Alaska ecosystem subregion from the AKFIN database using a web service. This script runs nightly on the shiny server to provide the latest data to the app each day, but does not update this repo. *Run this script to get the latest sst data.* For more details on AKFIN web services see https://repository.library.noaa.gov/view/noaa/33498.

The app.R file includes all plotting and heatwave calculation code.

For more information see the description below, this article (https://www.fisheries.noaa.gov/feature-story/current-sea-surface-temperatures-eastern-bering-sea), or contact emily.lemagie@noaa.gov or matt.callahan@noaa.gov.


**Methods**
We use the coral reef watch SST product (Liu et al., 2015), which has a 0.05 degree latitude-longitude grid, beginning in January 1985. 
SST data are downloaded daily from the NESDIS FTP site https://www.star.nesdis.noaa.gov/pub/sod/mecb/crw/data/coraltemp/v3.1/ to the Alaska Fisheries Information Network (AKFIN) database, clipped to the US EEZ, and joined to ecosystem subregions by a lookup table containing spatial strata for each SST grid cell (Watson and Callahan 2021).
AKFIN calculates and stores daily averages of SST for each ecosystem subregion in a table, and distributes these data through a customized web service (Watson & Callahan, 2021).
A depth filter (10-200m) is applied to Bering Sea and Gulf of Alaska cells prior to aggregation to limit results to more fisheries relevant continental shelf areas, but no filter is applied in the Aleutian Islands due to the narrow continental shelf (Figure 1). 
To improve processing speed and avoid downloading the entire dataset each time the app is loaded, a scheduled job downloads the time average SST time series from the AKFIN web service to a .RDS file stored on the shiny server.
When users load the Shiny app, it pulls the SST time series from this file.
These data typically have a 1-2 day latency, allowing users to visualize SST and marine heatwave status in near real-time.

Years are defined as December-November to keep winter (December-February) within a single year, as per the convention within the ecosystem status reports. 
Current year marine heatwave events are calculated for each region according to the methods of Hobday et al. (2016), as implemented within the heatwaveR package (Schlegel & Smit 2018). 
Briefly, a daily mean SST is compared to a baseline for that day of year (climatological mean, or normal), calculated from the first 30 years of the time series (1985-2014 here). 
A heatwave occurs when SST exceeds a threshold (the 90th percentile of the 30-year baseline) for five consecutive days.
Heatwave intensities are then categorized as moderate (SST between the threshold and two times the difference between the threshold and the climatological mean), strong (SST two to three times the difference between the threshold and the climatological mean), severe (SST three to four times the difference between the threshold and the climatological mean), and extreme (SST > four times the difference between the threshold and the climatological mean; Hobday et al. 2018). 
Plots are generated with the ggplot package in R (Wickham 2016, R Core Team 2020).

In 2022 The boundaries of the ecosystem status report regions used in this app were updated. 
NMFS 541 was transferred  from the eastern to central Aleutians and the EAI/WGOA boundary was shifted one degree East.

**Visualization**
The visualization consists a map and description, and a separate tab for each ecosystem (Gulf of Alaska, Bering Sea, and Aleuatian Islands).
Tabs contain an upper SST plot and lower heatwave plot for each ecosystem subregion (Figure 2). 
The current year's daily temperatures (black lines) are compared to the previous year (light blue line), the daily average (1985-2014, dark blue line), and each of the individual years since 1985 (grey lines). The app also comes with a download image button, and a download data option, which downloads the entire average SST time series as a .csv.

**Discussion**
This Shiny app is utilized by a range of analysts, managers, and science communicators. 
Authors of ecosystem status reports frequently can check SST and marine heatwave status with ease, facilitating early detection of marine heatwaves, such as the strong Aleutian Islands heatwave in September 2021. 
The figures generated by this app are used in presentations and shared on NOAA social media (e.g., NOAA website, Twitter, Facebook), particularly during notable marine heatwave events. 
The temporal structure of this visualization also complements existing products such as the coral reef watch heatwave map https://coralreefwatch.noaa.gov/product/marine_heatwave/. 


Marine heatwave categorization (Hobday et al. 2016, 2018) is useful for identifying periods of warm SST. 
However, periods of warm SST that are slightly below marine heatwave thresholds may still have ecological impacts relative to normal. 
For example, in the Southeastern Bering Sea from December 2020 - February 2021, water temperatures were among the 70th percentile relative to the baseline. 
Thus, while a marine heatwave was not triggered, the cumulative impacts of protracted warm periods could have effects that are more difficult to resolve than during more intense events. 
Conversely, the heatwave categorization may fail to communicate the rarity of a warm event. 
For example, September 2021 temperatures in the Aleutian Islands were the highest in the time series, but the intensity did not exceed the "strong" category (the second of four intensity categories).

Sources of SST data vary in the duration of their time series, as well as in their spatial resolution. 
Such differences among data sets can lead to slight differences in climatological normals (baselines), as well as the aggregated values used for determination of marine heatwave thresholds. 
The Optimum interpolation (OI) SST product (Reynolds et al., 2007) is commonly used for many heatwave studies. 
OI SST has a coarser resolution than the CRW SST data set used here, and with an earlier origin, its earliest 30-year baseline period (1982-2011) and measurements may differ slightly from CRW over the same area. 
Such discrepancies occasionally lead to a heatwave detected from one product but not the other. 
For example, in February 2021, the central Aleutian Islands experienced a marine heatwave according to the OI SST data set but not CRW SST.

The boundaries and depth filters used here are preferred by ecosystem status report authors, but some users might have interest in different spatial extents (e.g. off shelf waters, inside waters, other management regions, or species distribution areas).
The code developed for this app code could be applied to SST in other regions, or other data products that may be desirable to monitor through time such as chlorophyll.
As an example, I developed an SST and marine heatwave shiny app specific to Southeast Alaska troll fleet waters https://shinyfin.psmfc.org/baranof-sst-beta/ .

**Acknowledgements**
Jordan Watson originally developed these figures and provided vital input throughout. Bob Nigh (Nexus data solutions) developed the SST upload process and web service.

**References**

Hobday, A. J., Alexander, L. V., Perkins, S. E., Smale, D. A., Straub, S. C., Oliver, E. C., Benthuysen, J. A., Burrows, M.T., Bonat, M. G., Feng, M., Holbrook, N. J., Moore, P. J., Scannel, H. A., Gupta A. S.,  Wernberg, T. (2016). A hierarchical approach to defining marine heatwaves. Progress in Oceanography, 141, 227-238.

Hobday, A. J., Oliver, E. C., Gupta, A. S., Benthuysen, J. A., Burrows, M. T., Donat, M. G., Holbrook, N.J., Moore, P.J., Thomsen, M. S., Wernberg T., Smale, D. A. (2018). Categorizing and naming marine heatwaves. Oceanography, 31(2), 162-173.

Liu G, Heron SF, Mark Eakin C, Muller-Karger FE, Vega-Rodriguez M, Guild LS, Cour JL de la, Geiger EF, Skirving WJ, Burgess TFR, Strong AE, Harris A, Maturi E, Ignatov A, Sapper J, Li J, Lynds S. 2014. Reef-scale thermal stress monitoring of coral ecosystems: New 5-km global products from NOAA coral reef watch. Remote Sensing.

R Core Team (2020). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL https://www.R-project.org/.
Reynolds, R. W., Smith, T. M., Liu, C., Chelton, D. B., Casey, K. S., & Schlax, M. G. (2007). Daily high-resolution-blended analyses for sea surface temperature. Journal of climate, 20(22), 5473-5496.

Schlegel RW, Smit AJ (2018). "heatwaveR: A central algorithm for the detection of heatwaves and cold-spells." Journal of Open Source Software, *3*(27), 821. doi: 10.21105/joss.00821.

Wickham H. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York, 2016.