/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
private class SObjectUtilsTest {
    @IsTest
    static void testMergeSObjects() {
        Account acc = new Account(Id = SObjectUtils.getMockId(Account.SObjectType), Name = 'parent');
        Contact c1 = new Contact(FirstName = 'first1', LastName = 'last');
        Contact c2 = new Contact(FirstName = 'first2', Email = 'email@email.com', Account = acc);
        SObjectUtils.mergeSObjects(c1, c2);
        System.assertEquals('first2', c1.FirstName);
        System.assertEquals('last', c1.LastName);
        System.assertEquals('email@email.com', c1.Email);
        System.assertEquals('first2', c2.FirstName);
        System.assertEquals(null, c2.LastName);
        System.assertEquals('email@email.com', c2.Email);
        System.assertNotEquals(null, c1.Account);
        System.assertEquals(null, c1.AccountId);
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
                System.assert(false, 'Exception expected');
            } catch (TestDataFactoryException e) {
            }
        } else {
            // no exception expected
            SObjectUtils.requireRecordType(new Account());
        }
    }
    
    @IsTest
    static void testMisc() {
        System.assertNotEquals(null, SObjectUtils.getDescribeFieldResult(Contact.SObjectType, 'AccountId'));
        System.assertEquals(null, SObjectUtils.getDescribeFieldResult(Contact.SObjectType, 'Account'));
        System.assert(!SObjectUtils.getDescribeFieldResultReferences(Contact.SObjectType).isEmpty());
    }
}