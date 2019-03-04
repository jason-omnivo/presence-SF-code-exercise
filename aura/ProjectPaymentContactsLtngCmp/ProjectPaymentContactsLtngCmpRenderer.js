({
	rerender: function(component, event, helper) {
        var result = this.superRerender();
        console.log("rerender event fires");
        return result;
    }
})