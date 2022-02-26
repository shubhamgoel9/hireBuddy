global with sharing class HireBuddyController {

    @AuraEnabled(cacheable=true)
    public static List<HiringEventItem__c> getAllEventItem(String eventId) {
        List<HiringEventItem__c> eventItemList = [SELECT CreatedById, CreatedDate, Candidate__c, CandidateStatus__c, CodepairLink__c, HiringEvent__c, InterviewLink__c, R1Feedback__c, R1Interviewer__c, R1Observer__c, R1Round__c, R1RoundStatus__c, R1SiftLink__c, R1StartTime__c, R2Feedback__c, R2Interviewer__c, R2Observer__c, R2Round__c, R2RoundStatus__c, R2SiftLink__c, R2StartTime__c, R3Feedback__c, R3Interviewer__c, R3Observer__c, R3Round__c, R3RoundStatus__c, R3SiftLink__c, R3StartTime__c, ResumeLink__c, Role__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, OwnerId, SystemModstamp FROM HiringEventItem__ct WHERE Id =:eventId ];
        return eventItemList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Round__c> getMyUpcomingRound() {
        List<Round__c> roundList = null;
        Id userId = UserInfo.getUserId();
        Interviewer__c interviwer = [SELECT Id from Interviewer__c where User__c = :userId];
        if(interviwer != null){
            roundList = [SELECT CreatedById, CreatedDate, Candidate__c, EndTime__c, Feedback__c, HiringEvent__c, Interviewer__c, Observer__c, RoundStatus__c, SiftLink__c, StartTime__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, SystemModstamp FROM Round__c WHERE Interviewer__c =:interviwer.Id ];
        }
        return roundList;
    }
}