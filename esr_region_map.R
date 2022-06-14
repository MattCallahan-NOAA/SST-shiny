library(AKmarineareas)
library(tidyverse)
library(sf)
library(odbc)
library(getPass)

#import spatial lookup table from akfin

#establish akfin connection
#con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())

#download spatial lookup table and save as RDS
#dbFetch(dbSendQuery(con, paste0("select * from afsc.erddap_crw_sst_spatial_lookup")))%>%
#  saveRDS("Data/crw_sst_spatial_lookup_06132022.RDS")

#Load Lookup table
lkp<-readRDS("Data/crw_sst_spatial_lookup_06132022.RDS")%>%
  mutate(lon2=LONGITUDE, lat2=LATITUDE)%>%
  st_as_sf(coords = c('lon2', 'lat2'), crs = 4326, agr = 'constant')%>%
  st_transform(crs=3338)
#filter BS and GOA between 10 and 200 m
BS<-lkp%>%filter(ECOSYSTEM %in% c("Gulf of Alaska", "Eastern Bering Sea") & DEPTH< -10 & DEPTH> -200)
AI<-lkp%>%filter(ECOSYSTEM == "Aleutian Islands")

#download ESR regions (projected)
ESR<-AK_marine_area(area="Ecosystem Subarea", prj="prj")%>%
  remove_dateline()

#download basemap
AK<-AK_basemap()%>%
  st_transform(crs=3338)

#plot
png(filename="Figures/esr_map_depth_filters.png", width=1500, height=750)
ggplot()+
  geom_sf(data=AI, color="light gray", size=0.5)+
  geom_sf(data=BS, color="light gray", size=0.5)+
  geom_sf(data=AK, fill="dark gray")+
  geom_sf(data=ESR, fill=NA)+
  coord_sf(crs=3338)+
  theme_void()
dev.off()
