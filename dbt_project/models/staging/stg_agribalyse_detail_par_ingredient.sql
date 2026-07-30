with renamed as (
    select 
        ciqual_agb,
        ciqual_code,
        nom_francais,
        groupe_daliment,
        sous_groupe_daliment,
        lci_name,
        ingredients,
        score_unique_ef                              as score_unique_ef_mpt_par_kg_produit,
        changement_climatique                        as changement_climatique_kg_co2_eq_par_kg_produit,
        appauvrissement_couche_dozone                as appauvrissement_couche_dozone_kg_cvc11_eq_par_kg_produit,
        rayonnements_ionisants                       as rayonnements_ionisants_kbq_u235_eq_par_kg_produit,
        formation_photochimique_dozone               as formation_photochimique_dozone_kg_nmvoc_eq_par_kg_produit,
        particules_fines                             as particules_fines_disease_inc_par_kg_produit,
        effets_toxico_sante_humaine_non_cancerogene  as effets_toxico_sante_humaine_non_cancerogene_ctuh_par_kg_produit,
        effets_toxico_sante_humaine_cancerogene      as effets_toxico_sante_humaine_cancerogene_ctuh_par_kg_produit,
        acidification_terrestre_eaux_douces          as acidification_terrestre_eaux_douces_mol_h_eq_par_kg_produit,
        eutrophisation_eaux_douces                   as eutrophisation_eaux_douces_kg_p_eq_par_kg_produit,
        eutrophisation_marine                        as eutrophisation_marine_kg_n_eq_par_kg_produit,
        eutrophisation_terrestre                     as eutrophisation_terrestre_mol_n_eq_par_kg_produit,
        ecotoxicite_ecosystemes_aquatiques_eau_douce as ecotoxicite_ecosystemes_aquatiques_eau_douce_ctue_par_kg_produit,
        utilisation_du_sol                           as utilisation_du_sol_pt_par_kg_produit,
        epuisement_ressources_eau                    as epuisement_ressources_eau_m3_depriv_par_kg_produit,
        epuisement_ressources_energetiques           as epuisement_ressources_energetiques_mj_par_kg_produit,
        epuisement_ressources_mineraux               as epuisement_ressources_mineraux_kg_sb_eq_par_kg_produit
    from {{ source('ademe', 'agribalyse_detail_par_ingredient') }} 
),
add_surrogate_key as (
	select
		*,
        {{ dbt_utils.generate_surrogate_key(['ciqual_agb', 'ingredients']) }} as agb_ingredients_key
	from
        renamed
)
select *
from add_surrogate_key