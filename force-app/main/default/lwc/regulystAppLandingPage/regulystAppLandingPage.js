import { LightningElement } from 'lwc';
import LOGO from '@salesforce/resourceUrl/RegulystOfficialLogo';

export default class RegulystLandingPage extends LightningElement {
    logoUrl = LOGO;

    tiles = [
        { label: 'Frameworks', icon: 'utility:home', url: '/lightning/n/Framework_Admin' },
        { label: 'Projects', icon: 'utility:company', url: '/lightning/n/Projects' },
        { label: 'Controls', icon: 'utility:user', url: '/lightning/n/Controls' },
        { label: 'Control Requirements', icon: 'utility:briefcase', url: '/lightning/n/Control_Requirements' },
        { label: 'Evidence', icon: 'utility:chart_pie', url: '/lightning/n/Evidence' },
        { label: 'Reports', icon: 'utility:chart', url: '/lightning/n/Reports' }
    ];

    handleNavigate(event) {
        const url = event.currentTarget.dataset.url;
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { url }
        }));
    }
}
