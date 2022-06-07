({

  handleErrors: function(args, errors) {
    if (args.disableErrorNotification === true) {
      return;
    }
    let isUnknownError = true;
    if (errors && Array.isArray(errors) && errors.length > 0) {
      errors.forEach(error => {
        if (error.message) {
          this.displayError(error.message, args);
          isUnknownError = false;
        }
        const pageErrors = error.pageErrors;
        if (pageErrors && Array.isArray(pageErrors) && pageErrors.length > 0) {
          pageErrors.forEach(pageError => {
            if (pageError.message) {
              this.displayError(pageError.message, args);
              isUnknownError = false;
            }
          });
        }
      });
    }
    if (isUnknownError) {
      this.displayError('An unknown error occurred', args);
    }
  },

  displayError: function(errorMessage, args) {
    console.error('Server Error: ', errorMessage);
    console.error('Action: ', args.action.getName(), ' Params: ', JSON.stringify(args.params));
    const evt = $A.get('e.force:showToast');
    evt.setParams({
      message: errorMessage,
      mode: 'sticky',
      type: 'error'
    });
    evt.fire();
  }
    
})