public interface VDMLTransactionInterface 
{
	void markAsNew(SObject record);
	void markAsNew(List<SObject> records);
	void markAsNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);
	void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo);
	void markDirty(SObject record);
    void markDirty(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord);
	void markDirty(List<SObject> records);
	void markDeleted(SObject record);
	void markDeleted(List<SObject> records);
	void commitWork();
	void registerEmail(Messaging.Email email);
}