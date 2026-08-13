PARKING.md : - [J141] dbt debug échoue au login Snowflake | env + squelette OK, connexion FAIL | J142 Bloc 2, 15 min max avant escalade

PARKING.md : - [J143] à regarder. hors T3 : les 27 du MINUS, les 2 et le 1, Autres étapes dans ingredients.
FInir décisions 4.15

préparer entretiens : à ouvrir au lancement de la campagne

1	Ratio score/nb_produit : double comptage ou pas ? Vérifier qu'un produit connu somme à son score publié. Le décalage de grain n'est pas le problème.
2	Collision de noms ciqual_agb : entité (expr: ciqual_agb_key, un hash) et colonne physique (ciqual_agb, le code métier). Ça marche, ça se relit mal. Renommer l'entité.
3	Regroupement lisible par produit — route A (dimension catégorielle sur le fait, donne 11182) ou route B (semantic model sur dim_produit, donne nom_francais). À trancher.
4	Semantic model sur dim_ingredient.
5	Colonne eau + les autres colonnes d'impact.
6	Warning --show-all.

Questions Metabase groupées sur codes, pas sur libellés. Choisir le mécanisme de jointure.
