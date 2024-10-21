/**
 * SObjectFactory result collection.
 *
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
global interface ISObjectFactoryResult {
    Integer size();
    SObjectType getSObjectType();
    List<SObject> toList();
    SObject toSObject();
    SObject toSObject(Integer idx);
    SObject toLastSObject();
    Map<Id, SObject> toMap();
    Set<Id> toIds();
}