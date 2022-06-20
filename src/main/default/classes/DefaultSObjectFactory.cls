/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
public without sharing class DefaultSObjectFactory extends SObjectFactory {
    private static final TestDataFactory factory = new TestDataFactory();

    public SObject createDefaults(SObject target) {
        SObjectType sObjType = target.getSObjectType();
        SObject def = sObjType.newSObject();
        if (sObjType == Event.SObjectType) {
            def.put(Event.DurationInMinutes, 60);
            def.put(Event.ActivityDateTime, Datetime.now().addMonths(2));
        } else if (sObjType == OpportunityLineItem.SObjectType) {
            def.put(OpportunityLineItem.TotalPrice, 100);
            def.put(OpportunityLineItem.PricebookEntryId, getDefaultPricebookEntry().Id);
        } else if (sObjType == Order.SObjectType) {
            def.put(Order.Status, 'Draft');
            def.put(Order.AccountId, getDefaultAccount().Id);
            def.put(Order.Pricebook2Id, Test.getStandardPricebookId());
        } else if (sObjType == OrderItem.SObjectType) {
            def.put(OrderItem.UnitPrice, 1);
        } else if (sObjType == PricebookEntry.SObjectType) {
            def.put(PricebookEntry.Pricebook2Id, Test.getStandardPricebookId());
            def.put(PricebookEntry.IsActive, true);
        } else if (sObjType == ServiceContract.SObjectType) {
            def.put(ServiceContract.Pricebook2Id, Test.getStandardPricebookId());
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

    private static PricebookEntry defaultPricebookEntry;
    private PricebookEntry getDefaultPricebookEntry() {
        if (defaultPricebookEntry == null) {
            defaultPricebookEntry = (PricebookEntry) factory.inserted(new PricebookEntry()).toSObject();
        }
        return defaultPricebookEntry;
    }

    public override Boolean autoPopulateRequiredFields() {
        return true;
    }
}