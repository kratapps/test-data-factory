/**
 * @author Ondrej Kratochvil
 * @date 2021-04-6
 */
@IsTest
private class SObjectFieldDefaultValueProviderTest {
    @IsTest
    static void test() {
        SObjectField accountName = Account.Name;
        DescribeFieldResult accountNameDesc = accountName.getDescribe();
        SObjectFieldDefaultValueProvider p = new SObjectFieldDefaultValueProvider();
        System.assertEquals(Blob.valueOf('Name'), p.getDefaultBase64(accountName, accountNameDesc));
        System.assertEquals(false, p.getDefaultBoolean(null, null));
        System.assertEquals(0, p.getDefaultCurrency(null, null));
        System.assertEquals(Date.today(), p.getDefaultDate(null, null));
        System.assertEquals(Datetime.now(), p.getDefaultDatetime(null, null));
        System.assertEquals(0, p.getDefaultDouble(null, null));
        System.assertEquals('jon.doe@acme.com', p.getDefaultEmail(null, null));
        System.assertEquals(0, p.getDefaultInteger(null, null));
        Location loc = (Location) p.getDefaultLocation(null, null);
        System.assertEquals(0, loc.getDistance(Location.newInstance(0, 0), 'km'));
        System.assertEquals(0, p.getDefaultLong(null, null));
        System.assertEquals(0, p.getDefaultPercent(null, null));
        System.assertEquals('(555) 555-1234', p.getDefaultPhone(null, null));
        System.assertEquals(
            Account.SObjectType,
            p.getDefaultReference(Contact.AccountId, Contact.AccountId.getDescribe()).getSObjectType()
        );
        System.assertEquals('Name', p.getDefaultString(accountName, accountNameDesc));
        System.assertEquals('Name', p.getDefaultTextArea(accountName, accountNameDesc));
        System.assertEquals(Time.newInstance(12, 0, 0, 0), p.getDefaultTime(null, null));
        System.assertEquals('https://www.acme.com', p.getDefaultUrl(null, null));
    }
}