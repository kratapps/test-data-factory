<a href="https://kratapps.com/sobj/test-data-factory">
  <img title="Test Data Factory" alt="TDF" width="60px" height="60px" align="right" border-radius="10px"
       src="https://kratapps.com/images/logo_tdf_642_642.png"  />
</a>

# Test Data Factory
<!--
[![App Exchange](https://img.shields.io/badge/AppExchange-Test%20Data%20Factory-blue)](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016b7FEAQ)
-->

Create sObjects in unit tests seamlessly.  

* Test Data Factory out-of-the-box creates records with all required fields already populated.
* Extend `SObjectFactory` class to provide base records for your unit tests. This way you can ensure records pass validation rules.
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
Install Managed Package using this [URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t090000011mS6):
```text
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t090000011mS6
```
Using SFDX CLI:
```shell
sfdx force:package:install -p 04t090000011mS6
```

### Unpackaged
Deploy all components in the `src/main/default/`.

Using SFDX CLI:
```shell
git clone https://github.com/kratapps/test-data-factory.git
cd test-data-factory
sfdx force:source:deploy -p src/main/default -u my-org
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

## License
Licensed under [MIT](https://github.com/kratapps/test-data-factory/blob/main/LICENSE)
