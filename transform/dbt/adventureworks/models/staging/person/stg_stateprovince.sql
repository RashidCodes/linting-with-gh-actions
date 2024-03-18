select
    stateprovinceid,
    countryregioncode,
    modifieddate,
    rowguid,
    name as state_name,
    territoryid,
    isonlystateprovinceflag,
    stateprovincecode
from {{ source('person', 'stateprovince') }}
