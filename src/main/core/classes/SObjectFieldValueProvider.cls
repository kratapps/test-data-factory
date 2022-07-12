/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
@IsTest
public without sharing class SObjectFieldValueProvider {
    private final ISObjectFieldDefaultValueProvider provider;

    public SObjectFieldValueProvider() {
        provider = new SObjectFieldDefaultValueProvider();
    }
    
    public SObjectFieldValueProvider(ISObjectFieldDefaultValueProvider defaultValueProvider) {
        provider = defaultValueProvider;
    }
    
    public class DefaultValue {
        public final SObjectField sObjField;
        public final Object value;
        public DisplayType dType {
            public get {
                return sObjField.getDescribe().getType();
            }
        }
        DefaultValue(SObjectField sObjField, Object value) {
            this.sObjField = sObjField;
            this.value = value;
        }
    }

    public DefaultValue getDefaultValue(SObjectField sObjField) {
        DescribeFieldResult fieldDescribe = sObjField.getDescribe();
        DisplayType dType = fieldDescribe.getType();
        Object value = null;
        if (fieldDescribe.getDefaultValue() != null) {
            value = fieldDescribe.getDefaultValue();
        }
        switch on dType {
            when BASE64 {
                value = provider.getDefaultBase64(sObjField, fieldDescribe);
            }
            when BOOLEAN {
                value = provider.getDefaultBoolean(sObjField, fieldDescribe);
            }
            when CURRENCY {
                value = provider.getDefaultCurrency(sObjField, fieldDescribe);
            }
            when DATE {
                value = provider.getDefaultDate(sObjField, fieldDescribe);
            }
            when DATETIME {
                value = provider.getDefaultDatetime(sObjField, fieldDescribe);
            }
            when DOUBLE {
                value = provider.getDefaultDouble(sObjField, fieldDescribe);
            }
            when EMAIL {
                value = provider.getDefaultEmail(sObjField, fieldDescribe);
            }
            when INTEGER {
                value = provider.getDefaultInteger(sObjField, fieldDescribe);
            }
            when LOCATION {
                value = provider.getDefaultLocation(sObjField, fieldDescribe);
            }
            when LONG {
                value = provider.getDefaultLong(sObjField, fieldDescribe);
            }
            when PERCENT {
                value = provider.getDefaultPercent(sObjField, fieldDescribe);
            }
            when PHONE {
                value = provider.getDefaultPhone(sObjField, fieldDescribe);
            }
            when PICKLIST, MULTIPICKLIST {
                value = provider.getDefaultPicklist(sObjField, fieldDescribe);
            }
            when REFERENCE {
                value = provider.getDefaultReference(sObjField, fieldDescribe);
            }
            when STRING {
                value = provider.getDefaultString(sObjField, fieldDescribe);
            }
            when TEXTAREA {
                value = provider.getDefaultTextArea(sObjField, fieldDescribe);
            }
            when URL {
                value = provider.getDefaultUrl(sObjField, fieldDescribe);
            }
        }
        return new DefaultValue(sObjField, value);
    }
}