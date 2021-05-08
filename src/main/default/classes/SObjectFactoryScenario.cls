/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
global abstract class SObjectFactoryScenario implements ISObjectFactoryScenario {
    global virtual SObject makeParent(SObjectField sObjField, SObject target) {
        return null;
    }

    global virtual Database.DMLOptions getDmlOptions() {
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.duplicateRuleHeader.allowSave = true;
        return dmlOpts;
    }

    global virtual Boolean requireRecordType() {
        return true;
    }
    
    global virtual Boolean autoPopulateRequiredFields() {
        return true;
    }
}