/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
public without sharing class DefaultSObjectFactory extends SObjectFactory {
    private static final TestDataFactory factory = new TestDataFactory();

    public SObject createDefaults(SObject target) {
        SObjectType sObjType = target.getSObjectType();
        String sObjName = sObjType.getDescribe().getName();
        SObject def = sObjType.newSObject();
        if (sObjType == Event.SObjectType) {
            def.put(Event.DurationInMinutes, 60);
            def.put(Event.ActivityDateTime, Datetime.now().addMonths(2));
        } else if (sObjName == 'OpportunityLineItem') {
            def.put('TotalPrice', 100);
            def.put('PricebookEntryId', getDefaultPricebookEntry().Id);
        } else if (sObjName == 'Order') {
            def.put('Status', 'Draft');
            def.put('AccountId', getDefaultAccount().Id);
            def.put('Pricebook2Id', Test.getStandardPricebookId());
        } else if (sObjName == 'OrderItem') {
            def.put('UnitPrice', 1);
        } else if (sObjName == 'PricebookEntry') {
            def.put('Pricebook2Id', Test.getStandardPricebookId());
            def.put('IsActive', true);
        } else if (sObjName == 'ServiceContract') {
            def.put('Pricebook2Id', Test.getStandardPricebookId());
        } else if (sObjType == User.SObjectType) {
            def.put(User.ProfileId, getDefaultProfileId());
        }
        return def;
    }

    private static Account defaultAccount;
    private Account getDefaultAccount() {
        if (defaultAccount == null) {
            defaultAccount = (Account) factory.inserted(new Account()).toSObject();
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

    // use PricebookEntry dynamically to avoid dependency on the "Product" feature
    private static SObject defaultPricebookEntry;
    private SObject getDefaultPricebookEntry() {
        if (defaultPricebookEntry == null) {
            SObject sObj = (SObject) Type.forName('PricebookEntry').newInstance();
            defaultPricebookEntry = factory.inserted(sObj).toSObject();
        }
        return defaultPricebookEntry;
    }

    public override Boolean autoPopulateRequiredFields() {
        return true;
    }
}