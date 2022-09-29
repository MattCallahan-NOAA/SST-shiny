library(shiny)
library(tidyverse)
library(shinycssloaders)
library(lubridate)
library(cowplot)
library(httr)
library(heatwaveR)
library(gridExtra)

ui <- fluidPage(


  #Define Regional output in separate tabs
  tabsetPanel(type="tabs",
              tabPanel("Map",
              tags$blockquote("We present daily sea surface temperatures and marine heatwave status for five Southeast Alaskan regions.
              Temperatures are updated automatically
  using satellite data curated by NOAA's Coral Reef Watch Program (https://coralreefwatch.noaa.gov/). Contact matt.callahan@noaa.gov for more information."),
            # tabPanel("2020 Bering Sea", textOutput("text"),
                        imageOutput(outputId = "Map")%>%
                          withSpinner()),
            tabPanel("Northern SE Outside Waters",
                       plotOutput(outputId = "NOplot", height = 1000, width=1200)%>%
                         withSpinner()),
            tabPanel("Baranof Outside Waters",
                     plotOutput(outputId = "Bplot", height = 1000, width=1200)%>%
                       withSpinner()),
            tabPanel("Cross Sound and Icy Strait",
                     plotOutput(outputId = "CSplot", height = 1000, width=1200)%>%
                       withSpinner()),
            tabPanel("Northern Chatham",
                     plotOutput(outputId = "NCplot", height = 1000, width=1200)%>%
                       withSpinner()),
            tabPanel("Southern Chatham",
                     plotOutput(outputId = "SCplot", height = 1000, width=1200)%>%
                       withSpinner())),

)

server <- function(input, output) {
  ####--------------------------------------------------------------####
  #create first tab that will hopefully load before the other tabs
  output$Map<-renderImage({
    filename <- normalizePath(file.path('Figures/map_for_app_no_points.png'))

    # Return a list containing the filename and alt text
    list(src = filename,
         height = 800)

  }, deleteFile = FALSE)

  ####-----------------------------------------------------------------####
  #code relevent to all upper panels in subsequent plots

  #  Load 508 compliant NOAA colors
  OceansBlue1='#0093D0'
  OceansBlue2='#0055A4' # rebecca dark blue
  Crustacean1='#FF8300'
  UrchinPurple1='#7F7FFF'
  SeagrassGreen4='#D0D0D0' # This is just grey
  #  Assign colors to different time series.
  current.year.color <- "black"#CoralRed1 #OceansBlue1
  last.year.color <- OceansBlue1#WavesTeal1
  mean.color <- UrchinPurple1
  #  Set default plot theme
  theme_set(theme_cowplot())

  #  Specify legend position coordinates (top panel)
  mylegx <- 0.1
  mylegy <- 0.75

  #  Specify NOAA logo position coordinates (top panel)
  mylogox <- 0.045
  mylogoy <- 0.4

  ####-------------------------------------------------------------####
  #Load base data
  basedata<-read.csv("bar_avg_sst_011922.csv")%>%
    mutate(READ_DATE=as_date(dmy_hms(READ_DATE)))

  #update with API
  updateddata<-httr::content(
    httr::GET('https://apex.psmfc.org/akfin/data_marts/akmp/baranof_avg_sst?start_date=20220117&end_date=20221231'),
    type = "application/json") %>%
    bind_rows%>%
    mutate(READ_DATE=as_date(ymd_hms(READ_DATE)))

  #combine
  updateddata<-bind_rows(basedata, updateddata)

  data <-
    updateddata %>%
    rename_all(tolower) %>%
    mutate(month=month(read_date),
           day=day(read_date),
           year=year(read_date),
           newdate=as.Date(as.character(as.Date(paste("1999",month,day,sep="-"),format="%Y-%m-%d"))))%>%#  Create a dummy year so that each year can more easily be overlain
    arrange(read_date)
  #  Set year criteria to automatically identify the current and previous years
  current.year <- max(data$year)
  last.year <- current.year-1
  mean.years <- 1985:2015 # We use the oldest 30-year time series as our climatological baseline.
  mean.lab <- "Mean 1985-2015"

  ####---------------------------------------------------####
  #Plots for P1
  myplotfun <- function(region){
    mylines_base <- ggplot() +
      geom_line(data=data %>% filter(year<last.year& area_name==region), # Older years are grey lines.
                aes(newdate,mean_sst,group=factor(year),col='mygrey'),size=0.3) +
      geom_line(data=data %>% filter(year==last.year & area_name==region), # The previous year
                aes(newdate,mean_sst,color='last.year.color'),size=0.75) +
      geom_line(data=data %>%
                  filter(year%in%mean.years & area_name==region) %>% # The mean from 1986-2015
                  group_by(area_name,newdate) %>%
                  summarise(meantemp=mean(mean_sst,na.rm=TRUE)),
                aes(newdate,meantemp,col='mean.color'),size=0.65,linetype="solid") +
      geom_line(data=data %>% filter(year==current.year & area_name==region), # This year
                aes(newdate,mean_sst,color='current.year.color'),size=2) +
      scale_color_manual(name="",
                         breaks=c('current.year.color','last.year.color','mygrey','mean.color'),
                         values=c('current.year.color'=current.year.color,'last.year.color'=last.year.color,'mygrey'=SeagrassGreen4,'mean.color'=mean.color),
                         labels=c(current.year,last.year,paste0('1985-',last.year-1),mean.lab)) +
      scale_linetype_manual(values=c("solid","solid","solid","dashed")) +
      ylab("Sea Surface Temperature (°C)") +
      xlab("") +
      ggtitle(label=region)+
      ylim(c(0,19))+
      scale_x_date(date_breaks="1 month",
                   date_labels = "%b",
                   expand = c(0.025,0.025)) +
      theme(legend.position=c(mylegx,mylegy),
            legend.text = element_text(size=20,family="sans"),
            legend.background = element_blank(),
            legend.title = element_blank(),
            plot.title=element_text(size=24, face="bold", hjust=0.5),
            axis.title.y = element_text(size=20,family="sans"),
            axis.text.y = element_text(size=16,family="sans"),
            panel.border=element_rect(colour="black",size=0.75),
            axis.text.x=element_blank(),
            legend.key.size = unit(0.35,"cm"),
            plot.margin=unit(c(1,0.05,0,0),"cm"))
    ggdraw(mylines_base)
  }



  ####-------------------------------------------------####
  #Code used for all lower panels

  #  Create custom categories for lines
  lineColCat <- c(
    "Temperature" = "black",
    "Baseline" = mean.color,
    "Moderate (1x Threshold)" = "gray60",
    "Strong (2x Threshold)" = "gray60",
    "Severe (3x Threshold)" = "gray60",
    "Extreme (4x Threshold)" = "gray60"
  )

  #  Create flame fill parameters
  fillColCat <- c(
    "Moderate" = "#ffc866",
    "Strong" = "#ff6900",
    "Severe" = "#9e0000",
    "Extreme" = "#2d0000"
  )

  #  Modified flame fill parameters
  Moderate = "#ffc866"
  Strong = "#ff6900"
  Severe = "#9e0000"
  Extreme = "#2d0000"

  #  Format plot (modified from theme_cowplot)
  mytheme <- theme(axis.title = element_text(size=20,family="sans",color="black"),
                   axis.text = element_text(size=16,family="sans",color="black"),
                   panel.border=element_rect(colour="black",fill=NA,size=0.75),
                   panel.background = element_blank(),
                   legend.position=c(0.6,0.7),
                   legend.background = element_blank())


  ####------------------------------------------------####
  #Bering Sea lower panel code
  # Use heatwaveR package to detect marine heatwaves.
 mhw <- (detect_event(ts2clm(updateddata %>%
                                  filter(AREA_NAME=="Baranof Outside Waters") %>%
                                  rename(t=READ_DATE,temp=MEAN_SST) %>%
                                  arrange(t), climatologyPeriod = c("1985-01-01", "2014-12-31"))))$clim %>%
                mutate(region="2022 Baranof Outside Waters Heatwaves") %>%
    bind_rows((detect_event(ts2clm(updateddata %>%
                                     filter(AREA_NAME=="Northern SE Outside Waters") %>%
                                     rename(t=READ_DATE,temp=MEAN_SST) %>%
                                     arrange(t), climatologyPeriod = c("1985-01-01", "2014-12-31"))))$clim %>%
                mutate(region="2022 Northern SE Outside Waters Heatwaves"))%>%
    bind_rows((detect_event(ts2clm(updateddata %>%
                                  filter(AREA_NAME=="Cross Sound and Icy Strait") %>%
                                  rename(t=READ_DATE,temp=MEAN_SST) %>%
                                  arrange(t), climatologyPeriod = c("1985-01-01", "2014-12-31"))))$clim %>%
                mutate(region="2022 Cross Sound and Icy Strait Heatwaves")) %>%
    bind_rows((detect_event(ts2clm(updateddata %>%
                                     filter(AREA_NAME=="Northern Chatham") %>%
                                     rename(t=READ_DATE,temp=MEAN_SST) %>%
                                     arrange(t), climatologyPeriod = c("1985-01-01", "2014-12-31"))))$clim %>%
                mutate(region="2022 Northern Chatham Heatwaves")) %>%
    bind_rows((detect_event(ts2clm(updateddata %>%
                                     filter(AREA_NAME=="Southern Chatham") %>%
                                     rename(t=READ_DATE,temp=MEAN_SST) %>%
                                     arrange(t), climatologyPeriod = c("1985-01-01", "2014-12-31"))))$clim %>%
                mutate(region="2022 Southern Chatham Heatwaves"))



  #  Create a vector of the days remaining in the year without data.
  yearvec <- seq.Date(max(mhw$t)+1,as_date(paste0(current.year,"-12-31")),"day")
  #  Replace the current year with the previous year for our remaining days vector.
  dummydat <- data.frame(t=as_date(gsub(current.year,(current.year-1),yearvec)),newt=yearvec) %>%
    inner_join(mhw %>% dplyr::select(region,thresh,seas,t)) %>%
    dplyr::select(t=newt,region,thresh,seas) %>%
    mutate(temp=NA)
  # Calculate threshold values for heatwave categories. This code directly from Schegel & Smit
 clim_cat <- mhw %>%
    bind_rows(dummydat) %>%
    group_by(region) %>%
    dplyr::mutate(diff = thresh - seas,
                  thresh_2x = thresh + diff,
                  thresh_3x = thresh_2x + diff,
                  thresh_4x = thresh_3x + diff,
                  year=year(t)) %>%
    arrange(t)

  #  Create annotation text for plot
  mhwlab <- "Heatwave intensity increases\n(successive dotted lines)\nas waters warm.\nHeatwaves occur when daily\nSST exceeds the 90th\npercentile of normal\n(lowest dotted line) for\n5 consecutive days."
  #  Plotting code only slightly modified from heatwaveR vignette
  mhwplotfun <- function(area){
  mhw_base <- ggplot(data = clim_cat %>% filter(t>=as.Date("2022-01-01") & region==area), aes(x = t, y = temp)) +
    geom_line(aes(y = temp, col = "Temperature"), size = 0.85) +
    geom_flame(aes(y2 = thresh, fill = Moderate)) +
    geom_flame(aes(y2 = thresh_2x, fill = Strong)) +
    geom_flame(aes(y2 = thresh_3x, fill = Severe)) +
    geom_flame(aes(y2 = thresh_4x, fill = Extreme)) +
    geom_line(aes(y = thresh_2x, col = "Strong (2x Threshold)"), size = 0.5, linetype = "dotted") +
    geom_line(aes(y = thresh_3x, col = "Severe (3x Threshold)"), size = 0.5, linetype = "dotted") +
    geom_line(aes(y = thresh_4x, col = "Extreme (4x Threshold)"), size = 0.5, linetype = "dotted") +
    geom_line(aes(y = seas, col = "Baseline"), size = 0.65,linetype="solid") +
    geom_line(aes(y = thresh, col = "Moderate (1x Threshold)"), size = 0.5,linetype= "dotted") +

    geom_text(x=as_date("2022-03-01"), y=14, label=mhwlab, size=5, family="sans")+
    scale_colour_manual(name = NULL, values = lineColCat,
                        breaks = c("Temperature", "Baseline", "Moderate (1x Threshold)"),guide=FALSE) +
    scale_fill_manual(name = "Heatwave\nIntensity", values = c(Extreme,Severe,Strong,Moderate),labels=c("Extreme","Severe","Strong","Moderate")#, guide = FALSE
    ) +
    scale_x_date(limits=c(as_date("2022-01-01"),as_date("2022-12-31")),date_breaks="1 month",date_labels = "%b",expand=c(0.01,0)) +
    scale_y_continuous(labels = scales::number_format(accuracy = 1)) +
    ylim(c(0,19))+
    labs(y = "Sea Surface Temperature (°C)", x = NULL) +
    ggtitle(label=area)+
    mytheme+
    theme(strip.text=element_text(size=24),
          legend.position=c(0.615,0.285),
          legend.title = element_text(size=20),
          legend.key.size = unit(0.75,"line"),
          legend.text = element_text(size=16),
          plot.title=element_text(size=24, face="bold", hjust=0.5),
          axis.title.x=element_blank(),
          axis.text.x=element_text(color=c("black",NA,NA,"black",NA,NA,"black",NA,NA,"black",NA,NA,NA)),
          plot.margin=unit(c(1,0.05,3,0),"cm"))
  ggdraw(mhw_base)
  }
  #Northern SE Outside waters
  #temp
  pno1 <- reactive(myplotfun("Northern SE Outside Waters") )

  #sst
  pno2 <- reactive(mhwplotfun("2022 Northern SE Outside Waters Heatwaves"))
  #combine plots
  pno3<-reactive(plot_grid(pno1(),pno2(),ncol=1))
# render plot
  output$NOplot <- renderPlot({
    pno3()
  })

  #Baranof Outside waters
  #temp
  pb1 <- reactive(myplotfun("Baranof Outside Waters") )
  #sst
  pb2 <- reactive(mhwplotfun("2022 Baranof Outside Waters Heatwaves"))
  #combine plots
  pb3<-reactive(plot_grid(pb1(),pb2(),ncol=1))
  # render plot
  output$Bplot <- renderPlot({
    pb3()
  })

  #cross sound waters
  #temp
  pcs1 <- reactive(myplotfun("Cross Sound and Icy Strait") )
  #sst
  pcs2 <- reactive(mhwplotfun("2022 Cross Sound and Icy Strait Heatwaves"))
  #combine plots
  pcs3<-reactive(plot_grid(pcs1(),pcs2(),ncol=1))
  # render plot
  output$CSplot <- renderPlot({
    pcs3()
  })

  #Northern chatnam waters
  #temp
  pnc1 <- reactive(myplotfun("Northern Chatham") )
  #sst
  pnc2 <- reactive(mhwplotfun("2022 Northern Chatham Heatwaves"))
  #combine plots
  pnc3<-reactive(plot_grid(pnc1(),pnc2(),ncol=1))
  # render plot
  output$NCplot <- renderPlot({
    pnc3()
  })

  #Southern chatham
  #temp
  psc1 <- reactive(myplotfun("Southern Chatham") )

  #sst
  psc2 <- reactive(mhwplotfun("2022 Southern Chatham Heatwaves"))
  #combine plots
  psc3<-reactive(plot_grid(psc1(),psc2(),ncol=1))
  # render plot
  output$SCplot <- renderPlot({
    psc3()
  })



}

shinyApp(ui = ui, server = server)
