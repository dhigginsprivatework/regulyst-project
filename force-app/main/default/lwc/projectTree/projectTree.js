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

    /*formatTree(nodes) {
        return nodes.map(node => ({
            label: node.label,
            name: node.id,
            sObjectType: node.sObjectType,
            items: this.formatTree(node.children || [])
        }));
    }*/

        formatTree(nodes) {
    return nodes.map(node => {
        const children = node.children || [];

        // Recursively format children first
        let formattedChildren = this.formatTree(children);

        // Determine heading label based on current node type
        let headingLabel;
        switch (node.sObjectType) {
            case 'Project_Framework__c':
                headingLabel = 'Clause/Control Domains';
                break;
            case 'Project_Clause_Control_Domain__c':
                headingLabel = 'Controls';
                break;
            case 'Project_Control__c':
                headingLabel = 'Control Requirements';
                break;
            default:
                headingLabel = null;
        }

        // Inject heading node if applicable
        if (headingLabel && formattedChildren.length > 0) {
            formattedChildren = [
                {
                    label: headingLabel,
                    name: `${node.name}-heading`,
                    sObjectType: 'Heading',
                    expanded: true,
                    items: formattedChildren
                }
            ];
        }

        return {
            label: node.label,
            name: node.id,
            sObjectType: node.sObjectType,
            items: formattedChildren
        };
    });
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
