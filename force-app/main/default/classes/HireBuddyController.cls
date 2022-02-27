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
      FROM HiringEventItem__c
      WHERE HiringEvent__r.Id = :eventId
    ];
    System.debug('itemList:: ' + eventItemList);
    return eventItemList;
  }

  @AuraEnabled(cacheable=true)
  public static List<Round__c> getMyUpcomingRound() {
    List<Round__c> roundList = null;
    Id userId = UserInfo.getUserId();
    List<Interviewer__c> interviwerList = [
      SELECT Id
      FROM Interviewer__c
      WHERE User__c = :userId
    ];
    if (interviwerList != null && interviwerList.size() > 0) {
      roundList = [
        SELECT
          CreatedById,
          CreatedDate,
          Candidate__c,
          EndTime__c,
          Feedback__c,
          HiringEvent__c,
          Interviewer__c,
          Observer__c,
          RoundStatus__c,
          SiftLink__c,
          StartTime__c,
          Id,
          IsDeleted,
          LastModifiedById,
          LastModifiedDate,
          LastReferencedDate,
          LastViewedDate,
          Name,
          SystemModstamp
        FROM Round__c
        WHERE Interviewer__c = :interviwerList[0].Id AND StartTime__c >= TODAY
      ];
    }
    return roundList;
  }

  @AuraEnabled(cacheable=true)
  public static List<Round__c> getCandiateByRoundId(String roundId) {
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
    return roundList;
  }

  @AuraEnabled(cacheable=true)
  public String getCurrentUserName() {
    List<User> userList = [
      SELECT FirstName, LastName
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    return userList[0].FirstName + ' ' + userList[0].LastName;
  }

  @AuraEnabled(cacheable=true)
  public List<Hiring_Event__c> getMyTodayEvent() {
    List<Hiring_Event__c> hiringEventList = null;
    Id userId = UserInfo.getUserId();
    List<Interviewer__c> interviwerList = [
      SELECT Id
      FROM Interviewer__c
      WHERE User__c = :userId
    ];
    if (interviwerList != null && interviwerList.size() > 0) {
      Id interviewerId = interviwerList[0].Id;
      List<HiringEventItem__c> heiList = [
        SELECT
          Id,
          HiringEvent__c,
          HiringEvent__r.CreatedById,
          HiringEvent__r.CreatedDate,
          HiringEvent__r.hirebuddy__Date__c,
          HiringEvent__r.hirebuddy__Panel__c,
          HiringEvent__r.Id,
          HiringEvent__r.IsDeleted,
          HiringEvent__r.LastModifiedById,
          HiringEvent__r.LastModifiedDate,
          HiringEvent__r.LastReferencedDate,
          HiringEvent__r.LastViewedDate,
          HiringEvent__r.Name,
          HiringEvent__r.OwnerId
        FROM HiringEventItem__c
        WHERE
          (R1Interviewer__c = :interviewerId
          AND R1StartTime__c = TODAY)
          OR (R2Interviewer__c = :interviewerId
          AND R2StartTime__c = TODAY)
          OR (R3Interviewer__c = :interviewerId
          AND R2StartTime__c = TODAY)
      ];

      if (heiList != null && heiList.size() > 0) {
        for (HiringEventItem__c heItem : heiList) {
          Hiring_Event__c hiringEvent = (Hiring_Event__c) heItem.getSObject(
            HiringEventItem__c.HiringEvent__c.getDescribe()
              .getRelationshipName()
          );
          hiringEventList.add(hiringEvent);
        }
      }
    }
    return hiringEventList;
  }
  @AuraEnabled(cacheable=true)
  public String setInterviewerStatus(String interviewId, String status) {
    Interviewer__c interviewer = new Interviewer__c(
      Id = interviewId,
      InterviewerStatus__c = status
    );
    insert interviewer;
    return 'success';
  }
}
