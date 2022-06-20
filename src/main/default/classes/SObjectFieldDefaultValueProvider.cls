/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
public virtual class SObjectFieldDefaultValueProvider implements ISObjectFieldDefaultValueProvider {
    public virtual Blob getDefaultBase64(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Blob.valueOf(fieldDescribe.getLabel());
    }

    public virtual Boolean getDefaultBoolean(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return false;
    }

    public virtual Decimal getDefaultCurrency(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 0;
    }

    public virtual Date getDefaultDate(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Date.today();
    }

    public virtual Datetime getDefaultDatetime(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Datetime.now();
    }

    public virtual Double getDefaultDouble(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        Set<SObjectField> nonZeroFields = new Set<SObjectField>{
                OpportunityLineItem.Quantity,
                ContractLineItem.Quantity,
                OrderItem.Quantity
        };
        if (nonZeroFields.contains(sObjField)) {
            return 1; // quantity must be nonzero
        }
        return 0;
    }

    public virtual String getDefaultEmail(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 'first.last@company.com';
    }

    public virtual Integer getDefaultInteger(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 0;
    }

    public virtual Location getDefaultLocation(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Location.newInstance(0, 0);
    }

    public virtual Integer getDefaultLong(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 0;
    }

    public virtual Integer getDefaultPercent(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 0;
    }

    public virtual String getDefaultPhone(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return '(555) 555-1234';
    }

    public virtual String getDefaultPicklist(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        String value;
        for (PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            if (entry.isActive()) {
                value = entry.getValue();
                if (entry.isDefaultValue()) {
                    return value;
                }
            }
        }
        return value;
    }

    public virtual SObject getDefaultReference(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        if (!fieldDescribe.getReferenceTo().isEmpty()) {
            SObjectType referenceTo = fieldDescribe.getReferenceTo()[0];
            if (referenceTo.getDescribe().isCreateable()) {
                return new TestDataFactory().inserted(referenceTo.newSObject()).toSObject();
            }
        }
        return null;
    }

    public virtual String getDefaultString(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        if (sObjField == User.Username) {
            return 'first.last-' + Math.abs(Crypto.getRandomInteger()) + '@tdf.com';
        }
        return fieldDescribe.getLabel();
    }

    public virtual String getDefaultTextArea(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return fieldDescribe.getLabel();
    }

    public virtual Time getDefaultTime(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Time.newInstance(12, 0, 0, 0);
    }

    public virtual String getDefaultUrl(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 'website@company.com';
    }
}