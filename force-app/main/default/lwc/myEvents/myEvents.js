import { LightningElement, wire, api, track } from 'lwc';
import getFutureEvents from '@salesforce/apex/EventsController.getFutureEvents';
import getPastEvents from '@salesforce/apex/EventsController.getPastEvents';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';
import {refreshApex} from '@salesforce/apex';
import {removeNamespaceFromKeyInObject, addNamespaceForKeyInObject,namespace} from 'c/utility';
import { NavigationMixin } from 'lightning/navigation';

export default class MyEvents extends NavigationMixin(LightningElement) {

    @api recordId;
    //@wire(getNamespace) nsp;
    @wire(getFutureEvents) eventList;
    @wire(getPastEvents) pastEventList;
    @wire(getCurrentUserName) currentUser;

    currentEvent;

    connectedCallback()
    {
        console.log('Inside connectedCallback:: '+ namespace);
        
    }

    get futureEvents(){
        refreshApex(this.pastEvents);
        console.log("username : " + JSON.stringify(this.getCurrentUserName));
        console.log("events : " + JSON.stringify(this.eventList.data));
        if(this.eventList.data != undefined)
        {
            var eventListData =  this.eventList.data;
            var tempList =[];
            for(const key in eventListData)
            {
                console.log('Prit: eventListData[key] in future events: '+eventListData[key]);
                tempList[key] = removeNamespaceFromKeyInObject(eventListData[key]);
            }
            this.eventList.data=tempList;
            console.log('new eventList : '+JSON.stringify(this.data));
        }
        return this.eventList.data;
    }

    get pastEvents(){
        refreshApex(this.eventList);
        console.log("pastEventList : " + JSON.stringify(this.pastEventList));

        if(this.pastEventList.data != undefined)
        {
            var eventListData =  this.pastEventList.data;
            var tempList =[];
            for(const key in eventListData)
            {
                console.log('Prit: eventListData[key] in past events: '+eventListData[key]);
                tempList[key] = removeNamespaceFromKeyInObject(eventListData[key]);
                console.log('Prit: eventListData[key] in past events after removing ns: '+tempList[key]);
            }
            this.pastEventList.data = tempList;
            console.log('new pastEventList : '+JSON.stringify(this.pastEventList.data));
        }
        return this.pastEventList.data;
    }

    handleEventScreen(event) {
        event.preventDefault();
        var funEventID = event.currentTarget.dataset.id;
        this.currentEvent = event.target.value;
        console.log("currentEvent : " + JSON.stringify(funEventID));
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

    navigateToInterviewerAssignment(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({

			type: 'standard__navItemPage',
			attributes: {
                apiName: namespace+'Interviewer_Assignment',
                //actionName: 'new',
            }
		});
    }


    handleViewAll() {
        this[NavigationMixin.Navigate]({

            type: 'standard__objectPage',
            attributes: {
                objectApiName: namespace+'Hiring_Event__c',
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
                objectApiName: namespace+"Hiring_Event__c",
                actionName: 'new'
            },
            // state: {
            //     defaultFieldValues: defaultValues
            // }
        }); 

    }

    // navigateToRefreshPage(){

    //     refreshApex(this.eventList);
    //     refreshApex(this.pastEvents);

    //     this[NavigationMixin.Navigate]({

	// 		type: 'standard__navItemPage',
	// 		attributes: {
    //             apiName: 'Home_Recruiter',
    //             //actionName: 'new',
    //         }
	// 	});
    // }

}