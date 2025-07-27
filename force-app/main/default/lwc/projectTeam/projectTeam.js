import {LightningElement,api,wire,track} from 'lwc';
import getTeamMembers from '@salesforce/apex/ProjectTeamController.getTeamMembers';
import addTeamMember from '@salesforce/apex/ProjectTeamController.addTeamMember';
import deleteTeamMember from '@salesforce/apex/ProjectTeamController.deleteTeamMember';
import updateTeamMember from '@salesforce/apex/ProjectTeamController.updateTeamMember';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';

export default class ProjectTeam extends LightningElement {
	@api recordId;
	@track teamMembers = [];
	@track userId = '';
	@track role = 'None Selected';
	@track isLoading = false;

	wiredTeamMembersResult;

	@wire(getTeamMembers, {
		projectId: '$recordId'
	})
	wiredMembers(result) {
		this.wiredTeamMembersResult = result;
		const {
			data,
			error
		} = result;
		if (data) {
			this.teamMembers = data;
		} else if (error) {
			this.showToast('Error loading team members', error.body.message, 'error');
		}
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
			return; // User cancelled the action
		}

		this.isLoading = true;
		try {
			await deleteTeamMember({
				teamMemberId: memberId
			});
			this.showToast('Deleted', 'Team member removed', 'success');
			await refreshApex(this.wiredTeamMembersResult);
		} catch (err) {
			this.showToast('Error', err.body.message, 'error');
		} finally {
			this.isLoading = false;
		}
	}



	async handleEdit(event) {
		const memberId = event.currentTarget.dataset.id;
		const currentUserId = event.currentTarget.dataset.userId;
		const currentRole = event.currentTarget.dataset.role;

		const newUserId = prompt('Enter new User Id:', currentUserId);
		const newRole = prompt('Enter new Role:', currentRole);

		if (!newUserId || !newRole) {
			this.showToast('Missing Info', 'User ID and Role are required', 'warning');
			return;
		}

		this.isLoading = true;
		try {
			await updateTeamMember({
				teamMemberId: memberId,
				userId: newUserId,
				role: newRole
			});
			this.showToast('Updated', 'Team member updated', 'success');
			await refreshApex(this.wiredTeamMembersResult);
		} catch (err) {
			this.showToast('Error', err.body.message, 'error');
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

	get roleOptions() {
		return [{
				label: 'None Selected',
				value: 'None Selected'
			},
			{
				label: 'Compliance Lead',
				value: 'Compliance Lead'
			},
			{
				label: 'Document Owner',
				value: 'Document Owner'
			},
			{
				label: 'Technical Lead',
				value: 'Technical Lead'
			},
			{
				label: 'Auditor',
				value: 'Auditor'
			},
			{
				label: 'Contributor',
				value: 'Contributor'
			}
		];
	}
}