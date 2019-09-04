public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug('RESPONSE -');
        System.debug(response.getBody());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            
            List<Object> equipments = (List<Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('DESERIAZED RESPONSE -');
        	System.debug(equipments);
            List<Product2> products = new List<Product2>();
            
            // Deserializes the JSON string into collections of primitive data types.
            for(Object equipmentJson : equipments) {
                Map<String, Object> equipmentMap = (Map<String, Object>)equipmentJson;
                System.debug('EQUIPMENT MAP -');
        		System.debug(equipmentMap);
                Product2 equipment = new Product2(
                    Replacement_Part__c = (Boolean)equipmentMap.get('replacement'),
                    Current_Inventory__c = (Integer)equipmentMap.get('quantity'),
                    Name = (String)equipmentMap.get('name'),
                    Maintenance_Cycle__c = (Integer)equipmentMap.get('maintenanceperiod'),
                    Lifespan_Months__c = (Integer)equipmentMap.get('lifespan'),
                    Cost__c = (Decimal)equipmentMap.get('cost'),
                    Warehouse_SKU__c = (String)equipmentMap.get('sku')
                );
                products.add(equipment);
            }
            
            if(products.size()>0)
                upsert products;
        }
    }

}