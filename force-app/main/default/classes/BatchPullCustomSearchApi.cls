/*
* BatchPullCustomSearchApi
*
* Batchable, schedulable class to pull the search API on keywords that haven't run in 30 days. Uploads Ranking__c objects 
* for every result and Domain__c objects as needed
* 
* @documentation https://developers.google.com/custom-search/v1/overview
* API can be run 100 times daily for free, then up to 10,000 times daily for $5 per 1000 runs
*/
global class BatchPullCustomSearchApi implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {
    
    // constructor for BatchPullCustomSearchApi
    public BatchPullCustomSearchApi() {}

    // Class can be scheduled to run nightly, it will only pull in Keywords that havent run in 30 days
    // 
    // below will schedule the class to run daily @11 PM
    // System.schedule('BatchPullCustomSearchApi', '0 0 23 * * ?', new BatchPullCustomSearchApi());
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchPullCustomSearchApi(), 1);
    }

    // Queries all Keywords that haven't had a Custom Search Result uploaded in 30 days
    global Database.QueryLocator start(Database.BatchableContext BC) {
            Integer daysBetweenRefresh = 30;
            return Database.getQueryLocator('SELECT Keyword__c, Id FROM Keyword__c WHERE Last_Custom_Search_Date__c != LAST_N_DAYS:' + String.valueOf(daysBetweenRefresh));
    }   

    // getDomain -- parses domain from link
    //
    // simplified URL parsing to get domain, doesn't support multi tier suffixes *yet*
    //
    // @param link -- the url including the scheme (ie. http://)
    // @return the domain of the URL
    public static String getDomain(String link) {
        String toFind = '://';
        Integer pos = link.indexOf(toFind);
        link = link.substring(pos + toFind.length(), link.length());
        toFind = '/';
        pos = link.indexOf(toFind);
        if (pos == -1) {
            pos = link.length();
        }
        link = link.substring(0, pos);
        List<String> domainParts = link.split('\\.');
        return domainParts.get(domainParts.size() - 2) + '.' + domainParts.get(domainParts.size() - 1);
    }
           
    // execute -- runs a single batch of the job
    //
    // inserts Ranking__c and DOmain__c objects as needed
    //
    // @param BC -- the batchable context
    // @param keywords -- List of keywords being processed
    global void execute(Database.BatchableContext BC, List<Keyword__c> keywords){
        for (Keyword__c keyword : keywords){
            List<Map<String, String>> response = BatchPullCustomSearchApi.getGoogleCustomSearch(keyword.Keyword__c);
            Map<String, Map<String, String>> domainsToget = new Map<String, Map<String, String>>();
            for (Map<String, String> item : response) {
                String domain = BatchPullCustomSearchApi.getDomain(item.get('link'));
                domainsToGet.put(domain, item);
            }
            List<Domain__c> domains = [SELECT Id, Domain__c FROM Domain__c WHERE Domain__c IN :domainsToGet.keySet()];
            Map<String, Domain__c> domainsPresent = new Map<String, Domain__c>();
            for (Domain__c domain : domains) {
                domainsPresent.put(domain.Domain__c, domain);
            }
            List<Domain__c> domainsToCreate = new List<Domain__c>();
            for (String domain : domainsToGet.keySet()) {
                if (!domainsPresent.containsKey(domain) ){
                    domainsToCreate.add(new Domain__c(Domain__c = domain, Name = domain));
                }
            }
            if (!domainsToCreate.isEmpty()) {
                insert domainsToCreate;
            }
            //now contains full list of Domains present in search result
            domains = [SELECT Id, Domain__c FROM Domain__c WHERE Domain__c IN :domainsToGet.keySet()];
            domainsPresent = new Map<String, Domain__c>();
            for (Domain__c domain : domains) {
                domainsPresent.put(domain.Domain__c, domain);
            }
            List<Ranking__c> rankingsToCreate = new List<Ranking__c>();
            Integer index = 0;
            for (String domain : domainsToget.keySet()) {
                index += 1;
                String name = String.valueOf(index) + ' ' + keyword.Keyword__c + ' ' + domain;
                name = name.substring(0, Math.min(80, name.length()));
                rankingsToCreate.add(
                    new Ranking__c(
                        Name = name
                        , Keyword__c = keyword.Id
                        , Domain__c = domainsPresent.get(domain).Id
                        , Rank__c = index
                        , URL__c = domainsToGet.get(domain).get('link')
                        , Title__c = domainsToGet.get(domain).get('title')
                        , Type__c = 'Google Organic'
                    )
                );
            }
            insert rankingsToCreate;
        }
    }

    // finish -- called after final batch is processed
    global void finish(Database.BatchableContext BC) {}
    
    // parseGoogleCustomSearchResult -- returns map of search results given API Json response
    //
    // @param inJson -- raw response from Google Custom Search API
    // @return List<Map<String, String>> containing search result items, ie. link, title of search results. Order of list is the 
    // rank of that item 
    static public List<Map<String, String>> parseGoogleCustomSearchResult(String inJson) {
        Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(inJson);
        List<Object> items = (List<Object>) json.get('items');
        List<Map<String, String>> answer = new List<Map<String, String>>();
        for (Object item : items) {
            answer.add(
                new Map<String, String>{
                    'link' => (String) ((Map<String, Object>) item).get('link')
                    , 'title' => (String) ((Map<String, Object>) item).get('title')
                }
            );
        }
        return answer;
    }

    // getGoogleCustomSearch -- returns map of search results given Keyword to search
    //
    // Note: references private Custom Setting where credentials are stored.
    //
    // @param keyword -- raw text of keyword(s) to search
    // @return List<Map<String, String>> containing search result items, ie. link, title of search results. Order of list is the 
    // rank of that item 
    static List<Map<String, String>> getGoogleCustomSearch(String keyword) {
        // return 'response for "' + keyword + '"';
        List<Map<String, String>> results = new List<Map<String, String>>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        API_Credential__c key = [SELECT Secret__c FROM API_Credential__c WHERE Name = 'Google_Custom_Search_Key' LIMIT 1];
        API_Credential__c customEngineId = [SELECT Secret__c FROM API_Credential__c WHERE Name = 'Google_Custom_Search_Engine_Id' LIMIT 1];
        request.setEndpoint('https://www.googleapis.com/customsearch/v1?cx=' + customEngineId.Secret__c + '&key=' + key.Secret__c + '&q=' + EncodingUtil.urlEncode(keyword, 'UTF-8'));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            results = parseGoogleCustomSearchResult(response.getBody());
        }
        return results;
    }

    // getGoogleCustomSearch2 -- method used for initial testing only
    static List<Map<String, String>> getGoogleCustomSearch2(String keyword) {
        return parseGoogleCustomSearchResult('{"items" : [{"title": "Michigan Barber School", "link": "http://michiganbarberschool.org/"},{"title": "LARA - Barbers", "link": "https://www.michigan.gov/lara/0,4601,7-154-89334_72600_72602_72731_72861---,00.html"}]}');
    }
}
