public with sharing class CopilotCalloutService {
    private static final String DEPLOYMENT_NAME = 'gpt-4.1';
    private static final String API_VERSION = '2023-05-15';
    private static final String API_KEY = AzureOpenAIConfig__c.getInstance().API_Key__c;


    @AuraEnabled
    public static String getCopilotResponse(String prompt, Id evidenceId) {
        // Step 1: Get the most recent file attached to the Evidence__c record
        ContentDocumentLink cdl = [
            SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :evidenceId
            ORDER BY ContentDocument.CreatedDate DESC 
            LIMIT 1
        ];

        ContentVersion cv = [
            SELECT VersionData, Title, FileType
            FROM ContentVersion
            WHERE Id = :cdl.ContentDocument.LatestPublishedVersionId
            LIMIT 1
        ];

        // Step 2: Convert file to base64 (you could also extract text externally)
        String base64Content = EncodingUtil.base64Encode(cv.VersionData);

        // Step 3: Construct prompt with file content
        String fullPrompt = prompt + '\n\nHere is the base64-encoded content of the attached file: \n' + base64Content;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://myopenaisalesforce.openai.azure.com/openai/deployments/' + DEPLOYMENT_NAME + '/chat/completions?api-version=' + API_VERSION;
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('api-key', API_KEY);

        Map<String, Object> body = new Map<String, Object>{
            'messages' => new List<Object>{
                new Map<String, String>{ 'role' => 'system', 'content' => 'You are a helpful assistant.' },
                new Map<String, String>{ 'role' => 'user', 'content' => fullPrompt }
            },
            'temperature' => 0.7,
            'max_tokens' => 500
        };

        request.setBody(JSON.serialize(body));
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> choices = (List<Object>) result.get('choices');
            if (!choices.isEmpty()) {
                Map<String, Object> choice = (Map<String, Object>) choices[0];
                Map<String, Object> message = (Map<String, Object>) choice.get('message');
                return (String) message.get('content');
            }
        }

        throw new AuraHandledException('Failed to get response from Copilot: ' + response.getBody());
    }
}