/**
 * This class contains meta data about field of a table which will be
 * used for creating SQL statement.
 *
 * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
 *
 * Created 30 Sep, 2019
 *
 * @author - mehtesham@vlocity.com
 */
public inherited sharing class FieldInfo{

    public enum ComparisonOperators { OP_EQUALS,
                                      OP_NOT_EQUALS,
                                      OP_LESS_THAN,
                                      OP_LESS_THAN_EQUALS,
                                      OP_GREATER_THAN,
                                      OP_GREATER_THAN_EQUALS,
                                      OP_LIKE,
                                      OP_IN,
                                      OP_NOT_IN,
                                      OP_INCLUDES,
                                      OP_EXCLUDES
                                    }

    public enum LogicalOperators { OP_AND,
                                    OP_OR,
                                    OP_NOT
                                    }

    private static Map<String, ComparisonOperators> cOperatorMap = new Map<String, ComparisonOperators>();
    private static Map<String, LogicalOperators> lOperatorMap = new Map<String, LogicalOperators>();

    static{
        cOperatorMap.put('equals', ComparisonOperators.OP_EQUALS);
        cOperatorMap.put('not_equals', ComparisonOperators.OP_NOT_EQUALS);
        cOperatorMap.put('greater_than', ComparisonOperators.OP_GREATER_THAN);
        cOperatorMap.put('greater_than_equals', ComparisonOperators.OP_GREATER_THAN_EQUALS);
        cOperatorMap.put('less_than', ComparisonOperators.OP_LESS_THAN);
        cOperatorMap.put('less_than_equals', ComparisonOperators.OP_LESS_THAN_EQUALS);
        cOperatorMap.put('like', ComparisonOperators.OP_LIKE);
        cOperatorMap.put('in', ComparisonOperators.OP_IN);
        cOperatorMap.put('not_in', ComparisonOperators.OP_NOT_IN);
        cOperatorMap.put('include', ComparisonOperators.OP_INCLUDES);
        cOperatorMap.put('exclude', ComparisonOperators.OP_EXCLUDES);

        lOperatorMap.put('and', LogicalOperators.OP_AND);
        lOperatorMap.put('or', LogicalOperators.OP_OR);
        lOperatorMap.put('not', LogicalOperators.OP_NOT);
    }

    //Field of a table which is going to part in SQL conditional statment.
    List<Schema.SObjectField> relativeFields = null;

    //Comparison Operator which will be applied between field and its value
    ComparisonOperators comparisonOperator = ComparisonOperators.OP_EQUALS;

    // Logical operator - applies between two field
    LogicalOperators logicalOperator = LogicalOperators.OP_AND;

    //Value
    private List<Object> fieldValueList = null;
    private Object fieldValue = null;

    private static final String singleQuote = '\'';
    private static final String openBracket = ' ( ';
    private static final String closeBracket = ' ) ';

    private static Map<SObjectType, Map<String, Schema.SObjectField>> sObjToFieldMap = new Map<SObjectType, Map<String, Schema.SObjectField>>();

    /**
     * Prefix and postfix operator is only applicable for String data type and
     * LIKE operator.
     *
     * The '%' wildcard matches zero or more characters.
     * The '_' wildcard matches exactly one character.
     */
    String prefixWildCard = '%';

    String postfixWildCard = '%';

    //To combine additional field condition
    private FieldInfo linkedFieldInfo = null;

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators operator){
        this.relativeFields = new List<Schema.SObjectField>();
        this.relativeFields.add(field);
        this.comparisonOperator = operator;
    }

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators operator, Object value){
        this.relativeFields = new List<Schema.SObjectField>();
        this.fieldValueList = new List<Object>();
        this.relativeFields.add(field);
        this.comparisonOperator = operator;
        this.fieldValueList.add(value);
        this.fieldValue = value;
    }

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators operator, List<Object> fieldValues){
        this.relativeFields = new List<Schema.SObjectField>();
        this.fieldValueList = fieldValues;
        this.relativeFields.add(field);
        this.comparisonOperator = operator;
        this.fieldValue = fieldValues[0];
    }

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators cOperator, LogicalOperators lOperator){
        this.relativeFields = new List<Schema.SObjectField>();
        this.relativeFields.add(field);
        this.comparisonOperator = cOperator;
        this.logicalOperator = lOperator;
    }

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators cOperator, LogicalOperators lOperator, Object value){
        this.relativeFields = new List<Schema.SObjectField>();
        this.relativeFields.add(field);
        this.comparisonOperator = cOperator;
        this.logicalOperator = lOperator;
        this.fieldValue = value;
        this.fieldValueList = new List<Object>();
        if(value != null){
            this.fieldValueList.add(value);
        }
    }

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators cOperator, LogicalOperators lOperator, List<Object> values){
        this.relativeFields = new List<Schema.SObjectField>();
        this.relativeFields.add(field);
        this.comparisonOperator = cOperator;
        this.logicalOperator = lOperator;
        this.fieldValue = values;
        this.fieldValueList = values;
        if(fieldValueList != null && fieldValueList.size() > 0){
            this.fieldValue = fieldValueList[0];
        }
    }

    //Constructor
    public FieldInfo(List<Schema.SObjectField> relativeFields, ComparisonOperators operator){
        this.relativeFields = relativeFields;
        this.comparisonOperator = operator;
    }

    //Constructor
    public FieldInfo(List<Schema.SObjectField> relativeFields, ComparisonOperators cOperator, LogicalOperators lOperator){
        this.relativeFields = relativeFields;
        this.comparisonOperator = cOperator;
        this.logicalOperator = lOperator;
    }

    //Constructor
    public FieldInfo(List<Schema.SObjectField> relativeFields, ComparisonOperators cOperator, LogicalOperators lOperator, Object value){
        this.relativeFields = relativeFields;
        this.comparisonOperator = cOperator;
        this.logicalOperator = lOperator;
        this.fieldValue = value;
        this.fieldValueList = new List<Object>();
        if(value != null){
            this.fieldValueList.add(value);
        }
    }

    //Constructor
    public FieldInfo(List<Schema.SObjectField> relativeFields, ComparisonOperators cOperator, LogicalOperators lOperator, List<Object> values){
        this.relativeFields = relativeFields;
        this.comparisonOperator = cOperator;
        this.logicalOperator = lOperator;
        this.fieldValueList = values;
        if(fieldValueList != null && fieldValueList.size() > 0){
            this.fieldValue = fieldValueList[0];
        }
    }

    //Constructor
    public FieldInfo(SobjectField field, ComparisonOperators operator,
                    String prefixWildCard, String postfixWildCard){
        this.relativeFields = new List<Schema.SObjectField>();
        this.relativeFields.add(field);
        this.comparisonOperator = operator;
        this.prefixWildCard = prefixWildCard;
        this.postfixWildCard = postfixWildCard;
    }

    public void addFieldInfo(FieldInfo fieldInfo){
        FieldInfo tempFieldInfo = this;
        while(tempFieldInfo.linkedFieldInfo != null){
            tempFieldInfo = tempFieldInfo.linkedFieldInfo;
        }
        tempFieldInfo.linkedFieldInfo = fieldInfo;
    }

    public FieldInfo getLinkedFieldInfo(){
        return this.linkedFieldInfo;
    }

    /**
     * Getter for field
     */
    public List<Schema.SObjectField> getField(){
        return this.relativeFields;
    }

    public String getRelativeFieldPath(){
        String relativePath = '';
        for(Integer index = 0; index < relativeFields.size(); index++){
            if(index == (relativeFields.size() - 1)){
                relativePath = relativePath + relativeFields[index].getDescribe().getName();
            }else{
                relativePath = relativePath + relativeFields[index].getDescribe().getRelationshipName() + '.';
            }
        }
        return relativePath;
    }

    /**
     * Setter for comparison operator
     */
    public void setComparisonOperator(ComparisonOperators operator){
        this.comparisonOperator = operator;
    }

    /**
     * Getter for comparison operator
     */
    public ComparisonOperators getComparisonOperator(){
        return this.comparisonOperator;
    }

    /**
     * Setter for logicalOperator operator
     */
    public void setLogicalOperator(LogicalOperators operator){
        this.logicalOperator = operator;
    }

    /**
     * Getter for logicalOperator operator
     */
    public LogicalOperators getLogicalOperator(){
        return this.logicalOperator;
    }

    /**
     * Setter for Prefix
     */
    public void setPrefixWildCard(String prefixWildCard){
        this.prefixWildCard = prefixWildCard;
    }

    /**
     * Getter for Prefix
     */
    public String getPrefixWildCard(){
        return this.prefixWildCard;
    }

    /**
     * Setter for Postfix
     */
    public void setPostfixWildCard(String postfixWildCard){
        this.postfixWildCard = postfixWildCard;
    }

    /**
     * Getter for Postfix
     */
    public String getPostfixWildCard(){
        return this.postfixWildCard;
    }

    public static LogicalOperators getLogicalOperator(String logOpe){
        return lOperatorMap.get(logOpe);
    }

    public static ComparisonOperators getComparisonOperator(String compOpe){
        return cOperatorMap.get(compOpe);
    }

	public Boolean equals(Object obj) {
        return this.hashCode() == obj.hashCode();
    }

    /**
     * Getter for Prefix
     */
    public String getFieldValue(){
        if(fieldValue == null && (fieldValueList == null || (fieldValueList != null && fieldValueList.size() == 0))){
            return null;
        }else {
            if(fieldValueList.size() > 1){
                String retValue = openBracket;
                for(Object fldValue : fieldValueList){
                    if(retValue == openBracket){
                        retValue += formattedValue(fldValue);
                    }else{
                        retValue += ',' + formattedValue(fldValue);
                    }
                }
                return retValue + closeBracket;
            }else{
                if(comparisonOperator == ComparisonOperators.OP_IN || comparisonOperator == ComparisonOperators.OP_NOT_IN){
                    return openBracket + formattedValue(fieldValue) + closeBracket;
                }else{
                    return formattedValue(fieldValue);
                }
            }
        }
    }

    public String getFieldValue(Sobject sObj){
        if(sObj == null){
            return null;
        }
        SobjectField field = null;
        String fieldValue = null;
        List<Schema.SObjectField> relativeFields = getField();
        for(Integer index = 0; index < relativeFields.size(); index++){
            if(index == (relativeFields.size() - 1)){
                field = relativeFields[index];
            } else {
                field = relativeFields[index];
                sObj = (SObject) sObj.getSObject(field.getDescribe().getRelationshipName());
            }
        }
        return formattedValue(sObj.get(field.getDescribe().getName()));
    }

    private String formattedValue(Object strValue){

        SobjectField field = relativeFields[relativeFields.size() - 1];
        String fieldValue = null;
        if(strValue != null){
            String stringValue = String.valueOf(strValue).toUpperCase();
            if(stringValue.contains('SELECT') && stringValue.contains('FROM')){
                return String.valueOf(strValue);
            }
        }
        Schema.DescribeFieldResult fieldResult = field.getDescribe();

        if(Schema.DisplayType.STRING == fieldResult.getType() ||
            Schema.DisplayType.TEXTAREA == fieldResult.getType() ||
            Schema.DisplayType.PICKLIST == fieldResult.getType()){
            if(getComparisonOperator() == FieldInfo.ComparisonOperators.OP_EQUALS ||
                    getComparisonOperator() == FieldInfo.ComparisonOperators.OP_NOT_EQUALS ||
                    getComparisonOperator() == FieldInfo.ComparisonOperators.OP_IN||
                    getComparisonOperator() == FieldInfo.ComparisonOperators.OP_NOT_IN){
                if(strValue ==  null){
                    fieldValue = ' null ';
                }else {
                    fieldValue = singleQuote  + strValue  + singleQuote;
                }
            }else{
                fieldValue = singleQuote + getPrefixWildCard() + strValue + getPostfixWildCard() + singleQuote;
            }

        } else if(Schema.DisplayType.Integer == fieldResult.getType() ||
                Schema.DisplayType.DOUBLE == fieldResult.getType() ||
                Schema.DisplayType.LONG == fieldResult.getType() ||
                Schema.DisplayType.BOOLEAN == fieldResult.getType()) {

            fieldValue = String.valueOf(strValue);

        }else if(Schema.DisplayType.REFERENCE == fieldResult.getType() ||
                    Schema.DisplayType.ID == fieldResult.getType()){
                if(strValue ==  null){
                    fieldValue = ' null ';
                }else {
                    fieldValue = singleQuote  + strValue  + singleQuote;
                }

        } else if(Schema.DisplayType.TIME == fieldResult.getType() ||
                 Schema.DisplayType.DATE == fieldResult.getType() ||
                 Schema.DisplayType.DATETIME == fieldResult.getType()){

                fieldValue = String.valueOf(strValue);
        } else {
            /*
                //TODO : if any of these need special care.
                        Schema.DisplayType.MULTIPICKLIST
                        Schema.DisplayType.PICKLIST
                        Schema.DisplayType.ENCRYPTEDSTRING
                        Schema.DisplayType.EMAIL
                        Schema.DisplayType.LOCATION
                        Schema.DisplayType.DATACATEGORYGROUPREFERENCE
                        Schema.DisplayType.CURRENCY
                        Schema.DisplayType.COMPLEXVALUE
                        Schema.DisplayType.COMBOBOX
                        Schema.DisplayType.BASE64
                        Schema.DisplayType.ANYTYPE
                        Schema.DisplayType.ADDRESS
                        Schema.DisplayType.URL
                        Schema.DisplayType.SOBJECT
                        Schema.DisplayType.PHONE
                        Schema.DisplayType.PERCENT
            */
            fieldValue = String.valueOf(strValue);
        }
        return fieldValue;
    }

    /**
     * Setter for Postfix
     */
    public void setFieldValues(List<Object> fieldValues){
        this.fieldValueList = fieldValues;
        this.fieldValue = fieldValues[0];
    }

    public Object getValue(){
        return this.fieldValue;
    }

    public static Map<String, Schema.SObjectField> getFieldMap(SObjectType sObjType){
        Map<String, Schema.SObjectField> soMap = sObjToFieldMap.get(sObjType);
        if(soMap == null){
            soMap = sObjType.getDescribe().fields.getMap();
            sObjToFieldMap.put(sObjType, soMap);
        }
        return soMap;
    }

    public Integer hashCode() {
        Integer code = 0;
        if(relativeFields != null){
            for(Schema.SObjectField field : relativeFields){
                code += (field != null ? field.getDescribe().getName().hashCode() : 0);
            }
        }
        code += comparisonOperator.name().hashCode();
        code += logicalOperator.name().hashCode();
        code += prefixWildCard.hashCode();
        code += postfixWildCard.hashCode();
        code += (linkedFieldInfo != null ? linkedFieldInfo.hashCode() : 0);
        code += (fieldValueList != null ? fieldValueList.hashCode() : 0);
        return code;
    }

    public override String toString(){
        String toStr = null;
        if(relativeFields != null){
            for(Schema.SObjectField field : relativeFields){
                toStr += (field != null ? field.getDescribe().getName() : 'null');
            }
        }
        return toStr + ' comparisonOperator ' + comparisonOperator + ' logicalOperator ' + logicalOperator +
                ' prefixWildCard ' + prefixWildCard + ' postfixWildCard ' + postfixWildCard +
                ' linkedFieldInfo ' + linkedFieldInfo ;
    }
}