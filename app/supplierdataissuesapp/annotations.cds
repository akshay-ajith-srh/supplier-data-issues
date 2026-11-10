using { supplierDataIssuesSrv } from '../../srv/service.cds';

annotate supplierDataIssuesSrv.DataIssues with {
  SupplierAddresses @Common.ValueList: {
    CollectionPath: 'SupplierAddresses',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: SupplierAddresses_ID,
        ValueListProperty: 'ID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'businessPartner'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'addressID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'streetName'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'houseNumber'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'postalCode'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'cityName'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'country'
      },
    ],
  }
};
annotate supplierDataIssuesSrv.DataIssues with @UI.DataPoint #businessPartner: {
  Value: businessPartner,
  Title: 'Business Partner',
};
annotate supplierDataIssuesSrv.DataIssues with @UI.DataPoint #addressID: {
  Value: addressID,
  Title: 'Address ID',
};
annotate supplierDataIssuesSrv.DataIssues with @UI.DataPoint #fieldName: {
  Value: fieldName,
  Title: 'Field Name',
};
annotate supplierDataIssuesSrv.DataIssues with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#businessPartner', ID: 'BusinessPartner' },
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#addressID', ID: 'AddressID' },
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#fieldName', ID: 'FieldName' }
];
annotate supplierDataIssuesSrv.DataIssues with @UI.HeaderInfo: {
  TypeName: 'Issue',
  TypeNamePlural: 'Issues',
  Title: { Value: issueID }
};
annotate supplierDataIssuesSrv.DataIssues with {
  ID @UI.Hidden
};
annotate supplierDataIssuesSrv.DataIssues with @UI.Identification: [
  { $Type: 'UI.DataFieldForAction', Action: 'supplierDataIssuesSrv.recheck', Label: 'Recheck' },
  { $Type: 'UI.DataFieldForAction', Action: 'supplierDataIssuesSrv.draftQuestion', Label: 'Draft question (AI)' }
];
annotate supplierDataIssuesSrv.DataIssues with {
  issueID @Common.Label: 'Issue ID';
  businessPartner @Common.Label: 'Business Partner';
  addressID @Common.Label: 'Address ID';
  fieldName @Common.Label: 'Field Name';
  ruleID @Common.Label: 'Rule ID';
  ruleDescription @Common.Label: 'Rule Description';
  severity @Common.Label: 'Severity';
  status @Common.Label: 'Status';
  owner @Common.Label: 'Owner';
  currentValue @Common.Label: 'Current Value';
  lastCheckedAt @Common.Label: 'Last Checked At';
  reasonFalseAlarm @Common.Label: 'False Alarm Reason';
  questionText @Common.Label: 'Question Text';
  aiAssisted @Common.Label: 'Ai Assisted';
  SupplierAddresses @Common.Label: 'Address'
};
annotate supplierDataIssuesSrv.DataIssues with {
  ID @Common.Text: { $value: issueID, ![@UI.TextArrangement]: #TextOnly };
  SupplierAddresses @Common.Text: { $value: SupplierAddresses.businessPartner, ![@UI.TextArrangement]: #TextOnly };
};
annotate supplierDataIssuesSrv.DataIssues with @UI.SelectionFields : [
 status,
 severity,
 owner,
 ruleID,
 SupplierAddresses.country
];
annotate supplierDataIssuesSrv.DataIssues with @UI.LineItem : [
    { $Type: 'UI.DataField', Value: businessPartner },
    { $Type: 'UI.DataField', Value: fieldName },
    { $Type: 'UI.DataField', Value: ruleID },
    { $Type: 'UI.DataField', Value: severity },
    { $Type: 'UI.DataField', Value: status },
    { $Type: 'UI.DataField', Value: owner },
    { $Type: 'UI.DataField', Value: lastCheckedAt }
];
annotate supplierDataIssuesSrv.DataIssues with @UI.FieldGroup #issueDetails: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: issueID },
    { $Type: 'UI.DataField', Value: businessPartner },
    { $Type: 'UI.DataField', Value: addressID },
    { $Type: 'UI.DataField', Value: fieldName }

  ]
};


annotate supplierDataIssuesSrv.DataIssues with @UI.FieldGroup #rule: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: ruleID },
    { $Type: 'UI.DataField', Value: ruleDescription }

  ]
};


annotate supplierDataIssuesSrv.DataIssues with @UI.FieldGroup #statusAndOwner: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: severity },
    { $Type: 'UI.DataField', Value: status },
    { $Type: 'UI.DataField', Value: owner },
    { $Type: 'UI.DataField', Value: reasonFalseAlarm }

  ]
};


annotate supplierDataIssuesSrv.DataIssues with @UI.FieldGroup #lastCheck: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: currentValue },
    { $Type: 'UI.DataField', Value: lastCheckedAt }

  ]
};


annotate supplierDataIssuesSrv.DataIssues with @UI.FieldGroup #address: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: SupplierAddresses.streetName },
    { $Type: 'UI.DataField', Value: SupplierAddresses.houseNumber },
    { $Type: 'UI.DataField', Value: SupplierAddresses.postalCode },
    { $Type: 'UI.DataField', Value: SupplierAddresses.cityName },
    { $Type: 'UI.DataField', Value: SupplierAddresses.country }

  ]
};


annotate supplierDataIssuesSrv.DataIssues with @UI.FieldGroup #question: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: questionText },
    { $Type: 'UI.DataField', Value: aiAssisted }

  ]
};


annotate supplierDataIssuesSrv.DataIssues with @UI.Facets: [
  {
    $Type: 'UI.CollectionFacet',
    ID: 'issue',
    Label: 'Issue',
    Facets: [
      { $Type: 'UI.ReferenceFacet', ID: 'issueDetails', Label: 'Issue Details', Target: '@UI.FieldGroup#issueDetails' },
      { $Type: 'UI.ReferenceFacet', ID: 'rule', Label: 'Rule', Target: '@UI.FieldGroup#rule' },
      { $Type: 'UI.ReferenceFacet', ID: 'statusAndOwner', Label: 'Status and Owner', Target: '@UI.FieldGroup#statusAndOwner' },
      { $Type: 'UI.ReferenceFacet', ID: 'lastCheck', Label: 'Last Check', Target: '@UI.FieldGroup#lastCheck' } ]
  },
  {
    $Type: 'UI.CollectionFacet',
    ID: 'addressTab',
    Label: 'Address in S/4HANA',
    Facets: [
      { $Type: 'UI.ReferenceFacet', ID: 'address', Label: 'Address', Target: '@UI.FieldGroup#address' } ]
  },
  {
    $Type: 'UI.CollectionFacet',
    ID: 'questionTab',
    Label: 'Question to Supplier',
    Facets: [
      { $Type: 'UI.ReferenceFacet', ID: 'question', Label: 'Question', Target: '@UI.FieldGroup#question' } ]
  }
];
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.DataPoint #streetName: {
  Value: streetName,
  Title: 'Street Name',
};
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.DataPoint #houseNumber: {
  Value: houseNumber,
  Title: 'House Number',
};
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.DataPoint #postalCode: {
  Value: postalCode,
  Title: 'Postal Code',
};
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#streetName', ID: 'StreetName' },
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#houseNumber', ID: 'HouseNumber' },
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#postalCode', ID: 'PostalCode' }
];
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.HeaderInfo: {
  TypeName: 'Address',
  TypeNamePlural: 'Addresses',
  Title: { Value: businessPartner }
};
annotate supplierDataIssuesSrv.SupplierAddresses with {
  ID @UI.Hidden
};
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.Identification: [{ Value: businessPartner }];
annotate supplierDataIssuesSrv.SupplierAddresses with {
  businessPartner @Common.Label: 'Business Partner';
  addressID @Common.Label: 'Address ID';
  streetName @Common.Label: 'Street Name';
  houseNumber @Common.Label: 'House Number';
  postalCode @Common.Label: 'Postal Code';
  cityName @Common.Label: 'City Name';
  country @Common.Label: 'Country';
  DataIssues @Common.Label: 'Issues'
};
annotate supplierDataIssuesSrv.SupplierAddresses with {
  ID @Common.Text: { $value: businessPartner, ![@UI.TextArrangement]: #TextOnly };
};
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.SelectionFields: [
  businessPartner
];
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: businessPartner },
    { $Type: 'UI.DataField', Value: addressID },
    { $Type: 'UI.DataField', Value: streetName },
    { $Type: 'UI.DataField', Value: houseNumber },
    { $Type: 'UI.DataField', Value: postalCode },
    { $Type: 'UI.DataField', Value: cityName },
    { $Type: 'UI.DataField', Value: country }
];
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: businessPartner },
    { $Type: 'UI.DataField', Value: addressID },
    { $Type: 'UI.DataField', Value: streetName },
    { $Type: 'UI.DataField', Value: houseNumber },
    { $Type: 'UI.DataField', Value: postalCode },
    { $Type: 'UI.DataField', Value: cityName },
    { $Type: 'UI.DataField', Value: country }
]};
annotate supplierDataIssuesSrv.SupplierAddresses with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: 'General Information', Target: '@UI.FieldGroup#Main' }
];