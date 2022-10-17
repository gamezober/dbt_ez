
with sales as (
    {{ 
        incrementalize(
        source_relation=ref('sales'),
        timestamp_col='created_at',
        window=-1,
        in_union=True
        )
    }}
    ),
    order as (
    {{ 
        incrementalize(
        source_relation=ref('orders'),
        timestamp_col='created_at',
        window=-1,
        in_union=True
        )
    }}
    )