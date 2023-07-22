/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
global without sharing class SObjectUtils {
    private static Map<SObjectType, Long> mockIdCountBySObjectType = new Map<SObjectType, Long>();
    private static Map<SObjectType, Map<String, SObjectField>> fieldsByRelationshipNamesBySObjectTypes = new Map<SObjectType, Map<String, SObjectField>>();
    private static final Set<SoapType> PUT_SOAP_TYPES = new Set<SoapType>{
        SoapType.STRING,
        SoapType.ID,
        SoapType.BOOLEAN,
        SoapType.INTEGER,
        SoapType.DOUBLE,
        SoapType.LONG,
        SoapType.DATETIME,
        SoapType.DATE
    };
    global static Map<String, SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        private set;
    }
    private static final Map<SObjectType, DescribeSObjectResult> describeSObjectResults = new Map<SObjectType, DescribeSObjectResult>();

    global static DescribeSObjectResult describeSObject(SObjectType sObjType) {
        if (!describeSObjectResults.containsKey(sObjType)) {
            describeSObjectResults.put(sObjType, globalDescribe.get(String.valueOf(sObjType)).getDescribe());
        }
        return describeSObjectResults.get(sObjType);
    }

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
        Boolean isCustomMetadata = sObjType.getDescribe().getName()?.endsWith('__mdt');
        Map<String, Object> populatedFields = source.getPopulatedFieldsAsMap();
        for (String fieldName : populatedFields.keySet()) {
            Object fieldValue = populatedFields.get(fieldName);
            safePut(target, sObjType, isCustomMetadata, fieldName, fieldValue);
        }
    }

    public static void safePut(SObject sObj, SObjectType sObjType, Boolean isCustomMetadata, String fieldName, Object fieldValue) {
        DescribeFieldResult dfr = getDescribeFieldResult(sObjType, fieldName);
        if (dfr == null) {
            SObject record = (SObject) fieldValue;
            sObj.putSObject(fieldName, record);
            if (record?.Id != null) {
                SObjectField field = getFieldByRelationshipName(sObjType, fieldName);
                if (field != null) {
                    sObj.put(field, record.Id);
                }
            }
        } else if (PUT_SOAP_TYPES.contains(dfr.soapType) && !dfr.isAutoNumber()) {
            // DML on MDT is not possible so we can ignore isCreateable for MDT
            sObj.put(fieldName, fieldValue);
        }
    }

    public static DescribeFieldResult getDescribeFieldResult(SObjectType sObjType, String fieldName) {
        return getDescribeSObjectFieldMap(sObjType).get(fieldName)?.getDescribe();
    }

    private static Map<SObjectType, List<DescribeFieldResult>> describeFieldResultRequiredBySObjectType = new Map<SObjectType, List<DescribeFieldResult>>();
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
        return !fieldDescribe.isNillable() &&
            !fieldDescribe.isDefaultedOnCreate() &&
            !fieldDescribe.isAutoNumber() &&
            fieldDescribe.isCreateable();
    }

    private static Map<SObjectType, List<DescribeFieldResult>> describeFieldResultReferencesBySObjectType = new Map<SObjectType, List<DescribeFieldResult>>();
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

    private static Map<SObjectType, Map<String, SObjectField>> describeSObjectFieldMapBySObjectType = new Map<SObjectType, Map<String, SObjectField>>();
    private static Map<String, SObjectField> getDescribeSObjectFieldMap(SObjectType sObjType) {
        if (!describeSObjectFieldMapBySObjectType.containsKey(sObjType)) {
            describeSObjectFieldMapBySObjectType.put(sObjType, describeSObject(sObjType).fields.getMap());
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

    public static Object parseFieldValue(SObjectType sObjType, String fieldName, String fieldValue) {
        SoapType sType = SObjectUtils.getDescribeFieldResult(sObjType, fieldName).soapType;
        switch on sType {
            when STRING {
                return fieldValue;
            }
            when ID {
                return Id.valueOf(fieldValue);
            }
            when BOOLEAN {
                return Boolean.valueOf(fieldValue);
            }
            when INTEGER {
                return Integer.valueOf(fieldValue);
            }
            when DOUBLE {
                return Double.valueOf(fieldValue);
            }
            when LONG {
                return Long.valueOf(fieldValue);
            }
            when DATETIME {
                return Datetime.valueOf(fieldValue);
            }
            when DATE {
                return Date.valueOf(fieldValue);
            }
            when else {
                throw new SObjectException('Unsupported Soap Type: ' + sType);
            }
        }
    }

    private static SObjectField getFieldByRelationshipName(SObjectType sObjType, String relationshipName) {
        if (!fieldsByRelationshipNamesBySObjectTypes.containsKey(sObjType)) {
            Map<String, SObjectField> fieldsByRelationshipNames = new Map<String, SObjectField>();
            for (SObjectField field : sObjType.getDescribe().fields.getMap().values()) {
                String relName = field.getDescribe().getRelationshipName();
                if (relName != null) {
                    fieldsByRelationshipNames.put(relName, field);
                }
                fieldsByRelationshipNamesBySObjectTypes.put(sObjType, fieldsByRelationshipNames);
            }
        }
        return fieldsByRelationshipNamesBySObjectTypes.get(sObjType).get(relationshipName);
    }
}