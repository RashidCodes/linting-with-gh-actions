select
    productsubcategoryid,
    productcategoryid,
    name,
    modifieddate
from {{ source('production', 'productsubcategory') }}
