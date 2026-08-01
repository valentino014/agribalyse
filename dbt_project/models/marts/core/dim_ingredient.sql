--1 ligne = 1 ingrédient
with stg as (
select 
    distinct ingredients
from {{ ref('stg_agribalyse_detail_par_ingredient') }}
),
add_surrogate_key as (
	select
		*,
        {{ dbt_utils.generate_surrogate_key(['ingredients']) }} as ingredient_key
	from
        stg
)
select *
from add_surrogate_key