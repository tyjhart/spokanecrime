---
title: "2019 Spokane Crime"
author: "Tyler Hart"
date: "2019-12-12"
output:
  pdf_document:
    fig_caption: yes
    keep_tex: yes
    number_sections: yes
    toc: yes
    toc_depth: 2
  word_document:
    toc: yes
    toc_depth: '2'
  html_document:
    df_print: paged
header-includes:
- \usepackage{graphicx}
- \usepackage{float}
- \floatplacement{figure}{H}
---

```{r setup, echo=FALSE, warning=FALSE, message=FALSE}
library(tidyverse)
library(stringr)
library(data.table)
library(scales)
library(lunar)
library(kableExtra)
library(magick)
library(webshot)
library(knitr)
knitr::opts_chunk$set(
  echo = FALSE, 
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  results = 'asis',
  fig.align = 'center',
  fig.pos = 'ht',
  dpi = 400,
  fig.path='./figures/',
  dev=c('svg','png'),
  out.width = '100%'
  )
library(kableExtra)
require(RColorBrewer)
```

# Overview

This report summarizes 2019 crime data provided by the Spokane Police Department's (SPD) Crime Analysis Office. It's the first time our project has had the opportunity to do a comprehensive summary of a full year's data. This is also the first time we've had a full prior year's data for comparison. You can find weekly reports used for data analysis on the Compstat website at the link provided at the end of this report. This end-of-year report summarizes data from 2019 and compares against totals from 2018.

# Disclosures

Compstat data provided by SPD in weekly reports is limited. Their reports state, 

> "The CompStat report is designed for operational use and includes only selected NIBRS categories and coding less complex than full NIBRS rules. Official statistics for these and other NIBRS categories can be found on WASPC & FBI websites once available."

Unfortunately, as of 12/12/2019 there is no 2019 data available on the [FBI's NIBRS portal for Washington](https://crime-data-explorer.fr.cloud.gov/explorer/state/washington/crime). There is also no 2019 data available on the [Washington Association of Sheriffs & Police Chiefs (WASPC) webpage](https://www.waspc.org/crime-statistics-reports) either. Without data available for 2019 from either the FBI or WASPC we're using SPD-provided "operational use" data.

# Narrative

Overall, 2019 saw lower aggregate crime numbers from what we experienced in 2018. Figure !!! shows a table:



# Resources & Tools

The Weekly Watch project uses open software and data solutions. Here are the tools and data sources we use for analysis and compiling reports:

Tools:

1. Microsoft R: https://mran.microsoft.com/open

1. RStudio: https://rstudio.com/

1. MikTex: https://miktex.org/

Data Sources:

1. Spokane Compstat website: https://my.spokanecity.org/police/prevention/compstat/