import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation' ;
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem'
import getEventItem from '@salesforce/apex/EventItemsController.getEventItem'
import setEventItem from '@salesforce/apex/EventItemsController.setEventItem'
export default class EventItems extends NavigationMixin(LightningElement)
{
    @track selectedEventId;
    @track isModalOpen = false;
    @track eventItemRecords;
    @track eventId;// = 'a008c00000YUBTYAA5';
    @track eventItems;
    //@wire(getAllEventItems, {eventId: '$eventId'}) eventItems;


    parameters = {};

    connectedCallback() {

        this.parameters = this.getQueryParameters();
        console.log('shubham parameter : ' + JSON.stringify(this.parameters));
        console.log('shubham c__recordId : ' + JSON.stringify(this.parameters.c__recordId));
        this.eventId = this.parameters.c__recordId;

        getAllEventItems({eventId:this.eventId})
		.then(result => {
			this.eventItems = result;
            console.log('Prit: event.items::'+JSON.stringify(this.eventItems));
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.eventItems = undefined;
		})
    }

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

    openModal(event) {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.selectedEventId=event.target.dataset.id;
        console.log('pp1: '+event.target.dataset.id);

        getEventItem({eventItemId:this.selectedEventId})
		.then(result => {
			this.eventItemRecords = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.eventItemRecords = undefined;
		})
        
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    @track candidateStatus;
    @track R1Interviewer;
    @track R1Observer;
    @track R1Time;
    @track R1Sift;
    @track R1Feedback;
    handleChange(event) {
        var value = event.target.value;
        console.log('enter handle change::'+value);

        if(event.target.dataset.id === 'candidateStatus')
        {
            this.candidateStatus = value;
            console.log('handle change::'+value);
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
    submitDetails() {
        console.log('PP: inside submitDetails');
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        setEventItem({selectedEventId:this.selectedEventId,
            candidateStatus:this.candidateStatus,
            R1Interviewer:this.R1Interviewer,
            R1Observer:this.R1Observer,
            R1Time:this.R1Time,
            R1Sift:this.R1Sift,
            R1Feedback:this.R1Feedback})
        
        window.location.reload();
        this.isModalOpen = false;
    }
    navigateToNewHiringEventItem(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: "hirebuddy__HiringEventItem__c",
                actionName: 'new'
            },
            // state: {
            //     defaultFieldValues: defaultValues
            // }
        });
    }
    
    @track isModal2Open = false;
    openModal2() {
        // to open modal set isModalOpen tarck value as true
        this.isModal2Open = true;
    }
    closeModal2() {
        // to close modal set isModalOpen tarck value as false
        this.isModal2Open = false;
    }
    submitDetails2() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModal2Open = false;
    }
    /*eventItemId=this.selectedEventId;
    @wire(getEventItem, {eventItemId:'$eventItemId'}) eventItemRecord;*/
    
}