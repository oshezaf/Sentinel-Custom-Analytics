# Acceleration tables design

## Overview

A serverless scheduled service (implemented using either a Logic Apps or an Azure Function) will executed summarization queries against a workspace and store the resulting summary information in a custom table.

The configuration of the summarization service will be stored in a Watchlist and will support multiple summarization tables. Configuration will support two modes:

- `raw`, which allows specifying explicitly all the summarization parameters directly.
- `baseline`, which enables defining the baseline calculation needed, allowing the service to build the required query 


## Configuration details

### Common parameters

| Attribute | Description |
| --------- | ----------- |
| Type      | The type of definition: query or baseline |
| Summary Table  | The target custom table to write the summary to |
| Frequency | How often to execute the summarization definition, expressed in minutes. An enhacement would be to support cron like scheduling. |

### Query mode

| Attribute | Description |
| --------- | ----------- |
| Query     | The KQL query to run to generate the summary |

### Baseline mode

| Attribute | Description |
| --------- | ----------- |
| Base query | A query selecting the relevant records to summarize. At the minimum, this is a table name.  |
| Summary Fields | The fields to summarize |
| Summary function | The summary function to apply |

The process will support two modes. In query mode, `Query` is executed and the results are appended to the summary table. In baseline more, tיק 


Notes and open questions:

- The initial version will use Log Analytics v1 custom logs using the the [Log Analytics ingestion API](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview)
- How to implement workspace authentication configuration for read and write.
