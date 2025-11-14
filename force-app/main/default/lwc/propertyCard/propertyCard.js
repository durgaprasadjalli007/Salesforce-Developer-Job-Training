import { LightningElement, api, track } from 'lwc';
import defaultImage from '@salesforce/resourceUrl/NoImage';

export default class PropertyCard extends LightningElement {
    @api property;
    @track isFavorite = false;

    get hasImages() {
        return this.property?.Property_Images__r?.length > 0;
    }

    get firstImageUrl() {
        const images = this.property?.Property_Images__r;
        return images && images.length > 0 ? images[0].Image_Url__c : defaultImage;
    }

    get formattedPrice() {
        const price = this.property?.Price__c;
        return price ? `$${price.toLocaleString()}` : 'Price not available';
    }
    
    get locationName() {
    return this.property?.Location__r?.Name || 'No location'; 
    }

    get statusClass() {
        const status = this.property?.Property_Status__c?.toLowerCase();
        switch (status) {
            case 'available': return 'status-pill available';
            case 'pending': return 'status-pill pending';
            case 'sold': return 'status-pill sold';
            case 'withdrawn': return 'status-pill withdrawn';
            case 'under contract': return 'status-pill under-contract';
            default: return 'status-pill';
        }
    }

    get favoriteIcon() {
        return this.isFavorite ? 'utility:favorite' : 'utility:favorite_border';
    }

    toggleFavorite(event) {
        event.stopPropagation();
        this.isFavorite = !this.isFavorite;
    }

    get propertyType() {
        return this.property?.Property_Type__c || 'N/A';
    }

    get beds() {
        return this.property?.Beds__c ?? '—';
    }

    get baths() {
        return this.property?.Baths__c ?? '—';
    }

    navigateToPropertyDetail() {
        const propId = this.property.Id;
        const url = `/lightning/r/Property__c/${propId}/view`;
        window.open(url, '_blank');
    }

    get favoriteClass() {
        return this.isFavorite ? 'favorite-icon active' : 'favorite-icon';
    }
}