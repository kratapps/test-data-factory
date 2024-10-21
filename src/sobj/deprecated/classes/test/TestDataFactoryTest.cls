/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
private class TestDataFactoryTest {
    private static final TestDataFactory factory = new TestDataFactory();
    private static final String NEW_DESCRIPTION = 'overridden desc';
    private static final Organization org = [SELECT NamespacePrefix FROM Organization LIMIT 1];

    static void staticSetup() {
        factory.setNamespace(org.NamespacePrefix);
    }

    @IsTest
    static void testCreateAccount() {
        staticSetup();
        Account created = (Account) factory.created(new Account()).toSObject();
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.areEqual(null, created.Id);
        Assert.isTrue(queryAccounts().isEmpty());
        Assert.areEqual('Acme', created.Name);
        Assert.areEqual('description', created.Description);
    }

    @IsTest
    static void testCreateCustomMetadata() {
        staticSetup();
        List<Test_Data_Factory_Default__mdt> created = (List<Test_Data_Factory_Default__mdt>) factory
            .rotate(Test_Data_Factory_Default__mdt.Field_API_Name__c, new List<String>{ 'Name', 'Description' })
            .created(2, new Test_Data_Factory_Default__mdt(SObject_API_Name__c = 'Account'))
            .toList();
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.isTrue(queryAccounts().isEmpty());
        Assert.areEqual('Name', created[0].Field_API_Name__c);
        Assert.areEqual('Description', created[1].Field_API_Name__c);
        Assert.areEqual('Account', created[0].SObject_API_Name__c);
        Assert.areEqual('Account', created[1].SObject_API_Name__c);
        Test_Data_Factory_Default__mdt mocked = (Test_Data_Factory_Default__mdt) factory
            .mocked(new Test_Data_Factory_Default__mdt())
            .toSObject();
    }

    @IsTest
    static void testInsertContactsWithRotations() {
        staticSetup();
        Account acc = (Account) factory.inserted(new Account()).toSObject();
        List<Contact> created = (List<Contact>) factory
            .rotate(Contact.Description, new List<String>{ 'desc 0', 'desc 1', 'desc 2' })
            .rotate(Contact.AccountId, new List<Account>{ acc, null })
            .inserted(5, new Contact())
            .toList();
        Assert.areEqual(3, Limits.getDmlStatements()); // 1 for contact, 2 for accounts
        Assert.areEqual(5, created.size());
        Assert.areEqual(5, queryContacts().size());
        Assert.areEqual(2, queryAccounts().size());
        Assert.isNotNull(created[0].Id);
        Assert.areEqual('desc 0', created[0].Description);
        Assert.areEqual('desc 1', created[1].Description);
        Assert.areEqual('desc 2', created[2].Description);
        Assert.areEqual('desc 0', created[3].Description);
        Assert.areEqual('desc 1', created[4].Description);
        Assert.areEqual(acc.Id, created[0].AccountId);
        Assert.areNotEqual(acc.Id, created[1].AccountId);
        Assert.areEqual(acc.Id, created[2].AccountId);
        Assert.areNotEqual(acc.Id, created[3].AccountId);
        Assert.areEqual(acc.Id, created[4].AccountId);
    }

    @IsTest
    static void testInsertContactsWithParentRotations() {
        List<Account> accounts = (List<Account>) factory.inserted(3, new Account()).toList();
        List<Contact> created = (List<Contact>) factory.rotate(Contact.AccountId, accounts).inserted(3, new Contact()).toList();
        Assert.areEqual(2, Limits.getDmlStatements());
        Assert.areEqual(6, Limits.getDmlRows());
        List<Contact> contacts = queryContacts();
        Assert.areEqual(accounts[0].Id, created[0].AccountId);
        Assert.areEqual(accounts[0].Id, contacts[0].AccountId);
        Assert.areEqual(accounts[1].Id, created[1].AccountId);
        Assert.areEqual(accounts[1].Id, contacts[1].AccountId);
        Assert.areEqual(accounts[2].Id, created[2].AccountId);
        Assert.areEqual(accounts[2].Id, contacts[2].AccountId);
    }

    @IsTest
    static void testInsertContactsWithParentIdRotations() {
        List<Account> accounts = (List<Account>) factory.inserted(3, new Account()).toList();
        List<Id> accountsIds = new List<Id>{ accounts.get(0).Id, accounts.get(1).Id, accounts.get(2).Id };
        List<Contact> created = (List<Contact>) factory.rotate(Contact.AccountId, accountsIds).inserted(3, new Contact()).toList();
        Assert.areEqual(2, Limits.getDmlStatements());
        Assert.areEqual(6, Limits.getDmlRows());
        List<Contact> contacts = queryContacts();
        Assert.areEqual(accounts[0].Id, created[0].AccountId);
        Assert.areEqual(accounts[0].Id, contacts[0].AccountId);
        Assert.areEqual(accounts[1].Id, created[1].AccountId);
        Assert.areEqual(accounts[1].Id, contacts[1].AccountId);
        Assert.areEqual(accounts[2].Id, created[2].AccountId);
        Assert.areEqual(accounts[2].Id, contacts[2].AccountId);
    }

    @IsTest
    static void testCreateContact() {
        staticSetup();
        Contact created = (Contact) factory.created(new Contact()).toSObject();
        Assert.areEqual(1, Limits.getDmlStatements());
        Assert.isNull(created.Id);
        Assert.isNotNull(created.AccountId);
        Assert.isTrue(queryContacts().isEmpty());
        Assert.areEqual('Jon', created.FirstName);
        Assert.areEqual('Doe', created.LastName);
    }

    @IsTest
    static void testInsertSObjectWithoutFactoryImpl() {
        staticSetup();
        User u = (User) factory.inserted(new User(Profile = [SELECT Id FROM Profile LIMIT 1])).toSObject();
        Assert.areEqual(1, Limits.getDmlStatements());
        Assert.isNotNull(u.Id);
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
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.areEqual(0, Limits.getDmlRows());
        Assert.isNull(createdAccount.Id);
        Assert.isNull(createdContact.Id);
        Assert.areEqual('Jon', createdContact.FirstName);
        Assert.areEqual('Doe', createdContact.LastName);
        Assert.areEqual('Acme', createdContact.Account.Name);
        Assert.areEqual(NEW_DESCRIPTION, createdContact.Account.Description);
        Assert.areEqual(createdAccount, createdContact.Account);
    }

    @IsTest
    static void testCreateContactWithAccountWithInsert() {
        staticSetup();
        Account createdAccount = (Account) factory.inserted(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.inserted(new Contact(Account = createdAccount)).toSObject();
        Assert.areEqual(2, Limits.getDmlStatements());
        Assert.areEqual(2, Limits.getDmlRows());
        Assert.isNotNull(createdAccount.Id);
        Assert.isNotNull(createdContact.Id);
        List<Contact> contacts = queryContacts();
        Assert.areEqual(1, contacts.size());
        Assert.areEqual(1, queryAccounts().size());
        Assert.areEqual('Jon', createdContact.FirstName);
        Assert.areEqual('Jon', contacts[0].FirstName);
        Assert.areEqual('Doe', createdContact.LastName);
        Assert.areEqual('Acme', createdContact.Account.Name);
        Assert.areEqual(NEW_DESCRIPTION, contacts[0].Account.Description);
        Assert.areEqual(NEW_DESCRIPTION, createdContact.Account.Description);
        Assert.areEqual(createdAccount.Id, TestDataFactory.getRecord(createdAccount.Id).Id);
        Assert.areEqual(createdContact.Id, TestDataFactory.getRecord(createdContact.Id).Id);
    }

    @IsTest
    static void testCreateContactWithAccountWithMockedInsert() {
        staticSetup();
        Account createdAccount = (Account) factory.mocked(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.mocked(new Contact(Account = createdAccount)).toSObject();
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.areEqual(0, Limits.getDmlRows());
        Assert.isNotNull(createdAccount.Id);
        Assert.isNotNull(createdContact.Id);
        Assert.areEqual('Jon', createdContact.FirstName);
        Assert.areEqual('Doe', createdContact.LastName);
        Assert.areEqual('Acme', createdContact.Account.Name);
        Assert.areEqual(NEW_DESCRIPTION, createdContact.Account.Description);
    }

    @IsTest
    static void testCreateContactWithAccountMocked() {
        staticSetup();
        Account createdAccount = (Account) factory.mocked(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Contact createdContact = (Contact) factory.mocked(new Contact(Account = createdAccount)).toSObject();
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.isNotNull(createdAccount.Id);
        Assert.isNotNull(createdContact.Id);
        List<Contact> contacts = queryContacts();
        Assert.areEqual(0, contacts.size());
        Assert.areEqual('Jon', createdContact.FirstName);
        Assert.areEqual('Doe', createdContact.LastName);
        Assert.areEqual('Acme', createdContact.Account.Name);
        Assert.areEqual(NEW_DESCRIPTION, createdContact.Account.Description);
    }

    @IsTest
    static void testCreateAccountWithInsert() {
        staticSetup();
        Account created = (Account) factory.inserted(new Account(Description = NEW_DESCRIPTION)).toSObject();
        Assert.areEqual(1, Limits.getDmlStatements());
        List<Account> accounts = queryAccounts();
        Assert.isNotNull(created.Id);
        Assert.areEqual(1, accounts.size());
        Assert.areEqual('Acme', accounts[0].Name);
        Assert.areEqual(NEW_DESCRIPTION, accounts[0].Description);
        Assert.areEqual('Acme', created.Name);
        Assert.areEqual(NEW_DESCRIPTION, created.Description);
    }

    @IsTest
    static void testCreateContactWithInsert() {
        staticSetup();
        Contact con1 = (Contact) factory.inserted(new Contact()).toSObject();
        Contact con2 = (Contact) factory.inserted(new Contact()).toSObject();
        Assert.areEqual(3, Limits.getDmlStatements());
        Assert.areEqual(con1.AccountId, con2.AccountId);
    }

    @IsTest
    static void testCreateAccountWithInsertBulk() {
        staticSetup();
        List<Account> created = (List<Account>) factory.inserted(200, new Account(Description = 'overridden desc')).toList();
        Assert.areEqual(1, Limits.getDmlStatements());
        List<Account> accounts = queryAccounts();
        Assert.areEqual(200, created.size());
        Assert.areEqual(200, accounts.size());
        Assert.isNotNull(created[0].Id);
        Assert.isNotNull(created[1].Id);
        Assert.isNotNull(created[199].Id);
        Assert.areEqual('Acme', accounts[0].Name);
        Assert.areEqual(NEW_DESCRIPTION, accounts[0].Description);
        Assert.areEqual('Acme', created[0].Name);
        Assert.areEqual(NEW_DESCRIPTION, created[0].Description);
    }

    @IsTest
    static void testCreateAccountWithMockedInsert() {
        staticSetup();
        Account created = (Account) factory.mocked(new Account(Description = 'overridden desc')).toSObject();
        Assert.areEqual(0, Limits.getDmlStatements());
        List<Account> accounts = queryAccounts();
        Assert.areEqual(0, accounts.size());
        Assert.isNotNull(created.Id);
        Assert.areEqual('Acme', created.Name);
        Assert.areEqual(NEW_DESCRIPTION, created.Description);
    }

    @IsTest
    static void testSObjectFactoryScenario() {
        staticSetup();
        Account created = (Account) factory.useScenario(AccountScenario.class).created(new Account()).toSObject();
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.isNull(created.Id);
        Assert.areEqual(AccountScenario.NAME, created.Name);
        Assert.isNull(created.Description);

        created = (Account) factory.useScenario(AccountScenario.class).created(new Account()).toSObject();
        Assert.areEqual(0, Limits.getDmlStatements());
        Assert.isNull(created.Id);
        Assert.areEqual(AccountScenario.NAME, created.Name);
        Assert.isNull(created.Description);

        try {
            factory.useScenario(AccountScenario.class).useScenario(AccountScenario.class);
            Assert.isTrue(false, ' Exception expected');
        } catch (TestDataFactoryException e) {
            Assert.areEqual('Scenario already set', e.getMessage());
        }
    }

    @IsTest
    static void testSetChildren() {
        staticSetup();
        sobj.TestDataFactory factory = new sobj.TestDataFactory();
        Account account = (Account) factory.mocked(new Account()).toSObject();
        List<Account> children = (List<Account>) factory.mocked(10, new Account()).toList();
        account = (Account) sobj.TestDataFactory.setChildren(account, Schema.Account.ParentId, children);
        Assert.areEqual(children.size(), account.ChildAccounts.size(), 'Children not mocked.');
    }

    @IsTest
    static void testAbstract() {
        staticSetup();
        SObjectFactory f = (SObjectFactory) new SObjectFactoryLoader().loadSObjectFactory(Account.SObjectType);
        Assert.isNotNull(f.getDmlOptions());
        Assert.areEqual(null, f.makeParent(Account.ParentId, new Account()));
        Assert.isTrue(f.requireRecordType());
        SObjectFactoryScenario s = (SObjectFactoryScenario) new SObjectFactoryLoader().loadScenario(AccountScenario.class);
        Assert.isNotNull(s.getDmlOptions());
        Assert.areEqual(null, s.makeParent(Account.ParentId, new Account()));
        Assert.isTrue(s.requireRecordType());
    }

    @IsTest
    static void testMakeDefaultsPriority() {
        staticSetup();
        TestDataFactoryDefaultSettings.sObjNameToSettings.put(
            'Account',
            new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                    Active_for_Default_Factory__c = true,
                    Active_for_Custom_Factory__c = true,
                    Active_for_Scenario__c = true,
                    SObject_API_Name__c = 'Account',
                    Field_API_Name__c = 'Description',
                    Field_Value__c = 'desc mdt acc'
                )
            }
        );
        TestDataFactoryDefaultSettings.sObjNameToSettings.put(
            'Opportunity',
            new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                    Active_for_Default_Factory__c = true,
                    SObject_API_Name__c = 'Opportunity',
                    Field_API_Name__c = 'Description',
                    Field_Value__c = 'desc mdt opp'
                )
            }
        );
        // case 1: factory > metadata
        Account acc = (Account) factory.created(new Account()).toSObject();
        Assert.areEqual('description', acc.Description);
        // case 2: target > factory
        acc = (Account) factory.created(new Account(Description = 'desc target acc')).toSObject();
        Assert.areEqual('desc target acc', acc.Description);
        // case 3: no factory, no target
        Opportunity opp = (Opportunity) factory.created(new Opportunity()).toSObject();
        Assert.areEqual('desc mdt opp', opp.Description);
    }

    @IsTest
    static void testCampaign() {
        staticSetup();
        List<Lead> leads = (List<Lead>) factory.inserted(2, new Lead()).toList();
        Campaign camp = (Campaign) factory.inserted(new Campaign(Name = 'campaign')).toSObject();
        Assert.isNotNull(camp.Id, 'ID cannot be null.');
        Assert.areEqual('campaign', camp.Name);
        CampaignMember member = (CampaignMember) factory.inserted(new CampaignMember(Campaign = camp, LeadId = leads.get(0).Id))
            .toSObject();
        Assert.areEqual(camp.Id, member.Campaign.Id);
        Assert.areEqual(camp.Id, member.CampaignId);
        CampaignMember member2 = (CampaignMember) factory.inserted(new CampaignMember(CampaignId = camp.Id, LeadId = leads.get(1).Id))
            .toSObject();
        Assert.isNull(member2.Campaign.Id);
        Assert.areEqual(camp.Id, member2.CampaignId);
    }

    @IsTest
    static void testOpportunity() {
        staticSetup();
        Opportunity opp = (Opportunity) factory.inserted(new Opportunity()).toSObject();
        Opportunity opp2 = (Opportunity) factory.inserted(opp).toSObject();
        Assert.isNotNull(opp.Id, 'ID cannot be null.');
        List<OpportunityLineItem> lineItems = (List<OpportunityLineItem>) factory.inserted(50, new OpportunityLineItem(Opportunity = opp2))
            .toList();
        Assert.areEqual(50, lineItems.size());
    }

    @IsTest
    static void testDefaults() {
        staticSetup();
        Account defaults = new Account(
            Name = 'Name',
            Description = 'Description',
            AccountNumber = 'AccountNumber',
            AccountSource = 'AccountSource',
            AnnualRevenue = 500,
            BillingCity = 'Prague',
            BillingCountry = 'Czech Republic',
            BillingLatitude = 10,
            BillingLongitude = 10,
            Phone = '111222333',
            Website = 'www.website.com'
        );
        Account account1 = (Account) factory.inserted(defaults).toSObject();
        Assert.areEqual(defaults.Name, account1.Name);
        Assert.areEqual(defaults.Description, account1.Description);
        Assert.areEqual(defaults.AccountNumber, account1.AccountNumber);
        Assert.areEqual(defaults.AccountSource, account1.AccountSource);
        Assert.areEqual(defaults.AnnualRevenue, account1.AnnualRevenue);
        Assert.areEqual(defaults.BillingCity, account1.BillingCity);
        Assert.areEqual(defaults.BillingCountry, account1.BillingCountry);
        Assert.areEqual(defaults.BillingLatitude, account1.BillingLatitude);
        Assert.areEqual(defaults.BillingLongitude, account1.BillingLongitude);
        Assert.areEqual(defaults.Phone, account1.Phone);
        Assert.areEqual(defaults.Website, account1.Website);
        Account account2 = (Account) factory.inserted(account1).toSObject();
        Assert.areEqual(defaults.Name, account2.Name);
        Assert.areEqual(defaults.Description, account2.Description);
        Assert.areEqual(defaults.AccountNumber, account2.AccountNumber);
        Assert.areEqual(defaults.AccountSource, account2.AccountSource);
        Assert.areEqual(defaults.AnnualRevenue, account2.AnnualRevenue);
        Assert.areEqual(defaults.BillingCity, account2.BillingCity);
        Assert.areEqual(defaults.BillingCountry, account2.BillingCountry);
        Assert.areEqual(defaults.BillingLatitude, account2.BillingLatitude);
        Assert.areEqual(defaults.BillingLongitude, account2.BillingLongitude);
        Assert.areEqual(defaults.Phone, account2.Phone);
        Assert.areEqual(defaults.Website, account2.Website);
    }

    static List<Account> queryAccounts() {
        return [SELECT Id, Name, Description FROM Account];
    }

    static List<Contact> queryContacts() {
        return [SELECT Id, FirstName, LastName, AccountId, Account.Name, Account.Description FROM Contact];
    }
}