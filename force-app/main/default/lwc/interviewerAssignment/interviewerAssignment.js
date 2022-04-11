import { LightningElement, track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import assignInterviewerToPanel from '@salesforce/apex/InterviewerAssignmentService.assignInterviewerToPanel';
import getPanelList from '@salesforce/apex/InterviewerAssignmentService.getPanelList';
import getAllInterviewerList from '@salesforce/apex/InterviewerAssignmentService.getAllInterviewerList';
import deleteInterviewerList from '@salesforce/apex/EventItemsController.deleteInterviewerList';
const columns = [
    { label: 'Name', fieldName: 'InterviewerName__c', type:'text' },
    { label: 'Email', fieldName: 'InterviewerEmail__c', type:'email' },
    { label: 'Panel', fieldName: 'PanelName__c', type:'text'}
];
export default class InterviewerAssignment extends LightningElement {
    columns=columns;
    @track userEmail;
    @track panelId;
    @track panelName;
    @track panelList;
    @track interviewerList=[];
    @track isModalOpen =false;
    @track errorMessage;
    @track isInterviewerList=false;
    @track isDataEmpty=true;
    @track error;


    @api refresh() {
        console.log('Prit: refresh called. ');
        this.initializeComponent();
    }

    @wire(getAllInterviewerList)
    wiredResult(result){
        this.refreshTable =result;
        if(result.data)
        {
            this.allInterviewerList = result.data;
            this.isInterviewerList = true;
            this.error = undefined;
        }
        
        else if (result.error) 
        {
            this.error = result.error;
            this.allInterviewerList = undefined;
        }
    }
    handleClick() {
        console.log('Prit: refreshtable:: '+JSON.stringify(this.refreshTable));
        refreshApex(this.refreshTable);
        return this.refresh();
    }

    connectedCallback()
    {
       this.initializeComponent();
    }

    initializeComponent()
    {
        /*getAllInterviewerList()
        .then(result=>{
            console.log('Prit: Inside initialize: interviewerLIst: '+ JSON.stringify(result));
            this.allInterviewerList=result;
        })
        .catch(error => {
            this.error=error;
            this.allInterviewerList=undefined;
        })*/

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
        console.log('Prit: this.panelList:: '+JSON.stringify(this.panelList));
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
        }
        else if(event.target.dataset.id === 'userEmail')
        {
            this.userEmail = value;
        }
        this.isDataEmpty = (!(this.userEmail && this.panelId));
        console.log('Prit: isDataEmpty:'+this.isDataEmpty);
    }

    //method to get Interviewerlist from panel
    /*getInterviewerListFromPanel()
    {
        for(const key in this.allInterviewerList)
        {
            console.log('Prit: slected panel:: '+this.panelId);
            console.log('Prit: current interviewer panel in loop:: '+this.allInterviewerList[key].Panel__c);
            if(this.allInterviewerList[key].Panel__c == this.panelId)
            {
                console.log('Prit: before push:: '+ JSON.stringify(this.allInterviewerList[key]));
                this.interviewerList.push(this.allInterviewerList[key]);
                console.log('Prit: after push:: '+ JSON.stringify(this.interviewerList));
            }
        }*/
        /*getInterviewerList({panelId:this.panelId})
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
    }*/

    assignInterviewer()
    {
        var allValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);

        for(const key in this.allInterviewerList)
        {
            if(this.allInterviewerList[key].InterviewerEmail__c === this.userEmail)
            {
                allValid = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Interviewer already exists!',
                        variant: 'error'
                    })
                );
                break;
            }
        }
        if (allValid) 
        {
            assignInterviewerToPanel({userEmail:this.userEmail, panelId:this.panelId})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interviewer Assigned Successfully!',
                        variant: 'success'
                    })
                );
                console.log('Prit: result: '+JSON.stringify(result));
                this.allInterviewerList=[...this.allInterviewerList,result];
                this.refreshTable.data=this.allInterviewerList;
                console.log('Prit: new interviewerList'+ JSON.stringify(this.allInterviewerList));

            })
            .catch(error => {
                console.log('error in assignment: '+JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Assigning Interviewer to Panel',
                        message: JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });
            this.userEmail=null;
            this.panelId=null;
            this.isDataEmpty=true;
            //this.openModal();

        }
        
    }

    /*openModal()
    {
        this.isModalOpen = true;
        console.log('Prit: isModalOpen:: '+this.isModalOpen);

    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.refreshData();
    }*/

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
    /*deleteInterviewer()
    {
        console.log('Prit: Delete interviewer details:: '+JSON.stringify(this.selectedItems));
        deleteInterviewerList(
            {interviewerList:this.selectedItems}
        )
        this.errorMessage ="Deletion Successful!";
        this.openModal();
        this.isDeleteDisabled = true;
    }*/

    deleteInterviewer() {
        deleteInterviewerList({interviewerList:this.selectedItems})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interviewer record deleted',
                        variant: 'success'
                    })
                );
                for(const key in this.selectedItems)
                {
                    this.allInterviewerList = this.allInterviewerList.filter(value => value !== this.selectedItems[key]);
                }
                this.refreshTable.data=this.allInterviewerList;
                this.refresh();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting Interviewer record.',
                        message: error.data,
                        variant: 'error'
                    })
                );
            });
    }
    
}