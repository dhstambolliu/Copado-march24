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

        List<PaymentProcessor.PaymentInput> inputs = new List<PaymentProcessor.PaymentInput>();
        inputs.add(input);

        Test.startTest();
        PaymentProcessor.processPayment(inputs);
        Test.stopTest();

        // Verify the payment was processed correctly
        Contact updatedContact = [SELECT Payment_Amount__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(50, updatedContact.Payment_Amount__c, 'Payment amount should be updated');
    }
}