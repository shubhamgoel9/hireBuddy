/**
 * This inteface defines all basic operation supported by repository.
 *
 * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
 *
 * Created 30 Sep, 2019 
 * 
 * @author - mehtesham@vlocity.com                          
 */
public interface IDomainRepository {

    /**
     * Add entity to db.  
     *
     * @param Sobject - entity object to be saved.
     * @Returns Sobject - Saved entity object.
     */
    Sobject saveEntity(Sobject obj);

    /**
     * Clone entity to db.  
     *
     * @param Sobject - entity object to be saved.
     * @Returns Sobject - Saved entity object.
     */
    Sobject cloneEntity(Sobject obj);

    /**
     * Delete entity from db.  
     *
     * @param Sobject - entity object to be delete.
     * @Returns Boolean - status of operation.
     */
    boolean deleteEntity(Sobject obj);

    /**
     * Update entity to db.  
     *
     * @param Sobject - entity object to be updated.
     * @Returns Boolean - Status of the operation.
     */
    boolean updateEntity(Sobject obj);

    /**
     * Add list of entity to db.  
     *
     * @param List<Sobject> - list of entity object to be saved.
     * @Returns List<Sobject> - Saved entity objects.
     */
    List<Sobject>  saveEntitySet(List<Sobject> listObj);

    /**
     * Delete list of entity from db.  
     *
     * @param List<Sobject> - list of entity object to be delete.
     * @Returns Boolean - status of operation.
     */
    boolean deleteEntitySet(List<Sobject> listObj);

    /**
     * Update list of entity to db.  
     *
     * @param List<Sobject> - list of entity object to be updated.
     * @Returns Boolean - Status of the operation.
     */
    boolean updateEntitySet(List<Sobject> listObj);

    /**
    * registers relationship of entity with related parent
    * Sets obj.relatedToParentField = parent.Id
    *
    * @param Sobject - entity object.
    * @param Schema.sObjectField - object field pointing to the parent.
    * @param Sobject - parent record.
    * @Returns Sobject - Saved entity object.
    */
    Sobject registerRelationship(SObject obj, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);

    /**
     * Find entity by its Id.
     *
     * @param Id - Id of the entity which need to find. 
     * @return Sobject - match entity.
     */
    Sobject findEntityById(Id sObjId);

    /**
     * Find entity set by its corresponding Ids.
     *
     * @param Id - Set of Id of the entity which need to find. 
     * @return List<Sobject> - match entity set
     */
    List<Sobject> findEntitySetByIds(List<Id> sObjIds);

    /**
     * Find entity set by its fields.
     *
     * @param DomainRequest - Sobject inside DomainRequest must contains correspoing field value
     * @return DomainResponse 
     */
    DomainResponse findEntitySetByFields(DomainRequest epcReq);

    /**
     * It commits the transaction
     */
     void commitTransaction();


     /**
      * Get transaction
      */
      VDMLTransaction getTransaction();

    /**
     * Rollback the last activities
     */
    void rollBackTransaction();
}