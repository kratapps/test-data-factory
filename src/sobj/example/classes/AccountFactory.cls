/**
 * Use global modifier and namespace for sobj.BaseSObjectFactory when working with installed managed package.
 */
@IsTest
public without sharing class AccountFactory extends BaseSObjectFactory {
    public override SObject createDefaults(SObject target) {
        return new Account(Name = 'Acme', Description = 'description');
    }

    public override Boolean autoPopulateRequiredFields() {
        return true;
    }
}