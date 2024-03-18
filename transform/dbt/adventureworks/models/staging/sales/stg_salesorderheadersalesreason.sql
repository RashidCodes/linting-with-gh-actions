select
    salesorderid,
    modifieddate,
    salesreasonid
from {{ source('sales', 'salesorderheadersalesreason') }}
