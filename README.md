<a href="https://kratapps.com/sobj/test-data-factory">
  <img title="Test Data Factory" alt="TDF" width="60px" height="60px" align="right"
       src="https://kratapps.com/images/logo_tdf_642_642.png"  />
</a>

# Test Data Factory
<!--
[![App Exchange](https://img.shields.io/badge/AppExchange-Test%20Data%20Factory-blue)](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N4V00000FNCbZUAX)
[![Security Review](https://img.shields.io/badge/Security%20Review-Passed-green)](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N4V00000FNCbZUAX)
-->
Create sObjects in unit tests seamlessly.  

* Test Data Factory out-of-the-box creates records with all required fields already populated.
* Extend `SObjectFactory` class or add Custom Metadata to provide base records for your unit tests. This way you can ensure records pass validation rules.
* Do you need in some unit tests more customized records? Define your records using the `SObjectFactoryScenario`.
* Custom Settings and sObjects from managed packages can also be created.


## Example 
```apex
// create account, required fields are populated automatically
// add fields specific for your unit test
Account acc = (Account) factory
    .inserted(new Account(
        Description = 'My Account',
        Parent = anotherAcc
    ))
    .toSObject();
// create 5 contacts with 3 different descriptions
List<Contact> created = (List<Contact>) factory
    .rotate(Contact.Description, new List<String>{'desc 0', 'desc 1', 'desc 2'})
    .inserted(5, new Contact())
    .toList();
```

## Installation
You can either install our Managed Package or deployed code unpackaged.
Do not modify the unpackaged code, 
we are not able to provide support if code deployed unpackaged.

### Managed Package
Install Managed Package using this URL:
```text
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t09000000v7va
```
or using sfdx cli:
```shell
sfdx force:package:install -p 04t09000000v7va -u myOrg
```

### Unpackaged
Use our sfdx plugin to install all components in the `src/main/default/` without cloning:
```shell
sfdx kratapps:remote:source:deploy -s https://github.com/kratapps/test-data-factory -p src/main/default/ -u myOrg
```

or clone the project and deploy using standard sfdx command:
```shell
git clone https://github.com/kratapps/test-data-factory.git
cd test-data-factory
sfdx force:source:deploy -p src/main/default -u myOrg
```

## Usage
You can create records using the TDF immediately in small projects 
or sObjects that are created only occasionally in unit tests.
For other cases, we recommend extending `SObjectFactory` and/or `SObjectFactoryScenario`
for each sObject type. `SObjectFactory/SObjectFactoryScenario` gives you more flexibility.

### Test Data Factory
Initialize TDF in your unit test class.
```apex
private static final sobj.TestDataFactory factory = new sobj.TestDataFactory();
```

### Operations
Choose one of these operations: create, mock and insert.  
Prefer crete or mock over insert to improve performance.  

|             | create | mock | insert |
|-------------|--------|------|--------|
| Performance | fast   | fast | slower |
| With Ids    | x      | yes  | yes    |
| Queryable   | x      | x    | yes    |

Required fields are populated automatically.
Default fields can be overridden using the target sObject provided.  
The TDF will insert this account.  
```apex
Account acc = (Account) factory.inserted(new Account(
        Description = 'Overridden Description'
)).toSObject();
```

This record will have the AccountId of the account created above.  
Just assign the account and the Id will be populated automatically from the account sObject.  
In case you created the `AccountFactory` class, the account won't be created in that class this case.  
Create operation will not insert the record.
```apex
Contact con = (Contact) factory.created(new Contact(
        Account = acc
)).toSObject();
``` 
   
The mock operation will not insert the record. This record has generated Id, but the record does not exist in the database.  
```apex
Contact con2 = (Contact) factory.mocked(new Contact()).toSObject();
```

Generate multiple records.  
```apex
List<Contact> contacts = (List<Contact>) factory.inserted(200, new Contact()).toList();
```

Get mocked/inserted record by Id using getRecord static method 
```apex
SObject sObj = TestDataFactory.getRecord(sObjectId);
```

### Default Values
There are multiple ways how to set field values:
* Fields in the `target` sObject. This is the sObject you pass to created/inserted/mocked methods.
* Fields in the `defaults` sObject. This is the sObject returned by `createDefaults` method.
* Fields in the `metadata defaults` sObject. This sObject is build from Test_Data_Factory_Default__mdt metadata.

If you define a value for a same field more than once, the order is as follows: 
`target` > `defaults` > `metadata defaults`.

### Metadata Defaults
Define default fields values using Test_Data_Factory_Default__mdt custom metadata.
This way, you can set fields values without creating or modifying any Apex code.
Set sObject API name, field API name, and value in each entry.
Optionally, you can enable each default value to a subset of:
* Custom Factory. Taken into account only if SObjectFactory for related SObject is implemented and a scenario is not used.  
* Default Factory. Taken into account only if SObjectFactory for related SObject is not implemented and a scenario is not used.
* Scenario. Taken into account only if a scenario is used.

### SObject Factories and Scenarios
SObject Factories and Scenarios provide the same interface.
Look at the table below to choose between SObject Factory and Scenario.

|             | Factory                                                            | Scenario                       |
|-------------|--------------------------------------------------------------------|--------------------------------|
| When to use | to create records with attributes for most unit tests              | to create special case records |
| Extends     | sobj.SObjectFactory                                                | sobj.SObjectFactoryScenario    |
| Class Name  | SObject Api Name without '_', '__c', '__mdt' followed by 'Factory' | anything                       |
| Count       | only one per SObject                                               | multiple per SObject           |
| How to use  | don't use useScenario                                              | use useScenario                |

#### SObject Factory
Make sure to
* name the class after the SObject (without __c and underscores) 
with `Factory` suffix
* make the class and its methods global
* annotate the class with `@IsTest`

##### Methods
* createDefaults  
This method creates a new record with default values.
Avoid any DML Operation here as it is called for every sObject created.

* makeParent (optional)   
This method is called only once for each relationship.  
The parent should be created in this method, 
because the method is not called for records that already have the parent.
This way you can reduce redundant DML statements.

* getDmlOptions (optional)  
Every factory comes with DML Options, 
default DML Options have `duplicateRuleHeader.allowSave` set to true.  
You can override this behavior.

* requireRecordType (optional)  
If sObject has record types, 
it is enforced to set the RecordTypeId in unit tests.  
You can disable this feature by overriding this method.

* autoPopulateRequiredFields (optional)  
This feature is enabled for every sObject without SObject Factory class.
Once you create the SObject Factory instance class, the feature is disabled by default.
Override this method and return true to enable it again.
We strongly recommend disabling this feature for sObjects with a lot of fields
to improve performance.

##### Example Implementation
```apex
@IsTest
global without sharing class ContactFactory extends sobj.SObjectFactory {
    private final sobj.ITestDataFactory factory = new sobj.TestDataFactory();

    public SObject createDefaults(SObject target) {
        return new Contact(
                FirstName = 'First',
                LastName = 'Last'
        );
    }
    public override SObject makeParent(SObjectField sObjField, SObject target) {
        if (sObjField == Contact.AccountId) {
            return factory.inserted(new Account()).toSObject();
        } else if (sObjField == ...) {
            return ...
        }      
        return null;
    }  
}
```

#### SObject Factory Scenario
Sometimes you need special factories for special use cases.  

For example, your open opportunity is quite different from the closed one.
The closed one requires multiple related objects which are not required for the open one.  
`OpportunityFactory` class will provide open opportunities.
Then create `ClosedOpportunityFactory` that will provide closed opportunities.
The `ClosedOpportunityFactory` will extend the `SObjectFactoryScenario` class.  
To use the `ClosedOpportunityFactory` call the `useScenario` method.  
```apex
// this will use the OpportunityFactory
Opportunity opp = (Opportunity) factory.inserted(new Opportunity()).toSObject();
// this will use the ClosedOpportunityFactory
Opportunity closedOpp = (Opportunity) factory
    .useScenario(ClosedOpportunityFactory.class)
    .inserted(new Opportunity())
    .toSObject();
```

### Rotations
If you want your records to have different values, you can use `rotate` method.
In the following example you we will create 5 contacts with 3 different descriptions:
```apex
List<Contact> created = (List<Contact>) factory
    .rotate(Contact.Description, new List<String>{'desc 0', 'desc 1', 'desc 2'})
    .rotate(Contact.AccountId, accountList)
    .created(5, new Contact())
    .toList();
```

If using rotation for a relationship field, use Id field and list of sObjects.
In our example `.rotate(Contact.AccountId, accountList)`.

## Best Practices
Common best practices while using this TDF.

### Insertable records
You should be able to insert every record without providing any values in the call. 
The following snippet should work in every unit test for all sObjects:
```apex
Contact con = (Contact) factory.inserted(new Contact()).toSObject();
```
For example User requires ProfileId which is not possible to insert automatically.
In case you want to create user objects in your unit tests you should create `UserFactory` class and assign ProfileId there.
The ProfileId can be then overridden in the created/mocked/inserted method call in a unit test.

### Disable populating required fields
When your sObject has hundreds of fields, you should disable auto populating to improve performance.
Set `autoPopulateRequiredFields` false in your SObject Factory class.

## Release Notes
[Link](https://kratapps.com/sobj/test-data-factory/release-notes)

## License
Licensed under [MIT](https://github.com/kratapps/test-data-factory/blob/main/LICENSE)
