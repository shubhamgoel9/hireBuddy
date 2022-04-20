import { LightningElement, wire, track , api } from "lwc";   
import getCandiateByRoundId from '@salesforce/apex/HireBuddyController.getCandiateByRoundId'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setFeedback from '@salesforce/apex/HireBuddyController.setFeedback';
import setStatusToInterviewing from '@salesforce/apex/HireBuddyController.setStatusToInterviewing';
import getInterviewerStatus from '@salesforce/apex/HireBuddyController.getInterviewerStatus';
import isInterviewer from '@salesforce/apex/HirebuddyController.isInterviewer';
import { removeNamespaceFromKeyInObject, addNamespaceForKeyInObject, namespace } from 'c/utility';
import {refreshApex} from '@salesforce/apex';
export default class InterviewRound extends LightningElement {
    @track searchKey; 
    //@wire(getCandiateByRoundId, { roundId: 'a018c00000SpSEMAA3' }) accounts;
   // @track roundId;
    @track accounts;
    @track feedback;
    @track theRecord = {};
    @track roundId;
    @track disableStatus = false;
    @track isInterviewer;
    @wire(getInterviewerStatus) currentStatus;


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

    genericOnChange(event){
        this.theRecord[event.target.name] = event.target.value;

        this.feedback = event.target.value;

    }
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
    async connectedCallback() {
        await isInterviewer()
        .then(result => {
            this.isInterviewer = result;
        })
        .catch(error => {
            this.error = error;
            this.isInterviewer = false;
        })

        this.parameters = this.getQueryParameters();
        this.roundId = this.parameters.c__recordId;
        
        if(this.isInterviewer)
        {
            await getInterviewerStatus().then(result => {
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

            await getCandiateByRoundId({roundId:this.roundId})
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