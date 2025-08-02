@IsTest
private class EvidenceControllerTest {

    @IsTest
    static void testCreateEvidenceWithFilesAndGetEvidence() {
        // Setup test data
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw);
        Project_Framework__c pf = TestDataFactory.createTestProjectFrameworkRecord(project, fw);
        Project_Clause_Control_Domain__c clause = TestDataFactory.createTestProjectClauseControlDomain(pf);

        // Create dummy file
        ContentVersion cv = TestDataFactory.createTestContentVersion(
            TestDataFactory.TEST_FILE_NAME,
            TestDataFactory.TEST_FILE_CONTENT
        );
        Id contentDocId = cv.ContentDocumentId;

        // Prepare mock file upload
        EvidenceController.FileUpload file = new EvidenceController.FileUpload();
        file.fileName = TestDataFactory.TEST_FILE_NAME;
        file.base64Data = EncodingUtil.base64Encode(Blob.valueOf(TestDataFactory.TEST_FILE_CONTENT));

        List<EvidenceController.FileUpload> files = new List<EvidenceController.FileUpload>{ file };

        Test.startTest();
        EvidenceController.createEvidenceWithFiles(
            clause.Id,
            'Project_Clause_Control_Domain__c',
            TestDataFactory.TEST_EVIDENCE_DESCRIPTION,
            files
        );
        List<EvidenceController.EvidenceWrapper> wrappers = EvidenceController.getEvidenceForRecord(clause.Id);
        Test.stopTest();

        System.assertEquals(1, wrappers.size());
        System.assertEquals(TestDataFactory.TEST_EVIDENCE_DESCRIPTION, wrappers[0].evidenceDescription);

        // Link ContentDocument manually
        Evidence__c evidence = [SELECT Id FROM Evidence__c WHERE Clause_Control_Domain_project__c = :clause.Id LIMIT 1];
        insert new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = evidence.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        // Re-fetch wrappers to verify document link
        wrappers = EvidenceController.getEvidenceForRecord(clause.Id);
        System.assertEquals(contentDocId, wrappers[0].ContentDocumentId);
    }
}
