import { LightningElement, api } from 'lwc';

export default class TeamMemberModal extends LightningElement {
    @api isOpen = false;
    @api userId;
    @api role;
    @api memberId;

    roleOptions = [
        { label: 'Compliance Lead', value: 'Compliance Lead' },
        { label: 'Document Owner', value: 'Document Owner' },
        { label: 'Technical Lead', value: 'Technical Lead' },
        { label: 'Auditor', value: 'Auditor' },
        { label: 'Contributor', value: 'Contributor' }
    ];

    handleRoleChange(event) {
        this.role = event.target.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSave() {
        const userField = this.template.querySelector('lightning-input-field');
        const selectedUserId = userField?.value;

        this.dispatchEvent(new CustomEvent('save', {
            detail: {
                memberId: this.memberId,
                userId: selectedUserId,
                role: this.role
            }
        }));
    }
}