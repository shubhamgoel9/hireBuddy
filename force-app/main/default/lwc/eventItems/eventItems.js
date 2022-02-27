import { LightningElement, wire, api, track } from "lwc";
import getAllEventItems from '@salesforce/apex/EventItemsController.getAllEventItem'
import getEventItem from '@salesforce/apex/EventItemsController.getEventItem'
export default class EventItems extends LightningElement {
    @track isModalOpen = false;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
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
    eventId='a008c00000YUBTYAA5';
    @wire(getAllEventItems, {eventId: '$eventId'}) eventItems;

    eventItemId='';
    @wire(getEventItem, {eventItemId:'$eventItemId'}) eventItemRecord;
    
}