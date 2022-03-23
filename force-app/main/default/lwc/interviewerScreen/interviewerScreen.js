import { LightningElement ,wire, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyUpcomingRound from '@salesforce/apex/HireBuddyController.getMyUpcomingRound';
import getMyTodayEvent from '@salesforce/apex/HireBuddyController.getMyTodayEvent';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';

export default class InterviewerScreen extends NavigationMixin(LightningElement) {

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
        console.log('EventId: '+this.myTodayEvent.data);
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Event_Dashboard',
            },
            state: {
                c__recordId: this.myTodayEvent.data
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
                apiName: 'Assigned_Rounds',
                //actionName: 'view',
            },
            state: {
                c__recordId: funActID            }
        }).then((url) => {
            this.recordPageUrl = url;
        })
        ;
    }

    handleRoundNavigation(event){
        event.preventDefault();
        var funActID = event.currentTarget.dataset.id;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: funActID,
                objectApiName: 'Round__c',
                actionName: 'view'
            }
        });
        
    }
    
   
}