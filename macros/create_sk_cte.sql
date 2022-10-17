{% macro create_sk_cte(
        source_cte,
        columns,
        sk_name
    )
%}

create_sk as (

    select
        {{ dbt_utils.surrogate_key(columns)}} as {{ sk_name }},
        *
    from
        {{ source_cte }}
)

select * from create_sk

{% endmacro %}
