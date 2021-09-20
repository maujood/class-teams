trigger ClassTrigger on Class__c (before insert) {
    for (Class__c c : Trigger.new) {
        if (c.Description__c == null) {
            c.Description__c = c.Name;
        }
    }
}