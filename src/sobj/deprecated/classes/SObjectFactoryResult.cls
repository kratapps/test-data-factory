/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
global without sharing class SObjectFactoryResult implements ISObjectFactoryResult {
    private final SObjectType sObjType;
    private final List<SObject> sObjects;

    public SObjectFactoryResult(SObjectType sObjType, List<SObject> sObjects) {
        this.sObjType = sObjType;
        this.sObjects = sObjects;
    }

    global List<SObject> toList() {
        return sObjects;
    }

    global SObject toSObject() {
        return sObjects[0];
    }

    global SObject toSObject(Integer idx) {
        return sObjects[idx];
    }

    global SObject toLastSObject() {
        return sObjects[size() - 1];
    }

    global Map<Id, SObject> toMap() {
        return new Map<Id, SObject>(sObjects);
    }

    global Set<Id> toIds() {
        return toMap().keySet();
    }

    global Integer size() {
        return sObjects.size();
    }

    global SObjectType getSObjectType() {
        return sObjType;
    }
}