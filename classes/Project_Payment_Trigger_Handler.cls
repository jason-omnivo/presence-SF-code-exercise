public without sharing class Project_Payment_Trigger_Handler {

    public static void aInsert(Map<Id, Project_Payment__c> newProjPmtMap){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        for(Project_Payment__c pp: [SELECT Contact__c, Project__c, Payment_Amount__c, Payment_Date__c FROM Project_Payment__c WHERE Id IN:newProjPmtMap.keySet() ]){
            contactIdSet.add(pp.Contact__c);
            projIdSet.add(pp.Project__c);            
        }
        if(!contactIdSet.isEmpty() || !projIdSet.isEmpty()){
            rollUpProjectPayments(contactIdSet,projIdSet);
        }
    }

    public static void aUpdate(Map<Id, Project_Payment__c> newProjPmtMap,Map<Id, Project_Payment__c> oldProjPmtMap){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        for(Project_Payment__c pp: [SELECT Contact__c, Project__c, Payment_Amount__c, Payment_Date__c FROM Project_Payment__c WHERE Id IN:newProjPmtMap.keySet() ]){
            if(pp.Payment_Amount__c != oldProjPmtMap.get(pp.Id).Payment_Amount__c || pp.Payment_Date__c != oldProjPmtMap.get(pp.Id).Payment_Date__c){
            		contactIdSet.add(pp.Contact__c);
            		projIdSet.add(pp.Project__c);                  
              }            
        }
        if(!contactIdSet.isEmpty() || !projIdSet.isEmpty()){
            rollUpProjectPayments(contactIdSet,projIdSet);
        }        
    }

    public static void aDelete(Map<Id, Project_Payment__c> oldProjPmtMap){
        system.debug('old proj pmt map---' + oldProjPmtMap);
		Set<Id> contactIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        for(Project_Payment__c pp: [SELECT Contact__c, Project__c, Payment_Amount__c, Payment_Date__c FROM Project_Payment__c WHERE Id IN:oldProjPmtMap.keySet() ALL ROWS ]){
            contactIdSet.add(pp.Contact__c);
            projIdSet.add(pp.Project__c);            
        }
        if(!contactIdSet.isEmpty() || !projIdSet.isEmpty()){
            rollUpProjectPayments(contactIdSet,projIdSet);
        }        
    }
    
    public static void aUndelete(Map<Id, Project_Payment__c> newProjPmtMap){
		Set<Id> contactIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        for(Project_Payment__c pp: [SELECT Contact__c, Project__c, Payment_Amount__c, Payment_Date__c FROM Project_Payment__c WHERE Id IN:newProjPmtMap.keySet() ]){
            contactIdSet.add(pp.Contact__c);
            projIdSet.add(pp.Project__c);            
        }
        if(!contactIdSet.isEmpty() || !projIdSet.isEmpty()){
            rollUpProjectPayments(contactIdSet,projIdSet);
        }        
    }    
    
    private static void rollUpProjectPayments(Set<Id> contactIdSet, Set<Id> projIdSet){
        //Assumption: we will not exceed query limits for these rollup operations for a given Project or Contact
        //If we do, asynchronous or batch APEX would be used to perform these rollup operations				                
        
		//Contact Rollups
		List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c: [SELECT Most_Recent_Project_Payment_Date__c, (SELECT Payment_Date__c, Payment_Amount__c FROM Project_Payment__r ORDER BY Payment_Date__c DESC)  FROM Contact WHERE Id IN:contactIdSet ]){
            c.Most_Recent_Project_Payment_Date__c = NULL;
            c.Total_Project_Payments__c = 0;
            if(!c.Project_Payment__r.isEmpty()){
                c.Most_Recent_Project_Payment_Date__c = c.Project_Payment__r[0].Payment_Date__c;
                double paymentTotal = 0;
                for(Project_Payment__c pp: c.Project_Payment__r){
                    paymentTotal += (pp.Payment_Amount__c != NULL) ? pp.Payment_Amount__c : 0;
                }
                c.Total_Project_Payments__c = paymentTotal;
            }
			contactsToUpdate.add(c);            
        }
        
		//Project Rollups  
		List<Project__c> projectsToUpdate = new List<Project__c>();
        for(Project__c p: [SELECT Total_Project_Payments__c, (SELECT Payment_Amount__c FROM Project_Payment__r ORDER BY Payment_Date__c DESC)  FROM Project__c WHERE Id IN:projIdSet ]){
            p.Total_Project_Payments__c = 0;
            if(!p.Project_Payment__r.isEmpty()){
                double paymentTotal = 0;
                for(Project_Payment__c pp: p.Project_Payment__r){
                    paymentTotal += (pp.Payment_Amount__c != NULL) ? pp.Payment_Amount__c : 0;
                }
                p.Total_Project_Payments__c = paymentTotal;
            }
			projectsToUpdate.add(p);            
        }
        
        List<sObject> objectsToUpdate = new List<sObject>();
        objectsToUpdate.addAll(contactsToUpdate);
        objectsToUpdate.addAll(projectsToUpdate);
        
        //try{
            update objectsToUpdate;
        /*}
        catch(DMLException e){
            //Normally a custom exception that sends an email out to designated admins would be included here
            //Skipping for purposes of this code exercise            
        }*/
        
    }
    
}