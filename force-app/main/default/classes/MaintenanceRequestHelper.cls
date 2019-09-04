public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> requests){
        System.debug('Maintenance Request Trigger Helper Called');
        
        //Get all the Minimums for the Work Parts involved in the Maintenance Request
        List<AggregateResult> arList = [
            SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)
            FROM Work_Part__c
            WHERE Maintenance_Request__c IN :requests
            GROUP BY Maintenance_Request__c
        ];
        System.debug('Number of aggregated results: ' + arList.size());
        Map<Id, Integer> requestToMin = new Map<Id, Integer>();
        for (AggregateResult ar : arList) {
            requestToMin.put(
            	(Id)ar.get('Maintenance_Request__c'),
                Integer.valueOf(ar.get('expr0'))
            );
        }
        
        List<Case> newRequests = new List<Case>();
        for(Case request: requests){
            //If the maintenance request suffices the criteria
            if((request.type == 'Repair' || request.type == 'Routine Maintenance') && request.Status == 'Closed') {
                System.debug('New Repair/Maintenance Request Closed');
                Case newRequest = new Case(
                	Type='Routine Maintenance',
                    Vehicle__c=request.Vehicle__c,
                    Equipment__c=request.Equipment__c,
                    Origin=request.Origin,
                    Subject=(String.isBlank(request.Subject)?'Routine Maintenance':request.Subject),
                    Date_Reported__c=Date.today(),
                    Date_Due__c = (requestToMin.containsKey(request.Id) ? Date.today().addDays(requestToMin.get(request.Id)) : Date.today().addDays(30))
                );
                newRequests.add(newRequest);
                System.debug('New Request: ' + newRequest.Subject + '; Date Due: ' + newRequest.Date_Due__c);
            }
        }
        if(!newRequests.isEmpty())
        	insert newRequests;
    }        
}