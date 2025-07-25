public class CreateProjectJob implements Queueable {
    String body;
    String framework;
    String focus;
    String description;
    Id frameworkId;

    public CreateProjectJob(String body, String framework, String focus, String description, Id frameworkId) {
        this.body = body;
        this.framework = framework;
        this.focus = focus;
        this.description = description;
        this.frameworkId = frameworkId;
    }

    public void execute(QueueableContext context) {
        Framework__c fw = [SELECT Id, Name, Description__c, URL__c, Version__c FROM Framework__c WHERE Id = :frameworkId LIMIT 1];
        Project__c project = new Project__c(
            Name = fw.Name,
            Standards_Alignment_Body__c = body,
            Standards_Alignment_Framework__c = framework,
            Project_Focus__c = focus,
            Description__c = description,
            Framework__c = fw.Id
        );
        insert project;

        Project_Framework__c pf = new Project_Framework__c(
            Name = fw.Name,
            Description__c = fw.Description__c,
            URL__c = fw.URL__c,
            Version__c = fw.Version__c,
            Framework__c = fw.Id,
            Project__c = project.Id
        );
        insert pf;

        List<Clause__c> clauseList = [SELECT Id, Name, Clause_Number__c, Description__c, Sequence__c FROM Clause__c WHERE Framework__c = :fw.Id];
        List<Project_Clause_Control_Domain__c> clauses = new List<Project_Clause_Control_Domain__c>();
        Map<Id, Id> clauseMap = new Map<Id, Id>();

        for (Clause__c c : clauseList) {
            Project_Clause_Control_Domain__c pc = new Project_Clause_Control_Domain__c(
                Name = c.Name,
                Clause_Number__c = c.Clause_Number__c,
                Description__c = c.Description__c,
                Sequence__c = c.Sequence__c,
                Project_Framework__c = pf.Id
            );
            clauses.add(pc);
        }
        insert clauses;

        for (Integer i = 0; i < clauseList.size(); i++) {
            clauseMap.put(clauseList[i].Id, clauses[i].Id);
        }

        List<Control__c> controlList = [SELECT Id, Name, Clause__c, Control_Number__c, Description__c, Title__c FROM Control__c WHERE Framework__c = :fw.Id];
        List<Project_Control__c> controls = new List<Project_Control__c>();
        Map<Id, Id> controlMap = new Map<Id, Id>();

        for (Control__c ctrl : controlList) {
            Project_Control__c pc = new Project_Control__c(
                Name = ctrl.Name,
                Control_Number__c = ctrl.Control_Number__c,
                Description__c = ctrl.Description__c,
                Title__c = ctrl.Title__c,
                Project_Framework__c = pf.Id,
                Clause_Control_Domain__c = clauseMap.get(ctrl.Clause__c)
            );
            controls.add(pc);
        }
        insert controls;

        for (Integer i = 0; i < controlList.size(); i++) {
            controlMap.put(controlList[i].Id, controls[i].Id);
        }

        List<Control_Requirement__c> requirementList = [SELECT Id, Name, Description__c, Source__c, Control__c FROM Control_Requirement__c WHERE Control__c IN :controlMap.keySet()];
        List<Project_Control_Requirement__c> requirements = new List<Project_Control_Requirement__c>();

        for (Control_Requirement__c req : requirementList) {
            requirements.add(new Project_Control_Requirement__c(
                Name = req.Name,
                Description__c = req.Description__c,
                Source__c = req.Source__c,
                Project_Control__c = controlMap.get(req.Control__c)
            ));
        }
        insert requirements;
    }
}
