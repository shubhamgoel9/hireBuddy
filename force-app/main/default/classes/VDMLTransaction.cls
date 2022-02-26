/**
 * "A DML Transaction keeps track of everything you do during a business transaction that can affect the database. When you're done,
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 *
 * In an Apex context this pattern provides the following specific benifits
 *  - Applies bulkfication to DML operations, insert, update and delete
 *  - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 *  - Honours dependency rules between records and updates dependent relationships automatically during the commit
 * -  TODO ,incorporate Cache use
 *
 *
 **/
public virtual inherited sharing class VDMLTransaction implements VDMLTransactionInterface
{
	protected List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>();

	protected Map<String, List<SObject>> newListByType = new Map<String, List<SObject>>();

	protected Map<String, Map<Id, SObject>> dirtyMapByType = new Map<String, Map<Id, SObject>>();

	protected Map<String, Map<Id, SObject>> deletedMapByType = new Map<String, Map<Id, SObject>>();

	protected Map<String, Relationships> relationships = new Map<String, Relationships>();

	protected Set<String> upsertObjectTypes = new Set<String>();

	protected Map<String, Set<Id>> typeToDeletedItemIds = new Map<String, Set<Id>>();

	protected Boolean itemsMarkedAsNew = false;

	protected Boolean itemsMarkedAsDirty = false;

	protected Boolean itemsMarkedAsDeleted = false;

	private List<IDoWork> workList = new List<IDoWork>();

	private SendEmailWork emailWork = new SendEmailWork();

	private IDML dml;

	private static Savepoint sp;

	public interface IDoWork
	{
		void doWork();
	}

	public interface IDML
	{
		void dmlInsert(List<SObject> objList);
		void dmlUpdate(List<SObject> objList);
		void dmlDelete(List<SObject> objList);
	}

	public inherited sharing class SimpleDML implements IDML
	{
		public void dmlInsert(List<SObject> objList){
			insert objList;
		}
		public void dmlUpdate(List<SObject> objList){
			update objList;
		}
		public void dmlDelete(List<SObject> objList){
			delete objList;
		}
	}

	public VDMLTransaction()
	{
		this(new List<Schema.SObjectType> {Candidate__c.SObjectType, Interviewer__c.SObjectType, Round__c.SObjectType, Panel__c.SObjectType, Hiring_Event__c.SObjectType}, new SimpleDML());
	}

	public VDMLTransaction(List<Schema.SObjectType> sObTypes)
	{
		
		this(sObTypes,new SimpleDML());
	}


	public VDMLTransaction(List<Schema.SObjectType> sobTypes, IDML inpDml)
	{
		sObjectTypes = sobTypes.clone();

		for(Schema.SObjectType sObjectType : sObjectTypes)
		{
			// register the type
			handleRegisterType(sObjectType);
		}
		workList.add(emailWork);

		dml = inpDml;
	}

	// default implementations for commitWork events
	public virtual void onRegisterType(Schema.SObjectType sObjectType) {}
	public virtual void onCommitWorkStarting() {}
	public virtual void onDMLStarting() {}
	public virtual void onDMLDone() {}
	public virtual void onDoWorkStarting() {}
	public virtual void onDoWorkDone() {}
	public virtual void onCommitWorkFinishing() {}
	public virtual void onCommitWorkDone(Boolean wasSuccessful) {}

	// Method to add upsert Object types
	public void addUpsertObjectTypes(Set<String> objectTypes)
	{
		upsertObjectTypes.addAll(objectTypes);
	}

	private void handleRegisterType(Schema.SObjectType sObjectType)
	{
		// add type to dml operation tracking
		newListByType.put(String.valueOf(sObjectType), new List<SObject>());
		dirtyMapByType.put(String.valueOf(sObjectType), new Map<Id, SObject>());
		deletedMapByType.put(String.valueOf(sObjectType), new Map<Id, SObject>());
		relationships.put(String.valueOf(sObjectType), new Relationships());

		// give derived class opportunity to register the type
		onRegisterType(sObjectType);
	}

    /**
     * Resets the save point.
     */
    public static void resetSavePoint(){
        sp = Database.setSavePoint();
    }

	public void registerWork(IDoWork work)
	{
		workList.add(work);
	}

	public void registerEmail(Messaging.Email email)
	{
		emailWork.registerEmail(email);
	}

	public void markAsNew(SObject record)
	{
		markAsNew(record, null, null);
	}

	public void markAsNew(List<SObject> records)
	{
		for(SObject record : records)
		{
			markAsNew(record, null, null);
		}
	}

	public void markAsNew(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if(record.Id != null && !hasFakeId(record))
			throw new DMLTransactionException('Only new records can be registered as new');
			String sObjectType = String.valueOf(record.getSObjectType());
			if(!newListByType.containsKey(sObjectType))
			throw new DMLTransactionException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		newListByType.get(sObjectType).add(record);
		if(relatedToParentRecord != null && relatedToParentField != null)
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		itemsMarkedAsNew = true;
	}

	public void registerRelationship(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
	{
		String sObjectType = String.valueOf(record.getSObjectType());
		if(!newListByType.containsKey(sObjectType))
			throw new DMLTransactionException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		relationships.get(sObjectType).add(record, relatedToField, relatedTo);
	}

	public void markDirty(SObject record)
	{
		if(record.Id == null)
			throw new DMLTransactionException('New records cannot be registered as dirty');
			String sObjectType = String.valueOf(record.getSObjectType());
			if(!dirtyMapByType.containsKey(sObjectType))
			throw new DMLTransactionException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));

		// If item has been marked for deletion then no need to update
		Map<Id, SObject> toBeDeletedMap = deletedMapByType.get(sObjectType);
		if(toBeDeletedMap != null && toBeDeletedMap.containsKey(record.Id))
		{
			return;
		}
		dirtyMapByType.get(sObjectType).put(record.Id, record);
		itemsMarkedAsDirty = true;
	}


    public void markDirty(SObject record, Schema.sObjectField relatedToParentField, SObject relatedToParentRecord)
    {
        if(record.Id == null)
            throw new DMLTransactionException('New records cannot be registered as dirty');
			String sObjectType = String.valueOf(record.getSObjectType());
			if(!dirtyMapByType.containsKey(sObjectType))
            throw new DMLTransactionException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
        dirtyMapByType.get(sObjectType).put(record.Id, record);
        if(relatedToParentRecord!=null && relatedToParentField!=null)
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		itemsMarkedAsDirty = true;
    }


	public void markDirty(List<SObject> records)
	{
		for(SObject record : records)
		{
			this.markDirty(record);
		}
	}


	public void markDeleted(SObject record)
	{
		if(record.Id == null)
			throw new DMLTransactionException('New records cannot be registered for deletion');
			String sObjectType = String.valueOf(record.getSObjectType());
			if(!deletedMapByType.containsKey(sObjectType))
			throw new DMLTransactionException(String.format('SObject type {0} is not supported by this unit of work', new String[] { sObjectType }));
		deletedMapByType.get(sObjectType).put(record.Id, record);
		itemsMarkedAsDeleted = true;
	}


	public void markDeleted(List<SObject> records)
	{
		for(SObject record : records)
		{
			this.markDeleted(record);
		}
	}
	
	private Boolean hasFakeId(Sobject objectSO)
    {
        if((String.valueOf(objectSO.Id)).contains('0000000000'))
        {
            return true;
        }
        return false;
    }

	public void commitWork()
	{
		// notify we're starting the commit work
		onCommitWorkStarting();

		// Wrap the work in its own transaction
		if(sp == null)
		{
			sp = Database.setSavePoint();
		}
		Boolean wasSuccessful = false;
		try
		{
			// notify we're starting the DML operations
			onDMLStarting();

			// Insert by type
			for(Schema.SObjectType sObjectType : sObjectTypes)
			{
				relationships.get(String.valueOf(sObjectType)).resolve();
				String key = String.valueOf(sObjectType);
				if(upsertObjectTypes.contains(key))
				{
					continue;
				}
				List<SObject> toBeInsertedItems = new List<SObject>();
				for(SObject item : newListByType.get(key))
				{
					// If item has been inserted already
					if(item.Id != null)
					{
						continue;
					}
					toBeInsertedItems.add(item);
				}
				dml.dmlInsert(toBeInsertedItems);
			}

			// Update by type
			for(Schema.SObjectType sObjectType : sObjectTypes)
			{
				String key = String.valueOf(sObjectType);
				if(upsertObjectTypes.contains(key))
				{
					continue;
				}
				dml.dmlUpdate(dirtyMapByType.get(key).values());
			}

			// Delete by type (in reverse dependency order)
			Integer objectIdx = sObjectTypes.size() - 1;
			while(objectIdx>=0)
			{
				// Checking if items have already been deleted
				String key = String.valueOf(sObjectTypes[objectIdx--]);
				if(typeToDeletedItemIds.get(key) == null)
				{
					typeToDeletedItemIds.put(key, new Set<Id>());
				}

				// Getting all the ids that has been deleted for this object type
				Set<Id> deletedIds = typeToDeletedItemIds.get(key);

				// Placeholder for items to be deleted
				List<SObject> toBeDeletedItems = new List<SObject>();

				// Iterating over all ids to be deleted to check if they were processed earlier
				for(Id itemId : deletedMapByType.get(key).keySet())
				{
					if(deletedIds.contains(itemId))
					{
						continue;
					}

					// Adding to the list for deleting and also to processed ids list
					toBeDeletedItems.add(deletedMapByType.get(key).get(itemId));
					deletedIds.add(itemId);
				}

				// Deleting the left over items
				if(!toBeDeletedItems.isEmpty())
				{
					// Adding real ids to handle auto-replace case
					deletedIds.addAll(new Map<Id, SObject>(toBeDeletedItems).keySet());

					// Deleting now
					dml.dmlDelete(toBeDeletedItems);
				}
			}
			// notify we're done with DML
			onDMLDone();

			// notify we're starting to process registered work
			onDoWorkStarting();
			// Generic work
			for(IDoWork work : workList)
				work.doWork();
			// notify we've completed processing registered work
			onDoWorkDone();

			// notify we've completed all steps and are in the final stage of completing
			onCommitWorkFinishing();

			// mark tracker to indicate success
			wasSuccessful = true;
		}
		catch (Exception e)
		{
			// Rollback
			Database.rollback(sp);
			// Throw exception on to caller
			throw e;
		}
		finally
		{
			// notify we're done with commit work
			onCommitWorkDone(wasSuccessful);
		}
	}

	public void rollBackTransaction()
	{
		if(sp != null)
		{
			Database.rollback(sp);
		}
	}

	public inherited sharing class Relationships
	{
		public List<Relationship> relationships = new List<Relationship>();

		public void resolve()
		{
			// Resolve relationships
			for(Relationship relationship : relationships)
			{
				relationship.Record.put(relationship.RelatedToField, relationship.RelatedTo.Id);
			}
		}

		public void add(SObject record, Schema.sObjectField relatedToField, SObject relatedTo)
		{
			// Relationship to resolve
			Relationship relationship = new Relationship();
			relationship.Record = record;
			relationship.RelatedToField = relatedToField;
			relationship.RelatedTo = relatedTo;
			relationships.add(relationship);
		}
	}

	public inherited sharing class Relationship
	{
		public SObject Record;
		public Schema.sObjectField RelatedToField;
		public SObject RelatedTo;
	}


	public inherited sharing class DMLTransactionException extends Exception {}

	/**
	 * Internal implementation of Messaging.sendEmail, see outer class registerEmail method
	 **/
	private inherited sharing class SendEmailWork implements IDoWork
	{
		private List<Messaging.Email> emails;

		public SendEmailWork()
		{
			this.emails = new List<Messaging.Email>();
		}

		public void registerEmail(Messaging.Email email)
		{
			this.emails.add(email);
		}

		public void doWork()
		{
			if(emails.size() > 0) Messaging.sendEmail(emails);
		}
	}
}