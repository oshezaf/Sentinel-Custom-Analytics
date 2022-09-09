# Sentinel Custom Analytics
A Sentinel customizable behavioral analytics solution using KQL and Playbooks

Sentinel has robust analytics capabilities, but many do not address custom logs, such as business application logs and non-standard IT logs, and don't allow customers to tweak the analysis. 

In this project, we will develop a Sentinel solution that uses KQL, watchlists, and playbooks (with Azure Functions as an option) to allow customers to define behavioral analytics on any data source, any variable, and a choice of behavioral algorithms. We will also aim to add a few out-of-the-box behavioral analytics rules to demonstrate the use of the new solution.

The general outline of the project initial goals is as follows

- A scheduled playbook, or an Azure function, which is configured using a Watchlist and generate acceleration tables:
- A set of KQL functions that uses the acceleration tables to calculate dynamic thresholds over use selected fields in any give table and can be used as building blocks in queries and [Microsoft Sentinel](https://docs.microsoft.com/azure/sentinel/) [anlaytic rules](https://docs.microsoft.com/azure/sentinel/detect-threats-custom).
- Analytic rules that use the functions and acceleration tables to implment behavioral use cases 
- Package it all for Azure deployment and as a Sentinel solution.

As a next step the dynamic thresholds can be expanded to more sophisticated abalytical functions.
