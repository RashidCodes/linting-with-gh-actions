select
    salesreasonid,
    name,
    reasontype,
    modifieddate
from {{ source('sales', 'salesreason') }}
