import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import NAME_FIELD from '@salesforce/schema/Contact.Name';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Contact.Account.Name';
import MOBILE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import DEPARTMENT_FIELD from '@salesforce/schema/Contact.Department';
import CONTACT_ID from '@salesforce/schema/Contact.Id';

const FIELDS = [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, TITLE_FIELD, ACCOUNT_NAME_FIELD, MOBILE_FIELD, DEPARTMENT_FIELD];

export default class ContactRecordEditor extends LightningElement {
    @api recordId;

    @track contact;
    @track error;
    @track isLoading = false;
    @track isEditMode = false;

    // local editable model
    editable = {
        Name: '',
        Email: '',
        Phone: '',
        Title: '',
        MobilePhone: '',
        Department: ''
    };

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.contact = data;
            this.error = undefined;
            // initialize editable fields
            this.editable.Name = getFieldValue(data, NAME_FIELD) || '';
            this.editable.Email = getFieldValue(data, EMAIL_FIELD) || '';
            this.editable.Phone = getFieldValue(data, PHONE_FIELD) || '';
            this.editable.Title = getFieldValue(data, TITLE_FIELD) || '';
            this.editable.MobilePhone = getFieldValue(data, MOBILE_FIELD) || '';
            this.editable.Department = getFieldValue(data, DEPARTMENT_FIELD) || '';
        } else if (error) {
            this.error = this._reduceErrors(error).join(', ');
            this.contact = undefined;
        }
        this.isLoading = false;
    }

    get name() { return this.contact ? getFieldValue(this.contact, NAME_FIELD) : ''; }
    get email() { return this.contact ? getFieldValue(this.contact, EMAIL_FIELD) : ''; }
    get phone() { return this.contact ? getFieldValue(this.contact, PHONE_FIELD) : ''; }
    get title() { return this.contact ? getFieldValue(this.contact, TITLE_FIELD) : ''; }
    get accountName() { return this.contact ? getFieldValue(this.contact, ACCOUNT_NAME_FIELD) : ''; }
    get mobilePhone() { return this.contact ? getFieldValue(this.contact, MOBILE_FIELD) : ''; }
    get department() { return this.contact ? getFieldValue(this.contact, DEPARTMENT_FIELD) : ''; }

    toggleEdit() {
        this.isEditMode = true;
    }

    handleChange(e) {
        const field = e.target.dataset.field;
        if (field) {
            this.editable[field] = e.target.value;
        }
    }

    async saveChanges() {
        // basic validation: Name required, Email valid, Phone optional but must match pattern if provided
        if (!this.editable.Name || !this.editable.Email) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation error',
                message: 'Name and Email are required.',
                variant: 'error'
            }));
            return;
        }

        // simple email regex
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(this.editable.Email)) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation error',
                message: 'Please enter a valid email.',
                variant: 'error'
            }));
            return;
        }

        // phone simple pattern validation (digits, spaces, parentheses, +, -)
        if (this.editable.Phone && !/^[\d\s()+-]+$/.test(this.editable.Phone)) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation error',
                message: 'Phone contains invalid characters.',
                variant: 'error'
            }));
            return;
        }

        const fields = {};
        fields[CONTACT_ID.fieldApiName || 'Id'] = this.recordId;
        fields['Name'] = this.editable.Name;
        fields['Email'] = this.editable.Email;
        fields['Phone'] = this.editable.Phone;
        fields['Title'] = this.editable.Title;
        fields['MobilePhone'] = this.editable.MobilePhone;
        fields['Department'] = this.editable.Department;

        this.isLoading = true;
        try {
            await updateRecord({ fields });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Contact updated successfully.',
                variant: 'success'
            }));
            this.isEditMode = false;
            // refresh wired record snapshot happens automatically
        } catch (err) {
            const msg = this._reduceErrors(err).join(', ');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Update failed',
                message: msg,
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }

    handleCancel() {
        // revert local editable fields to source values
        if (this.contact) {
            this.editable.Name = getFieldValue(this.contact, NAME_FIELD) || '';
            this.editable.Email = getFieldValue(this.contact, EMAIL_FIELD) || '';
            this.editable.Phone = getFieldValue(this.contact, PHONE_FIELD) || '';
            this.editable.Title = getFieldValue(this.contact, TITLE_FIELD) || '';
            this.editable.MobilePhone = getFieldValue(this.contact, MOBILE_FIELD) || '';
            this.editable.Department = getFieldValue(this.contact, DEPARTMENT_FIELD) || '';
        }
        this.isEditMode = false;
    }

    async handleDelete() {
        // delegate deletion to viewer pattern: dispatch event so parent can handle navigation or refresh
        this.dispatchEvent(new CustomEvent('delete', { detail: { recordId: this.recordId } }));
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