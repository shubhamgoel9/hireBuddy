/**
  * It is base class of the repository which provides implemenation of
  * the all method in its interface.
  *
  * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
  *
  * Created 30 Sep, 2019
  *
  * @author - mehtesham@vlocity.com
  */
public abstract inherited sharing class DomainBaseRepository implements IDomainRepository {

    VDMLTransaction txn;
    String singleQuote = '\'';
    //public String nsp = ApplicationUtilities.getNameSpacePrefix();

    /**
     * Constructor
     *
     * @param VDMLTransaction - The transaction object.
     */
    public DomainBaseRepository(VDMLTransaction txn){
        this.txn = txn;
    }

    public DomainBaseRepository(){
        this.txn = txn;
    }

    /**
     * Add entity to db.
     *
     * @param Sobject - entity object to be saved.
     * @Returns Sobject - Saved entity object.
     */
    public Sobject saveEntity(Sobject obj){
         txn.markAsNew(obj);
         return obj;
    }

    /**
     * Add entity to db with related parent marked as new
     * Sets obj.relatedToParentField = parent.Id
     *
     * @param Sobject - entity object to be saved.
     * @param Schema.sObjectField - object field pointing to the parent.
     * @param Sobject - parent record.
     * @Returns Sobject - Saved entity object.
     */
    public Sobject saveEntity(SObject obj, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord){
        txn.markAsNew(obj, relatedToParentField, relatedToParentRecord);
        return obj;
    }

    /**
     * registers relationship of entity with related parent
     * Sets obj.relatedToParentField = parent.Id
     *
     * @param Sobject - entity object.
     * @param Schema.sObjectField - object field pointing to the parent.
     * @param Sobject - parent record.
     * @Returns Sobject - Saved entity object.
     */
    public Sobject registerRelationship(SObject obj, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord){
        txn.registerRelationship(obj, relatedToParentField, relatedToParentRecord);
        return obj;
    }

     /**
     * Add entity to db.
     *
     * @param Sobject - entity object to be saved.
     * @Returns Sobject - Saved entity object.
     */
    public Sobject cloneEntity(Sobject obj){
         Sobject obj2 = findEntityById(obj.Id);
         obj2.put('Id', null);
         txn.markAsNew(obj2);
         return obj2;
    }


    /**
     * Delete entity from db.
     *
     * @param Sobject - entity object to be delete.
     * @Returns Boolean - status of operation.
     */
    public boolean deleteEntity(Sobject obj){
        txn.markDeleted(obj);
        return true;
    }

    /**
     * Update entity to db.
     *
     * @param Sobject - entity object to be updated.
     * @Returns Sobject - Status of the operation.
     */
    public boolean updateEntity(Sobject obj){
        txn.markDirty(obj);
        return true;
    }

    /**
     * Updates entity in db with related parent
     * Sets obj.relatedToParentField = parent.Id
     *
     * @param Sobject - entity object to be updated.
     * @param Schema.sObjectField - object field pointing to the parent.
     * @param Sobject - parent record.
     * @Returns Sobject - Updated entity object.
     */
    public Sobject updateEntity(SObject obj, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord){
        txn.markDirty(obj, relatedToParentField, relatedToParentRecord);
        return obj;
    }

    /**
     * Add list of entity to db.
     *
     * @param List<Sobject> - list of entity object to be saved.
     * @Returns List<Sobject> - Saved entity objects.
     */
    public List<Sobject>  saveEntitySet(List<Sobject> listObj){
        txn.markAsNew(listObj);
        return listObj;
    }

    /**
     * Delete list of entity from db.
     *
     * @param List<Sobject> - list of entity object to be delete.
     * @Returns Boolean - status of operation.
     */
    public boolean deleteEntitySet(List<Sobject> listObj){
        txn.markDeleted(listObj);
        return true;
    }

    /**
     * Update list of entity to db.
     *
     * @param List<Sobject> - list of entity object to be updated.
     * @Returns Boolean - Status of the operation.
     */
    public boolean updateEntitySet(List<Sobject> listObj){
        txn.markDirty(listObj);
        return true;
    }

    /**
     * Rollback the last activities
     */
    public void rollBackTransaction()
    {
        txn.rollBackTransaction();
    }

    /**
     * Find entity by its Id.
     *
     * @param Id - Id of the entity which need to find.
     * @return Sobject - match entity.
     */
    public Sobject findEntityById(Id sObjId){
        Sobject sObj = null;
         String query = 'SELECT ' + getSobjectFields() + ' FROM ' +
                        getTableName() + ' WHERE Id =:sObjId';
        try{
            sObj = Database.query(query);
        }catch(Exception e){
            System.debug('Error while executing query ' + e.getMessage());
        }
        return sObj;
    }

    /**
     * Find entity set by its corresponding Ids.
     *
     * @param Id - Set of Id of the entity which need to find.
     * @return List<Sobject> - match entity set
     */
    public List<Sobject> findEntitySetByIds(List<Id> sObjIds){
        String query = 'SELECT ' + getSobjectFields() + ' FROM ' +
                        getTableName() + ' WHERE Id in :sObjIds';
        List<Sobject> listOfSobject = Database.query(query);
        return listOfSobject;
    }

    /**
     * Find entity set by its fields.
     *
     * @param DomainRequest - Sobject inside DomainRequest must contains correspoing field value
     * @return DomainResponse
     */
    public DomainResponse findEntitySetByFields(DomainRequest request){
        DomainResponse response = new DomainResponse();
        String queryFields = getSobjectFields();
        String whereClause = '';
        String paginationQuery = '';
        if(request != null){
            whereClause = getWhereClause(request) + getGroupBy(request) + getOrderBy(request)+getAllRows(request);
            paginationQuery = getLimit(request) + getOffset(request);
        }

        String query =  'SELECT ' + queryFields + ' FROM ' + getTableName() + whereClause ;
        System.debug('QUERY TO RUN' + query);
        List<Sobject> listOfSobject = Database.query(query + paginationQuery);

        if(listOfSobject != null && listOfSobject.size() > 0 && request.getOffsetNumber() != null){
            buildPageInfo(request, response, query);
        }
        response.setEntityList(listOfSobject);
        return response;
    }

     private String getAllRows(DomainRequest epcReqInfo){
        String allRows = '';
        if(epcReqInfo.isAllRows()){
            allRows = ' ALL ROWS ';
        }
        return allRows;
    }

    /**
     * Build page info
     *
     * @param DomainRequest request
     * @param DomainResponse response
     * @param String - query string
     */
    private void buildPageInfo(DomainRequest request, DomainResponse response, String query){

        List<SObject> result = Database.query(query);
        Integer totalCount = result.size();
        Integer totalPages = (Integer)  (totalCount/request.getPageSize());
        totalPages += Math.mod(totalCount, request.getPageSize()) > 0 ? 1 : 0;

        response.setTotalCount(totalCount);

        response.setTotalPages(totalPages);
        response.setPageSize(request.getPageSize());
        response.setCurrentPage(request.getPageNumber());
    }

    /**
     * Return where clause SQL statement based on passed argument.
     *
     */
     public String getWhereClause(DomainRequest epcReqInfo){
        FieldInfo fieldInfo = epcReqInfo.getFieldInfo();
        DomainRequest.Queries queries = epcReqInfo.getQueries();
        String whereClause = '';
        if(fieldInfo == null && queries == null) {
            return whereClause;
        }

        if(epcReqInfo.getWhereClause() != null){
            return epcReqInfo.getWhereClause();
        }

        Sobject sObj = epcReqInfo.getEntity();

        if(queries != null ){
            whereClause = ' WHERE ( ';
            Boolean first = true;
            for(FieldInfo fldInfo : queries.getFieldInfos()){
                if(first){
                    whereClause = whereClause + getClause(fldInfo, epcReqInfo) + ' ) ';
                    first = false;
                }else {
                    whereClause = whereClause + getLogicalOperatorString(queries.getOperator()) + ' (' + getClause(fldInfo, epcReqInfo) + ') ';
                }
            }
        }else {
            whereClause = ' WHERE (' + getClause(fieldInfo, epcReqInfo) + ') ';
        }
        return whereClause;
    }

    public String getClause(FieldInfo fieldInfo, DomainRequest epcReqInfo){
        String clause = fieldInfo.getRelativeFieldPath() +
                                getComparisonOperatorString(fieldInfo.getComparisonOperator()) +
                                getFieldValue(epcReqInfo.getEntityList(), fieldInfo);

        while(fieldInfo.getLinkedFieldInfo() != null){
            fieldInfo = fieldInfo.getLinkedFieldInfo();
            clause = clause + getLogicalOperatorString(fieldInfo.getLogicalOperator()) +
                                fieldInfo.getRelativeFieldPath() +
                                getComparisonOperatorString(fieldInfo.getComparisonOperator()) +
                                getFieldValue(epcReqInfo.getEntityList(), fieldInfo);
        }
        return clause;
    }

    /**
     * Return logical operator as string
     */
    private String getLogicalOperatorString(FieldInfo.LogicalOperators operator){
        String strOperator = ' AND ';
        if(operator == null || operator == FieldInfo.LogicalOperators.OP_AND){
            strOperator = ' AND ';
        }else if(operator == FieldInfo.LogicalOperators.OP_OR){
            strOperator = ' OR ';
        }else {
             strOperator = ' NOT ';
        }
        return strOperator;
    }

    /**
     * Return comparison operator as string
     */
    private String getComparisonOperatorString(FieldInfo.ComparisonOperators operator){
        String strOperator = ' = ';
        if(operator == null || operator == FieldInfo.ComparisonOperators.OP_EQUALS){
            strOperator = ' = ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_NOT_EQUALS){
            strOperator = ' != ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_NOT_EQUALS){
            strOperator = ' != ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_LESS_THAN){
            strOperator = ' < ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_LESS_THAN_EQUALS){
            strOperator = ' <= ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_GREATER_THAN){
            strOperator = ' > ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_GREATER_THAN_EQUALS){
            strOperator = ' >= ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_IN){
            strOperator = ' IN ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_NOT_IN){
            strOperator = ' NOT IN ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_LIKE){
            strOperator = ' LIKE ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_INCLUDES){
            strOperator = ' INCLUDES ';
        }else if(operator == FieldInfo.ComparisonOperators.OP_EXCLUDES){
            strOperator = ' EXCLUDES ';
        }
        return strOperator;
    }

    /**
     * Return value of the field from sobject
     *
     */
    private String getFieldValue(List<Sobject> entityList, FieldInfo fldInfo){

        String value = fldInfo.getFieldValue();
        if(value != null){
            return value;
        }
        String fieldValue = null;
        Boolean isFirst = true;

        if(fldInfo.getComparisonOperator() == FieldInfo.ComparisonOperators.OP_IN ||
            fldInfo.getComparisonOperator() == FieldInfo.ComparisonOperators.OP_NOT_IN ){
            fieldValue = ' ( ';
            for(SObject entity : entityList){
                if(isFirst){
                    isFirst = false;
                    fieldValue = fieldValue + fldInfo.getFieldValue(entity);
                }else{
                    fieldValue = fieldValue + ', ' + fldInfo.getFieldValue(entity);
                }
            }
            fieldValue = fieldValue + ' ) ';
        }else{
            fieldValue = fldInfo.getFieldValue(entityList[0]);
        }
        return fieldValue;
    }

    private String getOrderBy(DomainRequest epcReq){
        String orderBy = '';
        if(epcReq != null && epcReq.getOrderBy() != null) {
            orderBy = ' ORDER BY ' + epcReq.getOrderBy();
        }
        return orderBy;
    }

    private String getGroupBy(DomainRequest epcReq){
        String groupBy = '';
        if(epcReq != null && epcReq.getGroupBy() != null) {
            groupBy = ' GROUP BY ' + epcReq.getGroupBy();
        }
        return groupBy;
    }

    private String getLimit(DomainRequest epcReqInfo){
        String strLimit = '';
        if(epcReqInfo != null && epcReqInfo.getPageSize() != null && epcReqInfo.getPageSize() > 0){
            strLimit = ' LIMIT ' + epcReqInfo.getPageSize();
        }
        return strLimit;
    }

    private String getOffset(DomainRequest epcReqInfo){
        String strOffset = '';
        if(epcReqInfo != null && epcReqInfo.getOffsetNumber() != null && epcReqInfo.getOffsetNumber()  > 0){
            strOffset = ' OFFSET ' + epcReqInfo.getOffsetNumber();
        }
        return strOffset;
    }

    /**
     * Returns field name of the query string, child class can override this fuction
     * if it need additional fields.
     */
    public virtual String getSobjectFields(){
        return 'Id, Name';
    }

    /**
     * Return name of the table, child class must override this fucntion and
     * provide appropriate table name.
     */
    public virtual String getTableName(){
        return '';
    }

    /**
     * Commit Transaction
     */
    public void commitTransaction(){
        txn.commitWork();
    }

    /**
     * Get transaction object
     */
    public VDMLTransaction getTransaction(){
        return this.txn;
    }

    public interface IConstructable
    {
        IDomainRepository construct(List<SObject> sObjectList);
    }
}