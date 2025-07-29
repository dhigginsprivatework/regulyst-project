import { LightningElement, wire, api, track } from 'lwc';
import getProjectTree from '@salesforce/apex/ProjectTreeController.getFrameworkTree';
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import SELECTED_RECORD_CHANNEL from '@salesforce/messageChannel/SelectedRecord__c';


export default class ProjectTree extends NavigationMixin(LightningElement) {
    @api recordId;
    @track treeData = [];
    @track filteredTreeData = [];
    @track searchTerm = '';
    isLoading = true;
    @wire(MessageContext)
    messageContext;

    

    @wire(getProjectTree, { projectId: '$recordId' })
    wiredTree({ error, data }) {
        this.isLoading = false;
        if (data) {
            //console.log('data returned for Project Tree is', JSON.stringify(data));
            this.treeData = this.formatTree(data);
            this.filteredTreeData = this.treeData;
        } else if (error) {
            console.error('Error loading tree:', error);
        } else {
            console.warn('No data and no error returned from wire');
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        if (!this.searchTerm) {
            this.filteredTreeData = this.treeData;
        } else {
            this.filteredTreeData = this.filterTree(this.treeData, this.searchTerm);
        }
    }

    filterTree(nodes, term) {
        const filtered = [];

        for (const node of nodes) {
            const labelMatch = node.label.toLowerCase().includes(term);
            const childMatches = node.items ? this.filterTree(node.items, term) : [];

            if (labelMatch || childMatches.length > 0) {
                filtered.push({
                    ...node,
                    expanded: true,
                    items: childMatches
                });
            }
        }

        return filtered;
    }

    formatTree(nodes) {
        return nodes.map(node => {
            const children = node.children || [];
            let formattedChildren = this.formatTree(children);

            let headingLabel;
            switch (node.sObjectType) {
                case 'Project_Framework__c':
                    headingLabel = 'Clause Domains';
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

            if (headingLabel && formattedChildren.length > 0) {
                formattedChildren = [{
                    label: headingLabel,
                    name: `${node.name}-heading`,
                    sObjectType: 'Heading',
                    expanded: true,
                    items: formattedChildren,
                    iconName: 'utility:chevronright'
                }];
            }

            return {
                label: node.label,
                name: node.id,
                sObjectType: node.sObjectType,
                expanded: false,
                iconName: this.getIconForType(node.sObjectType),
                items: formattedChildren
            };
        });
    }

    getIconForType(type) {
        switch (type) {
            case 'Project_Framework__c':
                return 'standard:product';
            case 'Project_Clause_Control_Domain__c':
                return 'standard:topic';
            case 'Project_Control__c':
                return 'standard:task';
            case 'Project_Control_Requirement__c':
                return 'standard:check';
            default:
                return 'utility:record';
        }
    }

    /*handleSelect(event) {
        const nodeId = event.detail.name;
        const node = this.findNodeById(this.treeData, nodeId);
        if (node) {
            try {
                thisNavigationMixin.Navigate;
            } catch (e) {
                console.error('NavigationMixin failed, falling back to URL:', e);
                window.open(`/lightning/r/${node.sObjectType}/${node.name}/view`, '_blank');
            }
        }
    }*/ 

        
    handleSelect(event) {
        const nodeId = event.detail.name;
        const node = this.findNodeById(this.treeData, nodeId);
        if (node && node.sObjectType !== 'Heading') {
            publish(this.messageContext, SELECTED_RECORD_CHANNEL, {
                recordId: node.name,
                sObjectType: node.sObjectType
            });
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

    expandAll() {
        this.filteredTreeData = this.toggleExpandCollapse(this.filteredTreeData, true);
    }

    collapseAll() {
        this.filteredTreeData = this.toggleExpandCollapse(this.filteredTreeData, false);
    }

    toggleExpandCollapse(nodes, expand) {
        return nodes.map(node => {
            const updatedNode = {
                ...node,
                expanded: expand
            };
            if (node.items && node.items.length > 0) {
                updatedNode.items = this.toggleExpandCollapse(node.items, expand);
            }
            return updatedNode;
        });
    }
}
