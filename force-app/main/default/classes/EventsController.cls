public inherited sharing class EventsController {
    @AuraEnabled(cacheable=true)
    public static List<Hiring_Event__c> getFutureEvents() {
        Date today = Date.today();
        List<Hiring_Event__c> events= [select CreatedDate, Date__c, Panel__r.Name, Id, Name, Owner.Name from Hiring_Event__c where Date__c >= today];
        return events;

    }

    @AuraEnabled(cacheable=true)
    public static List<Hiring_Event__c> getPastEvents() {
        Date today = Date.today();
        List<Hiring_Event__c> events= [select CreatedDate, Date__c, Panel__r.Name, Id, Name, Owner.Name from Hiring_Event__c where Date__c < today];
        return events;

    }
}