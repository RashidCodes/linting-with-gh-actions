select
    scrapreasonid,
    name
from {{ source('production', 'scrapreason') }}
