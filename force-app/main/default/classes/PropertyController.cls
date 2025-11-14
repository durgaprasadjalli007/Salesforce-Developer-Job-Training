public with sharing class PropertyController {
    public class CurrentUserInfo {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public Boolean isGuest { get; set; }

        public CurrentUserInfo() {
            this.name = '';
            this.email = '';
            this.isGuest = true;
        }
    }
	@AuraEnabled(cacheable=true)
    public static CurrentUserInfo getCurrentUserInfo() {
        CurrentUserInfo currentUserInfo = new CurrentUserInfo();

        try {
            Id userId = UserInfo.getUserId();
            User currentUser = [
                SELECT Id, Name, Email, ContactId
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];

            currentUserInfo.name = currentUser.Name;
            currentUserInfo.email = currentUser.Email;
            currentUserInfo.isGuest = currentUser.ContactId == null;

        } catch (Exception e) {
            System.debug('Error fetching user info: ' + e.getMessage());
            currentUserInfo.isGuest = true;
        }

        return currentUserInfo;
    }
    @AuraEnabled(cacheable=true)
    public static List<Property__c> getFilteredProperties(
        String city,
        String type,
        String status,
        Decimal minPrice,
        Decimal maxPrice,
        Integer minBedrooms
    ) {
        String baseQuery = 'SELECT Id, Name, Listing_Price__c, Location__c, Location__r.Name, Bedrooms__c, ' +
                           'Bathrooms__c, Property_Type__c, Property_Status__c, Square_Footage__c, ' +
                           'Property_Address__c, Is_Favorite__c, ' +
                           '(SELECT Id, Image_Url__c FROM Property_Images__r) ' +
                           'FROM Property__c WHERE Id != null';

        if (String.isNotBlank(city)) baseQuery += ' AND Location__c = :city';
        if (String.isNotBlank(type)) baseQuery += ' AND Property_Type__c = :type';
        if (String.isNotBlank(status)) baseQuery += ' AND Property_Status__c = :status';
        if (minPrice != null) baseQuery += ' AND Listing_Price__c >= :minPrice';
        if (maxPrice != null) baseQuery += ' AND Listing_Price__c <= :maxPrice';
        if (minBedrooms != null) baseQuery += ' AND Bedrooms__c >= :minBedrooms';

        return Database.query(baseQuery + ' WITH SECURITY_ENFORCED');
    }

    // New method to toggle favorite
    @AuraEnabled
    public static Boolean toggleFavorite(Id propertyId, Boolean isFavorite) {
        try {
            Property__c prop = [SELECT Id, Is_Favorite__c FROM Property__c WHERE Id = :propertyId LIMIT 1];
            prop.Is_Favorite__c = isFavorite;
            update prop;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating favorite: ' + e.getMessage());
        }
    }
    public class PropertyDetailWrapper {
        @AuraEnabled public Property__c property { get; set; }
        @AuraEnabled public List<Property_Image__c> images { get; set; }
        @AuraEnabled public List<Property_Amenities__c> amenities { get; set; }
        @AuraEnabled public List<Property_Feature__c> features { get; set; }
    }
	@AuraEnabled(cacheable=true)
public static Map<String, Object> getPropertyDetails(Id propertyId) {
    if (propertyId == null) {
        throw new AuraHandledException('Property Id is required');
    }
    Property__c prop = [
        SELECT Id, Name, CurrencyIsoCode, Image_URL__c, Market_value__c, Property_Address__c,
                       Property_Taxes__c, Fireplace__c, Listing_Date__c, Property_Status__c,
                       Lot_Size__c, Property_Description__c, Year_Built__c, Square_footage__c,
                       Listing_price__c, Bathrooms__c, HOA_Fees__c, Property_Type__c,
                       Bedrooms__c, Garage_spaces__c, pool__c, Property_Agent__c,
                       Location__c, Price_Per_SqFt__c, Property_Age__c, Days_on_Market__c,
                       Total_Monthly_Fees__c, Is_Luxury_Property__c, City__c,
                       Location__r.Id, Location__r.Name, Location__r.City__c,
                       Location__r.State__c, Location__r.Address__c,
                       Location__r.Country__c, Location__r.Zip_Code__c,
                       Location__r.School_district__c,
                       Location__r.Safety_Score__c, Location__r.Walkability_Score__c,
                       Location__r.Public_Transportation__c,
                       Location__r.Average_Home_Price__c,
                       Location__r.Hospitals__c, Location__r.Shopping_Centers__c,
                       Location__r.Parks_Recreation__c
        FROM Property__c
        WHERE Id = :propertyId
        LIMIT 1
    ];
    List<Property_Image__c> images = [
        SELECT Id, Image_Url__c, Type__c
        FROM Property_Image__c
        WHERE Property__c = :propertyId
        ORDER BY CreatedDate ASC
    ];
    Map<String, Object> result = new Map<String, Object>();
    result.put('property', prop);
    result.put('images', images);
    return result;
}
   /* @AuraEnabled(cacheable=true)
    public static PropertyDetailWrapper getPropertyDetails(Id propertyId) {
        try {
            if (propertyId == null) {
                throw new AuraHandledException('Property Id is required');
            }

            // Query the property with all relevant fields including Location Site information
            Property__c property = [
                SELECT Id, Name, CurrencyIsoCode, Image_URL__c, Market_value__c, Property_Address__c,
                       Property_Taxes__c, Fireplace__c, Listing_Date__c, Property_Status__c,
                       Lot_size__c, Property_Description__c, Year_Built__c, Square_footage__c,
                       Listing_price__c, Bathrooms__c, HOA_Fees__c, Property_Type__c,
                       Bedrooms__c, Garage_spaces__c, pool__c, Property_Agent__c,
                       Location__c, Price_Per_SqFt__c, Property_Age__c, Days_on_Market__c,
                       Total_Monthly_Fees__c, Is_Luxury_Property__c, City__c,
                       Location__r.Id, Location__r.Name, Location__r.City__c,
                       Location__r.State__c, Location__r.Address__c,
                       Location__r.Country__c, Location__r.Zip_Code__c,
                       Location__r.School_district__c,
                       Location__r.Safety_Score__c, Location__r.Walkability_Score__c,
                       Location__r.Public_Transportation__c,
                       Location__r.Average_Home_Price__c,
                       Location__r.Hospitals__c, Location__r.Shopping_Centers__c,
                       Location__r.Parks_Recreation__c
                FROM Property__c
                WHERE Id = :propertyId
                LIMIT 1
            ];

            // Query related Property Images
            List<Property_Image__c> propertyImages = [
                SELECT Id, Name, Image_Url__c, Type__c
                FROM Property_Image__c
                WHERE Property__c = :propertyId
                ORDER BY CreatedDate ASC
            ];

            // Query related Property Amenities with Amenities details
            List<Property_Amenities__c> propertyAmenities = [
                SELECT Id, Name, Description__c, Active__c,
                       Amenities__c, Amenities__r.Name
                FROM Property_Amenities__c
                WHERE Property__c = :propertyId
                AND Active__c = true
                ORDER BY Amenities__r.Name ASC
            ];

            // Query related Property Features with Feature details
            List<Property_Feature__c> propertyFeatures = [
                SELECT Id, Name, Description__c, Active__c,
                       Feature__c, Feature__r.Name
                FROM Property_Feature__c
                WHERE Property__c = :propertyId
                AND Active__c = true
                ORDER BY Feature__r.Name ASC
            ];

            // Create and populate the wrapper
            PropertyDetailWrapper wrapper = new PropertyDetailWrapper();
            wrapper.property = property;
            wrapper.images = propertyImages;
            wrapper.amenities = propertyAmenities;
            wrapper.features = propertyFeatures;

            return wrapper;

        } catch (QueryException qe) {
            throw new AuraHandledException('Property not found: ' + qe.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching property details: ' + e.getMessage());
        }
    }*/
    @AuraEnabled
    public static AppointmentResult createAppointment(Id propertyId, String appointmentDateTime, String name, String phone) {
        AppointmentResult result = new AppointmentResult();

        try {
            // Validate required fields
            if (propertyId == null) {
                result.success = false;
                result.message = 'Property ID is required';
                return result;
            }

            if (String.isBlank(appointmentDateTime) || String.isBlank(name) || String.isBlank(phone)) {
                result.success = false;
                result.message = 'All fields are required';
                return result;
            }

            // Parse the date and time
            DateTime appointmentDT;
            try {
                appointmentDT = DateTime.valueOf(appointmentDateTime);
            } catch (Exception e) {
                result.success = false;
                result.message = 'Invalid date/time format';
                return result;
            }

            // Validate appointment is in the future
            if (appointmentDT < DateTime.now()) {
                result.success = false;
                result.message = 'Appointment date/time must be in the future';
                return result;
            }

            // Check if property exists
            List<Property__c> properties = [SELECT Id FROM Property__c WHERE Id = :propertyId LIMIT 1];
            if (properties.isEmpty()) {
                result.success = false;
                result.message = 'Property not found';
                return result;
            }

            // Get current user's Account (Buyer) if exists
            Id buyerId = null;
            List<User> currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (!currentUser.isEmpty() && currentUser[0].ContactId != null) {
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :currentUser[0].ContactId LIMIT 1];
                if (!contacts.isEmpty()) {
                    buyerId = contacts[0].AccountId;
                }
            }

            // Create Appointment__c record
            Appointment__c appointment = new Appointment__c();
            appointment.Property__c = propertyId;
            appointment.Account__c = buyerId;
            appointment.Appointment_Date_Time__c = appointmentDT;
            appointment.Status__c = 'Requested'; // Default status
            appointment.Showing_Type__c = 'Private'; // Default type - valid values: Private, Virtual Tour, Open House
            appointment.Duration__c = 60; // Default 1 hour duration
            appointment.Purpose__c = 'Property viewing appointment scheduled by ' + name + ' (Phone: ' + phone + ')';

            insert appointment;

            result.success = true;
            result.message = 'Appointment scheduled successfully';
            result.appointmentId = appointment.Id;

        } catch (DmlException dmlEx) {
            result.success = false;
            result.message = 'Error creating appointment: ' + dmlEx.getDmlMessage(0);
            System.debug('DML Exception: ' + dmlEx.getMessage());
        } catch (Exception e) {
            result.success = false;
            result.message = 'An unexpected error occurred: ' + e.getMessage();
            System.debug('Exception: ' + e.getMessage() + ' - Stack Trace: ' + e.getStackTraceString());
        }

        return result;
    }

    /**
     * Gets appointments for the current logged-in user
     * @return List of Appointment__c records with related property information
     */
    public class AppointmentWrapper {
        @AuraEnabled public Appointment__c appointment { get; set; }
        @AuraEnabled public Id propertyId { get; set; }
        @AuraEnabled public String propertyName { get; set; }
        @AuraEnabled public String propertyAddress { get; set; }
        @AuraEnabled public Decimal propertyPrice { get; set; }
        @AuraEnabled public String propertyType { get; set; }
        @AuraEnabled public String propertyImage { get; set; }
        @AuraEnabled public String propertyCity { get; set; }
        @AuraEnabled public String propertyState { get; set; }
    }
    public class OfferResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Id offerId { get; set; }

        public OfferResult() {
            this.success = false;
            this.message = '';
            this.offerId = null;
        }
    }
    public class InquiryWrapper {
        @AuraEnabled public Property_Inquiry__c inquiry { get; set; }
        @AuraEnabled public Id propertyId { get; set; }
        @AuraEnabled public String propertyName { get; set; }
        @AuraEnabled public String propertyAddress { get; set; }
        @AuraEnabled public Decimal propertyPrice { get; set; }
        @AuraEnabled public String propertyType { get; set; }
        @AuraEnabled public String propertyImage { get; set; }
        @AuraEnabled public String propertyCity { get; set; }
        @AuraEnabled public String propertyState { get; set; }
    }
    public class AppointmentResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Id appointmentId { get; set; }

        public AppointmentResult() {
            this.success = false;
            this.message = '';
            this.appointmentId = null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<AppointmentWrapper> getUserAppointments() {
        List<AppointmentWrapper> appointments = new List<AppointmentWrapper>();

        try {
            // Get current user's Account (Buyer) if exists
            Id buyerId = null;
            List<User> currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (!currentUser.isEmpty() && currentUser[0].ContactId != null) {
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :currentUser[0].ContactId LIMIT 1];
                if (!contacts.isEmpty()) {
                    buyerId = contacts[0].AccountId;
                }
            }

            // Query appointments for the current user
            List<Appointment__c> appointmentList = [
                SELECT Id, Name, Appointment_Date_Time__c, Status__c, Showing_Type__c,
                       Duration__c, Purpose__c, Property__c, Property__r.Name,
                       Property__r.Address__c, Property__r.Listing_price__c,
                       Property__r.Property_Type__c, Property__r.Image_URL__c,
                       Property__r.Location__r.City__c, Property__r.Location__r.State__c,
                       CreatedDate, LastModifiedDate
                FROM Appointment__c
                WHERE Account__c = :buyerId
                ORDER BY Appointment_Date_Time__c DESC
                LIMIT 100
            ];

            // Convert to wrapper objects
            for (Appointment__c appointment : appointmentList) {
                AppointmentWrapper wrapper = new AppointmentWrapper();
                wrapper.appointment = appointment;
                wrapper.propertyId = appointment.Property__c;
                wrapper.propertyName = appointment.Property__r.Name;
                wrapper.propertyAddress = appointment.Property__r.Address__c;
                wrapper.propertyPrice = appointment.Property__r.Listing_price__c;
                wrapper.propertyType = appointment.Property__r.Property_Type__c;
                wrapper.propertyImage = appointment.Property__r.Image_URL__c;
                wrapper.propertyCity = appointment.Property__r.Location__r.City__c;
                wrapper.propertyState = appointment.Property__r.Location__r.State__c;
                appointments.add(wrapper);
            }

        } catch (Exception e) {
            System.debug('Error fetching user appointments: ' + e.getMessage());
            throw new AuraHandledException('Error fetching appointments: ' + e.getMessage());
        }

        return appointments;
    }

    /**
     * Gets property inquiries for the current logged-in user
     * @return List of PropertyInquiry__c records with related property information
     */
    @AuraEnabled(cacheable=true)
    public static List<InquiryWrapper> getUserInquiries() {
        List<InquiryWrapper> inquiries = new List<InquiryWrapper>();

        try {
            // Get current user's Account (Buyer) if exists
            Id buyerId = null;
            List<User> currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (!currentUser.isEmpty() && currentUser[0].ContactId != null) {
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :currentUser[0].ContactId LIMIT 1];
                if (!contacts.isEmpty()) {
                    buyerId = contacts[0].AccountId;
                }
            }

            // Query inquiries for the current user
            List<Property_Inquiry__c> inquiryList = [
                SELECT Id, Name, Message__c, Inquiry_Date__c, Status__c, Priority__c,
                       Inquiry_Type__c, Response__c, Property__c, Property__r.Name,
                       Property__r.Address__c, Property__r.Listing_price__c,
                       Property__r.Property_Type__c, Property__r.Image_URL__c,
                       Property__r.Location__r.City__c, Property__r.Location__r.State__c,
                       CreatedDate, LastModifiedDate
                FROM Property_Inquiry__c
                WHERE Account__c = :buyerId
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];

            // Convert to wrapper objects
            for (Property_Inquiry__c inquiry : inquiryList) {
                InquiryWrapper wrapper = new InquiryWrapper();
                wrapper.inquiry = inquiry;
                wrapper.propertyId = inquiry.Property__c;
                wrapper.propertyName = inquiry.Property__r.Name;
                wrapper.propertyAddress = inquiry.Property__r.Address__c;
                wrapper.propertyPrice = inquiry.Property__r.Listing_price__c;
                wrapper.propertyType = inquiry.Property__r.Property_Type__c;
                wrapper.propertyImage = inquiry.Property__r.Image_URL__c;
                wrapper.propertyCity = inquiry.Property__r.Location__r.City__c;
                wrapper.propertyState = inquiry.Property__r.Location__r.State__c;
                inquiries.add(wrapper);
            }

        } catch (Exception e) {
            System.debug('Error fetching user inquiries: ' + e.getMessage());
            throw new AuraHandledException('Error fetching inquiries: ' + e.getMessage());
        }

        return inquiries;
    }
     public class InquiryResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Id inquiryId { get; set; }

        public InquiryResult() {
            this.success = false;
            this.message = '';
            this.inquiryId = null;
        }
    }
    @AuraEnabled
    public static InquiryResult createPropertyInquiry(Id propertyId, String name, String email, String phone, String message) {
        InquiryResult result = new InquiryResult();

        try {
            // Validate required fields
            if (propertyId == null) {
                result.success = false;
                result.message = 'Property ID is required';
                return result;
            }

            if (String.isBlank(name) || String.isBlank(email) || String.isBlank(message)) {
                result.success = false;
                result.message = 'Name, email, and message are required fields';
                return result;
            }

            // Validate email format
            String emailPattern = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            Pattern emailRegex = Pattern.compile(emailPattern);
            Matcher emailMatcher = emailRegex.matcher(email);

            if (!emailMatcher.matches()) {
                result.success = false;
                result.message = 'Please provide a valid email address';
                return result;
            }

            // Check if property exists
            List<Property__c> properties = [SELECT Id FROM Property__c WHERE Id = :propertyId LIMIT 1];
            if (properties.isEmpty()) {
                result.success = false;
                result.message = 'Property not found';
                return result;
            }

            // Get current user's Account (Buyer) if exists
            Id buyerId = null;
            List<User> currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (!currentUser.isEmpty() && currentUser[0].ContactId != null) {
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :currentUser[0].ContactId LIMIT 1];
                if (!contacts.isEmpty()) {
                    buyerId = contacts[0].AccountId;
                }
            }

            // Create PropertyInquiry__c record
            Property_Inquiry__c inquiry = new Property_Inquiry__c();
            inquiry.Property__c = propertyId;
            inquiry.Account__c = buyerId;
            inquiry.Inquiry_Date__c = System.today();
            inquiry.Status__c = 'New'; // Default status
            inquiry.Priority__c = 'Medium'; // Default priority
            inquiry.Inquiry_Type__c = 'General Info'; // Default type

            // Store contact info and message together
            String fullMessage = 'Contact: ' + name + '\n';
            fullMessage += 'Email: ' + email + '\n';
            if (String.isNotBlank(phone)) {
                fullMessage += 'Phone: ' + phone + '\n';
            }
            fullMessage += '\nMessage:\n' + message;
            inquiry.Message__c = fullMessage;

            insert inquiry;

            result.success = true;
            result.message = 'Inquiry submitted successfully';
            result.inquiryId = inquiry.Id;

        } catch (DmlException dmlEx) {
            result.success = false;
            result.message = 'Error creating inquiry: ' + dmlEx.getDmlMessage(0);
            System.debug('DML Exception: ' + dmlEx.getMessage());
        } catch (Exception e) {
            result.success = false;
            result.message = 'An unexpected error occurred: ' + e.getMessage();
            System.debug('Exception: ' + e.getMessage() + ' - Stack Trace: ' + e.getStackTraceString());
        }

        return result;
    }
     @AuraEnabled
    public static OfferResult createOffer(
        Id propertyId,
        Decimal offeredPrice,
        Decimal depositAmount,
        Date offerDate,
        Date expirationDate,
        Date proposedClosingDate,
        Boolean financingContingency,
        Boolean inspectionContingency,
        String specialTerms
    ) {
        OfferResult result = new OfferResult();

        try {
            // Validate required fields
            if (propertyId == null) {
                result.success = false;
                result.message = 'Property ID is required';
                return result;
            }

            if (offeredPrice == null || offeredPrice <= 0) {
                result.success = false;
                result.message = 'Please provide a valid offer price';
                return result;
            }

            // Check if property exists
            List<Property__c> properties = [SELECT Id FROM Property__c WHERE Id = :propertyId LIMIT 1];
            if (properties.isEmpty()) {
                result.success = false;
                result.message = 'Property not found';
                return result;
            }

            // Get current user's Account (Buyer) if exists
            Id buyerId = null;
            List<User> currentUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (!currentUser.isEmpty() && currentUser[0].ContactId != null) {
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :currentUser[0].ContactId LIMIT 1];
                if (!contacts.isEmpty()) {
                    buyerId = contacts[0].AccountId;
                }
            }

            // Create Offer__c record
            Offer__c offer = new Offer__c();
            offer.Property__c = propertyId;
            offer.Buyer_Account__c = buyerId;
            offer.Offered_purchase_price__c = offeredPrice;
            offer.Deposit_Amount__c = depositAmount;
            offer.Offer_Date__c = offerDate != null ? offerDate : System.today();
            offer.Expiration_date__c = expirationDate;
            offer.Proposed_date_for_closing__c = proposedClosingDate;
            offer.Financing_contingency_included__c = financingContingency != null ? financingContingency : false;
            offer.Inspection_contingency_included__c = inspectionContingency != null ? inspectionContingency : false;
            offer.Special_terms_and_conditions__c = specialTerms;
            offer.Status__c = 'Draft'; // Set status as Draft

            insert offer;

            result.success = true;
            result.message = 'Offer created successfully as Draft';
            result.offerId = offer.Id;

        } catch (DmlException dmlEx) {
            result.success = false;
            result.message = 'Error creating offer: ' + dmlEx.getDmlMessage(0);
            System.debug('DML Exception: ' + dmlEx.getMessage());
        } catch (Exception e) {
            result.success = false;
            result.message = 'An unexpected error occurred: ' + e.getMessage();
            System.debug('Exception: ' + e.getMessage() + ' - Stack Trace: ' + e.getStackTraceString());
        }

        return result;
    }

}