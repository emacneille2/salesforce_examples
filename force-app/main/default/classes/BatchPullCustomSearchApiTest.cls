@istest(seealldata = false)
public class BatchPullCustomSearchApiTest {
    public BatchPullCustomSearchApiTest() {
    }

    /*@istest
    static public void testParseGoogleCustomSearchResponse() {
        String testResponse = '{"items" : [{"title": "Michigan Barber School", "link": "http://michiganbarberschool.org/"},{"title": "LARA - Barbers", "link": "https://www.michigan.gov/lara/0,4601,7-154-89334_72600_72602_72731_72861---,00.html"}]}';
        //List<Map<String, Map<String, Object>>> responseObject = BatchPullCustomSearchApi.parseGoogleCustomSearchResult(testResponse);
        System.assert(false, String.valueOf(BatchPullCustomSearchApi.parseGoogleCustomSearchResult(testResponse)));
    }*/

    @istest
    static void testGetDomain() {

        Map<String, String> answers = new Map<String, String> {
            'https://www.umich.edu/students.html' => 'umich.edu'
            , 'http://google.com/students.html' => 'google.com'
            , 'https://www.umich.edu' => 'umich.edu'
            , 'http://www.umich.edu' => 'umich.edu'
            , 'https://umich.edu' => 'umich.edu'  
            , 'http://umich.edu' => 'umich.edu'
            , 'http://www.students.umich.edu' => 'umich.edu'
            , 'http://www.students.umich.ed/students.html' => 'umich.ed'
        };

        Integer index = 0;
        for (String itemToTest : answers.keyset()) {
            index += 1;
            System.assertEquals(answers.get(itemToTest), BatchPullCustomSearchApi.getDomain(itemToTest), 'failure on example ' + String.valueOf(index));
        }
    }
}