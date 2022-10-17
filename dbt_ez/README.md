# dbt Macros

Macros are functions that output compiled SQL. They are a very useful tool for simplifying and abstracting SQL code. Please add docs and instructions to this markdown when you build a new macro. Proper documentation is critical to ensuring code can be repurposed.

In your documentation, please include the following:

- macro name
- description of what it does
- args and what they do 
- example usage
- example compiled SQL (output)

And of course, thank you for your contribution!

P.S. *Macro Best Practice* - Macros are most useful when they are generalized and can apply to multiple data models (similar to python programming paradigms). If your macro only works for one data model, it might be better for that jinja logic to live in the model instead. Or you can add args to make the macro more flexible.
****************

### create_sk_cte \([source](https://github.com/SYRGAPP/dbt_dev/blob/main/macros/create_sk_cte.sql)\)

*description*: This macro is a wrapper for "create_sk" ctes. The output is a cte that will create a unique sk (using `dbt_utils.surrogate_key` macro) for your data model, which is a critical [best practice](https://www.notion.so/Data-Modeling-Best-Practices-541e3f120bb442b7899fdffe4a72d6f6#17d17065d487471693269e52e64b28cd) for defining and ensuring model uniqueness.

#### args
- *source_cte* (str):  the cte in your model that contains all the final output data.
- *columns* (list): one or more columns in the `source_cte` that define model uniqueness
- *sk_name* (str): alias for the model sk

#### example usage
```
final_data_cte as (
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
        columns=['order_id', 'sales_id],
        sk_name='sales_order_sk')
}}
```

#### example output:
```
    final_data_cte as (
    select
        *
    from
        orders o
    join
        sales s on o.order_id = s.order_id
),

create_sk as (

select
    {{ dbt_utils.surrogate_key(['order_id', 'sales_id])}} as sales_order_sk,
    *
from
    final_data_cte
)

select * from create_sk
```

### incrementalize ([source](https://github.com/SYRGAPP/dbt_dev/blob/main/macros/incrementalize.sql)\)
    
    *description*: This Macro makes it easier to implement incremental models by automatically compiling the timestamp filter logic for incremental runs.

#### args

    - *source_relation* (str): Any relation, source, ref, or cte. The relation must at the very least have some timestamp column. 

    - *timestamp_col* (str) The name of the column that will be determining the time increments. Ideally this column is the timestamp from when the record was loaded into your data warehouse.

    - *sql_where*  (str, default=none): If source data needs to be filtered, pass in a string containing the column and the condition.  e.g. `location='New York'`.

    - *window*  (int, default=none): If your `timestamp_col` is not the timestamp for when that record is loaded into your data warehouse,  configure your increment window to look back n days to capture late-arriving data. Pass in this arg as a negative integer.

    - *in_union* (bool, default=False): If the data is to be unioned with other incremental data, set this to `True` and the macro will make sure to define increment windows for each source of the union.

#### example usage:
```
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
```

### parse_mailgun_events ([source](https://github.com/SYRGAPP/dbt_dev/blob/main/macros/parse_mailgun_events.sql)\)
    *description*: Parses values out of JSON data from mailgun events.

#### args

    - *source_data*: CTE name of data containing mailgun data. Must be in format as ingested by Fivetran into Snowflake.
### not_fivetran_deleted

*description*: use instead of `source` macro to remove automatically filter our deleted records from fivetran.

#### example usage:

```
with source as (

    select * from {{ not_fivetran_deleted('prod', 'stores') }}
    -- if more filters use and
    and created_at > '2022-01-01'
),

select * from source

```
