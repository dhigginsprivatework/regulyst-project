import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import PROJECT_FOCUS from '@salesforce/schema/Project__c.Project_Focus__c';
import FRAMEWORK from '@salesforce/schema/Project__c.Framework__c';
import FRAMEWORK_NAME from '@salesforce/schema/Project__c.Framework__r.Name';
import STANDARDS_BODY from '@salesforce/schema/Project__c.Standards_Alignment_Body__c';
import STANDARDS_FRAMEWORK from '@salesforce/schema/Project__c.Standards_Alignment_Framework__c';

export default class ProjectHighlights extends LightningElement {
    @api recordId;

    projectFocus;
    frameworkName;
    frameworkId;
    standardsBody;
    standardsFramework;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [PROJECT_FOCUS, FRAMEWORK, FRAMEWORK_NAME, STANDARDS_BODY, STANDARDS_FRAMEWORK]
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.projectFocus = data.fields.Project_Focus__c.value;
            this.frameworkName = data.fields.Framework__r.value.fields.Name.value;
            this.frameworkId = data.fields.Framework__c.value;
            this.standardsBody = data.fields.Standards_Alignment_Body__c.value;
            this.standardsFramework = data.fields.Standards_Alignment_Framework__c.value;
        } else if (error) {
            console.error('Error loading project highlights:', error);
        }
    }

    get frameworkUrl() {
        return `/lightning/r/Framework__c/${this.frameworkId}/view`;
    }
}
