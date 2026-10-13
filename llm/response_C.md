
## Limites et risques

1. Les prévisions sont incertaines et peuvent être erronées.
2. Les performances historiques ne garantissent pas les performances futures.
3. Le test de Diebold-Mariano doit être examiné avant de déclarer un modèle
   supérieur à la marche aléatoire.
4. La volatilité varie dans le temps et peut rester élevée.
5. Les rendements peuvent présenter des valeurs extrêmes non bien décrites
   par une loi normale.
6. La relation prédictive entre AAPL et QQQ peut évoluer.
7. Les frais de transaction et la fiscalité ne sont pas nécessairement inclus.
8. Les recommandations dépendent du capital, de l'horizon et de la tolérance
   au risque, informations qui ne sont pas fournies.

## Trois scénarios d'investissement simulés

### Scénario 1 — Attente prudente
- Position : aucune nouvelle position dans la simulation.
- Taille relative : 0 % de nouvelle exposition.
- Horizon : attendre la prochaine évaluation.
- Condition d'arrêt : réexaminer le scénario à la prochaine évaluation.
- Justification : aucun modèle ne doit être considéré comme fiable sans
  examiner ses résultats de test et son avantage face à la référence.

### Scénario 2 — Exposition acheteuse expérimentale
- Position : simuler une petite position acheteuse sur AAPL.
- Taille relative : faible, à définir dans le cadre pédagogique.
- Horizon : un jour de bourse.
- Condition d'arrêt : clôturer ou réévaluer la simulation à la fin de
  l'horizon prévu.
- Justification : utiliser la prévision J+1 du modèle retenu, en tenant
  compte de son RMSE, de son taux directionnel et de son verdict statistique.

### Scénario 3 — Simulation avec surveillance du risque
- Position : simuler une exposition limitée à AAPL.
- Taille relative : limitée par une règle de risque définie à l'avance.
- Horizon : dix jours pour observer l'évolution de la volatilité.
- Condition d'arrêt : réévaluer la simulation si les observations réelles
  s'écartent des hypothèses du modèle.
- Justification : utiliser les prévisions de volatilité GARCH sur dix jours,
  sans les considérer comme certaines.

## Conclusion

Ces scénarios sont uniquement pédagogiques et ne constituent pas des
conseils financiers. Les prévisions, la volatilité et les performances
passées ne garantissent aucun gain futur. Les tailles de position proposées
ne sont pas optimisées à partir des données disponibles.
