# Predicting the outcome of international soccer matches
We use a multinomial logistic model to predict the outcome of international soccer matches. Everything is written in R.

## Model construction
Our dataset includes 2,565 international soccer matches played between January 2, 2022 and June 26, 2024.

We start by weighting the matches according to the date on which they took place, so that the more recent a match, the greater its weight in the model. Next, we create a weighted average of goals scored and conceded per team.

For each match, we calculate the probability of it being won by either team, as well as the probability of it being a draw. The explanatory variables are the average goals scored and conceded for each team. The model equation is therefore $\text{P}(Y = k | X) = \frac{e^{\beta_{k0} + \beta_{k1} X_1 + \beta_{k2} X_2 + \beta_{k3} X_3 + \beta_{k4} X_4}}{1 + \sum_{j=1}^{K-1} e^{\beta_{j0} + \beta_{j1} X_1 + \beta_{j2} X_2 + \beta_{j3} X_3 + \beta_{j4} X_4}}$

## Prerequisites
You will need the following dependencies:
- nnet
- pROC
- dplyr
- sqldf

## Performance insights
The macro AUC is ~0.69, which is quite respectable, considering the difficult-to-predict nature of soccer.

![heatmap_matrice_confusion](https://github.com/user-attachments/assets/ffe8cd73-7c79-463d-8b1f-d38e05c3c355)
