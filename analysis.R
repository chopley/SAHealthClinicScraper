#This script is used to read the data from the SA Health Site
#CJC Rev A 2017/04/12

install.packages("networkD3")
install.packages("extrafont")
install.packages("RCurl")
install.packages("caTools")
install.packages("stringdist")
install.packages("rgl")
install.packages("rvest")
install.packages("pipeR")
install.packages("dplyr")
install.packages("XML")
install.packages('leaflet')


require(rvest)
require(XML)
require(ggplot2)
require(pipeR) # %>>% will be faster than %>%
require(httr)
require(RCurl)
require(dplyr)
library('caTools')
library(igraph)
library('stringdist')
library('rgl')
require(doParallel)
require(foreach)
require(networkD3)
require(plotly)
library(magrittr)
library(extrafont)
font_import()
library(doParallel)

#open up the user specific functions defined in functions.R- this has definitions of the web page format etc.
source('./functions.R')



nCores<-detectCores()
cl<-makeCluster(nCores)
registerDoParallel(cl)
getDoParWorkers()
mcoptions <- list(preschedule=FALSE, set.seed=FALSE)
getDoParName()



base <- "http://www.healthsites.org.za"
startPages <- c("/clinics-in-western-cape.html",
                "/clinics-in-eastern-cape.html",
                "/clinics-in-free-state.html",
                "/clinics-in-gauteng.html",
                "/clinics-in-kwazulu-natal.html",
                "/clinics-in-limpopo.html",
                "/clinics-in-mpumalanga.html",
                "/clinics-in-north-west.html",
                "/clinics-in-northern-cape.html")

patterns <- c("^/western-cape-.*html$",
              "^/eastern-cape.*html$",
              "^/free-state-.*.html$",
              "^/gauteng-.*.html$",
              "^/kwazulu-natal-.*.html$",
              "^/limpopo-.*.html$",
              "^/mpumalanga-.*.html$",
              "^/north-west-.*.html$",
              "^/northern-cape-.*.html$")
URLlist=NULL
for(i in 1:length(patterns)){
  pageURL <- startPages[i]
  webPage<-read_html(paste(base,pageURL,sep=""))
  lastPageURL <- html_nodes(webPage,'a')[grep("Go to last page",html_nodes(webPage,'a'))] %>%html_attr("href")
  while(length(pageURL)>0){
    print(pageURL)
    webPage<-read_html(paste(base,pageURL,sep=""))
    URLs<-html_nodes(webPage,'a')%>%html_attr('href') %>% grep(patterns[i],.,value = TRUE)
    pageURL <- html_nodes(webPage,'a')[grep("Go to next page",html_nodes(webPage,'a'))] %>%html_attr("href")
    URLlist <- append(URLlist,URLs)
  }
}

length(URLlist)
facility.dataframe=NULL
for(i in 1:length(URLlist)) {
  testURL <- paste(base,URLlist[i],sep="")
  fac_name <-NULL
  category <-NULL
  contact_details <-NULL
  trading_hours <-NULL 
  municipality<-NULL 
  physical_address<-NULL 
  gps_coords<-NULL
  print(testURL)
  print(i)
  out <- tryCatch(
    {
      webPage<-read_html(testURL)
      #facility name
      fac_name <- html_nodes(webPage,'.page-title')%>%html_text()
      #-category
      html_nodes(webPage,'.field-name-field-category .field-label')%>%html_text
      category <- html_nodes(webPage,'.field-name-field-category .field-item')%>%html_text
      #-contact-dtails
      html_nodes(webPage,'.field-name-field-contact-dtails .field-label')%>%html_text
      contact_details <- html_nodes(webPage,'.field-name-field-contact-dtails .field-item')%>%
        html_text
      #trading hours
      html_nodes(webPage,'.field-name-field-combined-trading-hours .field-label')%>%html_text
      trading_hours <- html_nodes(webPage,'.field-name-field-combined-trading-hours .field-item')%>%
        html_text
      #municipality
      html_nodes(webPage,'.field-name-field-combined-municipality .field-label')%>%html_text
      municipality <- html_nodes(webPage,'.field-name-field-combined-municipality .field-item')%>%
        html_text
      #physical address
      html_nodes(webPage,'.field-name-field-combined-location .field-label')%>%
        html_text
      physical_address <- html_nodes(webPage,'.field-name-field-combined-location .field-item')%>%
        html_text%>%
        paste(., collapse = ',')
      #gps coords
      html_nodes(webPage,'.field-name-field-combined-gps-coordinates .field-label')%>%
        html_text
      gps_coords <- html_nodes(webPage,'.field-name-field-combined-gps-coordinates .field-item')%>%
        html_text
      facility.data <- data.frame(fac_name, category, contact_details,trading_hours, municipality, physical_address, gps_coords, testURL)
    },
    error=function(cond) {
      return(NA)
    }
  )
    facility.data <- data.frame(fac_name, category, contact_details,trading_hours, municipality, physical_address, gps_coords, testURL)
    facility.dataframe <- rbind(facility.dataframe,facility.data)
}

lat<-sapply(facility.dataframe$gps_coords, function(x) as.numeric(unlist(strsplit(as.character(x),','))[1]))
lon<-sapply(facility.dataframe$gps_coords, function(x) as.numeric(unlist(strsplit(as.character(x),','))[2]))


facility.dataframe$lon<-unlist(strsplit(as.character(facility.dataframe$gps_coords),','))[2]

?sapply
con <- dbConnect(MySQL(), user="root", 
                 dbname="charles", host="localhost",client.flag=CLIENT_MULTI_STATEMENTS)
dbListTables(con)
dbWriteTable(con,"south_africa_clinical_facilities",facility.dataframe,overwrite=T)
    dbDisconnect(con)


  
 
  