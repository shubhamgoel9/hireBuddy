@isTest
public class EventItemsControllerTest {
    public EventItemsControllerTest() {

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
    static void getEventNameTest()
    {
        try{
            String eventName = EventItemsController.getEventName(null);
        }catch(Exception ex){}
    }

    @isTest
    static void getAllEventItemTest()
    {
        try{
            List<HiringEventItem__c> items = EventItemsController.getAllEventItem(null);
        }catch(Exception ex){}
    }

    @isTest
    static void getPanelIdTest()
    {
        try{
            String panelId = EventItemsController.getPanelId(null);
        }catch(Exception ex){}
    }

    @isTest
    static void getInterviewerListTest()
    {
        try{
            List<Interviewer__c> interviewerList = EventItemsController.getInterviewerList(null);
        }catch(Exception ex){}
    }

    @isTest
    static void deleteInterviewerListTest()
    {
        try{
            EventItemsController.deleteInterviewerList(null);
        }catch(Exception ex){}
    }

    @isTest
    static void setEventItemTest()
    {
        try{
            Id selectedEventItemId = [SELECT Id FROM HiringEventItem__c][0].Id;
            String candidateStatus = 'Loop Cut';
            String codepairLink = 'http://www.salesforceindia.com';
            String interviewLink = 'http://www.salesforcegoogle.com';
            String R1InterviewerEmail = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email ;
            String R1ProxyInterviewer = null;
            String R1Observer = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email;
            DateTime R1Time=DateTime.Now();
            String R1Sift='https://wwww.salesforce.com/sift';
            String R1Feedback = 'Good';

            String R2InterviewerEmail = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email;
            String R2ProxyInterviewer = null;
            String R2Observer = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email;
            DateTime R2Time=DateTime.Now();
            String R2Sift='https://wwww.salesforce.com/sift';
            String R2Feedback = 'Good';

            String R3InterviewerEmail = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email;
            String R3ProxyInterviewer = null;
            String R3Observer = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()][0].Email;
            DateTime R3Time=DateTime.Now();
            String R3Sift='https://wwww.salesforce.com/sift';
            String R3Feedback = 'Good';
            
            EventItemsController.setEventItem(selectedEventItemId,
            candidateStatus,
            interviewLink,
            codepairLink,
            R1InterviewerEmail,
            R1ProxyInterviewer,
            R1Observer,
            R1Time,
            R1Sift,
            R1Feedback,
            R2InterviewerEmail,
            R2ProxyInterviewer,
            R2Observer,
            R2Time,
            R2Sift,
            R2Feedback,
            R3InterviewerEmail,
            R3ProxyInterviewer,
            R3Observer,
            R3Time,
            R3Sift,
            R3Feedback);
        }catch(Exception ex){}
    }

    @isTest
    static void setNewCandidateDetailsTest()
    {
        try{
            Id eventId =[SELECT Id FROM Hiring_Event__c][0].Id;
            String newCandidateName = 'TestCandidate';
            String newCandidateEmail = 'tc@gmail.com';
            String newCandidateContact = '';
            String newCandidateResume = '';
            String newCandidateRoleEvaluation='MTS';
            String newCandidateInterviewLink='';
            String newCandidateCodePairLink='';

            EventItemsController.setNewCandidateDetails(eventId,
             newCandidateName,
             newCandidateEmail,
             newCandidateContact,
             newCandidateResume,
             newCandidateRoleEvaluation,
             newCandidateInterviewLink,
             newCandidateCodePairLink);
        }catch(Exception ex){}
    }

    @isTest
    static void deleteCandidateDetailsTest()
    {
        try{
            HiringEventItem__c selectedEventItem = [SELECT Id,CandidateId__c,R1Round__c,R2Round__c,R3Round__c FROM HiringEventItem__c];
            EventItemsController.deleteCandidateDetails(new List<HiringEventItem__c>{selectedEventItem});
        }catch(Exception ex){}
    }

}