import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import assignInterviewerToPanel from '@salesforce/apex/InterviewerAssignmentService.assignInterviewerToPanel';
import getPanelList from '@salesforce/apex/InterviewerAssignmentService.getPanelList';
import getAllInterviewerList from '@salesforce/apex/InterviewerAssignmentService.getAllInterviewerList';
import assignPermissionSet from '@salesforce/apex/InterviewerAssignmentService.assignPermissionSet';
import removePermissionSet from '@salesforce/apex/InterviewerAssignmentService.removePermissionSet';
import deleteInterviewerList from '@salesforce/apex/EventItemsController.deleteInterviewerList';
import getInterviewerList from '@salesforce/apex/EventItemsController.getInterviewerList';
import isRecruiter from '@salesforce/apex/HirebuddyController.isRecruiter';
import {removeNamespaceFromKeyInObject, addNamespaceForKeyInObject,namespace} from 'c/utility';

const columns = [
    { label: 'Name', fieldName: 'InterviewerName__c', sortable: true, type:'text' },
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
    @track allInterviewerList = [];
    @track isModalOpen =false;
    @track errorMessage;
    @track isInterviewerList=false;
    @track isDataEmpty=true;
    @track error;
    @track isRecruiter;

    @track isDeleteDisabled=true;
    @track selectedInterviewerItem=null;

    connectedCallback()
    {
        isRecruiter()
        .then(result => {
            this.isRecruiter = result;
            if(this.isRecruiter)
            {
                this.initializeComponent();
            }
        })
        .catch(error => {
            this.error = error;
            this.isRecruiter = false;
        })
    }

    //initialize
    async initializeComponent()
    {
        //Method to get all of the interviewers assigned to all panels
        await getAllInterviewerList()
        .then(result=>{
            this.allInterviewerList = [];
            for(const key in result)
            {
                this.allInterviewerList[key]=removeNamespaceFromKeyInObject(result[key]);
            }
        })
        .catch(error => {
            this.error=error;
            this.allInterviewerList=undefined;
        })

        if(this.panelId) {
            this.getInterviewerListFromPanel();
        }

        //Method to get the list of panels
        await getPanelList()
        .then(result => {
            this.panelList=result;
        })
        .catch(error => {
            this.error = error;
            this.panelList = undefined;
        })

        this.isDataEmpty = (!(this.userEmail && this.panelId));
    }

    //Method to load panelList dropdown
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
        return picklistoptions;   
    }

    //handle the panel change dropdown event
    handleChange(event)
    {
        var value = event.target.value;

        if(event.target.dataset.id === 'panel')
        {
            this.panelId = value;
            for(const key in this.panelList)
            {
                if(this.panelList[key].Id === this.panelId)
                {
                    this.panelName = this.panelList[key].Name;
                    this.getInterviewerListFromPanel();
                }
            }
        }
        else if(event.target.dataset.id === 'userEmail')
        {
            this.userEmail = value;
        }
        this.isDataEmpty = (!(this.userEmail && this.panelId));
    }

    //method to get Interviewerlist from panel
    async getInterviewerListFromPanel()
    {
        await getInterviewerList({panelId:this.panelId})
		.then(result => {
            if(result.length > 0)
            {
                this.interviewerList=[];
                for(const key in result)
                {
                    this.interviewerList[key]=removeNamespaceFromKeyInObject(result[key]);

                }
                this.isInterviewerList = true;
            }
            else
            {
                this.interviewerList=[];
                this.isInterviewerList = false;
            }
		})
		.catch(error => {
			this.error = error;
			this.interviewerList = undefined;
		})
    }

    //Method to assign the interviewer to the panel and the interviewer permission set
    async assignInterviewer()
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
                        title: 'Interviewer already exists in '+this.allInterviewerList[key].PanelName__c+'!',
                        variant: 'error'
                    })
                );
                break;
            }
        }
        if (allValid) 
        {
            await assignInterviewerToPanel({userEmail:this.userEmail, panelId:this.panelId})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interviewer Assigned Successfully!',
                        variant: 'success'
                    })
                );
                //this.initializeComponent();
                assignPermissionSet({userEmail:this.userEmail})
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Permission Assigned Successfully!',
                            variant: 'success'
                        })
                    );
                    this.initializeComponent();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Assigning Permission to Interviewer',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Assigning Interviewer to Panel',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            this.userEmail=null;
            //this.panelId=null;
            this.isDataEmpty=true;
            //this.openModal();

        }
        
    }

    //Method to make delete Button enable/disabled based on the row select/unselect
    disableDeleteButton(event)
    {
        this.selectedItems=event.detail.selectedRows;
        if(this.selectedItems.length==0)
        {
            this.isDeleteDisabled=true;
        }
        else{
            this.isDeleteDisabled=false;
        }
    }

    //Method to delete the selected interviewers from panel and remove assigned permissionset
    async deleteInterviewer() {
        var selInterviewerList = this.selectedItems;
        for(const key in selInterviewerList)
        {
            this.selectedItems[key] = addNamespaceForKeyInObject(selInterviewerList[key]);
        }
        await deleteInterviewerList({interviewerList:this.selectedItems})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interviewer record deleted',
                        variant: 'success'
                    })
                );
                removePermissionSet({interviewerList:this.selectedItems})
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Interviewer permission removed',
                            variant: 'success'
                        })
                    );
                    this.initializeComponent();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error removing Interviewer permission.',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting Interviewer record.',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }
        );
    }
    
}