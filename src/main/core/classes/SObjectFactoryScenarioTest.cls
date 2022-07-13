/**
 * @author Ondrej Kratochvil
 * @date 2021-06-04
 */
@IsTest
private class SObjectFactoryScenarioTest {
    @IsTest
    static void testBehavior() {
        ScenarioImpl sObjFactory = new ScenarioImpl();
        System.assertEquals(null, sObjFactory.makeParent(null, null));
        System.assert(sObjFactory.getDmlOptions().duplicateRuleHeader.allowSave);
        System.assert(sObjFactory.requireRecordType());
        System.assert(!sObjFactory.autoPopulateRequiredFields());
    }

    private class ScenarioImpl extends SObjectFactoryScenario {
        public SObject createDefaults(SObject target) {
            return null;
        }
    }
}