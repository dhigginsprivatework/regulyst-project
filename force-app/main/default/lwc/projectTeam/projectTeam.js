import { LightningElement, api, wire, track } from 'lwc';
import getTeamMembers from '@salesforce/apex/ProjectTeamController.getTeamMembers';
import addTeamMember from '@salesforce/apex/ProjectTeamController.addTeamMember';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ProjectTeam extends LightningElement {
   @api recordId;
   @track teamMembers = [];
   @track userId = '';
   @track role = '';
   @track isLoading = false;

   wiredTeamMembersResult;

   @wire(getTeamMembers, { projectId: '$recordId' })
   wiredMembers(result) {
      this.wiredTeamMembersResult = result;
      const { data, error } = result;
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

      if (!this.userId || !this.role) {
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

         // Clear fields
         userField.value = null;
         this.role = '';

         // Refresh the wired data
         await refreshApex(this.wiredTeamMembersResult);
      } catch (err) {
         this.showToast('Error', err.body.message, 'error');
      } finally {
         this.isLoading = false;
      }
   }

   showToast(title, message, variant) {
      this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
   }

   get roleOptions() {
      return [
         { label: 'Compliance Lead', value: 'Compliance Lead' },
         { label: 'Document Owner', value: 'Document Owner' },
         { label: 'Technical Lead', value: 'Technical Lead' },
         { label: 'Auditor', value: 'Auditor' },
         { label: 'Contributor', value: 'Contributor' },
         { label: 'None Selected', value: 'None Selected' }
      ];
   }
}
