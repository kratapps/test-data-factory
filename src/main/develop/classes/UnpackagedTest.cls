@IsTest
private class UnpackagedTest {
    private static TestDataFactory factory = new TestDataFactory();

    @IsTest
    static void testInserted() {
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
            SObject sObj = factory.inserted(sObjType.newSObject()).toSObject();
            Assert.notNull(sObj.Id, 'Record not inserted: ' + sObjType);
        }
    }
    
    @IsTest
    static void testManagedPackageRecords() {
        sfLma__Package__c pkg = (sfLma__Package__c) factory.inserted(new sfLma__Package__c(
                Name = 'pkg',
                sfLma__Developer_Org_ID__c = 'aaa',
                sfLma__Developer_Name__c = 'name'
        )).toSObject();
        Assert.isEqual('pkg', pkg.Name);
        Assert.isEqual('name', pkg.sfLma__Developer_Name__c);
        sfLma__Package_Version__c version = (sfLma__Package_Version__c) factory.inserted(new sfLma__Package_Version__c(
                Name = 'version',
                sfLma__Version__c = 'v1.0'
        )).toSObject();
        Assert.isEqual('version', version.Name);
        Assert.isEqual('v1.0', version.sfLma__Version__c);
        Assert.notNull(version.sfLma__Package__c);
        Assert.notEqual(pkg.Id, version.sfLma__Package__c);
        sfLma__Package_Version__c version2 = (sfLma__Package_Version__c) factory.inserted(new sfLma__Package_Version__c(
                Name = 'version2',
                sfLma__Version__c = 'v2.0',
                sfLma__Package__c = pkg.Id
        )).toSObject();
        Assert.isEqual('version2', version2.Name);
        Assert.isEqual('v2.0', version2.sfLma__Version__c);
        Assert.notNull(version2.sfLma__Package__c);
        Assert.isEqual(pkg.Id, version2.sfLma__Package__c);
    }
}