import { LightningElement, api } from 'lwc';

export default class ProjectPanel extends LightningElement {
    @api frameworkId;

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleProjectCreated() {
        this.dispatchEvent(new CustomEvent('projectcreated'));
        this.handleClose();
    }
}
