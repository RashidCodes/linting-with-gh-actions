select
    businessentityid,
    title,
    firstname,
    middlename,
    lastname,
    persontype,
    namestyle,
    suffix,
    modifieddate,
    rowguid,
    emailpromotion
from {{ source('person', 'person') }}
