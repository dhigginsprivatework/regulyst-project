public class TestDataFactory {

    // Constants
    public static final String TEST_EVIDENCE_DESCRIPTION = 'Test Evidence Description';
    public static final String TEST_FILE_NAME = 'TestFile.txt';
    public static final String TEST_FILE_CONTENT = 'Test file content';

    // Generates a unique suffix using a cryptographically random integer and a time-based component
    public static String returnUniqueSuffixForExternalId() {
        return String.valueOf(Crypto.getRandomInteger()) + String.valueOf(Math.mod(DateTime.now().getTime(), 1000));
    }

    public static Framework__c createFrameworkWithChildren() {
        String uniqueSuffix = returnUniqueSuffixForExternalId();

        Framework__c fw = new Framework__c(
            Name = 'Test Framework ' + uniqueSuffix,
            Description__c = 'Desc',
            URL__c = 'http://example.com',
            Version__c = '1.0',
            External_Id__c = 'FW-' + uniqueSuffix
        );
        insert fw;

        List<Clause__c> clauses = new List<Clause__c>();
        for (Integer i = 1; i <= 2; i++) {
            clauses.add(new Clause__c(
                Name = 'Clause ' + i,
                Clause_Number__c = 'C' + i,
                Description__c = 'Clause Desc ' + i,
                Sequence__c = i,
                Framework__c = fw.Id,
                Clause_Unique_Id__c = 'CL-' + i + '-' + returnUniqueSuffixForExternalId()
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
                    Framework__c = fw.Id,
                    Control_Unique_Id__c = 'CTRL-' + clause.Clause_Number__c + '-' + j + '-' + returnUniqueSuffixForExternalId()
                ));
            }
        }
        insert controls;

        List<Control_Requirement__c> requirements = new List<Control_Requirement__c>();
        for (Control__c ctrl : controls) {
            requirements.add(new Control_Requirement__c(
                Name = 'Requirement',
                Description__c = 'Requirement Desc',
                Source__c = 'ISO 27001',
                Control__c = ctrl.Id,
                Framework__c = fw.Id,
                Control_Requirement_Unique_Id__c = 'REQ-' + ctrl.Control_Number__c + '-' + returnUniqueSuffixForExternalId()
            ));
        }
        insert requirements;

        return fw;
    }

    public static Project__c createTestProjectRecord(Framework__c fw){
        Project__c project = new Project__c(
            Name = 'Test Project Record',
            Standards_Alignment_Body__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_ISO,
            Standards_Alignment_Framework__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
            Project_Focus__c = ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO,
            Description__c = 'Test Project Description',
            Framework__c = fw.Id
        );
        insert project;
        return project; 
    }

    public static Project_Framework__c createTestProjectFrameworkRecord(Project__c project, Framework__c fw){
        Project_Framework__c pf = new Project_Framework__c(
            Name = 'Test PF',
            Framework__c = fw.Id,
            Project__c = project.Id,
            Description__c = 'PF Desc',
            URL__c = 'https://example.com',
            Version__c = '1.0'
        );
        insert pf; 
        return pf; 
    }

    public static Project_Clause_Control_Domain__c createTestProjectClauseControlDomain(Project_Framework__c pf){
        Project_Clause_Control_Domain__c clause = new Project_Clause_Control_Domain__c(
            Name = 'Clause 1',
            Clause_Number__c = '5.1',
            Description__c = 'Clause Description',
            Project_Framework__c = pf.Id,
            Sequence__c = 1
        );
        insert clause;
        return clause; 
    }

    public static Evidence__c createEvidence(Project_Clause_Control_Domain__c clause, String description) {
        Evidence__c evidence = new Evidence__c(
            Clause_Control_Domain_project__c = clause.Id,
            Description__c = description
        );
        insert evidence;
        return evidence;
    }

    public static ContentVersion createTestContentVersion(String title, String content) {
        Blob fileBody = Blob.valueOf(content);
        ContentVersion cv = new ContentVersion(
            Title = title,
            PathOnClient = '/' + title,
            VersionData = fileBody
        );
        insert cv;
        return [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
    }
}
