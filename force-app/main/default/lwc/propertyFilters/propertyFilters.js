import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PROPERTY_OBJ from '@salesforce/schema/Property__c';
import CITY_FIELD from '@salesforce/schema/Property__c.City__c';
import STATUS_FIELD from '@salesforce/schema/Property__c.Property_Status__c';
import TYPE_FIELD from '@salesforce/schema/Property__c.Property_Type__c';

export default class PropertyFilters extends LightningElement {
    @track filters = {
        city: '',
        type: '',
        status: '',
        minPrice: '',
        maxPrice: '',
        minBedrooms: ''
    };

    @track cityOptions = [];
    @track typeOptions = [];
    @track statusOptions = [];

    defaultRecordTypeId;

    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJ })
  objectInfo({ data, error }) {
    if (data) {
      this.defaultRecordTypeId = data.defaultRecordTypeId;
    } else {
      console.error('Error fetching object info', error);
    }
  }

  @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: CITY_FIELD })
    wiredCity({ data, error }) {
        if (data) {
            this.cityOptions = [
                { label: 'All Cities', value: '' },
                ...data.values.map(v => ({ label: v.label, value: v.value }))
            ];
        } else if (error) {
            console.error('Error getting city picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    wiredType({ data, error }) {
        if (data) {
            this.typeOptions = [
                { label: 'All Types', value: '' },
                ...data.values.map(v => ({ label: v.label, value: v.value }))
            ];
        } else if (error) {
            console.error('Error getting type picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecordTypeId', fieldApiName: STATUS_FIELD })
    wiredStatus({ data, error }) {
        if (data) {
            this.statusOptions = [
                { label: 'All Statuses', value: '' },
                ...data.values.map(v => ({ label: v.label, value: v.value }))
            ];
        } else if (error) {
            console.error('Error getting status picklist values', error);
        }
    }

 /*  cityOptions = [
    { label: 'All Cities', value: '' },
    { label: 'Denver', value: 'Denver' },
    { label: 'Miami', value: 'Miami' },
    { label: 'Los Angeles', value: 'Los Angeles' },
    { label: 'New York', value: 'New York' }
];

    propertyTypeOptions = [
    { label: 'All Types', value: '' },
    { label: 'Condo', value: 'Condo' },
    { label: 'Single Family', value: 'Single Family' },
    { label: 'Townhouse', value: 'Townhouse' },
    { label: 'Commercial', value: 'Commercial' },
    { label: 'Multi-Family', value: 'Multi-Family' },
    { label: 'Villa', value: 'Villa' },
    { label: 'Penthouse', value: 'Penthouse' }
];

    statusOptions = [
    { label: 'All', value: '' },
    { label: 'Available', value: 'Available' },
    { label: 'Pending', value: 'Pending' },
    { label: 'Sold', value: 'Sold' },
    { label: 'Withdrawn', value: 'Withdrawn' }
];

*/
    handleFilterChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.filters = { ...this.filters, [field]: value };

        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: { filterType: field, filterValue: value }
            })
        );
    }

    clearFilters() {
        this.filters = {
            city: '',
            type: '',
            status: '',
            minPrice: '',
            maxPrice: '',
            minBedrooms: ''
        };

        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: { filterType: 'reset', filterValue: this.filters }
            })
        );
    }
}