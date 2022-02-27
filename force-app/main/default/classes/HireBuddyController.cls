global with sharing class HireBuddyController {

    @AuraEnabled(cacheable=true)
    public static List<HiringEventItem__c> getAllEventItem(String eventId) {
        List<HiringEventItem__c> eventItemList = [
          SELECT 
            Candidate__r.Id,
            Candidate__r.Name,
            Candidate__r.CodepairLink__c,
            Candidate__r.Contact__c,
            Candidate__r.Email__c,
            Candidate__r.HiringEventId__c,
            Candidate__r.InterviewLink__c,
            Candidate__r.ResumeLink__c,
            Candidate__r.Role__c,
            Candidate__r.Status__c
            FROM HiringEventItem__c WHERE  HiringEvent__r.Id=:eventId];
            System.debug('itemList:: '+eventItemList);
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
    List<Candidate__c> candidates = new List<Candidate__c>();
    List<Round__c> roundList = [
      SELECT
        Id,
        Candidate__r.Id,
        Candidate__r.Name,
        Candidate__r.CodepairLink__c,
        Candidate__r.Contact__c,
        Candidate__r.Email__c,
        Candidate__r.HiringEventId__c,
        Candidate__r.InterviewLink__c,
        Candidate__r.ResumeLink__c,
        Candidate__r.Role__c,
        Candidate__r.Status__c
      FROM Round__c
      WHERE Id = :roundId
    ];
    if (roundList != null && roundList.size() > 0) {
      Candidate__c candidate = (Candidate__c) roundList[0]
        .getSObject(Round__c.Candidate__c.getDescribe().getRelationshipName());
      candidates.add(candidate);
    }
    return candidates;
  }
}