@IsTest
public class BaseRequestTest {

  private static String baseUrl = 'https://example.com';
  private static Integer cacheTtl = 14400;
  private static Boolean debug = false;
  private static Integer timeout = 10000;
  private static HttpMock mock;

  static {
    mock = new HttpMock();
  }

  @IsTest
  static void testConstructors() {
    Test.startTest();
    BaseRequest req = new BaseRequest(baseUrl);
    Test.stopTest();
    System.assert(String.isNotBlank(req.getRequestUrl()));
    System.assert(String.isNotBlank(req.getRequestUrl('test')));
  }

  @IsTest
  static void testError() {
    mock.setStaticResource('json_Blank');
    mock.setStatusCode(500);
    Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    try {
      new BaseRequest(baseUrl).send(HttpMethod.GET);
      System.assert(false, 'Expected an exception');
    } catch (HttpException e) {
      System.assert(true, 'Exception caught');
      System.assert(String.isNotBlank(e.getContext()));
      System.assert(String.isNotBlank(e.getErrorMessage()));
      System.assert(String.isNotBlank(e.getMessage()));
      System.assert(String.isNotBlank(e.getDebugMessage()));
    }
  }

  @IsTest
  static void testSend() {
    mock.setStaticResource('json_Blank');
    Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    BaseRequest req = new BaseRequest(baseUrl);
    req.addHeader('ContentType', 'application/json');
    req.addPath('testPath');
    req.addQuery('key', 'value');
    System.HttpResponse result = req.send(HttpMethod.GET, '"key": "value"');
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

}
