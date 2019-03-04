@isTest 
private class InputLookupAuraController_TEST {

	private static testMethod void testInputLookupAuraController() {

		Account acc = new Account(Name= 'acc test');
		insert acc;
		

		System.Test.startTest();

		List<SObject> records = InputLookupAuraController.getCurrentValue('acc', 'Account');
		String lookupName = InputLookupAuraController.getLookupName(String.valueOf(acc.Id), 'Account');

		System.Test.stopTest();

		System.assert(String.isNotBlank(lookupName));
		System.assert(records.size() > 0);
	}
}