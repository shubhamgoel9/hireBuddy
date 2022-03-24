import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation' ;
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem';
import getProfile from '@salesforce/apex/EventItemsController.getProfile';
const columns = [
    { label: 'Candidate Name', fieldName: 'ResumeLink__c', type:'url', initialWidth: 100, 
    typeAttributes:{
        label: {
            fieldName: 'CandidateName__c'
        }
    }},
    { label: 'Role Evaluation', fieldName: 'RoleEvaluation__c', initialWidth: 100},
    { label: 'Candidate Status', fieldName: 'CandidateStatus__c', initialWidth: 100},
    { label: 'Codepair Link', fieldName: 'CodepairLink__c', type:'url', initialWidth: 80},
    { label: 'Interview Link', fieldName: 'InterviewLink__c', type:'url',initialWidth: 80},
    { label: 'R1 Start Time ', fieldName: 'R1StartTime__c',initialWidth: 100},
    { label: 'R1 Interviewer ', fieldName: 'R1Interviewer__c',initialWidth: 100},
    { label: 'R1 Proxy Interviewer ', fieldName: 'R1ProxyInterviewer__c',type:'email', initialWidth: 100},
    { label: 'R1 Observer ', fieldName: 'R1Observer__c',initialWidth: 100, type:'email'},
    { label: 'R1 Round Status', fieldName: 'R1RoundStatus__c',initialWidth: 100},
    { label: 'R1 SIFT Link', fieldName: 'R1SiftLink__c',type:'url', initialWidth: 100},
    { label: 'R1 Feedback ', fieldName: 'R1Feedback__c',initialWidth: 100},
    { label: 'R2 Start Time ', fieldName: 'R2StartTime__c',initialWidth: 100},
    { label: 'R2 Interviewer ', fieldName: 'R2Interviewer__c',initialWidth: 100},
    { label: 'R2 Proxy Interviewer ', fieldName: 'R2ProxyInterviewer__c',type:'email',initialWidth: 100},
    { label: 'R2 Observer ', fieldName: 'R2Observer__c',type:'email', initialWidth: 100},
    { label: 'R2 Round Status', fieldName: 'R2RoundStatus__c',initialWidth: 100},
    { label: 'R2 SIFT Link', fieldName: 'R2SiftLink__c',type:'url', initialWidth: 100},
    { label: 'R2 Feedback ', fieldName: 'R2Feedback__c',initialWidth: 100},
    { label: 'R3 Start Time ', fieldName: 'R3StartTime__c',initialWidth: 100},
    { label: 'R3 Interviewer ', fieldName: 'R3Interviewer__c',initialWidth: 100},
    { label: 'R3 Proxy Interviewer ', fieldName: 'R3ProxyInterviewer__c',type:'email', initialWidth: 100},
    { label: 'R3 Observer ', fieldName: 'R3Observer__c',type:'email', initialWidth: 100},
    { label: 'R3 Round Status', fieldName: 'R3RoundStatus__c',initialWidth: 100},
    { label: 'R3 SIFT Link', fieldName: 'R3SiftLink__c',type:'url', initialWidth: 100},
    { label: 'R3 Feedback ', fieldName: 'R3Feedback__c',initialWidth: 100}

];
export default class InterviewerEventDashboard extends NavigationMixin(LightningElement)
{
    columns = columns;
    @track selectedEventItemId;
    @track isModalOpen = false;
    @track isCandidateModalOpen = false;
    @track eventItemRecord;
    @track eventId;
    @track eventName;
    @track eventItems=[];
    @track panelId;
    
    @wire(getProfile) profileName;
    get isInterviewer()
    {
        console.log('Prit: profileName:: '+this.profileName.data);
        if(this.profileName.data === 'Interviewer')
            return true;
        else
            return false;
    }

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
            this.eventName = this.eventItems[0].CandidateId__r.HiringEventId__r.Name;
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
    
}