@IsTest
public class HttpBuilderTest {

  private static HttpMock mock;
  private static String endpoint = 'https://example.com';

  static {
    mock = new HttpMock();
    mock.setBody('{"example":"test"}');
    mock.setHeader('Content-Type', 'application/json');
    mock.setStatusCode(200);
    Test.setMock(HttpCalloutMock.class, mock);
  }

  @IsTest
  static void testDebug() {
    Test.startTest();
    new HttpBuilder().endpoint(endpoint)
      .debug()
      .get()
      .send();
    Test.stopTest();
    System.assertEquals(1, [SELECT Count() FROM HttpLog__c]);
  }

  @IsTest
  static void testBlankEndpoint() {
    Test.startTest();
    try {
      new HttpBuilder().endpoint('')
        .get()
        .send();
      System.assert(false, 'Expected an exception');
    } catch (HttpBuilderException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testBuild() {
    Test.startTest();
    System.HttpRequest req = new HttpBuilder().endpoint(endpoint)
      .get()
      .build();
    Test.stopTest();
    System.assertEquals(endpoint, req.getEndpoint());
    System.assertEquals('GET', req.getMethod());
  }

  @IsTest
  static void testDelete() {
    Test.startTest();
    System.HttpResponse res = new HttpBuilder().endpoint(endpoint)
      .deletex()
      .send()
      .getResponse();
    Test.stopTest();
    System.assertNotEquals(null, res);
  }

  @IsTest
  static void testGet() {
    Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
    Test.startTest();
    HttpBuilder builder = new HttpBuilder();
    String result = builder.endpoint(endpoint)
      .cache(900)
      .compress()
      .header(headers)
      .timeout(Decimal.valueOf(5000))
      .get()
      .send()
      .getBody();
    Test.stopTest();
    System.assertEquals(result, '{"example":"test"}');
    System.assert(builder.getHeaders().size() > 0);
    System.assert(builder.getBase64() != null);
  }

  @IsTest
  static void testPatch() {
    Test.startTest();
    String result = new HttpBuilder().endpoint(endpoint)
      .header('testHeader', 'testing')
      .patch(Blob.valueOf('test'))
      .patch('test')
      .send()
      .getBody();
    Test.stopTest();
    System.assertEquals(result, '{"example":"test"}');
  }

  @IsTest
  static void testPatchDom() {
    Dom.Document body = new Dom.Document();
    body.load('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    mock.setBody('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    Test.startTest();
    Dom.Document result = new HttpBuilder().endpoint(endpoint)
      .patch(body)
      .header('Content-Type', 'application/xml')
      .send()
      .getDom();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testPost() {
    Test.startTest();
    String result = new HttpBuilder().endpoint(endpoint)
      .post(Blob.valueOf('test'))
      .post('test')
      .send()
      .getBody();
    Test.stopTest();
    System.assertEquals(result, '{"example":"test"}');
  }

  @IsTest
  static void testPostDom() {
    Dom.Document body = new Dom.Document();
    body.load('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    mock.setBody('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    Test.startTest();
    Dom.Document result = new HttpBuilder().endpoint(endpoint)
      .post(body)
      .header('Content-Type', 'application/xml')
      .send()
      .getDom();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testPut() {
    Test.startTest();
    String result = new HttpBuilder().endpoint(endpoint)
      .put(Blob.valueOf('test'))
      .put('test')
      .send()
      .getBody();
    Test.stopTest();
    System.assertEquals(result, '{"example":"test"}');
  }

  @IsTest
  static void testPutDom() {
    Dom.Document body = new Dom.Document();
    body.load('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    mock.setBody('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    Test.startTest();
    Dom.Document result = new HttpBuilder().endpoint(endpoint)
      .post(body)
      .header('Content-Type', 'application/xml')
      .send()
      .getDom();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testBlankMethod() {
    Test.startTest();
    try {
      new HttpBuilder().endpoint(endpoint)
        .method('')
        .send();
      System.assert(false, 'Expected an exception');
    } catch (HttpBuilderException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testGenericBody() {
    Object body = 'test';
    Test.startTest();
    String result = new HttpBuilder().endpoint(endpoint)
      .get()
      .body(body)
      .send()
      .getBody();
    Test.stopTest();
    System.assertEquals(result, '{"example":"test"}');
  }

  @IsTest
  static void testGenericBlob() {
    Object body = Blob.valueOf('test');
    Test.startTest();
    Blob result = new HttpBuilder().endpoint(endpoint)
      .get()
      .body(body)
      .send()
      .getBlob();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testGenericDom() {
    Dom.Document body = new Dom.Document();
    body.load('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    mock.setBody('<?xml version="1.0" encoding="utf-8"?><root><child /></root>');
    Test.startTest();
    Dom.Document result = new HttpBuilder().endpoint(endpoint)
      .get()
      .body((Object)body)
      .header('Content-Type', 'application/xml')
      .send()
      .getDom();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testError() {
    Test.startTest();
    try {
      mock.setStatusCode(500);
      new HttpBuilder().endpoint(endpoint)
        .delay(1)
        .retry(2)
        .get()
        .send();
      System.assert(false, 'Expected an exception');
    } catch (System.CalloutException e) {
      System.assert(true, 'Exeption caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testCacheLimits() {
    Test.startTest();
    try {
      new HttpBuilder().endpoint(endpoint)
      .cache(172801)
      .build();
      System.assert(false, 'Expected an exception');
    } catch (HttpBuilderException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testTimeoutLimits() {
    Test.startTest();
    try {
      new HttpBuilder().endpoint(endpoint)
      .timeout(120001)
      .build();
      System.assert(false, 'Expected an exception');
    } catch (HttpBuilderException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testDelayLimits() {
    Test.startTest();
    try {
      new HttpBuilder().endpoint(endpoint)
      .delay(5001)
      .build();
      System.assert(false, 'Expected an exception');
    } catch (HttpBuilderException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testRetryLimits() {
    Test.startTest();
    try {
      new HttpBuilder().endpoint(endpoint)
        .retry(11)
        .get()
        .send();
      System.assert(false, 'Expected an exception');
    } catch (HttpBuilderException e) {
      System.assert(true, 'Exception caught');
    }
    Test.stopTest();
  }

  @IsTest
  static void testCookie() {
    Test.startTest();
    HttpBuilder result = new HttpBuilder()
      .endpoint(endpoint)
      .post()
      .cookie('server_session', '1234')
      .send();
    Test.stopTest();
    System.assertEquals('server_session=1234', result.getRequestHeaders().get('Cookie'));
  }

  @IsTest
  static void testCookies() {
    Map<String, Object> cookies = new Map<String, Object>{
      'server_session' => '1234',
      'test1' => 'dude1',
      'test2' => 'dude2'
    };
    Test.startTest();
    HttpBuilder result = new HttpBuilder()
      .endpoint(endpoint)
      .post()
      .cookie(cookies)
      .send();
    Test.stopTest();
    System.assertEquals('server_session=1234; test1=dude1; test2=dude2', result.getRequestHeaders().get('Cookie'));
  }

  @IsTest
  static void testRedirectionStatusCodes() {
    Set<Integer> codes = new Set<Integer>{ 301, 302, 303, 307 };
    Test.startTest();
    for (Integer i : codes) {
      mock.setStatusCode(i);
      try {
        new HttpBuilder().endpoint(endpoint)
          .get()
          .send();
        System.assert(false, 'Expected an exception');
      } catch (HttpBuilderException e) { // the location headers have not been set
        System.assert(true, 'Exception caught');
      }
      mock.next();
    }
    Test.stopTest();
  }

  @IsTest
  static void testRetryStatusCodes() {
    Set<Integer> codes = new Set<Integer>{ 408, 409, 425, 502, 503, 504, 598, 599 };
    Test.startTest();
    for (Integer i : codes) {
      mock.setStatusCode(i);
      mock.next(); // retry is set to 1
      mock.setStatusCode(i);
      try {
        new HttpBuilder().endpoint(endpoint)
          .get()
          .delay(1)
          .retry(1)
          .send();
        System.assert(false, 'Expected an exception');
      } catch (HttpBuilderException e) { // the max retries were reached
        System.assert(true, 'Exception caught');
      }
      mock.next();
    }
    Test.stopTest();
  }

  @IsTest
  static void testClientErrorStatusCodes() {
    Set<Integer> codes = new Set<Integer>{ 304, 400, 401, 403, 404, 405, 406, 407, 416 };
    Test.startTest();
    for (Integer i : codes) {
      mock.setStatusCode(i);
      try {
        new HttpBuilder().endpoint(endpoint)
          .get()
          .send();
        System.assert(false, 'Expected an exception');
      } catch (System.CalloutException e) {
        System.assert(true, 'Exception caught');
      }
      mock.next();
    }
    Test.stopTest();
  }

  @IsTest
  static void testServerErrorStatusCodes() {
    Set<Integer> codes = new Set<Integer>{ 500, 501, 505, 506, 510, 511 };
    Test.startTest();
    for (Integer i : codes) {
      mock.setStatusCode(i);
      try {
        new HttpBuilder().endpoint(endpoint)
          .get()
          .send();
        System.assert(false, 'Expected an exception');
      } catch (System.CalloutException e) {
        System.assert(true, 'Exception caught');
      }
      mock.next();
    }
    Test.stopTest();
  }
}
