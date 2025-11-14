import { LightningElement, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactCreator extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phone = '';
    @track title = '';
    @track department = '';
    @track isLoading = false;
    @track error;

    handleChange(e) {
        const field = e.target.dataset.field;
        if (field) {
            this[fieldMap(field)] = e.target.value;
        }
    }

    async createContact() {
        if (!this.firstName || !this.lastName || !this.email || !this.phone || !this.title) {
            this._showToast('Validation error', 'Please fill required fields.', 'error');
            return;
        }

        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(this.email)) {
            this._showToast('Validation error', 'Please provide a valid email address.', 'error');
            return;
        }

        const accountField = this.template.querySelector('lightning-input-field[data-field="AccountId"]');
        const accountId = accountField ? accountField.value : null;

        if (!accountId) {
            this._showToast('Validation error', 'Please pick an Account using the lookup.', 'error');
            return;
        }

        const fields = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Email: this.email,
            Phone: this.phone,
            Title: this.title,
            Department: this.department,
            AccountId: accountId
        };

        const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields };

        this.isLoading = true;
        try {
            const created = await createRecord(recordInput);
            this._showToast('Success', `Contact created: ${created.id}`, 'success');
            this.clearForm();
            this.dispatchEvent(new CustomEvent('created', { detail: { id: created.id } }));
        } catch (err) {
            const message = this._reduceErrors(err).join(', ');
            this._showToast('Create failed', message, 'error');
            this.error = message;
        } finally {
            this.isLoading = false;
        }
    }

    clearForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.title = '';
        this.department = '';
        this.error = undefined;
        const lookupField = this.template.querySelector('lightning-input-field[data-field="AccountId"]');
        if (lookupField) {
            lookupField.value = null;
        }
    }

    noop() {}

    _showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    _reduceErrors(error) {
        if (!error) return ['Unknown error'];
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message);
        } else if (error.body && typeof error.body.message === 'string') {
            return [error.body.message];
        } else if (typeof error.message === 'string') {
            return [error.message];
        }
        return [JSON.stringify(error)];
    }
}

function fieldMap(dataField) {
    const map = {
        FirstName: 'firstName',
        LastName: 'lastName',
        Email: 'email',
        Phone: 'phone',
        Title: 'title',
        Department: 'department'
    };
    return map[dataField] || dataField;
}