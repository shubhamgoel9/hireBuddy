import { LightningElement, wire, track , api } from "lwc";   
import getCandiateByRoundId from '@salesforce/apex/HireBuddyController.getCandiateByRoundId'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setFeedback from '@salesforce/apex/HireBuddyController.setFeedback';
import setStatusToInterviewing from '@salesforce/apex/HireBuddyController.setStatusToInterviewing';
import getInterviewerStatus from '@salesforce/apex/HireBuddyController.getInterviewerStatus';
export default class InterviewRound extends LightningElement {
    @track searchKey; 
    //@wire(getCandiateByRoundId, { roundId: 'a018c00000SpSEMAA3' }) accounts;
   // @track roundId;
    @track accounts;
    @track feedback;
    @track theRecord = {};
    @track roundId;
    @track disableStatus = false;
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
    connectedCallback() {
        this.parameters = this.getQueryParameters();
        console.log('deeksha parameter : ' + JSON.stringify(this.parameters));
        console.log('deeksha c__recordId : ' + JSON.stringify(this.parameters.c__recordId));
        this.roundId = this.parameters.c__recordId;
        
        getInterviewerStatus().then(result => {
            this.currentStatus = result;
            console.log('Deeksha result --- ' + result);
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
			this.accounts = result;
            console.log('deeksha: accounts : '+JSON.stringify(this.accounts));  
            console.log('deeksha: work ');
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