global with sharing class HireBuddyController {
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
          Candidate__r.Name,
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
          Name,
          SystemModstamp
        FROM Round__c
        WHERE
          Interviewer__c = :interviwerList[0].Id
          AND StartTime__c >= TODAY
          AND RoundStatus__c != 'Completed'
      ];
    }
    return roundList;
  }

  @AuraEnabled(cacheable=true)
  public static List<Round__c> getCandiateByRoundId(String roundId) {
    List<Round__c> roundList = [
      SELECT
        Id,
        Name,
        SiftLink__c,
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
    return roundList;
  }

  @AuraEnabled(cacheable=true)
  public static String getCurrentUserName() {
    Id userId = UserInfo.getUserId();
    List<Interviewer__c> interviewer = [
      SELECT Id, InterviewerName__c
      FROM Interviewer__c
      WHERE User__c = :userId
      LIMIT 1
    ];
    if(interviewer.size() > 0){
        return interviewer[0].InterviewerName__c;
    }
    return null;
  }

  @AuraEnabled(cacheable=true)
  public static Id getMyTodayEvent() {
    Id userId = UserInfo.getUserId();
    Id eventId;
    List<Interviewer__c> interviwerList = [
      SELECT Id, InterviewerEmail__c
      FROM Interviewer__c
      WHERE User__c = :userId
      LIMIT 1
    ];
    if (interviwerList != null && interviwerList.size() > 0) {
      String interviewer = interviwerList[0].InterviewerEmail__c;
      List<HiringEventItem__c> heiList = [
        SELECT Id, HiringEvent__c, R1StartTime__c
        FROM HiringEventItem__c
        WHERE
          (R1InterviewerEmail__c = :interviewer
          AND (R1StartTime__c = TODAY
          OR R1StartTime__c = TOMORROW))
          OR (R2InterviewerEmail__c = :interviewer
          AND (R2StartTime__c = TODAY
          OR R2StartTime__c = TOMORROW))
          OR (R3InterviewerEmail__c = :interviewer
          AND (R3StartTime__c = TODAY
          OR R3StartTime__c = TOMORROW))
      ];
      if (heiList != null && !heiList.isEmpty()) {
        eventId = heiList[0].HiringEvent__c;
      }
    }
    return eventId;
  }

  @AuraEnabled(cacheable=true)
  public static String getInterviewerStatus() {
    try {
      Id userId = UserInfo.getUserId();
      List<Interviewer__c> interviewer = [
        SELECT Id, InterviewerStatus__c
        FROM Interviewer__c
        WHERE User__c = :userId
        LIMIT 1
      ];
      System.debug('Prit: interviewerStatus: ' + interviewer[0]);
      return interviewer[0].InterviewerStatus__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static void setInterviewerStatus(String status) {
    Id userId = UserInfo.getUserId();
    List<Interviewer__c> interviewer = [
      SELECT Id, InterviewerStatus__c
      FROM Interviewer__c
      WHERE User__c = :userId
      LIMIT 1
    ];
    interviewer[0].InterviewerStatus__c = status;
    update interviewer;
  }

  @AuraEnabled(cacheable=true)
  public static String sendEmail(
    String toEmail,
    String subject,
    String toName,
    String mailContent
  ) {
    EmailService.toMail = toEmail;
    EmailService.sendMail(subject, toName, mailContent);
    return 'success';
  }
  @AuraEnabled
  public static Boolean setFeedback(Id roundId, String feedback) {
    List<Round__c> updatedRound = new List<Round__c>();

    List<Round__c> roundObj = [
      SELECT Id, Name, Feedback__c, RoundStatus__c
      FROM Round__c
      WHERE Id = :roundId
      LIMIT 1
    ];

    roundObj[0].Feedback__c = feedback;
    roundObj[0].RoundStatus__c = 'Completed';
    updatedRound.add(roundObj[0]);
    if (!updatedRound.isEmpty()) {
      update updatedRound;
      return true;
    }
    return false;
  }


  @AuraEnabled
  public static Boolean setStatusToInterviewing(Id roundId ) {
    List<Round__c> updatedRound = new List<Round__c>();

    List<Round__c> roundObj = [
      SELECT Id, Name,  RoundStatus__c
      FROM Round__c
      WHERE Id = :roundId
      LIMIT 1
    ];
 
    roundObj[0].RoundStatus__c = 'In Progress';
    updatedRound.add(roundObj[0]);
    if (!updatedRound.isEmpty()) {
      update updatedRound;
      return true;
    }
    return false;
  }
}