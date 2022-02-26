/**
  * This class contains meta data about sobject and its references, based
  * on provided information it generate fields for query statement.
  *
  * Copyright (C) 2019 Vlocity Cloud Application.     ALL RIGHTS RESERVED
  *
  * Created 30 Sep, 2019 
  * 
  * @author - mehtesham@vlocity.com                          
  */
  public with sharing class ReferenceInfo {
    //Reference field
    Schema.SObjectField reference;

    //Reference object
    Schema.SObjectType referenceObjType;

    //Reference link
    List<ReferenceInfo> link;

    //User provided fields set.
    String baseFields = null;

    ////Reference object Id Field
    Schema.SObjectField referenceObjTypeId = null;

    List<String> strFieldList = new List<String>();
    List<Schema.SObjectField>  fieldList = new List<Schema.SObjectField>();

    /**
     * The only Constructor
     */
    public ReferenceInfo(Schema.SObjectField reference, Schema.SObjectType referenceObjectType ){
        this.reference = reference;
        this.referenceObjType = referenceObjectType;
        this.fieldList = referenceObjectType.getDescribe().fields.getMap().values();
        link = new List<ReferenceInfo>();
    }

    public ReferenceInfo(Schema.SObjectField reference, Schema.SObjectType referenceObjectType, 
                            String fields){
        this.reference = reference;
        this.referenceObjType = referenceObjectType;
        this.baseFields = fields;
        link = new List<ReferenceInfo>();
    }

    public ReferenceInfo(Schema.SObjectField reference, Schema.SObjectType referenceObjectType, 
                            List<Schema.SObjectField>  listfields){
        this.reference = reference;
        this.referenceObjType = referenceObjectType;
        this.fieldList = listfields;
        for(Schema.SObjectField objTypeFld: listfields){
            strFieldList.add(objTypeFld.getDescribe().getName());
        }
        baseFields = String.join(strFieldList, ', ');
        link = new List<ReferenceInfo>();
    }

    /**
     * Add reference to master table
     */
    public void addlink(ReferenceInfo referenceInfo){
        ReferenceInfo linkedRef = null;
        for(ReferenceInfo refInfo : link){
            if(refInfo.reference == referenceInfo.reference){
                linkedRef = refInfo;
                break;
            }
        }
        if(linkedRef == null){
            link.add(referenceInfo);
        }else{
            for(SObjectField objField : referenceInfo.fieldList){
                String fieldName = objField.getDescribe().name;
                if(!linkedRef.strFieldList.contains(fieldName)){
                    linkedRef.strFieldList.add(fieldName);
                    if(linkedRef.baseFields == null){
                        linkedRef.baseFields = fieldName;
                    }else{
                        linkedRef.baseFields += ', ' + fieldName;
                    }
                }
            }
        }
    }

    /**
     *
     */
    public String getFields(){
        List<String> allField =  new List<String>();
        allField.addAll(getBaseFields(this));
        allField.addAll(buildFields(getReferenceName(this)));
        return String.join(allField, ', ');
    }

    /**
     * 
     */
    private List<String> buildFields(String parentReference) {
        List<String> allField = new List<String>();
        if(link != null && link.size() > 0){
            for(ReferenceInfo refInfo : link) {
                String prefix = getReferenceName(refInfo);
                if(parentReference.length() > 0 ){
                    prefix = parentReference + '.' + prefix;
                }
                allField.addAll(getReferenceFields(prefix, refInfo));
                allField.addAll(refInfo.buildFields(prefix));
            }
        }
        return allField;
    }

    /**
     *
     */
    private String getReferenceName(ReferenceInfo refInfo){
        String referanceName = '';
        if(refInfo.reference != null){
            referanceName = refInfo.reference.getDescribe().getRelationshipName();
        }
        return referanceName;
    }

    /**
     * 
     */
    private List<String> getReferenceFields(String parentReference, ReferenceInfo refInfo){
        List<String> referenceField = new List<String>(); 
        List<String> baseField = getBaseFields(refInfo);
        for(String field : baseField){
            referenceField.add(parentReference + '.' + field.trim());
        }
        return referenceField;
    }

    /**
     * Populates fields of the table based on table name.
     */
    private List<String> getBaseFields(ReferenceInfo refInfo){
        List<String> listFields = new List<String>();
        if(refInfo.baseFields != null){
            listFields = refInfo.baseFields.split(',');
        }else{
            listFields =  new List<String>(refInfo.referenceObjType.getDescribe().fields.getMap().keySet());
        }
        return listFields;
    }

    public Schema.SObjectType getObjectType(){
        return  referenceObjType;
    }

    public Schema.SObjectField getObjectTypeId(){
        if(referenceObjTypeId == null){
            referenceObjTypeId = getObjectType().getDescribe().fields.getMap().get('id');
        }
        return  referenceObjTypeId;
    }

    public void setObjectTypeId(SObjectField objectId){
          referenceObjTypeId = objectId;
    }

    /**
     * Add fields in Reference
     */
    public void addFields(List<List<SObjectField>> allListField){
        for(List<SObjectField> fields: allListField){
            if(fields.size() == 1){
                String fieldName = fields[0].getDescribe().name;
                if(!strFieldList.contains(fieldName)){
                    strFieldList.add(fieldName);
                    if(baseFields == null){
                        baseFields = fieldName;
                    }else{
                        baseFields += ', ' + fieldName;
                    }
                }
            } else {
                SObjectField refField = fields[0];
                ReferenceInfo linkedRef = null;
                for(ReferenceInfo refInfo : link){
                    if(refInfo.reference == refField){
                        linkedRef = refInfo;
                        break;
                    }
                }
                if(linkedRef == null){
                    linkedRef = new ReferenceInfo(refField, refField.getDescribe().getReferenceTo()[0], 'Id');
                    this.addlink(linkedRef);
                }
                fields.remove(0);
                linkedRef.addFields(new List<List<SObjectField>>{fields});
            }
        }
    }

    public List<Schema.SObjectField> getFieldList(){
        return fieldList;
    }

    public String getBaseField(){
        return baseFields;
    }

    public List<ReferenceInfo> getLinkedReference(){
        return link;
    }
}