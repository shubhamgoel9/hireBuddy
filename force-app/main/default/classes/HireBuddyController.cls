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
        WHERE Interviewer__c = :interviwerList[0].Id AND StartTime__c >= TODAY
      ];
    }
    return roundList;
  }

  @AuraEnabled(cacheable=true)
  public static List<Round__c> getCandiateByRoundId(String roundId) {
    List<Round__c> roundList = [
      SELECT
        Id, Name,SiftLink__c,
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
    List<User> userList = [
      SELECT FirstName, LastName
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    return userList[0].FirstName + ' ' + userList[0].LastName;
  }

  @AuraEnabled(cacheable=true)
  public static Id getMyTodayEvent() {
    Id userId = UserInfo.getUserId();
    Id eventId;
    List<Interviewer__c> interviwerList = [
      SELECT Id,Name
      FROM Interviewer__c
      WHERE User__c = :userId
    ];
    if (interviwerList != null && interviwerList.size() > 0) {
      String interviewer = interviwerList[0].Name;
      List<HiringEventItem__c> heiList = [
        SELECT
          Id,HiringEvent__c,R1StartTime__c
        FROM HiringEventItem__c
        WHERE
          (R1Interviewer__c = :interviewer
            AND (R1StartTime__c = TODAY OR R1StartTime__c = TOMORROW))
          OR (R2Interviewer__c = :interviewer
            AND (R2StartTime__c = TODAY OR R2StartTime__c = TOMORROW))
          OR (R3Interviewer__c = :interviewer
            AND (R3StartTime__c = TODAY OR R3StartTime__c = TOMORROW))
      ];
      System.debug('R1StartTime__c '+heiList[0].R1StartTime__c+'today'+Date.Today().format()+' list::'+heiList);
      if(heiList != null && !heiList.isEmpty())
        eventId=heiList[0].HiringEvent__c;
    }
    return eventId;
  }
  @AuraEnabled(cacheable=true)
  public static String setInterviewerStatus(String interviewId, String status) {
    Interviewer__c interviewer = new Interviewer__c(
      Id = interviewId,
      InterviewerStatus__c = status
    );
    insert interviewer;
    return 'success';
  }

  @AuraEnabled(cacheable=true)
  public static String sendEmail(String toEmail, String subject, String toName, String mailContent) {
    EmailService.toMail = toEmail;
    EmailService.sendMail(subject, toName, mailContent);
    return 'success';
  }
}