public class ClassTeamMemberTriggerHandler {
    /**
     * insert sharing records for the given team members
     */
    public void createShares(List<Class_Team_Member__c> teamMembers) {
        List<Class__share> sharesToInsert = new List<Class__share>();
        Set<String> insertedParentAndUser = new Set<String>();
        
        for (Class_Team_Member__c tm : teamMembers) {
            String parentAndUser = String.valueOf(tm.Class__c) + String.valueOf(tm.Team_Member__c);
            //do not insert a READ record if something has already been inserted.
            if (insertedParentAndUser.contains(parentAndUser) && tm.Access_Level__c == 'Read') continue;
            sharesToInsert.add(new Class__share(
            	//ParentId, UserOrGroupId, AccessLevel, RowCause
            	ParentId = tm.Class__c,
                UserOrGroupId = tm.Team_Member__c,
                AccessLevel = tm.Access_Level__c,
                RowCause = Schema.Class__share.rowCause.Class_Team__c
            ));
            insertedParentAndUser.add(parentAndUser);
        }
        insert sharesToInsert;
    }
    
    /**
     * If a team member is deleted, delete the associated sharing record.. 
     * Unless there exists *another* team member entry giving access to
     * the same record for the same user. If another entry for the same user
     * exists, either leave the share record as-is or update it
     */
    public void adjustSharesForDeletedMembers(List<Class_Team_Member__c> deletedMembers) {
        Set<Id> userOrGroupIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Map<String, String> deletedUserToAccessLevelMap = new Map<String, String>();
        for (Class_Team_Member__c member : deletedMembers) {
            userOrGroupIds.add(member.Team_Member__c);
            parentIds.add(member.Class__c);
            deletedUserToAccessLevelMap.put(String.valueOf(member.Class__c) + String.valueOf(member.Team_Member__c), member.Access_Level__c);
        }

        List<Class_Team_Member__c> remainingMembers = [SELECT Class__c, Team_Member__c, Access_Level__c FROM Class_Team_Member__c WHERE Class__c in :parentIds AND Team_Member__c in :userOrGroupIds];
		// ^ The list above will contain all team member records which are giving access through another row. These are the cases in which the shares shouldn't be deleted.
		
        Map<String, String> userToAccessLevelMap = new Map<String, String>();
        for (Class_Team_Member__c member : remainingMembers) {
            String key = String.valueOf(member.Class__c) + String.valueOf(member.Team_Member__c);
            if (!userToAccessLevelMap.containsKey(key) || (userToAccessLevelMap.get(key) == 'Read' && member.Access_Level__c == 'Edit')) {
                userToAccessLevelMap.put(key, member.Access_Level__c);
            }
        }
        
        List<Class__share> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId in :parentIds AND UserOrGroupId in :userOrGroupIds];
        
        List<Class__share> sharesToDelete = new List<Class__share>();
        List<Class__share> sharesToUpdate = new List<Class__share>();
        
        for (Class__share share : currentShares) {
            String key = String.valueOf(share.ParentId) + String.valueOf(share.UserOrGroupId);
            if (deletedUserToAccessLevelMap.containsKey(key)) {
                if (!userToAccessLevelMap.containsKey(key)) {
                    sharesToDelete.add(share);
                }
                else if (userToAccessLevelMap.get(key) != deletedUserToAccessLevelMap.get(key)) {
                    share.AccessLevel = userToAccessLevelMap.get(key);
                    sharesToUpdate.add(share);
                }
            }
        }
        delete sharesToDelete;
        update sharesToUpdate;
    }
    
    public void updateShares(List<Class_Team_Member__c> updatedMembers, Map<Id, Class_Team_Member__c> oldMap) {
        //Create map of access level for 
        List<Class_Team_Member__c> sharingToRemove = new List<Class_Team_Member__c>();
        List<Class_Team_Member__c> sharingToInsert = new List<Class_Team_Member__c>();
        
        for (Class_Team_Member__c member : updatedMembers) {
            Class_Team_Member__c oldMember = oldMap.get(member.Id);
            if (member.Team_Member__c != oldMember.Team_Member__c 
                || member.Class__c != oldMember.Class__c
                || member.Access_Level__c != oldMember.Access_Level__c) {
                //delete the current sharing record IF there does not exist another Class Team Member that warrants keeping the current record
                //insert a new sharing record IF there does not exist another Class Team Member that gives current or higher access to the user
                sharingToRemove.add(oldMember);
                sharingToInsert.add(member);
            }
        }
        
        adjustSharesForDeletedMembers(sharingToRemove);
        createShares(sharingToInsert);
    }
}