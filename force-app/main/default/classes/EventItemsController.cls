global class EventItemsController {

  private static String plainNamespace = null;
  private static String namespacePrefix = null;

  /*Get EventName*/
  @AuraEnabled
  public static string getEventName(Id eventId){
    try {
      return [SELECT Id,Name FROM Hiring_Event__c WHERE Id = :eventId].Name;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  /*Get all Event Items of a particular event*/
  @AuraEnabled
  public static List<HiringEventItem__c> getAllEventItem(String eventId) {
  System.debug('Prit: event id::'+eventId);
      List<HiringEventItem__c> eventItemList = [
        SELECT 
          Id,
          HiringEvent__r.Name,
          CandidateName__c,
          CodepairLink__c,
          CandidateId__r.HiringEventId__r.Name,
          CandidateId__r.HiringEventId__r.Panel__c,
          InterviewLink__c,
          ResumeLink__c,
          RoleEvaluation__c,
          CandidateStatus__c,
          R1Round__c,
          R1RoundStatus__c,
          R1Interviewer__c,
          R1InterviewerEmail__c,
          R1ProxyInterviewer__c,
          R1StartTime__c,
          R1Feedback__c,
          R1SiftLink__c,
          R1Observer__c,
          R2Round__c,
          R2RoundStatus__c,
          R2Interviewer__c,
          R2InterviewerEmail__c,
          R2ProxyInterviewer__c,
          R2StartTime__c,
          R2Feedback__c,
          R2SiftLink__c,
          R2Observer__c,
          R3Round__c,
          R3RoundStatus__c,
          R3Interviewer__c,
          R3InterviewerEmail__c,
          R3ProxyInterviewer__c,
          R3StartTime__c,
          R3Feedback__c,
          R3SiftLink__c,
          R3Observer__c
          FROM HiringEventItem__c WHERE  CandidateId__r.HiringEventId__c=:eventId ORDER BY Id];
          System.debug('itemList:: '+eventItemList);
      return eventItemList;
  }

  /*Modify the EventItem record based on the inputs from Edit screen */
  @AuraEnabled
  public static void setEventItem(
    Id selectedEventItemId,
    String candidateStatus,
    String interviewLink,
    String codepairLink,
    String R1InterviewerEmail,
    String R1ProxyInterviewer,
    String R1Observer,
    DateTime R1Time,
    String R1Sift,
    String R1Feedback,
    String R2InterviewerEmail,
    String R2ProxyInterviewer,
    String R2Observer,
    DateTime R2Time,
    String R2Sift,
    String R2Feedback,
    String R3InterviewerEmail,
    String R3ProxyInterviewer,
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
      List<Candidate__c> candidateList = [SELECT Id, Status__c,CodepairLink__c,InterviewLink__c FROM Candidate__c WHERE Id = :items[0].CandidateId__c LIMIT 1];
      if(candidateList!=null && !candidateList.isEmpty())  
      {
        if(String.IsNotBlank(candidateStatus)) 
        {
          candidateList[0].Status__c = candidateStatus;
        }
        if(String.IsNotBlank(codepairLink))
        {
          candidateList[0].CodepairLink__c = codepairLink;
        }
        if(String.IsNotBlank(interviewLink))
        {
          candidateList[0].InterviewLink__c = interviewLink;
        }
        updateList.add(candidateList[0]);
      }
      if(items[0].R1Round__c != null)
      {
        updateRound(items[0].R1Round__c,R1InterviewerEmail,R1ProxyInterviewer,R1Observer,R1Time,R1Sift,R1Feedback,updateList);
      }
      if(items[0].R2Round__c != null)
      {
        updateRound(items[0].R2Round__c,R2InterviewerEmail,R2ProxyInterviewer,R2Observer,R2Time,R2Sift,R2Feedback,updateList);
      }
      if(items[0].R3Round__c != null)
      {
        updateRound(items[0].R3Round__c,R3InterviewerEmail,R3ProxyInterviewer,R3Observer,R3Time,R3Sift,R3Feedback,updateList);
      }
      if(!updateList.isEmpty()) 
      {
        System.debug('Prit: updateList:: '+JSON.serialize(updateList));
        update updateList;
      }
    }

    /*Add the following new records
    1. Candidate
    2. Three rounds of the candidate
    3. Hiring Event Item*/
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
          Name='Round1',
          HiringEvent__c=eventId,
          Candidate__c = newCandidate.Id);
        Round__c R2Round = new Round__c(
          Name = 'Round2',
          HiringEvent__c=eventId,
          Candidate__c = newCandidate.Id);
        Round__c R3Round = new Round__c(
          Name='Round3',
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

    /* Delete the following records along with the Event Item 
    1. Candidate
    2. Three rounds*/
    @AuraEnabled
    public static void deleteCandidateDetails(List<HiringEventItem__c> selectedEventItems){
      System.debug('Inside deleteCandidateDetails: '+selectedEventItems);
        List<SObject> toBeDeleted = new List<SObject>();
        for(HiringEventItem__c item: selectedEventItems)
        {
          toBeDeleted.add(item.CandidateId__c.getSObjectType().newSObject(item.CandidateId__c));
          if(item.R1Round__c != null) toBeDeleted.add(item.R1Round__c.getSObjectType().newSObject(item.R1Round__c));
          if(item.R2Round__c != null) toBeDeleted.add(item.R2Round__c.getSObjectType().newSObject(item.R2Round__c));
          if(item.R3Round__c != null) toBeDeleted.add(item.R3Round__c.getSObjectType().newSObject(item.R3Round__c));
          toBeDeleted.add(item);
        }
        delete toBeDeleted;

    }

    @AuraEnabled
    public static Id getPanelId(Id eventId){
      try {
        List<Hiring_Event__c> events = [SELECT Id, Panel__c FROM Hiring_Event__c WHERE Id = :eventId LIMIT 1];
        return events[0].Panel__c;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    @AuraEnabled
    public static List<Interviewer__c> getInterviewerList(Id panelId){
      try {
        System.debug('Prit: Getting interviewer list');
        return [SELECT Id, InterviewerName__c, InterviewerEmail__c,InterviewerStatus__c, PanelName__c FROM Interviewer__c WHERE InterviewerEmail__c != NULL AND Panel__r.Id =:panelId];
        
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    @AuraEnabled
    public static void deleteInterviewerList(List<Interviewer__c> interviewerList){
      try {
        delete interviewerList;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    /* --------------HELPER METHODS----------------*/
    private static void updateRound(Id roundId,
      String InterviewerEmail,
      String ProxyInterviewer,
      String Observer,
      DateTime InterviewTime,
      String Sift,
      String Feedback,
      List<SObject> updateList)
    {
      List<Round__c> round = [Select Id, Interviewer__c, ProxyInterviewer__c, Interviewer__r.Name, Observer__c, StartTime__c, SiftLink__c, Feedback__c from Round__c where Id=:roundId];
      
      if(InterviewTime != null){
        if(!round.isEmpty()) round[0].StartTime__c = InterviewTime;
      }

      System.debug('Prit: Interviewer:: '+InterviewerEmail);
      if(InterviewerEmail != null || ProxyInterviewer != null) 
      {
        String toEmail;
        if(!round.isEmpty() && InterviewerEmail != null && !InterviewerEmail.equalsIgnoreCase('Proxy'))
        {
          if(InterviewerEmail.equalsIgnoreCase('None'))
          {
            round[0].Interviewer__c = null;
          }
          else
          {
            List<Interviewer__c> inter = [Select Id from Interviewer__c where InterviewerEmail__c = :InterviewerEmail LIMIT 1];
            if(inter != null){
              round[0].Interviewer__c = inter[0].Id;
              round[0].ProxyInterviewer__c = null;
              toEmail = InterviewerEmail;
            }
          }
        }
        else if(!round.isEmpty() && ProxyInterviewer != null && InterviewerEmail.equalsIgnoreCase('Proxy'))
        {
          round[0].ProxyInterviewer__c = ProxyInterviewer;
          round[0].Interviewer__c = null;
          toEmail = ProxyInterviewer;
        }
        if(String.IsNotBlank(toEmail))
        {
          String emailBody = 'An interview of a candidate is scheduled at: '+round[0].StartTime__c+'. Kindly check HireBuddy for more details.';
          sendEmail(toEmail,'IMPORTANT: You have an assignment','',emailBody, round[0].StartTime__c);
        }
      }
      if(Observer != null) 
      {
        if(!round.isEmpty() && String.IsNotBlank(Observer))
        {
          round[0].Observer__c = Observer;
          String emailBody =  'An interview of a candidate is scheduled at: '+round[0].StartTime__c+'. You are an observer for interviewer '+round[0].Interviewer__r.Name;
          sendEmail(Observer,'IMPORTANT: You have an assignment','',emailBody, round[0].StartTime__c);
        }
      }
      if(Sift != null) 
      {
        if(!round.isEmpty()) round[0].SiftLink__c = Sift;
      }
      if(Feedback != null) {
        if(!round.isEmpty()) round[0].Feedback__c = Feedback;
      }
      if(!round.isEmpty()) 
      {
        updateList.add(round[0]);
      }
    }

    private static void sendEmail(String toEmail, String subject, String toName, String mailContent, DateTime startTime) {
        EmailService.toMail = toEmail;
        EmailService.sendMail(subject, toName, mailContent);
        CalenderInvite.sendinvite(new List<String> {toEmail}, startTime);
    }

}