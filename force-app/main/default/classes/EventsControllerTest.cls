@isTest
public class EventsControllerTest {
    public EventsControllerTest() {

    }
    @TestSetup
    static void makeData(){
        Panel__c panel = new Panel__c(Name = 'New Panel');
        insert panel;
        Hiring_Event__c he = new Hiring_Event__c(Panel__c = panel.Id,   Date__c =  Date.today());
        insert he;
        he = new Hiring_Event__c(Panel__c = panel.Id,   Date__c =  Date.today().addDays(-2));
        insert he;
    }

    @isTest
    static void getFutureEventsTest()
    {
        try{
            EventsController.getFutureEvents();
        }
        catch(Exception ex){}
    }

    @isTest
    static void getPastEventsTest()
    {
        try{
            EventsController.getPastEvents();
        }catch(Exception ex){}
    }

}