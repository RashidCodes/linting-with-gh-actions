select
    businessentityid,
    name,
    salespersonid,
    modifieddate
from {{ source('sales', 'store') }}
