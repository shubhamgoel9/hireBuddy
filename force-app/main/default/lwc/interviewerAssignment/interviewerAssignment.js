import { LightningElement, track } from 'lwc';
import assignInterviewerToPanel from '@salesforce/apex/InterviewerAssignmentService.assignInterviewerToPanel';
import getPanelList from '@salesforce/apex/InterviewerAssignmentService.getPanelList';
import getInterviewerList from '@salesforce/apex/EventItemsController.getInterviewerList';
import deleteInterviewerList from '@salesforce/apex/EventItemsController.deleteInterviewerList';
const columns = [
    { label: 'Name', fieldName: 'InterviewerName__c', type:'text' },
    { label: 'Email', fieldName: 'InterviewerEmail__c', type:'email' }
];
export default class InterviewerAssignment extends LightningElement {
    columns=columns;
    @track userEmail;
    @track panelId;
    @track panelName;
    @track panelList;
    @track interviewerList;
    @track isModalOpen =false;
    @track errorMessage;
    @track isInterviewerList=false;
    @track isDataEmpty=true;
    connectedCallback()
    {
        getPanelList()
		.then(result => {
            console.log('Prit: panel list result: '+JSON.stringify(result));
            this.panelList = result;
		})
		.catch(error => {
            console.log('Prit: panel list error: '+JSON.stringify(error));
			this.error = error;
			this.panelList = undefined;
		})
    }

    get panelOptions()
    {
        let picklistoptions = [];
        if(this.panelList)
        {
            for(const key in this.panelList)
            {
                picklistoptions.push({
                    label:this.panelList[key].Name,
                    value:this.panelList[key].Id
                });
            }
        }
        console.log('Prit: picklistoptions :: '+ JSON.stringify(picklistoptions));
        return picklistoptions;   
    }

    handleChange(event)
    {
        var value = event.target.value;
        console.log('enter handle change::'+value);

        if(event.target.dataset.id === 'panel')
        {
            this.panelId = value;
            for(const key in this.panelList)
            {
                if(this.panelList[key].Id === this.panelId)
                {
                    this.panelName = this.panelList[key].Name;
                }
            }
            this.getInterviewerListFromPanel();
        }
        else if(event.target.dataset.id === 'userEmail')
        {
            this.userEmail = value;
        }
        this.isDataEmpty = (!(this.userEmail && this.panelId));
        console.log('Prit: isDataEmpty:'+this.isDataEmpty);
    }

    //method to get Interviewerlist from panel
    getInterviewerListFromPanel()
    {
        getInterviewerList({panelId:this.panelId})
		.then(result => {
            this.interviewerList = result;
            this.isInterviewerList = true;
            console.log('Prit: interviewer list result: '+JSON.stringify(this.interviewerList));

		})
		.catch(error => {
            console.log('Prit: interviewer list error: '+error);
			this.error = error;
			this.interviewerList = undefined;
		})
    }
    assignInterviewer()
    {
        var allValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);

        for(const key in this.interviewerList)
        {
            if(this.interviewerList[key].InterviewerEmail__c === this.userEmail)
            {
                allValid = false;
                this.errorMessage = 'Interviewer already exists!';
                break;
            }
        }
        if (allValid) 
        {
            assignInterviewerToPanel({userEmail:this.userEmail, panelId:this.panelId})
            .then(result => {
                this.errorMessage = "Assignment Successful! Kindly refresh page to reload data.";
            })
            .catch(error => {
                console.log('error: '+JSON.stringify(error));
                this.errorMessage = error.body.message;
            });
            this.userEmail=null;
            this.panelId=null;
            this.isDataEmpty=true;
            console.log('Prit: '+JSON.stringify(this.errorMessage));
            this.openModal();

        }
        else
        {
            console.log('Prit: openModal: ');
            this.openModal();
        }
        
    }

    openModal()
    {
        this.isModalOpen = true;
        console.log('Prit: isModalOpen:: '+this.isModalOpen);

    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        //window.location.reload();
        this.connectedCallback();
    }

    @track isDeleteDisabled=true;
    @track selectedInterviewerItem=null;
    //Method to make delete Button enable/disabled based on the row select/unselect
    disableDeleteButton(event)
    {
        console.log('Prit: eventDetails:: '+JSON.stringify(event.detail));
        this.selectedItems=event.detail.selectedRows;
        console.log('Prit: selectedItems:: '+this.selectedItems);
        if(this.selectedItems.length==0)
        {
            this.isDeleteDisabled=true;
        }
        else{
            this.isDeleteDisabled=false;
        }
    }

    //Action to perform on clicking delete button
    deleteInterviewer()
    {
        console.log('Prit: Delete interviewer details:: '+JSON.stringify(this.selectedItems));
        deleteInterviewerList(
            {interviewerList:this.selectedItems}
        )
        this.errorMessage ="Deletion Successful. Kindly refresh page to reload data.";
        this.openModal();
        this.isDeleteDisabled = true;
    }
    
}