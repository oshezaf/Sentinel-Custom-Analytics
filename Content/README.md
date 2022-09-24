# Sentinel Custom Analytics - Playbooks

The following playbooks are used to by the Sentinel Custom Analytics solution to write custom analytics data:

### Time series generation
Playbook name: **SentinelCustomAnalyticsTimeSeries**
<br><br>
Description:<br>
The SentinelCustomAnalyticsTimeSeries playbook runs by default every 10 minutes and is used to generate Time Series based on the data entered in SentinelCustomAnalytics_SourceConfiguration or SentinelCustomAnalytics_GlobalConfiguration Watchlists. Currently the timeseries can only aggregate data based on a known field name for host, username, IP, activity or any one integer field.

### Anomaly forecast generation
Playbook name: **SentinelCustomAnalyticsForecast**
<br><br>
Description:<br>
The SentinelCustomAnalyticsForecast playbook runs by default every 1 hour and is used to call the KQL function **SCAForecast()** which in turn calls series_decompose_forecast() to generate anomaly predictions from data stored in the SentinelCustomAnalytics_TimeSeries_CL table. Resulting predictions are added and stored in SentinelCustomAnalytics_Prediction_CL.

### IP address anomaly data

Playbook name: **SentinelCustomAnalyticsFrequentIP**
<br><br>
Description:<br>
The SentinelCustomAnalyticsFrequentIP playbook runs by default every 1 hour and is used to call the KQL function **SCAFrequentIP()** which generates information on frequency seen IP addresses within the timeseries data. Results are written to SentinelCustomAnalytics_Prediction_CL.
<br><br>
Playbook name: **SentinelCustomAnalyticsRareIP**
<br><br>
Description:<br>
The SentinelCustomAnalyticsRareIP playbook runs by default every 1 hour and is used to call the KQL function **SCARareIP()** which generates information on rarely seen IP addresses within the timeseries data. Results are written to SentinelCustomAnalytics_Prediction_CL.