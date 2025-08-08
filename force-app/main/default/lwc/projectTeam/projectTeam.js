import { LightningElement, api, wire, track } from 'lwc';
import getTeamMembers from '@salesforce/apex/ProjectTeamController.getTeamMembers';
import addTeamMember from '@salesforce/apex/ProjectTeamController.addTeamMember';
import deleteTeamMember from '@salesforce/apex/ProjectTeamController.deleteTeamMember';
import updateTeamMember from '@salesforce/apex/ProjectTeamController.updateTeamMember';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';

export default class ProjectTeam extends LightningElement {
    @api recordId;
    @track teamMembers = [];
    @track filteredMembers = [];
    @track userId = '';
    @track role = 'None Selected';
    @track isLoading = false;
    @track searchTerm = '';

    @track isModalOpen = false;
    @track editUserId = '';
    @track editRole = '';
    @track editMemberId = '';

    wiredTeamMembersResult;

    @wire(getTeamMembers, { projectId: '$recordId' })
    wiredMembers(result) {
        this.wiredTeamMembersResult = result;
        const { data, error } = result;
        if (data) {
            this.teamMembers = data;
            this.filterMembers();
        } else if (error) {
            this.showToast('Error loading team members', error.body.message, 'error');
        }
    }

    filterMembers() {
        const term = this.searchTerm.toLowerCase();
        this.filteredMembers = this.teamMembers.filter(member =>
            member.User__r.Name.toLowerCase().includes(term) ||
            member.Role__c.toLowerCase().includes(term)
        );
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.filterMembers();
    }

    handleRoleChange(event) {
        this.role = event.target.value;
    }

    async handleAddMember() {
        const userField = this.template.querySelector('.userLookup');
        this.userId = userField?.value;

        if (!this.userId || !this.role || this.role === 'None Selected') {
            this.showToast('Missing Info', 'Please select a user and role', 'warning');
            return;
        }

        this.isLoading = true;
        try {
            await addTeamMember({
                projectId: this.recordId,
                userId: this.userId,
                role: this.role
            });

            this.showToast('Success', 'Team member added', 'success');

            userField.value = null;
            this.role = 'None Selected';

            await refreshApex(this.wiredTeamMembersResult);
        } catch (err) {
            this.showToast('Error', err.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleDelete(event) {
        const memberId = event.currentTarget.dataset.id;

        const confirmed = await LightningConfirm.open({
            message: 'Are you sure you want to delete this team member?',
            variant: 'header',
            label: 'Confirm Deletion',
            theme: 'warning'
        });

        if (!confirmed) {
            return;
        }

        this.isLoading = true;
        try {
            await deleteTeamMember({ teamMemberId: memberId });
            this.showToast('Deleted', 'Team member removed', 'success');
            await refreshApex(this.wiredTeamMembersResult);
        } catch (err) {
            this.showToast('Error', err.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleEdit(event) {
        this.editMemberId = event.currentTarget.dataset.id;
        this.editUserId = event.currentTarget.dataset.userId;
        this.editRole = event.currentTarget.dataset.role;
        this.isModalOpen = true;
    }

    handleModalClose() {
        this.isModalOpen = false;
    }

    async handleModalSave(event) {
        const { memberId, userId, role } = event.detail;

        if (!userId || !role) {
            this.showToast('Missing Info', 'User ID and Role are required', 'warning');
            return;
        }

        this.isLoading = true;
        try {
            await updateTeamMember({ teamMemberId: memberId, userId, role });
            this.showToast('Updated', 'Team member updated', 'success');
            await refreshApex(this.wiredTeamMembersResult);
        } catch (err) {
            this.showToast('Error', err.body.message, 'error');
        } finally {
            this.isLoading = false;
            this.isModalOpen = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    get roleOptions() {
        return [
            { label: 'None Selected', value: 'None Selected' },
            { label: 'Compliance Lead', value: 'Compliance Lead' },
            { label: 'Document Owner', value: 'Document Owner' },
            { label: 'Technical Lead', value: 'Technical Lead' },
            { label: 'Auditor', value: 'Auditor' },
            { label: 'Contributor', value: 'Contributor' }
        ];
    }
}