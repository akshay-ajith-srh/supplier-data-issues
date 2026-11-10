namespace supplierDataIssues;

entity DataIssues {
  key ID: UUID;
  issueID: String(50) @assert.unique @mandatory;
  businessPartner: String(20);
  addressID: String(10);
  fieldName: String(20);
  ruleID: String(30);
  ruleDescription: String(200);
  severity: String(10);
  status: String(20);
  owner: String(50);
  currentValue: String(100);
  lastCheckedAt: DateTime;
  reasonFalseAlarm: String(200);
  questionText: String(255);
  aiAssisted: Boolean;
  SupplierAddresses: Association to SupplierAddresses;
}

entity SupplierAddresses {
  key ID: UUID;
  businessPartner: String(20) @assert.unique @mandatory;
  addressID: String(10) @assert.unique @mandatory;
  streetName: String(100);
  houseNumber: String(20);
  postalCode: String(20);
  cityName: String(50);
  country: String(2);
  DataIssues: Association to many DataIssues on DataIssues.SupplierAddresses = $self;
}
