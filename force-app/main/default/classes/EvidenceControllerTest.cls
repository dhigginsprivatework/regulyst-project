@isTest
private class EvidenceControllerTest {
    @isTest
    static void testCreateEvidenceWithFilesAndGetEvidence() {
        // Create Framework
        String uniqueExternalId = TestDataFactory.returnUniqueSuffixForExternalId(); 
        Framework__c fw = new Framework__c(Name = 'Test Framework', External_Id__c = uniqueExternalId );
        insert fw;

        // Create Project
        Project__c project = new Project__c(
            Name = 'Test Project Record',
            Standards_Alignment_Body__c = 'ISO ',
            Standards_Alignment_Framework__c = 'ISO 27001',
            Project_Focus__c = 'Compliance',
            Description__c = 'Test Project Description',
            Framework__c = fw.Id
        );
        insert project;

        // Create Project_Framework
        Project_Framework__c pf = new Project_Framework__c(
            Name = 'Test PF',
            Framework__c = fw.Id,
            Project__c = project.Id,
            Description__c = 'PF Desc',
            URL__c = 'https://example.com',
            Version__c = '1.0'
        );
        insert pf;

        // Create Project_Clause_Control_Domain
        Project_Clause_Control_Domain__c clause = new Project_Clause_Control_Domain__c(
            Name = 'Clause 1',
            Clause_Number__c = '5.1',
            Description__c = 'Clause Description',
            Project_Framework__c = pf.Id,
            Sequence__c = 1
        );
        insert clause;

        // Create dummy ContentVersion
        Blob fileBody = Blob.valueOf('Test file content');
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile.txt',
            PathOnClient = '/TestFile.txt',
            VersionData = fileBody
        );
        insert cv;

        // Retrieve ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocId = cv.ContentDocumentId;

        // Prepare mock file upload
        EvidenceController.FileUpload file = new EvidenceController.FileUpload();
        file.fileName = 'TestFile.txt';
        file.base64Data = EncodingUtil.base64Encode(fileBody);

        List<EvidenceController.FileUpload> files = new List<EvidenceController.FileUpload>{ file };

        Test.startTest();
        // Call createEvidenceWithFiles
        EvidenceController.createEvidenceWithFiles(
            clause.Id,
            'Project_Clause_Control_Domain__c',
            'Test Evidence Description',
            files
        );

        // Test getEvidenceForRecord
        List<EvidenceController.EvidenceWrapper> wrappers = EvidenceController.getEvidenceForRecord(clause.Id);
        Test.stopTest();

        // Verify Evidence__c was created
        List<Evidence__c> evidences = [
            SELECT Id, Description__c
            FROM Evidence__c
            WHERE Clause_Control_Domain_project__c = :clause.Id
        ];
        System.assertEquals(1, evidences.size());
        System.assertEquals('Test Evidence Description', evidences[0].Description__c);

        // Link ContentDocument manually for test
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = evidences[0].Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        // Re-fetch wrappers to verify document link
        wrappers = EvidenceController.getEvidenceForRecord(clause.Id);
        System.assertEquals(1, wrappers.size());
        System.assertEquals('Test Evidence Description', wrappers[0].evidenceDescription);
        System.assertEquals(contentDocId, wrappers[0].ContentDocumentId);
    }
}
