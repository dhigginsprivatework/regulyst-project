@isTest
private class EvidenceControllerTest {
    @isTest
    static void testCreateEvidenceWithFilesAndGetEvidence() {
        // Create framework and project using valid picklist values
        Framework__c fw = new Framework__c(Name = 'Test Framework');
        insert fw;

        Project__c project = new Project__c(
            Name = 'Test Project Record',
            Standards_Alignment_Body__c = 'ISO ',
            Standards_Alignment_Framework__c = 'ISO 27001',
            Project_Focus__c = 'Compliance',
            Description__c = 'Test Project Description',
            Framework__c = fw.Id
        );
        insert project;

        // Create a dummy ContentVersion to simulate file upload
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
        EvidenceController.createEvidenceWithFiles(
            project.Id,
            'Project_Control__c',
            'Test Evidence Description',
            files
        );
        Test.stopTest();

        // Verify Evidence__c was created
        List<Evidence__c> evidences = [SELECT Id, Description__c FROM Evidence__c WHERE Project_Control__c = :project.Id];
        System.assertEquals(1, evidences.size());
        System.assertEquals('Test Evidence Description', evidences[0].Description__c);

        // Link the ContentDocument to the Evidence manually for test
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = evidences[0].Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        // Test getEvidenceForRecord
        Test.startTest();
        List<EvidenceController.EvidenceWrapper> wrappers = EvidenceController.getEvidenceForRecord(project.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals('Test Evidence Description', wrappers[0].evidenceDescription);
        System.assertEquals(contentDocId, wrappers[0].ContentDocumentId);
    }
}
