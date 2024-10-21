global virtual without sharing class GenericSObjectFactory extends SObjectFactory {
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
        String sObjectName = sObjectType.getDescribe().getName();
        SObject def = sObjectType.newSObject();
        if (sObjectName == 'Event') {
            def.put('DurationInMinutes', 60);
            def.put('ActivityDateTime', Datetime.now().addMonths(2));
        } else if (sObjectName == 'OpportunityLineItem') {
            def.put('TotalPrice', 100);
            def.put('PricebookEntryId', getDefaultPricebookEntry().Id);
        } else if (sObjectName == 'Order') {
            def.put('Status', 'Draft');
            def.put('AccountId', getDefaultAccount().Id);
            def.put('Pricebook2Id', Test.getStandardPricebookId());
        } else if (sObjectName == 'OrderItem') {
            def.put('UnitPrice', 1);
        } else if (sObjectName == 'PricebookEntry') {
            def.put('Pricebook2Id', Test.getStandardPricebookId());
            def.put('IsActive', true);
        } else if (sObjectName == 'ServiceContract') {
            def.put('Pricebook2Id', Test.getStandardPricebookId());
        } else if (sObjectType == User.SObjectType) {
            def.put(User.ProfileId, getDefaultProfileId());
        }
        return def;
    }

    private static Account defaultAccount;
    private Account getDefaultAccount() {
        if (defaultAccount == null) {
            defaultAccount = (Account) new GenericSObjectFactory().inserted().setRequiredFields().build(new Account()).toSObject();
        }
        return defaultAccount;
    }

    private static Id defaultProfileId;
    private Id getDefaultProfileId() {
        if (defaultProfileId == null) {
            defaultProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        }
        return defaultProfileId;
    }

    private static SObject defaultPricebookEntry;
    private SObject getDefaultPricebookEntry() {
        if (defaultPricebookEntry == null) {
            // Use PricebookEntry dynamically to avoid dependency on the "Product" feature.
            SObject target = (SObject) Type.forName('PricebookEntry').newInstance();
            defaultPricebookEntry = new GenericSObjectFactory().inserted().setRequiredFields().build(target).toSObject();
        }
        return defaultPricebookEntry;
    }
}