import { LightningElement, api, track } from 'lwc';
import getInteractions from '@salesforce/apex/ProjectInteractionsController.getInteractions';
import getUsers from '@salesforce/apex/ProjectInteractionsController.getUsers';

export default class ProjectInteractions extends LightningElement {
    @api recordId;
    @track isModalOpen = false;
    @track selectedDateFilter = 'today';
    @track showCustomDate = false;
    @track customStartDate;
    @track customEndDate;
    @track users = [];
    @track filteredUsers = [];
    @track selectedUserIds = new Set();
    @track selectedUsers = [];
    @track showUserResults = false;
    @track interactions = [];
    @track filteredInteractions = [];

    columns = [
        { label: 'Contributor', fieldName: 'ContributorName' },
        { label: 'Item Interacted With', fieldName: 'Item_Interacted_With__c' },
        { label: 'Intem Interacted With Name', fieldName: 'Item_Interacted_With_Name__c' },
        { label: 'Type', fieldName: 'Type__c' }
    ];

    connectedCallback() {
        this.loadUsers();
        this.loadInteractions();
    }

    get todayButtonClass() {
        return this.selectedDateFilter === 'today' ? 'selected' : '';
    }

    get weekButtonClass() {
        return this.selectedDateFilter === 'week' ? 'selected' : '';
    }

    get monthButtonClass() {
        return this.selectedDateFilter === 'month' ? 'selected' : '';
    }

    get customButtonClass() {
        return this.selectedDateFilter === 'custom' ? 'selected' : '';
    }

    handleDateFilter(event) {
        this.selectedDateFilter = event.target.dataset.value;
        this.showCustomDate = this.selectedDateFilter === 'custom';
        this.filterInteractions();
    }

    handleStartDateChange(event) {
        this.customStartDate = event.target.value;
        this.filterInteractions();
    }

    handleEndDateChange(event) {
        this.customEndDate = event.target.value;
        this.filterInteractions();
    }

    handleUserSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        if (searchTerm.length > 1) {
            this.filteredUsers = this.users.filter(user => user.Name.toLowerCase().includes(searchTerm));
            this.showUserResults = this.filteredUsers.length > 0;
        } else {
            this.showUserResults = false;
        }
    }

    handleUserAdd(event) {
        const userId = event.target.dataset.id;
        const user = this.users.find(u => u.Id === userId);
        if (user && !this.selectedUserIds.has(userId)) {
            this.selectedUserIds.add(userId);
            this.selectedUsers.push(user);
            this.filterInteractions();
        }
        this.showUserResults = false;
    }

    handleUserRemove(event) {
        const userId = event.detail.name;
        this.selectedUserIds.delete(userId);
        this.selectedUsers = this.selectedUsers.filter(u => u.Id !== userId);
        this.filterInteractions();
    }

    async loadUsers() {
        try {
            const result = await getUsers();
            this.users = result;
        } catch (error) {
            console.error('Error loading users:', error);
        }
    }

    async loadInteractions() {
        try {
            const result = await getInteractions({ projectId: this.recordId });
            this.interactions = result.map(i => ({
                ...i,
                ContributorName: i.Contributor__r?.Name
            }));
            this.filterInteractions();
        } catch (error) {
            console.error('Error loading interactions:', error);
        }
    }

    filterInteractions() {
        let filtered = [...this.interactions];

        // Date filter
        const now = new Date();
        let startDate;
        if (this.selectedDateFilter === 'today') {
            startDate = new Date();
            startDate.setHours(0, 0, 0, 0);
        } else if (this.selectedDateFilter === 'week') {
            const day = now.getDay();
            startDate = new Date();
            startDate.setDate(now.getDate() - day);
        } else if (this.selectedDateFilter === 'month') {
            startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        } else if (this.selectedDateFilter === 'custom' && this.customStartDate && this.customEndDate) {
            const start = new Date(this.customStartDate);
            const end = new Date(this.customEndDate);
            filtered = filtered.filter(i => {
                const created = new Date(i.CreatedDate);
                return created >= start && created <= end;
            });
        }

        if (startDate && this.selectedDateFilter !== 'custom') {
            filtered = filtered.filter(i => new Date(i.CreatedDate) >= startDate);
        }

        // User filter
        if (this.selectedUserIds.size > 0) {
            filtered = filtered.filter(i => this.selectedUserIds.has(i.Contributor__c));
        }

        this.filteredInteractions = filtered;
    }
}