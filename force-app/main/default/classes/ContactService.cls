public class ContactService {

    public Map<Id, Contact> oldContacts;
    public List<Contact> newContacts;

    public ContactService() {}

    public void beforeInsert(){
        fillFields();
    }

    public void afterInsert() {}

    public void beforeUpdate() {
        fillFields();
    }

    public void afterUpdate() {}

    public void beforeDelete() {}

    public void afterDelete() {}

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