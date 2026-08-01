{% docs dim_produit_doc %}
## Dimension `dim_produit`

**Grain** : 1 ligne = 1 ciqual_agb.

**Source** : alimentée par `agribalyse-31-detail-par-ingredient.csv`.
{% enddocs %}
{% docs dim_ingredient_doc %}
## Dimension `dim_ingredient`

**Grain** : 1 ligne = 1 ingrédient.

**Source** : alimentée par `agribalyse-31-detail-par-ingredient.csv`.
{% enddocs %}
{% docs fct_agribalyse_doc %}
## Fact `fct_agribalyse`

**Grain** : 1 ligne = 1 ingrédient par produit.

**Source** : alimentée par `agribalyse-31-detail-par-ingredient.csv`.

**Limites assumées** :
- La somme n'aura de sens que sur les ingrédients et non pas sur les produits (cf. 3.4)
{% enddocs %}