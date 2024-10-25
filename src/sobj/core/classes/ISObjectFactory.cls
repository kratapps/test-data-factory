/**
 * Interface for custom SObject Factory template implementations.
 *
 * Licensed under BSD 3-Clause
 * https://docs.kratapps.com/test-data-factory/license/
 *
 * @author kratapps.com
 */
global interface ISObjectFactory {
    /**
     * This method creates a new record with default values. <br/>
     * Avoid any DML Operation here as it is called for every SObject created. <br/>
     *
     * @param   target the user supplied SObject
     * @return  created SObject
     */
    SObject createDefaults(SObject target);
    /**
     * Provide parent base SObject with default values. <br/>
     * This method is called only once for request and parent. <br/>
     * Return null if no parent is needed. <br/>
     *
     * @param   sObjField the reference SObject field, e.g. Contact.AccountId for parent Account
     * @param   target the user supplied SObject
     *
     * @return  created SObject
     */
    SObject makeParent(SObjectField sObjField, SObject target);
    /**
     * Every factory comes with DML Options,
     * default DML Options have `duplicateRuleHeader.allowSave` set to true.
     *
     * @return  DML Options
     */
    Database.DMLOptions getDmlOptions();
    /**
     * If SObject has record types,
     * it is enforced to set the RecordTypeId in the unit tests.
     * You can disable this feature by overriding this method. <br/>
     * Default is true. <br/>
     *
     * @return  true if required
     */
    Boolean requireRecordType();
    /**
     * Disable auto populating to improve performance. <br/>
     * Default is false. <br/>
     * Note that this feature is enabled for every SObject without SObject Factory class. <br/>
     *
     * @return  true if required
     */
    Boolean autoPopulateRequiredFields();
}