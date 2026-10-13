
## Explication des résultats à un décideur non statisticien

### 1. Ce que nous avons fait

Nous avons étudié les prix journaliers d'Apple (AAPL) et de l'ETF QQQ,
qui suit le Nasdaq-100. Plusieurs modèles statistiques et réseaux de
neurones ont été comparés sur une période d'apprentissage et une période
de test. La marche aléatoire sert de référence : elle suppose que le
meilleur prix prévu pour demain est le prix d'aujourd'hui.

### 2. Ce que nous avons découvert

Les tests indiquent que les prix d'AAPL ne sont pas stationnaires,
contrairement à ses rendements journaliers. Le modèle GARCH montre que
la volatilité varie dans le temps et que les périodes agitées peuvent
persister.

Le test de Granger indique que les valeurs passées de QQQ apportent une
information utile pour prévoir AAPL, mais pas l'inverse. Cela ne démontre
pas une causalité économique.

Le test de cointégration ne détecte pas de relation d'équilibre de long
terme entre les deux actifs.

### 3. Ce que les modèles savent et ne savent pas faire

Les modèles peuvent identifier des régularités historiques et estimer
la volatilité. Cependant, leurs performances doivent être évaluées sur
les données de test. Un faible RMSE ne garantit pas une stratégie rentable.

### 4. Ce qu'il ne faut pas conclure

Il ne faut pas conclure qu'un modèle est supérieur sans vérifier les
résultats du test de Diebold-Mariano. Il ne faut pas non plus confondre
prédiction et causalité, ni supposer que les tendances historiques
continueront à l'avenir.

Les prévisions restent incertaines et ne garantissent aucun rendement.
