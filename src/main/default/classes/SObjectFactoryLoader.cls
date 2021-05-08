/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
global without sharing class SObjectFactoryLoader {
    public String namespacePrefix = '';
    public static Boolean isSObjPackageRunningTest = false;
    
    private static final Map<Type, SObjectFactoryScenario> scenarioCache = new Map<Type, SObjectFactoryScenario>();
    private static final Map<SObjectType, SObjectFactory> factories = new Map<SObjectType, SObjectFactory>();
    
    public ISObjectFactory loadScenario(Type scenarioType) {
        if (!scenarioCache.containsKey(scenarioType)) {
            Object scenarioObject;
            try {
                scenarioObject = scenarioType.newInstance();
            } catch (Exception e) {
                throw new TestDataFactoryException('SObject Factory Scenario constructor failed: ' + scenarioType.getName(), e);
            }
            SObjectFactoryScenario scenario;
            try {
                scenario = (SObjectFactoryScenario) scenarioObject;
            } catch (Exception e) {
                throw new TestDataFactoryException('SObject Factory Scenario is not extending SObjectFactoryScenario: ' + scenarioType.getName(), e);
            }
            scenarioCache.put(scenarioType, scenario);
        }
        return scenarioCache.get(scenarioType);
    }

    public ISObjectFactory loadSObjectFactory(SObjectType sObjType) {
        if (!factories.containsKey(sObjType)) {
            SObjectFactory sObjFactory = loadSObjectFactory(getSObjectFactoryType(sObjType));
            factories.put(sObjType, sObjFactory);
        }
        return factories.get(sObjType);
    }
    
    private SObjectFactory loadSObjectFactory(Type factoryType) {
        Object factory;
        try {
           factory = factoryType.newInstance();
        } catch (Exception e) {
            throw new TestDataFactoryException('SObject Factory constructor failed: ' + factoryType.getName(), e);
        }
        try {
            return (SObjectFactory) factory;
        } catch (Exception e) {
            throw new TestDataFactoryException('SObject Factory is not extending SObjectFactory: ' + factoryType.getName(), e);
        }
    }
    
    private String getFactoryName(SObjectType sObjType) {
        String sObjName = sObjType.getDescribe().getName();
        return sObjName.replaceAll('__mdt|__c|_', '') + 'Factory';
    }

    private Type getSObjectFactoryType(SObjectType sObjType) {
        String factoryName = getFactoryName(sObjType);
        String ns = isSObjPackageRunningTest ? 'sobj' : namespacePrefix;
        Type factoryType = Type.forName(ns, factoryName);
        if (factoryType == null || (!isSObjPackageRunningTest && factoryType.getName().startsWith('sobj.'))) {
            factoryType = DefaultSObjectFactory.class;
        }
        return factoryType;
    }
}