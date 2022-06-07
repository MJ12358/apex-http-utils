@IsTest
public class HttpStatusTest {

  @IsTest
  static void testGetCode() {
    System.assertEquals(100, HttpStatus.getCode('Continue'));
    System.assertEquals(200, HttpStatus.getCode('OK'));
    System.assertEquals(300, HttpStatus.getCode('MULTIPLE_CHOICE'));
    System.assertEquals(400, HttpStatus.getCode('Bad Request'));
    System.assertEquals(500, HttpStatus.getCode('Internal Server Error'));
    System.assertEquals(0, HttpStatus.getCode('Should return 0'));
  }

  @IsTest
  static void testGetMessage() {
    System.assert(String.isNotBlank(HttpStatus.getMessage(100)));
    System.assert(String.isNotBlank(HttpStatus.getMessage(200)));
    System.assert(String.isNotBlank(HttpStatus.getMessage(300)));
    System.assert(String.isNotBlank(HttpStatus.getMessage(400)));
    System.assert(String.isNotBlank(HttpStatus.getMessage(500)));
    System.assert(String.isNotBlank(HttpStatus.getMessage(666)));
  }

  @IsTest
  static void testGetName() {
    System.assertEquals('CONTINUE', HttpStatus.getName(100));
    System.assertEquals('OK', HttpStatus.getName(200));
    System.assertEquals('MULTIPLE CHOICE', HttpStatus.getName(300));
    System.assertEquals('BAD REQUEST', HttpStatus.getName(400));
    System.assertEquals('INTERNAL SERVER ERROR', HttpStatus.getName(500));
    System.assertEquals('UNKNOWN STATUS: 666', HttpStatus.getName(666));
  }

}
