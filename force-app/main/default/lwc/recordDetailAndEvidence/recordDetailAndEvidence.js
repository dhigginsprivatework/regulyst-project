import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, MessageContext } from 'lightning/messageService';
import SELECTED_RECORD_CHANNEL from '@salesforce/messageChannel/SelectedRecord__c';
import createEvidenceWithFiles from '@salesforce/apex/EvidenceController.createEvidenceWithFiles';

export default class RecordDetailAndEvidence extends LightningElement {
    @track recordId;
    @track objectApiName;
    @track evidenceDescription = '';
    @track files = [];

    fieldMap = {
        'Project_Clause_Control_Domain__c': ['Name', 'Clause_Number__c', 'Description__c'],
        'Project_Control__c': ['Name', 'Control_Number__c', 'Title__c', 'Description__c'],
        'Project_Control_Requirement__c': ['Name', 'Description__c', 'Source__c', 'Framework__c']
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        subscribe(this.messageContext, SELECTED_RECORD_CHANNEL, (message) => {
            this.recordId = message.recordId;
            this.objectApiName = message.sObjectType;
            this.files = [];
        });
    }

    get fieldsToDisplay() {
        return this.fieldMap[this.objectApiName] || [];
    }

    handleEvidenceChange(event) {
        this.evidenceDescription = event.target.value;
    }

    handleFileChange(event) {
        this.files = Array.from(event.target.files);
    }

    async handleSaveEvidenceAndUpload() {
        if (!this.recordId || !this.objectApiName || !this.evidenceDescription || this.files.length === 0) {
            alert('Please provide all required inputs and select at least one file.');
            return;
        }

        const filePromises = this.files.map(file => {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = () => {
                    const base64 = reader.result.split(',')[1];
                    resolve({
                        fileName: file.name,
                        base64Data: base64
                    });
                };
                reader.onerror = error => reject(error);
                reader.readAsDataURL(file);
            });
        });

        try {
            const fileData = await Promise.all(filePromises);
            await createEvidenceWithFiles({
                parentId: this.recordId,
                parentType: this.objectApiName,
                description: this.evidenceDescription,
                files: fileData
            });
            alert('Evidence and files uploaded successfully.');
            this.evidenceDescription = '';
            this.files = [];
        } catch (error) {
            console.error(error);
            alert('Error uploading evidence and files.');
        }
    }
}
