/**
 * Proxy for DML operations with mocking capability.
 *
 * Licensed under BSD 3-Clause
 * https://docs.kratapps.com/test-data-factory/license/
 *
 * @author kratapps.com
 */
@IsTest
global without sharing class SObjectDatabase {
    global enum ProcessType {
        CREATED,
        INSERTED,
        MOCKED
    }
    private final ProcessType processType;
    private static Map<Id, SObject> sObjectsByIds = new Map<Id, SObject>();

    @SuppressWarnings('PMD.emptystatementblock')
    global SObjectDatabase() {
        // Constructor has to remain in this global class as it was previously released.
    }

    public SObjectDatabase(ProcessType processType) {
        this.processType = processType;
    }

    public static SObject getRecord(Id sObjectId) {
        return sObjectsByIds.get(sObjectId);
    }

    public void process(SObjectType sObjType, List<SObject> sObjects, Database.DMLOptions dmlOpts) {
        fillIds(sObjType, sObjects);
        if (processType == SObjectDatabase.ProcessType.MOCKED) {
            MockId.setMockIds(sObjects);
            sObjectsByIds.putAll(sObjects);
        } else if (processType == SObjectDatabase.ProcessType.INSERTED) {
            processDatabaseResults(sObjType, Database.insert(sObjects, dmlOpts));
            sObjectsByIds.putAll(sObjects);
        }
    }

    private static void fillIds(SObjectType sObjType, List<SObject> sObjects) {
        for (Schema.SObjectField f : sObjType.getDescribe().fields.getMap().values()) {
            DescribeFieldResult fieldResult = f.getDescribe();
            if (fieldResult.getType() != Schema.DisplayType.REFERENCE) {
                continue;
            }
            String relationshipName = fieldResult.getRelationshipName();
            String idName = fieldResult.getName();
            if (relationshipName == null || idName == null) {
                continue;
            }
            for (SObject sObj : sObjects) {
                SObject parent = sObj.getSObject(relationshipName);
                if (parent != null) {
                    sObj.put(idName, parent.Id);
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
            throw new SObjectFactoryException(sObjType + ' insert failed:\n' + errors);
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