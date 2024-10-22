/**
 * Use global modifier and namespace for sobj.BaseSObjectFactory when working with installed managed package.
 */
@IsTest
public without sharing class ContactFactory extends BaseSObjectFactory {
    public override SObject createDefaults(SObject target) {
        return new Contact(FirstName = 'Jon', LastName = 'Doe');
    }

    public override SObject makeParent(SObjectField sObjField, SObject target) {
        if (sObjField == Contact.AccountId) {
            return new AccountFactory().inserted().build(new Account()).toSObject();
        }
        return null;
    }
}