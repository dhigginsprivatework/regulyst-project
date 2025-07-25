@isTest
public class TestDataFactory {
    public static Framework__c createFrameworkWithChildren() {
        Framework__c fw = new Framework__c(Name = 'Test Framework', Description__c = 'Desc', URL__c = 'http://example.com', Version__c = '1.0');
        insert fw;

        List<Clause__c> clauses = new List<Clause__c>();
        for (Integer i = 1; i <= 2; i++) {
            clauses.add(new Clause__c(
                Name = 'Clause ' + i,
                Clause_Number__c = 'C' + i,
                Description__c = 'Clause Desc ' + i,
                Sequence__c = i,
                Framework__c = fw.Id
            ));
        }
        insert clauses;

        List<Control__c> controls = new List<Control__c>();
        for (Clause__c clause : clauses) {
            for (Integer j = 1; j <= 2; j++) {
                controls.add(new Control__c(
                    Name = 'Control ' + j,
                    Control_Number__c = 'CTRL' + j,
                    Description__c = 'Control Desc ' + j,
                    Title__c = 'Title ' + j,
                    Clause__c = clause.Id,
                    Framework__c = fw.Id
                ));
            }
        }
        insert controls;

        List<Control_Requirement__c> requirements = new List<Control_Requirement__c>();
        for (Control__c ctrl : controls) {
            requirements.add(new Control_Requirement__c(
                Name = 'Requirement',
                Description__c = 'Requirement Desc',
                Source__c = 'Public',
                Control__c = ctrl.Id,
                Framework__c = fw.Id
            ));
        }
        insert requirements;

        return fw;
    }
}
