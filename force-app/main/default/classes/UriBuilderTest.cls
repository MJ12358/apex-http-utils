@IsTest
public class UriBuilderTest {

	private static final String BASEURL = 'https://example.com';

	@IsTest
	static void testBaseUrl() {
		Test.startTest();
		String result = new UriBuilder(BASEURL).build();
		Test.stopTest();
		System.assertEquals(BASEURL, result);
	}

	@IsTest
	static void testBasic() {
		Test.startTest();
		String result = new UriBuilder().scheme('https').host('example.com').build();
		Test.stopTest();
		System.assertEquals(BASEURL, result);
	}

	@IsTest
	static void testBasicEncode() {
		Test.startTest();
		String result = new UriBuilder().scheme('https').host('example.com').encode().build();
		Test.stopTest();
		System.assertEquals('https%3A%2F%2Fexample.com', result);
	}

	@IsTest
	static void testComplex() {
		Map<String, Object> query = new Map<String, Object>{'pid' => 456};
		Test.startTest();
		String result = new UriBuilder()
			.scheme('smb')
			.userinfo('root')
			.host('example.com')
			.port(22)
			.addPath('pwn')
			.addQuery('id', '123')
			.addQuery(query)
			.fragment('wtf')
			.build();
		Test.stopTest();
		System.assertEquals('smb://root@example.com:22/pwn?id=123&pid=456#wtf', result);
	}

	@IsTest
	static void testComplexOutOfOrder() {
		Test.startTest();
		String result = new UriBuilder()
			.fragment('wtf')
			.addQuery('id', '123')
			.addPath('pwn')
			.port(22)
			.host('example.com')
			.userinfo('root')
			.scheme('smb')
			.build();
		Test.stopTest();
		System.assertEquals('smb://root@example.com:22/pwn?id=123#wtf', result);
	}

	@IsTest
	static void testPortOutOfRange() {
		Test.startTest();
		try {
			new UriBuilder(BASEURL).port(0).build();
			System.assert(false, 'Expected an exception');
		} catch (UriBuilderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

	@IsTest
	static void testEncodeFailure() {
		Test.startTest();
		try {
			new UriBuilder(BASEURL).encode(null).build();
			System.assert(false, 'Expected an exception');
		} catch (UriBuilderException e) {
			System.assert(true, 'Exception caught');
		}
		Test.stopTest();
	}

}
