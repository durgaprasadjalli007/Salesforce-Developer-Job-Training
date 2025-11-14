import { LightningElement, track } from 'lwc';
import searchContacts from '@salesforce/apex/PS_ContactController.searchContacts';
import getContactById from '@salesforce/apex/PS_ContactController.getContactById';
import createContact from '@salesforce/apex/PS_ContactController.createContact';
import updateContact from '@salesforce/apex/PS_ContactController.updateContact';
import deleteContact from '@salesforce/apex/PS_ContactController.deleteContact';
import getAccounts from '@salesforce/apex/PS_ContactController.getAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactManager extends LightningElement {
    @track contactList = [];
    @track accountOptions = [];
    @track searchQuery = '';
    @track accountFilterId = '';
    @track loading = false;
    @track showForm = false;
    @track noResults = false;
    @track form = {};
    @track modalHeader = 'New Contact';
    editingId = null;
    debounceTimer;

    connectedCallback() {
        this.loadAccounts();
        this.loadContacts();
    }

    async loadAccounts() {
        try {
            const accounts = await getAccounts();
            this.accountOptions = [
                { label: 'All Accounts', value: '' },
                ...accounts.map(a => ({ label: a.Name, value: a.Id }))
            ];
        } catch (err) {
            this.showToast('Error loading accounts', this.parseApexError(err), 'error');
        }
    }

    async loadContacts() {
        this.loading = true;
        this.noResults = false;
        try {
            const data = await searchContacts({
                searchTerm: this.searchQuery || '',
                accountId: this.accountFilterId || ''
            });

            this.contactList = (data || []).map(c => ({
                ...c,
                Name: (c.FirstName ? c.FirstName + ' ' : '') + (c.LastName || ''),
                AccountName: c.Account ? c.Account.Name : ''
            }));

            this.noResults = this.contactList.length === 0;
        } catch (err) {
            this.contactList = [];
            this.noResults = true;
            this.showToast('Error loading contacts', this.parseApexError(err), 'error');
        } finally {
            this.loading = false;
        }
    }

    handleSearchInput(event) {
        this.searchQuery = event.target.value;
        console.log('searchQuery', this.searchQuery);
        if (this.searchQuery.length >= 3) {
            this.loadContacts();
        }
    }

    handleAccountFilter(event) {
        this.accountFilterId = event.detail.value;
        this.loadContacts();
    }

    openNewContactForm() {
        this.form = { FirstName: '', LastName: '', Email: '', Phone: '', AccountId: '' };
        this.modalHeader = 'New Contact';
        this.editingId = null;
        this.showForm = true;
    }

    closeForm() {
        this.showForm = false;
        this.form = {};
        this.editingId = null;
    }

    async handleEdit(event) {
        const contactId = event.currentTarget.dataset.id;
        if (!contactId) {
            this.showToast('Edit failed', 'No contact id found.', 'error');
            return;
        }
        this.loading = true;
        try {
            const c = await getContactById({ contactId });
            this.form = {
                Id: c.Id,
                FirstName: c.FirstName || '',
                LastName: c.LastName || '',
                Email: c.Email || '',
                Phone: c.Phone || '',
                AccountId: c.AccountId || ''
            };
            this.editingId = c.Id;
            this.modalHeader = 'Edit Contact';
            this.showForm = true;
        } catch (err) {
            this.showToast('Error loading contact', this.parseApexError(err), 'error');
        } finally {
            this.loading = false;
        }
    }

    async handleDelete(event) {
        const contactId = event.currentTarget.dataset.id;
        if (!contactId) {
            this.showToast('Delete failed', 'No contact id found.', 'error');
            return;
        }

        if (!window.confirm('Delete this contact? This action cannot be undone.')) {
            return;
        }

        this.loading = true;
        try {
            await deleteContact({ contactId });
            this.showToast('Deleted', 'Contact deleted successfully', 'success');
            await this.loadContacts();
        } catch (err) {
            this.showToast('Delete failed', this.parseApexError(err), 'error');
        } finally {
            this.loading = false;
        }
    }

    handleFormChange(event) {
        const field = event.target.dataset.field;
        if (!field) return;
        const newVal = (event.detail && typeof event.detail.value !== 'undefined')
            ? event.detail.value
            : event.target.value;
        this.form = { ...this.form, [field]: newVal };
    }

    async saveContact() {
        if (!this.form.LastName || !this.form.LastName.trim()) {
            this.showToast('Validation', 'Last Name is required.', 'warning');
            return;
        }

        this.loading = true;
        try {
            if (this.editingId || this.form.Id) {
                await updateContact({
                    contactId: this.editingId || this.form.Id,
                    firstName: this.form.FirstName || '',
                    lastName: this.form.LastName || '',
                    email: this.form.Email || '',
                    phone: this.form.Phone || ''
                });
                this.showToast('Saved', 'Contact updated successfully.', 'success');
            } else {
                await createContact({
                    firstName: this.form.FirstName || '',
                    lastName: this.form.LastName || '',
                    email: this.form.Email || '',
                    phone: this.form.Phone || '',
                    accountId: this.form.AccountId || null
                });
                this.showToast('Saved', 'Contact created successfully.', 'success');
            }

            this.closeForm();
            await this.loadContacts();
        } catch (err) {
            this.showToast('Save failed', this.parseApexError(err), 'error');
        } finally {
            this.loading = false;
        }
    }

    parseApexError(err) {
        try {
            if (!err) return 'Unknown error';
            if (err.body) {
                if (err.body.message) return err.body.message;
                if (err.body.output && err.body.output.errors?.length) {
                    return err.body.output.errors.map(e => e.message).join('; ');
                }
            }
            return err.message || JSON.stringify(err);
        } catch {
            return 'Unknown error';
        }
    }

    showToast(title, message, variant = 'info') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}