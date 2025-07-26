export const fieldConfig = {
  Project__c: [
    { label: 'Description', fieldName: 'Description__c', highlight: true }
  ],
  Project_Framework__c: [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Description', fieldName: 'Description__c', highlight: true },
    { label: 'URL', fieldName: 'URL__c', isLink: true },
    { label: 'Version', fieldName: 'Version__c' }
  ]
};
