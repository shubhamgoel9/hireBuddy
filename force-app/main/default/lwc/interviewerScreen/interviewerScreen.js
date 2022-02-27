import { LightningElement } from 'lwc';
export default class HelloWebComponent extends LightningElement {
	greeting = 'Interviewer';
    options = [
        { label: '  Unavailable', value: 'option1' },
        { label: '  Available', value: 'option2' },
        { label: '  Interviewing', value: 'option3' },
    ];

    // Select option1 by default
    value = 'option1';

    get capitalizedGreeting() {
        return `Welcome ${this.greeting.toUpperCase()}!`;
    }

    handleChange(event) {
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
    }

    handleGreetingChange(event) {
        this.greeting = event.target.value;
    }

    handleInterviewerAssignmentNavigate(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: "My_Events",
            }
		});
    }
}