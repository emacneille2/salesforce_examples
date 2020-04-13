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

    public Integer timezoneOffset = null;

    public PhoneParsingService(String phone) {
        init(phone);
    }

    void init(String Phone) {
        this.rawPhone = phone;
        this.getExtension();
        this.getCountryDialCode();
        this.getCanonicalPhone();
    }

    static String getNumeric(String inString) {
        String answer = '';
        for (String charInString: inString.split('')) {
            if (charInString.isNumeric()) {
                answer += charInString;
            }
        }
        return answer;
    }

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

    Boolean isCountryCodeOne() {
        // Phone is in US, Canada, Puerto Rico if it is 10 digits or 11 digits beginning with 1
        return this.beforeExtensionClean.length() == 10 || (this.beforeExtensionClean.length() == 11 && this.beforeExtensionClean.startsWith('1'));
    }

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

    void getCanonicalPhone() {
        if (this.areaCode != null) {
            this.canonicalPhone = this.countryDialCode + ' ' + this.areaCode + ' ' + this.lineNumber;
            if (this.extension != null) {
                this.canonicalPhone += ' x ' + this.extension;
            }
        }
    }
}