public class ClassTeamMemberSharingRecalculation implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Class__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Class__c> classes){
        //delete existing sharing records.
        List<Class__share> sharesToDelete = [SELECT Id FROM Class__share WHERE ParentId in :classes AND RowCause = :Schema.Class__share.rowCause.Class_Team__c];
        delete sharesToDelete;
        
        List<Class_Team_Member__c> teamMembers = [SELECT Id, Class__c, Team_Member__c, Access_Level__c FROM Class_Team_Member__c WHERE Class__c IN :classes];
        
        new ClassTeamMemberTriggerHandler().createShares(teamMembers);
    }    
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}