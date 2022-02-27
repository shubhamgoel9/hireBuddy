import { LightningElement, wire, api, track } from "lwc";
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem'
import getEventItem from '@salesforce/apex/EventItemsController.getEventItem'
import setEventItem from '@salesforce/apex/EventItemsController.setEventItem'
export default class EventItems extends LightningElement {
    @track selectedEventId;
    @track isModalOpen = false;
    @track eventItemRecords;
    eventId='a008c00000YUBTYAA5';
    @wire(getAllEventItems, {eventId: '$eventId'}) eventItems;
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
        this.isModalOpen = false;
        this.refreshData();
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