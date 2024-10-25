/**
 * Mock SObject IDs without insert DML operation.
 *
 * Licensed under BSD 3-Clause
 * https://docs.kratapps.com/test-data-factory/license/
 *
 * @author kratapps.com
 */
global inherited sharing class MockId {
    private static Map<SObjectType, Long> mockIdCountBySObjectType = new Map<SObjectType, Long>();

    global static Id getMockId(SObjectType sObjectType) {
        String keyPrefix = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix();
        Long mockIdCount = mockIdCountBySObjectType.containsKey(sObjectType) ? mockIdCountBySObjectType.get(sObjectType) + 1 : 1;
        mockIdCountBySObjectType.put(sObjectType, mockIdCount);
        String uniqueSuffix = String.valueOf(mockIdCount);
        String idString = keyPrefix + '0'.repeat(12 - uniqueSuffix.length()) + uniqueSuffix;
        return Id.valueOf(idString);
    }

    global static void setMockIds(List<SObject> records) {
        for (SObject record : records) {
            record.put('Id', getMockId(record.getSObjectType()));
        }
    }
}