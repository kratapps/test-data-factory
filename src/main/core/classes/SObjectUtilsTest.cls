/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
private class SObjectUtilsTest {
    @IsTest
    static void testMergeSObjects() {
        Account acc = new Account(Id = SObjectUtils.getMockId(Account.SObjectType), Name = 'parent');
        Contact c1 = new Contact(FirstName = 'first1', LastName = 'last', Description = 'desc');
        Contact c2 = new Contact(FirstName = 'first2', Email = 'email@email.com', Account = acc);
        SObjectUtils.mergeSObjects(c1, c2);
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
        SObjectUtils.mergeSObjects(c1, c2);
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
            SObjectUtils.requireRecordType(target);
            try {
                SObjectUtils.requireRecordType(new Account());
                Assert.fail('Exception expected');
            } catch (TestDataFactoryException e) {
            }
        } else {
            // no exception expected
            SObjectUtils.requireRecordType(new Account());
        }
    }

    @IsTest
    static void testSafePut() {
        Contact con = new Contact();
        SObjectUtils.safePut(con, con.getSObjectType(), false, 'Description', 'desc');
        Assert.areEqual('desc', con.Description);
        SObjectUtils.safePut(con, con.getSObjectType(), false, 'Description', null);
        Assert.isNull(con.Description);
        SObjectUtils.safePut(con, con.getSObjectType(), false, 'Account', new Account(Name = 'acc1'));
        Assert.areEqual('acc1', con.Account.Name);
        SObjectUtils.safePut(con, con.getSObjectType(), false, 'Account', null);
        Assert.isNull(con.Account);
        Account acc = new Account();
        SObjectUtils.safePut(acc, acc.getSObjectType(), false, 'BillingAddress', new Address()); // compound fields should be ignored
        Assert.isNull(acc.BillingAddress);
    }

    @IsTest
    static void testMisc() {
        Assert.areNotEqual(null, SObjectUtils.getDescribeFieldResult(Contact.SObjectType, 'AccountId'));
        Assert.areEqual(null, SObjectUtils.getDescribeFieldResult(Contact.SObjectType, 'Account'));
        Assert.isFalse(SObjectUtils.getDescribeFieldResultReferences(Contact.SObjectType).isEmpty());
    }
}