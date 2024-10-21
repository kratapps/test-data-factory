/**
 * Example implementation used for managed package testing.
 * Use global modifier when extending SObjectFactory.
 */
@IsTest
public without sharing class ContactFactory extends SObjectFactory {
    public SObject createDefaults(SObject target) {
        return new Contact(FirstName = 'Jon', LastName = 'Doe');
    }

    public override SObject makeParent(SObjectField sObjField, SObject target) {
        if (sObjField == Contact.AccountId) {
            return new AccountFactory().inserted().build(new Account()).toSObject();
        }
        return null;
    }
}