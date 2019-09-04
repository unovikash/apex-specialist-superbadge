@isTest
public class MaintenanceRequestHelperTest {
    
    public static final Integer BULK_COUNT = 300;
    
    @testSetup static void setupTestObjects() {
        List<Vehicle__c> vehicleList = new List<Vehicle__c>();
        List<Product2> equipmentList = new List<Product2>();
        List<Work_Part__c> workPartList = new List<Work_Part__c>();
        List<Case> caseList = new List<Case>();
        
        //Bulk create EquipmentList
        for(Integer i = 0; i < BULK_COUNT; i++) {
            Product2 equipment = new Product2(
                Name = 'Equipment' + i,
                IsActive = True,
                Cost__c = 20.00,
                Current_Inventory__c = 100,
                Maintenance_Cycle__c = 60,
                Replacement_Part__c = True,
                Lifespan_Months__c = 12,
                Warehouse_SKU__c = 'EQU' + i
            );
            equipmentList.add(equipment);
        }
        insert equipmentList;
        
        //Bulk create vehicles
        for(Integer i = 0; i < BULK_COUNT; i++) {
            Vehicle__c vehicle = new Vehicle__c(Name = 'RV' + i);
            vehicleList.add(vehicle);
        }
        insert vehicleList;
        
        //Bulk create cases (maintenance requests)
        for(Integer i = 0; i < BULK_COUNT; i++) {
            Case newCase = new Case(
                type='Repair',
                status='New',
                Origin='Phone',
                Vehicle__c=vehicleList.get(i).Id,
                Equipment__c=equipmentList.get(i).Id
            );
            caseList.add(newCase);
        }
        insert caseList;
        
        //Bulk add Work Part (for 100% code coverage)
        for(Integer i = 0; i < BULK_COUNT; i++) {
            Work_Part__c part = new Work_Part__c(
                Quantity__c = 2,
                Maintenance_Request__c = caseList.get(i).Id,
                Equipment__c = equipmentList.get(i).Id
            );
            workPartList.add(part);
        }
        insert workPartList;
    }
    
    @isTest static void testCaseUpdate() {
        //Get all the tests
        List<Case> caseList = [SELECT type, status, origin, Vehicle__c, Equipment__c FROM Case];
        for (Case maintenanceRequest : caseList)
            maintenanceRequest.status='Closed';
        
        Test.startTest();
        update caseList;
        Test.stopTest();
        
        caseList = [SELECT Id, type FROM Case WHERE type='Routine Maintenance'];
        //Assert if new cases are created for all closed cases
        System.assertEquals(BULK_COUNT, caseList.size());
    }
}