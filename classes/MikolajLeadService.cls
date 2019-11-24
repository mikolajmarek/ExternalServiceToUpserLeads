@ RestResource(urlMapping = '/MikolajLeadService/v1.0/*')
global with sharing class MikolajLeadService {
	//endpoint string for workbench: /services/apexrest/MikolajLeadService/v1.0/
    
    @HttpPut
	global static void upsertLeads() {
        @testVisible
        String input = RestContext.request.requestBody.toString();
	    List <Lead> leadsToInsertUpsert = new List <Lead>();
        List <LeadWrapper> recivedLeads = new List <LeadWrapper>(); 
        List <ResponseWrapper> respones = new List<ResponseWrapper>();
        try {
            recivedLeads = (List <LeadWrapper>)JSON.deserialize(input, List <LeadWrapper>.class);
        
            for (LeadWrapper lw: recivedLeads){
                leadsToInsertUpsert.add(leadBuilderFromLeadWrapper(lw));
            }
        
            Database.UpsertResult[] results = Database.upsert(leadsToInsertUpsert, Lead.UUID__c, false);
            for(Integer i = 0; i < results.size(); i++) {
                if(results[i].isSuccess()) {
                    if(results[i].isCreated()) {
                        System.debug(leadsToInsertUpsert[i].UUID__c +' was created');
                        ResponseWrapper rw = new ResponseWrapper();
                        rw.id = leadsToInsertUpsert[i].UUID__c; 
                        rw.Success = String.valueOf(results[i].isSuccess()); 
                        rw.message = 'Created';
                        respones.add(rw);
                    } else {
                        System.debug(leadsToInsertUpsert[i].UUID__c +' was updated');
                        ResponseWrapper rw = new ResponseWrapper();
                        rw.id = leadsToInsertUpsert[i].UUID__c; 
                        rw.Success = String.valueOf(results[i].isSuccess()); 
                        rw.message = 'Updated';
                        respones.add(rw);
                    }
                } else{
                    ResponseWrapper rw = new ResponseWrapper();
                    System.debug(leadsToInsertUpsert[i].UUID__c +' was wroong sth');
                        rw.id = leadsToInsertUpsert[i].UUID__c; 
                        rw.Success = String.valueOf(results[i].isSuccess()); 
                        rw.message = results[i].getErrors().get(0).getMessage();
                        respones.add(rw);                        
                }
            }
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respones));    
        } catch (Exception e)  {
            RestContext.response.addHeader('Content-Type', 'text/plain');
            RestContext.response.responseBody = Blob.valueOf('Something went wrong: ' + e.getMessage());
        }   
        
    }

    private static Lead leadBuilderFromLeadWrapper (LeadWrapper lw){
        Lead lead = new Lead();
        lead.UUID__c = lw.id;
        lead.Created_Date__c = (DateTime)JSON.deserialize(lw.createdDate,DateTime.class);
        lead.FirstName = lw.firstName;
        lead.LastName = lw.lastname;
        lead.Phone = lw.phone;
        
        //Adress:
        lead.Street = lw.address.street;
        lead.City = lw.address.city;
        lead.PostalCode = lw.address.postalcode;
        lead.Country = lw.address.country;
        //Dummy Lead fields:
        lead.company = 'No company';

        return lead;
    } 
    
    public class ResponseWrapper{
        private String id;
        private String Success;
        private String message;
    }
    
	public class LeadWrapper {
		      private String id;
		      private String createdDate;
		      private String firstName;
		      private String lastName;
		      private String phone;
		      private AddressWrapper address;
		      }
		      public class AddressWrapper {
		      private String street;
		      private String city;
		      private String postalcode;
		      private String country;

		      }
}