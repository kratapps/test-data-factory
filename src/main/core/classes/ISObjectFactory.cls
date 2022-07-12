/**
 * SObject factory provide base SObject with default values. <br/>
 * 
 * Factory name need to be in format: <br/>
 * SObject API Name Without suffix and underscores following with 'Factory' string. <br/>
 * You can also created factory for custom settings and managed SObjects. <br/>
 * 
 * You can create multiple scenarios for one SObjectType with any name you want. <br/>
 * To use scenario you need to use the `useScenario` method. <br/>
 * 
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
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