import { LightningElement, api } from 'lwc';

export default class FrameworkTile extends LightningElement {
    @api framework;
    @api selectedId;

    get isIsoFramework() {
        return this.framework.Name && this.framework.Name.includes('ISO 27001:2022 Controls Mapping to Information Security Control Domains');
    }

    get isNistIsoFramework() {
        return this.framework.Name && this.framework.Name.includes('NIST CSF 2.0 and ISO 27001:2022');
    }

    get isDoraIsoFramework() {
        return this.framework.Name && this.framework.Name.includes('EU DORA and ISO 27001:2022');
    }

    get isoImageUrl() {
        return '/resource/ISO_27001_Logo';
    }

    get nistIsoImageUrl() {
        return '/resource/NISTISO27001Logo';
    }

    get doraIsoImageUrl() {
        return '/resource/EUDORAISO27001Logo';
    }

    get tileClass() {
        return this.framework.Id === this.selectedId ? 'tile selected' : 'tile';
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('select', {
            detail: { frameworkId: this.framework.Id }
        }));
    }
}
