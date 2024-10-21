/**
 * Example implementation used for managed package testing.
 * Use global modifier when extending SObjectFactory.
 */
@IsTest
public without sharing class AccountFactory extends GenericSObjectFactory {
    public override SObject createDefaults(SObject target) {
        return new Account(Name = 'Acme', Description = 'description');
    }

    public override Boolean autoPopulateRequiredFields() {
        return true;
    }
}