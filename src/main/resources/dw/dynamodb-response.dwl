%dw 2.0
output application/json 
import update from dw::util::Values
import filterTree from dw::util::Tree
fun removeDynamodbKeys(data) = do {
    var dynamodbKeys = ["l", "m", "n", "s", "bool"] // add the keys you want to remove
    var dynamodbKeyUpdate = "unrepeatableKey" // change this name if this key is indeed repeated within your input
    fun removeDynamodbKeysRec(value) = value match {
        case obj is Object -> do {
            var finalObj = obj mapObject ((value, key) -> 
                if (dynamodbKeys contains (key as String))
                    (dynamodbKeyUpdate): removeDynamodbKeysRec(value)
                else
                    (key): removeDynamodbKeysRec(value)
            )
            ---
            finalObj[dynamodbKeyUpdate] default finalObj
        }
        case arr is Array -> arr map removeDynamodbKeysRec($)
        else -> value
    }
    ---
    data filterTree ($ != null) 
    then removeDynamodbKeysRec($)
}
fun flattenObject(data:Any, result={}) = (
    data match {
        case is Object -> data mapObject ((value, key) ->
            value match {
                case is Object -> flattenObject(value, result)
                else -> flattenObject(value, result ++ {(key):value})
            }
        )
        case is Array -> flattenObject(data[0]) // only first item from array will be taken
        else -> result
    }
)
---
data: (removeDynamodbKeys(payload.items) as Array) map do {
    var updatedAddressesObj = ($ update {
        case a at .addresses -> a filter $.main
    })
    var obj = flattenObject(updatedAddressesObj)
    ---
    {
        id: obj.id as Number,
        first_name: obj.firstName,
        last_name: obj.lastName,
        email: obj.email,
        street: obj.street,
        city: obj.city,
        state: upper(obj.state)[0 to 1],
        postalCode: obj.postalCode,
        lat: obj.lat as Number,
        lng: obj.lng as Number
    }
}