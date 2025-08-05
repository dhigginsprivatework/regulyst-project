import { LightningElement, api, track, wire } from 'lwc';
import getInteractions from '@salesforce/apex/ProjectInteractionsController.getInteractions';
import getUsers from '@salesforce/apex/ProjectInteractionsController.getUsers';
import { publish, MessageContext } from 'lightning/messageService';
import SELECTED_RECORD_CHANNEL from '@salesforce/messageChannel/SelectedRecord__c';

export default class ProjectInteractions extends LightningElement {
    @api recordId;
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

    @track pageSize = 10;
    @track currentPage = 1;

    @wire(MessageContext)
    messageContext;

    columns = [
        { label: 'Contributor', fieldName: 'ContributorName' },
        { label: 'Item Interacted With', fieldName: 'Item_Interacted_With__c' },
        { label: 'Item Interacted With Name', fieldName: 'Item_Interacted_With_Name__c' },
        { label: 'Type', fieldName: 'Type__c' },
        {
            label: 'View',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:preview',
                alternativeText: 'View',
                title: 'View',
                variant: 'bare',
                name: 'view'
            }
        }
    ];

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

    get pageSizeOptions() {
        return [
            { label: '10', value: 10 },
            { label: '20', value: 20 },
            { label: '50', value: 50 },
            { label: '100', value: 100 }
        ];
    }

    get totalPages() {
        return Math.ceil(this.filteredInteractions.length / this.pageSize);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get pagedInteractions() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.filteredInteractions.slice(start, end);
    }

    connectedCallback() {
        this.loadUsers();
        this.loadInteractions();
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

    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.currentPage = 1;
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    filterInteractions() {
        let filtered = [...this.interactions];
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

        if (this.selectedUserIds.size > 0) {
            filtered = filtered.filter(i => this.selectedUserIds.has(i.Contributor__c));
        }

        this.filteredInteractions = filtered;
        this.currentPage = 1;
    }

    handleSelect(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'view') {
            publish(this.messageContext, SELECTED_RECORD_CHANNEL, {
                recordId: row.Item_Interacted_With_Record_Id__c,
                sObjectType: row.Item_Interacted_With_API_Name__c
            });
        }
    }
}