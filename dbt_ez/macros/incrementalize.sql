{%%}

{% macro incrementalize(
        source_relation,
        timestamp_col,
        sql_where=none,
        window=none,
        in_union=False,
        alias=alias
    )
%}

select
    *
{%- if in_union %}
    ,
    '{{ source_relation.table }}' as source_table,
    '{{ source_relation.schema }}' as source_schema
{%- endif %}

from
    {{ source_relation }}
where
    true
{%- if sql_where is not none %}
and
    {{ sql_where }}

{%- endif %}

{% if is_incremental() %}

and
    {{ timestamp_col }} >
    (
        select
        {%- if window is not none%}
            {{ dbt_utils.dateadd(datepart='day', interval=window, from_date_or_timestamp=max(timestamp_col)) }}
        {%- else %}
            max({{ timestamp_col }})
        {%- endif %}
        from
            {{ this }}
        {%- if in_union %}
        where
            source_table = '{source_relation.table}'
        and
            source_schema = '{source_relation.schema}'
        {%- endif %}
    )
{%- endif %}

{%- endmacro %}