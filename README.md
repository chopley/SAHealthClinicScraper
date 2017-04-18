# SAHealthClinicScraper
Scraper for extracting health clinic data from online database

The data are found here:
http://www.healthsites.org.za

They are organised by province and include the following metadata describing the clinic itself:
1. facility_name
2. category (HIV Counselling, 1. HIV Counselling and Testing (HCT) 2. Abuse, Rape and Domestic Violence Survivor Support, 3. Medical Male Circumcision (MMC), 4.Antiretroviral (ARV) Treatment) 
3. contact_details
4. trading_hours
5. municipality
6. physical_address
7. gps_coords

This is still a work in progress but in the current incarnation you simply add wbepage of the first page for each province to startPages and an appropriate pattern search in the patterns location. The script will automatically go through all the the webpages associated with each province, extract the url's for each clinic page, parse each clinic page and insert the data into a dataframe. 

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
