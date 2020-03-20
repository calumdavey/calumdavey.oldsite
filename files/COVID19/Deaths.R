# USING CODE FROM: 
# 
# https://github.com/JonMinton/COVID-19 # @JonMinton
# https://gist.github.com/christophsax/dec0a57bcbc9d7517b852dd44eb8b20b 
# @christoph_sax
# https://github.com/gorkang/2020-corona/blob/master/2020-corona-plot.R#L18-L20

# Libraries 

library(dplyr)
library(ggplot2)
library(ggrepel)
library(readr)
library(tidyr)
library(scales)

# Data Repo Johns Hopkins CSSE (https://github.com/CSSEGISandData/COVID-19)
url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
dta_raw <- read_csv(url, col_types = cols()) %>% select(-Lat, -Long)

selection <- c("Italy", 
               #"Iran", 
               "Spain", 
               #"South Korea", 
               "France", 
               "Germany", 
               "US", 
               "Japan", 
               #"Mainland China", 
               "United Kingdom")

dta <- dta_raw %>%
  
  # tidy data
  rename(province = `Province/State`, country = `Country/Region`) %>%
  pivot_longer(c(-province, -country), "time") %>%
  mutate(time = as.Date(time, "%m/%d/%y")) %>%
  
  # rename some countries
  mutate(
    country = case_when(
      country == "Iran (Islamic Republic of)" ~ "Iran",
      country == "Hong Kong SAR"  ~ "Hong Kong",
      country == "Republic of Korea" ~ "South Korea",
      TRUE ~ country
    )) %>% 
  
  # selection
  filter(country %in% !! selection) %>%
  
  # ignore provinces
  group_by(country, time) %>%
  summarize(value = sum(value)) %>%
  ungroup() %>%
  
  # calculate new infections
  arrange(time) %>%
  group_by(country) %>%
  mutate(diff = value - lag(value)) %>%
  ungroup() %>%
  filter(!is.na(diff)) %>%
  arrange(country, time)

DF_plot = dta %>%
  filter(value >= 1) %>%
  group_by(country) %>% 
  mutate(days_after_1 = 0:(length(country)-1)) %>% 
  
  # Create labels for last instance for each country
  group_by(country) %>% 
  mutate(
    name_end = 
      case_when(
        days_after_1 == max(days_after_1) ~ paste0(as.character(country), " after ", days_after_1, " days"),
        TRUE ~ "")
  )



# PLOT --------------------------------------------------------------------

plot1 = DF_plot %>% 
  ggplot(aes(x = days_after_1, y = value, color = country)) +
  geom_line() + 
  ggrepel::geom_label_repel(aes(label = name_end), show.legend = FALSE, segment.color = "grey", segment.size  = .2) + #, segment.linetype = 5 
   scale_y_log10(
     breaks = scales::trans_breaks("log10", function(x) 10^x),
     labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
  scale_x_continuous(breaks = seq(0, max(DF_plot$value), 2)) +
  labs(
    title = "Confirmed Covid deaths",
    subtitle = "Arranged by number of days since 10 or more deaths",
    x = "Days after 10 confirmed cases",
    y = "Confirmed deaths (log scale)", 
    caption = "Source: Johns Hopkins CSSE"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

plot1