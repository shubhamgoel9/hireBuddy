import { LightningElement, wire, api, track } from "lwc";
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem'
import getEventItem from '@salesforce/apex/EventItemsController.getEventItem'
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
            console.log('PPa: '+this.eventItemRecords + 'Result :: '+result);

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
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
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