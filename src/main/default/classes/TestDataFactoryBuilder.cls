/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
global without sharing class TestDataFactoryBuilder implements ITestDataFactoryBuilder {
    private final ITestDataFactory factory;
    private final TestDataParentFactory parentFactory = new TestDataParentFactory();
    private Type scenarioType;
    private final Map<SObjectField, List<Object>> rotations = new Map<SObjectField, List<Object>>();
    private SObjectFieldValueProvider valueProvider = new SObjectFieldValueProvider();

    public TestDataFactoryBuilder(TestDataFactory factory) {
        this.factory = factory;
    }

    global ITestDataFactoryBuilder useScenario(Type scenarioType) {
        if (this.scenarioType != null) {
            throw new TestDataFactoryException('Scenario already set');
        }
        this.scenarioType = scenarioType;
        return this;
    }

    global ITestDataFactoryBuilder rotate(SObjectField field, List<Object> values) {
        rotations.put(field, values);
        return this;
    }

    global ISObjectFactoryResult created(SObject target) {
        return make(SObjectDatabase.ProcessType.CREATED, 1, target);
    }

    global ISObjectFactoryResult inserted(SObject target) {
        return make(SObjectDatabase.ProcessType.INSERTED, 1, target);
    }

    global ISObjectFactoryResult mocked(SObject target) {
        return make(SObjectDatabase.ProcessType.MOCKED, 1, target);
    }

    global ISObjectFactoryResult created(Integer count, SObject target) {
        return make(SObjectDatabase.ProcessType.CREATED, count, target);
    }

    global ISObjectFactoryResult inserted(Integer count, SObject target) {
        return make(SObjectDatabase.ProcessType.INSERTED, count, target);
    }

    global ISObjectFactoryResult mocked(Integer count, SObject target) {
        return make(SObjectDatabase.ProcessType.MOCKED, count, target);
    }

    public ISObjectFactoryResult make(SObjectDatabase.ProcessType pType, Integer count, SObject target) {
        if (target == null) {
            throw new TestDataFactoryException('SObject target cannot be null');
        } else if (count == null || count < 1) {
            throw new TestDataFactoryException('Count is invalid: ' + count);
        }
        SObjectType targetSObjectType = target.getSObjectType();
        System.debug(TestDataFactoryBuilder.class + ' ' + pType + ' ' + count + ' ' + targetSObjectType);
        ISObjectFactory sObjFactory = loadSObjectFactory(targetSObjectType);
        Boolean isDefaultFactory = sObjFactory instanceof DefaultSObjectFactory;
        if (sObjFactory.requireRecordType()) {
            SObjectUtils.requireRecordType(target);
        }
        List<SObject> sObjects = new List<SObject>();
        SObject metadataDefaults = TestDataFactoryDefaultSettings.getDefaults(targetSObjectType, isDefaultFactory, isScenarioSet());
        for (Integer i = 0; i < count; ++i) {
            processIterations(i, target);
            SObject defaults = metadataDefaults.clone();
            SObject factoryDefaults = sObjFactory.createDefaults(target);
            if (factoryDefaults.getSObjectType() != target.getSObjectType()) {
                throw new TestDataFactoryException('Defaults sObject from "createDefaults" is of invalid type: ' + factoryDefaults.getSObjectType());
            }
            SObjectUtils.mergeSObjects(defaults, factoryDefaults);
            SObjectUtils.mergeSObjects(defaults, target);
            parentFactory.mergeParentSObject(sObjFactory, defaults, target);
            if (sObjFactory.autoPopulateRequiredFields()) {
                autoPopulateRequiredFields(targetSObjectType, defaults);
            }
            sObjects.add(defaults);
        }
        SObjectDatabase.process(pType, targetSObjectType, sObjects, sObjFactory.getDmlOptions());
        return new SObjectFactoryResult(targetSObjectType, sObjects);
    }

    private void processIterations(Integer idx, SObject target) {
        for (SObjectField field : rotations.keySet()) {
            List<Object> values = rotations.get(field);
            Object value = values[Math.mod(idx, values.size())];
            String relationshipName = field.getDescribe()?.getRelationshipName();
            if (relationshipName == null) {
                target.put(field, value);
            } else {
                if (value == null) {
                    target.putSObject(relationshipName, null);
                    target.put(field, null);
                } else if (value instanceof SObject) {
                    SObject sObjValue = (SObject) value;
                    target.putSObject(relationshipName, sObjValue);
                    target.put(field, sObjValue.Id);
                } else if (value instanceof Id) {
                    target.put(field, (Id) value);
                } else {
                    throw new TestDataFactoryException('Iteration value for Id field must be either SObject or Id, is ' + value);
                }
            }
        }
    }

    private void autoPopulateRequiredFields(SObjectType targetSObjectType, SObject defaults) {
        for (DescribeFieldResult requiredField : SObjectUtils.getDescribeFieldResultRequired(targetSObjectType)) {
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

    private ISObjectFactory loadSObjectFactory(SObjectType sObjType) {
        return isScenarioSet()
                ? factory.getSObjFactoryLoader().loadScenario(scenarioType)
                : factory.getSObjFactoryLoader().loadSObjectFactory(sObjType);
    }
    
    private Boolean isScenarioSet() {
        return scenarioType != null;
    }
}