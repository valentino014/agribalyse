PARKING.md : - [J141] dbt debug échoue au login Snowflake | env + squelette OK, connexion FAIL | J142 Bloc 2, 15 min max avant escalade

PARKING.md : - [J143] à regarder. hors T3 : les 27 du MINUS, les 2 et le 1, Autres étapes dans ingredients.
FInir décisions 4.15

préparer entretiens : à ouvrir au lancement de la campagne

1	Ratio score/nb_produit : double comptage ou pas ? Vérifier qu'un produit connu somme à son score publié. Le décalage de grain n'est pas le problème.
2	expr: ciqual_agb dans la mesure nb_produit : vérifier si c'est la clé naturelle ou une résolution accidentelle. Aligner ou justifier.
3	Regroupement lisible par produit — route A (dimension catégorielle sur le fait, donne 11182) ou route B (semantic model sur dim_produit, donne nom_francais). À trancher.
4	Semantic model sur dim_ingredient.
5	Colonne eau + les autres colonnes d'impact.
6	Warning --show-all.



Questions Metabase groupées sur codes, pas sur libellés. Choisir le mécanisme de jointure.


Les 3 métriques ne disent pas ce qu'elles répondent, et aucune n'a d'unité. Les trois lignes actuelles reformulent le nom de la métrique — un lecteur n'apprend rien. Format visé : nom · la question à laquelle elle répond en français · l'unité. Les unités : un compte de produits · des mPt · des mPt par produit. Ajouter « (vérification en cours, voir Limites et pistes) » sur le ratio. Vérifier aussi que les trois noms écrits ici sont exactement ceux du YAML — le README dit nb_produit_distinct, la ligne de parking dit nb_produit.

L'architecture en une ligne de texte manque toujours, juste avant le premier diagramme : CSV ADEME → stage interne → table brute → staging → dimensions et fait → couche sémantique → Metabase, avec les volumétries (1099, 287, 6161). Un lecteur pressé ne déplie pas un mermaid.

Les trois premières lignes parlent encore d'Agribalyse, pas de ton pipeline. Première phrase = un verbe + un objet : « Ce pipeline transforme … en … ». Agribalyse vient après, en deux lignes.

Stack incomplet : MetricFlow (dbt-metricflow, en local) et Metabase n'y figurent pas.

« AI in development » n'existe pas : 5 lignes tout en bas, deux sur ce que l'IA fait, deux sur ce qu'elle ne fait jamais, une sur pourquoi.

Passage de nettoyage, un seul coup : la ligne Metabase de « Limites et pistes » flotte hors de la liste (deux lignes vides à supprimer) · « (donne 11182) » à couper, personne d'autre que toi ne sait ce que c'est · .env (étape 4) et profiles.yml (étape 8) sont deux mécanismes concurrents, une ligne pour dire lequel dbt lit · « en lançant data tests » → « les data tests » · « les étapes suivante » → suivantes · « les décisions prise » → prises · exploration.md : « Script » → « Notes » · le bloc venv active maintenant les deux lignes, Linux et Windows.

Millésime : le README dit 3.2, le fichier s'appelle -31-. À vérifier contre la date de ta dimension constante. Si les deux divergent, l'un des deux ment.

Le diagramme d'architecture s'arrête à « BI » et la couche sémantique n'y est pas.