/**
 * @author Ondrej Kratochvil
 * @date 2021-10-16
 */
@IsTest
private class TestDataFactoryDefaultSettingsTest {
    @IsTest
    static void testGetDefaults_activeForDefaultFactory() {
        TestDataFactoryDefaultSettings.sObjNameToSettings.put('Account', new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                        Active_for_Default_Factory__c = true,
                        Active_for_Scenario__c = false,
                        Active_for_Custom_Factory__c = false,
                        SObject_API_Name__c = 'Account',
                        Field_API_Name__c = 'Description',
                        Field_Value__c = 'desc'
                )
        });
        Account acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, true, false);
        System.assertEquals('desc', acc.Description);
        acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, false, false);
        System.assertEquals(null, acc.Description);
        acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, false, true);
        System.assertEquals(null, acc.Description);
    }
    @IsTest
    static void testGetDefaults_activeForCustomFactory() {
        TestDataFactoryDefaultSettings.sObjNameToSettings.put('Account', new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                        Active_for_Default_Factory__c = false,
                        Active_for_Scenario__c = false,
                        Active_for_Custom_Factory__c = true,
                        SObject_API_Name__c = 'Account',
                        Field_API_Name__c = 'Description',
                        Field_Value__c = 'desc'
                )
        });
        Account acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, true, false);
        System.assertEquals(null, acc.Description);
        acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, false, false);
        System.assertEquals('desc', acc.Description);
        acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, false, true);
        System.assertEquals(null, acc.Description);
    }
    @IsTest
    static void testGetDefaults_activeForScenario() {
        TestDataFactoryDefaultSettings.sObjNameToSettings.put('Account', new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                        Active_for_Default_Factory__c = false,
                        Active_for_Scenario__c = true,
                        Active_for_Custom_Factory__c = false,
                        SObject_API_Name__c = 'Account',
                        Field_API_Name__c = 'Description',
                        Field_Value__c = 'desc'
                )
        });
        Account acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, true, false);
        System.assertEquals(null, acc.Description);
        acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, false, false);
        System.assertEquals(null, acc.Description);
        acc = (Account) TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, false, true);
        System.assertEquals('desc', acc.Description);
    }
    @IsTest
    static void testGetDefaults_exceptions() {
        TestDataFactoryDefaultSettings.sObjNameToSettings.put('Account', new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                        DeveloperName = 'account',
                        Active_for_Default_Factory__c = true,
                        Active_for_Scenario__c = false,
                        Active_for_Custom_Factory__c = false,
                        SObject_API_Name__c = 'xyz',
                        Field_API_Name__c = 'Description',
                        Field_Value__c = '1'
                )
        });
        TestDataFactoryDefaultSettings.sObjNameToSettings.put('Contact', new List<Test_Data_Factory_Default__mdt>{
                new Test_Data_Factory_Default__mdt(
                        DeveloperName = 'contact',
                        Active_for_Default_Factory__c = true,
                        Active_for_Scenario__c = false,
                        Active_for_Custom_Factory__c = false,
                        SObject_API_Name__c = 'Contact',
                        Field_API_Name__c = 'xyz',
                        Field_Value__c = '1'
                )
        });
        try {
            TestDataFactoryDefaultSettings.getDefaults(Account.SObjectType, true, false);
        } catch (TestDataFactoryException e) {
            System.assert(e.getMessage().contains('Invalid SObject_API_Name__c.'));
        }
        try {
            TestDataFactoryDefaultSettings.getDefaults(Contact.SObjectType, true, false);
        } catch (TestDataFactoryException e) {
            System.assert(e.getMessage().contains('Invalid Field_API_Name__c.'));
        }
    }
}