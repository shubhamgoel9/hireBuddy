import { LightningElement,api } from 'lwc';

export default class Item extends LightningElement {
    @api item;
    handleOpenRecordClick() {
        const selectEvent = new CustomEvent('itemView', {
            detail: this.item.Id
        });
        this.dispatchEvent(selectEvent);
    }
}