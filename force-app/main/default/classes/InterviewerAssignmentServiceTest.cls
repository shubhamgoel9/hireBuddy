@isTest
public class InterviewerAssignmentServiceTest {
    public InterviewerAssignmentServiceTest() {

    }

    @TestSetup
    static void makeData(){
        Panel__c panel = new Panel__c(Name = 'New Panel');
        insert panel;
        Hiring_Event__c he = new Hiring_Event__c(Panel__c = panel.Id,   Date__c =  Date.today());
        insert he;
        Candidate__c can = new Candidate__c(HiringEventId__c=he.Id, Name = 'Satish',Email__c='satish@gmail.com');
        insert can;
        Interviewer__c inter = new Interviewer__c(Panel__c=panel.Id, User__c=UserInfo.getUserId());
        insert inter;
        Round__c round1 = new Round__c(  Candidate__c=can.Id, HiringEvent__c=he.Id,  Interviewer__c = inter.Id, Name = 'Round1', StartTime__c=DateTime.now(), 
                                            RoundStatus__c='In Progress', SiftLink__c='https://www.salesforce.com');
        insert round1;
        Round__c round2 = new Round__c(  Candidate__c=can.Id, HiringEvent__c=he.Id,  Interviewer__c = inter.Id, Name = 'Round2', StartTime__c=DateTime.now());
        insert round2;
        Round__c round3 = new Round__c(  Candidate__c=can.Id, HiringEvent__c=he.Id,  Interviewer__c = inter.Id, Name = 'Round3', StartTime__c=DateTime.now());
        insert round3;
        HiringEventItem__c item = new HiringEventItem__c(HiringEvent__c=he.id, CandidateId__c=can.id, R1Round__c=round1.id, R2Round__c=round2.id, R3Round__c=round3.id);
        insert item;

    }

    @isTest
    static void getPanelListTest()
    {
        try{
            List<Panel__c> panelList = InterviewerAssignmentService.getPanelList();
        }catch(Exception ex){}
    }

    @isTest
    static void assignInterviewerToPanelTest()
    {
        try{
            String userEmail = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email;
            Id panelId = [SELECT Id FROM Panel__c][0].Id;
            InterviewerAssignmentService.assignInterviewerToPanel(userEmail,panelId);
        }catch(Exception ex){}
    }

    
}