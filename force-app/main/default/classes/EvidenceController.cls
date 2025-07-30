public with sharing class EvidenceController {
    public class FileUpload {
        @AuraEnabled public String fileName { get; set; }
        @AuraEnabled public String base64Data { get; set; }
    }

    @AuraEnabled
    public static void createEvidenceWithFiles(Id parentId, String parentType, String description, List<FileUpload> files) {
        System.debug('📦 Incoming files: ' + JSON.serialize(files));

        if (parentId == null || String.isBlank(parentType) || String.isBlank(description) || files == null || files.isEmpty()) {
            throw new AuraHandledException('Missing required input for evidence creation.');
        }

        Evidence__c evidence = new Evidence__c();
        evidence.Description__c = description;

        if (parentType == 'Project_Clause_Control_Domain__c') {
            evidence.Clause_Control_Domain_project__c = parentId;
        } else if (parentType == 'Project_Control__c') {
            evidence.Project_Control__c = parentId;
        } else if (parentType == 'Project_Control_Requirement__c') {
            evidence.Project_Control_Requirement__c = parentId;
        } else {
            throw new AuraHandledException('Unsupported parent type: ' + parentType);
        }

        insert evidence;

        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for (FileUpload f : files) {
            if (String.isNotBlank(f.base64Data) && String.isNotBlank(f.fileName)) {
                try {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = f.fileName;
                    cv.PathOnClient = '/' + f.fileName;
                    cv.VersionData = EncodingUtil.base64Decode(f.base64Data);
                    contentVersions.add(cv);
                } catch (Exception e) {
                    System.debug('⚠️ Failed to decode or prepare file: ' + f.fileName + ' - ' + e.getMessage());
                }
            } else {
                System.debug('⚠️ Skipped file due to missing data: ' + f.fileName);
            }
        }

        if (!contentVersions.isEmpty()) {
            insert contentVersions;

            Map<Id, Id> versionToDocumentMap = new Map<Id, Id>();
            for (ContentVersion cv : [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id IN :contentVersions
            ]) {
                versionToDocumentMap.put(cv.Id, cv.ContentDocumentId);
            }

            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            for (ContentVersion cv : contentVersions) {
                Id docId = versionToDocumentMap.get(cv.Id);
                if (docId != null) {
                    links.add(new ContentDocumentLink(
                        ContentDocumentId = docId,
                        LinkedEntityId = evidence.Id,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                } else {
                    System.debug('❌ No ContentDocumentId found for ContentVersion: ' + cv.Id);
                }
            }

            if (!links.isEmpty()) {
                insert links;
                System.debug('✅ Inserted ContentDocumentLinks: ' + links.size());
            } else {
                System.debug('❌ No ContentDocumentLinks created.');
            }
        } else {
            System.debug('❌ No ContentVersions created.');
        }
    }
}
