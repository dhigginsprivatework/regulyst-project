export const fieldConfig = {
  Project__c: [
    { label: 'Framework', fieldName: 'Framework__r.Name', isLookup: true, objectApiName: 'Framework__c' },
    { label: 'Project Focus', fieldName: 'Project_Focus__c' },
    { label: 'Standards Alignment Body', fieldName: 'Standards_Alignment_Body__c' },
    { label: 'Standards Alignment Framework', fieldName: 'Standards_Alignment_Framework__c' },
    { label: 'Description', fieldName: 'Description__c', highlight: true }
  ],
  Project_Framework__c: [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Description', fieldName: 'Description__c', highlight: true },
    { label: 'URL', fieldName: 'URL__c', isLink: true },
    { label: 'Version', fieldName: 'Version__c' }
  ]
};
