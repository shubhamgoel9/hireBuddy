import { LightningElement, wire, track } from "lwc";   
import getCandiateByRoundId from '@salesforce/apex/HireBuddyController.getCandiateByRoundId';

export default class InterviewRound extends LightningElement {
    @track searchKey; 
    @wire(getCandiateByRoundId, { roundId: 'a018c00000SoXoTAAV' }) accounts;
    
    handleCompleted(event) {
        
    }
    
}