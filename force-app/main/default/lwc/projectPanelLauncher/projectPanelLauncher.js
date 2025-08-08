import { LightningElement, api, track } from 'lwc';

export default class ProjectPanelLauncher extends LightningElement {
    @api recordId;
    @track isExpanded = false;
    @track showPanel = false;
    @track activePanelLabel = '';
    @track isTeamPanel = false;
    @track isInteractionsPanel = false;

    get sidebarClass() {
        return this.isExpanded ? 'sidebar expanded' : 'sidebar collapsed';
    }

    get toggleIcon() {
        return this.isExpanded ? 'utility:chevrondown' : 'utility:chevronup';
    }

    toggleSidebar() {
        this.isExpanded = !this.isExpanded;
    }

    showTeamPanel() {
        this.activePanelLabel = 'Project Team';
        this.isTeamPanel = true;
        this.isInteractionsPanel = false;
        this.showPanel = true;
    }

    showInteractionsPanel() {
        this.activePanelLabel = 'Project Interactions';
        this.isTeamPanel = false;
        this.isInteractionsPanel = true;
        this.showPanel = true;
    }

    closePanel() {
        this.showPanel = false;
        this.isTeamPanel = false;
        this.isInteractionsPanel = false;
    }
}