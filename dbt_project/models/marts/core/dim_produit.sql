--1 ligne = 1 produit
with stg as (
    select 
        distinct ciqual_agb,
        nom_francais,
        lci_name,
        sous_groupe_daliment,
        groupe_daliment
    from {{ ref('stg_agribalyse_detail_par_ingredient') }}
),
add_surrogate_key as (
	select
		*,
        {{ dbt_utils.generate_surrogate_key(['ciqual_agb']) }} as ciqual_agb_key
	from
        stg
)
select *
from add_surrogate_key