import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import PROJECT_OBJECT from '@salesforce/schema/Project__c';
import createProjectWithFramework from '@salesforce/apex/ProjectController.createProjectWithFramework';

export default class ProjectCreator extends LightningElement {
    @track selectedBody;
    @track selectedFramework;
    @track projectFocus;
    @track description;
    @track frameworkId;

    @track bodyOptions = [];
    @track frameworkOptions = [];
    @track focusOptions = []; 
    @track controllerValues = {};
    @track filteredFrameworkOptions = [];

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
            console.log('this.focusOptions',JSON.stringify(this.focusOptions)); 
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
    }

    handleFrameworkChange(event) {
        this.selectedFramework = event.detail.value;
    }

    handleFocusChange(event) {
        this.projectFocus = event.detail.value;
    }

    handleDescriptionChange(event) {
        this.description = event.detail.value;
    }

    handleFrameworkSelected(event) {
        this.frameworkId = event.detail.frameworkId;
    }

    createProject() {
        createProjectWithFramework({
            body: this.selectedBody,
            framework: this.selectedFramework,
            focus: this.projectFocus,
            description: this.description,
            frameworkId: this.frameworkId
        }).then(() => {
            // Show success toast or reset form
        }).catch(error => {
            console.error('Error creating project', error);
        });
    }
}