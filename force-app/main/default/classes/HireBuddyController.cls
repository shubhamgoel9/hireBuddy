global with sharing class HireBuddyController {

    @AuraEnabled(cacheable=true)
    public static List<HiringEventItem__c> getAllEventItem(String eventId) {
        List<HiringEventItem__c> eventItemList = [SELECT CreatedById, CreatedDate, Candidate__c, CandidateStatus__c, CodepairLink__c, HiringEvent__c, InterviewLink__c, R1Feedback__c, R1Interviewer__c, R1Observer__c, R1Round__c, R1RoundStatus__c, R1SiftLink__c, R1StartTime__c, R2Feedback__c, R2Interviewer__c, R2Observer__c, R2Round__c, R2RoundStatus__c, R2SiftLink__c, R2StartTime__c, R3Feedback__c, R3Interviewer__c, R3Observer__c, R3Round__c, R3RoundStatus__c, R3SiftLink__c, R3StartTime__c, ResumeLink__c, Role__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, OwnerId, SystemModstamp FROM HiringEventItem__ct WHERE Id =:eventId and ];
        return eventItemList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Round__c> getMyUpcomingRound() {
        List<Round__c> roundList = null;
        Id userId = UserInfo.getUserId();
        List<Interviewer__c> interviwerList = [SELECT Id from Interviewer__c where User__c = :userId];
        if(interviwerList != null && interviwerList.size() > 0){
            roundList = [SELECT CreatedById, CreatedDate, Candidate__c, EndTime__c, Feedback__c, HiringEvent__c, Interviewer__c, Observer__c, RoundStatus__c, SiftLink__c, StartTime__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, SystemModstamp FROM Round__c WHERE Interviewer__c =:interviwerList[0].Id and StartTime__c >= TODAY];
        }
        return roundList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Candidate__c> getCandiateByRoundId(String roundId) {
        Candidate__c candidate = null;
        List<Round__c> roundList = [SELECT Id, Candidate__r.Id, Candidate__r.Name, Candidate__r.CodepairLink__c, Candidate__r.Contact__c, Candidate__r.Email__c, Candidate__r.HiringEventId__c, Candidate__r.InterviewLink__c, Candidate__r.ResumeLink__c,  Candidate__r.Role__c,  Candidate__r.Status__c from Round__c where Id = :roundId];
        if(roundList != null && roundList.size() > 0){
            candidate = (Candidate__c)roundList[0].getSObject(Round__c.Candidate__c.getDescribe().getRelationshipName());
        }
        return candidate;
    }
}