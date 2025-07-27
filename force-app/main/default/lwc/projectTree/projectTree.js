import { LightningElement, wire } from 'lwc';
import getProjectTree from '@salesforce/apex/ProjectTreeController.getFrameworkTree';
import { NavigationMixin } from 'lightning/navigation';

export default class ProjectTree extends NavigationMixin(LightningElement) {
    treeData = [];

    @wire(getProjectTree)
    wiredTree({ error, data }) {
        if (data) {
            this.treeData = this.formatTree(data);
            console.log('this.treeData', JSON.stringify(this.treeData));
        } else if (error) {
            console.error('Error loading tree:', error);
        }
    }

    formatTree(nodes) {
        return nodes.map(node => ({
            label: node.label,
            name: node.id,
            sObjectType: node.sObjectType,
            items: this.formatTree(node.children || [])
        }));
    }

    handleSelect(event) {
    const nodeId = event.detail.name;
    const node = this.findNodeById(this.treeData, nodeId);
    if (node) {
        console.log('Navigating to:', node.name, node.sObjectType);

        try {
            thisNavigationMixin.Navigate;
        } catch (e) {
            console.error('NavigationMixin failed, falling back to URL:', e);
            window.open(`/lightning/r/${node.sObjectType}/${node.name}/view`, '_blank');
        }
    }
}


    findNodeById(nodes, id) {
        for (let node of nodes) {
            if (node.name === id) return node;
            const found = this.findNodeById(node.items || [], id);
            if (found) return found;
        }
        return null;
    }
}
