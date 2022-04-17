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

        console.log( ' roundId ' + this.roundId);
        setStatusToInterviewing({roundId:this.roundId})
        .then(result => {
            if(result){
                console.log('setStatusToInterviewing: '+result);
                this.disableStatus = true;
            }
        })
        .catch(error => {
            console.log('Error: ', error);
        }) 
    }

    genericOnChange(event){
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);

        this.feedback = event.target.value;
        console.log(  ' feedback ' + this.feedback);

    }
    handleCompleted(event) { 
        setFeedback({roundId:this.roundId,feedback:this.feedback})
        .then(result => {
            if(result){
                console.log(result);
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
            console.log('Error: ', error);
        }) 
    }


    //Get All Event Items to display in dashboard
    parameters = {};
    async connectedCallback() {
        await isInterviewer()
        .then(result => {
            this.isInterviewer = result;
            console.log('Prit: isInterviewer: '+this.isInterviewer);
        })
        .catch(error => {
            this.error = error;
            this.isInterviewer = false;
        })

        this.parameters = this.getQueryParameters();
        console.log('deeksha parameter : ' + JSON.stringify(this.parameters));
        console.log('deeksha c__recordId : ' + JSON.stringify(this.parameters.c__recordId));
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
                        console.log('Deeksha     accountsData :' + JSON.stringify(accountsData));
                        var tempList = []; 
                        for(const key in accountsData)
                        {
                            
                            tempList[key] = removeNamespaceFromKeyInObject(accountsData[key]);
                                
                        }
                        console.log('new tempList : '+JSON.stringify(tempList));
                    
                        result=tempList;
                        console.log('new accounts : '+JSON.stringify(result));
                    }
                this.accounts = result;
                console.log('deeksha: accounts : '+JSON.stringify(this.accounts));  
                
                
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