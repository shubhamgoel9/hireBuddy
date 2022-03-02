import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation' ;
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem';
import setEventItem from '@salesforce/apex/EventItemsController.setEventItem';
export default class EventItems extends NavigationMixin(LightningElement)
{
    @track selectedEventItemId;
    @track isModalOpen = false;
    @track eventItemRecords;
    @track eventItemRecord;
    @track eventId;
    @track eventItems;
    //@wire(getAllEventItems, {eventId: '$eventId'}) eventItems;
    
    //Get All Event Items to display in dashboard
    parameters = {};
    connectedCallback() {

        this.parameters = this.getQueryParameters();
        console.log('prit parameter : ' + JSON.stringify(this.parameters));
        console.log('prit c__recordId : ' + JSON.stringify(this.parameters.c__recordId));
        this.eventId = this.parameters.c__recordId;

        getAllEventItems({eventId:this.eventId})
		.then(result => {
			this.eventItems = result;
            this.eventName = this.eventItems[0].hirebuddy__HiringEvent__r.Name;
            console.log('Prit: eventName::'+ this.eventName);
			this.error = undefined;
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

    //Action to perfrom when modal box is opened
    openModal(event) {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.selectedEventItemId=event.target.dataset.id;
        console.log('pp1: '+event.target.dataset.id);

        /*getEventItem({eventItemId:this.selectedEventItemId})
		.then(result => {
			this.eventItemRecords = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.eventItemRecords = undefined;
		})*/
        
        for (const key in this.eventItems) {
            console.log('Prit: key of eventItem: '+this.eventItems[key]);

            if(this.eventItems[key].Id === this.selectedEventItemId);
            {
                this.eventItemRecord = this.eventItems[key];
            }
        }
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    //method to get the combo box values for candidateStatus to be used in Modal box
    get candidateStatusOptions()
    {
        return [
            { label: 'Loop Cut', value: 'Loop Cut' },
            { label: 'Internet Issue', value: 'Internet Issue' },
            { label: 'No Show', value: 'No Show' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Completed', value: 'Completed' },
            { label: 'Time Break', value: 'Time Break' },

        ];
    }

    @track candidateStatus;
    @track R1Interviewer;
    @track R1Observer;
    @track R1Time;
    @track R1Sift;
    @track R1Feedback;

    //method to set the selected values in the Modify Candidate Modal box
    handleChange(event) {
        var value = event.target.value;
        console.log('enter handle change::'+value);

        if(event.target.dataset.id === 'candidateStatus')
        {
            this.candidateStatus = value;
            console.log('handle change candidateStatus::'+value);
        }
        else if(event.target.dataset.id === 'R1Interviewer')
        {
            this.R1Interviewer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R1Observer')
        {
            this.R1Observer = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R1Time')
        {
            this.R1Time = value;
            console.log('handle change::'+value);
        }
        else if(event.target.dataset.id === 'R1Feedback')
        {
            this.R1Feedback = value;
            console.log('handle change::'+value);
        }
    }
    
    //Action to perform on clicking SAVE on EDIT Modal
    submitDetails() {
        console.log('PP: inside submitDetails: selectedEventItemId::'+this.selectedEventItemId);
        // to close modal set isModalOpen tarck value as false
        //update Event Item Record
        setEventItem({selectedEventItemId:this.selectedEventItemId,
            candidateStatus:this.candidateStatus,
            R1Interviewer:this.R1Interviewer,
            R1Observer:this.R1Observer,
            R1Time:this.R1Time,
            R1Sift:this.R1Sift,
            R1Feedback:this.R1Feedback})
        
        window.location.reload();
        this.isModalOpen = false;
    }

    //Add New Candidate Button onlick event to create new HiringEventItem
    navigateToNewHiringEventItem(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: "hirebuddy__HiringEventItem__c",
                actionName: 'new'
            },
        });
    }
    
    
}