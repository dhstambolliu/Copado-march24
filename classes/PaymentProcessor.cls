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
        @InvocableVariable(label='MailingStreet')
        public String mailingStreet;
        @InvocableVariable(label='MailingPostalCode')
        public String mailingPostalCode;
        @InvocableVariable(label='MailingCity')
        public String mailingCity;
        @InvocableVariable(label='MailingCountry')
        public String mailingCountry;
        @InvocableVariable(label='MailingState')
        public String mailingState;
    }
    
    @InvocableMethod(label='Process Payment')
    public static void processPayment(List<PaymentInput> paymentInputs) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Decimal> contactIdToPaymentAmount = new Map<Id, Decimal>();
        Map<Id, PaymentInput> contactIdToPaymentInput = new Map<Id, PaymentInput>();
        
        for (PaymentInput paymentInput : paymentInputs) {
            contactIds.add(paymentInput.contactId);
            contactIdToPaymentAmount.put(paymentInput.contactId, 0); // Initialize payment amount map
            contactIdToPaymentInput.put(paymentInput.contactId, paymentInput); // Store payment input for later use
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Payment_Amount__c, MailingStreet, MailingPostalCode, MailingCity, MailingCountry, MailingState 
                                                             FROM Contact WHERE Id IN :contactIds]);
        
        VisaPaymentProcessor visaProcessor = new VisaPaymentProcessor(); // Instantiate once
        
        for (PaymentInput paymentInput : paymentInputs) {
            Id contactId = paymentInput.contactId;
            Decimal amount = paymentInput.amount;
            
            if (contactsMap.containsKey(contactId)) {
                Decimal existingPaymentAmount = contactsMap.get(contactId).Payment_Amount__c != null ?
                    contactsMap.get(contactId).Payment_Amount__c : 0;
                
                // Call pay method and store the result
                Decimal paymentResult = visaProcessor.pay(paymentInput.contactId, paymentInput.amount, 'VISA');
                contactIdToPaymentAmount.put(contactId, existingPaymentAmount - paymentResult);
            }
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactIdToPaymentAmount.keySet()) {
            Contact contact = contactsMap.get(contactId);
            contact.Payment_Amount__c = contactIdToPaymentAmount.get(contactId);
            
            // Update mailing address fields if not null in PaymentInput
            PaymentInput paymentInput = contactIdToPaymentInput.get(contactId);
            if (paymentInput != null) {
                if (paymentInput.mailingStreet != contactsMap.get(contactId).MailingStreet) {
                    contact.MailingStreet = paymentInput.mailingStreet;
                }
                if (paymentInput.mailingPostalCode != contactsMap.get(contactId).MailingPostalCode) {
                    contact.MailingPostalCode = paymentInput.mailingPostalCode;
                }
                if (paymentInput.mailingCity != contactsMap.get(contactId).MailingCity) {
                    contact.MailingCity = paymentInput.mailingCity;
                }
                if (paymentInput.mailingCountry != contactsMap.get(contactId).MailingCountry) {
                    contact.MailingCountry = paymentInput.mailingCountry;
                }
                if (paymentInput.mailingState != contactsMap.get(contactId).MailingState) {
                    contact.MailingState = paymentInput.mailingState;
                }
            }
            
            contactsToUpdate.add(contact);
        }
        update contactsToUpdate;
    }
}