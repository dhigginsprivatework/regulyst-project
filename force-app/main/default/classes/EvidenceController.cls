public with sharing class EvidenceController {
    public class FileUpload {
        @AuraEnabled public String fileName { get; set; }
        @AuraEnabled public String base64Data { get; set; }
    }

    public class EvidenceWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String evidenceDescription;
        @AuraEnabled public Id ContentDocumentId;

        public EvidenceWrapper(Id id, String evidenceDescription, Id contentDocId) {
            this.Id = id;
            this.evidenceDescription = evidenceDescription;
            this.ContentDocumentId = contentDocId;
        }
    }

    @AuraEnabled
    public static void createEvidenceWithFiles(Id parentId, String parentType, String description, List<FileUpload> files) {
        System.debug('📦 Incoming files: ' + JSON.serialize(files));

        if (parentId == null || String.isBlank(parentType) || String.isBlank(description) || files == null || files.isEmpty()) {
            throw new AuraHandledException('Missing required input for evidence creation.');
        }

        Evidence__c evidence = new Evidence__c();
        evidence.Description__c = description;
        evidence.Status__c = 'Evidence Submitted'; 
        

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

    @AuraEnabled(cacheable=true)
    public static List<EvidenceWrapper> getEvidenceForRecord(Id parentId) {
        List<Evidence__c> evidenceRecords = [
            SELECT Id, Description__c,
                (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 1)
            FROM Evidence__c
            WHERE Clause_Control_Domain_project__c = :parentId
               OR Project_Control__c = :parentId
               OR Project_Control_Requirement__c = :parentId
        ];

        List<EvidenceWrapper> wrappers = new List<EvidenceWrapper>();
        for (Evidence__c ev : evidenceRecords) {
            Id docId = (ev.ContentDocumentLinks.size() > 0) ? ev.ContentDocumentLinks[0].ContentDocumentId : null;
            wrappers.add(new EvidenceWrapper(ev.Id, ev.Description__c, docId));
        }
        return wrappers;
    }
}
