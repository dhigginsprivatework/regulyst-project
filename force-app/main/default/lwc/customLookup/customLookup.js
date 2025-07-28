import { LightningElement, api, track } from 'lwc';
import searchFrameworks from '@salesforce/apex/ProjectController.searchFrameworks';

export default class CustomLookup extends LightningElement {
    @api label = 'Search Framework';
    @track searchKey = '';
    @track results = [];
    @track resultsSize = 0; 

    handleSearch(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length > 2) {
            searchFrameworks({ searchKey: this.searchKey })
                .then(data => this.results = data)
                .catch(() => this.results = []);  
        }
    }

    get hasResults() {
    return Array.isArray(this.results) && this.results.length > 0;
    }

    handleSelect(event) {
    let target = event.target;
    while (target && !target.dataset.id) {
        target = target.parentElement;
    }

    if (target) {
        const selectedId = target.dataset.id;
        const selectedName = target.dataset.name;

        this.dispatchEvent(new CustomEvent('frameworkselected', {
            detail: { frameworkId: selectedId, name: selectedName }
        }));

        // Optionally clear results after selection
        this.results = [];
        this.searchKey = selectedName;
    }
}

}