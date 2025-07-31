import { LightningElement, api } from 'lwc';

export default class FrameworkTile extends LightningElement {
    @api framework;

    handleClick() {
        const event = new CustomEvent('select', {
            detail: { frameworkId: this.framework.Id }
        });
        this.dispatchEvent(event);
    }
}
