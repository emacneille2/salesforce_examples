/*
* ContactService
*
* Called by the Contact Trigger to handle data manipulations
* 
* Prefer to place logic in the before triggers when possible because making modifications in the after trigger 
* will cause an additional transaction
*/
public class ContactService {

    public Map<Id, Contact> oldContacts;
    public List<Contact> newContacts;

    public ContactService() {}


    // runs before a Contact is inserted
    public void beforeInsert(){
        fillFields();
    }

    // runs after a Contact is inserted
    public void afterInsert() {}

    // runs before a Contact is updated
    public void beforeUpdate() {
        fillFields();
    }

    // runs after a Contact is updated
    public void afterUpdate() {}

    // runs before a Contact is deleted
    public void beforeDelete() {}

    // runs after a Contact is deleted
    public void afterDelete() {}

    // fillFields - sets Contact's fields before Insert and before Update
    //
    // Uses phone parsing service to set fields if Contact is new or Phone has changed.
    void fillFields() {
        for (Contact contactToUpdate: newContacts) {

            // only enter logic if Contact is new or Phone is changing
            if (oldContacts == null || contactToUpdate.Phone != oldContacts.get(contactToUpdate.Id).Phone) {
                PhoneParsingService phoneParsingService = new PhoneParsingService(contactToUpdate.Phone);
                
                contactToUpdate.Phone_10_Digit__c = phoneParsingService.tenDigit;
                contactToUpdate.Phone_Country_Dial_Code__c = phoneParsingService.countryDialCode;
                contactToUpdate.Phone_Area_Code__c = phoneParsingService.areaCode;
                contactToUpdate.Phone_Extension__c = phoneParsingService.extension;
                contactToUpdate.Phone_Timezone_Offset__c = phoneParsingService.timezoneOffset;
                contactToUpdate.Phone_State_Code__c = phoneParsingService.stateIsoCode;
                contactToUpdate.Phone_Country_Code__c = phoneParsingService.countryIsoCode;
                contactToUpdate.Phone_Canonical__c = phoneParsingService.canonicalPhone;

                if (contactToUpdate.MailingStateCode == null && contactToUpdate.MailingCountryCode == null) {
                    contactToUpdate.MailingStateCode = phoneParsingService.stateIsoCode;
                    contactToUpdate.MailingCountryCode = phoneParsingService.countryIsoCode;
                }
            }
        }
    }
}