/**
 * Example implementation used for managed package testing.
 * Use global modifier when extending SObjectFactory.
 */
@IsTest
public without sharing class AccountFactory extends SObjectFactory {
    public static final String NAME = 'Acme';
    public static final String DESCRIPTION = 'desc';

    public SObject createDefaults(SObject target) {
        return new Account(Name = NAME, Description = DESCRIPTION);
    }


    public override Boolean autoPopulateRequiredFields() {
        return true;
    }
}