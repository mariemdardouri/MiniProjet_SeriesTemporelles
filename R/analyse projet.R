install.packages(c("quantmod","xts","tseries",
  "forecast",
  "ggplot2",
  "FinTS",
  "moments",
  "urca"
))
library(vars)
library(rugarch)
library(quantmod)
library(xts)
library(tseries)
library(forecast)
library(ggplot2)
library(FinTS)
library(moments)
library(urca)

set.seed(42)
#telechargement des données yahoo finances
tickers <- c("AAPL", "QQQ")

AAPL_data <- getSymbols(
  "AAPL",
  src = "yahoo",
  from = "2019-01-01",
  to = "2026-10-01",
  auto.assign = FALSE
)

QQQ_data <- getSymbols(
  "QQQ",
  src = "yahoo",
  from = "2019-01-01",
  to = "2026-10-01",
  auto.assign = FALSE
)
prices <- merge(
  AAPL = Ad(AAPL_data),
  QQQ = Ad(QQQ_data)
)

volume <- merge(
  AAPL = Vo(AAPL_data),
  QQQ = Vo(QQQ_data)
)

head(prices)
tail(prices)
#EDA
#examination des dim et dates 
cat("Nombre de lignes :", NROW(prices), "\n")
cat("Nombre de colonnes :", NCOL(prices), "\n")

cat("Première date :", as.character(first(index(prices))), "\n")
cat("Dernière date :", as.character(last(index(prices))), "\n")
#verif NA
print(colSums(is.na(prices)))
print(colSums(is.na(volume)))
#verif date
cat(
  "Nombre de dates dupliquées :",
  sum(duplicated(index(prices))),
  "\n"
)

cat(
  "Dates dans l'ordre chronologique :",
  is.unsorted(index(prices), strictly = FALSE) == FALSE,
  "\n"
)
#visualiser prix
#appel
plot(
  prices[, "AAPL.Adjusted"],
  main = "Prix ajusté de AAPL",
  xlab = "Date",
  ylab = "Prix",
  col = "blue"
)
#bourse 
plot(
  prices[, "QQQ.Adjusted"],
  main = "Prix ajusté de QQQ",
  xlab = "Date",
  ylab = "Prix",
  col = "red"
)
#comparer les deux séries 
plot(
  prices[, "AAPL.Adjusted"],
  main = "Évolution des prix AAPL et QQQ",
  xlab = "Date",
  ylab = "Prix",
  col = "blue"
)

lines(prices[, "QQQ.Adjusted"], col = "red")

legend(
  "topleft",
  legend = c("AAPL", "QQQ"),
  col = c("blue", "red"),
  lty = 1
)
#2.3 rendement logarithmique
returns <- diff(log(prices))
returns <- na.omit(returns)

head(returns)
#visualisation rendement APPL
plot(
  returns[, "AAPL.Adjusted"],
  main = "Rendements logarithmiques de AAPL",
  xlab = "Date",
  ylab = "Log Return",
  col = "blue"
)
#visualiser le rendement QQQ
plot(
  returns[, "QQQ.Adjusted"],
  main = "Rendements logarithmiques de QQQ",
  xlab = "Date",
  ylab = "Log Return",
  col = "red"
)
#2.4 moyenne mobile sur 20 jours
AAPL_MA20 <- rollapply(
  prices[, "AAPL.Adjusted"],
  width = 20,
  FUN = mean,
  align = "right",
  fill = NA
)
plot(
  prices[, "AAPL.Adjusted"],
  main = "AAPL et moyenne mobile 20 jours",
  xlab = "Date",
  ylab = "Prix",
  col = "blue"
)

lines(AAPL_MA20, col = "red")

legend(
  "topleft",
  legend = c("AAPL", "Moyenne mobile 20 jours"),
  col = c("blue", "red"),
  lty = 1
)
#volatilité sur 20 jours
rolling_volatility <- rollapply(
  returns[, "AAPL.Adjusted"],
  width = 20,
  FUN = sd,
  align = "right",
  fill = NA
)
plot(
  rolling_volatility,
  main = "Volatilité glissante de AAPL - 20 jours",
  xlab = "Date",
  ylab = "Volatilité",
  col = "darkgreen"
)
#2.6 statistique descriptive
#AAPL
summary(as.numeric(returns[, "AAPL.Adjusted"]))

cat(
  "Skewness AAPL :",
  skewness(as.numeric(returns[, "AAPL.Adjusted"])),
  "\n"
)

cat(
  "Kurtosis AAPL :",
  kurtosis(as.numeric(returns[, "AAPL.Adjusted"])),
  "\n"
)
#QQQ
summary(as.numeric(returns[, "QQQ.Adjusted"]))

cat(
  "Skewness QQQ :",
  skewness(as.numeric(returns[, "QQQ.Adjusted"])),
  "\n"
)

cat(
  "Kurtosis QQQ :",
  kurtosis(as.numeric(returns[, "QQQ.Adjusted"])),
  "\n"
)
#valeur aberantes
quantile(
  as.numeric(returns[, "AAPL.Adjusted"]),
  probs = c(0, 0.25, 0.5, 0.75, 1),
  na.rm = TRUE
)

sd(as.numeric(returns[, "AAPL.Adjusted"]))
mean(as.numeric(returns[, "AAPL.Adjusted"]))
#Boxplot
boxplot(
    as.numeric(returns[, "AAPL.Adjusted"]),
    main = "Détection des valeurs extrêmes - AAPL",
    horizontal = TRUE
  )
boxplot(
  as.numeric(returns[, "QQQ.Adjusted"]),
  main = "Détection des valeurs extrêmes - QQQ",
  horizontal = TRUE
)
#Dataset Final
dataset <- merge(
  prices[, "AAPL.Adjusted"],
  prices[, "QQQ.Adjusted"],
  returns[, "AAPL.Adjusted"],
  returns[, "QQQ.Adjusted"],
  AAPL_MA20,
  rolling_volatility
)

colnames(dataset) <- c(
  "AAPL",
  "QQQ",
  "AAPL_Return",
  "QQQ_Return",
  "AAPL_MA20",
  "AAPL_Volatility20"
)

head(dataset)
str(dataset)
colSums(is.na(dataset))
#train test split
split_index <- floor(NROW(dataset) * 0.90)

train <- dataset[1:split_index, ]
test <- dataset[(split_index + 1):NROW(dataset), ]

cat("Train :", NROW(train), "\n")
cat("Test :", NROW(test), "\n")

cat(
  "Train jusqu'à :",
  as.character(last(index(train))),
  "\n"
)

cat(
  "Test à partir de :",
  as.character(first(index(test))),
  "\n"
)
# acf prix aapl
acf(
  na.omit(train[, "AAPL"]),
  lag.max = 40,
  main = "ACF - Prix AAPL"
)
#acf rendements aapl
acf(
  na.omit(train[, "AAPL_Return"]),
  lag.max = 40,
  main = "ACF - Rendements AAPL"
)
#pacf rendements aapl
pacf(
  na.omit(train[, "AAPL_Return"]),
  lag.max = 40,
  main = "PACF - Rendements AAPL"
)
#acf rendements qqq
acf(
  na.omit(train[, "QQQ_Return"]),
  lag.max = 40,
  main = "ACF - Rendements QQQ"
)
#pacf rendements qqq
pacf(
  na.omit(train[, "QQQ_Return"]),
  lag.max = 40,
  main = "PACF - Rendements QQQ"
)
#ACf du pris AAPL différencié
AAPL_diff <- diff(na.omit(train[, "AAPL"]))
AAPL_diff <- na.omit(AAPL_diff)

acf(
  as.numeric(AAPL_diff),
  lag.max = 40,
  main = "ACF - Prix AAPL différencié"
)
#pacf du prix aapl différencier 
pacf(
  as.numeric(AAPL_diff),
  lag.max = 40,
  main = "PACF - Prix AAPL différencié"
)
#test stationnaritée ADF
adf_test <- function(series, name) {
  
  result <- adf.test(
    as.numeric(na.omit(series))
  )
  
  cat("Série :", name, "\n")
  cat("ADF Statistic :", result$statistic, "\n")
  cat("p-value :", result$p.value, "\n")
  
  if (result$p.value < 0.05) {
    cat("Conclusion : série stationnaire\n\n")
  } else {
    cat("Conclusion : série non stationnaire\n\n")
  }
}
adf_test(train[, "AAPL"], "AAPL Prix")
adf_test(train[, "AAPL_Return"], "AAPL Rendement")

adf_test(train[, "QQQ"], "QQQ Prix")
adf_test(train[, "QQQ_Return"], "QQQ Rendement")
#Kpss
kpss_test <- function(series, name) {
  
  result <- kpss.test(
    as.numeric(na.omit(series)),
    null = "Level"
  )
  
  cat("Série :", name, "\n")
  cat("KPSS Statistic :", result$statistic, "\n")
  cat("p-value :", result$p.value, "\n")
  
  if (result$p.value < 0.05) {
    cat("Conclusion : série non stationnaire\n\n")
  } else {
    cat("Conclusion : série stationnaire\n\n")
  }
}
kpss_test(train[, "AAPL"], "AAPL Prix")
kpss_test(train[, "AAPL_Return"], "AAPL Rendement")

kpss_test(train[, "QQQ"], "QQQ Prix")
kpss_test(train[, "QQQ_Return"], "QQQ Rendement")
# Différenciation des prix AAPL et QQQ
AAPL_diff <- na.omit(diff(train[, "AAPL"]))
QQQ_diff <- na.omit(diff(train[, "QQQ"]))

# Tests ADF
adf.test(as.numeric(AAPL_diff))
adf.test(as.numeric(QQQ_diff))

# Tests KPSS
kpss.test(as.numeric(AAPL_diff), null = "Level")
kpss.test(as.numeric(QQQ_diff), null = "Level")
#décomposition rendements aapl
decomposition <- decompose(
  ts(
    as.numeric(na.omit(train[, "AAPL_Return"])),
    frequency = 20
  ),
  type = "additive"
)

plot(decomposition)
#evolution rendements
plot(
  train[, "AAPL_Return"],
  main = "Évolution des rendements AAPL",
  xlab = "Date",
  ylab = "Rendement"
)

abline(h = 0, lty = 2)
#evolution de la volatilité
plot(
  train[, "AAPL_Volatility20"],
  main = "Évolution de la volatilité AAPL",
  xlab = "Date",
  ylab = "Volatilité"
)
#section 3
# 3.1 ARIMA

arima_auto <- auto.arima(
  na.omit(train[, "AAPL"]),
  seasonal = FALSE,
  stepwise = TRUE,
  trace = TRUE
)

summary(arima_auto)
ordres <- as.numeric(arimaorder(arima_auto)[1:3])
cat("Ordre ARIMA choisi (p, d, q) :", ordres, "\n")
p <- ordres[1]
d <- ordres[2]
q <- ordres[3]

# auto.arima
#include.mean = FALSE.
model_arima <- arima_auto
summary(model_arima)

# Résidus
residuals_arima <- residuals(model_arima)

plot(
  residuals_arima,
  main = "Résidus du modèle ARIMA",
  xlab = "Date",
  ylab = "Résidu"
)

# Ljung-Box 
ljung_box_10 <- Box.test(
  na.omit(residuals_arima),
  lag = 10,
  type = "Ljung-Box",
  fitdf = p + q
)

ljung_box_20 <- Box.test(
  na.omit(residuals_arima),
  lag = 20,
  type = "Ljung-Box",
  fitdf = p + q
)

print(ljung_box_10)
print(ljung_box_20)

# Jarque-Bera
jb_test <- jarque.bera.test(
  na.omit(as.numeric(residuals_arima))
)

cat("Jarque-Bera statistic :", jb_test$statistic, "\n")
cat("p-value :", jb_test$p.value, "\n")

# ARCH-LM
arch_test <- ArchTest(
  na.omit(as.numeric(residuals_arima)),
  lags = 10
)

print(arch_test)

# Comparaison de plusieurs modèles ARIMA 
modele_010 <- Arima(na.omit(train[, "AAPL"]), order = c(0, 1, 0), include.drift = TRUE)
modele_110 <- Arima(na.omit(train[, "AAPL"]), order = c(1, 1, 0), include.drift = TRUE)
modele_011 <- Arima(na.omit(train[, "AAPL"]), order = c(0, 1, 1), include.drift = TRUE)
modele_111 <- Arima(na.omit(train[, "AAPL"]), order = c(1, 1, 1), include.drift = TRUE)

comparaison_arima <- data.frame(
  Modele = c("ARIMA(0,1,0)", "ARIMA(1,1,0)", "ARIMA(0,1,1)", "ARIMA(1,1,1)"),
  AIC = c(AIC(modele_010), AIC(modele_110), AIC(modele_011), AIC(modele_111)),
  BIC = c(BIC(modele_010), BIC(modele_110), BIC(modele_011), BIC(modele_111))
)

comparaison_arima <- comparaison_arima[order(comparaison_arima$AIC), ]
print(comparaison_arima)

# Arima auto
print(arima_auto)
print(arimaorder(arima_auto))

# 3.2 VAR et causalité de Granger

rendements_var <- as.matrix(
  na.omit(train[, c("AAPL_Return", "QQQ_Return")])
)

# Sélection de l'ordre
selection_var <- VARselect(rendements_var, lag.max = 10, type = "const")
print(selection_var$selection)

# estime  VAR selon l'AIC 
#  selon le BIC (SC) 
p_aic <- as.integer(selection_var$selection["AIC(n)"])
p_bic <- as.integer(selection_var$selection["SC(n)"])
cat("Ordre AIC :", p_aic, "| Ordre BIC :", p_bic, "\n")

modele_var     <- VAR(rendements_var, p = p_aic, type = "const")  # principal
modele_var_bic <- VAR(rendements_var, p = p_bic, type = "const")  # comparaison

summary(modele_var)

# Stabilité < 1
print(roots(modele_var))
print(roots(modele_var_bic))

#  Granger + causalité instantanée
granger_var <- function(m, nom) {
  cat("\n=====", nom, "=====\n")
  for (v in c("AAPL_Return", "QQQ_Return")) {
    g <- causality(m, cause = v)
    print(g$Granger)
    print(g$Instant)
  }
}

granger_var(modele_var, paste0("VAR(", p_aic, ") - AIC"))
granger_var(modele_var_bic, paste0("VAR(", p_bic, ") - BIC"))

#  Diagnostics du VAR
diag_var <- function(m, nom) {
  cat("\n=====", nom, "=====\n")
  print(serial.test(m, lags.pt = 20, type = "PT.adjusted"))
  print(arch.test(m, lags.multi = 10))
  print(normality.test(m, multivariate.only = TRUE))
}

diag_var(modele_var, paste0("VAR(", p_aic, ") - AIC"))
diag_var(modele_var_bic, paste0("VAR(", p_bic, ") - BIC"))


# Cointégration

prix_cointegration <- as.matrix(
  na.omit(train[, c("AAPL", "QQQ")])
)

# Choix de K : ordre du VAR sur les niveaux
selection_niveaux <- VARselect(prix_cointegration, lag.max = 10, type = "const")
print(selection_niveaux$selection)

# Johansen avec K = 2 
test_johansen <- ca.jo(
  prix_cointegration,
  type = "trace",
  ecdet = "const",
  K = 2,
  spec = "transitory"
)
summary(test_johansen)

# Robustesse : K = 3
test_johansen_k3 <- ca.jo(
  prix_cointegration,
  type = "trace",
  ecdet = "const",
  K = 3,
  spec = "transitory"
)
summary(test_johansen_k3)

#test de Phillips Ouliaris 
# H0 : pas de cointégration
print(po.test(prix_cointegration))

# 3.3 GARCH

rendements_aapl <- na.omit(train[, "AAPL_Return"])

# Fonction d'estimation  comparer  ordres
fit_garch <- function(ordre) {
  spec <- ugarchspec(
    variance.model = list(model = "sGARCH", garchOrder = ordre),
    mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
    distribution.model = "std"
  )
  ugarchfit(
    spec = spec,
    data = as.numeric(rendements_aapl) * 100,
    solver = "hybrid"
  )
}

modele_garch <- fit_garch(c(1, 1))
show(modele_garch)

# Critères d'information + comparaison d'ordres
print(infocriteria(modele_garch))

ordres_garch <- list(
  "GARCH(1,1)" = c(1, 1),
  "GARCH(1,2)" = c(1, 2),
  "GARCH(2,1)" = c(2, 1)
)

comparaison_garch <- do.call(rbind, lapply(names(ordres_garch), function(nm) {
  ic <- infocriteria(fit_garch(ordres_garch[[nm]]))
  data.frame(Modele = nm, AIC = ic["Akaike", 1], BIC = ic["Bayes", 1])
}))
print(comparaison_garch)

# Volatilité conditionnelle estimée
volatilite_garch <- sigma(modele_garch) / 100

plot(
  index(rendements_aapl),
  as.numeric(volatilite_garch),
  type = "l",
  main = "Volatilité conditionnelle - GARCH(1,1)",
  xlab = "Date",
  ylab = "Volatilité conditionnelle"
)

# Événements connus (dates indicatives )
abline(
  v = as.Date(c("2020-03-16", "2022-09-13", "2025-04-03")),
  col = "red", lty = 2
)
legend(
  "topright",
  legend = c("Volatilité conditionnelle", "COVID-19 / 2022 hausse des taux / 2025 droits de douane"),
  col = c("black", "red"), lty = c(1, 2), cex = 0.7
)

# Résidus standardisés
residus_std <- as.numeric(residuals(modele_garch, standardize = TRUE))

plot(
  residus_std,
  type = "l",
  main = "Résidus standardisés du GARCH",
  xlab = "Temps",
  ylab = "Résidu standardisé"
)

# QQ-plot 
plot(modele_garch, which = 9)

# Ljung-Box sur les résidus
Box.test(residus_std, lag = 10, type = "Ljung-Box")

# Ljung-Box 
Box.test(residus_std^2, lag = 10, type = "Ljung-Box")

ArchTest(residus_std, lags = 10)

saveRDS(dataset, "dataset_aapl_qqq.rds")  
sessionInfo()                              

