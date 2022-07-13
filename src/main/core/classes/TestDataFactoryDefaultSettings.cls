/**
 * @author Ondrej Kratochvil
 * @date 2021-10-16
 */
@IsTest
public without sharing class TestDataFactoryDefaultSettings {
    @TestVisible
    private static final Map<String, List<Test_Data_Factory_Default__mdt>> sObjNameToSettings = new Map<String, List<Test_Data_Factory_Default__mdt>>();
    public static List<Test_Data_Factory_Default__mdt> getValues(String sObjName) {
        if (!sObjNameToSettings.containsKey(sObjName)) {
            List<Test_Data_Factory_Default__mdt> settings = [
                    SELECT
                            DeveloperName,
                            Active_for_Custom_Factory__c,
                            Active_for_Default_Factory__c,
                            Active_for_Scenario__c,
                            Field_API_Name__c,
                            SObject_API_Name__c,
                            Field_Value__c
                    FROM Test_Data_Factory_Default__mdt
                    WHERE SObject_API_Name__c = :sObjName
            ];
            sObjNameToSettings.put(sObjName, settings);
        }
        return sObjNameToSettings.get(sObjName);
    }

    public static SObject getDefaults(SObjectType sObjectType, Boolean isDefaultFactory, Boolean isScenario) {
        SObject defaults = sObjectType.newSObject();
        String sObjName = sObjectType?.getDescribe()?.getName();
        List<Test_Data_Factory_Default__mdt> settings = TestDataFactoryDefaultSettings.getValues(sObjName);
        for (Test_Data_Factory_Default__mdt setting : settings) {
            if ((isScenario && setting.Active_for_Scenario__c) ||
                    (!isScenario && isDefaultFactory && setting.Active_for_Default_Factory__c) ||
                    (!isScenario && !isDefaultFactory && setting.Active_for_Custom_Factory__c)) {
                SObjectType sObjType = SObjectUtils.globalDescribe.get(setting.SObject_API_Name__c);
                if (sObjType == null) {
                    throw new TestDataFactoryException('Invalid SObject_API_Name__c. Check your Test_Data_Factory_Default__mdt record: ' + setting.DeveloperName);
                }
                DescribeFieldResult dfr = SObjectUtils.getDescribeFieldResult(sObjType, setting.Field_API_Name__c);
                if (dfr == null) {
                    throw new TestDataFactoryException('Invalid Field_API_Name__c. Check your Test_Data_Factory_Default__mdt record: ' + setting.DeveloperName);
                }
                try {
                    Object fieldValue = SObjectUtils.parseFieldValue(sObjType, setting.Field_API_Name__c, setting.Field_Value__c);
                    defaults.put(setting.Field_API_Name__c, fieldValue);
                } catch (SObjectException e) {
                    throw new TestDataFactoryException('Unsupported data type. Check your Test_Data_Factory_Default__mdt record: ' + setting.DeveloperName, e);
                }
            }
        }
        return defaults;
    }
}
