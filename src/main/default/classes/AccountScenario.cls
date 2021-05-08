/**
 * Example implementation used for managed package testing.
 * Use global modifier when extending SObjectFactoryScenario.
 */
@IsTest
public without sharing class AccountScenario extends SObjectFactoryScenario {
    public static final String NAME = 'Scenario';

    public SObject createDefaults(SObject target) {
        return new Account(Name = NAME);
    }
}