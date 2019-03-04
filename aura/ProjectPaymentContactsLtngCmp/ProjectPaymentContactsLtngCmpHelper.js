({
	getNewPayment: function (component, helper, termSearch) {
		var action = component.get('c.getNewPayment');     
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set('v.newpp', result);
            } else if (state === "ERROR") {
                let errorMessage = 'Unknown error';
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                component.set("v.displayError", "true"); 
				component.set("v.errorMessage", errorMessage);
                console.log(errorMessage);
			}
			$A.enqueueAction(component.get('c.hideSpinner'));
        });
        $A.enqueueAction(action);
	},


	getContacts: function (component, helper, termSearch) {
		var action = component.get('c.getContacts');    
		action.setParams({
			"termSearch" : termSearch
		});    
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let results = response.getReturnValue();
                component.set('v.contacts', results);
            } else if (state === "ERROR") {
                let errorMessage = 'Unknown error';
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                component.set("v.displayError", "true"); 
				component.set("v.errorMessage", errorMessage);
                console.log(errorMessage);
			}
			$A.enqueueAction(component.get('c.hideSpinner'));
        });
        $A.enqueueAction(action);
	},

	getPayments: function(component, conId){
		var action = component.get('c.getPayments');  
		action.setParams({
			"conId" : conId
		});     
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let results = response.getReturnValue();
				let payments = component.get('v.payments');

				if(payments.length > 0){//remove existing elements related to conId
					let minIndexToRemove;
					let noOfRecords = 0;
					for(let i = 0; i < payments.length; i++){
						if(payments[i].paym.Contact__c == conId){
							noOfRecords++;
							if(minIndexToRemove == undefined)
								minIndexToRemove = i;
						}
					}//end for

					if(minIndexToRemove != undefined)
						payments.splice(minIndexToRemove, noOfRecords);
				}

				//add new elements
				for(let i = 0; i < results.length; i++){
					payments.push(results[i]);
				}//end for
				
                component.set('v.payments', payments);
            } else if (state === "ERROR") {
                let errorMessage = 'Unknown error';
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                component.set("v.displayError", "true"); 
				component.set("v.errorMessage", errorMessage);
                console.log(errorMessage);

			}

			$A.enqueueAction(component.get('c.hideSpinner'));
        });
        $A.enqueueAction(action);
	},

	deletePP: function(component, helper, ppId, conId){
		var action = component.get('c.deleteProjectPayment');
		action.setParams({
			"ppId" : ppId,
		});
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
				if(result.startsWith('Error')){
					component.set("v.displayError", "true"); 
					component.set("v.errorMessage", result);
					console.log(result);

					$A.enqueueAction(component.get('c.hideSpinner'));
				}else{
					let termSearch = component.find('searchContact').get('v.value');
					helper.getContacts(component, helper, termSearch);
					helper.getPayments(component, conId);
					component.set("v.displayDeletePopUp", "false");
					component.set("v.ppIdToDelete", "");
					component.set("v.conIdToRetrive", "");
				}

            } else if (state === "ERROR") {
                let errorMessage = 'Unknown error';
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                component.set("v.displayError", "true"); 
				component.set("v.errorMessage", errorMessage);
                console.log(errorMessage);
				
				$A.enqueueAction(component.get('c.hideSpinner'));
			}
        });
        $A.enqueueAction(action);
	},

	editpp: function(component, ppId, payments){
		for(let j = 0; j < payments.length; j++){
			if(payments[j].paym.Id == ppId)		
				payments[j].isEdit = true;
		}//end for

		component.set("v.payments", payments);
	},

	savePP: function(component, paymToUpdate, helper){
		let conId = paymToUpdate.Contact__c;

		var action = component.get('c.saveProjectPayment');
		action.setParams({
			"jsonPP" : JSON.stringify(paymToUpdate),
		});
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
				if(result.startsWith('Error')){
					component.set("v.displayError", "true"); 
					component.set("v.errorMessage", result);
					console.log(result);

					$A.enqueueAction(component.get('c.hideSpinner'));
				}else{
					let termSearch = component.find('searchContact').get('v.value');
					helper.getContacts(component, helper, termSearch);
					helper.getPayments(component, conId);
				}

            } else if (state === "ERROR") {
                let errorMessage = 'Unknown error';
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                component.set("v.displayError", "true"); 
				component.set("v.errorMessage", errorMessage);
                console.log(errorMessage);
				
				$A.enqueueAction(component.get('c.hideSpinner'));
			}
        });
        $A.enqueueAction(action);
	},

	saveNewPayment: function(component, conId, jsonPprojectRec, helper){
		var action = component.get('c.saveNewProjectPayment');
		action.setParams({
			"conId" : conId,
			"jsonpprojectrec" : JSON.stringify(jsonPprojectRec)
		});
        action.setCallback(this, function(response) {
            let state = response.getState();
            
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
				if(result.startsWith('Error')){
					$A.enqueueAction(component.get('c.hideSpinner'));
					component.set("v.displayError", "true"); 
					component.set("v.errorMessage", result);
					console.log(result);

					$A.enqueueAction(component.get('c.hideSpinner'));
				}else{
					let termSearch = component.find('searchContact').get('v.value');
					helper.getContacts(component, helper, termSearch);
					helper.getPayments(component, conId);
				}

				component.set("v.displayNewPaymPopUp", "false");
				component.set("v.conIdToRetrive", "");

            } else if (state === "ERROR") {
                let errorMessage = 'Unknown error';
                let errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = "Error message: " + errors[0].message;
                }
                
                component.set("v.displayError", "true"); 
				component.set("v.errorMessage", errorMessage);
                console.log(errorMessage);
				component.set("v.displayNewPaymPopUp", "false");
				component.set("v.conIdToRetrive", "");
				
				$A.enqueueAction(component.get('c.hideSpinner'));
			}
			helper.getNewPayment(component);
        });
        $A.enqueueAction(action);
	},
})