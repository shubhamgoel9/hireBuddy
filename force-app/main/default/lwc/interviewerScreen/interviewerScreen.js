import { LightningElement ,wire, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMyUpcomingRound from '@salesforce/apex/HireBuddyController.getMyUpcomingRound';
import getMyTodayEvent from '@salesforce/apex/HireBuddyController.getMyTodayEvent';
import getCurrentUserName from '@salesforce/apex/HireBuddyController.getCurrentUserName';
import setInterviewerStatus from '@salesforce/apex/HireBuddyController.setInterviewerStatus';
import getInterviewerStatus from '@salesforce/apex/HireBuddyController.getInterviewerStatus';
import isInterviewer from '@salesforce/apex/HirebuddyController.isInterviewer';
import { removeNamespaceFromKeyInObject, addNamespaceForKeyInObject, namespace } from 'c/utility';
import {refreshApex} from '@salesforce/apex';
export default class InterviewerScreen extends NavigationMixin(LightningElement) {

    @track isInterviewer;
    @wire(getMyUpcomingRound) roundList;
    @wire(getMyTodayEvent) myTodayEvent;
    @wire(getCurrentUserName) currentUser;
    @track currentStatus;
   
    options = [
        { label: '     Unavailable', value: 'Unavailable' },
        { label: '     Available', value: 'Available' },
        { label: '     Interviewing', value: 'Interviewing' },
    ];

    //Method to get the list of rounds assigned to interviewer
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


    //Get the current interviewer status
    connectedCallback()
    {
        isInterviewer()
        .then(result => {
            this.isInterviewer = result;
            getInterviewerStatus().then(result => {

                this.currentStatus = result;
    
            }).catch(error => {
                this.error = error;
            }) 
        })
        .catch(error => {
            this.error = error;
            this.isInterviewer = false;
        })

    }
    
    //Method to handle the change of interviewer status
    handleStatusChange(event) {
        var selectedStatus = event.target.value;
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
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating Interviewer status!',
                    message: JSON.stringify(error),
                    variant: 'error'
                })
            );
        });
    }

    //Method to navigate to event dashboard
    handleEventBoardNavigate(event){
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

    //Method to navigate assigned rounds to interviewer
    handleRoundNavigate(event) {
        // Generate a URL to a User record page
        var funActID = event.currentTarget.dataset.id;
         

       this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: namespace+'Assigned_Rounds',
                actionName: 'new',
            },
            state: {
                c__recordId: funActID            }
        }).then((url) => {
            this.recordPageUrl = url;
        })
        ; 
    }    
   
}