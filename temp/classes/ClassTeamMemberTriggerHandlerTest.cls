@isTest
public class ClassTeamMemberTriggerHandlerTest {
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
    
    /**
     * GIVEN 2 Class records
     * AND 2 Users
     * WHEN user 1 is added as a team member on Class 1 with READ access
     * AND user 2 is added as a team member on Class 2 with EDIT access
     * THEN the system should create 2 share records
     */
    @isTest
    public static void testTeamMemberInsert() {
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
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
            
        insert members;
        
        List<Class__share> class1Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id];
        List<Class__share> class2Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class2.Id];
        
        System.assertEquals(1, class1Shares.size(), 'Class 1 did not have 1 share record');
        System.assertEquals(user1.Id, class1Shares[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Read', class1Shares[0].AccessLevel, 'Access level was not "Read"');
        
        System.assertEquals(1, class2Shares.size(), 'Class 2 did not have 1 share record');
        System.assertEquals(user2.Id, class2Shares[0].UserOrGroupId, 'Share 2 was not shared with user 2');
        System.assertEquals('Edit', class2Shares[0].AccessLevel, 'Access level was not "Edit"');
    }
    
    @isTest
    public static void testTeamMemberDuplicateInsert() {
        Class__c class1 = [SELECT Id FROM Class__c WHERE Name = 'Test Class 1'];
        
        User user1 = [SELECT Id FROM User WHERE UserName = 'classteammember1@testusers.com'];
        
        List<Class_Team_Member__c> members = new List<Class_Team_Member__c> {
            new Class_Team_Member__c(
            	Class__c = class1.Id,
                Team_Member__c = user1.Id,
                Access_Level__c = 'Edit'
            ),
            new Class_Team_Member__c(
            	Class__c = class1.Id,
                Team_Member__c = user1.Id,
                Access_Level__c = 'Read'
            )
        };
            
        insert members;
        
        List<Class__share> class1Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id];
        
        System.assertEquals(1, class1Shares.size(), 'Class 1 did not have 1 share record');
        System.assertEquals(user1.Id, class1Shares[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Edit', class1Shares[0].AccessLevel, 'Access level was not "Edit"');
    }
    
    /**
     * GIVEN 2 Class records
     * AND 2 Users
     * WHEN user 1 & 2 are added as a team member on Class 1 with READ access
     * AND user 2 is added as a team member on Class 2 with EDIT access
     * THEN the system should create 3 share records with the correct access to class 1 and 2
     */
    @isTest
    public static void testTeamMemberInsert2() {
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
            )
        };
            
        insert members;
        
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
    }
    
    /**
     * GIVEN 1 Class record
     * AND 2 Users
     * WHEN user 1 & 2 are added as a team member on Class 1 with READ access
     * AND user 2 is added to the same class with EDIT access
     * THEN the system should create 2 share records giving user 1 read and user 2 edit access
     */
    @isTest
    public static void testTeamMemberConflictingInsert() {
        Class__c class1 = [SELECT Id FROM Class__c WHERE Name = 'Test Class 1'];
        
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
            	Class__c = class1.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
            
        insert members;
        
        List<Class__share> allClassShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id];
        List<Class__share> class1User1Share = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id AND UserOrGroupId = :user1.Id];
        List<Class__share> class1User2Share = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id AND UserOrGroupId = :user2.Id];
        
        System.assertEquals(2, allClassShares.size(), 'Class 2 did not have 2 shares');
        
        System.assertEquals(1, class1User1Share.size(), 'Class 1 did not have 1 share record for user 1');
        System.assertEquals(user1.Id, class1User1Share[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Read', class1User1Share[0].AccessLevel, 'Access level was not "Read" for class 1 and user 1');
        
        System.assertEquals(1, class1User2Share.size(), 'Class 1 did not have 1 share record for user 2');
        System.assertEquals(user2.Id, class1User2Share[0].UserOrGroupId, 'Share 1 was not shared with user 2');
        System.assertEquals('Edit', class1User2Share[0].AccessLevel, 'Access level was not "Edit" for class 1 and user 2');
    }
    
    @isTest
    public static void testTeamMemberDelete() {
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
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
            
        insert members;
        List<Class__share> classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(2, classShares.size(), 'Class should have had 2 share records');
        
        delete members;
        classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(0, classShares.size(), 'Class should have had 0 share records');
    }
    
    @isTest
    public static void testTeamMemberDeleteShareAdjustScenario() {
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
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
        
		List<Class_Team_Member__c> members2 = new List<Class_Team_Member__c> {
            new Class_Team_Member__c(
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Read'
            )
        };
            
        insert members;
        insert members2;
        List<Class__share> classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(2, classShares.size(), 'Class should have had 2 share records');
        
        delete members;
        classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(1, classShares.size(), 'Class should have had 1 share records');
        System.assertEquals(class2.Id, classShares[0].ParentId, 'Share record did not have Class 2 as Parent');
        System.assertEquals(user2.Id, classShares[0].UserOrGroupId, 'Share record was not sharing with User 2');
        System.assertEquals('Read', classShares[0].AccessLevel, 'Access Level was not "Read"');
        
        delete members2;
        classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(0, classShares.size(), 'Class should have had 0 share records');
    }
    
    @isTest
    public static void testTeamMemberDeleteShareIgnoreScenario() {
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
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
        
		List<Class_Team_Member__c> members2 = new List<Class_Team_Member__c> {
            new Class_Team_Member__c(
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
            
        insert members;
        insert members2;
        List<Class__share> classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(2, classShares.size(), 'Class should have had 2 share records');
        
        delete members;
        classShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c'];
        System.assertEquals(1, classShares.size(), 'Class should have had 1 share records');
        System.assertEquals(class2.Id, classShares[0].ParentId, 'Share record did not have Class 2 as Parent');
        System.assertEquals(user2.Id, classShares[0].UserOrGroupId, 'Share record was not sharing with User 2');
        System.assertEquals('Edit', classShares[0].AccessLevel, 'Access Level was not "Read"');
    }
    
    @isTest
    public static void testTeamMemberUpdateAccess() {
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
            	Class__c = class2.Id,
                Team_Member__c = user2.Id,
                Access_Level__c = 'Edit'
            )
        };
            
        insert members;
        
        List<Class__share> class1Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id];
        List<Class__share> class2Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class2.Id];
        
        System.assertEquals(1, class1Shares.size(), 'Class 1 did not have 1 share record');
        System.assertEquals(user1.Id, class1Shares[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Read', class1Shares[0].AccessLevel, 'Access level was not "Read"');
        
        System.assertEquals(1, class2Shares.size(), 'Class 2 did not have 1 share record');
        System.assertEquals(user2.Id, class2Shares[0].UserOrGroupId, 'Share 2 was not shared with user 2');
        System.assertEquals('Edit', class2Shares[0].AccessLevel, 'Access level was not "Edit"');
        
        members[0].Access_Level__c = 'Edit';
        update members[0];
        
        class1Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id];
        System.assertEquals(1, class1Shares.size(), 'Class 1 did not have 1 share record');
        System.assertEquals(user1.Id, class1Shares[0].UserOrGroupId, 'Share 1 was not shared with user 1');
        System.assertEquals('Edit', class1Shares[0].AccessLevel, 'Access level was not "Edit"');
        
        members[0].Access_Level__c = 'Read';
		members[0].Class__c = class2.Id;
        members[0].Team_Member__c = user2.Id;
        update members[0];
        
        class1Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class1.Id];
        class2Shares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Class__share WHERE RowCause = 'Class_Team__c' AND ParentId = :class2.Id];
        
        System.assertEquals(0, class1Shares.size(), 'Class 1 did not have 0 share records');
        
        System.assertEquals(1, class2Shares.size(), 'Class 2 did not have 1 share record');
        System.assertEquals(user2.Id, class2Shares[0].UserOrGroupId, 'Share 2 was not shared with user 2');
        System.assertEquals('Read', class2Shares[0].AccessLevel, 'Access level was not "Edit"');
        
        //members[0].Team_Member__c = user1.Id;
    }
}