/**
 * This class is container for response information
 *
 * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
 *
 * Created 30 Sep, 2019
 *
 * @author - mehtesham@vlocity.com
 */

public virtual inherited sharing class DomainResponse {

/**
 *        {
 *          "epcResponse": {
 *            "overallResult": "success",
 *            "failureReason": "MissingMantetoryData - Id is missing in payload",
 *            "entities": [
 *              "entityInfo": {
 *                "entity": {
 *                  "Id": "a2x3i000000ke9IAAQ",
 *                  "Name": "Test PL",
 *                  "vlocity_cmt__Code__c": "Test PL",
 *                  "vlocity_cmt__CurrencyCode__c": null,
 *                  "vlocity_cmt__Description__c": "Test PL Description__c",
 *                  "vlocity_cmt__EffectiveFromDate__c": null,
 *                  "vlocity_cmt__EffectiveUntilDate__c": null,
 *                  "vlocity_cmt__IsActive__c": true,
 *                  "vlocity_cmt__LoyaltyCode__c": null,
 *                  "vlocity_cmt__ParentPriceListId__c": null,
 *                  "vlocity_cmt__Pricebook2Id__c": "01s3i000002JmV0AAK",
 *                  "vlocity_cmt__Sequence__c": 10
 *                },
 *                "lastModified": "2 days back"
 *              }
 *            ],
 *            "hierarchy": {
 *                "entity": {
 *                  "Id": "a2x3i000000ke9IAAQ",
 *                  "Name": "Test PL",
 *                  "vlocity_cmt__Code__c": "Test PL",
 *                  "vlocity_cmt__CurrencyCode__c": null,
 *                  "vlocity_cmt__Description__c": "Test PL Description__c",
 *                  "vlocity_cmt__EffectiveFromDate__c": null,
 *                  "vlocity_cmt__EffectiveUntilDate__c": null,
 *                  "vlocity_cmt__IsActive__c": true,
 *                  "vlocity_cmt__LoyaltyCode__c": null,
 *                  "vlocity_cmt__ParentPriceListId__c": null,
 *                  "vlocity_cmt__Pricebook2Id__c": "01s3i000002JmV0AAK",
 *                  "vlocity_cmt__Sequence__c": 10
 *                },
 *                "hierarchy": [
 *                ]
 *            },
 *            "pageInfo": {
 *               "currentPage":10,
 *               "totalPages":30,
 *               "pageSize":50,
 *            }
 *          }
 *        }
 */

    //Response Constants
    public static final String EPC_RESPONSE_ELEMENT             = 'epcResponse';
    public static final String OVERALL_RESULT_ELEMENT           = 'overallResult';
    public static final String FAILURE_REASON_ELEMENT           = 'failureReason';
    public static final String WARNING_MESSAGE_ELEMENT          = 'warningMessage';
    public static final String ENTITIES_ELEMENT                 = 'entities';
    public static final String ENTITY_INFO_ELEMENT              = 'entityInfo';
    public static final String ENTITY_ELEMENT                   = 'entity';
    public static final String LAST_MODIFIED_ELEMENT            = 'lastModified';
    public static final String SUPPLIMENTRY_ENTITY_ELEMENT      = 'supplimentryEntity';
    public static final String HIERARCHY_ELEMENT                = 'hierarchy';
    public static final String DESCRIBE_ENTITY_ELEMENT          = 'describeEntity';
    public static final String CHILDREN_ELEMENT                 = 'children';
    public static final String PAGE_INFO_ELEMENT                = 'pageInfo';
    public static final String CURRENT_PAGE_ELEMENT             = 'currentPage';
    public static final String TOTAL_PAGES_ELEMENT              = 'totalPages';
    public static final String PAGE_SIZE_ELEMENT                = 'pageSize';
    public static final String TOTAL_COUNT_ELEMENT              = 'totalCount';
    public static final String NUMBER_OF_PRODUCT_ELEMENT        = 'numberOfProduct';

    //Possible overall result
    public enum RESULT_ENUM {
        success, failure, timeout, parsingError, validationError, missingMandatoryData
    }
    //Resultant entity
    List<SObject> enitityList = null;
    //Root response map
    Map<String, Object> epcResponseMap = new Map<String, Object>();
    //Entity hierarachy map, used for getHierarchy method.
    Map<String, Object> hierarchyMap = null;
    //Describe object map
    Map<String,Map<String,Object>> descObjMap = null;
    //Overall result of the request
    RESULT_ENUM overallResult = RESULT_ENUM.success;
    //Reason of failure if any
    String failureReason = null;
    //Warning messages if any
    public List<String> warningMessage = null;
    //Error code
    String errorCode = null;
    //Error
    String error = null;
    //Contains entity and relevant information
    List<EntityInfo> entitiesInfo = new List<EntityInfo>();
    //Contains pagination information
    private PageInfo pgInfo = new PageInfo();

    /**
     * Inner class for containsing entity and relevant information
     */
    public class EntityInfo{
        //Entity
        Sobject entity;
        //last modified format
        String modifiedFormat = null;
        //number of product assoiciated entity
        Integer numberOfProduct;
        //product hierarchy associated with entity
        Map<String, Object> hierarchyMap = null;
        //Additional entity
        List<Object> supplimentryEntityList = null;

        /**
         * Setter of entity
         */
        public void setEntity(SObject ent){
            this.entity = ent;
        }

        /**
         * Setter for last modified format
         */
        public void setModifiedFormat(String format){
            this.modifiedFormat = format;
        }

        /**
         * Setter for hierarchy map
         */
        public void setHierarchyMap(Map<String, Object> hierarchy){
            this.hierarchyMap = hierarchy;
        }

        /**
         * Setter for supplimentry entity list
         */
        public void setSupplimentryList(List<Object> supplimentryMap){
            this.supplimentryEntityList = supplimentryMap;
        }
    }

    /**
     * Inner class for containing pagination information
     */
    private class PageInfo{
        //Current page
        Integer currentPage = null;
        //Total number of pages
        Integer totalPages = null;
        //Total number of record per page
        Integer pageSize = null;
        //Total number of record per
        Integer totalCount = null;
    }

    /**
     * Build JSonResult
     */
    // public JSONResult toJSONResult(){
    //     return null;
    // }

    public String  toSObject(){
        return null;
    }

    /**
     * Build output map
     */
    public Map<String, Object> toOutputMap(){

        if(overallResult == RESULT_ENUM.success){
            epcResponseMap.put(OVERALL_RESULT_ELEMENT, overallResult.name());
            List<Map<String, Object>> entityInfoList = buildEnityInfoList();
            // Build entity information
            if(entityInfoList != null){
                epcResponseMap.put(ENTITIES_ELEMENT, entityInfoList);
            }
            //Build entity hierarchy
            if(hierarchyMap != null){
                epcResponseMap.put(HIERARCHY_ELEMENT, hierarchyMap);
            }
            //Build describe entity
            if(descObjMap != null){
                epcResponseMap.put(DESCRIBE_ENTITY_ELEMENT, descObjMap);
            }
            //Build pagination
            Map<String, Integer> pgInfoMap = buildPageInfo();
            if(pgInfoMap != null){
                epcResponseMap.put(PAGE_INFO_ELEMENT, pgInfoMap);
            }
        } else {
            //Buiod overall result and failure reason for failure case.
            epcResponseMap.put(OVERALL_RESULT_ELEMENT, overallResult.name());
            epcResponseMap.put(FAILURE_REASON_ELEMENT, failureReason);
        }
        if(this.warningMessage != null){
            epcResponseMap.put(WARNING_MESSAGE_ELEMENT, this.warningMessage);
        }
        return epcResponseMap;
    }

    /**
     * Build page info
     *
     * @return Map<String, Integer>
     */
    private Map<String, Integer> buildPageInfo(){
        Map<String, Integer> pageMap = null;
        //If any page info is available then build page information
        if(pgInfo.pageSize != null || pgInfo.totalPages != null || pgInfo.currentPage != null){
            pageMap = new Map<String, Integer>();
            pageMap.put(PAGE_SIZE_ELEMENT, pgInfo.pageSize);
            pageMap.put(TOTAL_PAGES_ELEMENT, pgInfo.totalPages);
            pageMap.put(CURRENT_PAGE_ELEMENT, pgInfo.currentPage);
            pageMap.put(TOTAL_COUNT_ELEMENT, pgInfo.totalCount);
        }
        return pageMap;
    }

    /**
     * Populates entity info list based on available inputs
     *
     * @return List<Map<String, Object>> - Formatted entity info list.
     */
    private List<Map<String, Object>>  buildEnityInfoList(){
        List<Map<String, Object>> entityInfoList = new List<Map<String, Object>>();
        for(EntityInfo entInfo : entitiesInfo){
            Map<String, Object> entityInfoMap = new Map<String, Object>();
            if(entInfo.entity == null){
                continue;
            }
            //Build entity
            entityInfoMap.put(ENTITY_ELEMENT, entInfo.entity);
            //Build last modified format
            if(entInfo.modifiedFormat != null){
                entityInfoMap.put(LAST_MODIFIED_ELEMENT, entInfo.modifiedFormat);
            }
            //Build number of product
            if(entInfo.numberOfProduct != null){
                entityInfoMap.put(NUMBER_OF_PRODUCT_ELEMENT, entInfo.numberOfProduct);
            }
            //Build supplimentry entity
            if(entInfo.supplimentryEntityList != null){
                entityInfoMap.put(SUPPLIMENTRY_ENTITY_ELEMENT, entInfo.supplimentryEntityList);
            }
            //Build hierarchy if available
            if(entInfo.hierarchyMap != null){
                entityInfoMap.put(HIERARCHY_ELEMENT, entInfo.hierarchyMap);
            }
            //Add entityInfoMaop to list.
            entityInfoList.add(entityInfoMap);
        }
        return entityInfoList;
    }

    /**
     * Get entity info List
     */
    public List<EntityInfo> getEntityInfoList(){
        return entitiesInfo;
    }

    /**
     * Add for entity info object
     */
    public void addEntityInfo(EntityInfo entInfo){
        entitiesInfo.add(entInfo);
    }

    /**
     * Add entity info
     *
     * @param Sobject - entity object
     * @param modifiedFormat = last modifierd format string.
     * @param productCount - number of product.
     */
    public void addEntityInfo(Sobject obj, String modifiedFormat, Integer productCount){
        EntityInfo entInfo = new EntityInfo();
        entInfo.entity = obj;
        entInfo.modifiedFormat = modifiedFormat;
        entInfo.numberOfProduct = productCount;
        entitiesInfo.add(entInfo);
    }

    /**
     * Setter for hierarchy map
     */
    public void setHierarchyMap(Map<String, Object> hierarchyMap){
        this.hierarchyMap = hierarchyMap;
    }

    /**
     * Setter for describe object
     */
    public void setDescribeObjectMap(Map<String,Map<String,Object>> descMap){
        this.descObjMap = descMap;
    }

    /**
     * Setter for overall result
     */
    public void setOverallResult(RESULT_ENUM result){
        this.overallResult = result;
    }

    /**
     * Getter for overall result
     */
    public RESULT_ENUM getOverallResult(){
        return this.overallResult;
    }

    /**
     * Setter for failure reason
     */
    public void setFailureReason(String reason){
        this.failureReason = reason;
    }

    /**
     * Getter for failure reason
     */
    public String getFailureReason(){
        return this.failureReason;
    }

    /**
     * Setter for warning messages
     */
    public void setWarningMesssages(List<String> warningMsg){
        this.warningMessage = warningMsg;
    }

    /**
     * Getter for warning message
     */
    public List<String> getWarningMesssages(){
        return this.warningMessage;
    }

    /**
     * Setter for current page
     */
    public void setCurrentPage(Integer curPage){
        this.pgInfo.currentPage = curPage;
    }

    /**
     * Getter for current page
     */
    public Integer getCurrentPage(){
        return this.pgInfo.currentPage;
    }

    /**
     * Setter for total pages
     */
    public void setTotalPages(Integer totPages){
        this.pgInfo.totalPages = totPages;
    }

    /**
     * Getter for total pages
     */
    public Integer getTotalPages(){
        return this.pgInfo.totalPages;
    }

    /**
     * Setter for page size
     */
    public void setPageSize(Integer pgSize){
        this.pgInfo.pageSize = pgSize;
    }

    /**
     * Getter for page size
     */
    public Integer getPageSize(){
        return this.pgInfo.pageSize;
    }

    /**
     * Setter for total count
     */
    public void setTotalCount(Integer totCount){
        this.pgInfo.totalCount = totCount;
    }

    /**
     * Getter for total count
     */
    public Integer getTotalCount(){
        return this.pgInfo.totalCount;
    }

    /**
     * Setter for entity list
     */
    public void setEntityList(List<SObject> entityList){
        this.enitityList = entityList;
    }

    /**
     * Getter for entity list
     */
    public List<SObject> getEntityList(){
        return this.enitityList;
    }

    /**
     * Setter for ErrorCode
     */
    public void setErrorCode(String errorCode){
        this.errorCode = errorCode;
    }

    /**
     * Getter for ErrorCode
     */
    public String getErrorCode(){
        return this.errorCode;
    }

    /**
     * Setter for Error
     */
    public void setError(String error){
        this.error = error;
    }

    /**
     * Getter for Error
     */
    public String getError(){
        return this.error;
    }
}