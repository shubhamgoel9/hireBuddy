import { LightningElement, track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
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


    @api refresh() {
        console.log('Prit: refresh called. ');
        this.initializeComponent();
    }

    connectedCallback()
    {
        console.log('Connected callback..');
       this.initializeComponent();
    }

    async initializeComponent()
    {
        await isRecruiter()
        .then(result => {
            this.isRecruiter = result;
            console.log('Prit: isRecruiter: '+this.isRecruiter);
        })
        .catch(error => {
            this.error = error;
            this.isRecruiter = false;
        })
        if(this.isRecruiter)
        {
            await getAllInterviewerList()
            .then(result=>{
                this.allInterviewerList = [];
                console.log('Prit: Inside initialize: interviewerLIst: '+ JSON.stringify(result));
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

            await getPanelList()
            .then(result => {
                console.log('Prit: panel list result: '+JSON.stringify(result));
                this.panelList=result;
            })
            .catch(error => {
                console.log('Prit: panel list error: '+JSON.stringify(error));
                this.error = error;
                this.panelList = undefined;
            })
        }

        this.isDataEmpty = (!(this.userEmail && this.panelId));
    }

    //Method to load panelList dropdown
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
                    console.log('Prit: panelId found in panelList');
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
        console.log('Prit: isDataEmpty:'+this.isDataEmpty);
    }

    //method to get Interviewerlist from panel
    async getInterviewerListFromPanel()
    {
        console.log('Prit: Entered getInterviewerListFromPanel: ');
        await getInterviewerList({panelId:this.panelId})
		.then(result => {
            console.log('Prit: this.interviewerList result: '+JSON.stringify(result) + ' length: '+result.length);
            if(result.length > 0)
            {
                this.interviewerList=[];
                for(const key in result)
                {
                    this.interviewerList[key]=removeNamespaceFromKeyInObject(result[key]);
                    console.log('Prit: this.interviewerList[key]: '+JSON.stringify(this.interviewerList[key]));

                }
                this.isInterviewerList = true;
            }
            else
            {
                this.interviewerList=[];
                this.isInterviewerList = false;
            }
            console.log('Prit: this.interviewerList: '+JSON.stringify(this.interviewerList));
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
                //this.initializeComponent();
            })
            .catch(error => {
                console.log('error in assignment: '+JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Assigning Interviewer to Panel',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });

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
                console.log('error in assignment: '+JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Assigning Permission to Interviewer',
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

    async deleteInterviewer() {
        await deleteInterviewerList({interviewerList:this.selectedItems})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interviewer record deleted',
                        variant: 'success'
                    })
                );
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

        var selInterviewerList = this.selectedItems;
        for(const key in selInterviewerList)
        {
            this.selectedItems[key] = addNamespaceForKeyInObject(selInterviewerList[key]);
        }
        await removePermissionSet({interviewerList:this.selectedItems})
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
    }
    
}