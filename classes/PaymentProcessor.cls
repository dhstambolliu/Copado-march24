public class PaymentProcessor {
    public class PaymentInput {
        @InvocableVariable(label='Contact Id')
        public Id contactId;
        @InvocableVariable(label='Card Number')
        public String cardNumber;
        @InvocableVariable(label='Card Holder')
        public String cardHolder;
        @InvocableVariable(label='Card Expiration Month')
        public Integer expirationMonth;
        @InvocableVariable(label='Card Expiration Year')
        public Integer expirationYear;
        @InvocableVariable(label='CVV')
        public String cvv;
        @InvocableVariable(label='Amount')
        public Decimal amount;
    }

    @InvocableMethod(label='Process Payment')
    public static void processPayment(List<PaymentInput> paymentInputs) {
        List<Decimal> results = new List<Decimal>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Decimal> contactIdToPaymentAmount = new Map<Id, Decimal>();
        
        // Collect unique Contact Ids from input
        for (PaymentInput paymentInput : paymentInputs) {
            contactIds.add(paymentInput.contactId);
        }
        
        // Query Contact records outside the loop
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Payment_Amount__c FROM Contact WHERE Id IN :contactIds]);
        
        // Update Payment Amount based on input data
        for (PaymentInput paymentInput : paymentInputs) {
            // Access input parameters from paymentInput object
            Id contactId = paymentInput.contactId;
            Decimal amount = paymentInput.amount;

            // Process the payment (dummy implementation for now)
            // For demonstration purposes, just return the payment amount
            results.add(amount);

            // Update the Payment Amount in the map
            if (contactsMap.containsKey(contactId)) {
                Decimal existingPaymentAmount = contactsMap.get(contactId).Payment_Amount__c != null ?
                                                contactsMap.get(contactId).Payment_Amount__c : 0;
                contactIdToPaymentAmount.put(contactId, existingPaymentAmount - amount);
            }

            // Instantiate VisaPaymentProcessor and call its pay method
            VisaPaymentProcessor visaProcessor = new VisaPaymentProcessor();
            Decimal paymentResult = visaProcessor.pay(paymentInput.contactId, paymentInput.amount, 'VISA');
        }
        
        // Update Contact records
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactIdToPaymentAmount.keySet()) {
            Contact contact = contactsMap.get(contactId);
            contact.Payment_Amount__c = contactIdToPaymentAmount.get(contactId);
            contactsToUpdate.add(contact);
        }
        update contactsToUpdate;

        // Output the results (optional, for further processing)
        System.debug('Payment processing results: ' + results);
    }
}