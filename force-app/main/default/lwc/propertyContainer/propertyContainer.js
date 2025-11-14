import { LightningElement, track, wire } from 'lwc';
import getFilteredProperties from '@salesforce/apex/PropertyController.getFilteredProperties';


export default class PropertyContainer extends LightningElement {
    @track filters = {
        city: '',
        type: '',
        status: '',
        minPrice: null,
        maxPrice: null,
        minBedrooms: null
    };

    @track properties;
    @track error;
    @track isLoading = false;

    @wire(getFilteredProperties, {
        city: '$filters.city',
        type: '$filters.type',
        status: '$filters.status',
        minPrice: '$filters.minPrice',
        maxPrice: '$filters.maxPrice',
        minBedrooms: '$filters.minBedrooms'
    })
    wiredProperties({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.properties = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.properties = undefined;
        }
    }

    handleFilterChange(event) {
        const { filterType, filterValue } = event.detail;
        if (filterType === 'reset') {
            this.filters = {
                city: '',
                type: '',
                status: '',
                minPrice: null,
                maxPrice: null,
                minBedrooms: null
            };
        } else {
            this.filters = { ...this.filters, [filterType]: filterValue };
        }
        this.isLoading = true;
    }

}