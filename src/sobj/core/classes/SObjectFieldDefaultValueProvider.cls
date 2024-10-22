public virtual class SObjectFieldDefaultValueProvider {
    public virtual Blob getDefaultBase64(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Blob.valueOf(fieldDescribe.getName());
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
        if (fieldDescribe?.getName() == 'Quantity') {
            return 1; // nonzero standard quantity fields
        }
        return 0;
    }

    public virtual String getDefaultEmail(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 'jon.doe@acme.com';
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
                return new BaseSObjectFactory().inserted().setRequiredFields().build(referenceTo.newSObject()).toSObject();
            }
        }
        return null;
    }

    public virtual String getDefaultString(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        if (sObjField == User.Username) {
            return 'jon.doe-' + Math.abs(Crypto.getRandomInteger()) + '@acme.com';
        }
        return fieldDescribe.getName();
    }

    public virtual String getDefaultTextArea(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return fieldDescribe.getName();
    }

    public virtual Time getDefaultTime(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return Time.newInstance(12, 0, 0, 0);
    }

    public virtual String getDefaultUrl(SObjectField sObjField, DescribeFieldResult fieldDescribe) {
        return 'https://www.acme.com';
    }
}