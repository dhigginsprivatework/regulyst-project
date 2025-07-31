import { LightningElement, api } from 'lwc';

export default class FrameworkTile extends LightningElement {
    @api framework;

    get isIsoFramework() {
        return this.framework.Name && this.framework.Name.includes('ISO 27001');
    }

    get isoImageUrl() {
        return '/resource/ISO_27001_Logo'; // Replace with your static resource name
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('select', {
            detail: { frameworkId: this.framework.Id }
        }));
    }
}
