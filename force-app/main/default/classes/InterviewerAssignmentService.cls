global with sharing class InterviewerAssignmentService {
    @AuraEnabled(cacheable=true)
    public static List<Panel__c> getPanelList(){
        try {
            return [SELECT Id, Name FROM Panel__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Interviewer__c> getInterviewerList(){
      try {
        System.debug('Prit: Getting interviewer list');
        return [SELECT Id, InterviewerName__c, InterviewerEmail__c,InterviewerStatus__c,Panel__c FROM Interviewer__c WHERE InterviewerEmail__c != NULL];
        
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
    @AuraEnabled
    public static void assignInterviewerToPanel(String userEmail, Id panelId){
        try {
            List<User> user = [SELECT Id, Name, Email FROM User WHERE Email =:userEmail LIMIT 1];
            Interviewer__c interviewer = new Interviewer__c(User__c=user[0].Id, Panel__c=panelId);
            insert interviewer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
