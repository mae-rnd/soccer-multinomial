library(nnet)
library(pROC)
model<-multinom(outcome ~ scored_home+scored_away+conceded_home+conceded_away, data = matches)
summary(model)
probs <- predict(model, type = "probs")
calculate_p_values <- function(model) {
  coef_estimates <- coef(model)
  std_errors <- sqrt(diag(vcov(model)))
  z_values <- coef_estimates / std_errors
  p_values <- 2 * (1 - pnorm(abs(z_values)))
  return(data.frame(coefficients = coef_estimates, StdErrors = std_errors, Zvalues = z_values, Pvalues = p_values))
}
p_values <- calculate_p_values(model)
predictions <- predict(model, newdata = matches)
confusion_matrix <- table(matches$outcome, predictions)
proba <- predict(model, newdata = matches, type = "prob")
matches$prob_0 <- proba[, "0"]
matches$prob_1 <- proba[, "1"]
matches$prob_2 <- proba[, "2"]
auc_0 <- multiclass.roc(response = matches$outcome, predictor = matches$prob_0)
auc_1 <- multiclass.roc(response = matches$outcome, predictor = matches$prob_1)
auc_2 <- multiclass.roc(response = matches$outcome, predictor = matches$prob_2)