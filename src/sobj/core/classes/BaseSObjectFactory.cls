global virtual without sharing class BaseSObjectFactory extends SObjectFactory {
    global Builder created() {
        return new Builder(SObjectDatabase.ProcessType.CREATED, this, 1);
    }

    global Builder mocked() {
        return new Builder(SObjectDatabase.ProcessType.MOCKED, this, 1);
    }

    global Builder inserted() {
        return new Builder(SObjectDatabase.ProcessType.INSERTED, this, 1);
    }

    global Builder created(Integer numberOfRecords) {
        return new Builder(SObjectDatabase.ProcessType.CREATED, this, numberOfRecords);
    }

    global Builder mocked(Integer numberOfRecords) {
        return new Builder(SObjectDatabase.ProcessType.MOCKED, this, numberOfRecords);
    }

    global Builder inserted(Integer numberOfRecords) {
        return new Builder(SObjectDatabase.ProcessType.INSERTED, this, numberOfRecords);
    }

    public virtual SObject createDefaults(SObject target) {
        SObjectType sObjectType = target.getSObjectType();
        String sObjectName = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getName();
        SObject defaults = sObjectType.newSObject();
        if (sObjectName == 'Event') {
            defaults.put('DurationInMinutes', 60);
            defaults.put('ActivityDateTime', Datetime.now().addMonths(2));
        } else if (sObjectName == 'OpportunityLineItem') {
            defaults.put('TotalPrice', 100);
            defaults.put('PricebookEntryId', defaultPricebookEntry.Id);
        } else if (sObjectName == 'Order') {
            defaults.put('Status', 'Draft');
            defaults.put('AccountId', defaultAccount.Id);
            defaults.put('Pricebook2Id', Test.getStandardPricebookId());
        } else if (sObjectName == 'OrderItem') {
            defaults.put('UnitPrice', 1);
        } else if (sObjectName == 'PricebookEntry') {
            defaults.put('Pricebook2Id', Test.getStandardPricebookId());
            defaults.put('IsActive', true);
        } else if (sObjectName == 'ServiceContract') {
            defaults.put('Pricebook2Id', Test.getStandardPricebookId());
        } else if (sObjectName == 'User') {
            defaults.put('ProfileId', defaultProfile.Id);
        }
        return defaults;
    }

    private static Account defaultAccount {
        get {
            if (defaultAccount == null) {
                defaultAccount = (Account) new BaseSObjectFactory().inserted().setRequiredFields().build(new Account()).toSObject();
            }
            return defaultAccount;
        }
        set;
    }

    private static Profile defaultProfile {
        get {
            if (defaultProfile == null) {
                defaultProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            }
            return defaultProfile;
        }
        set;
    }

    private static SObject defaultPricebookEntry {
        get {
            if (defaultPricebookEntry == null) {
                // Use PricebookEntry dynamically to avoid dependency on the "Product" feature.
                SObject target = (SObject) Type.forName('PricebookEntry').newInstance();
                defaultPricebookEntry = new BaseSObjectFactory().inserted().setRequiredFields().build(target).toSObject();
            }
            return defaultPricebookEntry;
        }
        set;
    }
}