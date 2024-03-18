select
    salesorderid,
    orderqty,
    salesorderdetailid,
    unitprice,
    specialofferid,
    modifieddate,
    rowguid,
    productid,
    unitpricediscount
from {{ source('sales', 'salesorderdetail') }}
