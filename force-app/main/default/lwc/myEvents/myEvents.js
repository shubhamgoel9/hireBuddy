import { LightningElement, wire } from 'lwc';
import getFutureEvents from '@salesforce/apex/EventsController.getFutureEvents';
export default class MyEvents extends LightningElement {

    @wire(getFutureEvents) eventList;

    get futureEvents(){
        console.log("events : " + JSON.stringify(this.eventList.data));
        return this.eventList.data;
    }

}