@isTest
public class WarehouseSyncScheduleTest {

    @isTest static void testScheduledJob(){
        
        // Setting up Mock for the test
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
            String CRON_EXP = '0 0 1 * * ? *';
            WarehouseSyncSchedule sch = new WarehouseSyncSchedule();
            String jobId = System.Schedule('Test Scheduler', CRON_EXP, sch);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name
    						FROM CronTrigger ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('CRON JOB NAME: ' + ct.CronJobDetail.Name);
        System.assertEquals(jobId, ct.Id);
    }    
}