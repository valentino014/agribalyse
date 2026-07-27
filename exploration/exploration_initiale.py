"""
Script d'exploration des données AGRIBALYSE.
Sert à justifier les choix de modélisation documentés dans le DECISIONS.md.

Usage : python exploration/explore.py
Sortie : exploration/cardinalite.csv
"""
import pandas as pd

def explore(filepath):
    df = pd.read_csv(filepath, low_memory=False)
    print("Shape:", df.shape)
    print("\nColonnes:", df.columns.tolist())
    print("\nCardinalité -> exploration/cardinalite.csv")
    df.nunique().sort_values().to_csv(
        'exploration/cardinalite.csv', header=['n_distinct']
    )
    print("\nTaux de NULL (%) :")
    with pd.option_context('display.max_rows', None):
        print((df.isnull().sum() / len(df) * 100).sort_values(ascending=False))

    return df


if __name__ == "__main__":
    df = explore("data/agribalyse-31-detail-par-ingredient.csv")