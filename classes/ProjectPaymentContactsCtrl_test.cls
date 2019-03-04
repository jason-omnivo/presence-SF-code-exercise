@isTest 
public class ProjectPaymentContactsCtrl_test {

	public static testMethod void testProjectPaymentContactsCtrl() {


		Account acc = new Account(Name = 'test acc');
		insert acc;

		Contact con = new Contact(FirstName = 'fname', LastName = 'lName', email = 'lname@test.com', AccountId = acc.Id);
		insert con;

		Project__c p =new Project__c();
		p.Name = 'Project test';
		insert p;

		Project_Payment__c pp = new Project_Payment__c();
		pp.Contact__c = con.Id;
		pp.Project__c = p.Id;
		pp.Payment_Amount__c = 101;
		pp.Payment_Date__c = Date.today();
		insert pp;


		System.Test.startTest();

			List<ProjectPaymentContactsCtrl.ContactWP> contacts = ProjectPaymentContactsCtrl.getContacts('');
			List<ProjectPaymentContactsCtrl.Paymentwp> payments = ProjectPaymentContactsCtrl.getPayments(con.Id);

			Project_Payment__c ppNew = ProjectPaymentContactsCtrl.getNewPayment();
			ppNew.Project__c = p.Id;
			ppNew.Payment_Amount__c = 201;
			ppNew.Payment_Date__c = Date.today().addDays(-2);
			ProjectPaymentContactsCtrl.saveNewProjectPayment(con.Id, JSON.serialize(ppNew));
			ProjectPaymentContactsCtrl.deleteProjectPayment(pp.Id);

			ppNew = [Select Id, Payment_Amount__c from Project_Payment__c WHERE Payment_Amount__c = 201];
			ppNew.Payment_Amount__c = 51;
			ProjectPaymentContactsCtrl.saveProjectPayment(JSON.serialize(ppNew));

		System.Test.stopTest();

		List<Project_Payment__c> ppList = [Select Id, Payment_Amount__c from Project_Payment__c];
		System.assertEquals(1, ppList.size());
		System.assertEquals(51, ppList.get(0).Payment_Amount__c);
	}
}