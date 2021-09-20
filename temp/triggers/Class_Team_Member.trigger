trigger Class_Team_Member on Class_Team_Member__c (after insert, after update, after delete) {
    ClassTeamMemberTriggerHandler handler = new ClassTeamMemberTriggerHandler();
    if (Trigger.isInsert && Trigger.isAfter) {
        handler.createShares(Trigger.new);
    }
    else if (Trigger.isUpdate) {
        handler.updateShares(Trigger.new, Trigger.oldMap);
    }
    else if (Trigger.isDelete && Trigger.isAfter) {
        handler.adjustSharesForDeletedMembers(Trigger.old);
    }
}