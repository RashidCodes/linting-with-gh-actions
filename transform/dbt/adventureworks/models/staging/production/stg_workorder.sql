select
    workorderid,
    productid,
    orderqty,
    scrappedqty,
    startdate,
    enddate,
    duedate,
    scrapreasonid,
    modifieddate
from {{ source('production', 'workorder') }}
