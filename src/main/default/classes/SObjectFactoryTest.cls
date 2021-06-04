/**
 * @author Ondrej Kratochvil
 * @date 2021-06-04
 */
@IsTest
private class SObjectFactoryTest {
    @IsTest
    static void testBehavior() {
        SObjectFactory sObjFactory = new FactoryImpl();
        System.assertEquals(null, sObjFactory.makeParent(null, null));
        System.assert(sObjFactory.getDmlOptions().duplicateRuleHeader.allowSave);
        System.assert(sObjFactory.requireRecordType());
        System.assert(!sObjFactory.autoPopulateRequiredFields());
    }
    
    private class FactoryImpl extends SObjectFactory {
        public SObject createDefaults(SObject target) {
            return null;
        }
    }
}