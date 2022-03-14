import { LightningElement ,wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyUpcomingRound from '@salesforce/apex/HireBuddyController.getMyUpcomingRound';
import getMyTodayEvent from '@salesforce/apex/HireBuddyController.getMyTodayEvent';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';

export default class InterviewerScreen extends LightningElement {
    @wire(getMyUpcomingRound) roundList;
    @wire(getMyTodayEvent) myTodayEvent;
    @wire(getCurrentUserName) currentUser;
   
    options = [
        { label: '     Unavailable', value: 'option1' },
        { label: '     Available', value: 'option2' },
        { label: '     Interviewing', value: 'option3' },
    ];

    // Select option1 by default
    value = 'option1';

    /*get capitalizedGreeting() {
        return `Welcome ${this.greeting.toUpperCase()}!`;
    }*/

    handleChange(event) {
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
    }

    handleEventBoardNavigate(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'hirebuddy__Event_Screen',
            }
        });
    }

    handleRoundNavigate(event){
        // Generate a URL to a User record page
        var funActID = event.currentTarget.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //recordId: funActID,
                apiName: 'hirebuddy__Assigned_Rounds',
                //actionName: 'view',
            },
        }).then((url) => {
            this.recordPageUrl = url;
        });
    }

    handleRoundNavigation(event){
        event.preventDefault();
        var funActID = event.currentTarget.dataset.id;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: funActID,
                objectApiName: 'hirebuddy__Round__c',
                actionName: 'view'
            }
        });
        
    }
    
   
}
