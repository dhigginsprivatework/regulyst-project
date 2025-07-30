import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SELECTED_RECORD_CHANNEL from '@salesforce/messageChannel/SelectedRecord__c';
import createEvidenceWithFiles from '@salesforce/apex/EvidenceController.createEvidenceWithFiles';

export default class RecordDetailAndEvidence extends LightningElement {
    @track recordId;
    @track objectApiName;
    @track evidenceDescription = '';
    @track files = [];
    @track isMinimized = true;

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
            this.isMinimized = false; // Auto-expand on new selection
        });
    }

    get fieldsToDisplay() {
        return this.fieldMap[this.objectApiName] || [];
    }

    togglePanel() {
        this.isMinimized = !this.isMinimized;
    }

    get panelClass() {
        return this.isMinimized ? 'floating-panel minimized' : 'floating-panel open';
    }

    get toggleIcon() {
        return this.isMinimized ? 'utility:chevronleft' : 'utility:chevronright';
    }

    get toggleLabel() {
        return this.isMinimized ? 'Show Details' : 'Hide Details';
    }

    handleEvidenceChange(event) {
        this.evidenceDescription = event.target.value;
    }

    handleFileChange(event) {
        this.files = Array.from(event.target.files);
    }

    async handleSaveEvidenceAndUpload() {
        if (!this.recordId || !this.objectApiName || !this.evidenceDescription || this.files.length === 0) {
            this.showToast('Missing Information', 'Please provide all required inputs and select at least one file.', 'error');
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
            this.showToast('Success', 'Evidence and files uploaded successfully.', 'success');
            this.evidenceDescription = '';
            this.files = [];
        } catch (error) {
            console.error(error);
            this.showToast('Upload Failed', 'Error uploading evidence and files.', 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
