# apex-http-utils
Utilities to make Http requests easier.

This is a WIP

## This package's highlights includes the following:

-	### HttpBuilder
	Wraps System.Http, System.HttpRequest and System.HttpResponse

	Use it to easily send http requests via a fluent api.

- ### HttpFormBuilder
	Used to build multi-part form requests easily.

-	###	HttpMethod
	An emum containing http methods.

-	###	HttpMock
	Implements System.HttpCalloutMock.

	Allows for chaining requests during testing.

-	### HttpStatus
	Used to get http status names/messages by code or vice versa

-	### JwtBuilder
	Allows easy creation of JSON web tokens via a fluent api.

-	###	UriBuilder
	Used to build uri's easily.

-	### ServerAction
	An Aura component to make server-side calls to @AuraEnabled actions.