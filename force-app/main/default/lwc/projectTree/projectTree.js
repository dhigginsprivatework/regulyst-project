import {LightningElement,wire, api} from 'lwc';
import getProjectTree from '@salesforce/apex/ProjectTreeController.getFrameworkTree';
import {NavigationMixin} from 'lightning/navigation';

export default class ProjectTree extends NavigationMixin(LightningElement) {
   @api recordId; 
   treeData = [];

@wire(getProjectTree, { projectId: '$recordId' })
    wiredTree({ error, data }) {
        if (data) {
         console.log('data returned for Project Tree is',JSON.stringify(data)); 
            this.treeData = this.formatTree(data);
        } else if (error) {
            console.error('Error loading tree:', error);
        }
        else {
           console.warn('No data and no error returned from wire'); 
        }
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
               items: formattedChildren
            }];
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