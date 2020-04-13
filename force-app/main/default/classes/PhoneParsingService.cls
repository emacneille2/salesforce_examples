/*
* PhoneParsingService 
*
* parses phone numbers and determines their geography based on country dial code and area code
* seperates extension from the rest of the number so extension uniqueness can be sued
*
* Author: Elliot MacNeille
*/
public class PhoneParsingService {

    public String extension = null;

    String beforeExtension = null;
    String beforeExtensionClean = null;

    String rawPhone = null;
    public String countryDialCode = null;
    public String tenDigit = null;
    public String areaCode = null;
    public String lineNumber = null;
    
    public String canonicalPhone = null;

    public String countryIsoCode = null;
    public String stateIsoCode = null;
    public Boolean isUsNumber = false;
    public Boolean isValidNumber = false;

    // Integer -11 ... 12 that is the offset of a timezone from GMT
    public Integer timezoneOffset = null;

    // constructor for PhoneParsingService
    //
    // @param: phone -- the raw unformatted phone string entered by Users
    public PhoneParsingService(String phone) {
        init(phone);
    }

    // called upon Class cretaion to do parsing
    //
    // @param: phone -- the raw unformatted phone string entered by Users
    void init(String Phone) {
        this.rawPhone = phone;
        if (phone != null) {
            this.getExtension();
            this.getCountryDialCode();
            this.getCanonicalPhone();
        }
    }

    // getNumeric -- gets numeric part of inString
    //
    // @param inString -- any string
    // @return subset of string that is numeric characters, empty string if none are present
    static String getNumeric(String inString) {
        String answer = '';
        for (String charInString: inString.split('')) {
            if (charInString.isNumeric()) {
                answer += charInString;
            }
        }
        return answer;
    }

    // getExtension -- gets extension of phone number
    //
    // @set extension -- to extension of phone if phone has a numeric extension, null otherwise
    void getExtension() {
        // this will catch seperators such as 'x', 'X', 'ext.'', 'EXT.'
        String toFind = 'x';

        List<String> phoneParts = this.rawPhone.toLowerCase().split(toFind);
        this.beforeExtension = phoneParts[0];
        this.beforeExtensionClean = PhoneParsingService.getNumeric(phoneParts[0]);

        // initialize extension in case it isn't set in if block
        this.extension = null;
        if (phoneParts.size() > 1) {
            phoneParts.remove(0);
            this.extension = PhoneParsingService.getNumeric(String.join(phoneParts, 'x'));
            if (this.extension == '') {
                this.extension = null;
            }
        }
    }

    // isCountryCode -- determines if Phone number can be country code 1 
    Boolean isCountryCodeOne() {
        // Phone is in US, Canada, Puerto Rico if it is 10 digits or 11 digits beginning with 1
        return this.beforeExtensionClean.length() == 10 || (this.beforeExtensionClean.length() == 11 && this.beforeExtensionClean.startsWith('1'));
    }

    // getCountryDialCode - parses the rest of the phone number
    //
    // Note: This is greedy towards considering a number to be within country code of '1'
    //
    // @set areaCode -- the phone's area code if area code is a member of Area_Code__mdt
    // @set lineNumber -- the phone's 7 digits between the area code and the extension
    // @set isValidNumber -- true for country code 1 numbers with a valid area code
    // @set isUsNumber -- true for country code 1 numbers with a US area code
    // @set timezoneOffset -- set based on Area Code. Set to null if Area Code is not timezone specific such as '800'
    void getCountryDialCode() {
        if (this.isCountryCodeOne()) {
            this.countryDialCode = '1';
            
            if (this.beforeExtensionClean.length() == 10) {
                this.tenDigit = this.beforeExtensionClean;
            }
            else {
                this.tenDigit = this.beforeExtensionClean.substring(1, 11);
            }
            this.areaCode = this.tenDigit.substring(0, 3);
            this.lineNumber = this.tenDigit.substring(3, 10);
            List<Area_Code__mdt> areaCodeMdtList = [SELECT State_Code__c, Country_Code__c, Timezone_Offset__c FROM Area_Code__mdt WHERE Label = :this.areaCode LIMIT 1];
            if (areaCodeMdtList.size() != 0) {
                Area_Code__mdt areaCodeMdt = areaCodeMdtList.get(0);
                this.isValidNumber = true;
                this.countryIsoCode = areaCodeMdt.Country_Code__c;
                if (this.countryIsoCode == 'US') {
                    this.isUsNumber = true;
                }
                this.stateIsoCode = areaCodeMdt.State_Code__c;
                if (areaCodeMdt.Timezone_Offset__c != null) {
                    this.timezoneOffset = Integer.valueOf(areaCodeMdt.Timezone_Offset__c);
                }
            }
        }
    }

    // getCountryDialCode - sets the phone's canonical representation including extension
    //
    // @set canonicalPhone -- the phone's canonical representation within Salesforce
    // Note: canonicalPhone is a good candidate for matching rules/uniqueness criteria
    void getCanonicalPhone() {
        if (this.areaCode != null) {
            this.canonicalPhone = this.countryDialCode + ' ' + this.areaCode + ' ' + this.lineNumber;
            if (this.extension != null) {
                this.canonicalPhone += ' x ' + this.extension;
            }
        }
    }
}