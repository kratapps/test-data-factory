/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
private class TestDataFactoryTest {
    private static final TestDataFactory factory = new TestDataFactory();
    private static final String NEW_DESCRIPTION = 'overridden desc';
    
    static void staticSetup() {
        SObjectFactoryLoader.isSObjPackageRunningTest = true;
    }

    @IsTest
    static void testCreateAccount() {
        staticSetup();
        Account created = (Account) factory.created(new Account()).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        System.assertEquals(null, created.Id);
        System.assert(queryAccounts().isEmpty());
        System.assertEquals(AccountFactory.NAME, created.Name);
        System.assertEquals(AccountFactory.DESCRIPTION, created.Description);
    }

    @IsTest
    static void testInsertContactsWithRotations() {
        staticSetup();
        Account acc = (Account) factory.inserted(new Account()).toSObject();
        List<Contact> created = (List<Contact>) factory
                .rotate(Contact.Description, new List<String>{
                        'desc 0', 'desc 1', 'desc 2'
                })
                .rotate(Contact.AccountId, new List<Account>{
                        acc, null
                })
                .inserted(5, new Contact())
                .toList();
        System.assertEquals(3, Limits.getDmlStatements()); // 1 for contact, 2 for accounts
        System.assertEquals(5, created.size());
        System.assertEquals(5, queryContacts().size());
        System.assertEquals(2, queryAccounts().size());
        System.assertNotEquals(null, created[0].Id);
        System.assertEquals('desc 0', created[0].Description);
        System.assertEquals('desc 1', created[1].Description);
        System.assertEquals('desc 2', created[2].Description);
        System.assertEquals('desc 0', created[3].Description);
        System.assertEquals('desc 1', created[4].Description);
        System.assertEquals(acc.Id, created[0].AccountId);
        System.assertNotEquals(acc.Id, created[1].AccountId);
        System.assertEquals(acc.Id, created[2].AccountId);
        System.assertNotEquals(acc.Id, created[3].AccountId);
        System.assertEquals(acc.Id, created[4].AccountId);
    }

    @IsTest
    static void testInsertContactsWithParentRotations() {
        List<Account> accounts = (List<Account>) factory
                .inserted(3, new Account())
                .toList();
        List<Contact> created = (List<Contact>) factory
                .rotate(Contact.AccountId, accounts)
                .inserted(3, new Contact())
                .toList();
        System.assertEquals(2, Limits.getDmlStatements());
        System.assertEquals(6, Limits.getDmlRows());
        List<Contact> contacts = queryContacts();
        System.assertEquals(accounts[0].Id, created[0].AccountId);
        System.assertEquals(accounts[0].Id, contacts[0].AccountId);
        System.assertEquals(accounts[1].Id, created[1].AccountId);
        System.assertEquals(accounts[1].Id, contacts[1].AccountId);
        System.assertEquals(accounts[2].Id, created[2].AccountId);
        System.assertEquals(accounts[2].Id, contacts[2].AccountId);
    }

    @IsTest
    static void testCreateContact() {
        staticSetup();
        Contact created = (Contact) factory.created(new Contact()).toSObject();
        System.assertEquals(1, Limits.getDmlStatements());
        System.assertEquals(null, created.Id);
        System.assertNotEquals(null, created.AccountId);
        System.assert(queryContacts().isEmpty());
        System.assertEquals(ContactFactory.FIRST_NAME, created.FirstName);
        System.assertEquals(ContactFactory.LAST_NAME, created.LastName);
    }

    @IsTest
    static void testInsertSObjectWithoutFactoryImpl() {
        staticSetup();
        User u = (User) factory.inserted(new User(
                Profile = [SELECT Id FROM Profile LIMIT 1]
        )).toSObject();
        System.assertEquals(1, Limits.getDmlStatements());
        System.assertNotEquals(null, u.Id);
        factory.inserted(new Case()).toSObject();
        factory.inserted(new Lead()).toSObject();
        factory.inserted(new Opportunity()).toSObject();
        factory.inserted(new Task()).toSObject();
    }

    @IsTest
    static void testCreateContactWithAccount() {
        staticSetup();
        Account createdAccount = (Account) factory.created(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.created(new Contact(Account = createdAccount)).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        System.assertEquals(0, Limits.getDmlRows());
        System.assertEquals(null, createdAccount.Id);
        System.assertEquals(null, createdContact.Id);
        System.assertEquals(ContactFactory.FIRST_NAME, createdContact.FirstName);
        System.assertEquals(ContactFactory.LAST_NAME, createdContact.LastName);
        System.assertEquals(AccountFactory.NAME, createdContact.Account.Name);
        System.assertEquals(NEW_DESCRIPTION, createdContact.Account.Description);
        System.assertEquals(createdAccount, createdContact.Account);
    }

    @IsTest
    static void testCreateContactWithAccountWithInsert() {
        staticSetup();
        Account createdAccount = (Account) factory.inserted(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.inserted(new Contact(Account = createdAccount)).toSObject();
        System.assertEquals(2, Limits.getDmlStatements());
        System.assertEquals(2, Limits.getDmlRows());
        System.assertNotEquals(null, createdAccount.Id);
        System.assertNotEquals(null, createdContact.Id);
        List<Contact> contacts = queryContacts();
        System.assertEquals(1, contacts.size());
        System.assertEquals(1, queryAccounts().size());
        System.assertEquals(ContactFactory.FIRST_NAME, createdContact.FirstName);
        System.assertEquals(ContactFactory.FIRST_NAME, contacts[0].FirstName);
        System.assertEquals(ContactFactory.LAST_NAME, createdContact.LastName);
        System.assertEquals(AccountFactory.NAME, createdContact.Account.Name);
        System.assertEquals(NEW_DESCRIPTION, contacts[0].Account.Description);
        System.assertEquals(NEW_DESCRIPTION, createdContact.Account.Description);
        System.assertEquals(createdAccount.Id, TestDataFactory.getRecord(createdAccount.Id).Id);
        System.assertEquals(createdContact.Id, TestDataFactory.getRecord(createdContact.Id).Id);
    }

    @IsTest
    static void testCreateContactWithAccountWithMockedInsert() {
        staticSetup();
        Account createdAccount = (Account) factory.mocked(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.mocked(new Contact(Account = createdAccount)).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        System.assertEquals(0, Limits.getDmlRows());
        System.assertNotEquals(null, createdAccount.Id);
        System.assertNotEquals(null, createdContact.Id);
        System.assertEquals(ContactFactory.FIRST_NAME, createdContact.FirstName);
        System.assertEquals(ContactFactory.LAST_NAME, createdContact.LastName);
        System.assertEquals(AccountFactory.NAME, createdContact.Account.Name);
        System.assertEquals(NEW_DESCRIPTION, createdContact.Account.Description);
    }

    @IsTest
    static void testCreateContactWithAccountMocked() {
        staticSetup();
        Account createdAccount = (Account) factory.mocked(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.mocked(new Contact(Account = createdAccount)).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        System.assertNotEquals(null, createdAccount.Id);
        System.assertNotEquals(null, createdContact.Id);
        List<Contact> contacts = queryContacts();
        System.assertEquals(0, contacts.size());
        System.assertEquals(ContactFactory.FIRST_NAME, createdContact.FirstName);
        System.assertEquals(ContactFactory.LAST_NAME, createdContact.LastName);
        System.assertEquals(AccountFactory.NAME, createdContact.Account.Name);
        System.assertEquals(NEW_DESCRIPTION, createdContact.Account.Description);
    }

    @IsTest
    static void testCreateAccountWithInsert() { 
        staticSetup();
        Account created = (Account) factory.inserted(new Account(
                Description = NEW_DESCRIPTION
        )).toSObject();
        System.assertEquals(1, Limits.getDmlStatements());
        List<Account> accounts = queryAccounts();
        System.assertNotEquals(null, created.Id);
        System.assertEquals(1, accounts.size());
        System.assertEquals(AccountFactory.NAME, accounts[0].Name);
        System.assertEquals(NEW_DESCRIPTION, accounts[0].Description);
        System.assertEquals(AccountFactory.NAME, created.Name);
        System.assertEquals(NEW_DESCRIPTION, created.Description);
    }

    @IsTest
    static void testCreateContactWithInsert() {
        staticSetup();
        Contact con1 = (Contact) factory.inserted(new Contact()).toSObject();
        Contact con2 = (Contact) factory.inserted(new Contact()).toSObject();
        System.assertEquals(3, Limits.getDmlStatements());
        System.assertEquals(con1.AccountId, con2.AccountId);
    }

    @IsTest
    static void testCreateAccountWithInsertBulk() {
        staticSetup();
        List<Account> created = (List<Account>) factory.inserted(200, new Account(
                Description = 'overridden desc'
        )).toList();
        System.assertEquals(1, Limits.getDmlStatements());
        List<Account> accounts = queryAccounts();
        System.assertEquals(200, created.size());
        System.assertEquals(200, accounts.size());
        System.assertNotEquals(null, created[0].Id);
        System.assertNotEquals(null, created[1].Id);
        System.assertNotEquals(null, created[199].Id);
        System.assertEquals(AccountFactory.NAME, accounts[0].Name);
        System.assertEquals(NEW_DESCRIPTION, accounts[0].Description);
        System.assertEquals(AccountFactory.NAME, created[0].Name);
        System.assertEquals(NEW_DESCRIPTION, created[0].Description);
    }

    @IsTest
    static void testCreateAccountWithMockedInsert() {
        staticSetup();
        Account created = (Account) factory.mocked(new Account(
                Description = 'overridden desc'
        )).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        List<Account> accounts = queryAccounts();
        System.assertEquals(0, accounts.size());
        System.assertNotEquals(null, created.Id);
        System.assertEquals(AccountFactory.NAME, created.Name);
        System.assertEquals(NEW_DESCRIPTION, created.Description);
    }

    @IsTest
    static void testSObjectFactoryScenario() {
        staticSetup();
        Account created = (Account) factory.useScenario(AccountScenario.class).created(new Account()).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        System.assertEquals(null, created.Id);
        System.assertEquals(AccountScenario.NAME, created.Name);
        System.assertEquals(null, created.Description);

        created = (Account) factory.useScenario(AccountScenario.class).created(new Account()).toSObject();
        System.assertEquals(0, Limits.getDmlStatements());
        System.assertEquals(null, created.Id);
        System.assertEquals(AccountScenario.NAME, created.Name);
        System.assertEquals(null, created.Description);
        
        try {
            factory.useScenario(AccountScenario.class).useScenario(AccountScenario.class);
            System.assert(false,' Exception expected');
        } catch (TestDataFactoryException e) {
            System.assertEquals('Scenario already set', e.getMessage());
        }
    }
     
    @IsTest
    static void testAbstract() {
        staticSetup();
        SObjectFactory f = (SObjectFactory) new SObjectFactoryLoader().loadSObjectFactory(Account.SObjectType);
        System.assertNotEquals(null, f.getDmlOptions());
        System.assertEquals(null, f.makeParent(Account.ParentId, new Account()));
        System.assert(f.requireRecordType());
        SObjectFactoryScenario s = (SObjectFactoryScenario) new SObjectFactoryLoader().loadScenario(AccountScenario.class);
        System.assertNotEquals(null, s.getDmlOptions());
        System.assertEquals(null, s.makeParent(Account.ParentId, new Account()));
        System.assert(s.requireRecordType());
    }

    static List<Account> queryAccounts() {
        return [SELECT Id, Name, Description FROM Account];
    }

    static List<Contact> queryContacts() {
        return [SELECT Id, FirstName, LastName, AccountId, Account.Name, Account.Description FROM Contact];
    }
}

