@isTest
public class Project_Payment_Trigger_Tests {

    public static testMethod void testProjectPaymentRollups(){
        //test data Setup
        Contact c = new Contact(LastName ='TestLast');
        insert c;
        
        Project__c p = new Project__c(Name = 'TestProject');
        insert p;
        
        Project_Payment__c pp1 = new Project_Payment__c(Project__c = p.Id, Contact__c = c.Id, Payment_Amount__c = 100, Payment_Date__c = date.newInstance(2019, 2, 25) );
        Project_Payment__c pp2 = new Project_Payment__c(Project__c = p.Id, Contact__c = c.Id, Payment_Amount__c = 50, Payment_Date__c = date.newInstance(2019, 2, 26) );
        List<Project_Payment__c> ppList = new List<Project_Payment__c>();
        ppList.add(pp1);
        ppList.add(pp2);
        
        //test Insert case
		insert ppList;
        Contact resultContact = [SELECT Total_Project_Payments__c, Most_Recent_Project_Payment_Date__c FROM Contact WHERE Id=:c.Id];
        Project__c resultProject = [SELECT Total_Project_Payments__c FROM Project__c WHERE Id=:p.Id];
        system.assertEquals(150,resultContact.Total_Project_Payments__c);
        system.assertEquals(date.newInstance(2019, 2, 26), resultContact.Most_Recent_Project_Payment_Date__c);
        system.assertEquals(150,resultProject.Total_Project_Payments__c);
        
        //test Update case
        pp1.Payment_Amount__c = 200;
        pp1.Payment_Date__c = date.newInstance(2019, 2, 27);
        update pp1;
        resultContact = [SELECT Total_Project_Payments__c, Most_Recent_Project_Payment_Date__c FROM Contact WHERE Id=:c.Id];
        resultProject = [SELECT Total_Project_Payments__c FROM Project__c WHERE Id=:p.Id];
        system.assertEquals(250,resultContact.Total_Project_Payments__c);
        system.assertEquals(date.newInstance(2019, 2, 27), resultContact.Most_Recent_Project_Payment_Date__c);
        system.assertEquals(250,resultProject.Total_Project_Payments__c);        
        
        //test Delete Case
        delete pp1;
        resultContact = [SELECT Total_Project_Payments__c, Most_Recent_Project_Payment_Date__c FROM Contact WHERE Id=:c.Id];
        resultProject = [SELECT Total_Project_Payments__c FROM Project__c WHERE Id=:p.Id];
        system.assertEquals(50,resultContact.Total_Project_Payments__c);
        system.assertEquals(date.newInstance(2019, 2, 26), resultContact.Most_Recent_Project_Payment_Date__c);
        system.assertEquals(50,resultProject.Total_Project_Payments__c);        
        
        //test Undelete case
        undelete pp1;
        resultContact = [SELECT Total_Project_Payments__c, Most_Recent_Project_Payment_Date__c FROM Contact WHERE Id=:c.Id];
        resultProject = [SELECT Total_Project_Payments__c FROM Project__c WHERE Id=:p.Id];
        system.assertEquals(250,resultContact.Total_Project_Payments__c);
        system.assertEquals(date.newInstance(2019, 2, 27), resultContact.Most_Recent_Project_Payment_Date__c);
        system.assertEquals(250,resultProject.Total_Project_Payments__c);  
        
    }
    
}