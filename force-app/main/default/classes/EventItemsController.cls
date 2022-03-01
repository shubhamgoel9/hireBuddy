global with sharing class EventItemsController {
  @AuraEnabled(cacheable=true)
  public static List<HiringEventItem__c> getAllEventItem(String eventId) {
  System.debug('Prit: event id::'+eventId);
      List<HiringEventItem__c> eventItemList = [
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
          Candidate__r.Status__c,
          Round1__r.Id,
          R1RoundStatus__c,
          R1Interviewer__c,
          R1StartTime__c,
          R1Feedback__c,
          R1SiftLink__c,
          R1Observer__c,
          Round2__r.Id,
          R2RoundStatus__c,
          R2Interviewer__c,
          R2StartTime__c,
          R2Feedback__c,
          R2SiftLink__c,
          R2Observer__c,
          Round3__r.Id,
          R3RoundStatus__c,
          R3Interviewer__c,
          R3StartTime__c,
          R3Feedback__c,
          R3SiftLink__c,
          R3Observer__c
          FROM HiringEventItem__c WHERE  HiringEvent__r.Id=:eventId];
          System.debug('itemList:: '+eventItemList);
      return eventItemList;
  }

  @AuraEnabled(cacheable=true)
  public static List<HiringEventItem__c> getEventItem(String eventItemId) {
      List<HiringEventItem__c> eventItemList = [
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
          Candidate__r.Status__c,
          Round1__r.Id,
          R1RoundStatus__c,
          R1Interviewer__c,
          R1StartTime__c,
          R1Feedback__c,
          R1SiftLink__c,
          R1Observer__c,
          Round2__r.Id,
          R2RoundStatus__c,
          R2Interviewer__c,
          R2StartTime__c,
          R2Feedback__c,
          R2SiftLink__c,
          R2Observer__c,
          Round3__r.Id,
          R3RoundStatus__c,
          R3Interviewer__c,
          R3StartTime__c,
          R3Feedback__c,
          R3SiftLink__c,
          R3Observer__c
          FROM HiringEventItem__c WHERE  Id=:eventItemId];
          System.debug('itemList:: '+eventItemList);
      return eventItemList;
  }

  @AuraEnabled
  public static void setEventItem(
    Id selectedEventId,
    String candidateStatus,
    String R1Interviewer,
    String R1Observer,
    DateTime R1Time,
    String R1Sift,
    String R1Feedback) 
    {
      List<HiringEventItem__c> items = [ SELECT
        Id,
          Candidate__r.Id,
          Candidate__r.Status__c,
          Round1__r.Id,
          R1RoundStatus__c,
          R1Interviewer__c,
          R1StartTime__c,
          R1Feedback__c,
          R1SiftLink__c,
          R1Observer__c,
          Round2__c,
          R2RoundStatus__c,
          R2Interviewer__c,
          R2StartTime__c,
          R2Feedback__c,
          R2SiftLink__c,
          R2Observer__c,
          Round3__c,
          R3RoundStatus__c,
          R3Interviewer__c,
          R3StartTime__c,
          R3Feedback__c,
          R3SiftLink__c,
          R3Observer__c
          FROM HiringEventItem__c WHERE  Id=:selectedEventId LIMIT 1];
      
      List<SObject> updateList = new List<SObject>();
      List<Candidate__c> candidateList = [Select Id, Status__c from Candidate__c where Id = :items[0].Candidate__r.Id LIMIT 1];
      if(candidateStatus != null) 
      {
        candidateList[0].Status__c = candidateStatus;
        updateList.add(candidateList[0]);
      }
      List<Round__c> round1 = [Select Id, Interviewer__r.Id, Interviewer__r.Name,Interviewer__r.Email__c, Observer__c, StartTime__c, SiftLink__c, Feedback__c from Round__C where Id=:items[0].Round1__r.Id LIMIT 1];
      if(R1Interviewer != null) 
      {
        items[0].R1Interviewer__c = R1Interviewer;
        if(!round1.isEmpty())
        {
          Interviewer__c inter = (Interviewer__c)round1[0].getSObject(Round__c.Interviewer__c.getDescribe().getRelationshipName());
          if(inter != null){
           inter.Email__c = R1Interviewer;
          updateList.add(inter);
          }
        }
       sendEmail(R1Interviewer,'IMPORTANT: You have an assignment','','Kindly check HireBuddy for more details');
      }
      if(R1Observer != null) {
        items[0].R1Observer__c = R1Observer;
        if(!round1.isEmpty()) round1[0].Observer__c = R1Observer;
      }
      if(R1Sift != null) 
      {
        items[0].R1SiftLink__c = R1Sift;
        if(!round1.isEmpty()) round1[0].SiftLink__c = R1Sift;
      }
      if(R1Time != null){
        items[0].R1StartTime__c = R1Time;
        if(!round1.isEmpty()) round1[0].StartTime__c = R1Time;
      }
      if(R1Feedback != null) {
        items[0].R1Feedback__c = R1Feedback;
        if(!round1.isEmpty()) round1[0].Feedback__c = R1Feedback;
      }
      updateList.add(items[0]);
      if(!round1.isEmpty()) updateList.add(round1[0]);
System.debug('Prit: before update:'+ items);
      update updateList;
    }
    
    @AuraEnabled(cacheable=true)
    public static String sendEmail(String toEmail, String subject, String toName, String mailContent) {
        EmailService.toMail = toEmail;
        EmailService.sendMail(subject, toName, mailContent);
        return 'success';
      }

}