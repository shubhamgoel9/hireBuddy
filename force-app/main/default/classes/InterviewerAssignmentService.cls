global with sharing class InterviewerAssignmentService {
    @AuraEnabled
    public static List<Panel__c> getPanelList(){
        try {
            return [SELECT Id, Name FROM Panel__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Interviewer__c assignInterviewerToPanel(String userEmail, Id panelId){
        try {
            List<User> user = [SELECT Id, Name, Email FROM User WHERE Email =:userEmail LIMIT 1];
            Interviewer__c interviewer = new Interviewer__c(User__c=user[0].Id, Panel__c=panelId);
            insert interviewer;
            return [SELECT Id, InterviewerName__c, InterviewerEmail__c, PanelName__c,Panel__c FROM Interviewer__c WHERE InterviewerEmail__c = :userEmail][0];
        } catch (Exception e) {
            throw new AuraHandledException('Assignment of Interviewer failed! User not found in the org database.');
        }
    }

    @AuraEnabled
    public static List<Interviewer__c> getAllInterviewerList(){
        try {
            return [SELECT Id, InterviewerName__c, InterviewerEmail__c, PanelName__c,Panel__c FROM Interviewer__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}