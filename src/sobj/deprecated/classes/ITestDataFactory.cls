/**
 * Test Data Factory.
 *
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
global interface ITestDataFactory {
    /**
     * Get factory loader associated with this factory.

     * @return  the SObject factory loader
     * 
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    SObjectFactoryLoader getSObjFactoryLoader();
    /**
     * Override default SObjectFactory with SObjectFactoryScenario.
     *
     * @param   scenarioType the class type extending SObjectFactoryScenario
     * @return  this builder
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ITestDataFactoryBuilder useScenario(Type scenarioType);
    /**
     * Create multiple records with different field values.
     *
     * @param   field the target field
     * @param   values the values used
     * @return  factory builder
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ITestDataFactoryBuilder rotate(SObjectField field, List<Object> values);
    /**
     * Set namespace of SObject factories to use. <br/>
     *
     * @param   namespacePrefix the namespace
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    void setNamespace(String namespacePrefix);
    /**
     * Create SObject. The target SObject is merged with the default SObject from your factory. <br/>
     * Use `created` if you don't need SObjects to be inserted in database. <br/>
     * Use `mocked` if you need records with Ids. <br/>
     * Use `inserted` if you need records with Ids and in database. <br/>
     *
     * @param   target the target SObject with optional specific attributes
     * @return  factory result
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ISObjectFactoryResult created(SObject target);
    /**
     * Insert SObject. The target SObject is merged with the default SObject from your factory. <br/>
     * Use `created` if you don't need SObjects to be inserted in database. <br/>
     * Use `mocked` if you need records with Ids. <br/>
     * Use `inserted` if you need records with Ids and in database. <br/>
     *
     * @param   target the target SObject with optional specific attributes
     * @return  factory result
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ISObjectFactoryResult inserted(SObject target);
    /**
     * Mock SObject. The target SObject is merged with the default SObject from your factory. <br/>
     * Use `created` if you don't need SObjects to be inserted in database. <br/>
     * Use `mocked` if you need records with Ids. <br/>
     * Use `inserted` if you need records with Ids and in database. <br/>
     *
     * @param   target the target SObject with optional specific attributes
     * @return  factory result
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ISObjectFactoryResult mocked(SObject target);
    /**
     * Create SObjects. The target SObjects are merged with the default SObject from your factory. <br/>
     * Use `created` if you don't need SObjects to be inserted in database. <br/>
     * Use `mocked` if you need records with Ids. <br/>
     * Use `inserted` if you need records with Ids and in database. <br/>
     *
     * @param   count number of target records
     * @param   target the target SObject with optional specific attributes
     * @return  factory result
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ISObjectFactoryResult created(Integer count, SObject target);
    /**
     * Insert SObjects. The target SObjects are merged with default SObject from your factory. <br/>
     * Use `created` if you don't need SObjects to be inserted in database. <br/>
     * Use `mocked` if you need records with Ids. <br/>
     * Use `inserted` if you need records with Ids and in database. <br/>
     *
     * @param   count number of target records
     * @param   target the target SObject with optional specific attributes
     * @return  factory result
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ISObjectFactoryResult inserted(Integer count, SObject target);
    /**
     * Mock SObjects. The target SObjects are merged with default SObject from your factory. <br/>
     * Use `created` if you don't need SObjects to be inserted in database. <br/>
     * Use `mocked` if you need records with Ids. <br/>
     * Use `inserted` if you need records with Ids and in database. <br/>
     *
     * @param   count number of target records
     * @param   target the target SObject with optional specific attributes
     * @return  factory result
     *
     * @author  Ondrej Kratochvil
     * @date    2021-04-06
     */
    ISObjectFactoryResult mocked(Integer count, SObject target);
}