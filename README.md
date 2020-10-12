# chase-spatial-temporal
This report aims to use the universal kriging method by choosing an adequate spatio-temporal variogram to predict money deposits at unobserved locations in Ohio state for each year from 2010 to 2016 from data observed at 264 known sites.

## Table of contents
* [General info](#general-info)
* [Results](#results)

## General info
The data used in this report relates to the number of money deposits in each Chase branches in Ohio state. Theses yearly data is obtained from the Summary of Deposits originated from https://www.fdic.gov. The Summary of Deposits is the annual survey of each branch office deposits of all institutions that are insured by Federal Deposit Insurance Corporation (FDIC).
The data set consists of one variable that is yearly money deposits (deposits) in thousands of dollars ($000) at 264 Chase branches in Ohio state (between 38oN-42oN and 81oW-85oW), recorded between the years 2010 and 2016. These data are changed with time (yearly) and irregular in space. The data are complete with no missing value. Still, the branches themselves are not located everywhere in Ohio; therefore, if Chase has knowledge about the number of money deposits in the whole area, they can consider where to open the next locations.

## Results
Chase bank locations in Ohio state as of 2016.
![ohmap](https://user-images.githubusercontent.com/56982400/95799097-9b615200-0cc1-11eb-9089-d2f549aa3648.png)

The deposits range from 1 million to 827 million. By taking the logarithm of the data, the number of deposits is more interpretable. This is the money deposits (in $000) from the Chase bank data set for each year from 2010 to 2016, plotted on a log scale.
![logDepositsPlot](https://user-images.githubusercontent.com/56982400/95799119-b7fd8a00-0cc1-11eb-8975-1713dc21623b.png)

Spatio-temporal universal kriging predictions of deposits (log $000) within a rectangle lat-lon box enclosing the domain of interest for 7 years from 2010 to 2016.
![predictions](https://user-images.githubusercontent.com/56982400/95799197-ee3b0980-0cc1-11eb-9108-c1756e5869ef.png)

Prediction standard errors of deposits (log $000) within a rectangle lat-lon box enclosing the domain of interest for 7 years from 2010 to 2016.
![error](https://user-images.githubusercontent.com/56982400/95799210-f72bdb00-0cc1-11eb-85ec-262d519bb63f.png)

