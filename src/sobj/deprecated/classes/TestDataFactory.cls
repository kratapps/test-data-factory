/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
global without sharing class TestDataFactory implements ITestDataFactory {
    private final SObjectFactoryLoader sObjFactoryLoader = new SObjectFactoryLoader();

    public SObjectFactoryLoader getSObjFactoryLoader() {
        return sObjFactoryLoader;
    }

    global static SObject getRecord(Id sObjectId) {
        return SObjectDatabase.getRecord(sObjectId);
    }

    global static SObject setChildren(SObject record, SObjectField relationship, List<SObject> children) {
        Map<SObjectField, List<SObject>> childrenByRelationship = new Map<SObjectField, List<SObject>>{ relationship => children };
        return setChildren(record, childrenByRelationship);
    }

    global static SObject setChildren(SObject record, Map<SObjectField, List<SObject>> childrenByRelationship) {
        Map<String, Object> populatedFields = record.getPopulatedFieldsAsMap().clone();
        for (SObjectField relationship : childrenByRelationship.keySet()) {
            List<SObject> children = childrenByRelationship.get(relationship);
            List<ChildRelationship> childRelationships = relationship.getDescribe().getSObjectType().getDescribe().getChildRelationships();
            for (ChildRelationship childRel : childRelationships) {
                if (childRel.getField() == relationship) {
                    populatedFields.put(
                        childRel.getRelationshipName(),
                        new Map<String, Object>{ 'totalSize' => children.size(), 'done' => true, 'records' => children }
                    );
                    break;
                }
            }
        }
        return (SObject) JSON.deserialize(JSON.serialize(populatedFields), Type.forName(record.getSObjectType().toString()));
    }

    global ITestDataFactoryBuilder useScenario(Type scenarioType) {
        return new TestDataFactoryBuilder(this).useScenario(scenarioType);
    }

    global void setNamespace(String namespacePrefix) {
        sObjFactoryLoader.namespacePrefix = namespacePrefix;
    }

    global ITestDataFactoryBuilder rotate(SObjectField field, List<Object> values) {
        return builder().rotate(field, values);
    }

    global ISObjectFactoryResult created(SObject target) {
        return builder().created(1, target);
    }

    global ISObjectFactoryResult inserted(SObject target) {
        return builder().inserted(1, target);
    }

    global ISObjectFactoryResult mocked(SObject target) {
        return builder().mocked(1, target);
    }

    global ISObjectFactoryResult created(Integer count, SObject target) {
        return builder().make(SObjectDatabase.ProcessType.CREATED, count, target);
    }

    global ISObjectFactoryResult inserted(Integer count, SObject target) {
        return builder().make(SObjectDatabase.ProcessType.INSERTED, count, target);
    }

    global ISObjectFactoryResult mocked(Integer count, SObject target) {
        return builder().make(SObjectDatabase.ProcessType.MOCKED, count, target);
    }

    private ITestDataFactoryBuilder builder() {
        return new TestDataFactoryBuilder(this);
    }
}