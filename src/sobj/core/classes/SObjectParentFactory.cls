@IsTest
public without sharing class SObjectParentFactory {
    private static final Map<ISObjectFactory, Map<SObjectField, SObject>> factoryToSObjectFieldToParent = new Map<ISObjectFactory, Map<SObjectField, SObject>>();

    public void mergeParentSObject(ISObjectFactory sObjFactory, SObject defaults, SObject target) {
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
}