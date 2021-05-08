/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
public without sharing class DefaultSObjectFactory extends SObjectFactory {
    public SObject createDefaults(SObject target) {
        return target.getSObjectType().newSObject();
    }

    public override Boolean autoPopulateRequiredFields() {
        return true;
    }
}