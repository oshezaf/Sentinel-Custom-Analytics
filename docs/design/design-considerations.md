# Design considerations

## Prediction vs. detection

Analytics requires prediction, or baselining to drive detection. There are two options to implement that:
- Both as part of the anlaytic rule.
- Seperating the prediction to a prepeartion job (Logic Apps or an Azure function)

In the first phase of the project we have opted for the second option. Note that the optins are not mutulaly exclusive. For example, since the main limitation of using only an analytic rule is looking back only to a maximum of 14 days, any predicision for which this is enough can use only a rule.

### Both as part of the anlaytic rule

Pros:
- Easier to maintain: 
  - Users feel more comfortable with creating and updating analytic rules.
  - Always easier to maintain a single location than a split algorithm.

Cons:
- Limited to 14 days look back. To resolve that, we would need to "Refresh" the data on an onging basis to the last 14 days, which creates significant data duplication and cost to the customer.
- Less efficient as each rule run need to build the prediction again.
