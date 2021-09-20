@isTest
public class ClassTeamMemberSharingRecalculationTest {
	@testSetup 
    public static void makeData() {
        List<Class__c> classes = new List<Class__c> {
            new Class__c(Name = 'Test Class 1'),
            new Class__c(Name = 'Test Class 2')
        };
        insert classes;
        
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> users = new List<User> {
            new User(Alias = 'test1', Email='classteammember1@testusers.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='classteammember1@testusers.com'),
            new User(Alias = 'test2', Email='classteammember2@testusers.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='classteammember2@testusers.com')
        };
        
        insert users;
    }
    
    @isTest
    public static void insertAndRecalculateSharing() {
        Class__c class1 = [SELECT Id FROM Class__c WHERE Name = 'Test Class 1'];
        Class__c class2 = [SELECT Id FROM Class__c WHERE Name = 'Test Class 2'];
        
        User user1 = [SELECT Id FROM User WHERE UserName = 'classteammember1@testusers.com'];
        User user2 = [SELECT Id FROM User WHERE UserName = 'classteammember2@testusers.com'];
        
        List<Class_Team_Member__c> members = new List<Class_Team_Member__c> {
            new Class_Team_Member__c(
            	Class__c = class1.Id,
                Team_Member__c = user1.Id,
                Access_Level__c = 'Read'
            ),
            new Class_Team_Member__c(
            	Class__c = class1.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Read'
            ),
            new Class_Team_Member__c(
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            ),
            new Class_Team_Member__c(
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Read'
            )
        };
            
        insert members;
        
        Test.startTest();
        
        List<Class__share> class1User1Share = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id AND UserOrGroupId = :user1.Id];
        List<Class__share> class1User2Share = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id AND UserOrGroupId = :user2.Id];
        List<Class__share> class2Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class2.Id];
        
        System.assertEquals(1, class1User1Share.size(), 'Class 1 did not have 1 share record for user 1');
        System.assertEquals(user1.Id, class1User1Share[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Read', class1User1Share[0].AccessLevel, 'Access level was not "Read" for class 1 and user 1');
        
        System.assertEquals(1, class1User2Share.size(), 'Class 1 did not have 1 share record for user 2');
        System.assertEquals(user2.Id, class1User2Share[0].UserOrGroupId, 'Share 1 was not shared with user 2');
        System.assertEquals('Read', class1User2Share[0].AccessLevel, 'Access level was not "Read" for class 1 and user 2');
        
        System.assertEquals(1, class2Shares.size(), 'Class 2 did not have 1 share record');
        System.assertEquals(user2.Id, class2Shares[0].UserOrGroupId, 'Share 2 was not shared with user 2');
        System.assertEquals('Edit', class2Shares[0].AccessLevel, 'Access level was not "Edit"');
        
        delete class1User1Share;
        delete class1User2Share;
        delete class2Shares;
        
		ClassTeamMemberSharingRecalculation recalcBatch = new ClassTeamMemberSharingRecalculation(); 
		Database.executeBatch(recalcBatch);
        
        Test.stopTest();
        
        class1User1Share = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id AND UserOrGroupId = :user1.Id];
        class1User2Share = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id AND UserOrGroupId = :user2.Id];
        class2Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class2.Id];
        
        System.assertEquals(1, class1User1Share.size(), 'Class 1 did not have 1 share record for user 1');
        System.assertEquals(user1.Id, class1User1Share[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Read', class1User1Share[0].AccessLevel, 'Access level was not "Read" for class 1 and user 1');
        
        System.assertEquals(1, class1User2Share.size(), 'Class 1 did not have 1 share record for user 2');
        System.assertEquals(user2.Id, class1User2Share[0].UserOrGroupId, 'Share 1 was not shared with user 2');
        System.assertEquals('Read', class1User2Share[0].AccessLevel, 'Access level was not "Read" for class 1 and user 2');
        
        System.assertEquals(1, class2Shares.size(), 'Class 2 did not have 1 share record');
        System.assertEquals(user2.Id, class2Shares[0].UserOrGroupId, 'Share 2 was not shared with user 2');
        System.assertEquals('Edit', class2Shares[0].AccessLevel, 'Access level was not "Edit"');
    }
}