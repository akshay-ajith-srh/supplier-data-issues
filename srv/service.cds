using { supplierDataIssues } from '../db/schema.cds';

service supplierDataIssuesSrv {
  @odata.draft.enabled
  @Capabilities.DeleteRestrictions.Deletable: false
  entity DataIssues as projection on supplierDataIssues.DataIssues actions {
    action recheck() returns DataIssues;
    action draftQuestion() returns String;
  };
  entity SupplierAddresses as projection on supplierDataIssues.SupplierAddresses;
  action importFindings(table : LargeString) returns String;
}