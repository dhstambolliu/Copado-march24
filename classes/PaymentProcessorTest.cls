@isTest
public class PaymentProcessorTest {
    @isTest
    static void testProcessPayment() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Payment_Amount__c = 100 // Initial payment amount
        );
        insert testContact;

        PaymentProcessor.PaymentInput input = new PaymentProcessor.PaymentInput();
        input.contactId = testContact.Id;
        input.cardNumber = '1234567890123456';
        input.cardHolder = 'Test Holder';
        input.expirationMonth = 12;
        input.expirationYear = 2025;
        input.cvv = '123';
        input.amount = 50;
        input.mailingStreet = 'Test Street';
        input.mailingPostalCode = '12345';
        input.mailingCity = 'Test City';
        input.mailingCountry = 'Test Country';
        input.mailingState = 'Test State';

        List<PaymentProcessor.PaymentInput> inputs = new List<PaymentProcessor.PaymentInput>();
        inputs.add(input);

        Test.startTest();
        PaymentProcessor.processPayment(inputs);
        Test.stopTest();

        // Verify the payment was processed correctly
        Contact updatedContact = [SELECT Payment_Amount__c, MailingStreet, MailingPostalCode, MailingCity, MailingCountry, MailingState 
                                  FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(50, updatedContact.Payment_Amount__c, 'Payment amount should be updated');
        System.assertEquals('Test Street', updatedContact.MailingStreet, 'Mailing Street should be updated');
        System.assertEquals('12345', updatedContact.MailingPostalCode, 'Mailing Postal Code should be updated');
        System.assertEquals('Test City', updatedContact.MailingCity, 'Mailing City should be updated');
        System.assertEquals('Test Country', updatedContact.MailingCountry, 'Mailing Country should be updated');
        System.assertEquals('Test State', updatedContact.MailingState, 'Mailing State should be updated');
    }
}