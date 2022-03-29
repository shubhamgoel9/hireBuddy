@isTest
private class EmailServiceTest
{
    @isTest static void testSendEmail(){
        EmailService.sendMail('Subject of Email', 'Hello World', 'Test message content');
    }
}