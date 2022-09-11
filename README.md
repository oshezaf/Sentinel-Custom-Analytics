# Sentinel Custom Analytics

A Sentinel customizable behavioral analytics solution using KQL and Playbooks

Sentinel has robust analytics capabilities, but many do not address custom logs, such as business application logs and non-standard IT logs, and don't allow customers to tweak the analysis. 

In this project, we will develop a Sentinel solution that uses KQL, watchlists, and playbooks (with Azure Functions as an option) to allow customers to define behavioral analytics [use cases](docs/design/use-cases.md) on any data source, any variable, and a choice of behavioral algorithms. We will also aim to add a few out-of-the-box behavioral analytics rules to demonstrate the use of the new solution.

The general outline of the project initial goals is as follows:

- A [service to generate acceleration tables](docs/design/acceleration-tables.md), using Logic Apps or Azure Functions, that will serve as baselines to compare activity against.
- A set of KQL functions that use the acceleration tables to calculate dynamic thresholds to facilitate custom rules, hunting queries and insights using the baselines.
- A dynamic analytics rule, configured using a Watchlist, that can be configured to detect abnormal behaviors for variable or variables in any table using the acceleration tables baselines.
- A content hub solution to package it all.

As a next step the dynamic thresholds can be expanded to more sophisticated analytical functions.
