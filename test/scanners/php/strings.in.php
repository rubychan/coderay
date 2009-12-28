Single quoted
<?php
echo 'this is a simple string';

echo 'You can also have embedded newlines in 
strings this way as it is
okay to do';

// Outputs: Arnold once said: "I'll be back"
echo 'Arnold once said: "I\'ll be back"';

// Outputs: You deleted C:\*.*?
echo 'You deleted C:\\*.*?';

// Outputs: You deleted C:\*.*?
echo 'You deleted C:\*.*?';

// Outputs: This will not expand: \n a newline
echo 'This will not expand: \n a newline';

// Outputs: Variables do not $expand $either
echo 'Variables do not $expand $either';
?>

Double quoted

<?php
$escape_sequences = "\n\r\t\v\f\\\$\"\000-\777\x0-\xFF";
?>

Heredoc

Example #1 Invalid example
<?php
class foo {
    public $bar = <<<EOT
bar
EOT;
}
?>

Example #2 Heredoc string quoting example

<?php
$str = <<<EOD
Example of string
spanning multiple lines
using heredoc syntax.
EOD;

/* More complex example, with variables. */
class foo
{
    var $foo;
    var $bar;

    function foo()
    {
        $this->foo = 'Foo';
        $this->bar = array('Bar1', 'Bar2', 'Bar3');
    }
}

$foo = new foo();
$name = 'MyName';

echo <<<EOT
My name is "$name". I am printing some $foo->foo.
Now, I am printing some {$foo->bar[1]}.
This should print a capital 'A': \x41
EOT;
?>

The above example will output:

My name is "MyName". I am printing some Foo.
Now, I am printing some Bar2.
This should print a capital 'A': A

Example #3 Heredoc in arguments example

<?php
var_dump(array(<<<EOD
foobar!
EOD
));
?>

Example #4 Using Heredoc to initialize static values

<?php
// Static variables
function foo()
{
    static $bar = <<<LABEL
Nothing in here...
LABEL;
}

// Class properties/constants
class foo
{
    const BAR = <<<FOOBAR
Constant example
FOOBAR;

    public $baz = <<<FOOBAR
Property example
FOOBAR;
}
?>

Example #5 Using double quotes in Heredoc

<?php
echo <<<"FOOBAR"
Hello $World!
FOOBAR;
?>

Nowdoc

Example #6 Nowdoc string quoting example

<?php
$str = <<<'EOD'
Example of string
spanning multiple lines
using nowdoc syntax.
EOD;

/* More complex example, with variables. */
class foo
{
    public $foo;
    public $bar;

    function foo()
    {
        $this->foo = 'Foo';
        $this->bar = array('Bar1', 'Bar2', 'Bar3');
    }
}

$foo = new foo();
$name = 'MyName';

echo <<<'EOT'
My name is "$name". I am printing some $foo->foo.
Now, I am printing some {$foo->bar[1]}.
This should not print a capital 'A': \x41
EOT;
?>
The above example will output:

My name is "$name". I am printing some $foo->foo.
Now, I am printing some {$foo->bar[1]}.
This should not print a capital 'A': \x41

Example #7 Static data example

<?php
class foo {
    public $bar = <<<'EOT'
bar
EOT;
}
?>

Variable parsing

When a string is specified in double quotes or with heredoc, variables are parsed within it.

There are two types of syntax: a simple one and a complex one. The simple syntax is the most common and convenient. It provides a way to embed a variable, an array value, or an object property in a string with a minimum of effort.

The complex syntax was introduced in PHP 4, and can be recognised by the curly braces surrounding the expression.

Simple syntax

If a dollar sign ($) is encountered, the parser will greedily take as many tokens as possible to form a valid variable name. Enclose the variable name in curly braces to explicitly specify the end of the name.

<?php
$beer = 'Heineken';
echo "$beer's taste is great"; // works; "'" is an invalid character for variable names
echo "He drank some $beers";   // won't work; 's' is a valid character for variable names but the variable is "$beer"
echo "He drank some ${beer}s"; // works
echo "He drank some {$beer}s"; // works
?>
Similarly, an array index or an object property can be parsed. With array indices, the closing square bracket (]) marks the end of the index. The same rules apply to object properties as to simple variables.

<?php
// These examples are specific to using arrays inside of strings.
// When outside of a string, always quote array string keys and do not use
// {braces}.

// Show all errors
error_reporting(E_ALL);

$fruits = array('strawberry' => 'red', 'banana' => 'yellow');

// Works, but note that this works differently outside a string
echo "A banana is $fruits[banana].";

// Works
echo "A banana is {$fruits['banana']}.";

// Works, but PHP looks for a constant named banana first, as described below.
echo "A banana is {$fruits[banana]}.";

// Won't work, use braces.  This results in a parse error.
echo "A banana is $fruits['banana'].";

// Works
echo "A banana is " . $fruits['banana'] . ".";

// Works
echo "This square is $square->width meters broad.";

// Won't work. For a solution, see the complex syntax.
echo "This square is $square->width00 centimeters broad.";
?>
For anything more complex, you should use the complex syntax.

Complex (curly) syntax

This isn't called complex because the syntax is complex, but because it allows for the use of complex expressions.

In fact, any value in the namespace can be included in a string with this syntax. Simply write the expression the same way as it would appear outside the string, and then wrap it in { and }. Since { can not be escaped, this syntax will only be recognised when the $ immediately follows the {. Use {\$ to get a literal {$. Some examples to make it clear:

<?php
// Show all errors
error_reporting(E_ALL);

$great = 'fantastic';

// Won't work, outputs: This is { fantastic}
echo "This is { $great}";

// Works, outputs: This is fantastic
echo "This is {$great}";
echo "This is ${great}";

// Works
echo "This square is {$square->width}00 centimeters broad."; 

// Works
echo "This works: {$arr[4][3]}";

// This is wrong for the same reason as $foo[bar] is wrong  outside a string.
// In other words, it will still work, but only because PHP first looks for a
// constant named foo; an error of level E_NOTICE (undefined constant) will be
// thrown.
echo "This is wrong: {$arr[foo][3]}"; 

// Works. When using multi-dimensional arrays, always use braces around arrays
// when inside of strings
echo "This works: {$arr['foo'][3]}";

// Works.
echo "This works: " . $arr['foo'][3];

echo "This works too: {$obj->values[3]->name}";

echo "This is the value of the var named $name: {${$name}}";

echo "This is the value of the var named by the return value of getName(): {${getName()}}";

echo "This is the value of the var named by the return value of \$object->getName(): {${$object->getName()}}";
?>
It is also possible to access class properties using variables within strings using this syntax.

<?php
class foo {
    var $bar = 'I am bar.';
}

$foo = new foo();
$bar = 'bar';
$baz = array('foo', 'bar', 'baz', 'quux');
echo "{$foo->$bar}\n";
echo "{$foo->$baz[1]}\n";
?>
The above example will output:
I am bar.
I am bar.

Note: Functions, method calls, static class variables, and class constants inside {$} work since PHP 5. However, the value accessed will be interpreted as the name of a variable in the scope in which the string is defined. Using single curly braces ({}) will not work for accessing the return values of functions or methods or the values of class constants or static class variables. 
<?php
// Show all errors.
error_reporting(E_ALL);

class beers {
    const softdrink = 'rootbeer';
    public static $ale = 'ipa';
}

$rootbeer = 'A & W';
$ipa = 'Alexander Keith\'s';

// This works; outputs: I'd like an A & W
echo "I'd like an {${beers::softdrink}}\n";

// This works too; outputs: I'd like an Alexander Keith's
echo "I'd like an {${beers::$ale}}\n";
?>
String access and modification by character

Characters within strings may be accessed and modified by specifying the zero-based offset of the desired character after the string using square array brackets, as in $str[42]. Think of a string as an array of characters for this purpose.

Note: Strings may also be accessed using braces, as in $str{42}, for the same purpose. However, this syntax is deprecated as of PHP 5.3.0. Use square brackets instead, such as $str[42].

Warning
Writing to an out of range offset pads the string with spaces. Non-integer types are converted to integer. Illegal offset type emits E_NOTICE. Negative offset emits E_NOTICE in write but reads empty string. Only the first character of an assigned string is used. Assigning empty string assigns NUL byte.

Example #8 Some string examples
<?php
// Get the first character of a string
$str = 'This is a test.';
$first = $str[0];

// Get the third character of a string
$third = $str[2];

// Get the last character of a string.
$str = 'This is still a test.';
$last = $str[strlen($str)-1]; 

// Modify the last character of a string
$str = 'Look at the sea';
$str[strlen($str)-1] = 'e';

?>

String conversion to numbers

<?php
$foo = 1 + "10.5";                // $foo is float (11.5)
$foo = 1 + "-1.3e3";              // $foo is float (-1299)
$foo = 1 + "bob-1.3e3";           // $foo is integer (1)
$foo = 1 + "bob3";                // $foo is integer (1)
$foo = 1 + "10 Small Pigs";       // $foo is integer (11)
$foo = 4 + "10.2 Little Piggies"; // $foo is float (14.2)
$foo = "10.0 pigs " + 1;          // $foo is float (11)
$foo = "10.0 pigs " + 1.0;        // $foo is float (11)     
?>

<?php
echo "\$foo==$foo; type is " . gettype ($foo) . "<br />\n";
?>

If you want a parsed variable surrounded by curly braces, just double the curly braces: 

<?php 
  $foo = "bar"; 
  echo "{{$foo}}"; 
?>

Although current documentation says 'A string literal can be specified in four different ways: ...', actually there is a fifth way to specify a (binary) string: 

<?php $binary = b'This is a binary string'; ?>
