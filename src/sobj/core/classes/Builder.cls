global class Builder {
    private final SObjectDatabase.ProcessType processType;
    private final ISObjectFactory factory;
    private final Integer numberOfRecords;
    private List<SObject> sObjects;
    private SObjectFieldValueProvider valueProvider = new SObjectFieldValueProvider();
    private final Map<SObjectField, List<SObject>> childrenByRelationship = new Map<SObjectField, List<SObject>>();
    private final Map<SObjectField, Object> readOnlyValuesByField = new Map<SObjectField, Object>();
    private Boolean autoPopulateRequiredFields;

    public Builder(SObjectDatabase.ProcessType processType, SObjectFactory factory) {
        this.processType = processType;
        this.factory = factory;
        this.numberOfRecords = 1;
    }

    public Builder(SObjectDatabase.ProcessType processType, SObjectFactory factory, Integer numberOfRecords) {
        this.processType = processType;
        this.factory = factory;
        this.numberOfRecords = numberOfRecords;
        if (numberOfRecords == null || numberOfRecords < 1) {
            throw new SObjectFactoryException('Number of records is invalid: ' + numberOfRecords);
        }
    }

    global List<SObject> toList() {
        return sObjects;
    }

    global SObject toSObject() {
        return sObjects.get(0);
    }

    global Set<Id> toIds() {
        return new Map<Id, SObject>(sObjects).keySet();
    }

    global Builder setChildren(SObjectField relationship, List<SObject> children) {
        childrenByRelationship.put(relationship, children);
        return this;
    }

    global Builder setChildren(Map<SObjectField, List<SObject>> childrenByRelationship) {
        this.childrenByRelationship.putAll(childrenByRelationship);
        return this;
    }

    global Builder setReadOnly(SObjectField relationship, Object value) {
        readOnlyValuesByField.put(relationship, value);
        return this;
    }

    global Builder setRequiredFields() {
        autoPopulateRequiredFields = true;
        return this;
    }

    global Builder build(SObject target) {
        if (target == null) {
            throw new SObjectFactoryException('SObject target cannot be null');
        }
        sObjects = new List<SObject>();
        SObjectType targetSObjectType = target.getSObjectType();
        SObject defaults = targetSObjectType.newSObject();
        for (Integer i = 0; i < numberOfRecords; ++i) {
            SObject record = defaults.clone();
            SObject factoryDefaults = factory.createDefaults(target);
            if (factoryDefaults.getSObjectType() != target.getSObjectType()) {
                throw new SObjectFactoryException(
                    'Defaults sObject from "createDefaults" is of invalid type: ' + factoryDefaults.getSObjectType()
                );
            }
            SObjectFactoryUtils.mergeSObjects(record, factoryDefaults);
            SObjectFactoryUtils.mergeSObjects(record, target);
            SObjectFactoryUtils.mergeParentSObject(factory, record, target);
            if ((autoPopulateRequiredFields == null && factory.autoPopulateRequiredFields()) || autoPopulateRequiredFields == true) {
                autoPopulateRequiredFields(targetSObjectType, record);
            }
            record = buildReadOnlyAttributes(record);
            // ID could be populated through defaults record. Clear the value.
            record.Id = null;
            sObjects.add(record);
        }
        SObjectDatabase.process(processType, targetSObjectType, sObjects, factory.getDmlOptions());
        return this;
    }

    private SObject buildReadOnlyAttributes(SObject record) {
        Map<String, Object> untypedRecord = record.getPopulatedFieldsAsMap().clone();
        // Set children
        for (SObjectField relationship : childrenByRelationship.keySet()) {
            List<SObject> children = childrenByRelationship.get(relationship);
            List<ChildRelationship> childRelationships = relationship.getDescribe().getSObjectType().getDescribe().getChildRelationships();
            for (ChildRelationship childRel : childRelationships) {
                if (childRel.getField() == relationship) {
                    untypedRecord.put(
                        childRel.getRelationshipName(),
                        new Map<String, Object>{ 'totalSize' => children.size(), 'done' => true, 'records' => children }
                    );
                    break;
                }
            }
        }
        // Set read only fields
        for (SObjectField field : readOnlyValuesByField.keySet()) {
            Object value = readOnlyValuesByField.get(field);
            untypedRecord.put(field.toString(), value);
        }
        return (SObject) JSON.deserialize(JSON.serialize(untypedRecord), Type.forName(record.getSObjectType().toString()));
    }

    private void autoPopulateRequiredFields(SObjectType targetSObjectType, SObject defaults) {
        for (DescribeFieldResult requiredField : SObjectFactoryUtils.getDescribeFieldResultRequired(targetSObjectType)) {
            SObjectField field = requiredField.getSobjectField();
            DescribeFieldResult fieldDesc = field.getDescribe();
            if (requiredField.getDefaultValue() == null && defaults.get(field) == null) {
                Object value = valueProvider.getDefaultValue(field).value;
                if (value instanceof SObject) {
                    SObject sObjValue = (SObject) value;
                    String relationshipName = fieldDesc.getRelationshipName();
                    defaults.putSObject(relationshipName, sObjValue);
                    defaults.put(field, sObjValue.Id);
                } else {
                    defaults.put(field, value);
                }
            }
        }
    }
}