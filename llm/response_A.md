**Remarque préalable.** Toutes les justifications ci-dessous reposent sur vos chiffres. Les valeurs que j'ai **calculées moi-même** à partir d'eux sont marquées *(dérivé)* : à recalculer de votre côté.

## A. Hypothèses classiques

**H1 — Les prix sont intégrés d'ordre 1 : modéliser les différences / rendements (d = 1).**
- Justification : ADF ne rejette pas la racine unitaire sur les prix (p = 0.8388 pour AAPL, p = 0.9591 pour QQQ) et KPSS rejette la stationnarité (statistiques 5.9976 et 5.4912, p = 0.01). C'est l'inverse sur les rendements (ADF p = 2.2e-25 et 1.1e-24 ; KPSS 0.2135 et 0.0903, p = 0.10). Les deux tests, d'hypothèses nulles opposées, convergent.
- Test : relancer ADF/KPSS avec constante puis constante + tendance ; contrôler le nombre de retards de l'ADF.
- Risque : ces tests ont une puissance limitée face à des ruptures (mars 2020) ; « d = 1 » est une approximation de travail, pas une preuve d'une racine unitaire exacte.

**H2 — Référence à battre : marche aléatoire, ARIMA(0,1,0).**
- Justification : l'ACF des prix décroît très lentement (≈ 0.88 au lag 40, signature d'une racine unitaire) et celle des rendements est faible (|ρ₁| ≤ 0.13).
- Test : Ljung-Box sur les résidus ; comparaison AIC/BIC avec ARIMA(1,1,0) et (0,1,1).
- Risque : si aucun modèle ne bat cette référence, ce n'est pas un échec mais le résultat attendu sur un actif liquide.
- Dérive : t ≈ 2.57 (AAPL) et ≈ 2.42 (QQQ) *(dérivé, calculé comme si les rendements étaient i.i.d.)* → inclure une constante dans les modèles de moyenne. Ce t est probablement surestimé car il ignore les queues épaisses et le regroupement de volatilité.

**H3 — Faible structure linéaire de court terme dans les rendements (AR d'ordre faible).**
- Justification : ρ₁ ≈ -0.08 (AAPL) et ≈ -0.13 (QQQ) sortent de la bande ±1.96/√1752 ≈ ±0.047 *(dérivé)*. Mais le R² associé est ≈ ρ² ≈ 0.64 % et ≈ 1.69 % *(dérivé)*.
- Test : ACF/PACF numériques, Ljung-Box, AIC/BIC d'AR(1), AR(2), ARMA(1,1).
- Risque : significatif ne veut pas dire exploitable (coûts de transaction) ; les pics aux lags 7-9 peuvent être des faux positifs (beaucoup de lags testés simultanément).

**H4 — Dépendance AAPL–QQQ : VAR sur les rendements + causalité de Granger.**
- Justification : le rapport des écarts-types est 1.28 *(dérivé)* et les deux séries ont des asymétries et kurtosis de même signe/ordre de grandeur. La corrélation n'est pas fournie : l'hypothèse est plausible mais non vérifiable ici.
- Test : sélection de l'ordre par AIC/BIC, stabilité, test de Granger dans les deux sens.
- Risque : une forte corrélation simultanée n'implique pas de prédictibilité décalée ; AIC et BIC choisissent souvent des ordres très différents.

**H5 — Cointégration des log-prix (Engle-Granger / Johansen).**
- Justification : condition nécessaire remplie si les deux séries sont I(1) (H1). Elle n'est pas suffisante, et vos données ne disent rien d'une relation de long terme. AAPL est une composante de QQQ (connaissance générale, **pas** issue de vos données).
- Test : Johansen (trace, constante dans la relation) ; si rejet de H0 seulement, estimer un VECM.
- Risque : la cointégration est souvent absente entre un titre et son indice sur 7 ans ; ne pas forcer un VECM.

## B. Volatilité et distribution

**H6 — Hétéroscédasticité conditionnelle : GARCH(1,1).**
- Justification : volatilité glissante entre ≈ 0.006 et ≈ 0.068, soit un facteur ≈ 11 *(dérivé)*, avec regroupements ; kurtosis en excès 6.5079 et 7.2799.
- Test : ARCH-LM sur les résidus du modèle de moyenne, puis sur les résidus standardisés ; Ljung-Box sur les carrés.
- Risque : un GARCH(1,1) gaussien sous-estime les queues.

**H7 — Innovations à queues épaisses (loi de Student).**
- Justification : pour une loi t i.i.d., kurtosis en excès = 6/(ν − 4), d'où ν ≈ 4.9 (AAPL) et ≈ 4.8 (QQQ) *(dérivé)*.
- Test : Jarque-Bera et QQ-plot des résidus standardisés ; estimer ν par maximum de vraisemblance ; comparer AIC/BIC gaussien vs Student.
- Risque : le kurtosis inconditionnel mélange regroupement de volatilité et vraies queues épaisses, donc ν conditionnel est en général plus grand ; il dépend aussi de 2-3 jours extrêmes (-0.138 et +0.143).

**H8 — Asymétrie (GJR-GARCH / EGARCH), surtout pour QQQ.**
- Justification : skewness -0.3657 (QQQ) contre -0.1201 (AAPL) ; médianes supérieures aux moyennes (0.001404 > 0.000828 ; 0.001301 > 0.001123).
- Test : test de biais de signe d'Engle-Ng ; significativité du paramètre d'asymétrie.
- Risque : une skewness inconditionnelle ne prouve pas un effet de levier ; pour AAPL l'indice est faible.

## C. Modèles neuronaux

**H9 — LSTM/GRU sur les rendements (stationnaires d'après H1), fenêtre ≥ 10 jours** (pics aux lags 7-9), entrées : rendements AAPL et QQQ + volatilité glissante 20 j.
- Test : validation walk-forward ; comparaison à la prévision naïve (rendement 0) ; test de Diebold-Mariano.
- Risque : si le R² linéaire plausible est ≤ 2 % (H3), le gain attendu est très faible ; avec ~1750 observations le surapprentissage est le danger principal.

**H10 — Hybride : sortie d'un GARCH comme variable d'entrée du réseau.**
- Test : étude d'ablation avec / sans la variable GARCH, mêmes hyper-paramètres.
- Risque : fuite d'information si la volatilité utilisée à la date t contient de l'information sur t+1 : bien décaler les séries.

**H11 — Pas de SARIMA a priori** : aucune donnée fournie n'indique de saisonnalité. À ne tester (jour de la semaine, lags 5 et 21) que si l'ACF numérique le suggère.

## Informations manquantes
Corrélation AAPL–QQQ ; valeurs numériques de l'ACF/PACF ; test de normalité sur les rendements ; test ARCH ; spécification déterministe et nombre de retards de l'ADF ; volumes ; composition de QQQ ; régime de marché de la période de test.

## Trois limites de mon analyse
1. Les statistiques descriptives semblent calculées sur l'échantillon complet (test inclus) : risque de regard vers l'avenir si elles guident le choix des modèles.
2. Les lectures graphiques (ACF, volatilité) sont approximatives.
3. Mes ν, R² et t-stats sont des approximations simples (dérivées) qui ne remplacent pas une estimation par maximum de vraisemblance ni des erreurs-types robustes.