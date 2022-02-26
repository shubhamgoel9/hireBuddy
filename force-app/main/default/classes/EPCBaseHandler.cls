/**
  * Base class for EPC handler
  *
  * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
  *
  * Created 30 Sep, 2019
  *
  * @author - mehtesham@vlocity.com
  */

public virtual inherited sharing class EPCBaseHandler implements IEPCHandler {

    //public static String nsp = ApplicationUtilities.getNameSpacePrefix();
    public Map<String,Object> inputs = null;
    public Map<String,Object> output = null;
    public Map<String,Object> options = null;
    protected VDomainBase domainBase = null;
    protected DomainRequest epcReq;
    protected DomainResponse epcRes;
    private OperationType operation;
    protected String methodName;
    private ReferenceInfo mySelf = null;
    protected Boolean isReferenceBuilt = false;

    public class MissingMandatoryDataException extends Exception {}
    public class InvalidDataException extends Exception {}
    public class ParsingException extends Exception {}

    //CRUD operation type.
    public enum OperationType {
        OPERATION_CREATE, OPERATION_READ, OPERATION_UPDATE, OPERATION_DELETE,OPERATION_CLONE,OPERATION_AMEND
    }

    /**
     * Initialize with inputs arguments
     */
    public virtual void initialize(String methodName, Map<String,Object> inputs, Map<String,Object> output,
                            Map<String,Object> options){
        this.inputs = inputs;
        this.output = output;
        this.options = options;
        this.methodName = methodName;
        //Add this log based on flag.
        //System.debug('Output Request ' + JSON.serialize(inputs));

        try{
            domainBase = new VDomainBase();//EPCAppModule.Domain.newInstance(getReferenceInfo().getObjectType());
        }catch(Exception e){
            domainBase = new VDomainBase();
            System.debug('Error in initializing domain object ' + e.getMessage());
        }
        epcRes = new DomainResponse();

        if (EPCAppConstants.CREATE_METHODS.contains(methodName)) {
            operation = OperationType.OPERATION_CREATE;
        }
        else if (EPCAppConstants.READ_METHODS.contains(methodName)) {
            operation = OperationType.OPERATION_READ;
        }
        else if (EPCAppConstants.UPDATE_METHODS.contains(methodName)) {
            operation = OperationType.OPERATION_UPDATE;
        }
        else if (EPCAppConstants.DELETE_METHODS.contains(methodName)) {
           operation = OperationType.OPERATION_DELETE;
        } else if(EPCAppConstants.CLONE_METHODS.contains(methodName)){
            operation = OperationType.OPERATION_CLONE;
        }
    }

    /**
     *
     */
    public DomainResponse execute()
    {
        try
        {
            /**
            * parse request, Validate parsed request etc.
            */
            preProcess();
        } 
        catch(MissingMandatoryDataException mmde)
        {
            System.debug(mmde.getStackTraceString());
            epcRes.setOverallResult(DomainResponse.RESULT_ENUM.missingMandatoryData);
            epcRes.setFailureReason(mmde.getMessage());
        }
        catch(InvalidDataException ide)
        {
            System.debug(ide.getStackTraceString());
            epcRes.setOverallResult(DomainResponse.RESULT_ENUM.validationError);
            epcRes.setFailureReason(ide.getMessage());
        }
        catch(ParsingException pe)
        {
            System.debug(pe.getStackTraceString());
            epcRes.setOverallResult(DomainResponse.RESULT_ENUM.parsingError);
            epcRes.setFailureReason(pe.getMessage());
        } 
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            epcRes.setOverallResult(DomainResponse.RESULT_ENUM.failure);
            epcRes.setFailureReason(ex.getMessage());
            // if(ex instanceOf VlcBaseException)
            // {
            //    VlcBaseException vbe = (VlcBaseException) ex;
            //    epcRes.setErrorCode(vbe.getErrorCode());
            //    epcRes.setError(vbe.getError());
            // }
            // else
            // {
            //    epcRes.setErrorCode(VlcBaseException.ERROR_CODE_500);
            // }
        }

        if(epcRes.getOverallResult() == DomainResponse.RESULT_ENUM.success)
        {
            //If validation fails then dont process 
            try{
                /**
                * Operation
                */
                process();
            } 
            catch(Exception ex)
            {
                //Rollback the transaction
                domainBase.rollBackTransaction();
                
                System.debug(ex.getMessage());
                System.debug(ex.getStackTraceString());
                epcRes.setOverallResult(DomainResponse.RESULT_ENUM.failure);
                epcRes.setFailureReason(ex.getMessage());
                // if(ex instanceOf VlcBaseException)
                // {
                // VlcBaseException vbe = (VlcBaseException) ex;
                // epcRes.setErrorCode(vbe.getErrorCode());
                // epcRes.setError(vbe.getError());
                // }
                // else
                // {
                // epcRes.setErrorCode(VlcBaseException.ERROR_CODE_500);
                // }
            }
        }

        /**
         * Commit transaction, build response, clean up etc.
         */
        postProcess();

        return epcRes;
    }

    /**
     * Pre Process
     */
    public void preProcess(){
        parseInputParam();
        validateData();
        if(!isReferenceBuilt){
            isReferenceBuilt = true;
            buildReference();
        }
    }

    /**
     * Based on operation type it call appropriate function.
     */
    public void process(){

        if(operation == OperationType.OPERATION_DELETE){
            if(!getReferenceInfo().getObjectType().getDescribe().isDeletable()){
                throw new InvalidDataException(String.format('Insufficient privilege to {0} operation on {1}', new List<String>{'delete', getReferenceInfo().getObjectType().getDescribe().label}));
            }
            deleteProcess();
        } else if(operation == OperationType.OPERATION_UPDATE){
            if(!getReferenceInfo().getObjectType().getDescribe().isUpdateable()){
                throw new InvalidDataException(String.format('Insufficient privilege to {0} operation on {1}', new List<String>{'update', getReferenceInfo().getObjectType().getDescribe().label}));
            }
            updateProcess();
        } else if(operation == OperationType.OPERATION_READ){
            if(!getReferenceInfo().getObjectType().getDescribe().isAccessible()){
                throw new InvalidDataException(String.format('Insufficient privilege to {0} operation on {1}', new List<String>{'view', getReferenceInfo().getObjectType().getDescribe().label}));
            }
            readProcess();
        } else if(operation == OperationType.OPERATION_CREATE){
            if(!getReferenceInfo().getObjectType().getDescribe().isCreateable()){
                throw new InvalidDataException(String.format('Insufficient privilege to {0} operation on {1}', new List<String>{'create', getReferenceInfo().getObjectType().getDescribe().label}));
            }
            createProcess();
        } else if(operation == OperationType.OPERATION_CLONE){
            if(!getReferenceInfo().getObjectType().getDescribe().isCreateable()){
                throw new InvalidDataException(String.format('Insufficient privilege to {0} operation on {1}', new List<String>{'create', getReferenceInfo().getObjectType().getDescribe().label}));
            }
            cloneProcess();
        } else if(operation == OperationType.OPERATION_AMEND){
            if(!getReferenceInfo().getObjectType().getDescribe().isUpdateable()){
                throw new InvalidDataException(String.format('Insufficient privilege to {0} operation on {1}', new List<String>{'update', getReferenceInfo().getObjectType().getDescribe().label}));
            }
            amendProcess();
        }else{
            customProcess();
        }
    }

    /**
     * Post process
     */
    public virtual void postProcess(){
        //Populate the response.
        output.put(DomainResponse.EPC_RESPONSE_ELEMENT, epcRes.toOutputMap());
        //To make happy to PCConsoleController
        output.put('result', null);
        //Add this log based on flag.
        //System.debug('Output Response ' + JSON.serialize(output));
        //Clean up.
        //DomainRequest = null;
    }

    /*
     * Default implementation of clone process
     */
    public virtual void cloneProcess(){
        domainBase.cloneEntity(getReferenceInfo(),getEntity());
        epcRes.addEntityInfo(getEntity(), null, null);
    }

    /*
     * Default implementation of read process
     */
    public virtual void createProcess(){
        DomainResponse response = domainBase.saveEntity(getDomainRequest(), true);
        epcRes.setWarningMesssages(response.getWarningMesssages());
        getDomainRequest().setFieldInfo(new FieldInfo(getReferenceInfo().getObjectTypeId(), FieldInfo.ComparisonOperators.OP_IN));
        epcRes.setEntityList(domainBase.findEntitySetByFields(getReferenceInfo(), getDomainRequest()).getEntityList());
        for(SObject entity : getDomainResponse().getEntityList()){
            epcRes.addEntityInfo(entity,
                epcReq.isLastModifiedEvaluatedFormat() ? getLastModifiedFormat(entity) : null, null);
        }
    }

    /**
     * Default implementation of read process
     */
    public virtual void readProcess(){
        if(getDomainRequest().isFindById()){
            readByID();
        } else {
            readByField();
        }
    }

    /**
     * Reads a record based on Id.
     */
    public Sobject readByID(){
        Sobject entity = domainBase.findEntityById(getReferenceInfo(), getEntity().Id);
        epcRes.addEntityInfo(entity,
            epcReq.isLastModifiedEvaluatedFormat() ? getLastModifiedFormat(entity) : null, null);
        return entity;
    }

    /**
     * Query set of record based on passed criteria.
     */
    public List<Sobject> readByField(){
        DomainResponse response = domainBase.findEntitySetByFields(getReferenceInfo(), getDomainRequest());
        List<Sobject> entities = response.getEntityList();
        copyPageInfo(response);
        for(Sobject entity : entities){
            epcRes.addEntityInfo(entity,
                epcReq.isLastModifiedEvaluatedFormat() ? getLastModifiedFormat(entity) : null, null);
        }
        return entities;
    }

    /**
     * Copies pageInfo from passed argument.
     */
     public void copyPageInfo(DomainResponse response){
        epcRes.setPageSize(response.getPageSize());
        epcRes.setTotalPages(response.getTotalPages());
        epcRes.setCurrentPage(response.getCurrentPage());
        epcRes.setTotalCount(response.getTotalCount());
    }

    /**
     * Return formatted modified date/time
     *
     */
    public String getLastModifiedFormat(Sobject entity){

        String lastModifiedFormat = 'Unknown';
        if (entity == null)
        {
            return lastModifiedFormat;
        }
        DateTime lastModified = (DateTime)entity.get('LastModifiedDate');

        if(lastModified != null){
            Long todayInMilli = DateTime.now().getTime();
            Long lastModifiedInMilli = lastModified.getTime();
            Long milliseconds = todayInMilli - lastModifiedInMilli;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;

            if(days > 2){
                lastModifiedFormat = '' + lastModified.date();
            } else if(days == 2){
                lastModifiedFormat = 'Yesterday';
            }else if (hours > 0){
                lastModifiedFormat = hours + ((hours == 1) ? ' hour ago' : ' hours ago');
            } else if(minutes > 0){
                lastModifiedFormat = minutes + ((minutes == 1) ? ' minute ago' : ' minutes ago');
            }else{
                lastModifiedFormat =  'Few seconds ago';
            }
        }
        return lastModifiedFormat;
    }

    /*
     * Default implementation of update process
     */
    public virtual void updateProcess(){
        DomainResponse response = domainBase.updateEntity(getDomainRequest(), true);
        epcRes.setWarningMesssages(response.getWarningMesssages());
        getDomainRequest().setFieldInfo(new FieldInfo(getReferenceInfo().getObjectTypeId(), FieldInfo.ComparisonOperators.OP_IN));
        epcRes.setEntityList(domainBase.findEntitySetByFields(getReferenceInfo(), getDomainRequest()).getEntityList());
        for(SObject entity : getDomainResponse().getEntityList()){
            epcRes.addEntityInfo(entity,
                epcReq.isLastModifiedEvaluatedFormat() ? getLastModifiedFormat(entity) : null, null);
        }
    }

     /*
     * Default implementation of amend process
     */
    public virtual void amendProcess(){
        DomainResponse response = domainBase.updateEntity(getDomainRequest(), true);
        epcRes.setWarningMesssages(response.getWarningMesssages());
        getDomainRequest().setFieldInfo(new FieldInfo(getReferenceInfo().getObjectTypeId(), FieldInfo.ComparisonOperators.OP_IN));
        epcRes.setEntityList(domainBase.findEntitySetByFields(getReferenceInfo(), getDomainRequest()).getEntityList());
        for(SObject entity : getDomainResponse().getEntityList()){
            epcRes.addEntityInfo(entity,
                epcReq.isLastModifiedEvaluatedFormat() ? getLastModifiedFormat(entity) : null, null);
        }
    }

    /*
     * Default implementation of delete process
     */
    public virtual void deleteProcess(){
        DomainResponse response = domainBase.deleteEntity(getDomainRequest(), true);
        epcRes.setWarningMesssages(response.getWarningMesssages());
        for(SObject entity : getDomainRequest().getEntityList()){
            epcRes.addEntityInfo(entity, null, null);
        }

    }
    /**
     * Child class can override this function if needed for any custom processing.
     */
    public virtual void customProcess(){
        if(methodName == EPCAppConstants.METHOD_DESCRIBE_ENTITY){
            //getDomainResponse().setDescribeObjectMap(
                //EPCAdminUtils.describeObject(getReferenceInfo().getObjectType().getDescribe().getName()));
        }
        else{
            throw new InvalidDataException('Operation not supported ' + methodName);
        }
    }

    /**
     * This is an optional method for request handler to implemnent, in this mehtod
     * it is expected that to validate request payload with mandatory and valid values.
     * This method can throw exception like
     *  MissingMandatoryDataException -
     *  InvalidValueException -
     */
    public virtual void validateData(){
        for(SObject entity : getDomainRequest().getEntityList()){
            if(operation == EPCBaseHandler.OperationType.OPERATION_DELETE ||
                    operation == EPCBaseHandler.OperationType.OPERATION_UPDATE ||
                    operation == EPCBaseHandler.OperationType.OPERATION_CREATE){
                if(entity == null){
                    throw new MissingMandatoryDataException('Entity is missing in payload.');
                }

            }
            if(operation == EPCBaseHandler.OperationType.OPERATION_DELETE ||
                    operation == EPCBaseHandler.OperationType.OPERATION_UPDATE){
                if(entity.Id == null){
                    throw new MissingMandatoryDataException('Missing entity Id for Delete or Update operations.');
                }
            }
        }
    }

    /**
     * All request handler need to override this method and populate Sobject
     * from payload value.
     */
    public virtual void parseInputParam(){

        Map<String, Object> epcRequestMap = (Map<String, Object>) inputs.get(DomainRequest.EPC_REQUEST_ELEMENT);
        List<Object> entities = (List<Object>) epcRequestMap.get(DomainRequest.ENTITIES_ELEMENT);
        Map<String, Object> entityMap = (Map<String, Object>) epcRequestMap.get(DomainRequest.ENTITY_ELEMENT);
        Map<String, Object> querySet = (Map<String, Object>) epcRequestMap.get(DomainRequest.QUERY_SET_ELEMENT);

        List<Object> queryListObj = (List<Object>) epcRequestMap.get(DomainRequest.QUERY_ELEMENT);

        List<Map<String, Object>> queryList = new List<Map<String, Object>>();
        if(queryListObj != null){
            for(Object obj : queryListObj){
                queryList.add((Map<String, Object>)obj);
            }
        }

        Map<String, Object> pageInfoMap = (Map<String, Object>) epcRequestMap.get(DomainRequest.PAGE_INFO_ELEMENT);

        epcReq = new DomainRequest(inputs);
        //TODO: remove below code.
        epcReq.setObjectType((String)inputs.get('objectType'));
        epcReq.setRecordType((String)inputs.get('recordType'));
        epcReq.setCondition((String)inputs.get('condition'));
        epcReq.setSearchString((String)inputs.get('searchString'));

        populateFieldSet(epcRequestMap);
        populateInclude(epcRequestMap);
        //Entities
        if(entities != null){
            for(Object entInfoMap : entities){
                Map<String, Object> entityInfoMap = (Map<String, Object>) entInfoMap;
                Map<String, Object> entMap = (Map<String, Object>)entityInfoMap.get(DomainRequest.ENTITY_ELEMENT);
                epcReq.addEntity(populateEntity(getReferenceInfo().getObjectType(), entMap));
            }
        }else{
            //Set entity
            setEntity(populateEntity(getReferenceInfo().getObjectType(), entityMap));
        }

        //Set FieldInfo
        if(querySet != null){
            FieldInfo.LogicalOperators logicalOpr = FieldInfo.getLogicalOperator('and');
            List<Object> listQuery =  (List<Object>) querySet.get('and');
            if(listQuery == null){
                listQuery =  (List<Object>) querySet.get('or');
                logicalOpr = FieldInfo.getLogicalOperator('or');
            }
            if(listQuery == null){
                //throw exception
            }else{
                for(Object queryObj : listQuery){
                    List<Object> queryListObject = (List<Object>)queryObj;
                    queryList = new List<Map<String, Object>>();
                    if(queryListObject != null){
                        for(Object obj : queryListObject){
                            queryList.add((Map<String, Object>)obj);
                        }
                    }
                    FieldInfo fldInfo = populateFieldInfo(queryList);
                    epcReq.setQueries(fldInfo, logicalOpr);
                }
            }
        }else {
            epcReq.setFieldInfo(populateFieldInfo(queryList));
        }

        //Populate page info
        popuatePage(pageInfoMap);
    }

    /**
     * Populates fieldSet 
     */
    private void populateFieldSet(Map<String, Object> epcRequestMap){
        
        List<Object> fldSet = (List<Object>) epcRequestMap.get(DomainRequest.FIELD_SET_ELEMENT);
        List<List<Schema.SObjectField>> fieldSetList = new List<List<Schema.SObjectField>>();
        ReferenceInfo refInfo = getReferenceInfo();

        SObjectType soType = refInfo.getObjectType();
        Map<String, Schema.SObjectField> soFieldMap = soType.getDescribe().fields.getMap();
        if(fldSet != null){
            for(Object objField : fldSet){
                String refField = String.valueOf(objField);
                List<Schema.SObjectField> relativeFields = new List<Schema.SObjectField>();
                if(refField != null){
                    Schema.SobjectField theField = soFieldMap.get(refField);
                    if(theField == null){
                        //Lets check for relative field information
                        String[] relativeFld = refField.split('\\.');
                        if(relativeFld.size() > 1){
                            relativeFields = getRelativeFields(soType, relativeFld);
                        }else{
                            throw new ParsingException('Invalid field ' + refField);
                        }
                    }else {
                        relativeFields.add(theField);
                    }
                    fieldSetList.add(relativeFields);
                }
            }
        }
        refInfo.addFields(fieldSetList);
    }



    private void populateInclude(Map<String, Object> epcRequestMap){
        List<Object> include = (List<Object>) epcRequestMap.get(DomainRequest.INCLUDE_ELEMENT);
        if(include != null){
            for(Object token : include){
                if((String)token == DomainRequest.USER_DETAIL_ELEMENT){
                    epcReq.setNeedUserInfo(true);
                }else if((String)token == DomainRequest.EVALUATED_DATE_ELEMENT){
                    epcReq.setLastModifiedFormat(DomainRequest.EVALUATED_DATE_ELEMENT);
                }else if((String)token == DomainRequest.PRODUCT_HIERARCHY_ELEMENT){
                    epcReq.setIncludeProductHierarchy(true);
                }else if((String)token == DomainRequest.TIME_PLAN_ELEMENT){
                    epcReq.setIncludeTimePlan(true);
                }else if((String)token == DomainRequest.TIME_POLICY_ELEMENT){
                    epcReq.setIncludeTimePolicy(true);
                }else if((String)token == DomainRequest.PRODUCT_PROPERTY_ELEMENT){
                    epcReq.setIncludeProductPropertyy(true);
                }else if((String)token == DomainRequest.RELATED_PRODUCT_ELEMENT){
                    epcReq.setIncludeRelatedProduct(true);
                }else if((String)token == DomainRequest.PICKLIST_VALUE_ELEMENT){
                    epcReq.setIncludePicklistValue(true);
                }else if((String)token == DomainRequest.ALL_VERSION_ELEMENT){
                    epcReq.setIncludeAllVersion(true);
                }
            }
        }
    }

     /**
     * Populate fieldInfo
     */
    private FieldInfo populateFieldInfo(List<Map<String, Object>> queryList){

        FieldInfo fldInfo = null;
        if(queryList == null){
            return null;
        }
        SObjectType soType = getReferenceInfo().getObjectType();
        Map<String, Schema.SObjectField> soFieldMap = soType.getDescribe().fields.getMap();
        for(Map<String, Object> fieldInfoMap : queryList){
            List<Schema.SObjectField> relativeFields = new List<Schema.SObjectField>();
            if(fieldInfoMap != null){
                String strFieldType = (String) fieldInfoMap.get(DomainRequest.FIELD_TYPE_ELEMENT);
                Schema.SobjectField theField = soFieldMap.get(strFieldType);
                if(theField == null){
                    //Lets check for relative field information
                    String[] relativeFld = strFieldType.split('\\.');
                    if(relativeFld.size() > 1){
                        relativeFields = getRelativeFields(soType, relativeFld);
                    }else{
                        throw new ParsingException('Invalid field ' + strFieldType);
                    }
                }else {
                    relativeFields.add(theField);
                }

                String strCompOperator = (String) fieldInfoMap.get(DomainRequest.COMPARISON_OPERATOR_ELEMENT);
                FieldInfo.ComparisonOperators cOperator = FieldInfo.getComparisonOperator(strCompOperator);

                String strLogicOperator = (String) fieldInfoMap.get(DomainRequest.LOGICAL_OPERATOR_ELEMENT);
                FieldInfo.LogicalOperators lOperator = FieldInfo.getLogicalOperator(strLogicOperator);

                List<Object> fieldValues = (List<Object> )fieldInfoMap.get(DomainRequest.FIELD_VALUES_ELEMENT);
                if(fieldValues != null){
                    if(fldInfo == null){
                        fldInfo = new FieldInfo(relativeFields, cOperator, lOperator, fieldValues);
                    }else{
                        fldInfo.addFieldInfo(new FieldInfo(relativeFields, cOperator, lOperator, fieldValues));
                    }
                }else {
                    Object fieldValue = fieldInfoMap.get(DomainRequest.FIELD_VALUE_ELEMENT);
                    if(fldInfo == null){
                        fldInfo = new FieldInfo(relativeFields, cOperator, lOperator, fieldValue);
                    }else{
                        fldInfo.addFieldInfo(new FieldInfo(relativeFields, cOperator, lOperator, fieldValue));
                    }
                }
            }
        }
        return fldInfo;
    }

    private List<Schema.SObjectField> getRelativeFields(Schema.SObjectType soType, String[] fields){
        List<Schema.SObjectField> listFields = new List<Schema.SObjectField>();
        Integer fieldSize = fields.size();
        for(Integer index = 0; index < fieldSize; index++){
            String strFld = fields[index];
            Map<String, Schema.SObjectField> feildMap = soType.getDescribe().fields.getMap();
            for(String refFld : feildMap.keySet()){
                Schema.SObjectField fieldDef = feildMap.get(refFld);
                if(index < (fieldSize - 1) && fieldDef.getDescribe().getRelationshipName() == strFld){
                    listFields.add(fieldDef);
                    soType = fieldDef.getDescribe().getReferenceTo()[0];
                    break;
                }else if(index == (fieldSize - 1) && fieldDef.getDescribe().getName() == strFld){
                    listFields.add(fieldDef);
                    break;
                }
            }
        }

        if(fieldSize != listFields.size()){
            throw new ParsingException('Invalid field ' + fields);
        }
        return listFields;
    }

    /**
     * Populate entity from map.
     */
    private SObject populateEntity(SObjectType soType, Map<String, Object> entityMap){
        if(entityMap == null){
            return null;
        }
        if(entityMap.containsKey('Id')){
            Id objId = (Id) entityMap.get('Id');
            soType = objId.getSobjectType();
        }
        SObject sObj = soType.newSObject();
        Map<String, Schema.SObjectField> feildMap = soType.getDescribe().fields.getMap();
        for (String fld : entityMap.keySet()) {
            Schema.SObjectField fieldDef = feildMap.get(fld);
            if(fieldDef == null){
                //Look for reference field
                for(String refFld : feildMap.keySet()){
                    fieldDef = feildMap.get(refFld);
                    if(fieldDef.getDescribe().getRelationshipName() == fld){
                        Map<String, Object> relEntityMap = (Map<String, Object>)entityMap.get(fld);
                        SObject relSObj = populateEntity(fieldDef.getDescribe().getReferenceTo()[0], relEntityMap);
                        sObj.putSObject(fieldDef.getDescribe().getRelationshipName(), relSObj);
                    }
                }
                //throw new InvalidDataException('Invalid field ' + fld + ' in ' + soType.getDescribe().getName());
            }else{
                Object fieldValue = entityMap.get(fld);
                if(fieldValue == null) {
                    sObj.put(fld, fieldValue);
                    continue;
                }
                if (fieldDef.getDescribe().getType() == DisplayType.DateTime) {
                    sObj.put(fld, toDateTime(fieldValue));
                } else if(fieldDef.getDescribe().getType() == DisplayType.DATE) {
                    sObj.put(fld, DateTime.newInstance((Long)fieldValue).date());
                } else if(fieldDef.getDescribe().getType() == DisplayType.INTEGER) {
                    sObj.put(fld, Integer.valueOf(fieldValue));
                } else if(fieldDef.getDescribe().getType() == DisplayType.DOUBLE ||
                            fieldDef.getDescribe().getType() == DisplayType.CURRENCY) {
                    sObj.put(fld, Double.valueOf(fieldValue));
                } else if(fieldDef.getDescribe().getType() == DisplayType.BOOLEAN) {
                    sObj.put(fld, Boolean.valueOf(fieldValue));
                } else if(fieldDef.getDescribe().getType() == DisplayType.BASE64) {
                    if(fieldValue instanceof Blob){
                        sObj.put(fld, (Blob)fieldValue);
                    }else{
                        sObj.put(fld, EncodingUtil.base64Decode((String)fieldValue));
                    }
                }else {
                    sObj.put(fld, entityMap.get(fld));
                }
            }
        }
        return sObj;
    }

    /**
     * Convert DateTime input argument as long or string to DateTime data type.
     * 
     * @param Object dateTimeObj - DateTime value in long or String type (1591034400000 , 2020-06-01 11:00:00)
     * @return DateTime - Return DateTime obj 
     */
    private DateTime toDateTime(Object dateTimeObj) {
        DateTime dateTm = null;
        if (dateTimeObj instanceof Long) {
            dateTm = DateTime.newInstance((Long)dateTimeObj);
        } else if (dateTimeObj instanceof String) {
            dateTm = DateTime.valueOf((String)dateTimeObj);
        } else {
            // throw exception for unsupported type 
            throw new InvalidDataException('Invalid DateTime value: ' + dateTimeObj);
        }
        return dateTm;
    }

    /**
     * It populates page releted arguments in DomainRequest.
     */
    private void popuatePage(Map<String, Object> pageInfoMap){
        if(pageInfoMap != null){
            Integer pageSize = parseInt(pageInfoMap.get(DomainRequest.PAGE_SIZE_ELEMENT));
            Integer pageNumber = parseInt(pageInfoMap.get(DomainRequest.PAGE_NUMBER_ELEMENT));
            if(pageNumber != null){
                epcReq.setPageNumber(pageNumber);
            }
            if(pageSize != null){
                epcReq.setPageSize(pageSize);
            }
            if(pageSize == null && pageNumber == null){
                epcReq.resetPagination();
            }
            epcReq.setOrderBy((String) pageInfoMap.get(DomainRequest.ORDER_BY_ELEMENT));
            epcReq.setGroupBy((String) pageInfoMap.get(DomainRequest.GROUP_BY_ELEMENT));
        }
    }

    private Integer parseInt(Object obj){
        Integer intValue = null;
        try{
            intValue = Integer.valueOf(obj);
        } catch(TypeException te){
            System.debug('Parse Error, Invalid value of integer ' + obj);
        }
        return intValue;
    }

    public void setEntity(Sobject entity){
        if(epcReq == null){
            epcReq = new DomainRequest();
        }
        this.epcReq.setEntity(entity);
    }

    public void setEntity(List<Sobject> entities){
        if(epcReq == null){
            epcReq = new DomainRequest();
        }
        this.epcReq.addEntity(entities);
    }

    public Sobject getEntity(){
        Sobject entity;
         if(epcReq != null){
            entity = epcReq.getEntity();
        }
        return entity;
    }

    public void setOperationType(OperationType opType){
        this.operation = opType;
    }
    public OperationType getOperationType(){
        return this.operation;
    }

    public DomainRequest getDomainRequest(){
        return epcReq;
    }

    public DomainResponse getDomainResponse(){
        return epcRes;
    }

    /**
     * Child Request handler must override this method.
     */
    public virtual ReferenceInfo getReferenceInfo(){
        if(mySelf == null){
            String sobjName = (String) inputs.get(DomainRequest.OBJECT_TYPE_ELEMENT);
             if(sobjName != null){
                Schema.SObjectType objType = ((SObject)(Type.forName('Schema.'+sobjName).newInstance())).getSObjectType();
                mySelf = new ReferenceInfo(null, objType);
            }
        }
        return mySelf;
    }

    /**
     * Child Request handler must override this method.
     */
    public virtual void buildReference(){
        if(getDomainRequest().isNeedUserInfo()){
            mySelf.addlink(getUserReference(mySelf.getObjectType().getDescribe().fields.getMap().get('LastModifiedById')));
        }
    }

    public ReferenceInfo getUserReference(Schema.SObjectField lastModifiedBy){
         ReferenceInfo userDetails = new ReferenceInfo(lastModifiedBy, User.SObjectType,
                                new List<Schema.SObjectField>{
                                     User.Id,
                                     User.Name,
                                     User.FullPhotoUrl
                                 });
        return userDetails;
    }
}