/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
global without sharing class SObjectUtils {
    private static Map<SObjectType, Long> mockIdCountBySObjectType = new Map<SObjectType, Long>();
    
    global static Id getMockId(SObjectType sObjType) {
        String keyPrefix = sObjType.getDescribe().getKeyPrefix();
        Long mockIdCount = mockIdCountBySObjectType.containsKey(sObjType) ? mockIdCountBySObjectType.get(sObjType) + 1 : 1;
        mockIdCountBySObjectType.put(sObjType, mockIdCount);
        String uniqueSuffix = String.valueOf(mockIdCount);
        String idString = keyPrefix + '0'.repeat(12 - uniqueSuffix.length()) + uniqueSuffix;
        return Id.valueOf(idString);
    }

    global static void setMockIds(List<SObject> sObjects) {
        for (SObject sObj : sObjects) {
            sObj.put('Id', getMockId(sObj.getSObjectType()));
        }
    }

    public static void mergeSObjects(SObject target, SObject source) {
        SObjectType sObjType = source.getSObjectType();
        Map<String, Object> populatedFields = source.getPopulatedFieldsAsMap();
        for (String fieldName : populatedFields.keySet()) {
            Object fieldValue = populatedFields.get(fieldName);
            if (fieldValue != null) {
                if (fieldValue instanceof SObject) {
                    target.putSObject(fieldName, (SObject) fieldValue);
                } else {
                    DescribeFieldResult f = getDescribeFieldResult(sObjType, fieldName);
                    if (f != null) {
                        target.put(f.getSobjectField(), fieldValue);
                    }
                }
            }
        }
    }

    public static DescribeFieldResult getDescribeFieldResult(SObjectType sObjType, String fieldName) {
        return getDescribeSObjectFieldMap(sObjType).get(fieldName)?.getDescribe();
    }

    private static Map<SObjectType, List<DescribeFieldResult>> describeFieldResultRequiredBySObjectType =
            new Map<SObjectType, List<DescribeFieldResult>>();
    public static List<DescribeFieldResult> getDescribeFieldResultRequired(SObjectType sObjType) {
        if (!describeFieldResultRequiredBySObjectType.containsKey(sObjType)) {
            List<DescribeFieldResult> results = new List<DescribeFieldResult>();
            for (SObjectField f : getDescribeSObjectFieldMap(sObjType).values()) {
                DescribeFieldResult fieldDescribe = f.getDescribe();
                if (isRequired(fieldDescribe)) {
                    results.add(fieldDescribe);
                }
            }
            describeFieldResultRequiredBySObjectType.put(sObjType, results);
        }
        return describeFieldResultRequiredBySObjectType.get(sObjType);
    }

    private static Boolean isRequired(DescribeFieldResult fieldDescribe) {
        return !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate() &&
                !fieldDescribe.isAutoNumber() && fieldDescribe.isCreateable();
    }

    private static Map<SObjectType, List<DescribeFieldResult>> describeFieldResultReferencesBySObjectType =
            new Map<SObjectType, List<DescribeFieldResult>>();
    public static List<DescribeFieldResult> getDescribeFieldResultReferences(SObjectType sObjType) {
        if (!describeFieldResultReferencesBySObjectType.containsKey(sObjType)) {
            List<DescribeFieldResult> results = new List<DescribeFieldResult>();
            for (SObjectField f : getDescribeSObjectFieldMap(sObjType).values()) {
                DescribeFieldResult fieldResult = f.getDescribe();
                if (fieldResult.getType() == DisplayType.REFERENCE) {
                    results.add(fieldResult);
                }
            }
            describeFieldResultReferencesBySObjectType.put(sObjType, results);
        }
        return describeFieldResultReferencesBySObjectType.get(sObjType);
    }
    
    private static Map<SObjectType, Map<String, SObjectField>> describeSObjectFieldMapBySObjectType = 
            new Map<SObjectType, Map<String, SObjectField>>();
    private static Map<String, SObjectField> getDescribeSObjectFieldMap(SObjectType sObjType) {
        if (!describeSObjectFieldMapBySObjectType.containsKey(sObjType)) {
            describeSObjectFieldMapBySObjectType.put(sObjType, sObjType.getDescribe().fields.getMap());
        }
        return describeSObjectFieldMapBySObjectType.get(sObjType);
    }

    public static void requireRecordType(SObject target) {
        Integer recordTypesSize = 0;
        for (Schema.RecordTypeInfo info : target.getSObjectType().getDescribe().getRecordTypeInfos()) {
            if (info.isActive()) {
                ++recordTypesSize;
            }
        }
        if (recordTypesSize > 1 && target.getPopulatedFieldsAsMap().get('RecordTypeId') == null) {
            throw new TestDataFactoryException('Record Type need to be specified: ' + target.getSObjectType());
        }
    }
}