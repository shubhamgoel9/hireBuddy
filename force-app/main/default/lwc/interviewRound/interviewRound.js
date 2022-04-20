import { LightningElement, wire, track , api } from "lwc";   
import getCandiateByRoundId from '@salesforce/apex/HireBuddyController.getCandiateByRoundId'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setFeedback from '@salesforce/apex/HireBuddyController.setFeedback';
import setStatusToInterviewing from '@salesforce/apex/HireBuddyController.setStatusToInterviewing';
import getInterviewerStatus from '@salesforce/apex/HireBuddyController.getInterviewerStatus';
import isInterviewer from '@salesforce/apex/HirebuddyController.isInterviewer';
import { removeNamespaceFromKeyInObject, addNamespaceForKeyInObject, namespace } from 'c/utility';
export default class InterviewRound extends LightningElement {
    @track searchKey; 
    @track accounts;
    @track feedback;
    @track theRecord = {};
    @track roundId;
    @track disableStatus = false;
    @track isInterviewer;
    @wire(getInterviewerStatus) currentStatus;


    //Method to set the Interviewer status to interviewing 
    setStatus(event) {

        setStatusToInterviewing({roundId:this.roundId})
        .then(result => {
            if(result){
                this.disableStatus = true;
            }
        })
        .catch(error => {
        }) 
    }

    //Method to set the feedback
    genericOnChange(event){
        this.theRecord[event.target.name] = event.target.value;

        this.feedback = event.target.value;

    }

    //Method to handle complete button event
    handleCompleted(event) { 
        setFeedback({roundId:this.roundId,feedback:this.feedback})
        .then(result => {
            if(result){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Round Completed!',
                        variant: 'success'
                    })
                );
            }
        })
        .catch(error => {
            new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error'
            })
        }) 
    }


    //Get All Event Items to display in dashboard
    parameters = {};
    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.roundId = this.parameters.c__recordId;
        isInterviewer()
        .then(result => {
            this.isInterviewer = result;
            getInterviewerStatus().then(result => {
                this.currentStatus = result;
                
                if (result == 'Interviewing') {
                    this.disableStatus = true;
                }
                else
                {
                    this.disableStatus = false;
                }
            }).catch(error => {
                this.error = error;
            }) 

            getCandiateByRoundId({roundId:this.roundId})
                .then(result => {
                
                    if(result != undefined)
                    {
                        var accountsData = result;
                        var tempList = []; 
                        for(const key in accountsData)
                        {
                            
                            tempList[key] = removeNamespaceFromKeyInObject(accountsData[key]);
                                
                        }
                    
                        result=tempList;
                    }
                this.accounts = result;
                
                
            })
            .catch(error => {
                this.error = error;
                this.eventItems = undefined;
            })
        })
        .catch(error => {
            this.error = error;
            this.isInterviewer = false;
        })
        
        if(this.isInterviewer)
        {
            
        }
        
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