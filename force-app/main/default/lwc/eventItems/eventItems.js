import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation' ;
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem';
import setEventItem from '@salesforce/apex/EventItemsController.setEventItem';
import setNewCandidateDetails from '@salesforce/apex/EventItemsController.setNewCandidateDetails';
const columns = [
    { label: 'Candidate Name', fieldName: 'hirebuddy__CandidateName__c', initialWidth: 150 },
    { label: 'Role Evaluation', fieldName: 'hirebuddy__RoleEvaluation__c', initialWidth: 100},
    { label: 'Candidate Status', fieldName: 'hirebuddy__CandidateStatus__c', initialWidth: 100},
    { label: 'Codepair Link', fieldName: 'hirebuddy__CodepairLink__c', type:'url', initialWidth: 80},
    { label: 'Interview Link', fieldName: 'hirebuddy__InterviewLink__c', type:'url',initialWidth: 80},
    { label: 'R1 Start Time ', fieldName: 'hirebuddy__R1StartTime__c',initialWidth: 100},
    { label: 'R1 Interviewer ', fieldName: 'hirebuddy__R1Interviewer__c',initialWidth: 100},
    { label: 'R1 Observer ', fieldName: 'hirebuddy__R1Observer__c',initialWidth: 100},
    { label: 'R1 Round Status', fieldName: 'hirebuddy__R1RoundStatus__c',initialWidth: 100},
    { label: 'R1 SIFT Link', fieldName: 'hirebuddy__R1SiftLink__c',type:'url', initialWidth: 100},
    { label: 'R1 Feedback ', fieldName: 'hirebuddy__R1Feedback__c',initialWidth: 100},
    { label: 'R2 Start Time ', fieldName: 'hirebuddy__R2StartTime__c',initialWidth: 100},
    { label: 'R2 Interviewer ', fieldName: 'hirebuddy__R2Interviewer__c',initialWidth: 100},
    { label: 'R2 Observer ', fieldName: 'hirebuddy__R2Observer__c',initialWidth: 100},
    { label: 'R2 Round Status', fieldName: 'hirebuddy__R2RoundStatus__c',initialWidth: 100},
    { label: 'R2 SIFT Link', fieldName: 'hirebuddy__R2SiftLink__c',type:'url', initialWidth: 100},
    { label: 'R2 Feedback ', fieldName: 'hirebuddy__R2Feedback__c',initialWidth: 100},
    { label: 'R3 Start Time ', fieldName: 'hirebuddy__R3StartTime__c',initialWidth: 100},
    { label: 'R3 Interviewer ', fieldName: 'hirebuddy__R3Interviewer__c',initialWidth: 100},
    { label: 'R3 Observer ', fieldName: 'hirebuddy__R3Observer__c',initialWidth: 100},
    { label: 'R3 Round Status', fieldName: 'hirebuddy__R3RoundStatus__c',initialWidth: 100},
    { label: 'R3 SIFT Link', fieldName: 'hirebuddy__R3SiftLink__c',type:'url', initialWidth: 100},
    { label: 'R3 Feedback ', fieldName: 'hirebuddy__R3Feedback__c',initialWidth: 100},
    {type: "button", intialWidht: 80,typeAttributes: {  
        label: 'Edit',  
        name: 'Edit',  
        title: 'Edit',  
        disabled: false,  
        value: 'edit',  
        iconPosition: 'left'  
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
    @track eventItems=[];
    //@wire(getAllEventItems, {eventId: '$eventId'}) eventItems;
    
    //Get All Event Items to display in dashboard
    parameters = {};
    connectedCallback() {
        this.parameters = this.getQueryParameters();
        console.log('prit parameter : ' + JSON.stringify(this.parameters));
        console.log('prit c__recordId : ' + JSON.stringify(this.parameters.c__recordId));
        this.eventId = this.parameters.c__recordId;

        getAllEventItems({eventId:this.eventId})
		.then(result => {
			this.eventItems = result;
            console.log('Prit: eventItems : '+JSON.stringify(this.eventItems));
            this.eventName = this.eventItems[0].hirebuddy__CandidateId__r.hirebuddy__HiringEventId__r.Name;
            console.log('Prit: eventName:: '+ this.eventName);
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.eventItems = undefined;
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

    //Action to perfrom when modal box is opened
    openModal(event) {
        // to open modal set isModalOpen tarck value as true
        console.log('Prit: openModal entry:: event : '+JSON.stringify(event));
        const actionName = event.detail.action.name;
        console.log('actionName: '+actionName);
        if ( actionName === 'Edit' ) {
            this.isModalOpen = true;
            this.selectedEventItemId=event.detail.row.Id;
            console.log('Prit: eventItems:: '+JSON.stringify(this.eventItems));
            for (const key in this.eventItems) {
                if(this.eventItems[key].Id === this.selectedEventItemId);
                {
                    this.eventItemRecord = this.eventItems[key];
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

    @track candidateStatus;
    @track R1Interviewer;
    @track R1Observer;
    @track R1Time;
    @track R1Sift;
    @track R1Feedback;

    //method to set the selected values in the Modify Candidate Modal box
    handleChange(event) {
        var value = event.target.value;
        console.log('enter handle change::'+value);

        if(event.target.dataset.id === 'candidateStatus')
        {
            this.candidateStatus = value;
            console.log('handle change candidateStatus::'+value);
        }
        else if(event.target.dataset.id === 'R1Interviewer')
        {
            this.R1Interviewer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R1Observer')
        {
            this.R1Observer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R1Time')
        {
            this.R1Time = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R1Feedback')
        {
            this.R1Feedback = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R2Interviewer')
        {
            this.R2Interviewer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R2Observer')
        {
            this.R2Observer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R2Time')
        {
            this.R2Time = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R2Feedback')
        {
            this.R2Feedback = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R3Interviewer')
        {
            this.R3Interviewer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R3Observer')
        {
            this.R3Observer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R3Time')
        {
            this.R3Time = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R3Feedback')
        {
            this.R3Feedback = value;
            console.log('handle change::'+value);
        }
    }
    
    //Action to perform on clicking SAVE on EDIT Modal
    submitDetails() {
        console.log('PP: inside submitDetails: selectedEventItemId::'+this.selectedEventItemId);
        // to close modal set isModalOpen tarck value as false
        //update Event Item Record
        setEventItem({selectedEventItemId:this.selectedEventItemId,
            candidateStatus:this.candidateStatus,
            R1Interviewer:this.R1Interviewer,
            R1Observer:this.R1Observer,
            R1Time:this.R1Time,
            R1Sift:this.R1Sift,
            R1Feedback:this.R1Feedback,
            R2Interviewer:this.R2Interviewer,
            R2Observer:this.R2Observer,
            R2Time:this.R2Time,
            R2Sift:this.R2Sift,
            R2Feedback:this.R2Feedback,
            R3Interviewer:this.R3Interviewer,
            R3Observer:this.R3Observer,
            R3Time:this.R3Time,
            R3Sift:this.R3Sift,
            R3Feedback:this.R3Feedback
        })
        
        window.location.reload();
        this.isModalOpen = false;
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
    @track newCandidateName;
    @track newCandidateEmail;
    @track newCandidateContact;
    @track newCandidateResume;
    @track newCandidateRoleEvaluation;
    @track newCandidateInterviewLink;
    @track newCandidateCodePairLink;
    //handle new candidate details change
    handleNewCandidateChange(event){
        var value = event.target.value;
        console.log('enter handle change::'+value);

        if(event.target.dataset.id === 'newCandidateName')
        {
            this.newCandidateName = value;
            console.log('handle change newCandidateName::'+value);
        }
        if(event.target.dataset.id === 'newCandidateEmail')
        {
            this.newCandidateEmail = value;
            console.log('handle change newCandidateEmail::'+value);
        }
        if(event.target.dataset.id === 'newCandidateContact')
        {
            this.newCandidateContact = value;
            console.log('handle change newCandidateContact::'+value);
        }
        if(event.target.dataset.id === 'newCandidateResume')
        {
            this.newCandidateResume = value;
            console.log('handle change newCandidateResume::'+value);
        }
        if(event.target.dataset.id === 'newCandidateRoleEvaluation')
        {
            this.newCandidateRoleEvaluation = value;
            console.log('handle change newCandidateRoleEvaluation::'+value);
        }
        if(event.target.dataset.id === 'newCandidateInterviewLink')
        {
            this.newCandidateInterviewLink = value;
            console.log('handle change newCandidateInterviewLink::'+value);
        }
        if(event.target.dataset.id === 'newCandidateCodePairLink')
        {
            this.newCandidateCodePairLink = value;
            console.log('handle change newCandidateCodePairLink::'+value);
        }

    }
    //Action to perform on clicking SAVE on Add New Candidate Modal
    submitNewCandidateDetails(){
        console.log('Prit: saving new candidate details:: ');
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
        window.location.reload();
        this.isCandidateModalOpen = false;
    }
    
    
}