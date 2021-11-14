({
	
	callServer: function(component, event, helper) {
		const args = event.getParam('arguments');
		if (!args.disableLoading) {
			component.set('v.isLoading', true);
		}
		const action = args.action;
		if (args.params) {
			action.setParams(args.params);
		}
		action.setCallback(this, response => {
			const state = response.getState();
			switch (state) {
				case 'SUCCESS':
					if (args.successCallback) {
						args.successCallback(response.getReturnValue());
					}
					break;
				case 'INCOMPLETE':
				case 'ERROR':
					const errors = response.getError();
					helper.handleErrors(args, errors);
					if (args.errorCallback) {
						args.errorCallback(errors);
					}
					break;
				default:
					helper.handleErrors(args, response.getError());
			}
			if (!args.disableLoading) {
				component.set('v.isLoading', false);
			}
		});
		$A.enqueueAction(action);
	},

	displaySuccess: function(component, event, helper) {
		const args = event.getParam('arguments');
		const evt = $A.get('e.force:showToast');
		evt.setParams({
			message: args.message || 'The operation completed successfully',
			title: args.title || '',
			type: 'success'
		});
		evt.fire();
	},

	displayError: function(component, event, helper) {
		const args = event.getParam('arguments');
		const evt = $A.get('e.force:showToast');
		evt.setParams({
			message: args.message || 'The operation was unsuccessful',
			mode: 'sticky',
			title: args.title || '',
			type: 'error'
		});
		evt.fire();
	}
		
})