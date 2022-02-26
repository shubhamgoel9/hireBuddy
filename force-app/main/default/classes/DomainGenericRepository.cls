/**
 * This repository is can be used for any enitity type by passing table name
 * or Sobjecttype.
 *
 * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
 *
 * Created 30 Sep, 2019
 *
 * @author - mehtesham@vlocity.com
 */

public inherited sharing class DomainGenericRepository extends DomainBaseRepository {

    //Name of the entity.
    String tableName;

    // Fields of the entity.
    String objFields;

    /*
     * Reference info contains tree structure of releation ship between the entity.
     * This object will be used to generate relationship field.
     */
    ReferenceInfo referenceInfo;

    public DomainGenericRepository(VDMLTransaction dmlTxn) {
        super(dmlTxn);
    }

    /**
     * Constructor with table name, a new transaction object wil be created.
     */
    public DomainGenericRepository(String tableName){
       // super(EPCAppModule.DmlTxn.newInstance());
        this.tableName = tableName;
        populateFields();
    }

    /**
     * Constructor with ReferenceInfo
     */
    public DomainGenericRepository(ReferenceInfo referenceInfo){
        //super(EPCAppModule.DmlTxn.newInstance());
        this.referenceInfo = referenceInfo;
        this.tableName = referenceInfo.getObjectType().getDescribe().getName();
        objFields = referenceInfo.getFields();
    }
    /**
     * Constructor with table name and transaction
     */
    public DomainGenericRepository(String tableName, VDMLTransaction txn){
        super(txn);
        this.tableName = tableName;
    }

    /**
     * Getter for table name, fields are going to repopulate based on
     * new table name.
     */
    public void setTableName(String tableName){
        this.referenceInfo = referenceInfo;
        this.tableName = tableName;
        populateFields();
    }

    /**
     * Setter for reference info
     */
    public void setReferenceInfo(ReferenceInfo referenceInfo){
        this.tableName = referenceInfo.getObjectType().getDescribe().getName();
        objFields = referenceInfo.getFields();
    }

    /**
     * Getter for table name
     */
    public override String getTableName(){
        return tableName;
    }

    /**
     * Getter for obejct field
     */
    public override String getSobjectFields(){
        return objFields;
    }

    /**
     * Setter for object fields
     */
    public void setObjectFields(String objFields){
        this.objFields = objFields;
    }

    /**
     * Populates fields of the table based on table name.
     */
    private void populateFields(){
        Schema.SObjectType objType = ((SObject)(Type.forName('Schema.'+this.tableName).newInstance())).getSObjectType();
        objFields = String.join(new List<String>(objType.getDescribe().fields.getMap().keySet()), ',');
        this.tableName = objType.getDescribe().getName();
    }
}