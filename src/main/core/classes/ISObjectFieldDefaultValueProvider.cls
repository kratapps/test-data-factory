/**
 * @author  Ondrej Kratochvil
 * @date    2021-04-06
 */
public interface ISObjectFieldDefaultValueProvider {
    Blob getDefaultBase64(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Boolean getDefaultBoolean(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Decimal getDefaultCurrency(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Date getDefaultDate(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Datetime getDefaultDatetime(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Double getDefaultDouble(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    String getDefaultEmail(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Integer getDefaultInteger(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Location getDefaultLocation(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Integer getDefaultLong(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Integer getDefaultPercent(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    String getDefaultPhone(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    String getDefaultPicklist(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    SObject getDefaultReference(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    String getDefaultString(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    String getDefaultTextArea(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    Time getDefaultTime(SObjectField sObjField, DescribeFieldResult fieldDescribe);
    String getDefaultUrl(SObjectField sObjField, DescribeFieldResult fieldDescribe);
}