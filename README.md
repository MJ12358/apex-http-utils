# apex-http-utils

Utilities to make [Http requests](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm) easier in [Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm).

<a href="https://githubsfdeploy.herokuapp.com/app/githubdeploy/MJ12358/apex-http-utils?ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Highlights

- ### HttpBuilder

  Wraps System.Http, System.HttpRequest and System.HttpResponse.

  Use it to easily send http requests via a fluent api.

- ### HttpException

  Used to consistently format http exceptions.

- ### HttpFormBuilder

  [Inspired by this post](https://salesforce.stackexchange.com/questions/132135/how-can-i-compose-a-multipart-form-data-request)

  Used to build multipart/form-data requests easily.

- ### HttpMethod

  An emum containing http methods.

- ### HttpMock

  Implements [System.HttpCalloutMock](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_httpcalloutmock.htm)

  Allows for chaining requests during testing.

- ### HttpStatus

  Used to get http status names/messages by status code or vice versa.

- ### JwtBuilder

  Allows easy creation of JSON web tokens via a fluent api.

- ### UriBuilder

  Used to build uri's easily.

- ### ServerAction

  An Aura component to make server-side calls to @AuraEnabled actions.

## Usage

`HttpBuilder`

```apex
HttpBuilder builder = new HttpBuilder();

builder
 .endpoint('https://example.com')
 .method(HttpMethod.POST)
 .body(new Map<String, Object>{'key' => 'value'})
 .compress()
 .header('Content-Type', 'application/json')
 .send()

System.HttpResponse response = builder.getResponse();
```

Or with a convience http method.

```apex
HttpBuilder builder = new HttpBuilder();

builder
 .endpoint('https://example.com')
 .post(new Map<String, Object>{'key' => 'value'})
 .compress()
 .header('Content-Type', 'application/json')
 .send()

String response = builder.getBody();
```

`HttpException`

```apex
throw new HttpException(request, response);
```

`HttpFormBuilder`

```apex
HttpFormBuilder builder = new HttpFormBuilder();

builder
 .put('key1', 'value')
 .put('key2', 101)
 .put('myfile', 'ABCDE=', 'myfile.txt')
 .build();

Blob result = builder.build();
```

`JwtBuilder`

```apex
JwtBuilder builder = new JwtBuilder(JwtBuilder.Algorighm.RS256);

builder
 .audience('host@domain.com')
 .expires(3600)
 .issuer('your@company.com')
 .key('A1B2C3')

String result = builder.build();
```

`UriBuilder`

The order of the paths matter.

```apex
UriBuilder builder = new UriBuilder('https://example.com');

builder
 .path('users')
 .path('MJ12358')
 .query('$select', 'displayName')
 .query('$expand', 'manager');

String result = builder.build();

System.assertEquals('https://example.com/users/MJ12358?$select=displayName&$expand=manager', result);
```

`ServerAction`

// YourComponent.cmp

```html
<c:ServerAction aura:id="serverAction" isLoading="{!v.isLoading}" />
```

// YourComponentController.js

```javascript
component.get('serverAction').callServer(
  component.get('c.myServerAction'),
  {
    param1: component.get('v.param1'),
    param2: component.get('v.param2'),
  },
  $A.getCallback(response => {
    // do something on success
  }),
  $A.getCallback(response => {
    // optionally do something on error
    // by default a toast is shown
  });
)
```

## Tests

Current test results:

| Class      | Percent | Lines  |
| --------------- | ------- | ------- |
| BaseRequest   | 80%   | 48/60  |
| HttpBuilder   | 80%   | 303/377 |
| HttpException  | 100%   | 34/34  |
| HttpFormBuilder | 85%   | 83/97  |
| HttpStatus   | 100%  | 184/184 |
| JwtBuilder   | 81%   | 124/152 |
| UriBuilder   | 81%   | 75/92  |
