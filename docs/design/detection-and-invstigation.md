# Detection and investigation

Anomaly detection will include:
- An analytic rule that will find anomalies using the [forecast generated](docs/design/acceleration.md). 
- An analytic rule to aggregate anomalies into incidents.
- A workbook to investigate anomalies.

## Configuration Watchlists

The rules and workbook will use the [**SentinelCustomAnalytics_SourceConfiguration** configuration watchlist](docs/design/acceleration.md#configuration-watchlists) as well as the **SentinelCustomAnalytics_AnomaliesConfiguration** wachlist.

### Anomalies configuration

The watchlist **SentinelCustomAnalytics_AnomaliesConfiguration** will include a row per source and activity with information about the alert to generate if an anomaly is identified for this source an activity. Defaults will be provided in the general configuration wathclist if a row is not provided for the specific source and activity. 

### Exceptions configuration

The watchlist **SentinelCustomAnalytics_AnomaliesExceptions** will enable defining combniation of host/user/activity/ip for which an alert should not be triggered. The value * will indicate any in the exception.

So for example:
-	User/*/*/* will suppress any anomaly for the user
-	User/Activity/*/* will suppress anomaly for the user for a specific activity.

## Anomaly detection analytic rule

-	The analytic rule will compare the prediction prepared by the forcast to the actual values to using [Tukey's fences](https://en.wikipedia.org/wiki/Outlier#Tukey%27s_fences).
-	If an anomaly is identified, an alert will be triggered, with the alert details taken from the **SentinelCustomAnalytics_AnomaliesConfiguration** configuration watchlist.
-	An alert will not be triggered if the combination of host/user/activity/ip combinations appears in the **SentinelCustomAnalytics_AnomaliesExceptions** watchlist.

## Incident generation analytic rule

The incident generation rule will aggregate anomlies for each dimention combination, taking into account a wight include **SentinelCustomAnalytics_AnomaliesConfiguration** and will trigger an incident if the sum is higher than a threshold.

## Anomaly investigation workbook

A workbookthat  will allow exploring the anomalies:
-	Filter anomalies for a specific user/host/ip/activity.
-	For a selected anomaly:
  -	Chart the anomaly, i.e. the time series the anomaly is part of highlighting the anomaly.
  - List activities that is part of the anomaly.
