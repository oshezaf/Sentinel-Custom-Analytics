# Use cases

## Overview

The solution will enable to easily create behavioral analytics over any logs using baselines. The primary use case is identifying abnormal, excessive, rate, of activity.

Examples include identifying:

- Excessive access to files in a specific folder by a specific user.
- Excessive number of new users added to a system.
- Excessive number of purchase orders issued.

The abnormal behavior can be:

- Global, i.e. overall activity rate.
- For an entity, when compared to its past behavior.
- For an entity, when compared to a typical entity behavior.

## Example

Let's look at the access to files in a specific folder by a specific user example, with the following model assumptions:

- The baseline normal behavior is the average access rate of users that actually use files.
- The detection period is a day, i.e. for each user we will check their daily use and compare to the baseline.
- The learning period is at least 15 days, and up to 180 days.
- Abnormal behavior, or the threshold, is defined as 4 standard deviations above the average.

## Generalization

The above use case can be generalized using parameters:

- Detection frequency
- Minimum and maximum learning periods
- The grouping fields.
- The threshold criteria. To start with, any of:
  - Number of standard deviations.
  - Multiply of percentiles, including median.
- Whether the threshold is for the individual, or across the population.
