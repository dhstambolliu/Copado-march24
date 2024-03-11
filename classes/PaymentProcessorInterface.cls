public Interface PaymentProcessorInterface {
    Decimal pay(Id recordId, Decimal amount, String providerName);
}