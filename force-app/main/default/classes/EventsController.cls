public inherited sharing class EventsController {
    @AuraEnabled(cacheable=true)
    public static List<Hiring_Event__c> getFutureEvents() {
        List<Hiring_Event__c> events= [select CreatedDate, Date__c, Panel__c, Id, Name, OwnerId from Hiring_Event__c];
        return events;

    }
}