/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
global without sharing class SObjectUtils {
    global static Map<String, SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        private set;
    }

    global static DescribeSObjectResult describeSObject(SObjectType sObjType) {
        return SObjectFactoryUtils.describeSObject(sObjType);
    }

    global static Id getMockId(SObjectType sObjectType) {
        return MockId.getMockId(sObjectType);
    }

    global static void setMockIds(List<SObject> sObjects) {
        MockId.setMockIds(sObjects);
    }
}