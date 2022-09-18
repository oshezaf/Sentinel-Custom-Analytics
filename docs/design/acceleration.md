# Generating forecasts using playbooks

## Overview

A serverless scheduled service (initially implemented using Logic Apps) will will create time series and derived forcast over data sets defined using a wathclist.

Future:
- Converting the Logic App to an Azure Function. 

## Configuration Watchlists

### Series defintion

- Watchlist name: SentinelCustomAnalytics_Series
- Watchlist columns:
  - Source: the 
  - HostnameField - the field from the source depicting a hostname.
  - UserField- the field from the source depicting a user.
  - AcitivtyField - the field from the source depicting an activity.
  - SrcIpAddField- the field from the source depicting the IP from which the activity was performed.

### Global configuration

- Watchlist name: SentineCustomAnalytics_Configuration
- Wachlist columns: Key, Value
- Supported Keys:
  - TimeSeriesFrequency (X below)
  - TimeSeriesMaxGenerationPeriod (Y below)
  - ForecastMaxLookBack 
  - ForecastGenerationFrequency
  - ForecastGenerationWindow

## Time Series generation Playbook

A playbook that will run every X minutes and generate a time series custom table from a list of source tables.
-	The configuration of X will be from a general configuration watchlist of this system. 
-	The playbook will take input from the SentinelCustomAnalytics_Series watchlist that stores definition of the sources to detect anomalies on. Each row in the watchlist will include:
-	The playbook will iterate over the watchlist and create a time series for each watchlist source definition row:
  - The time series will be over accurate time buckets (i.e. 10:10 <= time <10:20)
  - The playbook will pick from the last entry in the time series, but not more than Y minutes back.
  -  Note that the time series need to be generated using summarize, and not make_series, as the output it a table.
-	The output time series, in a standard format will be written to a single custom table that will include:
  -	The table name.
  - The dimention values
  - The bin timestamp.

Future enhancements:
-	Setting the frequency (X), maximum going back (Y), per source definition. 
-	Arbitrary number of dimensions.

Notes:
- Users can still achieve full flexibility by using a stored function as the table. Another option is to allow a query in the watchlist, but a table name allows the alert/workbook/incident to more easily reference the original data.

## Prediction generation playbook

A playbook that will take the timeseries and will generate predictions to be used by the analytic rule. 
-	The playbook will run every Z minutes, that can be different than X above, also configured in the general configuration watchlist.
-	The playbook will generate for each time series (i.e. per source and dimensions), the prediction to the next periods needed until it runs again, using the time_series_forecast function. 
-	The result will be appended to the prediction custom table 

Future enhancements:
-	Setting Z per source definition. 
-	Generating prediction for a population, for example general activity for a user or a host, regardless of activity type, and taking those into account in the anomaly detection.
