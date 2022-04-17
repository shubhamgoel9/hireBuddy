import { LightningElement ,wire, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMyUpcomingRound from '@salesforce/apex/HireBuddyController.getMyUpcomingRound';
import getMyTodayEvent from '@salesforce/apex/HireBuddyController.getMyTodayEvent';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';
import setInterviewerStatus from '@salesforce/apex/HireBuddyController.setInterviewerStatus';
import getInterviewerStatus from '@salesforce/apex/HireBuddyController.getInterviewerStatus';
import { removeNamespaceFromKeyInObject, addNamespaceForKeyInObject, namespace } from 'c/utility';
import {refreshApex} from '@salesforce/apex';
export default class InterviewerScreen extends NavigationMixin(LightningElement) {

    @wire(getMyUpcomingRound) roundList;
    @wire(getMyTodayEvent) myTodayEvent;
    @wire(getCurrentUserName) currentUser;
    //@wire(getInterviewerStatus) 
    @track currentStatus;
   
    options = [
        { label: '     Unavailable', value: 'Unavailable' },
        { label: '     Available', value: 'Available' },
        { label: '     Interviewing', value: 'Interviewing' },
    ];

    /*get capitalizedGreeting() {
        return `Welcome ${this.greeting.toUpperCase()}!`;
    }*/

    get upcomingRounds(){
        refreshApex(this.roundList);
        refreshApex(this.myTodayEvent);
        if(this.roundList.data != undefined && this.roundList.data.length>0)
        {
            var roundListData =  this.roundList.data;
            var tempList =[];
            for(const key in roundListData)
            {
                tempList[key] = removeNamespaceFromKeyInObject(roundListData[key]);
            }
            this.roundList.data=tempList;   
            return this.roundList.data;
        }
        else
        {
            return false;
        }
    }


    connectedCallback()
    {

        getInterviewerStatus().then(result => {
            console.debug('Deeksha - result  ' + result);

            this.currentStatus = result;
            console.debug('Deeksha - this.currentStatus  ' + this.currentStatus);

        }).catch(error => {
			this.error = error;
		}) 
    }
    
    handleStatusChange(event) {
        var selectedStatus = event.target.value;
        console.log('Option selected with value: ' + selectedStatus);
        setInterviewerStatus({status:selectedStatus})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Interviewer Status Updated Successfully!',
                    variant: 'success'
                })
            );

        })
        .catch(error => {
            console.log('error in creating record: '+JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating Interviewer status!',
                    message: JSON.stringify(error),
                    variant: 'error'
                })
            );
        });
    }

    handleEventBoardNavigate(event){
        console.log('EventId: '+this.myTodayEvent.data);
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: namespace+'Event_Dashboard',
            },
            state: {
                c__recordId: this.myTodayEvent.data
            }
        });
    }

    handleRoundNavigate(event) {
       /* var roundId = event.currentTarget.dataset.id;
        const navConfig = {
            type: "standard__component",
            attributes: {
              componentName: "c__interviewDetails"
            },
            state: {
               c__recordId:  roundId
            }
          };
      

        //4. Invoke Naviate method
    this[NavigationMixin.Navigate](navConfig); */
        // Generate a URL to a User record page
        var funActID = event.currentTarget.dataset.id;
         

       this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //recordId: funActID,
                apiName: namespace+'Assigned_Rounds',
                actionName: 'new',
                //actionName: 'view',
            },
            state: {
                c__recordId: funActID            }
        }).then((url) => {
            this.recordPageUrl = url;
        })
        ; 
    }

    /*handleRoundNavigation(event){
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
        
    }*/
    
   
}