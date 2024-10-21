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