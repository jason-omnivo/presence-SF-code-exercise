public class ProjectPaymentContactsCtrl  {

	public ProjectPaymentContactsCtrl(){
	
	}

	/*********************************** Public Methods ************************************/


	/*****
    * @name         : getContacts()
    * @params       : (void)
    * @return       : List<ContactWP>
    * @description  : This method is used to get all contacts from the that have made 
	*				at least one Project Payment to any Project. 
    *
    ******/
	@AuraEnabled
	public static List<ContactWP> getContacts(String termSearch){
		List<ContactWP> contactsWp = new List<ContactWP>();
		//get all projectPayments
		List<Project_Payment__c> projectPayments = [Select Id, Name, Contact__c, Payment_Amount__c, Project__c, Payment_Date__c
																from Project_Payment__c Where Project__c != null];
		Map<Id, List<Project_Payment__c>> ppContactsMap = new Map<Id, List<Project_Payment__c>>();
		for(Project_Payment__c pp: projectPayments){
			if(ppContactsMap.get(pp.Contact__c) != null)
				ppContactsMap.get(pp.Contact__c).add(pp);
			else ppContactsMap.put(pp.Contact__c, new List<Project_Payment__c>{pp});
		}//end for
	
		//get all related contacts
		
		List<Contact> contacts = new List<Contact>();
		if(String.isNotBlank(termSearch)){
			termSearch = '%' + termSearch + '%';
			contacts = [Select Id, FirstName, LastName, Email, Name from Contact Where Id IN :ppContactsMap.keySet() AND Name Like :termSearch];
		}else contacts = [Select Id, FirstName, LastName, Email, Name from Contact Where Id IN :ppContactsMap.keySet()];

		for(Contact con: contacts){
			ContactWP cwp = new ContactWP();
			cwp.contact = con;
			for(Project_Payment__c pp: ppContactsMap.get(con.Id)){
				cwp.totalPayment += pp.Payment_Amount__c;
				if(cwp.mostRecentPaymDate == null || cwp.mostRecentPaymDate < pp.Payment_Date__c)
					cwp.mostRecentPaymDate = pp.Payment_Date__c;
			}//end for

			contactsWp.add(cwp);
		}///end for

		return contactsWp;
	}


	/*****
    * @name         : getPayments()
    * @params       : (String) conId
    * @return       : List<Paymentwp>
    * @description  : This method is used to get all the Project_Payment__c records related to a specified contact
    *
    ******/
	@AuraEnabled
	public static List<Paymentwp> getPayments(String conId){
		List<Paymentwp> payments = new List<Paymentwp>();
		List<Project_Payment__c> projectPayments = [Select Id, Name, Contact__c, Payment_Amount__c, Project__c, Payment_Date__c
																from Project_Payment__c Where Contact__c =: conId];
		for(Project_Payment__c pp: projectPayments){
			payments.add(new Paymentwp(pp));
		}//end for
		return payments;
	}


	/*****
    * @name         : deleteProjectPayment()
    * @params       : (String) ppId
    * @return       : String
    * @description  : This method is used to delete a Project_Payment__c record
    *
    ******/
	@AuraEnabled
	public static String deleteProjectPayment(String ppId){
		try{
			Project_Payment__c pp = [select Id from Project_Payment__c where id =: ppId];
			delete pp;
		}catch(DmlException ex){
			System.debug('An error was caught on deleting a Project_Payment__c record with id: ' + ppId + '.');
			return 'Error: An error was caught on deleting a Project_Payment__c record with id: ' + ppId + '.';
		}

		return 'Successfully deleted!';
	}

	/*****
    * @name         : getNewPayment()
    * @params       : (void)
    * @return       : Project_Payment__c
    * @description  : This method is used to get a Project_Payment__crecord
    *
    ******/
	@AuraEnabled
	public static Project_Payment__c getNewPayment(){
		return new Project_Payment__c();
	}

	/*****
    * @name         : saveProjectPayment()
    * @params       : (String) jsonPP
    * @return       : String
    * @description  : This method is used to update a Project_Payment__crecord
    *
    ******/
	@AuraEnabled
	public static String saveProjectPayment(String jsonPP){
		Project_Payment__c pp = (Project_Payment__c) JSON.deserializeStrict(jsonPP, Project_Payment__c.class);
		try{
			update pp;
		}catch(DmlException ex){
			System.debug('An error was caught on updating the Project_Payment__c record with id: ' + pp.Id + '.');
			return 'Error: An error was caught on updating the Project_Payment__c record with id: ' + pp.Id + '.';
		}

		return 'Successfully updated!';
	}

	/*****
    * @name         : saveNewProjectPayment()
    * @params       : (String) conId, (String) jsonpprojectrec, 
    * @return       : String
    * @description  : This method is used to update a Project_Payment__c record
    *
    ******/
	@AuraEnabled
	public static String saveNewProjectPayment(String conId, String jsonpprojectrec){
		Project_Payment__c pp = (Project_Payment__c) JSON.deserializeStrict(jsonPprojectRec, Project_Payment__c.class);
		pp.Contact__c = conId;
		try{
			insert pp;
		}catch(DmlException ex){
			System.debug('An error was caught inserting the Project_Payment__c record with id: ' + pp.Id + '.');
			return 'Error: An error was caught inserting the Project_Payment__c record with id: ' + pp.Id + '.';
		}

		return 'Successfully updated!';
	}

	/*********************************** Private Methods ***********************************/

	/*************************************** Wrappers **************************************/
	public class ContactWP{
		@AuraEnabled
		public Contact contact {get;set;}
		@AuraEnabled
		public Decimal totalPayment {get;set;}
		@AuraEnabled
		public Date mostRecentPaymDate {get;set;}

		public ContactWP(){
			contact = new Contact();
			totalPayment = 0;
			mostRecentPaymDate = null;
		}
	}

	public class Paymentwp {
		@AuraEnabled
		public Project_Payment__c paym {get;set;}
		@AuraEnabled
		public Boolean isEdit {get;set;}

		public Paymentwp(){
			paym = new Project_Payment__c();
			isEdit = false;
		}

		public Paymentwp(Project_Payment__c pp){
			paym = pp;
			isEdit = false;
		}
	}
}