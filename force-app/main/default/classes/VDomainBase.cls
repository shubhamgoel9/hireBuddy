public virtual inherited sharing class VDomainBase //implements VlocityOpenInterface
{

    protected IDomainRepository repository = null;


    public VDomainBase(){
    }

    public VDomainBase(IDomainRepository repository){
        this.repository = repository;
    }


    public Boolean invokeMethod(    String methodName,
                                    Map<String,Object> inp,
                                    Map<String,Object> outp,
                                    Map<String,Object> options)
    {
        outp =  new Map<String,Object>();
        if ( methodName.equals('getsObjectType'))
            {
                outp.put('output', sObjectType());
            }
        else if ( methodName.equals('getRecords'))
            {
                outp.put('output', getRecords());
            }
        else if ( methodName.equals('getWarnings'))
			{
				outp.put('output', getWarnings());
			}
        return true;
    }


    public SObjectType sObjectType()
        {
            return getSObjectType();
        }

    public List<SObject> getRecords()
        {
            return Records;
        }
    public List<String> getWarnings()
		{
			return Warnings;
		}

    public List<SObject> Records { get; protected set;}

    public List<String> Warnings { get; protected set;}

    public static ErrorFactory Errors  {get; private set;}

    public VDomainBase(List<SObject> sObjectList)
    {
        this(sObjectList, sObjectList.getSObjectType());
    }

    public VDomainBase(List<SObject> sObjectList, SObjectType sObjectType)
    {
        // Ensure the domain class has its own copy of the data
        Records = sObjectList.clone();
    }

    public virtual void onApplyDefaults() { }

    public virtual void onValidate() {    }

    public virtual void onValidate(Map<Id,SObject> existingRecords)    { }

    public virtual void onBeforeInsert() { }

    public virtual void onBeforeUpdate(Map<Id,SObject> existingRecords) { }

    public virtual void onBeforeDelete() { }

    public virtual void onAfterInsert() { }

    public virtual void onAfterUpdate(Map<Id,SObject> existingRecords) { }

    public virtual void onAfterDelete() { }

    public virtual void onAfterUndelete() { }


    public SObjectType getSObjectType()
    {
        return Records.getSObjectType();
    }

    /**
     * Interface used to aid the triggerHandler in constructing instances of Domain classes
     **/
    public interface IConstructable
    {
        VDomainBase construct(List<SObject> sObjectList);
    }

    /**
     * Interface used to aid the triggerHandler in constructing instances of Domain classes
     **/
    public interface IConstructable2 extends IConstructable
    {
        VDomainBase construct(List<SObject> sObjectList, SObjectType sObjectType);
    }


    public inherited sharing class DomainException extends Exception
    {
    }

    public String error(String message, SObject record)
    {
        return Errors.error(this, message, record);
    }

    public String error(String message, SObject record, SObjectField field)
    {
        return Errors.error(this, message, record, field);
    }

    public inherited sharing class ErrorFactory
    {
        private List<Error> errorList = new List<Error>();

        private ErrorFactory()
        {

        }

        public String error(String message, SObject record)
        {
            return error(null, message, record);
        }

        private String error(VDomainBase domain, String message, SObject record)
        {
            ObjectError objectError = new ObjectError();
            objectError.domain = domain;
            objectError.message = message;
            objectError.record = record;
            errorList.add(objectError);
            return message;
        }

        public String error(String message, SObject record, SObjectField field)
        {
            return error(null, message, record, field);
        }

        private String error(VDomainBase domain, String message, SObject record, SObjectField field)
        {
            FieldError fieldError = new FieldError();
            fieldError.domain = domain;
            fieldError.message = message;
            fieldError.record = record;
            fieldError.field = field;
            errorList.add(fieldError);
            return message;
        }

        public List<Error> getAll()
        {
            return errorList.clone();
        }

        public void clearAll()
        {
            errorList.clear();
        }
    }

    public virtual inherited sharing class FieldError extends ObjectError
    {
        public SObjectField field;

        public FieldError()
        {

        }
    }

    public virtual inherited sharing class ObjectError extends Error
    {
        public SObject record;

        public ObjectError()
        {

        }
    }

    public abstract inherited sharing class Error
    {
        public String message;
        public VDomainBase domain;
    }

    /**
     * Return domain based on SobjectType
     *
     * @param SobjectType objType
     * @return Domain object based on passed argument.
     */
    public VDomainBase getDomain(SObjectType objType, VDomainBase defaultDomain){
        VDomainBase domainBase = null;
        try{
            //domainBase = EPCAppModule.Domain.newInstance(objType);
            domainBase.setRepository(repository);
        }catch(Exception e){
            domainBase = defaultDomain;
        }
        return domainBase;
    }

    /**
    /**
    * Saves the entities
    *
    * @param DomainRequest - Domain Request containing sobjects
   * @param Boolean commit the transaction after operation if value is set
    * @return DomainResponse - Domain response containing saved sobjects
    */
    public virtual DomainResponse saveEntity(DomainRequest request, Boolean commitTxn){
        DomainResponse response = new DomainResponse();
        if(repository == null){
            
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        for(SObject sObj : request.getEntityList()){
            repository.saveEntity(sObj);
        }
        if(commitTxn){
            repository.commitTransaction();
        }
        response.setEntityList(request.getEntityList());
        response.setWarningMesssages(this.Warnings);
        return response;
    }



    /**
    * Update the entities
    *
    * @param DomainRequest - Domain Request containing sobjects
    * @param Boolean commit the transaction after operation if value is set
    * @return DomainResponse - Domain response containing updated sobjects
    */
    public virtual DomainResponse updateEntity(DomainRequest request, Boolean commitTxn){
        DomainResponse response = new DomainResponse();
        if(repository == null){
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        for(SObject sObj : request.getEntityList()){
            repository.updateEntity(sObj);
        }
        if(commitTxn){
            repository.commitTransaction();
        }
        response.setEntityList(request.getEntityList());
        response.setWarningMesssages(this.Warnings);
        return response;
    }

    /**
    * Delete the entites
    *
    * @param DomainRequest - Domain Request containing sobjects
    * @param Boolean commit the transaction after operation if value is set
    * @return DomainResponse - Domain response containing deleted sobjects
    */
    public virtual DomainResponse deleteEntity(DomainRequest request, Boolean commitTxn){
        if(repository == null){
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        for(SObject sObj : request.getEntityList()){
            repository.deleteEntity(sObj);
        }
        if(commitTxn){
            repository.commitTransaction();
        }
        DomainResponse response = new DomainResponse();
        response.setEntityList(request.getEntityList());
        response.setWarningMesssages(this.Warnings);
        return response;
    }

    /**
    * Clone the entites
    *
    * @param DomainRequest - Domain Request containing sobjects
    * @param Boolean commit the transaction after operation if value is set
    * @return DomainResponse - Domain response containing cloned sobjects
    */
    public virtual DomainResponse cloneEntity(DomainRequest request, Boolean commitTxn){
        DomainResponse response = new DomainResponse();
        if(repository == null){
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        for(SObject sObj : request.getEntityList()){
            repository.cloneEntity(sObj);
        }
        if(commitTxn){
            repository.commitTransaction();
        }
        response.setEntityList(request.getEntityList());
        return response;
    }

    /**
     * Commits the transaction
     */
    public void commitTransaction(){
        if(repository != null){
            repository.commitTransaction();
        }
    }

    /**
     * Saves the entity
     *
     * @param SObject - SObject of the entity to be saved
     * @return SObject - Saved Sobject
     */
    public SObject saveEntity(SObject sObj){
        if(repository == null){
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        Sobject retSobject = repository.saveEntity(sObj);
        repository.commitTransaction();
        return retSobject;
    }

    /**
     * Clones the entity
     *
     * @param ReferenceInfo - Besically this is table and its corresponding field along with
     *                        associated references.
     * @param SObject - SObject of the entity to be cloned
     * @return SObject - Cloned Sobject
     */
    public SObject cloneEntity(ReferenceInfo refInfo,SObject sObj){
        if(repository == null){
            repository = new DomainGenericRepository(refInfo);
        }
        Sobject retSobject = repository.cloneEntity(sObj);
        repository.commitTransaction();
        return retSobject;
    }

    /**
     * Deletes existing records (Sobject)
     *
     * @param SObject - The Sobject which need to get deleted
     * @return Boolean - true on success otherwise false
     */
    public boolean deleteEntity(Sobject sObj){
        if(repository == null){
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        repository.deleteEntity(sObj);
        repository.commitTransaction();
        return true;
    }

    /**
     * Updates existing records (Sobject)
     *
     * @param SObject - The Sobject which need to get updated
     * @return Boolean - true on success otherwise false
     */
    public boolean updateEntity(SObject sObj){
        if(repository == null){
            repository = new DomainGenericRepository(new VDMLTransaction());
        }
        repository.updateEntity(sObj);
        repository.commitTransaction();
        return true;
    }

    /**
     * Finds the entity based on passed entity id
     *
     * @param Id - Id of the entity to be searched
     * @return SObject -  SObject based on passed id in DB otherwise null.
     */
    public SObject findEntityById(Id entityId){
        SObject sobj = null;
        if(entityId != null){
            sobj =  new DomainGenericRepository(new ReferenceInfo(null, entityId.getSObjectType())).findEntityById(entityId);
        }
        return sobj;
    }

    /**
     * Finds the entity based on passed argument
     *
     * @param ReferenceInfo - Besically this is table and its corresponding field along with
     *                        associated references.
     * @param Id - Id of the entity to be searched
     * @return SObject -  SObject based on passed id in DB otherwise null.
     */
    public SObject findEntityById(ReferenceInfo refInfo, Id entityId){
        return new DomainGenericRepository(refInfo).findEntityById(entityId);
    }


    /**
     * Finds the entity based on passed entity id
     *
     * @param List<Id> - List of Id of the entities to be searched
     * @return List<SObject> -  SObject based on passed id in DB otherwise null.
     */
    public List<SObject> findEntityByIds(List<Id> entityIds){
        List<SObject> listSobj = null;
        if(entityIds != null && entityIds.size() > 0) {
            listSobj =  new DomainGenericRepository(new ReferenceInfo(null, entityIds[0].getSObjectType())).findEntitySetByIds(entityIds);
        }
        return listSobj;
    }

    /**
     * Finds the entities based on passed argument
     *
     * @param ReferenceInfo - Besically this is table and its corresponding field along with
     *                        associated references.
     * @param List<Id> - List of Id of the entities to be searched
     * @return SObject -  SObject based on passed id in DB otherwise null.
     */
    public List<SObject> findEntityByIds(ReferenceInfo refInfo, List<Id> entityIds){
        return new DomainGenericRepository(refInfo).findEntitySetByIds(entityIds);
    }

    /**
     * Finds the set of entity based on passed argument
     *
     * @param ReferenceInfo - Besically this is table and its corresponding field along with
     *                        associated references.
     * @param DomainRequest - This contains the values as entity, conditions as FieldInfo and
     *                        page info
     * @return DomainResponse - which will contains set of entity and page info.
     */
    public DomainResponse findEntitySetByFields(ReferenceInfo refInfo, DomainRequest epcReq){
        return new DomainGenericRepository(refInfo).findEntitySetByFields(epcReq);
    }

    public void setRepository(IDomainRepository repository){
        this.repository = repository;
    }

    public IDomainRepository getRepository(){
        return this.repository;
    }

    /**
     * Rollback the last activities
     */
    public void rollBackTransaction()
    {
        if(this.repository != null)
        {
            this.repository.rollBackTransaction();
        }
    }
}