select
    creditcardid,
    cardtype,
    expyear,
    modifieddate,
    expmonth,
    cardnumber
from {{ source('sales', 'creditcard') }}
