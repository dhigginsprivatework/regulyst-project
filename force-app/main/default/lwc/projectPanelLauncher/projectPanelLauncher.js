import { LightningElement, api, track } from 'lwc';

export default class ProjectPanelLauncher extends LightningElement {
    @api recordId;
    @track showPanel = false;
    @track activePanelLabel = '';
    @track isTeamPanel = false;
    @track isInteractionsPanel = false;
    @track isExpanded = false;

    get sidebarClass() {
        return this.isExpanded ? 'sidebar expanded' : 'sidebar collapsed';
    }

    get toggleIcon() {
        return this.isExpanded ? 'utility:chevronleft' : 'utility:chevronright';
    }

    toggleSidebar() {
        this.isExpanded = !this.isExpanded;
    }

    showTeamPanel() {
        this.showPanel = true;
        this.activePanelLabel = 'Project Team';
        this.isTeamPanel = true;
        this.isInteractionsPanel = false;
    }

    showInteractionsPanel() {
        this.showPanel = true;
        this.activePanelLabel = 'Project Interactions';
        this.isTeamPanel = false;
        this.isInteractionsPanel = true;
    }

    closePanel() {
        this.showPanel = false;
        this.isTeamPanel = false;
        this.isInteractionsPanel = false;
    }
}
