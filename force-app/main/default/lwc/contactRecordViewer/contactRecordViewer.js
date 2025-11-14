import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import NAME_FIELD from '@salesforce/schema/Contact.Name';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import DEPARTMENT_FIELD from '@salesforce/schema/Contact.Department';
import ACCOUNTID_FIELD from '@salesforce/schema/Contact.AccountId';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Contact.Account.Name';

const FIELDS = [
    NAME_FIELD,
    FIRSTNAME_FIELD,
    LASTNAME_FIELD,
    EMAIL_FIELD,
    PHONE_FIELD,
    MOBILE_FIELD,
    TITLE_FIELD,
    DEPARTMENT_FIELD,
    ACCOUNTID_FIELD,
    ACCOUNT_NAME_FIELD
];

export default class ContactRecordViewer extends LightningElement {
    @api recordId;
    @track contact;
    @track isEditMode = false;
    @track isLoading = false;
    @track draftValues = {};
    wiredContactResult;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContact(result) {
        this.wiredContactResult = result;
        if (result.data) {
            this.contact = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.contact = undefined;
        }
    }
    get name() { return this.contact ? getFieldValue(this.contact, NAME_FIELD) : ''; }
    get firstName() { return getFieldValue(this.contact, FIRSTNAME_FIELD); }
    get lastName() { return getFieldValue(this.contact, LASTNAME_FIELD); }
    get email() { return getFieldValue(this.contact, EMAIL_FIELD); }
    get phone() { return getFieldValue(this.contact, PHONE_FIELD); }
    get mobile() { return getFieldValue(this.contact, MOBILE_FIELD); }
    get title() { return getFieldValue(this.contact, TITLE_FIELD); }
    get department() { return getFieldValue(this.contact, DEPARTMENT_FIELD); }
    get accountId() { return getFieldValue(this.contact, ACCOUNTID_FIELD); }
    get accountName() { return getFieldValue(this.contact, ACCOUNT_NAME_FIELD); }

    handleEdit() {
        this.isEditMode = true;
        this.draftValues = {
            FirstName: this.firstName || '',
            LastName: this.lastName || '',
            Email: this.email || '',
            Phone: this.phone || '',
            MobilePhone: this.mobile || '',
            Title: this.title || '',
            Department: this.department || '',
            AccountId: this.accountId || null
        };
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        this.draftValues[field] = event.target.value;
    }

    handleAccountChange(event) {
        let val = event.detail.value || event.target.value;
        if (Array.isArray(val)) val = val.length ? val[0] : null;
        this.draftValues.AccountId = val;
    }

    handleCancel() {
        this.isEditMode = false;
    }

    async handleSave() {
        this.isLoading = true;
        try {
            const fields = { Id: this.recordId, ...this.draftValues };
            await updateRecord({ fields });
            this.showToast('Success', 'Contact updated successfully', 'success');
            this.isEditMode = false;
            await refreshApex(this.wiredContactResult);
        } catch (error) {
            this.showToast('Error updating record', error?.body?.message || 'An unknown error occurred', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async handleDelete() {
        if (!confirm('Are you sure you want to delete this contact?')) return;
        this.isLoading = true;
        try {
            await deleteRecord(this.recordId);
            this.showToast('Deleted', 'Contact deleted successfully', 'success');
        } catch (error) {
            this.showToast('Error deleting record', error?.body?.message || 'Unable to delete this contact', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}