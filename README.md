# Sentinel Custom Analytics

A Sentinel customizable behavioral analytics solution using KQL and Playbooks

Sentinel has robust analytics capabilities, but many do not address custom logs, such as business application logs and non-standard IT logs, and don't allow customers to tweak the analysis. 

In this project, we will develop a Sentinel solution that uses KQL, watchlists, and playbooks (with Azure Functions as an option) to allow customers to define behavioral analytics [use cases](docs/design/use-cases.md) on any data source, any variable, and a choice of behavioral algorithms. We will also aim to add a few out-of-the-box behavioral analytics rules to demonstrate the use of the new solution.

The general outline of the initial project is as follows:

- [Service to generate acceleration tables](docs/design/acceleration.md), using Logic Apps or Azure Functions, that will serve as baselines to compare activity against.
- [Dynamic analytics rule](docs/design/detection-and-invstigation.md#anomaly-detection-analytic-rule), configured using a Watchlist, that detects abnormal behaviors, using [series decomposition](https://learn.microsoft.com/azure/data-explorer/kusto/query/series-decomposefunction). The initial release focuses on supporting any source, across predefined dimension. 
- [Analytic rule](docs/design/detection-and-invstigation.md#incident-generation-analytic-rule) to aggregate anomalies to trigger an incident.
- [Workbook](docs/design/detection-and-invstigation.md#anomaly-investigation-workbook) to investigate an anomaly.
- A content hub solution to package it all.

In the future we plan to expand also to:
- Additional anomaly detection algorithms. 
- Arbitrary dimensions.
