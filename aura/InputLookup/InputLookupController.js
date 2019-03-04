({

	valueChange : function(component, event, helper){
		var val = component.get('v.value');
		var recName = component.get('v.recName');
		if(val && !recName){
			helper.getLookupName(component, val);
		}
	},
    onInputKeyUp: function(component, event, helper){
		var className = '.' + $(event.currentTarget).attr('id') + '_item';
        helper.parseInputKeyUp(component, event, className);
        $(className + " .tt-dataset").css("display", "block");
    },
    
    onRecordClick: function(component, event, helper){
        var recordId = event.target.dataset.id;
        var recordName = event.target.dataset.name;
        helper.onRecordSelect(component, recordId, recordName, helper);
        $(".tt-dataset").css("display", "none");
    },

	clearText: function(component, event, helper){
		var id = $(event.currentTarget).data().id;
		var className = '.' + id + '_item';
		$('#' + id).val('');
		component.set('v.value', '');
		$(className + " .tt-dataset").css("display", "none");
		$(event.currentTarget).hide();
	}
})