import { LightningElement, wire } from 'lwc';
import getFutureEvents from '@salesforce/apex/EventsController.getFutureEvents';
import getPastEvents from '@salesforce/apex/EventsController.getPastEvents';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';

import { NavigationMixin } from 'lightning/navigation';

export default class MyEvents extends NavigationMixin(LightningElement) {

    @wire(getFutureEvents) eventList;
    @wire(getPastEvents) pastEventList;
    @wire(getCurrentUserName) currentUser;

    currentEvent;

    get futureEvents(){
        console.log("username : " + JSON.stringify(this.getCurrentUserName));
        console.log("events : " + JSON.stringify(this.eventList.data));
        console.log("pastEvents : " + JSON.stringify(this.pastEventList.data));
        return this.eventList.data;
    }

    get pastEvents(){
        console.log("pastEventList : " + JSON.stringify(this.pastEventList.data));
        return this.pastEventList.data;
    }

    handleEventScreen(event) {
        event.preventDefault();
        var funEventID = event.currentTarget.dataset.id;

        this.currentEvent = event.target.value;
        console.log("currentEvent : " + JSON.stringify(funEventID));
        this.dispatchEvent(new CustomEvent('currenteventscreen', {detail : {eventId: funEventID}  }));

        this[NavigationMixin.Navigate]({

            // type: 'standard__recordPage',
            // attributes: {
            //     recordId: funEventID,
            //     objectApiName: 'Account',
            //     actionName: 'view'
            // }

			type: 'standard__navItemPage',
			attributes: {
                apiName: 'Event_Screen'
				// recordId: event.target.squad.Id,
				// objectApiName: 'Squad__c',
				// actionName: 'view',
			},
            state: {
                c__recordId: funEventID,
            }
		});
    }

    handleViewAll() {
        this[NavigationMixin.Navigate]({

            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Hiring_Event__c',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: 'All' // or by 18 char '00BT0000002TONQMA4'
            }
		});
    }

    navigateToNewHiringEvent(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: "Hiring_Event__c",
                actionName: 'new'
            },
            // state: {
            //     defaultFieldValues: defaultValues
            // }
        });
    }


}