# Tooth Growth Analysis
Michael Szczepaniak  
September 2015  

## Synopsis

This report explores the relationship between the length of teeth in 10 guinea pigs to three Vitimin C dosages and two delivery methods using the R ToothGrowth data set.  The data provided evidence that an increased mean tooth length was observed with increased dosage with both delivery methods under a Type II error rate alpha = 0.05.  The data also provided evidence that an increased mean tooth length was observed with the orange juice deliver method for the 0.5 and 1.0 mg doses under a Type II error rate alpha = 0.05.

## Loading Data & Exploratory Data Analysis
Note: All code used for the report are contained the **Code Used for the Analysis** section.

The *loadToothData* function was used to load the data.  This function was first passed to the *getToothSummary* to create the following summary table.  The **Group** variable concatinates the **Delivery** and **Dose** variables.
  
<table>
<thead>
<tr class="header">
<th align="left">Group</th>
<th align="right">Mean.Length</th>
<th align="right">Std.Dev.Length</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">OJ0.5</td>
<td align="right">13.23</td>
<td align="right">4.46</td>
</tr>
<tr class="even">
<td align="left">OJ1.0</td>
<td align="right">22.70</td>
<td align="right">3.91</td>
</tr>
<tr class="odd">
<td align="left">OJ2.0</td>
<td align="right">26.06</td>
<td align="right">2.66</td>
</tr>
<tr class="even">
<td align="left">VC0.5</td>
<td align="right">7.98</td>
<td align="right">2.75</td>
</tr>
<tr class="odd">
<td align="left">VC1.0</td>
<td align="right">16.77</td>
<td align="right">2.52</td>
</tr>
<tr class="even">
<td align="left">VC2.0</td>
<td align="right">26.14</td>
<td align="right">4.80</td>
</tr>
</tbody>
</table>
  
The *loadToothData* function was then passed to the *exploreBox* function to create the boxplot below.

![](ToothDecayAnalysis_files/figure-html/unnamed-chunk-2-1.png) 
  
From this initial look at the data, three questions emerge to guide further exploration:

1. Does increased vitamin C dosage lead to an increase or decrease in tooth length?
2. Does vitamin C delivery method lead to an increase or decrease in tooth length?
3. Are the effects of dosage and delivery method on tooth length independent or coupled?

The plot above suggests a possible relationship between increasing dosage and tooth length for both delivery methods.  Dosage and delivery method were then explored by hypothesis testing.  The independence of the impact of dosage and delivery as stated in the third question above was not explored in this report.

## Analysis of the Data
Because the data does not contained ids for each animal, a paired analysis is not possible without assuming the data was ordered in a particular way.  For this reason, the analysis will focus on group comparisons.  The data contains 6 groups each with 10 measurments and are defined in the summary table.

To answer the first two questions, the null hypothesis was defined as H0: Mean A = Mean B and the alternative hypothesis as Ha: Mean B > Mean A where A and B are the groups defined in the testing table (created by the function *createTestingTable*) shown below.
  
<table>
<thead>
<tr class="header">
<th align="left">Test</th>
<th align="left">t1</th>
<th align="left">t2</th>
<th align="left">t3</th>
<th align="left">t4</th>
<th align="left">t5</th>
<th align="left">t6</th>
<th align="left">t7</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Addresses</td>
<td align="left">Question 1.</td>
<td align="left">Question 1.</td>
<td align="left">Question 1.</td>
<td align="left">Question 1.</td>
<td align="left">Question 2.</td>
<td align="left">Question 2.</td>
<td align="left">Question 2.</td>
</tr>
<tr class="even">
<td align="left">Group A</td>
<td align="left">OJ0.5</td>
<td align="left">OJ1.0</td>
<td align="left">VC0.5</td>
<td align="left">VC1.0</td>
<td align="left">VC0.5</td>
<td align="left">VC1.0</td>
<td align="left">VC2.0</td>
</tr>
<tr class="odd">
<td align="left">Group B</td>
<td align="left">OJ1.0</td>
<td align="left">OJ2.0</td>
<td align="left">VC1.0</td>
<td align="left">VC2.0</td>
<td align="left">OJ0.5</td>
<td align="left">OJ1.0</td>
<td align="left">OJ2.0</td>
</tr>
<tr class="even">
<td align="left">Mean A</td>
<td align="left">13.23</td>
<td align="left">22.7</td>
<td align="left">7.98</td>
<td align="left">16.77</td>
<td align="left">7.98</td>
<td align="left">16.77</td>
<td align="left">26.14</td>
</tr>
<tr class="odd">
<td align="left">Mean B</td>
<td align="left">22.7</td>
<td align="left">26.06</td>
<td align="left">16.77</td>
<td align="left">26.14</td>
<td align="left">13.23</td>
<td align="left">22.7</td>
<td align="left">26.06</td>
</tr>
</tbody>
</table>
  
## Hypothesis Testing Result
  
TBD
  
## Assumptions & Conclusions

### Assumptions  
1. Variation between the populations tested were not equal.
2. Distribution of group means are not skewed (i.e. they are relatively symmetric) and mound-shaped.
3. The guineau pigs were IID normal in their selection.
4. The effects of dosage and delivery method on tooth length are independent.

### Conclusions
1. Under False Positive Rate (FPR) control only with alpha = 0.05, we reject H0 in favor of Ha for all tests except **t7**.
2. Under Family-wise Error Rate (FWER) control using Bonferroni correction, TBD
3. Under False Discovery Rate (FDR) control using Benjamini Hochberg (BH), TBD
4. Based on ???, the evidence of the data supports the hypothesis that an increased mean tooth length will be observed with increased dosage with both delivery methods under TBD
3. Based on ???, the evidence of the data supports the hypothesis that an increased mean tooth length will be observed using the orange juice deliver method for the 0.5 and 1.0 mg dose levels under TBD

## Code Used for the Analysis

See the file **tooth.R** in this repo.  The code from this file was used in the R Markdown file which was knitted to created the pdf.
