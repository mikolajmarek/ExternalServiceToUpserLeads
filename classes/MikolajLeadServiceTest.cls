@IsTest
private class MikolajLeadServiceTest {
    
    Final Static String SERVICE_URL = System.URL.getSalesforceBaseURL().toExternalForm()+ '/MikolajLeadService/v1.0/';
    //for insert of 2 new Leads
    Final Static String CORRECT_INSERT_TWO_LEADS = '[{"id" : "testId_1","createddate" : " 2019-11-24T11:00:00.000-0700","firstname" : "firstname1","lastname" : "lastname1","phone" : "123456789","address" : {"street" : "street1","city" : "Krakow","postalcode" : "112233","country" : "PL"}},{"id" : "test_ID2","createddate" : " 2019-11-24T10:00:45.000-0700" ,"firstname" : "firstname2","lastname" : "lastname2","phone" : "987654321","address" : {"street" : "street 2","city" : "Warsaw","postalcode" : "22222","country" : "POLand"}}]';
    // for upde one lead, one is missing data
    Final Static String CORRECT_UPDATE_AND_INCORRECT_INSERT = '[{"id" : "testId_1","createddate" : " 2019-11-24T11:00:00.000-0700","firstname" : "updated_name_1","lastname" : "updated_lastname_1","phone" : "123456789","address" : {"street" : "street1","city" : "Krakow","postalcode" : "112233","country" : "PL"}},{"id" : "test_ID2","createddate" : " 2019-11-24T10:00:45.000-0700" ,"firstname" : "firstname2","lastname" : "lastname2","phone" : null,"address" : {"street" : "street 2","city" : "Warsaw","postalcode" : "22222","country" : "POLand"}}]';
    // malformed JSON
    Final Static String MALFORMED_JSON_INSERT = '[{"idd" : "testId_1","createddate" : " 2019-11-24T11:00:00.000-0700","firstname" : "updated_name_1","lastname" : "updated_lastname_1","phone" : "123456789","address" : {"street" : "street1","city" : "Krakow","postalcode" : "112233","country" : "PL"}}]';
    //correct response for first JSON - insert
    Final Static String RESPONSE_FOR_CORRECT_INSERT_TWO_LEADS = '[{"Success":"true","message":"Created","id":"testId_1"},{"Success":"true","message":"Created","id":"test_ID2"}]';
    //correct response for second JSON - update&incorrect input
    Final Static String RESPONSE_FOR_CORRECT_UPDATE_AND_INCORRECT_INSERT = '[{"Success":"true","message":"Updated","id":"testId_1"},{"Success":"false","message":"Missing Required fields - Last Name, id or phone","id":"test_ID2"}]';     
    //malformed JSON response for missing UUIC__c
    Final Static String RESPONSE_FOR_MALFORMED_JSON = '[{"Success":"false","message":"UUID__c not specified","id":null}]';
    @isTest 
    static void testUpsertLeads(){
        
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/MikolajLeadService/v1.0/';
        RestContext.request.addHeader('content-type', 'application/json');
        
        //run for correct insert of two leads
        RestContext.request.requestBody = Blob.valueof( CORRECT_INSERT_TWO_LEADS );
        MikolajLeadService.upsertLeads();
        System.assertEquals(RESPONSE_FOR_CORRECT_INSERT_TWO_LEADS, RestContext.response.responseBody.toString());

        //run for update operation and broken lead
        RestContext.request.requestBody = Blob.valueof( CORRECT_UPDATE_AND_INCORRECT_INSERT );
        MikolajLeadService.upsertLeads();
        System.assertEquals(RESPONSE_FOR_CORRECT_UPDATE_AND_INCORRECT_INSERT, RestContext.response.responseBody.toString());

        //run for malformed JSON
        RestContext.request.requestBody = Blob.valueof( MALFORMED_JSON_INSERT );
        MikolajLeadService.upsertLeads();
        System.assertEquals(RESPONSE_FOR_MALFORMED_JSON, RestContext.response.responseBody.toString());	

        //run with empty response
        RestContext.request.requestBody = Blob.valueof( '' );
        
        try{
            MikolajLeadService.upsertLeads();
        } catch (Exception e)  {
            String message = e.getMessage();
            System.assert(message.contains('Something went wrong'));            
        }  	
        
    }
}