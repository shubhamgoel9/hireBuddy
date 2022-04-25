import { LightningElement, wire, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation' ;
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem';
import setEventItem from '@salesforce/apex/EventItemsController.setEventItem';
import setNewCandidateDetails from '@salesforce/apex/EventItemsController.setNewCandidateDetails';
import deleteCandidateDetails from '@salesforce/apex/EventItemsController.deleteCandidateDetails';
import getInterviewerList from '@salesforce/apex/EventItemsController.getInterviewerList';
import getPanelId from '@salesforce/apex/EventItemsController.getPanelId';
import getEventName from '@salesforce/apex/EventItemsController.getEventName';
import isRecruiter from '@salesforce/apex/HirebuddyController.isRecruiter';
import {removeNamespaceFromKeyInObject, addNamespaceForKeyInObject,namespace} from 'c/utility';

const columns = [
    {label: 'Action', type: "button", initialWidth: 80, typeAttributes: {
        label: 'Edit',  
        name: 'Edit',  
        title: 'Edit',  
        disabled: false,  
        value: 'edit',  
        iconPosition: 'left',
        brand:'variant'  
    }},
    { label: 'Candidate Name', sortable: true, fieldName: 'ResumeLink__c', type:'url', initialWidth: 100, 
        typeAttributes:{
            label: {
            fieldName: 'CandidateName__c'
            }
        },
    },
    { label: 'Role Evaluation', fieldName: 'RoleEvaluation__c', initialWidth: 100},
    { label: 'Candidate Status', fieldName: 'CandidateStatus__c', initialWidth: 100},
    { label: 'Codepair Link', fieldName: 'CodepairLink__c', type:'url', initialWidth: 80},
    { label: 'Interview Link', fieldName: 'InterviewLink__c', type:'url',initialWidth: 80},
    { label: 'R1 Start Time ', fieldName: 'R1StartTime__c',initialWidth: 130, type:'date', 
        typeAttributes: {
            year:'2-digit', month:"short", day:"2-digit", hour:"numeric", minute:"2-digit", timezone:"IST"
        },
        cellAttributes: {
            style: {fieldName:'r1RoundColor'},
        }
    },
    { label: 'R1 Interviewer ', fieldName: 'R1Interviewer__c',initialWidth: 100 ,
        cellAttributes: {
        style:  {fieldName:'r1RoundColor'} 
    }
    },
    { label: 'R1 Proxy Interviewer ', fieldName: 'R1ProxyInterviewer__c',type:'email', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r1RoundColor'} 
    }},
    { label: 'R1 Observer ', fieldName: 'R1Observer__c',initialWidth: 100, type:'email', cellAttributes: {
        style:  {fieldName:'r1RoundColor'} 
    }},
    { label: 'R1 Round Status', fieldName: 'R1RoundStatus__c',initialWidth: 100,
        cellAttributes: {
            style:  {fieldName:'r1RoundColor'} 
        }
    },
    { label: 'R1 SIFT Link', fieldName: 'R1SiftLink__c',type:'url', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r1RoundColor'} 
    }},
    { label: 'R1 Feedback ', fieldName: 'R1Feedback__c',initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r1RoundColor'} 
    }},
    { label: 'R2 Start Time ', fieldName: 'R2StartTime__c',initialWidth: 130, type:'date', 
        typeAttributes: {
            year:'2-digit', month:"short", day:"2-digit", hour:"numeric", minute:"2-digit", timezone:"IST"
        },
        cellAttributes: {
            style:  {fieldName:'r2RoundColor'} 
        }
    },
    { label: 'R2 Interviewer ', fieldName: 'R2Interviewer__c',initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r2RoundColor'} 
    }},
    { label: 'R2 Proxy Interviewer ', fieldName: 'R2ProxyInterviewer__c',type:'email',initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r2RoundColor'} 
    }},
    { label: 'R2 Observer ', fieldName: 'R2Observer__c',type:'email', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r2RoundColor'} 
    }},
    { label: 'R2 Round Status', fieldName: 'R2RoundStatus__c',initialWidth: 100,
        cellAttributes: {
            style:  {fieldName:'r2RoundColor'}
        }
    },
    { label: 'R2 SIFT Link', fieldName: 'R2SiftLink__c',type:'url', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r2RoundColor'} 
    }},
    { label: 'R2 Feedback ', fieldName: 'R2Feedback__c',initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r2RoundColor'} 
    }},
    { label: 'R3 Start Time ', fieldName: 'R3StartTime__c',initialWidth: 130, type:'date', 
        typeAttributes: {
            year:'2-digit', month:"short", day:"2-digit", hour:"numeric", minute:"2-digit", timezone:"IST"
        },
        cellAttributes: {
            style:  {fieldName:'r3RoundColor'} 
        }
    },
    { label: 'R3 Interviewer ', fieldName: 'R3Interviewer__c',initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r3RoundColor'} 
    }},
    { label: 'R3 Proxy Interviewer ', fieldName: 'R3ProxyInterviewer__c',type:'email', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r3RoundColor'} 
    }},
    { label: 'R3 Observer ', fieldName: 'R3Observer__c',type:'email', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r3RoundColor'} 
    }},
    { label: 'R3 Round Status', fieldName: 'R3RoundStatus__c',initialWidth: 100,
        cellAttributes: {
            style:  {fieldName:'r3RoundColor'}
        }
    },
    { label: 'R3 SIFT Link', fieldName: 'R3SiftLink__c',type:'url', initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r3RoundColor'} 
    }},
    { label: 'R3 Feedback ', fieldName: 'R3Feedback__c',initialWidth: 100, cellAttributes: {
        style:  {fieldName:'r3RoundColor'} 
    }}

];
export default class EventItems extends NavigationMixin(LightningElement)
{
    columns = columns;
    @track selectedEventItemId;
    @track isModalOpen = false;
    @track isCandidateModalOpen = false;
    @track eventItemRecord;
    @track eventId;
    @track eventName;
    @track eventItems;
    @track panelId;
    @track interviewerList = [];
    @track isRecruiter = false;

    @track disableR1ProxyInterviewer;
    @track disableR2ProxyInterviewer;
    @track disableR3ProxyInterviewer;
    
    //Variables for modify candidate modal box
    @track candidateStatus;
    @track codepairLink;
    @track interviewLink;
    @track R1InterviewerEmail;
    @track R1ProxyInterviewer;
    @track R1Observer;
    @track R1Time;
    @track R1Sift;
    @track R1Feedback;
    @track R2InterviewerEmail;
    @track R2Observer;
    @track R2Time;
    @track R2Sift;
    @track R2Feedback;
    @track R3InterviewerEmail;
    @track R3Observer;
    @track R3Time;
    @track R3Sift;
    @track R3Feedback;
    @track isR1TimeRequired;
    @track isR2TimeRequired;
    @track isR3TimeRequired;

    //Variables for new Candidate details
    @track newCandidateName;
    @track newCandidateEmail;
    @track newCandidateContact;
    @track newCandidateResume;
    @track newCandidateRoleEvaluation;
    @track newCandidateInterviewLink;
    @track newCandidateCodePairLink;

    //variables for disableDeleteButton
    @track isDeleteCandidateDisabled=true;
    @track selectedEventItems=null;

    parameters = {};

    initializeComponent()
    {
        //Get All Event Items to display in dashboard
        getAllEventItems({eventId:this.eventId})
		.then(result => {
            if(result != undefined && result.length>0)
			{
                this.eventItems = result;
            }
            else
            {
                this.eventItems = false;
                return;
            }
			this.error = undefined;
            this.eventItems = result.map(item=>{
                item = removeNamespaceFromKeyInObject(item);
                let r1RoundColor 
                let r2RoundColor 
                let r3RoundColor 
                let completedColor = "background-color: #C1E1C1;"
                let inProgressColor = "background-color: #FFE4B5;"
                if(item.R1RoundStatus__c == 'Completed')
                {
                    r1RoundColor =  completedColor;
                } 
                else if(item.R1RoundStatus__c == 'In Progress')
                {
                    r1RoundColor = inProgressColor;
                }
                if(item.R2RoundStatus__c == 'Completed')
                {
                    r2RoundColor =  completedColor;
                } 
                else if(item.R2RoundStatus__c == 'In Progress')
                {
                    r2RoundColor = inProgressColor;
                }
                if(item.R3RoundStatus__c == 'Completed')
                {
                    r3RoundColor =  completedColor;
                } 
                else if(item.R3RoundStatus__c == 'In Progress')
                {
                    r3RoundColor = inProgressColor;
                }

                return {...item, 
                    "r1RoundColor":r1RoundColor,
                    "r2RoundColor":r2RoundColor,
                    "r3RoundColor":r3RoundColor
                }
            })
		})
		.catch(error => {
			this.error = error;
			this.eventItems = undefined;
		})

        getPanelId({eventId:this.eventId})
		.then(result => {
			this.panelId = result;
            this.getInterviewerListFromPanel();
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.panelId = undefined;
		})

    }

    connectedCallback() {
        isRecruiter()
        .then(result => {
            this.isRecruiter = result;
            this.parameters = this.getQueryParameters();
            this.eventId = this.parameters.c__recordId;

            getEventName({eventId:this.eventId})
            .then(result => {
                this.eventName = result;
            })
            .catch(error => {
                this.error = error;
                this.eventName = undefined;
            })

            this.initializeComponent();
        })
        .catch(error => {
            this.error = error;
            this.isRecruiter = false;
        })
        
    }
    
    //method to recieve query parameters from the calling page
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    //method to get Interviewerlist from panel
    getInterviewerListFromPanel()
    {
        getInterviewerList({panelId:this.panelId})
		.then(result => {
            for(const key in result)
            {
                this.interviewerList[key] = removeNamespaceFromKeyInObject(result[key]);
            }
		})
		.catch(error => {
			this.error = error;
			this.interviewerList = undefined;
		})
    }
    
    //Action to perfrom when modal box is opened
    openModal(event) {
        if(this.isInterviewer)
        {
            alert('You are not authorized to perform this action');
            this.isModalOpen = false;
            return;
        }
        const actionName = event.detail.action.name;
        if ( actionName === 'Edit' ) {
            this.isModalOpen = true;
            this.selectedEventItemId=event.detail.row.Id;
            for (const key in this.eventItems) {

                if(this.eventItems[key].Id === this.selectedEventItemId)
                {
                    this.eventItemRecord = this.eventItems[key];
                    if(this.eventItemRecord.R1InterviewerEmail__c)
                    {
                        this.disableR1ProxyInterviewer = true;
                    }
                    else
                    {
                        this.disableR1ProxyInterviewer = false;
                    }
                    if(this.eventItemRecord.R2InterviewerEmail__c)
                    {
                        this.disableR2ProxyInterviewer = true;
                    }
                    else
                    {
                        this.disableR2ProxyInterviewer = false;
                    }
                    if(this.eventItemRecord.R3InterviewerEmail__c)
                    {
                        this.disableR3ProxyInterviewer = true;
                    }
                    else
                    {
                        this.disableR3ProxyInterviewer = false;
                    }
                    break;
                }
            } 
        }          
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.isCandidateModalOpen = false;
        this.selectedEventItemId = '';
        this.eventItemRecord='';
    }

    //method to get the combo box values for candidateStatus to be used in Modal box
    get candidateStatusOptions()
    {
        return [
            { label: 'Loop Cut', value: 'Loop Cut' },
            { label: 'Internet Issue', value: 'Internet Issue' },
            { label: 'No Show', value: 'No Show' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Completed', value: 'Completed' },
            { label: 'Time Break', value: 'Time Break' },

        ];
    }

    //method to get the interviewer list options in combo-box based on panel
    get interviewerListOptions()
    {
        let picklistoptions = [{label:'---None---',value:'None'},{label:'Proxy Interviewer',value:'Proxy'}];
        if(this.interviewerList)
        {
            for(const key in this.interviewerList)
            {
                picklistoptions.push({
                    label:this.interviewerList[key].InterviewerName__c+' ('+this.interviewerList[key].InterviewerStatus__c+')',
                    value:this.interviewerList[key].InterviewerEmail__c
                });
            }
        }
        return picklistoptions;
            
    }

    //method to set the selected values in the Modify Candidate Modal box
    handleChange(event) {
        var value = event.target.value;

        if(event.target.dataset.id === 'candidateStatus')
        {
            this.candidateStatus = value;
        }
        else if(event.target.dataset.id === 'codepairLink')
        {
            this.codepairLink = value;
        }
        else if(event.target.dataset.id === 'interviewLink')
        {
            this.interviewLink = value;
        }
        else if(event.target.dataset.id === 'R1Interviewer')
        {
            if(value === 'Proxy')
            {
                this.disableR1ProxyInterviewer=false;
            }
            else
            {
                this.disableR1ProxyInterviewer=true;
            }
            this.R1InterviewerEmail = value;
            if(value === 'None')
            {
                this.isR1TimeRequired=false;
            }
            else
            {
                this.isR1TimeRequired=true;
            }
        }
        else if(event.target.dataset.id === 'R1ProxyInterviewer')
        {
            this.R1ProxyInterviewer = value;
        }
        else if(event.target.dataset.id === 'R1Observer')
        {
            this.R1Observer = value;
            this.isR1TimeRequired = true;
        }
        else if(event.target.dataset.id === 'R1Time')
        {
            this.R1Time = value;
        }
        else if(event.target.dataset.id === 'R1Sift')
        {
            this.R1Sift = value;
        }
        else if(event.target.dataset.id === 'R1Feedback')
        {
            this.R1Feedback = value;
        }
        else if(event.target.dataset.id === 'R2Interviewer')
        {
            if(value === 'Proxy')
            {
                this.disableR2ProxyInterviewer=false;
            }
            else
            {
                this.disableR2ProxyInterviewer=true;
            }
            this.R2InterviewerEmail = value;
            if(value === 'None')
            {
                this.isR2TimeRequired=false;
            }
            else
            {
                this.isR2TimeRequired=true;
            }
        }
        else if(event.target.dataset.id === 'R2ProxyInterviewer')
        {
            this.R2ProxyInterviewer = value;
        }
        else if(event.target.dataset.id === 'R2Observer')
        {
            this.R2Observer = value;
        }
        else if(event.target.dataset.id === 'R2Time')
        {
            this.R2Time = value;
        }
        else if(event.target.dataset.id === 'R2Sift')
        {
            this.R2Sift = value;
        }
        else if(event.target.dataset.id === 'R2Feedback')
        {
            this.R2Feedback = value;
        }
        else if(event.target.dataset.id === 'R3Interviewer')
        {
            if(value === 'Proxy')
            {
                this.disableR3ProxyInterviewer=false;
            }
            else
            {
                this.disableR3ProxyInterviewer=true;
            }
            this.R3InterviewerEmail = value;
            if(value === 'None')
            {
                this.isR3TimeRequired=false;
            }
            else
            {
                this.isR3TimeRequired=true;
            }
        }
        else if(event.target.dataset.id === 'R3ProxyInterviewer')
        {
            this.R3ProxyInterviewer = value;
        }
        else if(event.target.dataset.id === 'R3Observer')
        {
            this.R3Observer = value;
        }
        else if(event.target.dataset.id === 'R3Time')
        {
            this.R3Time = value;
        }
        else if(event.target.dataset.id === 'R3Sift')
        {
            this.R3Sift = value;
        }
        else if(event.target.dataset.id === 'R3Feedback')
        {
            this.R3Feedback = value;
        }
    }
    
    //Action to perform on clicking SAVE on EDIT Modal
    submitDetails() {
        //update Event Item Record
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) 
        {    
            setEventItem({selectedEventItemId:this.selectedEventItemId,
                candidateStatus:this.candidateStatus,
                interviewLink:this.interviewLink,
                codepairLink:this.codepairLink,
                R1InterviewerEmail:this.R1InterviewerEmail,
                R1ProxyInterviewer:this.R1ProxyInterviewer,
                R1Observer:this.R1Observer,
                R1Time:this.R1Time,
                R1Sift:this.R1Sift,
                R1Feedback:this.R1Feedback,
                R2InterviewerEmail:this.R2InterviewerEmail,
                R2ProxyInterviewer:this.R2ProxyInterviewer,
                R2Observer:this.R2Observer,
                R2Time:this.R2Time,
                R2Sift:this.R2Sift,
                R2Feedback:this.R2Feedback,
                R3InterviewerEmail:this.R3InterviewerEmail,
                R3ProxyInterviewer:this.R3ProxyInterviewer,
                R3Observer:this.R3Observer,
                R3Time:this.R3Time,
                R3Sift:this.R3Sift,
                R3Feedback:this.R3Feedback
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Candidate Record Modfied Successfully!',
                        variant: 'success'
                    })
                );
                this.isModalOpen = false;
                this.initializeComponent();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Modify Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
        else
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required fields missing',
                    message: '',
                    variant: 'error'
                })
            );

        }
    }

    //Add New Candidate Button onlick event to open candidateModal
    openCandidateModal(){
        this.isCandidateModalOpen = true;
    }

    //method to get the combo box values for new candidate role evaluation to be used in Modal box
    get candidateRoleOptions()
    {
        return [
            { label: 'AMTS', value: 'AMTS' },
            { label: 'MTS', value: 'MTS' },
            { label: 'SMTS', value: 'SMTS' },
            { label: 'LMTS', value: 'LMTS' },
            
        ];
    }
    
    //handle new candidate details change
    handleNewCandidateChange(event){
        var value = event.target.value;

        if(event.target.dataset.id === 'newCandidateName')
        {
            this.newCandidateName = value;
        }
        if(event.target.dataset.id === 'newCandidateEmail')
        {
            this.newCandidateEmail = value;
        }
        if(event.target.dataset.id === 'newCandidateContact')
        {
            this.newCandidateContact = value;
        }
        if(event.target.dataset.id === 'newCandidateResume')
        {
            this.newCandidateResume = value;
        }
        if(event.target.dataset.id === 'newCandidateRoleEvaluation')
        {
            this.newCandidateRoleEvaluation = value;
        }
        if(event.target.dataset.id === 'newCandidateInterviewLink')
        {
            this.newCandidateInterviewLink = value;
        }
        if(event.target.dataset.id === 'newCandidateCodePairLink')
        {
            this.newCandidateCodePairLink = value;
        }

    }
    //Action to perform on clicking SAVE on Add New Candidate Modal
    submitNewCandidateDetails(event){

        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) 
        {
            setNewCandidateDetails(
                {
                    eventId:this.eventId,
                    newCandidateName:this.newCandidateName,
                    newCandidateEmail:this.newCandidateEmail,
                    newCandidateContact:this.newCandidateContact,
                    newCandidateResume:this.newCandidateResume,
                    newCandidateRoleEvaluation:this.newCandidateRoleEvaluation,
                    newCandidateInterviewLink:this.newCandidateInterviewLink,
                    newCandidateCodePairLink:this.newCandidateCodePairLink
                }
            )
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Candidate record created Successfully!',
                        variant: 'success'
                    })
                );
                this.isCandidateModalOpen = false;
                this.initializeComponent();
    
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Candidate record.',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
            //window.location.reload();
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required fields missing',
                    message: '',
                    variant: 'error'
                })
            );
        }
    }

    //Method to make delete Button enable/disabled based on the row select/unselect
    disableDeleteButton(event)
    {
        this.selectedEventItems=event.detail.selectedRows;
        if(this.selectedEventItems.length==0)//|| this.profileName.data === 'Interviewer')
        {
            this.isDeleteCandidateDisabled=true;
        }
        else{
            this.isDeleteCandidateDisabled=false;
        }
    }

    //Action to perform on clicking delete button
    deleteCandidate()
    {
        var eventItemsList = this.selectedEventItems
        for(const key in eventItemsList)
        {
            this.selectedEventItems[key] = addNamespaceForKeyInObject(eventItemsList[key]);
        }
        deleteCandidateDetails({selectedEventItems:this.selectedEventItems})
        .then( () => 
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Candidate record deleted successfully!',
                    variant: 'success'
                })
            );
            this.isDeleteCandidateDisabled = true;
            this.initializeComponent();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting Candidate record.',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
    
    
}