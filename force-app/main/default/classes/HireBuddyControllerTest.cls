@isTest
private class HireBuddyControllerTest
{
    @testSetup static void setupData()
    {
        Panel__c panel = new Panel__c(Name = 'New Panel');
        insert panel;
        Hiring_Event__c he = new Hiring_Event__c(Panel__c = panel.Id,   Date__c =  Date.today());
        insert he;
        Candidate__c can = new Candidate__c(HiringEventId__c=he.Id);
        insert can;
        Interviewer__c inter = new Interviewer__c(Panel__c=panel.Id, User__c=UserInfo.getUserId());
        insert inter;
        Round__c round = new Round__c(  Candidate__c=can.Id, HiringEvent__c=he.Id,  Interviewer__c = inter.Id);
        insert round;
    }
    @isTest static void testGetMyUpcomingRound(){
        try{
            HireBuddyController.getMyUpcomingRound();
        }catch(Exception e){}
    }
    @isTest static void testGetCandiateByRoundId(){
        try{
            HireBuddyController.getCandiateByRoundId(null);
        }catch(Exception e){}
    }
    @isTest static void testGetCurrentUserName(){
        try{
            HireBuddyController.getCurrentUserName();
        }catch(Exception e){}
    }
    @isTest static void testGetMyTodayEvent(){
        try{
            HireBuddyController.getMyTodayEvent();
        }catch(Exception e){}
    }
    @isTest static void testGetInterviewerStatus(){
        try{
            HireBuddyController.getInterviewerStatus();
        }catch(Exception e){}
    }
    @isTest static void testSetInterviewerStatus(){
        try{
            HireBuddyController.setInterviewerStatus('Available');
        }catch(Exception e){}
    }
    @isTest static void testSendEmail(){
        try{
            HireBuddyController.sendEmail('','','','');
        }catch(Exception e){}
    }
    @isTest static void testSetFeedback(){
        try{
            Id roundId = [SELECT Id FROM Round__c][0].Id;
            String feedback = 'Excellent';
            HireBuddyController.setFeedback(roundId, feedback);
        }catch(Exception e){}
    }
    @isTest static void testSetStatusToInterviewing(){
        try{
            Id roundId = [SELECT Id FROM Round__c][0].Id;
            HireBuddyController.setStatusToInterviewing(roundId);
        }catch(Exception e){}
    }
    
}