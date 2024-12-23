/**
 * Utility class to describe SObjects.
 *
 * Licensed under BSD 3-Clause
 * https://docs.kratapps.com/test-data-factory/license/
 *
 * @author kratapps.com
 */
@SuppressWarnings('PMD.cyclomaticcomplexity')
public inherited sharing class SObjectFactoryUtils {
    private static Map<SObjectType, DescribeSObjectResult> describeSObjectResults = new Map<SObjectType, DescribeSObjectResult>();
    private static Map<SObjectType, Map<String, SObjectField>> fieldsByRelationshipNamesBySObjectTypes = new Map<SObjectType, Map<String, SObjectField>>();
    private static Map<SObjectType, Map<String, SObjectField>> describeSObjectFieldMapBySObjectType = new Map<SObjectType, Map<String, SObjectField>>();
    private static Map<SObjectType, List<DescribeFieldResult>> describeFieldResultReferencesBySObjectType = new Map<SObjectType, List<DescribeFieldResult>>();
    private static Map<SObjectType, List<DescribeFieldResult>> describeFieldResultRequiredBySObjectType = new Map<SObjectType, List<DescribeFieldResult>>();
    private static Map<ISObjectFactory, Map<SObjectField, SObject>> factoryToSObjectFieldToParent = new Map<ISObjectFactory, Map<SObjectField, SObject>>();

    private static final Set<SoapType> SAFE_PUT_SOAP_TYPES = new Set<SoapType>{
        SoapType.STRING,
        SoapType.ID,
        SoapType.BOOLEAN,
        SoapType.INTEGER,
        SoapType.DOUBLE,
        SoapType.LONG,
        SoapType.DATETIME,
        SoapType.DATE
    };

    public static Map<String, SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        private set;
    }

    public static void mergeSObjects(SObject target, SObject source) {
        Map<String, Object> populatedFields = source.getPopulatedFieldsAsMap();
        for (String fieldName : populatedFields.keySet()) {
            Object fieldValue = populatedFields.get(fieldName);
            safePut(target, fieldName, fieldValue);
        }
    }

    @TestVisible
    private static void safePut(SObject record, String fieldName, Object fieldValue) {
        SObjectType sObjType = record.getSObjectType();
        DescribeFieldResult dfr = getDescribeFieldResult(sObjType, fieldName);
        if (dfr == null) {
            SObject recordValue = (SObject) fieldValue;
            record.putSObject(fieldName, recordValue);
            if (recordValue?.Id != null) {
                SObjectField field = getFieldByRelationshipName(sObjType, fieldName);
                if (field != null) {
                    record.put(field, recordValue.Id);
                }
            }
        } else if (SAFE_PUT_SOAP_TYPES.contains(dfr.soapType) && !dfr.isAutoNumber()) {
            record.put(fieldName, fieldValue);
        }
    }

    public static DescribeSObjectResult describeSObject(SObjectType sObjType) {
        if (!describeSObjectResults.containsKey(sObjType)) {
            describeSObjectResults.put(sObjType, globalDescribe.get(String.valueOf(sObjType)).getDescribe());
        }
        return describeSObjectResults.get(sObjType);
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

    public static void requireRecordType(SObject target) {
        Integer recordTypesSize = 0;
        for (Schema.RecordTypeInfo info : target.getSObjectType().getDescribe().getRecordTypeInfos()) {
            if (info.isActive()) {
                ++recordTypesSize;
            }
        }
        if (recordTypesSize > 1 && target.getPopulatedFieldsAsMap().get('RecordTypeId') == null) {
            throw new SObjectFactoryException('Record Type need to be specified: ' + target.getSObjectType());
        }
    }

    public static Object parseFieldValue(SObjectType sObjType, String fieldName, String fieldValue) {
        SoapType sType = SObjectFactoryUtils.getDescribeFieldResult(sObjType, fieldName).soapType;
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

    public static DescribeFieldResult getDescribeFieldResult(SObjectType sObjType, String fieldName) {
        return getDescribeSObjectFieldMap(sObjType).get(fieldName)?.getDescribe();
    }

    public static void mergeParentSObject(ISObjectFactory sObjFactory, SObject defaults, SObject target) {
        List<DescribeFieldResult> fieldResults = SObjectFactoryUtils.getDescribeFieldResultReferences(defaults.getSObjectType());
        for (DescribeFieldResult fieldResult : fieldResults) {
            String relationshipName = fieldResult.getRelationshipName();
            if (relationshipName != null && defaults.getSObject(relationshipName) == null) {
                SObjectField parentField = fieldResult.getSobjectField();
                SObject parent = getParentDefaults(sObjFactory, parentField, target);
                if (parent != null) {
                    defaults.putSObject(relationshipName, parent);
                    defaults.put(fieldResult.getName(), parent.Id);
                }
            }
        }
    }

    private static SObject getParentDefaults(ISObjectFactory sObjFactory, SObjectField parentField, SObject target) {
        if (!factoryToSObjectFieldToParent.containsKey(sObjFactory)) {
            factoryToSObjectFieldToParent.put(sObjFactory, new Map<SObjectField, SObject>());
        }
        Map<SObjectField, SObject> relationshipNameToParent = factoryToSObjectFieldToParent.get(sObjFactory);
        if (!relationshipNameToParent.containsKey(parentField)) {
            SObject parent = sObjFactory.makeParent(parentField, target);
            relationshipNameToParent.put(parentField, parent);
        }
        return relationshipNameToParent.get(parentField);
    }

    private static Map<String, SObjectField> getDescribeSObjectFieldMap(SObjectType sObjType) {
        if (!describeSObjectFieldMapBySObjectType.containsKey(sObjType)) {
            describeSObjectFieldMapBySObjectType.put(sObjType, describeSObject(sObjType).fields.getMap());
        }
        return describeSObjectFieldMapBySObjectType.get(sObjType);
    }

    private static Boolean isRequired(DescribeFieldResult fieldDescribe) {
        return !fieldDescribe.isNillable() &&
            !fieldDescribe.isDefaultedOnCreate() &&
            !fieldDescribe.isAutoNumber() &&
            fieldDescribe.isCreateable();
    }
}