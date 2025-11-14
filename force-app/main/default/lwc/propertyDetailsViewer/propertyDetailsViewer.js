import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getPropertyImages from '@salesforce/apex/BuyerAccountController.getPropertyImages';
import USER_ID from '@salesforce/user/Id';

import NAME_FIELD from '@salesforce/schema/Property__c.Name';
import TYPE_FIELD from '@salesforce/schema/Property__c.Property_Type__c';
import STATUS_FIELD from '@salesforce/schema/Property__c.Property_Status__c';
import BEDROOMS_FIELD from '@salesforce/schema/Property__c.Bedrooms__c';
import BATHROOMS_FIELD from '@salesforce/schema/Property__c.Bathrooms__c';
import PRICE_FIELD from '@salesforce/schema/Property__c.Listing_Price__c';
import ADDRESS_FIELD from '@salesforce/schema/Property__c.Property_Address__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Property__c.Property_Description__c';
import SQUARE_FEET_FIELD from '@salesforce/schema/Property__c.Square_Footage__c';
import AGENT_FIELD from '@salesforce/schema/Property__c.Property_Agent__c';

import AGENT_NAME_FIELD from '@salesforce/schema/Agent__c.Name';
import AGENT_EMAIL_FIELD from '@salesforce/schema/Agent__c.Email__c';
import AGENT_PHONE_FIELD from '@salesforce/schema/Agent__c.Phone__c';
import AGENT_EXPERIENCE_FIELD from '@salesforce/schema/Agent__c.Years_Experience__c';
import AGENT_SPECIALIZATION_FIELD from '@salesforce/schema/Agent__c.Specialization__c';
import AGENT_STATUS_FIELD from '@salesforce/schema/Agent__c.Status__c';



const PROPERTY_FIELDS = [
  NAME_FIELD,
  TYPE_FIELD,
  STATUS_FIELD,
  BEDROOMS_FIELD,
  BATHROOMS_FIELD,
  PRICE_FIELD,
  ADDRESS_FIELD,
  DESCRIPTION_FIELD,
  SQUARE_FEET_FIELD,
  AGENT_FIELD
];

const AGENT_FIELDS = [
  AGENT_NAME_FIELD,
  AGENT_EMAIL_FIELD,
  AGENT_PHONE_FIELD,
  AGENT_EXPERIENCE_FIELD,
  AGENT_SPECIALIZATION_FIELD,
  AGENT_STATUS_FIELD
];

export default class PropertyDetailsViewer extends NavigationMixin(LightningElement) {
  @api recordId;
  @track propertyRecord;
  @track agentRecord;
  @track propertyImages = [];
  @track error;
  @track isLoading = true;
  

  userId = USER_ID;
  agentId;
  defaultImage = '/resource/default_property'; // 👈 Replace with your static resource name

  // Load Property
  @wire(getRecord, { recordId: '$recordId', fields: PROPERTY_FIELDS })
  wiredProperty({ data, error }) {
    if (data) {
      this.propertyRecord = data;
      this.agentId = getFieldValue(data, AGENT_FIELD);
      this.error = undefined;
    } else if (error) {
      this.error = 'Failed to load property details.';
      this.propertyRecord = undefined;
    }
    this.isLoading = false;
  }

  // Load Images
 @wire(getPropertyImages, { propertyId: '$recordId' })
    wiredImages({ data, error }) {
        console.log('📸 Property Image Wire called for:', this.recordId);
        if (data && data.length > 0) {
            console.log('✅ Image Data received:', data);
            this.propertyImages = data;
        } else if (data && data.length === 0) {
            console.log('ℹ️ No images found for property.');
            this.propertyImages = [];
        } else if (error) {
            console.error('❌ Error in getPropertyImages:', error);
            this.propertyImages = [];
        }
    }

    get defaultImage() {
        return DEFAULT_IMAGE;
    }

    handleImageError(event) {
        event.target.src = this.defaultImage;
    }

  // Load Agent Info
  @wire(getRecord, { recordId: '$agentId', fields: AGENT_FIELDS })
  wiredAgent({ data, error }) {
    if (data) {
      this.agentRecord = data;
    } else if (error) {
      this.agentRecord = undefined;
    }
  }

  // Getters
  get name() { return getFieldValue(this.propertyRecord, NAME_FIELD) || '—'; }
  get type() { return getFieldValue(this.propertyRecord, TYPE_FIELD) || '—'; }
  get statusLabel() { return getFieldValue(this.propertyRecord, STATUS_FIELD) || '—'; }
  get bedrooms() { return getFieldValue(this.propertyRecord, BEDROOMS_FIELD) || '—'; }
  get bathrooms() { return getFieldValue(this.propertyRecord, BATHROOMS_FIELD) || '—'; }
  get price() {
    const val = getFieldValue(this.propertyRecord, PRICE_FIELD);
    return val ? `$${val.toLocaleString()}` : '—';
  }
  get address() { return getFieldValue(this.propertyRecord, ADDRESS_FIELD) || '—'; }
  get description() { return getFieldValue(this.propertyRecord, DESCRIPTION_FIELD) || ''; }
  get squareFeet() {
    const val = getFieldValue(this.propertyRecord, SQUARE_FEET_FIELD);
    return val ? `${val} sq.ft` : '—';
  }
  get agentName() { return this.agentRecord ? getFieldValue(this.agentRecord, AGENT_NAME_FIELD) : '—'; }
  get agentEmail() { return this.agentRecord ? getFieldValue(this.agentRecord, AGENT_EMAIL_FIELD) : ''; }
  get agentPhone() { return this.agentRecord ? getFieldValue(this.agentRecord, AGENT_PHONE_FIELD) : ''; }
  get agentExperience() {
    const years = this.agentRecord ? getFieldValue(this.agentRecord, AGENT_EXPERIENCE_FIELD) : null;
    return years ? `${years} years` : '';
  }
  get agentSpecialization() { return this.agentRecord ? getFieldValue(this.agentRecord, AGENT_SPECIALIZATION_FIELD) : ''; }
  get agentStatus() { return this.agentRecord ? getFieldValue(this.agentRecord, AGENT_STATUS_FIELD) : ''; }
  get showAgentContact() { return !!this.userId && this.agentRecord !== undefined; }

  // Fallback for image error
  handleImageError(event) {
    event.target.src = this.defaultImage;
  }

  // Buttons Navigation
  handleContact() {
    const defaultValues = { Property__c: this.recordId, Inquiry_Type__c: 'General Info' };
    this.navigateToNewInquiry(defaultValues);
  }

  handleTour() {
    const defaultValues = { Property__c: this.recordId, Inquiry_Type__c: 'Visit Request' };
    this.navigateToNewInquiry(defaultValues);
  }

  navigateToNewInquiry(defaultValues) {
    const fields = Object.entries(defaultValues)
      .map(([k, v]) => `${k}=${encodeURIComponent(v)}`)
      .join('&');
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Property_Inquiry__c',
        actionName: 'new'
      },
      state: { defaultFieldValues: fields }
    });
  }
}