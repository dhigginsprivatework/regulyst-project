import { LightningElement, api } from 'lwc';

export default class FrameworkTile extends LightningElement {
    @api framework;

    get isIsoFramework() {
        return this.framework.Name && this.framework.Name.includes('ISO 27001:2022 Controls Mapping to Information Security Control Domains');
    }

    get isNistIsoFramework() {
        return this.framework.Name && this.framework.Name.includes('NIST CSF 2.0 and ISO 27001:2022');
    }

    get isoImageUrl() {
        return '/resource/ISO_27001_Logo'; // Replace with your actual static resource name
    }

    get nistIsoImageUrl() {
        return '/resource/NISTISO27001Logo'; // Replace with your actual static resource name
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('select', {
            detail: { frameworkId: this.framework.Id }
        }));
    }
}
