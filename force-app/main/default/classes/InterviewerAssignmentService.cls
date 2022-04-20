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
    public static void assignPermissionSet(String userEmail){
        try {
            User usr = [SELECT Id FROM User WHERE Email =:userEmail LIMIT 1];
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HireBuddy_Interviewer'][0];
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId=usr.Id, PermissionSetId=ps.Id);

            List<PermissionSetAssignment> existingPsa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id AND PermissionSetId=:ps.Id];
            if(existingPsa==null || existingPsa.size()==0)
                upsert psa;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removePermissionSet(List<Interviewer__c> interviewerList){
        try {
            List<String> emailIds = new List<String>();
            List<String> userIds = new List<String>();
            for(Interviewer__c inter: interviewerList)
            {
                emailIds.add(inter.InterviewerEmail__c);
            }
            List<User> userList = [SELECT Id FROM User WHERE Email =:emailIds];
            for(User usr: userList)
            {
                userIds.add(usr.Id);
            }
            delete [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userIds AND PermissionSet.Name='HireBuddy_Interviewer'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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