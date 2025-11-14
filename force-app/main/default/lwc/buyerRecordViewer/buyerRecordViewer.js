import { LightningElement, track, wire } from 'lwc';
import getCurrentBuyerAccount from '@salesforce/apex/BuyerAccountController.getCurrentBuyerAccount';
import updateBuyerAccount from '@salesforce/apex/BuyerAccountController.updateBuyerAccount';
import getPicklistValues from '@salesforce/apex/BuyerAccountController.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class BuyerRecordViewer extends LightningElement {
    @track buyer;
    @track error;
    @track isEdit = false;

    @track budgetOptions = [];
    @track statusOptions = [];

    wiredBuyerResult; 

    connectedCallback() {
        this.loadPicklistOptions();
    }

    loadPicklistOptions() {
        getPicklistValues({ objectApiName: 'Account', fieldApiName: 'Budget_Range__c' })
            .then(result => {
                this.budgetOptions = result; 
                console.log('Budget picklist options:', JSON.stringify(this.budgetOptions));
            })
            .catch(error => {
                console.error('Budget picklist error:', error);
            });

        getPicklistValues({ objectApiName: 'Account', fieldApiName: 'Status__c' })
            .then(result => {
                this.statusOptions = result;
                console.log('Status picklist options:', JSON.stringify(this.statusOptions));
            })
            .catch(error => {
                console.error('Status picklist error:', error);
            });
    }

    @wire(getCurrentBuyerAccount)
    wiredBuyer(result) {
        this.wiredBuyerResult = result;

        const { data, error } = result;
        if (data) {
            this.buyer = JSON.parse(JSON.stringify(data));
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : error.message;
            this.buyer = undefined;
        }
    }

    get inputDisabled() {
        return !this.isEdit;
    }

    get isSaveDisabled() {
        return !this.isEdit;
    }

    handleEdit() {
        this.isEdit = true;
    }

    handleChange(event) {
    const field = event.target.dataset.field;
    this.buyer[field] = event.target.value;
}

handleSave() {
    if (!this.buyer || !this.buyer.Id) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Invalid Account data',
                variant: 'error'
            })
        );
        return;
    }

    const updatedAcc = {
        Id: this.buyer.Id,
        Name: this.buyer.Name || null,
        Phone: this.buyer.Phone || null,
        Budget_Range__c: this.buyer.Budget_Range__c || null,
        Status__c: this.buyer.Status__c || null
    };

    console.log('Sending to Apex:', JSON.stringify(updatedAcc));

    updateBuyerAccount({ updatedAcc })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account details updated successfully',
                    variant: 'success'
                })
            );
            this.isEdit = false;
            return refreshApex(this.wiredBuyerResult);
        })
        .catch(error => {
            console.error('Update error:', JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
        });
}

}