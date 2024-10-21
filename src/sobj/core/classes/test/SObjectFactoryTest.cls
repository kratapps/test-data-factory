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
        SObjectFactory factory = new GenericSObjectFactory();
        Assert.areEqual(null, factory.makeParent(null, null), 'No parent record created by default.');
        Assert.isTrue(factory.getDmlOptions().duplicateRuleHeader.allowSave, 'Duplicate rule header expected to be disabled by default.');
        Assert.isTrue(factory.requireRecordType(), 'Record Type in target required by default.');
        Assert.isFalse(factory.autoPopulateRequiredFields(), 'Auto-populate required fields expected to be disabled by default.');
    }

    @IsTest
    static void recordInsertedThroughGenericFactory() {
        List<SObjectType> sObjectType = new List<SObjectType>{
            Account.SObjectType,
            Campaign.SObjectType,
            Case.SObjectType,
            Contact.SObjectType,
            Contract.SObjectType,
            Event.SObjectType,
            Lead.SObjectType,
            Opportunity.SObjectType,
            OpportunityLineItem.SObjectType,
            Order.SObjectType,
            OrderItem.SObjectType,
            Pricebook2.SObjectType,
            PricebookEntry.SObjectType,
            Product2.SObjectType,
            Task.SObjectType,
            User.SObjectType
        };
        for (SObjectType sObjType : sObjectType) {
            System.debug('Going to test: ' + sObjType);
            SObject sObj = new GenericSObjectFactory().inserted().setRequiredFields().build(sObjType.newSObject()).toSObject();
            Assert.isNotNull(sObj.Id, 'Record not inserted: ' + sObjType);
        }
    }
}