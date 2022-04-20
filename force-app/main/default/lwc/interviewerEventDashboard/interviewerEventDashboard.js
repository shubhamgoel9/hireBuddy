import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation' ;
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem';
import getEventName from '@salesforce/apex/EventItemsController.getEventName';
import {removeNamespaceFromKeyInObject, addNamespaceForKeyInObject,namespace} from 'c/utility';

const columns = [
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
export default class InterviewerEventDashboard extends NavigationMixin(LightningElement)
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
    
    //Get All Event Items to display in dashboard
    parameters = {};
    connectedCallback() {
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
        
        getAllEventItems({eventId:this.eventId})
		.then(result => {
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