/**
 * Example implementation used for managed package testing.
 * Use global modifier when extending SObjectFactory.
 */
@IsTest
public without sharing class ContactFactory extends SObjectFactory {
    public static final String FIRST_NAME = 'First';
    public static final String LAST_NAME = 'Last';

    private final TestDataFactory factory = new TestDataFactory();

    public SObject createDefaults(SObject target) {
        return new Contact(
                FirstName = FIRST_NAME,
                LastName = LAST_NAME
        );
    }

    public override SObject makeParent(SObjectField sObjField, SObject target) {
        if (sObjField == Contact.AccountId) {
            return factory.inserted(new Account()).toSObject();
        }
        return null;
    }
}
