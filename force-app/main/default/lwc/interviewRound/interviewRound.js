import { LightningElement, wire, track } from "lwc";   
import getCandiateByRoundId from '@salesforce/apex/HireBuddyController.getCandiateByRoundId';

export default class InterviewRound extends LightningElement {
    @track searchKey; 
    //@wire(getCandiateByRoundId, { roundId: 'a018c00000SpSEMAA3' }) accounts;
    @track roundId;
    @track accounts;
    handleCompleted(event) {
        
    }


    //Get All Event Items to display in dashboard
    parameters = {};
    connectedCallback() {
        this.parameters = this.getQueryParameters();
        console.log('deeksha parameter : ' + JSON.stringify(this.parameters));
        console.log('deeksha c__recordId : ' + JSON.stringify(this.parameters.c__recordId));
        this.roundId = this.parameters.c__recordId;

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