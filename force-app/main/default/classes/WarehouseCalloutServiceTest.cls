@isTest
private class WarehouseCalloutServiceTest {
  	// implement your mock callout test here
    @isTest static void testWarehouseCallout(){
        
        /*Salesforce has provided a framework to force asynchronous code to execute synchronously for testing: We enclose our test code between 
         * Test.startTest() and Test.stopTest(). The system collects all asynchronous calls made after startTest(). When stopTest() is executed, 
         * these collected asynchronous processes are then run synchronously and complete before control returns to our code.
         */
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        List<Product2> equipUpserted = [SELECT Replacement_Part__c, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Name 
                                           FROM Product2];
        //Assertions to check the response
        System.debug(equipUpserted.size());
        System.assertEquals(22, equipUpserted.size());
        for (Product2 equipment : equipUpserted) {
            System.assert(equipment.Cost__c != null);
            System.assert(equipment.Current_Inventory__c != null);
            System.assert(equipment.Lifespan_Months__c != null);
            System.assert(equipment.Name != null);
        }
    }
}