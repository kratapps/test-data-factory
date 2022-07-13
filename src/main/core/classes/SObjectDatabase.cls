/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
global without sharing class SObjectDatabase {
    global enum ProcessType {
        CREATED, INSERTED, MOCKED
    }
    private static final Map<Id, SObject> sObjectsByIds = new Map<Id, SObject>();

    public static SObject getRecord(Id sObjectId) {
        return sObjectsByIds.get(sObjectId);
    }
    
    public static void process(ProcessType pType, SObjectType sObjType, List<SObject> sObjects, Database.DMLOptions dmlOpts) {
        System.debug(SObjectDatabase.class + ': ' + pType + ' ' + sObjType);
        fillIds(sObjType, sObjects);
        if (pType == ProcessType.MOCKED) {
            SObjectUtils.setMockIds(sObjects);
            sObjectsByIds.putAll(sObjects);
        } else if (pType == ProcessType.INSERTED) {
            processDatabaseResults(sObjType, Database.insert(sObjects, dmlOpts));
            sObjectsByIds.putAll(sObjects);
        }
    }
    
    private static void fillIds(SObjectType sObjType, List<SObject> sObjects) {
        for (Schema.SObjectField f : sObjType.getDescribe().fields.getMap().values()) {
            DescribeFieldResult fieldResult = f.getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.REFERENCE) {
                String relationshipName = fieldResult.getRelationshipName();
                String idName = fieldResult.getName();
                if (relationshipName != null && idName != null) {
                    for (SObject sObj : sObjects) {
                        SObject parent = sObj.getSObject(relationshipName);
                        if (parent != null) {
                            sObj.put(idName, parent.Id);
                        }
                    }
                }
            }
        }
    }

    private static void processDatabaseResults(SObjectType sObjType, List<Database.SaveResult> results) {
        String errors = '';
        for (Integer i = 0; i < results.size(); ++i) {
            Database.SaveResult result = results[i];
            if (!result.isSuccess()) {
                errors += 'Insert failed on row ' + i + ', ' + joinErrors(result.getErrors()) + '\n';
            }
        }
        if (String.isNotBlank(errors)) {
            throw new TestDataFactoryException(sObjType +  ' insert failed:\n' + errors);
        }
    }

    private static String joinErrors(List<Database.Error> errors) {
        List<String> messages = new List<String>();
        for (Database.Error err : errors) {
            messages.add(err.getMessage());
        }
        return String.join(messages, ', ');
    }
}