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
            this.isMinimized = false;
            document.documentElement.style.setProperty('--show-backdrop', 'block');
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
                        console.warn('⚠️ rawFile is not a File object:', fileWrapper.rawFile);
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

            console.log('🧪 fileData:', fileData);
            fileData.forEach((f, i) => {
                console.log(`📄 File ${i + 1}:`, f.fileName, f.base64Data?.substring(0, 100));
            });

            const payload = {
                parentId: this.recordId,
                parentType: this.objectApiName,
                description: this.evidenceDescription,
                files: fileData
            };

            console.log('📤 Sending to Apex:', payload);

            await createEvidenceWithFiles(JSON.parse(JSON.stringify(payload)));

            this.showToast('Success', 'Evidence and files uploaded successfully.', 'success');
            this.evidenceDescription = '';
            this.files = [];

            const fileInput = this.template.querySelector('input[type="file"]');
            if (fileInput) fileInput.value = null;

        } catch (error) {
            console.error('❌ Apex call failed:', error);
            this.showToast('Upload Failed', error.body?.message || error.message || 'Unknown error', 'error');
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
