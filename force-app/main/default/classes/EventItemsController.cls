global with sharing class EventItemsController {
  @AuraEnabled(cacheable=true)
  public static List<HiringEventItem__c> getAllEventItem(String eventId) {
  System.debug('Prit: event id::'+eventId);
      List<HiringEventItem__c> eventItemList = [
        SELECT 
          Id,
          HiringEvent__r.Name,
          CandidateName__c,
          CodepairLink__c,
          CandidateId__r.HiringEventId__r.Name,
          InterviewLink__c,
          ResumeLink__c,
          RoleEvaluation__c,
          CandidateStatus__c,
          R1Round__c,
          R1RoundStatus__c,
          R1Interviewer__c,
          R1StartTime__c,
          R1Feedback__c,
          R1SiftLink__c,
          R1Observer__c,
          R2Round__c,
          R2RoundStatus__c,
          R2Interviewer__c,
          R2StartTime__c,
          R2Feedback__c,
          R2SiftLink__c,
          R2Observer__c,
          R3Round__c,
          R3RoundStatus__c,
          R3Interviewer__c,
          R3StartTime__c,
          R3Feedback__c,
          R3SiftLink__c,
          R3Observer__c
          FROM HiringEventItem__c WHERE  CandidateId__r.HiringEventId__c=:eventId];
          System.debug('itemList:: '+eventItemList);
      return eventItemList;
  }

  @AuraEnabled
  public static void setEventItem(
    Id selectedEventItemId,
    String candidateStatus,
    String R1Interviewer,
    String R1Observer,
    DateTime R1Time,
    String R1Sift,
    String R1Feedback,
    String R2Interviewer,
    String R2Observer,
    DateTime R2Time,
    String R2Sift,
    String R2Feedback,
    String R3Interviewer,
    String R3Observer,
    DateTime R3Time,
    String R3Sift,
    String R3Feedback
    ) 
    {
      System.debug('Prit: selectedEventItemId:: '+selectedEventItemId);
      List<HiringEventItem__c> items = [ SELECT
        Id,
        CandidateId__c,
        R1Round__c,
        R2Round__c,
        R3Round__c
        FROM HiringEventItem__c WHERE  Id=:selectedEventItemId LIMIT 1];
      
      List<SObject> updateList = new List<SObject>();
      List<Candidate__c> candidateList = [Select Id, Status__c from Candidate__c where Id = :items[0].CandidateId__c LIMIT 1];
      if(candidateStatus != null) 
      {
        candidateList[0].Status__c = candidateStatus;
        updateList.add(candidateList[0]);
      }
      if(items[0].R1Round__c != null)
      {
        updateRound(items[0].R1Round__c,R1Interviewer,R1Observer,R1Time,R1Sift,R1Feedback,updateList);
      }
      if(items[0].R2Round__c != null)
      {
        updateRound(items[0].R2Round__c,R2Interviewer,R2Observer,R2Time,R2Sift,R2Feedback,updateList);
      }
      if(items[0].R3Round__c != null)
      {
        updateRound(items[0].R3Round__c,R3Interviewer,R3Observer,R3Time,R3Sift,R3Feedback,updateList);
      }
      if(!updateList.isEmpty()) 
      {
        update updateList;
      }
    }

    private static void updateRound(Id roundId,
      String RInterviewer,
      String RObserver,
      DateTime RTime,
      String RSift,
      String RFeedback,
      List<SObject> updateList)
    {
      List<Round__c> round = [Select Id, Interviewer__c, Interviewer__r.Email__c, Observer__c, StartTime__c, SiftLink__c, Feedback__c from Round__c where Id=:roundId];

      if(RInterviewer != null) 
      {
        if(!round.isEmpty())
        {
          List<Interviewer__c> inter = [Select Id from Interviewer__c where Email__c = :RInterviewer LIMIT 1];
          if(inter != null){
            round[0].Interviewer__c = inter[0].Id;
          }
        }
        sendEmail(RInterviewer,'IMPORTANT: You have an assignment','','Kindly check HireBuddy for more details');
      }
      if(RObserver != null) {
        if(!round.isEmpty()) round[0].Observer__c = RObserver;
        sendEmail(RObserver,'IMPORTANT: You have an assignment','','You are the observer for interviewer '+round[0].Interviewer__r.Email__c);
      }
      if(RSift != null) 
      {
        if(!round.isEmpty()) round[0].SiftLink__c = RSift;
      }
      if(RTime != null){
        if(!round.isEmpty()) round[0].StartTime__c = RTime;
      }
      if(RFeedback != null) {
        if(!round.isEmpty()) round[0].Feedback__c = RFeedback;
      }
      if(!round.isEmpty()) 
      {
        updateList.add(round[0]);
      }
    }

    private static void sendEmail(String toEmail, String subject, String toName, String mailContent) {
        EmailService.toMail = toEmail;
        EmailService.sendMail(subject, toName, mailContent);
    }

    @AuraEnabled
    public static void setNewCandidateDetails(
      Id eventId,
      String newCandidateName,
      String newCandidateEmail,
      String newCandidateContact,
      String newCandidateResume,
      String newCandidateRoleEvaluation,
      String newCandidateInterviewLink,
      String newCandidateCodePairLink)
    {
        Candidate__c newCandidate = new Candidate__c(
          HiringEventId__c=eventId, 
          Name=newCandidateName, 
          Email__c=newCandidateEmail,
          Contact__c=newCandidateContact,
          ResumeLink__c = newCandidateResume,
          Role__c = newCandidateRoleEvaluation,
          InterviewLink__c = newCandidateInterviewLink,
          CodepairLink__c = newCandidateCodePairLink);
        
        insert newCandidate;

        Round__c R1Round = new Round__c(
          HiringEvent__c=eventId,
          Candidate__c = newCandidate.Id);
        Round__c R2Round = new Round__c(
          HiringEvent__c=eventId,
          Candidate__c = newCandidate.Id);
        Round__c R3Round = new Round__c(
          HiringEvent__c=eventId,
          Candidate__c = newCandidate.Id);

        insert R1Round;
        insert R2Round;
        insert R3Round;

        HiringEventItem__c newItem = new HiringEventItem__c(
          CandidateId__c = newCandidate.Id,
          R1Round__c = R1Round.Id,
          R2Round__c = R2Round.Id,
          R3Round__c = R3Round.Id,
          HiringEvent__c = eventId);
        
        insert newItem;
          
    }
}