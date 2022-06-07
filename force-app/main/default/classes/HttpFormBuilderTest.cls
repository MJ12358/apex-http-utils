@IsTest
public class HttpFormBuilderTest {

  @IsTest
  static void testPut() {
    Test.startTest();
    HttpFormBuilder builder = new HttpFormBuilder();
    builder.put('key1', 'test');
    String contentType = builder.getContentType();
    Blob result = builder.build();
    Test.stopTest();
    System.assert(String.isNotBlank(contentType));
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testGet() {
    Test.startTest();
    HttpFormBuilder builder = new HttpFormBuilder();
    builder.put('key1', 'test');
    builder.put('key2', 123);
    Blob result = builder.build();
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals('test', builder.get('key1'));
    System.assertEquals(123, builder.get('key2'));
  }

  @IsTest
  static void testPutFile() {
    Blob value = Blob.valueOf('ABCDEFG123456');
    Test.startTest();
    HttpFormBuilder builder = new HttpFormBuilder();
    builder.put('key1', System.EncodingUtil.base64Encode(value), 'filename.txt');
    Blob result = builder.build();
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

}
