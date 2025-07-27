public with sharing class ProjectTeamController {@AuraEnabled(cacheable = true)
  public static List < Project_Team__c > getTeamMembers(Id projectId) {
    return [
    SELECT Id, User__c, User__r.Name, Role__c
    FROM Project_Team__c
    WHERE Project__c = :projectId
    ORDER BY CreatedDate DESC];
  }

  @AuraEnabled
  public static Project_Team__c addTeamMember(Id projectId, Id userId, String role) {
    Project_Team__c teamMember = new Project_Team__c(
    Project__c = projectId, User__c = userId, Role__c = role);
    insert teamMember;
    return teamMember;
  }

  @AuraEnabled
  public static void deleteTeamMember(Id teamMemberId) {
      delete [SELECT Id FROM Project_Team__c WHERE Id = :teamMemberId];
  }

  @AuraEnabled
  public static void updateTeamMember(Id teamMemberId, Id userId, String role) {
      Project_Team__c pt = [SELECT Id FROM Project_Team__c WHERE Id = :teamMemberId];
      pt.User__c = userId;
      pt.Role__c = role;
      update pt;
  }

}