# Sentinel Custom Analytics

A Sentinel customizable behavioral analytics solution using KQL and Playbooks

![banner](https://github.com/oshezaf/Sentinel-Custom-Analytics/raw/main/media/analytics.jpg)

Sentinel has robust analytics capabilities, but many do not address custom logs, such as business application logs and non-standard IT logs, and don't allow customers to tweak the analysis. 

In this project, we will develop a Sentinel solution that uses KQL, watchlists, and playbooks (with Azure Functions as an option) to allow customers to define behavioral analyticson any data source. Initial use cases we identified are:
-	Business applications such as SAP or Dynamics.
- Networking activity, for example ASIM Network Session data.
-	Cloud management, for example Azure Audit logs.
-	Office activity.

Initially the project is focused on predefined analysis dimensions and using time series decompostion to forecast behoavior. In the future we plan to extend to arbitrary dimentions and add additional anomaly detection algorithms.

The general outline of the initial project is as follows:

- [Service to generate acceleration tables](docs/design/acceleration.md), using Logic Apps or Azure Functions, that will serve as baselines to compare activity against.
- [Dynamic analytics rule](docs/design/detection-and-invstigation.md#anomaly-detection-analytic-rule), configured using a Watchlist, that detects abnormal behaviors, using [series decomposition](https://learn.microsoft.com/azure/data-explorer/kusto/query/series-decomposefunction). The initial release focuses on supporting any source, across predefined dimension. 
- [Analytic rule](docs/design/detection-and-invstigation.md#incident-generation-analytic-rule) to aggregate anomalies to trigger an incident.
- [Workbook](docs/design/detection-and-invstigation.md#anomaly-investigation-workbook) to investigate an anomaly.
- A content hub solution to package it all.

In addition, we plan to provide:
-	Documentation.
-	Presentation and demo.
-	Cost prediction model for the cost of Logic Apps and custom logs required.


