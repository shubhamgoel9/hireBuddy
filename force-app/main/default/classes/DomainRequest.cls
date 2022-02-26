/**
 * This class is container for request information
 *
 * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
 *
 * Created 30 Sep, 2019
 *
 * @author - mehtesham@vlocity.com
 */
public virtual inherited sharing class DomainRequest {
/**
 *
 *        {
 *        "methodName": "addPrice",
 *          "epcRequest": {
 *            "entityInfo": {
 *              "entity": {
 *                "Id": "a2x3i000000ke9IAAQ",
 *                "Name": "Test PL",
 *                "vlocity_cmt__Code__c": "Test PL",
 *                "vlocity_cmt__CurrencyCode__c": null,
 *                "vlocity_cmt__Description__c": "Test PL Description__c",
 *                "vlocity_cmt__EffectiveFromDate__c": null,
 *                "vlocity_cmt__EffectiveUntilDate__c": null,
 *                "vlocity_cmt__IsActive__c": true,
 *                "vlocity_cmt__LoyaltyCode__c": null,
 *                "vlocity_cmt__ParentPriceListId__c": null,
 *                "vlocity_cmt__Pricebook2Id__c": "01s3i000002JmV0AAK",
 *                "vlocity_cmt__Sequence__c": 10
 *              },
 *              "incldue": ["userDetail", "evaluatedDate", "productCount"],
 *              "fieldSet": ["Id,"Name]
 *            },
 *            "query": [
 *                "fieldInfo": {
 *                  "fieldType": "Name",
 *                  "comparisonOperator": "like"
 *                },
 *                "fieldInfo": {
 *                  "fieldType": "vlocity_cmt__Code__c",
 *                  "comparisonOperator": "equals",
 *                  "logicalOperator": "and"
 *                }
 *            ],
 *            "pageInfo": {
 *              "pageNumber": 1,
 *              "pageSize": 50,
 *              "recordLimit": 50,
 *              "orderBy": "vlocity_cmt__Sequence__c"
 *            }
 *          }
 *        }
 */

    //Request Constants
    public static final String EPC_REQUEST_ELEMENT                  = 'epcRequest';
    public static final String ENTITIES_ELEMENT                     = 'entities';
    public static final String ENTITY_ELEMENT                       = 'entity';
    public static final String INCLUDE_ELEMENT                      = 'include';
    public static final String USER_DETAIL_ELEMENT                  = 'userDetail';
    public static final String TIME_PLAN_ELEMENT                    = 'timePlan';
    public static final String TIME_POLICY_ELEMENT                  = 'timePolicy';
    public static final String PICKLIST_VALUE_ELEMENT               = 'picklistValue';
    public static final String ALL_VERSION_ELEMENT                  = 'allVersion';
    public static final String PRODUCT_PROPERTY_ELEMENT             = 'productProperty';
    public static final String RELATED_PRODUCT_ELEMENT              = 'relatedProduct';
    public static final String EVALUATED_DATE_ELEMENT               = 'evaluatedDate';
    public static final String PRODUCT_HIERARCHY_ELEMENT            = 'productHierarchy';
    public static final String PRODUCT_COUNT_ELEMENT                = 'productCount';
    public static final String OBJECT_TYPE_ELEMENT                  = 'objectType';
    public static final String QUERY_ELEMENT                        = 'query';
    public static final String QUERY_SET_ELEMENT                    = 'querySet';
    public static final String FIELD_SET_ELEMENT                    = 'fieldSet';
    public static final String FIELD_INFO_ELEMENT                   = 'fieldInfo';
    public static final String FIELD_TYPE_ELEMENT                   = 'fieldType';
    public static final String FIELD_VALUE_ELEMENT                  = 'fieldValue';
    public static final String FIELD_VALUES_ELEMENT                 = 'fieldValues';
    public static final String COMPARISON_OPERATOR_ELEMENT          = 'comparisonOperator';
    public static final String LOGICAL_OPERATOR_ELEMENT             = 'logicalOperator';
    public static final String PAGE_INFO_ELEMENT                    = 'pageInfo';
    public static final String PAGE_NUMBER_ELEMENT                  = 'pageNumber';
    public static final String PAGE_SIZE_ELEMENT                    = 'pageSize';
    public static final String RECORD_LIMIT_ELEMENT                 = 'recordLimit';
    public static final String ORDER_BY_ELEMENT                     = 'orderBy';
    public static final String GROUP_BY_ELEMENT                     = 'groupBy';

    private String objectType = null;
    private String recordType = null;
    private String condition = null;
    private String searchString = null;
    private String fieldSetName = null;
    private String whereClause = null;
    private Boolean allRows = false;

    private Boolean incldueUserDetail = false;
    private Boolean incldueTimePlan = false;
    private Boolean incldueTimePolicy = false;
    private Boolean includePicklistValue = false;
    private Boolean includeAllVersion = false;
    private String lastModifiedFormat = null;
    private Boolean includeProductCount = false;
    private Boolean includeProductHierarchy = false;
    private Boolean includeRelatedProduct = false;
    private Boolean includeProductProperty = false;

    private PageInfo pgInfo = new PageInfo();
    private Sobject entity = null;
    private List<SObject> entityList = null;

    private Queries queries = null;
    private FieldInfo fldInfo = null;

    public class Queries {
        List<FieldInfo> listFldInfo = new List<FieldInfo>();
        FieldInfo.LogicalOperators logicalOpr = null;
        public List<FieldInfo> getFieldInfos(){
            return listFldInfo;
        }
        public FieldInfo.LogicalOperators getOperator(){
            return logicalOpr;
        }
    }

    private class PageInfo {
        private Integer pageNumber = null;
        private Integer pageSize = null;
        private Integer offsetNumber = null;
        private String orderBy = 'Id';
        private String groupBy = null;

        public Boolean equals(Object obj) {
            return this.hashCode() == obj.hashCode();
        }

        public Integer hashCode() {
            return (pageNumber != null ? pageNumber : 0)
                    + (pageSize != null ? pageSize : 0)
                    + (offsetNumber != null ? offsetNumber : 0)
                    + (orderBy != null ? orderBy.hashCode() : 0)
                    + (groupBy != null ? groupBy.hashCode() : 0);
        }
    }

    private Map<String, Object> inputs = null;

    public DomainRequest() {
        entityList = new List<SObject>();
    }

    public DomainRequest(Map<String,Object> inputs) {
        entityList = new List<SObject>();
        this.inputs = inputs;
    }

    public Set<String> getKeys()
    {
        if (this.inputs == null)
            return null;
        return this.inputs.keySet();
    }

    public Object get(String paramKey) {
        return this.inputs.get(paramKey);
    }

    public Map<String, Object> getMap(){
        return this.inputs;
    }

    /**
     * Getter for objectType
     * @param - String
     */
    public void setObjectType(String objectType){
        this.objectType = objectType;
    }

    /**
     * Getter for objectTuype
     * @return - String
     */
    public String getObjectType(){
        return this.objectType;
    }

    /**
     * Getter for recordtype
     * @param - String
     */
    public void setRecordType(String recordType){
        this.recordType = recordType;
    }

    /**
     * Getter for record type
     * @return - String
     */
    public String getRecordType(){
        return this.recordType;
    }

    /**
     * setter for condigtion
     * @param - String
     */
    public void setCondition(String condition){
        this.condition = condition;
    }

    /**
     * Getter for Condition
     * @return - String
     */
    public String getCondition(){
        return this.condition;
    }

    /**
     * Setter for searchString
     * @param - String
     */
    public void setSearchString(String searchString){
        this.searchString = searchString;
    }

    /**
     * Getter for searchString
     * @return - String
     */
    public String getSearchString(){
        return this.searchString;
    }

    /**
     * Setter for pageNumber, if case of null it will defaulted to 1
     * @param - Integer as pagenumber
     */
    public void setPageNumber(Integer pageNumber){
        pgInfo.pageNumber = pageNumber;
        // default pageNumber = 1
        if (pgInfo.pageNumber == null) {
            pgInfo.pageNumber = 1;
        }
    }

    /**
     * Getter for pageNumber
     * @return -Integer
     */
    public Integer getPageNumber(){
        return pgInfo.pageNumber;
    }

    /**
     * Setter for pageNumber, if passed pageSize is null the it takes defualt value
     * from configured one.
     *
     * @param - List<Entity>
     */
    public void setPageSize(Integer pageSize){

        pgInfo.pageSize = pageSize;

        if (pgInfo.pageSize == null) {
            String searchResultsPerPage = null;//CustomSettingsUtilities.getProductManagementSettings('SearchResultsPerPage');
            if (searchResultsPerPage == null) {
                pgInfo.pageSize = 50; // default pageSize = 50
            } else {
                pgInfo.pageSize = Integer.valueOf(searchResultsPerPage);
                if(pgInfo.pageSize <= 0 ){
                    pgInfo.pageSize = 50; // default pageSize = 50
                }
            }
        }
        //Set offset
        if (pgInfo.pageNumber == null) {
            pgInfo.pageNumber = 1;
        }
        pgInfo.offsetNumber = (pgInfo.pageNumber-1) * pgInfo.pageSize;
    }

    /**
     * Set pagination field to null i.e pageSize, pageNumber and offset
     */
    public void resetPagination(){
        pgInfo.pageSize = null;
        pgInfo.pageNumber = null;
        pgInfo.offsetNumber = null;
    }

    /**
     * Getter for pageSize
     * @return - Integer
     */
    public Integer getPageSize(){
        return pgInfo.pageSize;
    }

    /**
    * Setter for fieldsetname
    * @param - String fieldSetName
    */
    public void setFieldSetName(String fieldSetName){
        this.fieldSetName = fieldSetName;
    }

    /**
     * Getter for fieldSetName
     * @return - String
     */
    public String getFieldSetName(){
        return this.fieldSetName;
    }

    /**
     * Set entity and clean the entity list.
     *
     * @param SObject- entity to set to DomainRequest
     */
    public void setEntity(Sobject entity){
        this.entityList.clear();
        this.entityList.add(entity);
        this.entity = entity;
    }

    /**
     * Set entity and clean the entity list.
     *
     * @param SObject- entity to set to DomainRequest
     */
    public void setEntity(List<Sobject> entities){
        if(entities != null && !entities.isEmpty()){
            this.clearEntity();
            this.addEntity(entities);
        }
    }
    /**
     * Clears the  entity list
     */
    public void clearEntity(){
        this.entityList.clear();
        this.entity = null;
    }

    /**
     * Add entity in entity list, if it first entry then it set to initialized
     *  with entity object of domainrequest
     *
     * @param SObject- entity to be added to entity list
     */
    public void addEntity(Sobject entity){
        this.entityList.add(entity);
        if(this.entity == null){
            this.entity = entity;
        }
    }

    /**
     * Add/Copy entity list in entity list, if it first entry then it set to initialized
     *  with first entity (index 0) object of domainrequest
     *
     * @param List<SObject>- list entity to be added to entity list
     */
    public void addEntity(List<Sobject> entities){
        if(entities != null && !entities.isEmpty()){
            this.entityList.addAll(entities);
            if(this.entity == null && entityList != null && entityList.size() > 0){
                this.entity = entityList[0];
            }
        }
    }

    /**
     * Clean entity list.
     */
    public void removeEntity(){
        this.entityList.clear();
        this.entity = null;
    }

    /**
     * Getter for entity
     * @return - Sobject - entity of domainrequest
     */
    public Sobject getEntity(){
        return this.entity;
    }

    /**
     * Getter for entity list
     * @return - List<Entity>
     */
    public List<Sobject> getEntityList(){
        return this.entityList;
    }

    /**
     * Getter for offset
     * @return - offsetNumber
     */
    public Integer getOffsetNumber(){
        return pgInfo.offsetNumber;
    }

    /**
     * Setter for order by
     * @param - orderBy as string
     */
    public void setOrderBy(String orderBy){
        pgInfo.orderBy = orderBy;
    }

    /**
     * Getter for order by
     * @return - orderBy as string
     */
    public String getOrderBy(){
        return pgInfo.orderBy;
    }

    /**
     * Setter for group by
     * @param - groupBy as string
     */
    public void setGroupBy(String groupBy){
        pgInfo.groupBy = groupBy;
    }

    /**
     * Getter for group by
     * @return - groupBy as string
     */
    public String getGroupBy(){
        return pgInfo.groupBy;
    }

    /**
     * Setter for customised whereClause
     * @param - whereClause
     */
    public void setWhereClause(String whereClause){
        this.whereClause = whereClause;
    }

    /**
     * Getter for whereClause
     * @return - whereClause
     */
    public String getWhereClause(){
        return this.whereClause;
    }

    /**
     * Setter for incldueUserDetail
     * @param - needUserDetail as boolean
     */
    public void setNeedUserInfo(Boolean needUserDetail){
        this.incldueUserDetail = needUserDetail;
    }

    /**
     * Getter for incldueUserDetail
     * @return - incldueUserDetail
     */
    public Boolean isNeedUserInfo(){
        return this.incldueUserDetail;
    }

    /**
     * Setter for incldueTimePlan
     * @param - Boolean
     */
    public void setIncludeTimePlan(Boolean incTimePlan){
        this.incldueTimePlan = incTimePlan;
    }

    /**
     * Getter for incldueTimePlan
     * @return - incldueTimePlan
     */
    public Boolean isIncludeTimePlan(){
        return this.incldueTimePlan;
    }

    /**
     * Setter for incldueTimePolicy
     * @param -  boolean
     */
    public void setIncludeTimePolicy(Boolean incTimePolicy){
        this.incldueTimePolicy = incTimePolicy;
    }

    /**
     * Getter for inclduePicklistValue
     * @return - inclduePicklistValue
     */
    public Boolean isIncludePicklistValue(){
        return this.includePicklistValue;
    }

    /**
     * Setter for includePicklistValue
     * @param -  boolean
     */
    public void setIncludePicklistValue(Boolean incPicklistValue){
        this.includePicklistValue = incPicklistValue;
    }


    /**
     * Getter for includeAllVersion
     * @return - includeAllVersion
     */
    public Boolean isIncludeAllVersion(){
        return this.includeAllVersion;
    }

    /**
     * Setter for includeAllVersion
     * @param -  boolean
     */
    public void setIncludeAllVersion(Boolean incAllVersion){
        this.includeAllVersion = incAllVersion;
    }

    /**
     * Getter for incldueTimePolicy
     * @return - incldueTimePolicy
     */
    public Boolean isIncludeTimePolicy(){
        return this.incldueTimePolicy;
    }

    /**
     * Setter for fieldInfo
     * @param - fieldInfo
     */
    public void setFieldInfo(FieldInfo fieldInfo){
        this.fldInfo = fieldInfo;
    }

    /**
     * Setter for fldInfo
     * @param - FieldInfo
     */
    public FieldInfo getFieldInfo(){
        return this.fldInfo;
    }

    /**
     * Setter for Queries
     * @param -
     */
    public void setQueries(FieldInfo fieldInfo, FieldInfo.LogicalOperators operator){
        if(this.queries == null){
            this.queries = new Queries();
        }
        this.queries.listFldInfo.add(fieldInfo);
        this.queries.logicalOpr = operator;
    }

    /**
     * Setter for fldInfo
     * @param - FieldInfo
     */
    public Queries getQueries(){
        return this.queries;
    }

    /**
     * Check for read operation type is byId or ByField
     * @param - boolean
     */
    public Boolean isFindById(){
        if (this.entity == null)
            return false;
        else
            return  (getEntity().get('Id') != null && this.fldInfo == null) ? true : false;
    }

    /**
     * Setter for lastModifiedFormat
     * @param - lastModFormat as string
     */
    public void setLastModifiedFormat(String lastModFormat){
        this.lastModifiedFormat = lastModFormat;
    }

    /**
     * Getter for lastModifiedFormat
     * @return - status of lastModifiedFormat
     */
    public Boolean isLastModifiedEvaluatedFormat(){
        return this.lastModifiedFormat == EVALUATED_DATE_ELEMENT;
    }

    /**
     * Setter for gincludeProductCount
     * @param - incProdCount as boolean
     */
    public void setIncludeProductCount(Boolean incProdCount){
        this.includeProductCount = incProdCount;
    }

    /**
     * Getter for includeProductCount
     * @return - status of includeProductCount
     */
    public Boolean isIncludeProductCount(){
        return this.includeProductCount;
    }

    /**
     * Setter for includeProductHierarchy
     * @param - incProdHierarchy as boolean
     */
    public void setIncludeProductHierarchy(Boolean incProdHierarchy){
        this.includeProductHierarchy = incProdHierarchy;
    }

    /**
     * Getter for includeProductHierarchy
     * @return - status of includeProductHierarchy
     */
    public Boolean IsIncludeProductHierarchy(){
        return this.includeProductHierarchy;
    }

    /**
     * Setter for includeFacetObject
     * @param - includeFacetObject as boolean
     */
    public void setIncludeRelatedProduct(Boolean includeRelatedProduct){
        this.includeRelatedProduct = includeRelatedProduct;
    }

    /**
     * Getter for includeFacetObject
     * @return - status of includeFacetObject
     */
    public Boolean isIncludeRelatedProduct(){
        return this.includeRelatedProduct;
    }

    /**
     * Setter for includeFacetObject
     * @param - incFacetObject as boolean
     */
    public void setIncludeProductPropertyy(Boolean incProdProperty){
        this.includeProductProperty = incProdProperty;
    }

    /**
     * Getter for includeProductProperty
     * @return - status of includeProductProperty
     */
    public Boolean isIncludeProductProperty(){
        return this.includeProductProperty;
    }

    /**
     * Getter for allRows
     * @return - status of allRows
     */
    public Boolean isAllRows(){
        return this.allRows;
    }
    /**
     * Setter for allRows
     * @param - allRows as boolean
     */
    public void setAllRows(Boolean allRows){
        this.allRows = allRows;
    }

    public Boolean equals(Object obj) {
        return this.hashCode() == obj.hashCode();
    }

    public Integer hashCode() {
        Integer code = 0;
        code += (incldueUserDetail == true ? 1 : 0 );
        code += (incldueTimePlan == true ? 1 : 0);
        code += (incldueTimePolicy ==  true ? 1 : 0);
        code += (includeProductCount == true ? 1 : 0);
        code += (includeProductHierarchy == true ? 1 : 0);
        code += (includeProductProperty == true ? 1 : 0);
        code += (includeRelatedProduct == true ? 1 : 0);
        code +=  (lastModifiedFormat != null ? lastModifiedFormat.hashCode() : 0);
        code +=  entityList.hashCode();
        code +=  pgInfo.hashCode();
        code +=  fldInfo.hashCode();
        return code;
    }
}