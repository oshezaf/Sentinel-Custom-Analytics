# Sentinel Custom Analytics solution overview

## Time series generation

Logic App Name: **SentinelCustomAnalyticsTimeSeries**

The SentinelCustomAnalyticsTimeSeries Logic App runs by default every 10 minutes and is used to generate Time Series based on the data entered in SentinelCustomAnalytics_SourceConfiguration or SentinelCustomAnalytics_GlobalConfiguration Watchlists. Currently the time series can only aggregate data based on a known field name for host, username, IP, activity or any one integer field.

## Anomaly forecast generation

### Using series decomposition

Logic App Name: **SentinelCustomAnalyticsForecast**

The SentinelCustomAnalyticsForecast Logic App runs by default every 1 hour and is used to call the KQL function **SCAForecast()** which in turn calls series_decompose_forecast() to generate anomaly predictions from data stored in the SentinelCustomAnalytics_TimeSeries_CL table. Resulting predictions are added and stored in SentinelCustomAnalytics_Prediction_CL.

### Using IP address prediction

Logic App Name: **SentinelCustomAnalyticsFrequentIP**

The SentinelCustomAnalyticsFrequentIP Logic App runs by default every 1 hour and is used to call the KQL function **SCAFrequentIP()** which generates information on frequency seen IP addresses within the time series data. Results are written to SentinelCustomAnalytics_Prediction_CL.

Logic App Name: **SentinelCustomAnalyticsRareIP**

The SentinelCustomAnalyticsRareIP Logic App runs by default every 1 hour and is used to call the KQL function **SCARareIP()** which generates information on rarely seen IP addresses within the time series data. Results are written to SentinelCustomAnalytics_Prediction_CL.