with final_data_cte as (
    select
        *
    from
        orders o
    join
        sales s on o.order_id = s.order_id
),

{{
    create_sk_cte(
        source_cte='final_data_cte',
        columns=['order_id', 'sales_id'],
        sk_name='sales_order_sk')
}}