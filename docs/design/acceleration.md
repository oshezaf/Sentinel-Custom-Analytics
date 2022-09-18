# Generating forecasts using playbooks

## Overview

A serverless scheduled service (initially implemented using Logic Apps) will will create time series and derived forcast over data sets defined using a wathclist.

Future:
- Converting the Logic App to an Azure Function. 

## Configuration Watchlists

### Series defintion

- Watchlist name: SentinelCustomAnalytics_SourceConfiguration
- Watchlist columns:
  - Source: the name of the table to analyse. This can be a stored function to allow further customization of the sourcee data.
  - The columns to analyze:
    - HostnameField - the field from the source depicting a hostname.
    - UserField- the field from the source depicting a user.
    - AcitivtyField - the field from the source depicting an activity.
    - SrcIpAddField- the field from the source depicting the IP from which the activity was performed.
  - Time series and forecast generation parameters 
    - **TimeSeriesBinSize** - the size, in minutes of the bins to create data points and forecasts on. Note that the same value is also used for the forcast bin size.
    - **TimeSeriesGenerationDelay** - the delay, in minutes for generation, to accomodate for source ingest delays. For example, if the TimeSeriesGenerationDelay, the current generation run will generate time series only up to events arriving at least 30 minutes ago. 
    - **MaxTimeSeriesGenerationPeriod** (Y below) - how far back, in days, to generate time series for if missing.
    - **MinForecastLookbackPeriod** - the minimum time, in days, needed to generate a forecast.
    - **MaxForecastLookbackPeriod** - how far back, in days, to include in the data series for a forecast. Limiting lookback may be needed for performance reasons.
    - **ForecastGenerationPeriod** - how far forward to generate forcasts in each forecasting run.

### Global configuration

- Watchlist name: SentineCustomAnalytics_GlobalConfiguration
- Wachlist columns: Key, Value
- Supported Keys:
  - Playbooks frequency (those values might be hard to get from the configuration and many need to be embedded in the playbooks):
    - SeriesGenerationFrequency
    - ForecastGenerationFrequency
  - Default values for series specific settings:
    - DefaultTimeSeriesBinSize
    - DefaultTimeSeriesGenerationDelay
    - DefaultMaxTimeSeriesGenerationPeriod 
    - DefaultMinForecastLookbackPeriod
    - DefaultMaxForecastLookbackPeriod
    - DefaultForecastGenerationPeriod

## Time Series generation Playbook

A playbook that will run every **SeriesGenerationFrequency** minutes and generate a time series custom table from a list of source tables.
-	The playbook will take input from the **SentinelCustomAnalytics_SourceConfiguration** watchlist that stores definition of the sources to detect anomalies on. 
-	The playbook will iterate over the watchlist and create a time series for each watchlist source definition row:
  - The time series will be over accurate time bins of **TimeSeriesBinSize** minutes (i.e. 10:10 <= time <10:20).
  - The time series will be generated with a delay of **TimeSeriesGenerationDelay** minutes to accomodate for source ingestion delays.
  - The playbook will pick from the last entry in the time series, but not more than **MaxTimeSeriesGenerationPeriod** days back.
  - Note that the time series need to be generated using summarize, and not make_series, as the output it a table.
-	The output time series, in a standard format will be appended to the custom table **SentinelCustomAnalytics_TimeSeries** that will include:
  -	**Source**: The source name.
  - **Hostname**, **User**, **SrcIpAddr**, **Activity**: The dimention values.
  - **TimeBin**: The bin timestamp.

Future enhancements:
-	Arbitrary number of dimensions.
-	Support for aggregation functions other than count.

## Prediction generation playbook

A playbook that will take the timeseries and will generate predictions to be used by the analytic rule. 
-	The playbook will run every **ForecastGenerationFrequency** minutes, that can be different than **SeriesGenerationFrequency**.
-	The playbook will generate for each time series (i.e. per source and dimensions), the prediction to future time bins up to **ForecastGenerationPeriod** using the [series_decompose_forecast](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/series-decompose-forecastfunction) function. 
-	The output time series, in a standard format will be written to a single custom table that will include:
-	The result will be appended to the prediction custom table **SentinelCustomAnalytics_Prediction** which has the same fields as **SentinelCustomAnalytics_TimeSeries** plus a forecast value.

Future enhancements:
-	Generating prediction for a population, for example general activity for a user or a host, regardless of activity type, and taking those into account in the anomaly detection.
