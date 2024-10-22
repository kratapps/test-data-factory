@IsTest
private class SObjectFactoryTest {
    @IsTest
    static void createAccount() {
        List<Account> accounts = (List<Account>) new AccountFactory().created(5).build(new Account()).toList();
        Assert.areEqual(5, accounts.size(), 'Expected 5 accounts created.');
    }

    @IsTest
    static void setChildren() {
        List<Account> children = (List<Account>) new AccountFactory().created(5).build(new Account(Name = 'child')).toList();
        Account account = (Account) new AccountFactory().created().setChildren(Account.ParentId, children).build(new Account()).toSObject();
        Assert.areEqual(5, account.ChildAccounts.size(), 'Expected 5 child accounts created.');
    }

    @IsTest
    static void setReadOnlyField() {
        Datetime mockedDatetime = Date.today().addDays(2);
        Account account = (Account) new AccountFactory()
            .created()
            .setReadOnly(Account.LastModifiedDate, mockedDatetime)
            .build(new Account())
            .toSObject();
        Assert.areEqual(account.LastModifiedDate, mockedDatetime, 'Expected mocked last modified date value.');
    }

    @IsTest
    static void genericFactoryImplementation() {
        SObjectFactory factory = new BaseSObjectFactory();
        Assert.areEqual(null, factory.makeParent(null, null), 'No parent record created by default.');
        Assert.isTrue(factory.getDmlOptions().duplicateRuleHeader.allowSave, 'Duplicate rule header expected to be disabled by default.');
        Assert.isTrue(factory.requireRecordType(), 'Record Type in target required by default.');
        Assert.isFalse(factory.autoPopulateRequiredFields(), 'Auto-populate required fields expected to be disabled by default.');
    }

    @IsTest
    static void mockIdsSet() {
        List<Account> accounts = new List<Account>{ new Account(), new Account(), new Account(), new Account() };
        MockId.setMockIds(accounts);
        Assert.areEqual(4, accounts.size(), 'Incorrect number of accounts.');
        for (Account account : accounts) {
            Assert.isNotNull(account.Id, 'Mock ID is expected.');
            Assert.isTrue(String.valueOf(account.Id).startsWith('001'), 'Mock ID does not start with proper object prefix.');
        }
    }

    @IsTest
    static void testMergeSObjects() {
        Account acc = new Account(Id = MockId.getMockId(Account.SObjectType), Name = 'parent');
        Contact c1 = new Contact(FirstName = 'first1', LastName = 'last', Description = 'desc');
        Contact c2 = new Contact(FirstName = 'first2', Email = 'email@email.com', Account = acc);
        SObjectFactoryUtils.mergeSObjects(c1, c2);
        Assert.areEqual('first2', c1.FirstName);
        Assert.areEqual('last', c1.LastName);
        Assert.areEqual('email@email.com', c1.Email);
        Assert.areEqual('first2', c2.FirstName);
        Assert.areEqual(null, c2.LastName);
        Assert.areEqual('email@email.com', c2.Email);
        Assert.isNotNull(c1.Account);
        Assert.areEqual(c1.Account.Id, c1.AccountId);
        c2.Account = null;
        c2.Description = null;
        SObjectFactoryUtils.mergeSObjects(c1, c2);
        Assert.isNull(c1.Account);
        Assert.isNull(c1.Description);
    }

    @IsTest
    static void testRequireRecordType() {
        Integer recordTypesSize = Account.SObjectType.getDescribe().getRecordTypeInfos().size();
        if (recordTypesSize > 1) {
            Id recordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfos()[0].getRecordTypeId();
            Account target = new Account();
            target.put('RecordTypeId', recordTypeId);
            SObjectFactoryUtils.requireRecordType(target);
            try {
                SObjectFactoryUtils.requireRecordType(new Account());
                Assert.fail('Exception expected');
            } catch (TestDataFactoryException e) {
            }
        } else {
            // no exception expected
            SObjectFactoryUtils.requireRecordType(new Account());
        }
    }

    @IsTest
    static void describeUtils() {
        Assert.isNotNull(SObjectFactoryUtils.getDescribeFieldResult(Contact.SObjectType, 'AccountId'), '');
        Assert.isNull(SObjectFactoryUtils.getDescribeFieldResult(Contact.SObjectType, 'Account'));
        Assert.isFalse(SObjectFactoryUtils.getDescribeFieldResultReferences(Contact.SObjectType).isEmpty());
    }

    @IsTest
    static void safePutModifiesRecord() {
        Contact con = new Contact();
        SObjectFactoryUtils.safePut(con, con.getSObjectType(), false, 'Description', 'desc');
        Assert.areEqual('desc', con.Description);
        SObjectFactoryUtils.safePut(con, con.getSObjectType(), false, 'Description', null);
        Assert.isNull(con.Description);
        SObjectFactoryUtils.safePut(con, con.getSObjectType(), false, 'Account', new Account(Name = 'acc1'));
        Assert.areEqual('acc1', con.Account.Name);
        SObjectFactoryUtils.safePut(con, con.getSObjectType(), false, 'Account', null);
        Assert.isNull(con.Account);
        Account acc = new Account();
        SObjectFactoryUtils.safePut(acc, acc.getSObjectType(), false, 'BillingAddress', new Address()); // compound fields should be ignored
        Assert.isNull(acc.BillingAddress);
    }

    @IsTest
    static void defaultValuesProvided() {
        SObjectField accountName = Account.Name;
        DescribeFieldResult accountNameDesc = accountName.getDescribe();
        SObjectFieldDefaultValueProvider p = new SObjectFieldDefaultValueProvider();
        Assert.areEqual(Blob.valueOf('Name'), p.getDefaultBase64(accountName, accountNameDesc));
        Assert.areEqual(false, p.getDefaultBoolean(null, null));
        Assert.areEqual(0, p.getDefaultCurrency(null, null));
        Assert.areEqual(Date.today(), p.getDefaultDate(null, null));
        Assert.areEqual(Datetime.now(), p.getDefaultDatetime(null, null));
        Assert.areEqual(0, p.getDefaultDouble(null, null));
        Assert.areEqual('jon.doe@acme.com', p.getDefaultEmail(null, null));
        Assert.areEqual(0, p.getDefaultInteger(null, null));
        Location loc = (Location) p.getDefaultLocation(null, null);
        Assert.areEqual(0, loc.getDistance(Location.newInstance(0, 0), 'km'));
        Assert.areEqual(0, p.getDefaultLong(null, null));
        Assert.areEqual(0, p.getDefaultPercent(null, null));
        Assert.areEqual('(555) 555-1234', p.getDefaultPhone(null, null));
        Assert.areEqual(Account.SObjectType, p.getDefaultReference(Contact.AccountId, Contact.AccountId.getDescribe()).getSObjectType());
        Assert.areEqual('Name', p.getDefaultString(accountName, accountNameDesc));
        Assert.areEqual('Name', p.getDefaultTextArea(accountName, accountNameDesc));
        Assert.areEqual(Time.newInstance(12, 0, 0, 0), p.getDefaultTime(null, null));
        Assert.areEqual('https://www.acme.com', p.getDefaultUrl(null, null));
    }
}