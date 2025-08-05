import { LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SELECTED_RECORD_CHANNEL from '@salesforce/messageChannel/SelectedRecord__c';
import createEvidenceWithFiles from '@salesforce/apex/EvidenceController.createEvidenceWithFiles';
import getEvidenceForRecord from '@salesforce/apex/EvidenceController.getEvidenceForRecord';

export default class RecordDetailAndEvidence extends LightningElement {
    @track recordId;
    @track objectApiName;
    @track evidenceDescription = '';
    @track files = [];
    @track isMinimized = true;
    @track evidenceList = [];

    fieldMap = {
        'Project_Clause_Control_Domain__c': ['Name', 'Description__c'],
        'Project_Control__c': ['Name', 'Title__c', 'Description__c'],
        'Project_Control_Requirement__c': ['Name', 'Description__c']
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        subscribe(this.messageContext, SELECTED_RECORD_CHANNEL, (message) => {
            this.recordId = message.recordId;
            this.objectApiName = message.sObjectType;
            this.files = [];
            this.isMinimized = false;
            document.documentElement.style.setProperty('--show-backdrop', 'block');
            this.fetchEvidence();
        });
    }

    get fieldsToDisplay() {
        return this.fieldMap[this.objectApiName] || [];
    }

    togglePanel() {
        this.isMinimized = !this.isMinimized;
        document.documentElement.style.setProperty('--show-backdrop', this.isMinimized ? 'none' : 'block');
    }

    closePanel() {
        this.isMinimized = true;
        document.documentElement.style.setProperty('--show-backdrop', 'none');
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
        const selectedFiles = Array.from(event.target.files);
        this.files = selectedFiles.map(file => ({
            rawFile: file,
            fileName: file.name
        }));
    }

    async handleSaveEvidenceAndUpload() {
        if (!this.recordId || !this.objectApiName || !this.evidenceDescription || this.files.length === 0) {
            this.showToast('Missing Information', 'Please provide all required inputs and select at least one file.', 'error');
            return;
        }

        try {
            const filePromises = this.files.map(fileWrapper => {
                return new Promise((resolve, reject) => {
                    if (!(fileWrapper.rawFile instanceof File)) {
                        reject(new Error('Invalid file object'));
                        return;
                    }
                    const reader = new FileReader();
                    reader.onloadend = () => {
                        const result = reader.result;
                        if (result && result.startsWith('data:')) {
                            const base64 = result.split(',')[1];
                            resolve({
                                fileName: fileWrapper.fileName,
                                base64Data: base64
                            });
                        } else {
                            reject(new Error(`Invalid file data for ${fileWrapper.fileName}`));
                        }
                    };
                    reader.onerror = error => reject(error);
                    reader.readAsDataURL(fileWrapper.rawFile);
                });
            });

            const fileData = await Promise.all(filePromises);
            const payload = {
                parentId: this.recordId,
                parentType: this.objectApiName,
                description: this.evidenceDescription,
                files: fileData
            };

            await createEvidenceWithFiles(JSON.parse(JSON.stringify(payload)));
            this.showToast('Success', 'Evidence and files uploaded successfully.', 'success');
            this.fetchEvidence();
            this.evidenceDescription = '';
            this.files = [];
            const fileInput = this.template.querySelector('input[type="file"]');
            if (fileInput) fileInput.value = null;
        } catch (error) {
            this.showToast('Upload Failed', error.body?.message || error.message || 'Unknown error', 'error');
        }
    }

    async fetchEvidence() {
        if (!this.recordId) return;
        try {
            const result = await getEvidenceForRecord({ parentId: this.recordId });
            this.evidenceList = result.map(e => ({
                ...e,
                fileUrl: e.ContentDocumentId ? `/sfc/servlet.shepherd/document/download/${e.ContentDocumentId}` : null,
                recordUrl: '/' + e.Id
            }));
        } catch (error) {
            console.error('Failed to fetch evidence:', error);
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
