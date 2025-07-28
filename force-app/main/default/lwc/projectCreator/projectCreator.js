import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import PROJECT_OBJECT from '@salesforce/schema/Project__c';
import createProjectWithFramework from '@salesforce/apex/ProjectController.createProjectWithFramework';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProjectCreator extends LightningElement {
    @track selectedBody;
    @track selectedFramework;
    @track selectedProjectFocus;
    @track description;
    @track name; 
    @track frameworkId;

    @track bodyOptions = [];
    @track frameworkOptions = [];
    @track focusOptions = [];
    @track controllerValues = {};
    @track filteredFrameworkOptions = [];

    @track isLoading = false;

    @wire(getObjectInfo, { objectApiName: PROJECT_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: PROJECT_OBJECT,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId'
    })
    picklistValues({ data, error }) {
        if (data) {
            this.bodyOptions = data.picklistFieldValues.Standards_Alignment_Body__c.values;
            this.frameworkOptions = data.picklistFieldValues.Standards_Alignment_Framework__c.values;
            this.focusOptions = data.picklistFieldValues.Project_Focus__c.values;
            this.controllerValues = data.picklistFieldValues.Standards_Alignment_Framework__c.controllerValues;
        } else if (error) {
            console.error('Error loading picklist values', error);
        }
    }

    handleBodyChange(event) {
        this.selectedBody = event.detail.value;
        const controllingKey = this.controllerValues[this.selectedBody];
        this.filteredFrameworkOptions = this.frameworkOptions.filter(option =>
            option.validFor.includes(controllingKey)
        );
        this.selectedFramework = null;
        this.selectedProjectFocus = null; 
    }

    handleFrameworkChange(event) {
        this.selectedFramework = event.detail.value;
    }

    handleFocusChange(event) {
        this.selectedProjectFocus = event.detail.value;
    }

    handleDescriptionChange(event) {
        this.description = event.detail.value;
    }

    handleNameChange(event) {
        this.name = event.detail.value;
    }

    handleFrameworkSelected(event) {
        this.frameworkId = event.detail.frameworkId;
    }

    async createProject() {
        this.isLoading = true;
        try {
            const projectId = await createProjectWithFramework({
                body: this.selectedBody,
                framework: this.selectedFramework,
                focus: this.selectedProjectFocus,
                description: this.description,
                frameworkId: this.frameworkId,
                name: this.name
            });

            this.showToastWithLink('Success', 'Project created successfully.', 'success', projectId);
        } catch (error) {
            console.error('Error creating project', error);
            this.showToast('Error', 'Failed to create project.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    showToastWithLink(title, message, variant, recordId) {
    const url = `/lightning/r/Project__c/${recordId}/view`;
    this.dispatchEvent(new ShowToastEvent({
        title,
        message: 'Click {0} to view the project.',
        variant,
        mode: 'dismissable',
        messageData: [
            {
                url,
                label: 'here'
            }
        ]
    }));
}

}
