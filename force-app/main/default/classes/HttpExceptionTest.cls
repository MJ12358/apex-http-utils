@IsTest
public class HttpExceptionTest {

  @IsTest
  static void testSuccess() {
    System.HttpRequest req = new System.HttpRequest();
    req.setEndpoint('https://example.com/test?q=query');
    req.setBody('testing');
    System.HttpResponse res = new System.HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    Test.startTest();
    HttpException result = new HttpException(req, res);
    Test.stopTest();
    System.assert(String.isNotBlank(result.getContext()));
    System.assert(String.isNotBlank(result.getMessage()));
    System.assert(String.isNotBlank(result.getDebugMessage()));
    System.assertNotEquals(null, result.getRequest());
    System.assertNotEquals(null, result.getResponse());
  }

}
