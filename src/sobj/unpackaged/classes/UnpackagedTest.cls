@IsTest
private class UnpackagedTest {
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
            SObject sObj = new BaseSObjectFactory().inserted().setRequiredFields().build(sObjType.newSObject()).toSObject();
            Assert.isNotNull(sObj.Id, 'Record not inserted: ' + sObjType);
        }
    }

    @IsTest
    static void testManagedPackageRecords() {
        BaseSObjectFactory factory = new BaseSObjectFactory();
        sfLma__Package__c pkg = (sfLma__Package__c) factory.inserted()
            .setRequiredFields()
            .build(new sfLma__Package__c(Name = 'pkg', sfLma__Developer_Org_ID__c = 'aaa', sfLma__Developer_Name__c = 'name'))
            .toSObject();
        Assert.areEqual('pkg', pkg.Name);
        Assert.areEqual('name', pkg.sfLma__Developer_Name__c);
        sfLma__Package_Version__c version = (sfLma__Package_Version__c) factory.inserted()
            .setRequiredFields()
            .build(new sfLma__Package_Version__c(Name = 'version', sfLma__Version__c = 'v1.0'))
            .toSObject();
        Assert.areEqual('version', version.Name);
        Assert.areEqual('v1.0', version.sfLma__Version__c);
        Assert.isNotNull(version.sfLma__Package__c);
        Assert.areNotEqual(pkg.Id, version.sfLma__Package__c);
        sfLma__Package_Version__c version2 = (sfLma__Package_Version__c) factory.inserted()
            .setRequiredFields()
            .build(new sfLma__Package_Version__c(Name = 'version2', sfLma__Version__c = 'v2.0', sfLma__Package__c = pkg.Id))
            .toSObject();
        Assert.areEqual('version2', version2.Name);
        Assert.areEqual('v2.0', version2.sfLma__Version__c);
        Assert.isNotNull(version2.sfLma__Package__c);
        Assert.areEqual(pkg.Id, version2.sfLma__Package__c);
    }
}