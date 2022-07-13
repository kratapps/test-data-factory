@IsTest
private class AssertTest {

    @IsTest
    private static void testFail() {
        try {
            Assert.fail();
            Assert.isTrue(false, 'Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }
    
    @IsTest
    private static void testIsTrue() {
        Assert.isTrue(true);

        try {
            Assert.isTrue(false);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsFalse() {
        Assert.isFalse(false);

        try {
            Assert.isFalse(true);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsNull() {
        Assert.isNull(null);

        try {
            Assert.isNull(0);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testNotNull() {
        Assert.notNull(0);

        try {
            Assert.notNull(null);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsEqual() {
        Assert.isEqual(0, 0);
        Assert.isEqual(0.1234, 0.1234);
        Assert.isEqual(123456789.123456789, 123456789.123456789);
        Assert.isEqual(-123456789.123456789, -123456789.123456789);
        Assert.isEqual('', '');
        Assert.isEqual('test', 'test');
        Assert.isEqual(true, true);
        Assert.isEqual(false, false);
        Assert.isEqual(new Account(), new Account());
        Assert.isEqual(Account.class, Account.class);
        Assert.isEqual(
                new Account(Name = 'name', Description = 'desc'),
                new Account(Description = 'desc', Name = 'name'));

        try {
            Assert.isEqual('test', 'test ');
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(-123456789.123456789, 123456789.123456789);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(new Account(Name = 'test'), new Account());
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(Assert.class, Account.class);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsEqualWithNull() {
        Assert.isEqual(null, null);
        try {
            Assert.isEqual(0, null);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual('', null);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsEqualWithCollections() {
        Assert.isEqual(null, null);
        Assert.isEqual(new String[0], new List<String>());
        Assert.isEqual(
                new List<String>{'a','b','c','d','e'},
                new String[]{'a','b','c','d','e'});
        Assert.isEqual(
                new List<List<String>>{new List<String>{'a','b'}, new List<String>{'c'}, null},
                new List<List<String>>{new List<String>{'a','b'}, new List<String>{'c'}, null});
        Assert.isEqual(
                new List<Object>{new Set<String>{'a','b'}, new List<String>{'c'}, 'a', 0, null},
                new List<Object>{new Set<String>{'a','b'}, new List<String>{'c'}, 'a', 0, null});
        Assert.isEqual(
                new Object[]{new Set<String>{'a','b'}, new List<String>{'c'}, 'a', 0, null},
                new Object[]{new Set<String>{'a','b'}, new List<String>{'c'}, 'a', 0, null});
        Assert.isEqual(
                new Set<Object>{new Set<Set<String>>{new Set<String>{'a'},new Set<String>{'b'}}, new List<String>{'c'}, 'a', 0, null},
                new Set<Object>{new Set<Set<String>>{new Set<String>{'a'},new Set<String>{'b'}}, new List<String>{'c'}, 'a', 0, null});

        try {
            Assert.isEqual(new String[0], null);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(
                    new List<String>{'a','b','c','d','e'},
                    new String[]{'a','b','c','d'});
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(
                    new List<List<String>>{new List<String>{'a','b'}, new List<String>{}, null},
                    new List<List<String>>{new List<String>{'a','b'}, new List<String>{'c'}, null});
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(
                    new List<Object>{new Set<String>{'a','b'}},
                    new List<Object>{new List<String>{'a','b'}});
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsEqualWithDelta() {
        Assert.isEqual(0.1, 0.1, 0.0);
        Assert.isEqual(1.0, 1.0, 0.0);
        Assert.isEqual(1.123456, 1.123456, 0.0);
        Assert.isEqual(10.0, 8.0, 2.0);
        Assert.isEqual(8.0, 10.0, 2.0);
        Assert.isEqual(10.001, 8.001, 2.0);
        Assert.isEqual(8.001, 10.001, 2.0);

        try {
            Assert.isEqual(8.0, 10.0, 1.0009);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(10.001, 8.002, 2.0);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.isEqual(8.000, 10.001, 2.0);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testNotEqual() {
        Assert.notEqual('test', 'test ');
        Assert.notEqual(-123456789.123456789, 123456789.123456789);
        Assert.notEqual(new Account(Name = 'test'), new Account());
        Assert.notEqual(Assert.class, Account.class);

        try {
            Assert.notEqual(-123456789.123456789, -123456789.123456789);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.notEqual('', '');
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.notEqual(new Account(), new Account());
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        try {
            Assert.notEqual(
                    new Account(Name = 'name', Description = 'desc'),
                    new Account(Description = 'desc', Name = 'name'));
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testIsSame() {
        Account acc1 = new Account();
        Account acc2 = new Account();
        Account acc3 = new Account(Name = 'name');

        Assert.isSame(acc1, acc1);
        Assert.isSame(acc2, acc2);
        Assert.isSame(acc3, acc3);
        
        try {
            Assert.isSame(acc1, acc2);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }

        try {
            Assert.isSame(acc1, acc3);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testNotSame() {
        Account acc1 = new Account();
        Account acc2 = new Account();
        Account acc3 = new Account(Name = 'name');

        Assert.notSame(acc1, acc2);
        Assert.notSame(acc1, acc3);
        Assert.notSame(acc2, acc3);

        try {
            Assert.notSame(acc1, acc1);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }

        try {
            Assert.notSame(acc3, acc3);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testContains() {
        Assert.contains('aaa', 'a');
        Assert.contains('aaa', 'aa');
        Assert.contains('==ABC==', 'ABC');

        try {
            Assert.contains('aaa', 'AAA');
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        
        try {
            Assert.contains('aaa', null);
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
        
        try {
            Assert.contains(null, 'aaa');
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testNotContains() {
        Assert.notContains('aaa', 'AAA');

        try {
            Assert.notContains('aaa', 'a');
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }

        try {
            Assert.notContains('==ABC==', 'ABC');
            Assert.fail('Exception expected.');
        } catch (Assert.AssertionException e) {
        }
    }

    @IsTest
    private static void testFormatFailMessage() {
        String formatted = Assert.formatFailMessage('test', 0, 0);

        Assert.isTrue(formatted.contains('test '));
        Assert.isFalse(formatted.contains('Integer'));

        formatted = Assert.formatFailMessage('test', 0, 'string');
        Assert.isTrue(formatted.contains('test '));
        Assert.isTrue(formatted.contains('Integer'));
        Assert.isTrue(formatted.contains('String'));
    }

    private class AssertExtension extends Assert {
    }

    @IsTest
    private static void testGetObjectType() {
        Assert.isNull(Assert.getObjectType(null));
        Assert.isEqual(Integer.class, Assert.getObjectType(0));
        Assert.isEqual(Decimal.class, Assert.getObjectType(0.0));
        Assert.isEqual(String.class, Assert.getObjectType(''));
        Assert.isEqual(Account.class, Assert.getObjectType(new Account()));
    }
    
    @IsTest
    private static void testGetObjectTypeString() {
        Assert.isNull(Assert.getObjectTypeString(null));
        Assert.isEqual('Integer', Assert.getObjectTypeString(0));
        Assert.isEqual('Decimal', Assert.getObjectTypeString(0.0));
        Assert.isEqual('String', Assert.getObjectTypeString(''));
        Assert.isEqual('Account', Assert.getObjectTypeString(new Account()));
        Assert.isTrue(Assert.getObjectTypeString(new AssertExtension()).endsWith('AssertExtension'));
    }
}