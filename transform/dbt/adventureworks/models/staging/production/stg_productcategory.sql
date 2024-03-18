select
    productcategoryid,
    name,
    modifieddate
from {{ source('production', 'productcategory') }}
