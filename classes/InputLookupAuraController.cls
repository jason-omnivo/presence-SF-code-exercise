public class InputLookupAuraController { 

	/*
	* Returns the "Name" field for a given SObject (e.g. Case has CaseNumber, Account has Name)
	*/
    private static String getSobjectNameField(SobjectType sobjType){
        
        //describes lookup obj and gets its name field
        String nameField = 'Name';
        Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
        for(schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
            Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
            if(fieldDescObj.isNameField() ){
            	nameField = fieldDescObj.getName();
                break;
            }
        }
        return nameField; 
    }

	@AuraEnabled
    public static String getLookupName(String idVal, String typeVal){
		SObjectType objType = Schema.getGlobalDescribe().get(typeVal);
        if(objType == null){
            return null;
        }
		System.debug('typeVal: ' + typeVal);
        String nameField = getSobjectNameField(objType);

		String query = 'Select Id, '+ nameField + ' from ' + typeVal +' where Id = \'' + idVal + '\'';
        System.debug('### Query: ' + query);
        List<SObject> oList = Database.query(query);
        System.debug('### Query oList: ' + oList);
		if (oList != null && oList.size() > 0){
			return String.valueOf(oList.get(0).get(nameField));
		}

        return '';
	}

	/*
     * Loads the initial value of the given SObject type with ID "value"
	 */
	@AuraEnabled
    public static List<SObject> getCurrentValue(String searchVal, String typeVal){
        
        SObjectType objType = Schema.getGlobalDescribe().get(typeVal);
        if(objType == null){
            return null;
        }
		System.debug('typeVal: ' + typeVal);
        String nameField = getSobjectNameField(objType);
		
		//if searchVal have special char
		if(searchVal.contains('\'')){
			searchVal = searchVal.split('\'')[0] + '\\\'';
		}
		system.debug('searchVal: ' + searchVal);
        String s = '\'%' + searchVal + '%\'';
        String query = 'Select Id, '+ nameField + ' from ' + typeVal +' where '+ nameField + ' LIKE ' + s + ' LIMIT 5';
        System.debug('### Query: ' + query);
        List<SObject> oList = Database.query(query);
        System.debug('### Query oList: ' + oList);
        
        return oList;
    }

}