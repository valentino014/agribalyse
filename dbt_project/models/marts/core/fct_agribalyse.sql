
SELECT 
    stg.ciqual_agb,
    stg.ingredients,
    dim_p.ciqual_agb_key,
    dim_i.ingredient_key,
    score_unique_ef_mpt_par_kg_produit,
    changement_climatique_kg_co2_eq_par_kg_produit,
    appauvrissement_couche_dozone_kg_cvc11_eq_par_kg_produit,
    rayonnements_ionisants_kbq_u235_eq_par_kg_produit,
    formation_photochimique_dozone_kg_nmvoc_eq_par_kg_produit,
    particules_fines_disease_inc_par_kg_produit,
    effets_toxico_sante_humaine_non_cancerogene_ctuh_par_kg_produit,
    effets_toxico_sante_humaine_cancerogene_ctuh_par_kg_produit,
    acidification_terrestre_eaux_douces_mol_h_eq_par_kg_produit,
    eutrophisation_eaux_douces_kg_p_eq_par_kg_produit,
    eutrophisation_marine_kg_n_eq_par_kg_produit,
    eutrophisation_terrestre_mol_n_eq_par_kg_produit,
    ecotoxicite_ecosystemes_aquatiques_eau_douce_ctue_par_kg_produit,
    utilisation_du_sol_pt_par_kg_produit,
    epuisement_ressources_eau_m3_depriv_par_kg_produit,
    epuisement_ressources_energetiques_mj_par_kg_produit,
    epuisement_ressources_mineraux_kg_sb_eq_par_kg_produit
FROM {{ ref('stg_agribalyse_detail_par_ingredient') }} stg
left join {{ ref('dim_produit') }} dim_p on dim_p.ciqual_agb = stg.ciqual_agb
left join {{ ref('dim_ingredient') }} dim_i on dim_i.ingredients = stg.ingredients