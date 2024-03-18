select
    countryregioncode,
    modifieddate,
    name as country_name
from {{ source('person', 'countryregion') }}
