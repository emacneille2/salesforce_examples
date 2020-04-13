@istest(seealldata = false)
public class PhoneParsingServiceTest {
    public PhoneParsingServiceTest() {}

    @istest
    static void testGetExtension() {

        Map<String, String> answers = new Map<String, String> {
            '222-121-1212x1232' => '1232'
            , '213-422-2122' => null
            , '222-121-1212x' => null
            , '222-121-1212x 12d#21' => '1221'
            , '12 222-121-1212 EXT. 12d21' => '1221'
            , '222-121-121 EXT. 12d21' => '1221'
            , '222-121-121 EXT. ssdwdd' => null
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.extension, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetCountryDialCode() {

        Map<String, String> answers = new Map<String, String> {
            '222-121-1212x1232' => '1'
            , '213-422-2122' => '1'
            , '222-121-1212x' => '1'
            , '222-121-1212x 12d#21' => '1'
            , '12 222-121-1212 EXT. 12d21' => null
            , '222-121-121 EXT. 12d21' => null
            , '222-121-121 EXT. ssdwdd' => null
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.countryDialCode, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetTenDigit() {

        Map<String, String> answers = new Map<String, String> {
            '222-121-1212x1232' => '2221211212'
            , '213-422-2122' => '2134222122'
            , '222-121-1212x' => '2221211212'
            , '222-121-1212x 12d#21' => '2221211212'
            , '12 222-121-1212 EXT. 12d21' => null
            , '+1 222-121-121 EXT. 12d21' => '1222121121'
            , '+1 222-121-1211 EXT. ssdwdd' => '2221211211'
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.tenDigit, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetAreaCode() {

        Map<String, String> answers = new Map<String, String> {
            '222-121-1212x1232' => '222'
            , '213-422-2122' => '213'
            , '222-121-1212x' => '222'
            , '222-121-1212x 12d#21' => '222'
            , '12 222-121-1212 EXT. 12d21' => null
            , '+1 222-121-121 EXT. 12d21' => '122'
            , '+1 222-121-1211 EXT. ssdwdd' => '222'
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.areaCode, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetStateCode() {

        Map<String, String> answers = new Map<String, String> {
            '224-121-1212x1232' => 'IL'
            , '218-422-2122' => 'MN'
            , '1249-121-1212x' => 'ON'
            , '254-121-1212x 12d#21' => 'TX'
            , '12 222-121-1212 EXT. 12d21' => null
            , '+1 456-121-121 EXT. 12d21' => null
            , '+1 479-121-1211 EXT. ssdwdd' => 'AR'
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.stateIsoCode, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetCountryCode() {

        Map<String, String> answers = new Map<String, String> {
            '224-121-1212x1232' => 'US'
            , '218-422-2122' => 'US'
            , '1249-121-1212x' => 'CA'
            , '254-121-1212x 12d#21' => 'US'
            , '12 222-121-1212 EXT. 12d21' => null
            , '+1 456-121-1211 EXT. 12d21' => 'US'
            , '+1 479-121-1211 EXT. ssdwdd' => 'US'
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.countryIsoCode, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetIsValidNumber() {

        Map<String, Boolean> answers = new Map<String, Boolean> {
            '222-121-1212x1232' => false
            , '213-422-2122' => true
            , '479-121-1212x' => true
            , '479-121-1212x 12d#21' => true
            , '12 222-121-1212 EXT. 12d21' => false
            , '+1 478-121-121 EXT. 12d21' => false
            , '+1 478-121-1211 EXT. ssdwdd' => true
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.isValidNumber, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetIsUsNumber() {

        Map<String, Boolean> answers = new Map<String, Boolean> {
            '224-121-1212x1232' => true
            , '218-422-2122' => true
            , '1249-121-1212x' => false
            , '254-121-1212x 12d#21' => true
            , '12 222-121-1212 EXT. 12d21' => false
            , '+1 456-121-1211 EXT. 12d21' => true
            , '+1 479-121-1211 EXT. ssdwdd' => true
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.isUsNumber, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetTimezoneOffset() {

        Map<String, Integer> answers = new Map<String, Integer> {
            '213-121-1212x1232' => -8
            , '218-422-2122' => -6
            , '1249-121-1212x' => -5
            , '254-121-1212x 12d#21' => -6
            , '12 222-121-1212 EXT. 12d21' => null
            , '+1 456-121-1211 EXT. 12d21' => null
            , '+1 479-121-1211 EXT. ssdwdd' => -6
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.timezoneOffset, 'failure on example ' + String.valueOf(index));
        }
    }

    @istest
    static void testGetPhoneCanonical() {

        Map<String, String> answers = new Map<String, String> {
            '213-121-1212x1232' => '1 213 1211212 x 1232'
            , '218-422-2122' => '1 218 4222122'
            , '1249-121-1212x' => '1 249 1211212'
            , '254-121-1212x 12d#21' => '1 254 1211212 x 1221'
            , '12 222-121-1212 EXT. 12d21' => null
            , '+1 456-121-1211 EXT. 12d21' => '1 456 1211211 x 1221'
            , '+1 479-121-1211 EXT. ssdwdd' => '1 479 1211211'
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            PhoneParsingService phoneParsingService = new PhoneParsingService(itemToTest);
            System.assertEquals(answers.get(itemToTest), phoneParsingService.canonicalPhone, 'failure on example ' + String.valueOf(index));
        }
    }
}