({
	doInit: function (component, event, helper) {
		$A.enqueueAction(component.get('c.displaySpinner'));

		helper.getContacts(component, helper, '');
		helper.getNewPayment(component);
	},

	displaySpinner: function(component, event, helper){
		document.getElementById('spinnerContent').style.display = 'block';
	},

	hideSpinner: function(component, event, helper){
		document.getElementById('spinnerContent').style.display = 'none';
	},

	closeError: function(component, event, helper){
		component.set("v.displayError", "false");
		component.set("v.errorMessage", "");
	},

	togglePP: function(component, event, helper){
		let btnId = event.currentTarget.getAttribute('data-Controls');

		if(document.getElementById(btnId).style.display != 'block' ){
			$A.enqueueAction(component.get('c.displaySpinner'));

			document.getElementById(btnId).style.display = 'block';
			helper.getPayments(component, btnId.split('accordion-details-')[1]);
		}else document.getElementById(btnId).style.display = 'none';
	},

	editPP: function(component, event, helper){
		let ppId = event.currentTarget.getAttribute('data-pp');
		let payments = component.get("v.payments");
		helper.editpp(component, ppId, payments);
	},

	deletePP: function(component, event, helper){
		$A.enqueueAction(component.get('c.displaySpinner'));

		let ppId = component.get("v.ppIdToDelete");
		let conId = component.get("v.conIdToRetrive");
		helper.deletePP(component, helper, ppId, conId);
	},

	prepareToDelPP: function(component, event, helper){
		let ppId = event.currentTarget.getAttribute('data-pp');
		let conId = event.currentTarget.getAttribute('data-conId');

		component.set("v.displayDeletePopUp", "true");
		component.set("v.ppIdToDelete", ppId);
		component.set("v.conIdToRetrive", conId);
	},

	canceldeletePP:  function(component, event, helper){
		component.set("v.displayDeletePopUp", "false");
		component.set("v.ppIdToDelete", "");
		component.set("v.conIdToRetrive", "");
	},
	
	savePP: function(component, event, helper){
		$A.enqueueAction(component.get('c.displaySpinner'));

		let payments = component.get("v.payments");
		let ppId = event.currentTarget.getAttribute('data-pp');
		let paymToUpdate;
		for(let i = 0; i < payments.length; i++){
			if(payments[i].paym.Id == ppId)
				paymToUpdate = payments[i].paym;
		}//end for

		helper.savePP(component, paymToUpdate, helper);
	},

	cancelPP: function(component, event, helper){
		let ppId = event.currentTarget.getAttribute('data-pp');
		let payments = component.get("v.payments");
		for(let j = 0; j < payments.length; j++){
			if(payments[j].paym.Id == ppId)		
				payments[j].isEdit = false;
		}//end for

		component.set("v.payments", payments);
	},

	handleSearchKeyUp: function(component, event, helper){
		var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
			$A.enqueueAction(component.get('c.displaySpinner'));

            var queryTerm = component.find('searchContact').get('v.value');
            helper.getContacts(component, helper, queryTerm);
        }
	},

	prepareToAddNewPayment: function(component, event, helper){
		let conId = event.currentTarget.getAttribute('data-conid');

		component.set("v.displayNewPaymPopUp", "true");
		component.set("v.conIdToRetrive", conId);
	},

	cancelNewPayment: function(component, event, helper){
		component.set("v.displayNewPaymPopUp", "false");
		component.set("v.conIdToRetrive", "");
	},

	saveNewPayment: function(component, event, helper){
		$A.enqueueAction(component.get('c.displaySpinner'));

		let conId = component.get("v.conIdToRetrive");
		let pprojectRec = component.get("v.newpp");
		
		helper.saveNewPayment(component, conId, pprojectRec, helper);
	}
})