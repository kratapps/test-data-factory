/**
 * First version of custom SObject Factory template implementations.
 * Partially replaced by BaseSObjectFactory in v2.
 *
 * Licensed under BSD 3-Clause
 * https://docs.kratapps.com/test-data-factory/license/
 *
 * @author kratapps.com
 */
global abstract class SObjectFactory implements ISObjectFactory {
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
        return false;
    }
}