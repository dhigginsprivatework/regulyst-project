import { LightningElement, api, track } from 'lwc';

export default class ProjectSideNavigator extends LightningElement {
    @api recordId;
    @track showPanel = false;
    @track activePanelLabel = '';
    @track isTeamPanel = false;
    @track isInteractionsPanel = false;

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
