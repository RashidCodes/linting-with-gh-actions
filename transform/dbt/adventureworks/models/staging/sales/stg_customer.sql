select
    customerid,
    personid,
    storeid,
    territoryid
from {{ source('sales', 'customer') }}
