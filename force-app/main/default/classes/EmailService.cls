public with sharing class EmailService {

    public static String toMail;
    public static String ccMail;
    public static String repMail;
    
    public static void sendMail(String subject, String name, String mailContent){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] to = new string[] {toMail};
        String[] cc = new string[] {ccMail};
        
        email.setToAddresses(to);
        if(ccMail!=null && ccMail != '')
            email.setCcAddresses(cc);
        if(repmail!=null && repmail!= '')
            email.setInReplyTo(repMail);
        
        email.setSubject(subject);
        
        email.setHtmlBody('Hello' + name + ' ,' + '<br/><br/>' + mailContent + '<br/><br/>Regards<br/> HireBuddy');
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
        
        toMail = '';
        ccMail = '';
        repMail = '';
    }
}