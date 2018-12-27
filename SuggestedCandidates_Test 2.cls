@istest
    Private class SuggestedCandidates_Test implements HttpCalloutMock {
        
            
        private HttpResponse resp;
        public HTTPResponse respond(HTTPRequest req) {
            return resp;}
        public SuggestedCandidates_Test(String testBody) {resp = new HttpResponse();
        resp.setBody(testBody);
        resp.setStatusCode(200);}
        
        @testSetup static void setup() {
        
            // Virtually Inserting Client
            Account aa = new Account();
            aa.Name = 'Client';
            aa.BillingStreet='28 Sheerwater Drive';
            aa.BillingCity='Northampton';
            aa.BillingState = 'Northamptonshire';
            aa.BillingCountry='United Kingdom';
            aa.BillingPostalCode='NN3 5HU';
            insert aa;
            System.assert(aa.id!=null);
            
            
            // Virtually Inserting Contact
            Contact con  = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'contact';
            con.AccountId = aa.id;
            insert con;
            System.assert(con.id!=null);
        
          // Create common test Account
          String RecTypeId= [select Id from RecordType where (Name='Candidate') and (SobjectType='Account')].Id;
             //List<Account> acclist = new List<Account>();
             // Virtually Inserting Person account
            Account Accnt = new Account();
            Accnt.RecordTypeID=RecTypeId;
            Accnt.FirstName='FName';
            Accnt.LastName='LName';
            Accnt.Salutation='Mr';
            Accnt.PersonMailingStreet='11111';
            Accnt.PersonMailingPostalCode='12345';
            Accnt.PersonMailingCity='SFO';
            Accnt.BusinessName__pc = 'Paye';
            Accnt.PersonEmail='charu.rani4@birlasoft.com';
            Accnt.BankAccountNumber__pc='12345678';
            Accnt.PersonHomePhone='1234567';
            Accnt.PersonMailingState = 'Bedfordshire';
            //acclist.add(Accnt);
            insert Accnt;
            System.assert(Accnt.id!=null);
            
            // Virtually Inserting Job
            Job__c j = new Job__c(External_Reference__c='Client',Engagement_Type__c = 'Permanent',
                               Client_Name__c=aa.id,Location__c='gsdghds',Live_Roles__c = 1,No_of_Vacancies__c=1,
                               Working_Hours__c = 4.0,On_Site_Contact__c = con.id,Date_Vacancy_Received__c = date.today(),
                               Job_Status__c = 'Open',Status__c ='Published' ); 
            insert j;
            System.assert(j.id!=null);
            Decimal ClientLatitude = j.Client_Name__r.Geolocation__Latitude__s;
            Decimal ClientLongitude = j.Client_Name__r.Geolocation__Longitude__s;
            
            // Virtually Inserting Account Tag Public
            list<AccountTag> AccountTaglist=new List<AccountTag>();
            AccountTag Accounttag=new AccountTag();
            Accounttag.Name = 'Diligenta';
            Accounttag.itemid = Accnt.id;
            Accounttag.type = 'Public';
            AccountTaglist.add(Accounttag);
            insert AccountTaglist;
            Integer candidatePublIcTagSize =  AccountTaglist.size();
            
            // Virtually Inserting Account Tag Personal
            list<AccountTag> AccountTaglistPersonal=new List<AccountTag>();
            AccountTag AccounttagPersonal=new AccountTag();
            AccounttagPersonal.Name = 'Diligenta';
            AccounttagPersonal.itemid = Accnt.id;
            AccounttagPersonal.type = 'Personal';
            AccountTaglistPersonal.add(AccounttagPersonal);
            insert AccountTaglistPersonal;
            Integer candidatePersonalTagSize =  AccountTaglistPersonal.size();
            
            // Virtually Inserting Job Tag Public
            List<Job__Tag> Job_TagPublic = new List<Job__Tag>();
            Job__Tag jobtag=new Job__Tag();
            jobtag.Name = 'Diligenta';
            jobtag.itemid = j.id;
            jobtag.type = 'Public';
            Job_TagPublic.add(jobtag);
            insert Job_TagPublic;           
            Integer jobPublicTagSize = Job_TagPublic.size();
            
            // Virtually Inserting Job Tag Personal
            list<Job__Tag> Job_TaglstPersonal=new List<Job__Tag>();
            Job__Tag jobtagPersonal=new Job__Tag();
            jobtagPersonal.Name = 'Diligenta';
            jobtagPersonal.itemid = j.id;
            jobtagPersonal.type = 'Personal';
            Job_TaglstPersonal.add(jobtagPersonal);
            insert Job_TaglstPersonal;          
            Integer jobPersonalTagSize = Job_TaglstPersonal.size();         
        }
        
         @istest static void SuggestedCandidates_Testmethod() {
         
             // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
            
            string testbody = '{"results" : [   {"address_components" : [   {"long_name" : "28","short_name" : "28","types" : [ "street_number" ]   },   {"long_name" : "Sheerwater Drive","short_name" : "Sheerwater Dr","types" : [ "route" ]   },   {"long_name" : "Northampton","short_name" : "Northampton","types" : [ "locality", "political" ]   },   {"long_name" : "Northampton","short_name" : "Northampton","types" : [ "postal_town" ]   },   {"long_name" : "Northamptonshire","short_name" : "Nhants","types" : [ "administrative_area_level_2", "political" ]   },   {"long_name" : "United Kingdom","short_name" : "GB","types" : [ "country", "political" ]   },   {"long_name" : "NN3 5HU","short_name" : "NN3 5HU","types" : [ "postal_code" ]   }],"formatted_address" : "28 Sheerwater Drive, Northampton, Northamptonshire NN3 5HU, UK","geometry" : {   "location" : {"lat" : 52.2616062,"lng" : -0.8029021   },   "location_type" : "ROOFTOP",   "viewport" : {"northeast" : {   "lat" : 52.2629551802915,   "lng" : -0.8015531197084979},"southwest" : {   "lat" : 52.2602572197085,   "lng" : -0.8042510802915019}   }},"place_id" : "ChIJxd6P65IJd0gRWjiRCjDFsJ8","types" : [ "street_address" ]   }],"status" : "OK"}';
            HttpCalloutMock mock = new SuggestedCandidates_Test(testBody);
            Test.setMock(HttpCalloutMock.class, mock);
            LocationCallouts loccallouts = new LocationCallouts();
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='100';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='100';
            scg.DistanceinMiles='10.4';
            
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodgreaterthan() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodgreatrthanorequalto() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>=10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>=10';
            scg.DistanceinMiles='>=10.4';
            
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodlessthan() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='<80';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='<80';
            scg.DistanceinMiles='<10.4';
            
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodlessthanorqualto() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore= '<=80';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.DistanceinMiles= '<=10.4';
            
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodnotequalto() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='!=100';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='!=100';
            scg.DistanceinMiles='!=10.4';
            
            scg.filterdata();
         }
         
         private static testMethod void SuggestedCandidates_Testmethodequalto() {
             
            // Virtually Inserting Client
            Account aa = new Account();
            aa.Name = 'Client';
            aa.BillingStreet='28 Sheerwater Drive';
            aa.BillingCity='Northampton';
            aa.BillingState = 'Northamptonshire';
            aa.BillingCountry='United Kingdom';
            aa.BillingPostalCode='NN3 5HU';
            insert aa;
            System.assert(aa.id!=null);
            
            
            // Virtually Inserting Contact
            Contact con  = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'contact';
            con.AccountId = aa.id;
            insert con;
            System.assert(con.id!=null);
            
            String RecTypeId= [select Id from RecordType where (Name='Candidate') and (SobjectType='Account')].Id;
             //List<Account> acclist = new List<Account>();
             // Virtually Inserting Person account for Band 8
            Account Accnt = new Account();
            Accnt.RecordTypeID=RecTypeId;
            Accnt.FirstName='Test FName';
            Accnt.LastName='Test LName';
            Accnt.Salutation='Mr';
            Accnt.PersonEmail='charu.rani4sss@birlasoft.com';
            Accnt.PersonMailingStreet='28 Sheerwater Drive';
            Accnt.BusinessName__pc = 'PAYE';
            Accnt.PersonMailingCity='Northampton';
            Accnt.PersonMailingState = 'Northamptonshire';
            Accnt.PersonMailingCountry='United Kingdom';
            Accnt.PersonMailingPostalCode='NN3 5HU';
            //acclist.add(Accnt);
            insert Accnt;
            Decimal CandidateLatitude = 51.521238;
            Decimal CandidateLongitude = -0.052638;
            
            
            Account Accnt1 = new Account();
            Accnt1.RecordTypeID=RecTypeId;
            Accnt1.FirstName='Test FName';
            Accnt1.LastName='Test LName';
            Accnt1.PersonMailingStreet='11111';
            Accnt1.PersonMailingPostalCode='12345';
            Accnt1.PersonMailingCity='SFO';
            Accnt1.PersonEmail='charu.rani34ddd@birlasoft.com';
            Accnt1.PersonHomePhone='1234567';
            Accnt1.Salutation='Mr';
            Accnt1.BusinessName__pc = 'PAYE';
            Accnt1.PersonMailingState = 'Bedfordshire';
            Accnt1.BillingStreet='28 Sheerwater Drive';
            Accnt1.BillingCity='Northampton';
            Accnt1.BillingState = 'Northamptonshire';
            Accnt1.BillingCountry='United Kingdom';
            Accnt1.BillingPostalCode='NN3 5HU';
            //acclist.add(Accnt1);
            insert Accnt1;
            
            System.assert(Accnt.id!=null);
            
            // Virtually Inserting Job
            Job__c j = new Job__c(Job_Title__c='Devel',External_Reference__c='Client',Engagement_Type__c = 'Permanent',
                               Client_Name__c=aa.id,Location__c='gsdghds',Live_Roles__c = 1,No_of_Vacancies__c=1,
                               Working_Hours__c = 4.0,On_Site_Contact__c = con.id,Date_Vacancy_Received__c = date.today(),
                               Job_Status__c = 'Open',Status__c ='Published' ); 
            insert j;
            System.assert(j.id!=null);
            Decimal ClientLatitude = 51.521238;
            Decimal ClientLongitude = -0.052638;
            
            // Virtually Inserting Application
            Application__c app = new Application__c();
            app.Candidate__c = Accnt.id;
            app.Job__c = j.Id;
           
            app.Broadbean_Applicant_Name__c ='testname';
            app.Source__c ='Job Fair';
            app.Submission_Outcome__c='1st Interview';
            app.X1st_Interview_Outcome__c='2nd Interview';
            app.New_AWR_Core_Code__c = 'ADM';   
            app.Date_Submitted__c = system.today()-7;
            app.Late_Assignments_Flag__c ='No';
            insert app;
            
            // Virtually Inserting Attachment
            Attachment attach = new Attachment();
            attach.Parentid = j.id;
            attach.Name='Job Description';
            attach.body=Blob.valueOf('dghfdghfsddfh');
            insert attach;
            
            // Virtually Inserting Account Tag Public
            list<AccountTag> AccountTaglist=new List<AccountTag>();
            AccountTag Accounttag=new AccountTag();
            Accounttag.Name = 'Diligenta';
            Accounttag.itemid = Accnt.id;
            Accounttag.type = 'Public';
            AccountTaglist.add(Accounttag);
            
            AccountTag Accounttag1=new AccountTag();
            Accounttag1.Name = 'Diligenta';
            Accounttag1.itemid = Accnt1.id;
            Accounttag1.type = 'Public';
            AccountTaglist.add(Accounttag1);
            
            insert AccountTaglist;
            Integer candidatePublIcTagSize =  AccountTaglist.size();
            
            list<String> AccountTaglistPublicString = new list<String>();
            for(AccountTag acctag : AccountTaglist){
                AccountTaglistPublicString.add(acctag.Name);
            }
            
            // Virtually Inserting Account Tag Personal
            list<AccountTag> AccountTaglistPersonal=new List<AccountTag>();
            AccountTag AccounttagPersonal=new AccountTag();
            AccounttagPersonal.Name = 'Diligenta';
            AccounttagPersonal.itemid = Accnt.id;
            AccounttagPersonal.type = 'Personal';
            AccountTaglistPersonal.add(AccounttagPersonal);
            insert AccountTaglistPersonal;
            Integer candidatePersonalTagSize =  AccountTaglistPersonal.size();
            
            list<String> AccountTaglistPersonalString = new list<String>();
            for(AccountTag acctag : AccountTaglistPersonal){
                AccountTaglistPersonalString.add(acctag.Name);
            }
            
            // Virtually Inserting Job Tag Public
            List<Job__Tag> Job_TagPublic = new List<Job__Tag>();
            Job__Tag jobtag=new Job__Tag();
            jobtag.Name = 'Diligenta';
            jobtag.itemid = j.id;
            jobtag.type = 'Public';
            Job_TagPublic.add(jobtag);
            insert Job_TagPublic;           
            Integer jobPublicTagSize = Job_TagPublic.size();
            
            // Virtually Inserting Job Tag Personal
            list<Job__Tag> Job_TaglstPersonal=new List<Job__Tag>();
            Job__Tag jobtagPersonal=new Job__Tag();
            jobtagPersonal.Name = 'Diligenta';
            jobtagPersonal.itemid = j.id;
            jobtagPersonal.type = 'Personal';
            Job_TaglstPersonal.add(jobtagPersonal);
            insert Job_TaglstPersonal;          
            Integer jobPersonalTagSize = Job_TaglstPersonal.size(); 
            
            ApexPages.StandardController sc = new ApexPages.StandardController(j);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            // Virtually insert Suggested Candidate record 
            Suggested_Candidates__c suggestedcandidate = new Suggested_Candidates__c();
            suggestedcandidate.Candidate_Name__c = accnt.id;
            suggestedcandidate.Desirable_Criteria_Value__c = AccountTaglistPersonal[0].Name;
            suggestedcandidate.Desirable_Criteria_Score__c = 100;
            suggestedcandidate.Essential_Criteria_Value__c = AccountTaglist[0].name;
            suggestedcandidate.Essential_Criteria_Score__c = 100;
            suggestedcandidate.Distance__c = 10.4;
            suggestedcandidate.Unique_identifier__c = accnt.id+'-'+suggestedcandidate.Candidate_Name__r.Name+'-'+j.id;
            insert suggestedcandidate;
            
            //Insert data for filter 
            scg.SearchCandidateName='Test LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='=100';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='=100';
            scg.DistanceinMiles='=10.4';            
            scg.filterdata();
            clsSuggestedCandidates.wrappercandidate wrap1 = new clsSuggestedCandidates.wrappercandidate(suggestedcandidate.Candidate_Name__c,suggestedcandidate.Candidate_Name__r.Name,suggestedcandidate.Essential_Criteria_Value__c,suggestedcandidate.Desirable_Criteria_Score__c,suggestedcandidate.Essential_Criteria_Value__c,suggestedcandidate.Essential_Criteria_Score__c,suggestedcandidate.Distance__c);
            wrap1.calculatedistanceinmiles(CandidateLatitude,CandidateLongitude,ClientLatitude,ClientLongitude);
         }
         
         private static testMethod void SuggestedCandidates_Testmethodallvalueblank() {
             
            // Virtually Inserting Client
            Account aa = new Account();
            aa.Name = 'Client';
            aa.BillingStreet='28 Sheerwater Drive';
            aa.BillingCity='Northampton';
            aa.BillingState = 'Northamptonshire';
            aa.BillingCountry='United Kingdom';
            aa.BillingPostalCode='NN3 5HU';
            insert aa;
            System.assert(aa.id!=null);
            
            
            // Virtually Inserting Contact
            Contact con  = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'contact';
            con.AccountId = aa.id;
            insert con;
            System.assert(con.id!=null);
            
            String RecTypeId= [select Id from RecordType where (Name='Candidate') and (SobjectType='Account')].Id;
             //List<Account> acclist = new List<Account>();
             // Virtually Inserting Person account for Band 8
            Account Accnt = new Account();
            Accnt.RecordTypeID=RecTypeId;
            Accnt.FirstName='Test FName';
            Accnt.LastName='Test LName';
            Accnt.PersonMailingStreet='11111';
            Accnt.PersonMailingPostalCode='12345';
            Accnt.PersonMailingCity='SFO';
            Accnt.PersonEmail='charu.rani24@birlasoft.com';
            Accnt.Salutation='Mr';
            Accnt.BusinessName__pc = 'PAYE';
            Accnt.PersonHomePhone='1234567';
            Accnt.PersonMailingState = 'Bedfordshire';
            Accnt.BillingStreet='28 Sheerwater Drive';
            Accnt.BillingCity='Northampton';
            Accnt.BillingState = 'Northamptonshire';
            Accnt.BillingCountry='United Kingdom';
            Accnt.BillingPostalCode='NN3 5HU';
            //acclist.add(Accnt);
            insert Accnt;
            System.assert(Accnt.id!=null);
            
            Account Accnt1 = new Account();
            Accnt1.RecordTypeID=RecTypeId;
            Accnt1.FirstName='Test FName';
            Accnt1.LastName='Test LName';
            Accnt1.PersonMailingStreet='11111';
            Accnt1.PersonMailingPostalCode='12345';
            Accnt1.PersonMailingCity='SFO';
            Accnt1.BusinessName__pc = 'PAYE';
            Accnt1.PersonEmail='charu.rani114@birlasoft.com';
            Accnt1.PersonHomePhone='1234567';
            Accnt1.Salutation='Mr';
            Accnt1.PersonMailingState = 'Bedfordshire';
            Accnt1.BillingStreet='28 Sheerwater Drive';
            Accnt1.BillingCity='Northampton';
            Accnt1.BillingState = 'Northamptonshire';
            Accnt1.BillingCountry='United Kingdom';
            Accnt1.BillingPostalCode='NN3 5HU';
            //acclist.add(Accnt1);
            insert Accnt1;
            
            System.assert(Accnt1.id!=null);
            
            // Virtually Inserting Job
            Job__c j = new Job__c(Job_Title__c='Devel',External_Reference__c='Client',Engagement_Type__c = 'Permanent',
                               Client_Name__c=aa.id,Location__c='gsdghds',Live_Roles__c = 1,No_of_Vacancies__c=1,
                               Working_Hours__c = 4.0,On_Site_Contact__c = con.id,Date_Vacancy_Received__c = date.today(),
                               Job_Status__c = 'Open',Status__c ='Published' ); 
            insert j;
            System.assert(j.id!=null);
            Decimal ClientLatitude = j.Client_Name__r.Geolocation__Latitude__s;
            Decimal ClientLongitude = j.Client_Name__r.Geolocation__Longitude__s;
            
            // Virtually Inserting Application
            Application__c app = new Application__c();
            app.Candidate__c = Accnt.id;
            app.Job__c = j.Id;
            app.Broadbean_Applicant_Name__c ='testname';
            app.Source__c ='Job Fair';
            app.Submission_Outcome__c='1st Interview';
            app.X1st_Interview_Outcome__c='2nd Interview';
            app.New_AWR_Core_Code__c = 'ADM';   
            app.Date_Submitted__c = system.today()-7;
            app.Late_Assignments_Flag__c ='No';
             
            insert app;
            
            // Virtually Inserting Attachment
            Attachment attach = new Attachment();
            attach.Parentid = j.id;
            attach.Name='Job Description';
            attach.body=Blob.valueOf('dghfdghfsddfh');
            insert attach;
            
            // Virtually Inserting Account Tag Public
            list<AccountTag> AccountTaglist=new List<AccountTag>();
            AccountTag Accounttag=new AccountTag();
            Accounttag.Name = 'EY';
            Accounttag.itemid = Accnt.id;
            Accounttag.type = 'Public';
            AccountTaglist.add(Accounttag);
            
            AccountTag Accounttag1=new AccountTag();
            Accounttag1.Name = 'Diligenta';
            Accounttag1.itemid = Accnt1.id;
            Accounttag1.type = 'Public';
            AccountTaglist.add(Accounttag1);
            
            /*AccountTag Accounttag2=new AccountTag();
            Accounttag2.Name = 'EY';
            Accounttag2.itemid = Accnt1.id;
            Accounttag2.type = 'Personal';
            AccountTaglist.add(Accounttag2);
            
            AccountTag Accounttag4=new AccountTag();
            Accounttag4.Name = 'Diligenta';
            Accounttag4.itemid = Accnt1.id;
            Accounttag4.type = 'Personal';
            AccountTaglist.add(Accounttag4);*/
            
            insert AccountTaglist;
            Integer candidatePublIcTagSize =  AccountTaglist.size();
            
            list<String> AccountTaglistPublicString = new list<String>();
            for(AccountTag acctag : AccountTaglist){
                if(acctag.type == 'Public'){
                    AccountTaglistPublicString.add(acctag.Name);
                }
            }
            
            // Virtually Inserting Account Tag Personal
            list<AccountTag> AccountTaglistPersonal=new List<AccountTag>();
            AccountTag AccounttagPersonal=new AccountTag();
            AccounttagPersonal.Name = 'Diligenta';
            AccounttagPersonal.itemid = Accnt.id;
            AccounttagPersonal.type = 'Personal';
            AccountTaglistPersonal.add(AccounttagPersonal);
            insert AccountTaglistPersonal;
            Integer candidatePersonalTagSize =  AccountTaglistPersonal.size();
            
            list<String> AccountTaglistPersonalString = new list<String>();
            for(AccountTag acctag : AccountTaglistPersonal){
                AccountTaglistPersonalString.add(acctag.Name);
            }
            
            // Virtually Inserting Job Tag Public
            List<Job__Tag> Job_TagPublic = new List<Job__Tag>();
            Job__Tag jobtag=new Job__Tag();
            jobtag.Name = 'Diligenta';
            jobtag.itemid = j.id;
            jobtag.type = 'Public';
            Job_TagPublic.add(jobtag);
            insert Job_TagPublic;           
            Integer jobPublicTagSize = Job_TagPublic.size();
            
            // Virtually Inserting Job Tag Personal
            list<Job__Tag> Job_TaglstPersonal=new List<Job__Tag>();
            Job__Tag jobtagPersonal=new Job__Tag();
            jobtagPersonal.Name = 'Diligenta';
            jobtagPersonal.itemid = j.id;
            jobtagPersonal.type = 'Personal';
            Job_TaglstPersonal.add(jobtagPersonal);
            insert Job_TaglstPersonal;          
            Integer jobPersonalTagSize = Job_TaglstPersonal.size(); 
            
            // Virtually Inserting Email Store
            Email_Store__c emailstore = new Email_Store__c();
            emailstore.Candidate__c = Accnt.id;
            emailstore.Job__c = j.id;
            emailstore.Type__c='Candidate';
            insert emailstore;
            System.assert(emailstore.id!=null);
            
            string testbody = '{"results" : [   {"address_components" : [   {"long_name" : "28","short_name" : "28","types" : [ "street_number" ]   },   {"long_name" : "Sheerwater Drive","short_name" : "Sheerwater Dr","types" : [ "route" ]   },   {"long_name" : "Northampton","short_name" : "Northampton","types" : [ "locality", "political" ]   },   {"long_name" : "Northampton","short_name" : "Northampton","types" : [ "postal_town" ]   },   {"long_name" : "Northamptonshire","short_name" : "Nhants","types" : [ "administrative_area_level_2", "political" ]   },   {"long_name" : "United Kingdom","short_name" : "GB","types" : [ "country", "political" ]   },   {"long_name" : "NN3 5HU","short_name" : "NN3 5HU","types" : [ "postal_code" ]   }],"formatted_address" : "28 Sheerwater Drive, Northampton, Northamptonshire NN3 5HU, UK","geometry" : {   "location" : {"lat" : 52.2616062,"lng" : -0.8029021   },   "location_type" : "ROOFTOP",   "viewport" : {"northeast" : {   "lat" : 52.2629551802915,   "lng" : -0.8015531197084979},"southwest" : {   "lat" : 52.2602572197085,   "lng" : -0.8042510802915019}   }},"place_id" : "ChIJxd6P65IJd0gRWjiRCjDFsJ8","types" : [ "street_address" ]   }],"status" : "OK"}';
            HttpCalloutMock mock = new SuggestedCandidates_Test(testBody);
            Test.setMock(HttpCalloutMock.class, mock);
            LocationCallouts loccallouts = new LocationCallouts();
            Decimal ClientLatitudeAccnt = Accnt.Geolocation__Latitude__s;
            Decimal ClientLongitudeAccnt = Accnt.Geolocation__Longitude__s;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(j);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='';         
            scg.filterdata();           
            clsSuggestedCandidates.wrappercandidate wrap = new clsSuggestedCandidates.wrappercandidate(Accnt,AccountTaglistPublicString,AccountTaglistPersonalString,jobPublIcTagSize,candidatePublIcTagSize,candidatePersonalTagSize,jobPersonalTagSize,ClientLatitude,ClientLongitude,AccountTaglistPersonalString);
            scg.wrappercandidatelist[0].isSelected = true; 
            scg.SendemailJob();
            scg.create_application();
         }
         
         @istest static void SuggestedCandidates_Testmethodwithfivevalues() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore= '<=80';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.DistanceinMiles= '<=10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodwithtwovalues() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodwiththreevalues() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodwiththreevalues_1() {
             
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfourvalues_1() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfourvalues_2() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfourvalues_3() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfourvalues_4() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfourvalues_5() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfourvalues_6() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.filterdata();
         }
         
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_1() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_2() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_3() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_4() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_5() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_6() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_7() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_8() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_9() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_10() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_11() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_12() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_13() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodfivevalues_14() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore= '<=80';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_1() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_2() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_3() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_4() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_5() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_6() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_7() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_8() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_9() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_10() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_11() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_12() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_13() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_14() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_15() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_16() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_17() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_18() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_19() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='LName';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_20() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_21() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_22() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_23() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_24() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_25() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_26() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_27() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_28() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='Diligenta';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_29() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='>10';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
         
         @istest static void SuggestedCandidates_Testmethodsixvalues_30() {
            
            // Get the  account by using a SOQL query
                Account acct = [SELECT Id FROM Account WHERE Name='FName LName' LIMIT 1];
                
            // Get the job by using a SOQL query
                Job__c job = [SELECT Id FROM Job__c WHERE Status__c ='Published' LIMIT 1];
                
            ApexPages.StandardController sc = new ApexPages.StandardController(job);
            clsSuggestedCandidates scg=new clsSuggestedCandidates(sc);
            scg.insertdata();
            
            //Insert data for filter 
            scg.SearchCandidateName='';
            scg.SearchEssentialCriteria='Diligenta';
            scg.SearchEssentialScore='>10';
            scg.SearchDesirableCriteria='';
            scg.SearchDesirableScore='';
            scg.DistanceinMiles='>10.4';
            scg.filterdata();
         }
    }