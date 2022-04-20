import { LightningElement, wire, api, track } from 'lwc';
import getFutureEvents from '@salesforce/apex/EventsController.getFutureEvents';
import getPastEvents from '@salesforce/apex/EventsController.getPastEvents';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';
import {refreshApex} from '@salesforce/apex';
import {removeNamespaceFromKeyInObject, addNamespaceForKeyInObject,namespace} from 'c/utility';
import isRecruiter from '@salesforce/apex/HirebuddyController.isRecruiter';
import { NavigationMixin } from 'lightning/navigation';

export default class MyEvents extends NavigationMixin(LightningElement) {

    @api recordId;
    @wire(getFutureEvents) eventList;
    @wire(getPastEvents) pastEventList;
    @wire(getCurrentUserName) currentUser;
    @track isRecruiter;

    currentEvent;

    async connectedCallback()
    {
        await isRecruiter()
        .then(result => {
            this.isRecruiter = result;
        })
        .catch(error => {
            this.error = error;
            this.isRecruiter = false;
        })
        
    }

    //Method to return the future event to html page
    get futureEvents(){
        refreshApex(this.pastEvents);
        if(this.eventList.data != undefined)
        {
            var eventListData =  this.eventList.data;
            var tempList =[];
            for(const key in eventListData)
            {
                tempList[key] = removeNamespaceFromKeyInObject(eventListData[key]);
            }
            this.eventList.data=tempList;
        }
        return this.eventList.data;
    }

    //Method to return past events to html page
    get pastEvents(){
        refreshApex(this.eventList);

        if(this.pastEventList.data != undefined)
        {
            var eventListData =  this.pastEventList.data;
            var tempList =[];
            for(const key in eventListData)
            {
                tempList[key] = removeNamespaceFromKeyInObject(eventListData[key]);
            }
            this.pastEventList.data = tempList;
        }
        return this.pastEventList.data;
    }

    //Method to navigate to the clicked event
    handleEventScreen(event) {
        event.preventDefault();
        var funEventID = event.currentTarget.dataset.id;
        this.currentEvent = event.target.value;
        this.dispatchEvent(new CustomEvent('currenteventscreen', {detail : {eventId: funEventID}  }));

        this[NavigationMixin.Navigate]({

			type: 'standard__navItemPage',
			attributes: {
                apiName: namespace+'Event_Screen',
                //actionName: 'new',
			},
            state: {
                c__recordId: funEventID,
            }
		});
    }

    //Method to to navigate to interviewer assignment page on buttonn click
    navigateToInterviewerAssignment(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({

			type: 'standard__navItemPage',
			attributes: {
                apiName: namespace+'Interviewer_Assignment',
            }
		});
    }


    //Method to open all the records of the Hiring_Event with 'Recent' Filter
    handleViewAll() {
        this[NavigationMixin.Navigate]({

            type: 'standard__objectPage',
            attributes: {
                objectApiName: namespace+'Hiring_Event__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' // or by 18 char '00BT0000002TONQMA4'
            }
		});

    }

    //Method to create the new Hiring event
    navigateToNewHiringEvent(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: namespace+"Hiring_Event__c",
                actionName: 'new'
            },
        }); 

    }

}