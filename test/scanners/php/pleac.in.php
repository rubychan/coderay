# -*- php -*-
# The examples are taken from the Perl Cookbook
# By Tom Christiansen & Nathan Torkington
# see http://www.oreilly.com/catalog/cookbook for more

# @@PLEAC@@_NAME
# @@SKIP@@ PHP

# @@PLEAC@@_WEB
# @@SKIP@@ http://php.net/

# @@PLEAC@@_1.0
#-----------------------------
$string = '\n';                     # two characters, \ and an n
$string = 'Jon \'Maddog\' Orwant';  # literal single quotes
$string = 'Jon "Maddog" Orwant';    # literal double quotes
#-----------------------------
$string = "\n";                     # a "newline" character
$string = "Jon \"Maddog\" Orwant";  # literal double quotes
$string = "Jon 'Maddog' Orwant";    # literal single quotes
#-----------------------------
$a = 
"This is a multiline
here document";

$a = <<<EOF
This is a multiline here document
terminated by EOF on a line by itself
EOF;
#-----------------------------

# @@PLEAC@@_1.1
#-----------------------------
$value = substr($string, $offset, $count);
$value = substr($string, $offset);

$string = substr_replace($string, $newstring, $offset, $count);
$string = substr_replace($string, $newtail, $offset);
#-----------------------------
# get a 5-byte string, skip 3, then grab 2 8-byte strings, then the rest
list($leading, $s1, $s2, $trailing) =
    array_values(unpack("A5a/x3/A8b/A8c/A*d", $data);

# split at five byte boundaries
preg_match_all ("/.{5}/", $data, $f, PREG_PATTERN_ORDER);
$fivers = $f[0];

# chop string into individual characters
$chars  = $string;
#-----------------------------
$string = "This is what you have";
#         +012345678901234567890  Indexing forwards  (left to right)
#          109876543210987654321- Indexing backwards (right to left)
#           note that 0 means 10 or 20, etc. above

$first  = substr($string, 0, 1);  # "T"
$start  = substr($string, 5, 2);  # "is"
$rest   = substr($string, 13);    # "you have"
$last   = substr($string, -1);    # "e"
$end    = substr($string, -4);    # "have"
$piece  = substr($string, -8, 3); # "you"
#-----------------------------
$string = "This is what you have";
print $string;
#This is what you have

$string = substr_replace($string, "wasn't", 5, 2);  # change "is" to "wasn't"
#This wasn't what you have

$string = substr_replace($string, "ondrous", -12);  # "This wasn't wondrous"
#This wasn't wondrous

$string = substr_replace($string, "", 0, 1);        # delete first character
#his wasn't wondrous

$string = substr_replace($string, "", -10);         # delete last 10 characters
#his wasn'
#-----------------------------
if (preg_match("/pattern/", substr($string, -10)) {
    print "Pattern matches in last 10 characters\n";
}

# substitute "at" for "is", restricted to first five characters
$string=(substr_replace(preg_replace("/is/", "at", substr($string,0,5)),0,5);
#-----------------------------
# exchange the first and last letters in a string
$a = "make a hat";
list($a[0], $a[strlen($a)-1]) = Array(substr($a,-1), substr($a,0,1));
print $a;

#-----------------------------
# extract column with unpack
$a = "To be or not to be";
$b = unpack("x6/A6a", $a);  # skip 6, grab 6
print $b['a'];


$b = unpack("x6/A2b/X5/A2c", $a); # forward 6, grab 2; backward 5, grab 2
print $b['b']."\n".$b['c']."\n";

#-----------------------------
function cut2fmt() {
    $positions = func_get_args();
    $template  = '';
    $lastpos   = 1;
    foreach($positions as $place) {
        $template .= "A" . ($place - $lastpos) . " ";
        $lastpos   = $place;
    }
    $template .= "A*";
    return $template;
}

$fmt = cut2fmt(8, 14, 20, 26, 30);
print "$fmt\n";
#A7 A6 A6 A6 A4 A*
#-----------------------------

# @@PLEAC@@_1.2
#-----------------------------
# use $b if $b is true, else $c
$a = $b?$b:$c;

# set $x to $y unless $x is already true
$x || $x=$y;
#-----------------------------
# use $b if $b is defined, else $c
$a = defined($b) ? $b : $c;
#-----------------------------
$foo = $bar || $foo = "DEFAULT VALUE";
#-----------------------------
$dir = array_shift($_SERVER['argv']) || $dir = "/tmp";
#-----------------------------
$dir = $_SERVER['argv'][0] || $dir = "/tmp";
#-----------------------------
$dir = defined($_SERVER['argv'][0]) ? array_shift($_SERVER['argv']) : "/tmp";
#-----------------------------
$dir = count($_SERVER['argv']) ? $_SERVER['argv'][0] : "/tmp";
#-----------------------------
$count[$shell?$shell:"/bin/sh"]++;
#-----------------------------
# find the user name on Unix systems
$user = $_ENV['USER']
     || $user = $_ENV['LOGNAME']
     || $user = posix_getlogin()
     || $user = posix_getpwuid(posix_getuid())[0]
     || $user = "Unknown uid number $<";
#-----------------------------
$starting_point || $starting_point = "Greenwich";
#-----------------------------
count($a) || $a = $b;          # copy only if empty
$a = count($b) ? $b : $c;          # assign @b if nonempty, else @c
#-----------------------------

# @@PLEAC@@_1.3
#-----------------------------
list($VAR1, $VAR2) = array($VAR2, $VAR1);
#-----------------------------
$temp    = $a;
$a       = $b;
$b       = $temp;
#-----------------------------
$a       = "alpha";
$b       = "omega";
list($a, $b) = array($b, $a);        # the first shall be last -- and versa vice
#-----------------------------
list($alpha, $beta, $production) = Array("January","March","August");
# move beta       to alpha,
# move production to beta,
# move alpha      to production
list($alpha, $beta, $production) = array($beta, $production, $alpha);
#-----------------------------

# @@PLEAC@@_1.4
#-----------------------------
$num  = ord($char);
$char = chr($num);
#-----------------------------
$char = sprintf("%c", $num);                # slower than chr($num)
printf("Number %d is character %c\n", $num, $num);
#-----------------------------
$ASCII = unpack("C*", $string);
eval('$STRING = pack("C*", '.implode(',',$ASCII).');');
#-----------------------------
$ascii_value = ord("e");    # now 101
$character   = chr(101);    # now "e"
#-----------------------------
printf("Number %d is character %c\n", 101, 101);
#-----------------------------
$ascii_character_numbers = unpack("C*", "sample");
print explode(" ",$ascii_character_numbers)."\n";

eval('$word = pack("C*", '.implode(',',$ascii_character_numbers).');');
$word = pack("C*", 115, 97, 109, 112, 108, 101);   # same
print "$word\n";
#-----------------------------
$hal = "HAL";
$ascii = unpack("C*", $hal);
foreach ($ascii as $val) {
    $val++;                 # add one to each ASCII value
}
eval('$ibm = pack("C*", '.implode(',',$ascii).');');
print "$ibm\n";             # prints "IBM"
#-----------------------------

# @@PLEAC@@_1.5
#-----------------------------
// using perl regexp
$array = preg_split('//', $string ,-1, PREG_SPLIT_NO_EMPTY);
// using PHP function: $array = str_split($string);

// Cannot use unpack with a format of 'U*' in PHP.
#-----------------------------
for ($offset = 0; preg_match('/(.)/', $string, $matches, 0, $offset) > 0; $offset++) {
    // $matches[1] has charcter, ord($matches[1]) its number
}
#-----------------------------
$seen = array();
$string = "an apple a day";
foreach (str_split($string) as $char) {
    $seen[$char] = 1;
}
$keys = array_keys($seen);
sort($keys);
print "unique chars are: " . implode('', $keys)) . "\n";
unique chars are:  adelnpy
#-----------------------------
$seen = array();
$string = "an apple a day";
for ($offset = 0; preg_match('/(.)/', $string, $matches, 0, $offset) > 0; $offset++) {
    $seen[$matches[1]] = 1;
}
$keys = array_keys($seen);
sort($keys);
print "unique chars are: " . implode('', $keys) . "\n";
unique chars are:  adelnpy
#-----------------------------
$sum = 0;
foreach (unpack("C*", $string) as $byteval) {
    $sum += $byteval;
}
print "sum is $sum\n";
// prints "1248" if $string was "an apple a day"
#-----------------------------
$sum = array_sum(unpack("C*", $string));
#-----------------------------

// sum - compute 16-bit checksum of all input files
$handle = @fopen($argv[1], 'r');
$checksum = 0;
while (!feof($handle)) {
    $checksum += (array_sum(unpack("C*", fgets($handle))));
}
$checksum %= pow(2,16) - 1;
print "$checksum\n";

# @@INCLUDE@@ include/php/slowcat.php
#-----------------------------

# @@PLEAC@@_1.6
#-----------------------------
$revchars = strrev($string);
#-----------------------------
$revwords = implode(" ", array_reverse(explode(" ", $string)));
#-----------------------------
// reverse word order
$string = 'Yoda said, "can you see this?"';
$allwords    = explode(" ", $string);
$revwords    = implode(" ", array_reverse($allwords));
print $revwords . "\n";
this?" see you "can said, Yoda
#-----------------------------
$revwords = implode(" ", array_reverse(explode(" ", $string)));
#-----------------------------
$revwords = implode(" ", array_reverse(preg_split("/(\s+)/", $string)));
#-----------------------------
$word = "reviver";
$is_palindrome = ($word === strrev($word));
#-----------------------------
// quite a one-liner since "php" does not have a -n switch
% php -r 'while (!feof(STDIN)) { $word = rtrim(fgets(STDIN)); if ($word == strrev($word) && strlen($word) > 5) print $word; }' < /usr/dict/words
#-----------------------------

# @@PLEAC@@_1.8
#-----------------------------
$text = preg_replace('/\$(\w+)/e', '$$1', $text);
#-----------------------------
list($rows, $cols) = Array(24, 80);
$text = 'I am $rows high and $cols long';
$text = preg_replace('/\$(\w+)/e', '$$1', $text);
print $text;

#-----------------------------
$text = "I am 17 years old";
$text = preg_replace('/(\d+)/e', '2*$1', $text);
#-----------------------------
# expand variables in $text, but put an error message in
# if the variable isn't defined
$text = preg_replace('/\$(\w+)/e','isset($$1)?$$1:\'[NO VARIABLE: $$1]\'', $text);
#-----------------------------

// As PHP arrays are used as hashes too, separation of section 4
// and section 5 makes little sense.

# @@PLEAC@@_1.9
#-----------------------------
$big = strtoupper($little);
$little = strtolower($big);
// PHP does not have the\L and\U string escapes.
#-----------------------------
$big = ucfirst($little);
$little = strtolower(substr($big, 0, 1)) . substr($big, 1);
#-----------------------------
$beast   = "dromedary";
// capitalize various parts of $beast
$capit   = ucfirst($beast); // Dromedar
// PHP does not have the\L and\U string escapes.
$capall  = strtoupper($beast); // DROMEDAR
// PHP does not have the\L and\U string escapes.
$caprest = strtolower(substr($beast, 0, 1)) . substr(strtoupper($beast), 1); // dROMEDAR
// PHP does not have the\L and\U string escapes.
#-----------------------------
// titlecase each word's first character, lowercase the rest
$text = "thIS is a loNG liNE";
$text = ucwords(strtolower($text));
print $text;
This Is A Long Line
#-----------------------------
if (strtoupper($a) == strtoupper($b)) { // or strcasecmp($a, $b) == 0
    print "a and b are the same\n";
}
#-----------------------------
# @@INCLUDE@@ include/php/randcap.php

// % php randcap.php < genesis | head -9
#-----------------------------

# @@PLEAC@@_1.10
#-----------------------------
echo $var1 . func() . $var2; // scalar only
#-----------------------------
// PHP can only handle variable expression without operators
$answer = "STRING ${[ VAR EXPR ]} MORE STRING";
#-----------------------------
$phrase = "I have " . ($n + 1) . " guanacos.";
// PHP cannot handle the complex exression: ${\($n + 1)}
#-----------------------------
// Rest of Discussion is not applicable to PHP
#-----------------------------
// Interpolating functions not available in PHP
#-----------------------------

# @@PLEAC@@_1.11
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_1.12
#-----------------------------
$output = wordwrap($str, $width, $break, $cut);
#-----------------------------
# @@INCLUDE@@ include/php/wrapdemo.php
#-----------------------------
// merge multiple lines into one, then wrap one long line
print wordwrap(str_replace("\n", " ", file_get_contents('php://stdin')));
#-----------------------------
while(!feof(STDIN)) {
    print wordwrap(str_replace("\n", " ", stream_get_line(STDIN, 0, "\n\n")));
    print "\n\n";
}
#-----------------------------

# @@PLEAC@@_1.13
#-----------------------------
//backslash
$var = preg_replace('/([CHARLIST])/', '\\\$1', $var);
// double
$var = preg_replace('/([CHARLIST])/', '$1$1', $var);
#-----------------------------
$var = preg_replace('/%/', '%%', $var);
#-----------------------------
$string = 'Mom said, "Don\'t do that."';
$string = preg_replace('/([\'"])/', '\\\$1', $string);
// in PHP you can also use the addslashes() function
#-----------------------------
$string = 'Mom said, "Don\'t do that."';
$string = preg_replace('/([\'"])/', '$1$1', $string);
#-----------------------------
$string = preg_replace('/([^A-Z])/', '\\\$1', $string);
#-----------------------------
// PHP does not have the \Q and \E string metacharacters
$string = "this is\\ a\\ test\\!";
// PHP's quotemeta() function is not the same as perl's quotemeta() function
$string = preg_replace('/(\W)/', '\\\$1', 'is a test!');
#-----------------------------

# @@PLEAC@@_1.14
#-----------------------------
$string = trim($string);
#-----------------------------
// print what's typed, but surrounded by > < symbols
while (!feof(STDIN)) {
    print ">" . substr(fgets(STDIN), 0, -1) . "<\n";
}
#-----------------------------
$string = preg_replace('/\s+/', ' ', $string); // finally, collapse middle
#-----------------------------
$string = trim($string);
$string = preg_replace('/\s+/', ' ', $string);
#-----------------------------
// 1. trim leading and trailing white space
// 2. collapse internal whitespace to single space each
function sub_trim($string) {
    $string = trim($string);
    $string = preg_replace('/\s+/', ' ', $string);
    return $string;
}
#-----------------------------

# @@PLEAC@@_1.15
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_1.16
#-----------------------------
$code = soundex($string);
#-----------------------------
$phoned_words = metaphone("Schwern");
#-----------------------------
// substitution function for getpwent():
// returns an array of user entries,
// each entry contains the username and the full name
function getpwent() {
    $pwents = array();
    $handle = fopen("passwd", "r");
    while (!feof($handle)) {
        $line = fgets($handle);
        if (preg_match("/^#/", $line)) continue;
        $cols = explode(":", $line);
        $pwents[$cols[0]] = $cols[4];
    }
    return $pwents;
}

print "Lookup user: ";
$user = rtrim(fgets(STDIN));
if (empty($user)) exit;
$name_code = soundex($user);
$pwents = getpwent();
foreach($pwents as $username => $fullname) {
    preg_match("/(\w+)[^,]*\b(\w+)/", $fullname, $matches);
    list(, $firstname, $lastname) = $matches;
  
    if ($name_code == soundex($username) ||
        $name_code == soundex($lastname) ||
        $name_code == soundex($firstname))
    {
        printf("%s: %s %s\n", $username, $firstname, $lastname);
    }
}
#-----------------------------

# @@PLEAC@@_1.17
#-----------------------------
# @@INCLUDE@@ include/php/fixstyle.php
#-----------------------------
# @@INCLUDE@@ include/php/fixstyle2.php
#-----------------------------
// very fast, but whitespace collapse
while (!feof($input)) {
  $i = 0;
  preg_match("/^(\s*)(.*)/", fgets($input), $matches); // emit leading whitespace
  fwrite($output, $matches[1]);
  foreach (preg_split("/(\s+)/", $matches[2]) as $token) { // preserve trailing whitespace
    fwrite($output, (array_key_exists($token, $config) ? $config[$token] : $token) . " ");
  }
  fwrite($output, "\n");
}
#-----------------------------

// @@PLEAC@@_2.0
// As is the case under so many other languages floating point use under PHP is fraught
// with dangers. Although the basic techniques shown below are valid, please refer to
// the official PHP documentation for known issues, bugs, and alternate approaches 

// @@PLEAC@@_2.1
// Two basic approaches to numeric validation:
// * Built-in functions like 'is_numeric', 'is_int', 'is_float' etc
// * Regexes, as shown below

$s = '12.345';

preg_match('/\D/', $s) && die("has nondigits\n");
preg_match('/^\d+$/', $s) || die("not a natural number\n");
preg_match('/^-?\d+$/', $s) || die("not an integer\n");
preg_match('/^[+-]?\d+$/', $s) || die("not an integer\n");
preg_match('/^-?\d+\.?\d*$/', $s) || die("not a decimal\n");
preg_match('/^-?(?:\d+(?:\.\d*)?|\.\d+)$/', $s) || die("not a decimal\n");
preg_match('/^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/', $s) || die("not a C float\n");

// ----------------------------

function getnum($s)
{
  sscanf($s, "%D", $number); return isset($number) ? $number : 0;
}

echo getnum(123) . "\n";   // ok
echo getnum(0xff) . "\n";  // ..
echo getnum(044) . "\n";   // ..

echo getnum('x') . "\n";   // fail

// @@PLEAC@@_2.2
// In PHP floating point comparisions are 'safe' [meaning the '==' comparison operator
// can be used] as long as the value consists of 14 digits or less [total digits, either
// side of the decimal point e.g. xxxxxxx.xxxxxxx, xxxxxxxxxxxxxx., .xxxxxxxxxxxxxx]. If
// values with more digits must be compared, then:
//
// * Represent as strings, and take care to avoid any implicit conversions e.g. don't pass
//   a float as a float to a function and expect all digits to be retained - they won't be -
//   then use 'strcmp' to compare the strings
//
// * Avoid float use; perhaps use arbitrary precision arithmetic. In this case, the
//   'bccomp' function is relevant

// Will work as long as each floating point value is 14 digits or less
if ($float_1 == $float_2)
{
  ; // ...
}

// Compare as strings
$cmp = strcmp('123456789.123456789123456789', '123456789.123456789123456788');

// Use 'bccomp'
$precision = 5; // Number of significant comparison digits after decimal point
if (bccomp('1.111117', '1.111116', $precision))
{
  ; // ...
}

$precision = 6;
if (bccomp('1.111117', '1.111116', $precision))
{
  ; // ...
}

// ----------------------------

$wage = 536;
$week = $wage * 40;
printf("One week's wage is: $%.2f\n", $week / 100);

// @@PLEAC@@_2.3
// Preferred approach
$rounded = round($unrounded, $precision);

// Possible alternate approach
$format = '%[width].[prec]f';
$rounded = sprintf($format, $unrounded);

// ------------

$a = 0.255; $b = round($a, 2);
echo "Unrounded: {$a}\nRounded: {$b}\n";

$a = 0.255; $b = sprintf('%.2f', $a);
echo "Unrounded: {$a}\nRounded: {$b}\n";

$a = 0.255;
printf("Unrounded: %.f\nRounded: %.2f\n", $a, $a);

// ----------------------------

echo "number\tint\tfloor\tceil\n";

foreach(array(3.3, 3.5, 3.7, -3.3) as $number)
{
  printf("%.1f\t%.1f\t%.1f\t%.1f\n", $number, (int) $number, floor($number), ceil($number));
}

// @@PLEAC@@_2.4
// PHP offers the 'bindec' and 'decbin' functions to converting between binary and decimal

$num = bindec('0110110');

$binstr = decbin(54);

// @@PLEAC@@_2.5
foreach (range($X, $Y) as $i)
{
  ; // ...
}

foreach (range($X, $Y, 7) as $i)
{
  ; // ...
}

for ($i = $X; $i <= $Y; $i++)
{
  ; // ...
}

for ($i = $X; $i <= $Y; $i += 7)
{
  ; // ...
}

// ----------------------------

echo 'Infancy is:'; foreach(range(0, 2) as $i) echo " {$i}\n";
echo 'Toddling is:'; foreach(range(3, 4) as $i) echo " {$i}\n";
echo 'Childhood is:'; foreach(range(5, 12) as $i) echo " {$i}\n";

// @@PLEAC@@_2.6
// PHP offers no native support for Roman Numerals. However, a 'Numbers_Roman' class
// is available for download from PEAR: [http://pear.php.net/package/Numbers_Roman].
// Note the following 'include' directives are required:
//
//   include_once('Numbers/Roman.php');

$roman = Numbers_Roman::toNumeral($arabic);
$arabic = Numbers_Roman::toNumber($roman);

// ----------------------------

$roman_fifteen = Numbers_Roman::toNumeral(15);

$arabic_fifteen = Numbers_Roman::toNumber($roman_fifteen);

printf("Roman for fifteen is: %s\n", $roman_fifteen);
printf("Arabic for fifteen is: %d\n", $arabic_fifteen);

// @@PLEAC@@_2.7
// Techniques used here simply mirror Perl examples, and are not an endorsement
// of any particular RNG technique

// In PHP do this ...
$random = rand($lowerbound, $upperbound);
$random = rand($x, $y);

// ----------------------------

function make_password($chars, $reqlen)
{
  $len = strlen($chars);
  for ($i = 0; $i < $reqlen; $i++) $password .= substr($chars, rand(0, $len), 1);
  return $password;
}

$chars = 'ABCDEfghijKLMNOpqrstUVWXYz'; $reqlen = 8;

$password = make_password($chars, $reqlen);

// @@PLEAC@@_2.8
// PHP sports a large number of C Standard Library routines including the 'srand'
// function, used to re-seed the RNG used with calls to the 'rand' function. Thus,
// as per Perl example:

while (TRUE)
{
  $seed = (int) fgets(STDIN);
  if (!empty($seed)) break;
}

srand($seed);

// @@PLEAC@@_2.9
// The above is considered - for many reasons - a poor way of seeding the RNG. PHP
// also offers alternate versions of the functions, 'mt_srand' and 'mt_rand',
// which are described as faster, and more 'random', though key to obtaining a
// more 'random' distribution of generated numbers seems to be through using
// a combination of a previously saved random value in combination with an
// unrepeatable value [like the current time in microseconds] that is multiplied
// by a large prime number, or perhaps as part of a hash [examples available in
// PHP documentation for 'srand' and 'mt_srand']

mt_srand($saved_random_value + microtime() * 1000003);

// or

mt_srand(($saved_random_value + hexdec(substr(md5(microtime()), -8))) & 0x7fffffff);

// Use of 'mt_rand' together with an appropriate seeding approach should help better
// approximate the generation of a 'truly random value'
$truly_random_value = mt_rand();

// @@PLEAC@@_2.10
function random() { return (float) rand() / (float) getrandmax(); }

function gaussian_rand()
{
  $u1 = 0.0; $u2 = 0.0; $g1 = 0.0; $g2 = 0.0; $w = 0.0;
  
  do
  {
    $u1 = 2.0 * random() - 1.0; $u2 = 2.0 * random() - 1.0;
    $w = $u1 * $u1 + $u2 * $u2;
  } while ($w > 1.0);
  
  $w = sqrt((-2.0 * log($w)) / $w); $g2 = $u1 * $w; $g1 = $u2 * $w;

  return $g1;
}

// ------------

$mean = 25.0; $sdev = 2.0;
$salary = gaussian_rand() * $mean + $sdev;

printf("You have been hired at: %.2f\n", $salary);

// @@PLEAC@@_2.11
// 'deg2rad' and 'rad2deg' are actually PHP built-ins, but here is how you might implement
/  them if needed
function deg2rad_($deg) { return ($deg / 180.0) * M_PI; }
function rad2deg_($rad) { return ($rad / M_PI) * 180.0; }

// ------------

printf("%f\n", deg2rad_(180.0));
printf("%f\n", deg2rad(180.0));

// ----------------------------

function degree_sin($deg) { return sin(deg2rad($deg)); }

// ------------

$rad = deg2rad(380.0);

printf("%f\n", sin($rad));
printf("%f\n", degree_sin(380.0));

// @@PLEAC@@_2.12
function my_tan($theta) { return sin($theta) / cos($theta); }

// ------------

$theta = 3.7;

printf("%f\n", my_tan($theta));
printf("%f\n", tan($theta));

// @@PLEAC@@_2.13
$value = 100.0;

$log_e = log($value);
$log_10 = log10($value);

// ----------------------------

function log_base($base, $value) { return log($value) / log($base); }

// ------------

$answer = log_base(10.0, 10000.0);

printf("log(10, 10,000) = %f\n", $answer);

// @@PLEAC@@_2.14
// PHP offers no native support for matrices. However, a 'Math_Matrix' class
// is available for download from PEAR: [http://pear.php.net/package/Math_Matrix].
// Note the following 'include' directives are required:
//
//  include_once('Math/Matrix.php');

$a = new Math_Matrix(array(array(3, 2, 3), array(5, 9, 8)));
$b = new Math_Matrix(array(array(4, 7), array(9, 3), array(8, 1)));

echo $a->toString() . "\n";
echo $b->toString() . "\n";

// NOTE: When I installed this package I had to rename the 'clone' method else
// it would not load, so I chose to rename it to 'clone_', and this usage is
// shown below. This bug may well be fixed by the time you obtain this package

$c = $a->clone_();
$c->multiply($b);

echo $c->toString() . "\n";

// @@PLEAC@@_2.15
// PHP offers no native support for complex numbers. However, a 'Math_Complex' class
// is available for download from PEAR: [http://pear.php.net/package/Math_Complex].
// Note the following 'include' directives are required:
//
//   include_once('Math/Complex.php');
//   include_once('Math/TrigOp.php');
//   include_once('Math/ComplexOp.php');

$a = new Math_Complex(3, 5);
$b = new Math_Complex(2, -2);

$c = Math_ComplexOp::mult($a, $b);

echo $c->toString() . "\n";

// ----------------------------

$d = new Math_Complex(3, 4);
$r = Math_ComplexOp::sqrt($d);

echo $r->toString() . "\n";

// @@PLEAC@@_2.16
// Like C, PHP supports decimal-alternate notations. Thus, for example, the integer
// value, 867, is expressable in literal form as:
//
//   Hexadecimal -> 0x363
//   Octal       -> 01543
//
// For effecting such conversions using strings there is 'sprintf' and 'sscanf'.

$dec = 867;
$hex = sprintf('%x', $dec);
$oct = sprintf('%o', $dec);

// ------------

$dec = 0;
$hex = '363';

sscanf($hex, '%x', $dec);

// ------------

$dec = 0;
$oct = '1543';

sscanf($oct, '%o', $dec);

// ----------------------------

$number = 0;

printf('Gimme a number in decimal, octal, or hex: ');
sscanf(fgets(STDIN), '%D', $number);

printf("%d %x %o\n", $number, $number, $number);

// @@PLEAC@@_2.17
// PHP offers the 'number_format' built-in function to, among many other format tasks, 
// commify numbers. Perl-compatible [as well as extended] regexes are also available

function commify_series($s) { return number_format($s, 0, '', ','); }

// ------------

$hits = 3456789;

printf("Your website received %s accesses last month\n", commify_series($hits));

// ----------------------------

function commify($s)
{
  return strrev(preg_replace('/(\d\d\d)(?=\d)(?!\d*\.)/', '${1},', strrev($s)));
}

// ------------

$hits = 3456789;

echo commify(sprintf("Your website received %d accesses last month\n", $hits));

// @@PLEAC@@_2.18
function pluralise($value, $root, $singular='' , $plural='s')
{
  return $root . (($value > 1) ? $plural : $singular);
}

// ------------

$duration = 1;
printf("It took %d %s\n", $duration, pluralise($duration, 'hour'));
printf("%d %s %s enough.\n", $duration, pluralise($duration, 'hour'),
      pluralise($duration, '', 'is', 'are'));

$duration = 5;
printf("It took %d %s\n", $duration, pluralise($duration, 'hour'));
printf("%d %s %s enough.\n", $duration, pluralise($duration, 'hour'),
      pluralise($duration, '', 'is', 'are'));

// ----------------------------

function plural($singular)
{
  $s2p = array('/ss$/' => 'sses', '/([psc]h)$/' => '${1}es', '/z$/' => 'zes',
               '/ff$/' => 'ffs', '/f$/' => 'ves', '/ey$/' => 'eys',
               '/y$/' => 'ies', '/ix$/' => 'ices', '/([sx])$/' => '$1es',
               '$' => 's');

  foreach($s2p as $s => $p)
  {
    if (preg_match($s, $singular)) return preg_replace($s, $p, $singular);
  }
}

// ------------

foreach(array('mess', 'index', 'leaf', 'puppy') as $word)
{
  printf("%6s -> %s\n", $word, plural($word));
}

// @@PLEAC@@_2.19
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_3.0
// PHP's date / time suport is quite extensive, and appears grouped into three areas of
// functionality:
//
// * UNIX / C Library [libc]-based routines, which include [among others]:
//   - localtime, gmtime
//   - strftime, strptime, mktime
//   - time, getdate, gettimeofday, 
//
// * PHP 'native' functions, those date / time routines released in earlier versions,
//   and which otherwise provide 'convenience' functionality; these include:
//   - date
//   - strtotime
//
// * 'DateTime' class-based. This facility appears [according to the PHP documentation]
//   to be extremely new / experimental, so whilst usage examples will be provided, they
//   should not be taken to be 'official' examples, and obviously, subject to change.
//   My own impression is that this facility is currently only partially implemented,
//   so there is limited use for these functions. The functions included in this group
//   are some of the 'date_'-prefixed functions; they are, however, not used standalone,
//   but as methods in conjunction with an object. Typical usage:
//
//     $today = new DateTime();             // actually calls: date_create($today, ...);
//     echo $today->format('U') . "\n";     // actually calls: date_format($today, ...);
//
// Also worth mentioning is the PEAR [PHP Extension and Repository] package, 'Calendar',
// which offers a rich set of date / time manipulation facilities. However, since it is
// not currently shipped with PHP, no examples appear

// Helper functions for performing date arithmetic 

function dateOffset()
{
  static $tbl = array('sec' => 1, 'min' => 60, 'hou' => 3600, 'day' => 86400, 'wee' => 604800);
  $delta = 0;

  foreach (func_get_args() as $arg)
  {
    $kv = explode('=', $arg);
    $delta += $kv[1] * $tbl[strtolower(substr($kv[0], 0, 3))];
  }

  return $delta;
}

function dateInterval($intvltype, $timevalue)
{
  static $tbl = array('sec' => 1, 'min' => 60, 'hou' => 3600, 'day' => 86400, 'wee' => 604800);
  return (int) round($timevalue / $tbl[strtolower(substr($intvltype, 0, 3))]);
}

// ----------------------------

// Extract indexed array from 'getdate'
$today = getdate();
printf("Today is day %d of the current year\n", $today['yday']);

// Extract indexed, and associative arrays, respectively, from 'localtime'
$today = localtime();
printf("Today is day %d of the current year\n", $today[7]);

$today = localtime(time(), TRUE);
printf("Today is day %d of the current year\n", $today['tm_yday']);

// @@PLEAC@@_3.1
define(SEP, '-');

// ------------

$today = getdate();

$day = $today['mday'];
$month = $today['mon'];
$year = $today['year'];

// Either do this to use interpolation:
$sep = SEP;
echo "Current date is: {$year}{$sep}{$month}{$sep}{$day}\n";

// or simply concatenate:
echo 'Current date is: ' . $year . SEP . $month . SEP . $day . "\n";

// ------------

$today = localtime(time(), TRUE);

$day = $today['tm_mday'];
$month = $today['tm_mon'] + 1;
$year = $today['tm_year'] + 1900;

printf("Current date is: %4d%s%2d%s%2d\n", $year, SEP, $month, SEP, $day);

// ------------

$format = 'Y' . SEP . 'n' . SEP . 'd';

$today = date($format);

echo "Current date is: {$today}\n";

// ------------

$sep = SEP;

$today = strftime("%Y$sep%m$sep%d");

echo "Current date is: {$today}\n";

// @@PLEAC@@_3.2
$timestamp = mktime($hour, $min, $sec, $month, $day, $year);

$timestamp = gmmktime($hour, $min, $sec, $month, $day, $year);

// @@PLEAC@@_3.3
$dmyhms = getdate();            // timestamp: current date / time

$dmyhms = getdate($timestamp);  // timestamp: arbitrary

$day = $dmyhms['mday'];
$month = $dmyhms['mon'];
$year = $dmyhms['year'];

$hours = $dmyhms['hours'];
$minutes = $dmyhms['minutes'];
$seconds = $dmyhms['seconds'];

// @@PLEAC@@_3.4
// Date arithmetic is probably most easily performed using timestamps [i.e. *NIX Epoch
// Seconds]. Dates - in whatever form - are converted to timestamps, these are
// arithmetically manipulated, and the result converted to whatever form required.
// Note: use 'mktime' to create timestamps properly adjusted for daylight saving; whilst
// 'strtotime' is more convenient to use, it does not, AFAIK, include this adjustment

$when = $now + $difference;
$then = $now - $difference;

// ------------

$now = mktime(0, 0, 0, 8, 6, 2003);

$diff1 = dateOffset('day=1'); $diff2 = dateOffset('weeks=2');

echo 'Today is:                 ' . date('Y-m-d', $now) . "\n";
echo 'One day in the future is: ' . date('Y-m-d', $now + $diff1) . "\n";
echo 'Two weeks in the past is: ' . date('Y-m-d', $now - $diff2) . "\n";

// ----------------------------

// Date arithmetic performed using a custom function, 'dateOffset'. Internally, offset may
// be computed in one of several ways:
// * Direct timestamp manipulation - fastest, but no daylight saving adjustment 
// * Via 'date' built-in function - slower [?], needs a base time from which to
//   compute values, but has daylight saving adjustment 
// * Via 'strtotime' built-in function - as for 'date'
// * Via 'DateTime' class
//
// Approach used here is to utilise direct timestamp manipulation in 'dateOffset' [it's
// performance can also be improved by replacing $tbl with a global definition etc],
// and to illustrate how the other approaches might be used 

// 1. 'dateOffset'

$birthtime = mktime(3, 45, 50, 1, 18, 1973);

$interval = dateOffset('day=55', 'hours=2', 'min=17', 'sec=5');

$then = $birthtime + $interval;

printf("Birthtime is: %s\nthen is:      %s\n", date(DATE_RFC1123, $birthtime), date(DATE_RFC1123, $then));

// ------------

// 2. 'date'

// Base values, and offsets, respectively
$hr = 3; $min = 45; $sec = 50; $mon = 1; $day = 18; $year = 1973;

$yroff = 0; $monoff = 0; $dayoff = 55; $hroff = 2; $minoff = 17; $secoff = 5;

// Base date
$birthtime = mktime($hr, $min, $sec, $mon, $day, $year, TRUE);

$year = date('Y', $birthtime) + $yroff;
$mon = date('m', $birthtime) + $monoff;
$day = date('d', $birthtime) + $dayoff;

$hr = date('H', $birthtime) + $hroff;
$min = date('i', $birthtime) + $minoff;
$sec = date('s', $birthtime) + $secoff;

// Offset date
$then = mktime($hr, $min, $sec, $mon, $day, $year, TRUE);

printf("Birthtime is: %s\nthen is:      %s\n", date(DATE_RFC1123, $birthtime), date(DATE_RFC1123, $then));

// ------------

// 3. 'strtotime'

// Generate timestamp whatever way is preferable
$birthtime = mktime(3, 45, 50, 1, 18, 1973);
$birthtime = strtotime('1/18/1973 03:45:50');

$then = strtotime('+55 days 2 hours 17 minutes 2 seconds', $birthtime);

printf("Birthtime is: %s\nthen is:      %s\n", date(DATE_RFC1123, $birthtime), date(DATE_RFC1123, $then));

// ------------

// 4. 'DateTime' class

$birthtime = new DateTime('1/18/1973 03:45:50');
$then = new DateTime('1/18/1973 03:45:50');
$then->modify('+55 days 2 hours 17 minutes 2 seconds');

printf("Birthtime is: %s\nthen is:      %s\n", $birthtime->format(DATE_RFC1123), $then->format(DATE_RFC1123));

// @@PLEAC@@_3.5
// Date intervals are most easily computed using timestamps [i.e. *NIX Epoch
// Seconds] which, of course, gives the interval result is seconds from which
// all other interval measures [days, weeks, months, years] may be derived.
// Refer to previous section for discussion of daylight saving and other related
// problems

$interval_seconds = $recent - $earlier;

// ----------------------------

// Conventional approach ...
$bree = strtotime('16 Jun 1981, 4:35:25');
$nat = strtotime('18 Jan 1973, 3:45:50');

// ... or, with daylight saving adjustment
$bree = mktime(4, 35, 25, 6, 16, 1981, TRUE);
$nat = mktime(3, 45, 50, 1, 18, 1973, TRUE);

$difference = $bree - $nat;

// 'dateInterval' custom function computes intervals in several measures given an
// interval in seconds. Note, 'month' and 'year' measures not provided
printf("There were %d seconds between Nat and Bree\n", $difference);
printf("There were %d weeks between Nat and Bree\n", dateInterval('weeks', $difference));
printf("There were %d days between Nat and Bree\n", dateInterval('days', $difference));
printf("There were %d hours between Nat and Bree\n", dateInterval('hours', $difference));
printf("There were %d minutes between Nat and Bree\n", dateInterval('mins', $difference));

// @@PLEAC@@_3.6
// 'getdate' accepts a timestamp [or implicitly calls 'time'] and returns an array of
// date components. It returns much the same information as 'strptime' except that
// the component names are different

$today = getdate();

$weekday = $today['wday'];
$monthday = $today['mday'];
$yearday = $today['yday'];

$weeknumber = (int) round($yearday / 7.0);

// Safter method of obtaining week number
$weeknumber = strftime('%U') + 1;

// ----------------------------

define(SEP, '/');

$day = 16;
$month = 6;
$year = 1981;

$timestamp = mktime(0, 0, 0, $month, $day, $year);

$date = getdate($timestamp);

$weekday = $date['wday'];
$monthday = $date['mday'];
$yearday = $date['yday'];

$weeknumber = (int) round($yearday / 7.0);

$weeknumber = strftime('%U', $timestamp) + 1;

// Interpolate ...
$sep = SEP;
echo "{$month}{$sep}{$day}{$sep}{$year} was a {$date['weekday']} in week {$weeknumber}\n";

// ... or, concatenate
echo $month . SEP . $day . SEP . $year . ' was a ' . $date['weekday']
     . ' in week ' . $weeknumber . "\n";

// @@PLEAC@@_3.7
// 'strtotime' parses a textual date expression by attempting a 'best guess' at
// the format, and either fails, or generates a timestamp. Timestamp could be fed
// into any one of the various functions; example:
$timestamp = strtotime('1998-06-03'); echo strftime('%Y-%m-%d', $timestamp) . "\n";

// 'strptime' parses a textual date expression according to a specified format,
// and returns an array of date components; components can be easily dumped
print_r(strptime('1998-06-03', '%Y-%m-%d'));

// ----------------------------

// Parse date string according to format
$darr = strptime('1998-06-03', '%Y-%m-%d');

if (!empty($darr))
{
  // Show date components in 'debug' form
  print_r($darr);

  // Check whether there was a parse error i.e. one or more components could not
  // be extracted from the string
  if (empty($darr['unparsed']))
  {
    // Properly parsed date, so validate required components using, 'checkdate'
    if (checkdate($darr['tm_mon'] + 1, $darr['tm_mday'], $darr['tm_year'] + 1900))
      echo "Parsed date verified as correct\n";
    else
      echo "Parsed date failed verification\n";
  }
  else
  {
    echo "Date string parse not complete; failed components: {$darr['unparsed']}\n";
  }
}
else
{
  echo "Date string could not be parsed\n";
}

// @@PLEAC@@_3.8
// 'date' and 'strftime' both print a date string based on:
// * Format String, describing layout of date components
// * Timestamp [*NIX Epoch Seconds], either given explicitly, or implictly
//   via a call to 'time' which retrieves current time value

$ts = 1234567890;

date('Y/m/d', $ts); 
date('Y/m/d', mktime($h, $m, $s, $mth, $d, $y, $is_dst)); 

date('Y/m/d');         // same as: date('Y/m/d', time());

// ------------

$ts = 1234567890;

strftime('%Y/%m/%d', $ts);
strftime('%Y/%m/%d', mktime($h, $m, $s, $mth, $d, $y, $is_dst));

strftime('%Y/%m/%d');  // same as: strftime('%Y/%m/%d', time());

// ----------------------------

// 'mktime' creates a local time timestamp
$t = strftime('%a %b %e %H:%M:%S %z %Y', mktime(3, 45, 50, 1, 18, 73, TRUE));
echo "{$t}\n";

// 'gmmktime' creates a GMT time timestamp
$t = strftime('%a %b %e %H:%M:%S %z %Y', gmmktime(3, 45, 50, 1, 18, 73));
echo "{$t}\n";

// ----------------------------

// 'strtotime' parses a textual date expression, and generates a timestamp 
$t = strftime('%A %D', strtotime('18 Jan 1973, 3:45:50'));
echo "{$t}\n";

// This should generate output identical to previous example
$t = strftime('%A %D', mktime(3, 45, 50, 1, 18, 73, TRUE));
echo "{$t}\n";

// @@PLEAC@@_3.9
// PHP 5 and above can use the built-in, 'microtime'. Crude implementation for ealier versions:
// function microtime() { $t = gettimeofday(); return (float) ($t['sec'] + $t['usec'] / 1000000.0); } 

// ------------

$before = microtime();

$line = fgets(STDIN);

$elapsed = microtime() - $before;

printf("You took %.3f seconds\n", $elapsed);

// ------------

define(NUMBER_OF_TIMES, 100);
define(SIZE, 500);

for($i = 0; $i < NUMBER_OF_TIMES; $i++)
{
  $arr = array();
  for($j = 0; $j < SIZE; $j++) $arr[] = rand();

  $begin = microtime();
  sort($arr);
  $elapsed = microtime() - $begin;

  $total_time += $elapsed;
}

printf("On average, sorting %d random numbers takes %.5f seconds\n", SIZE, $total_time / (float) NUMBER_OF_TIMES);

// @@PLEAC@@_3.10
// Low-resolution: sleep time specified in seconds
sleep(1);

// High-resolution: sleep time specified in microseconds [not reliable under Windows]
usleep(250000);

// @@PLEAC@@_3.11
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_4.0
// Nested arrays are supported, and may be easily printed using 'print_r'

$nested = array('this', 'that', 'the', 'other');

$nested = array('this', 'that', array('the', 'other')); print_r($nested);

$tune = array('The', 'Star-Spangled', 'Banner');

// @@PLEAC@@_4.1
// PHP offers only the 'array' type which is actually an associative array, though
// may be numerically indexed, to mimic vectors and matrices; there is no separate
// 'list' type

$a = array('quick', 'brown', 'fox');

// ------------

$a = escapeshellarg('Why are you teasing me?');

// ------------

$lines = <<<END_OF_HERE_DOC
    The boy stood on the burning deck,
    it was as hot as glass.
END_OF_HERE_DOC;

// ------------

$bigarray = array_map('rtrim', file('mydatafile'));

// ------------

$banner = 'The mines of Moria';

$banner = escapeshellarg('The mines of Moria');

// ------------

$name = 'Gandalf';

$banner = "Speak {$name}, and enter!";

$banner = 'Speak ' . escapeshellarg($name) . ' and welcome!';

// ------------

$his_host = 'www.perl.com';

$host_info = `nslookup $his_host`;

$cmd = 'ps ' . posix_getpid(); $perl_info = `$cmd`;

$shell_info = `ps $$`;

// ------------

$banner = array('Costs', 'only', '$4.95');

$banner = array_map('escapeshellarg', split(' ', 'Costs only $4.95'));

// ------------

// AFAIK PHP doesn't support non-quoted strings ala Perl's 'q', 'qq' and 'qw', so arrays
// created from strings must use quoted strings, and make use of 'split' [or equivalent].
// A slew of functions exist for performing string quoting, including 'escapeshellarg',
// 'quotemeta', and 'preg_quote'

$brax = split(' ', '( ) < > { } [ ]');

// Do this to quote each element within '..'
// $brax = array_map('escapeshellarg', split(' ', '( ) < > { } [ ]'));

$rings = split(' ', 'Nenya Narya Vilya');

$tags = split(' ', 'LI TABLE TR TD A IMG H1 P');

$sample = split(' ', 'The vertical bar | looks and behaves like a pipe.');

// @@PLEAC@@_4.2
function commify_series($list)
{
  $n = str_word_count($list); $series = str_word_count($list, 1);

  if ($n == 0) return NULL;
  if ($n == 1) return $series[0];
  if ($n == 2) return $series[0] . ' and ' . $series[1];
  
  return join(', ', array_slice($series, 0, -1)) . ', and ' . $series[$n - 1];
}

// ------------

echo commify_series('red') . "\n";
echo commify_series('red yellow') . "\n";
echo commify_series('red yellow green') . "\n";

$mylist = 'red yellow green';
echo 'I have ' . commify_series($mylist) . " marbles.\n";

// ----------------------------

function commify_series($arr)
{
  $n = count($arr); $sepchar = ',';

  foreach($arr as $str)
  {
    if (strpos($str, ',') === false) continue;
    $sepchar = ';'; break; 
  }

  if ($n == 0) return NULL;
  if ($n == 1) return $arr[0];
  if ($n == 2) return $arr[0] . ' and ' . $arr[1];
  
  return join("{$sepchar} ", array_slice($arr, 0, -1)) . "{$sepchar} and " . $arr[$n - 1];
}

// ------------

$lists = array(
  array('just one thing'),
  split(' ', 'Mutt Jeff'),
  split(' ', 'Peter Paul Mary'),
  array('To our parents', 'Mother Theresa', 'God'),
  array('pastrami', 'ham and cheese', 'peanut butter and jelly', 'tuna'),
  array('recycle tired, old phrases', 'ponder big, happy thoughts'),
  array('recycle tired, old phrases', 'ponder big, happy thoughts', 'sleep and dream peacefully'));

foreach($lists as $arr)
{
  echo 'The list is: ' . commify_series($arr) . ".\n";
}

// @@PLEAC@@_4.3
// AFAICT you cannot grow / shrink an array to an arbitrary size. However, you can:
// * Grow an array by appending an element using subscrip notation, or using
//   either 'array_unshift' or 'array_push' to add one or more elements

$arr[] = 'one';
array_unshift($arr, 'one', 'two', 'three');
array_push($arr, 'one', 'two', 'three');

// * Shrink an array by using 'unset' to remove one or more specific elements, or
//   either 'array_shift' or 'array_pop' to remove an element from the ends

unset($arr[$idx1], $arr[$idx2], $arr[$idx3]);
$item = array_shift($arr);
$item = array_pop($arr);

// ----------------------------

function what_about_the_array()
{
  global $people;

  echo 'The array now has ' . count($people) . " elements\n";
  echo 'The index value of the last element is ' . (count($people) - 1) . "\n";
  echo 'Element #3 is ' . $people[3] . "\n";
}

$people = array('Crosby', 'Stills', 'Nash', 'Young');
what_about_the_array();

array_pop($people);
what_about_the_array();

// Cannot, AFAICT, resize the array to an arbitrary size

# @@PLEAC@@_4.4
foreach ($list as $item) {
    // do something with $item
}

// Environment listing example

// PHP defines a superglobal $_ENV to provide access to environment
// variables.

// Beware, array assignment means copying in PHP. You need to use
// the reference operator to avoid copying. But we want a copy here.
$env = $_ENV;

// PHP can sort an array by key, so you don't need to get keys,
// and then sort.
ksort($env);

foreach ($env as $key => $value) {
    echo "{$key}={$value}\n";
}

// Literal translation of Perl example would be:
$keys = array_keys($_ENV);
sort($keys);
foreach ($keys as $key) {
    echo "{$key}={$_ENV[$key]}\n";
}

// This assumes that MAX_QUOTA is a named constant.
foreach ($all_users as $user) {
    $disk_space = get_usage($user);
    if ($disk_space > MAX_QUOTA) {
        complain($user);
    }
}

// You can't modify array's elements in-place.
$array = array(1, 2, 3);
$newarray = array();
foreach ($array as $item) {
    $newarray[] = $item - 1;
}
print_r($newarray);

// Before PHP 5, that is. You can precede the reference operator
// before $item to get reference instead of copy.
$array = array(1, 2, 3);
foreach ($array as &$item) {
    $item--;
}
print_r($array);

// TODO: explain the old each() and list() iteration construct.
// foreach is new in PHP 4, and there are subtle differences.

// @@PLEAC@@_4.5
// Conventional 'read-only' access
foreach($array as $item)
{
  ; // Can access, but not update, array element referred to by '$item'
}

// ----

// '&' makes '$item' a reference
foreach($array as &$item)
{
  ; // Update array element referred to by '$item'
}

// ------------

$arraylen = count($array);

for($i = 0; $i < $arraylen; $i++)
{
  ; // '$array' is updateable via subscript notation
}

// ----------------------------

$fruits = array('Apple', 'Raspberry');

foreach($fruits as &$fruit)
{
  echo "{$fruit} tastes good in a pie.\n";
}

$fruitlen = count($fruits);

for($i = 0; $i < $fruitlen; $i++)
{
  echo "{$fruits[$i]} tastes good in a pie.\n";
}

// ----------------------------

$rogue_cats = array('Blackie', 'Goldie', 'Silkie');

// Take care to assign reference to '$rogue_cats' array via '=&'
$namelist['felines'] =& $rogue_cats;

// Take care to make '$cat' a reference via '&$' to allow updating
foreach($namelist['felines'] as &$cat)
{
  $cat .= ' [meow]';
}

// Via array reference
foreach($namelist['felines'] as $cat)
{
  echo "{$cat} purrs hypnotically.\n";
}

echo "---\n";

// Original array
foreach($rogue_cats as $cat)
{
  echo "{$cat} purrs hypnotically.\n";
}

// @@PLEAC@@_4.6
// PHP offers the 'array_unique' function to perform this task. It works with both keyed,
// and numerically-indexed arrays; keys / indexes are preserved; use of 'array_values' 
// is recommended to reindex numerically-indexed arrays since there will likely be missing
// indexes

// Remove duplicate values
$unique = array_unique($array);

// Remove duplicates, and reindex [for numerically-indexed arrays only]
$unique = array_values(array_unique($array));

// or use:
$unique = array_keys(array_flip($array));

// ----------------------------

// Selected Perl 'seen' examples
foreach($list as $item)
{
  if (!isset($seen[$item]))
  {
    $seen[$item] = TRUE;
    $unique[] = $item;
  }
}

// ------------

foreach($list as $item)
{
  $seen[$item] || (++$seen[$item] && ($unique[] = $item));
}

// ------------

function some_func($item)
{
  ; // Do something with '$item'
}

foreach($list as $item)
{
  $seen[$item] || (++$seen[$item] && some_func($item));
}

// ----------------------------

foreach(array_slice(preg_split('/\n/', `who`), 0, -1) as $user_entry)
{
  $user = preg_split('/\s/', $user_entry);
  $ucnt[$user[0]]++;
}

ksort($ucnt);

echo "users logged in:\n";

foreach($ucnt as $user => $cnt)
{
  echo "\t{$user} => {$cnt}\n";
}

// @@PLEAC@@_4.7
// PHP offers the 'array_diff' and 'array_diff_assoc' functions to perform this task. Same
// points as made about 'array_unique' apply here also

$a = array('c', 'a', 'b', 'd');
$b = array('c', 'a', 'b', 'e');

$diff = array_diff($a, $b);                 // $diff -> [3] 'd'
$diff = array_diff($b, $a);                 // $diff -> [3] 'e'

// Numerically-indexed array, reindexed
$diff = array_values(array_diff($a, $b));   // $diff -> [0] 'd'
$diff = array_values(array_diff($b, $a));   // $diff -> [0] 'e'

// ----------------------------

// 1st Perl 'seen' example only

$a = array('k1' => 11, 'k2' => 12, 'k4' => 14);
$b = array('k1' => 11, 'k2' => 12, 'k3' => 13);

foreach($b as $item => $value) { $seen[$item] = 1; }

// Stores key only e.g. $aonly[0] contains 'k4', same as Perl example
foreach($a as $item => $value) { if (!$seen[$item]) $aonly[] = $item; }

// Stores key and value e.g. $aonly['k4'] contains 14, same entry as in $a
foreach($a as $item => $value) { if (!$seen[$item]) $aonly[$item] = $value; }

// ----------------------------

// Conventional way: $hash = array('key1' => 1, 'key2' => 2);

$hash['key1'] = 1;
$hash['key2'] = 2;

$hash = array_combine(array('key1', 'key2'), array(1, 2));

// ------------

$seen = array_slice($b, 0);

$seen = array_combine(array_keys($b), array_fill(0, count($b), 1));

// @@PLEAC@@_4.8
// PHP offers a number of array-based 'set operation' functions:
// * union:        array_unique(array_merge(...))
// * intersection: array_intersect and family
// * difference:   array_diff and family
// which may be used for this type of task. Also, if returned arrays need to be
// reindexed, 'array_slice($array, 0)', or 'array_values($array)' are useful

$a = array(1, 3, 5, 6, 7, 8);
$b = array(2, 3, 5, 7, 9);

$union = array_values(array_unique(array_merge($a, $b))); // 1, 2, 3, 5, 6, 7, 8, 9
$isect = array_values(array_intersect($a, $b));           // 3, 5, 7
$diff = array_values(array_diff($a, $b));                 // 1, 8

// @@PLEAC@@_4.9
// PHP offers the 'array_merge' function to perform this task. Duplicate values are retained,
// but if arrays are numerically-indexed, resulting array is reindexed

$arr1 = array('c', 'a', 'b', 'd');
$arr2 = array('c', 'a', 'b', 'e');

$new = array_merge($arr1, $arr2);     // $new -> 'c', 'a', 'b', 'd', 'c', 'a', 'b', 'd'

// ----------------------------

$members = array('Time', 'Flies');
$initiates = array('An', 'Arrow');

$members = array_merge($members, $initiates);

// ------------

$members = array('Time', 'Flies');
$initiates = array('An', 'Arrow');

// 'array_splice' is the PHP equivalent to Perl's 'splice'
array_splice($members, 2, 0, array_merge(array('Like'), $initiates));
echo join(' ', $members) . "\n";

array_splice($members, 0, 1, array('Fruit'));
array_splice($members, -2, 2, array('A', 'Banana'));
echo join(' ', $members) . "\n";

// @@PLEAC@@_4.10
$reversed = array_reverse($array);

// ----------------------------

foreach(array_reverse($array) as $item)
{
  ; // ... do something with '$item' ...
}

// ------------

for($i = count($array) - 1; $i >= 0; $i--)
{
  ; // ... do something with '$array[$i]' ...
}

// ----------------------------

sort($array);
$array = array_reverse($array);

// ------------

rsort($array);

// @@PLEAC@@_4.11
// Array elements can be deleted using 'unset'; removing several elements would require applying
// 'unset' several times, probably in a loop. However, they would most likely also need to be
// reindexed, so a better approach would be to use 'array_slice' which avoids explicit looping.
// Where elements need to be removed, and those elements also returned, it is probably best to
// combine both operations in a function. This is the approach taken here in implementing both
// 'shiftN' and 'popN', and it is these functions that are used in the examples

function popN(&$arr, $n)
{
  $ret = array_slice($arr, -($n), $n);
  $arr = array_slice($arr, 0, count($arr) - $n);
  return $ret;
}

function shiftN(&$arr, $n)
{
  $ret = array_slice($arr, 0, $n);
  $arr = array_slice($arr, $n);
  return $ret;
}

// ------------

// Remove $n elements from the front of $array; return them in $fron
$front = shiftN($array, $n);

// Remove $n elements from the end of $array; return them in $end
$end = popN($array, $n);

// ------------

$friends = array('Peter', 'Paul', 'Mary', 'Jim', 'Tim');

list($this_, $that) = shiftN($friends, 2);

echo "{$this_} {$that}\n";

// ------------

$beverages = array('Dew', 'Jolt', 'Cola', 'Sprite', 'Fresca');

$pair = popN($beverages, 2);

echo join(' ', $pair) . "\n";

// @@PLEAC@@_4.12
// This section illustrates various 'find first' techniques. The Perl examples all use an
// explicit loop and condition testing [also repeated here]. This is the simplest, and
// [potentially] most efficient approach because the search can be terminated as soon as a
// match is found. However, it is worth mentioning a few alternatives:
// * 'array_search' performs a 'find first' using the element value rather than a condition
//    check, so isn't really applicable here
// * 'array_filter', whilst using a condition check, actually performs a 'find all', though
//   all but the first returned element can be discarded. This approach is actually less error
//   prone than using a loop, but the disadvantage is that each element is visited: there is no
//   means of terminating the search once a match has been found. It would be nice if this
//   function were to have a third parameter, a Boolean flag indicating whether to traverse
//   the whole array, or quit after first match [next version, maybe :) ?]

$found = FALSE;

foreach($array as $item)
{
  // Not found - skip to next item
  if (!$criterion) continue;

  // Found - save and leave
  $match = $item;
  $found = TRUE;
  break;  
}

if ($found)
{
  ; // do something with $match
}
else
{
  ; // not found
}

// ------------

function predicate($element)
{
  if (criterion) return TRUE;
  return FALSE;
}

$match = array_slice(array_filter($array, 'predicate'), 0, 1);

if ($match)
{
  ; // do something with $match[0]
}
else
{
  ; // $match is empty - not found
}

// ----------------------------

class Employee
{
  public $name, $age, $ssn, $salary;

  public function __construct($name, $age, $ssn, $salary, $category)
  {
    $this->name = $name;
    $this->age = $age;
    $this->ssn = $ssn;
    $this->salary = $salary;
    $this->category = $category;
  }
}

// ------------

$employees = array(
  new Employee('sdf', 27, 12345, 47000, 'Engineer'),
  new Employee('ajb', 32, 12376, 51000, 'Programmer'),
  new Employee('dgh', 31, 12355, 45000, 'Engineer'));

// ------------

function array_update($arr, $lambda, $updarr)
{
  foreach($arr as $key) $lambda($updarr, $key);
  return $updarr;
}

function highest_salaried_engineer(&$arr, $employee)
{
  static $highest_salary = 0;
  
  if ($employee->category == 'Engineer')
  {
    if ($employee->salary > $highest_salary)
    {
      $highest_salary = $employee->salary;
      $arr[0] = $employee;
    }
  }
}

// ------------

// 'array_update' custom function is modelled on 'array_reduce' except that it allows the
// return of an array, contents and length of which are entirely dependant on what the
// callback function does. Here, it is logically working in a 'find first' capacity
$highest_salaried_engineer = array_update($employees, 'highest_salaried_engineer', array());

echo 'Highest paid engineer is: ' . $highest_salaried_engineer[0]->name . "\n";

// @@PLEAC@@_4.13
// PHP implements 'grep' functionality [as embodied in the current section] in the 'array_filter'
// function

function predicate($element)
{
  if (criterion) return TRUE;
  return FALSE;
}

$matching = array_filter($list, 'predicate');

// ------------

$bigs = array_filter($nums, create_function('$n', 'return $n > 1000000;'));

// ------------

function is_pig($user)
{
  $user_details = preg_split('/(\s)+/', $user);
  // Assuming field 5 is the resource being compared
  return $user_details[5] > 1e7;  
}

$pigs = array_filter(array_slice(preg_split('/\n/', `who -u`), 0, -1), 'is_pig');

// ------------

$matching = array_filter(array_slice(preg_split('/\n/', `who`), 0, -1),
                         create_function('$user', 'return preg_match(\'/^gnat /\', $user);'));

// ------------

class Employee
{
  public $name, $age, $ssn, $salary;

  public function __construct($name, $age, $ssn, $salary, $category)
  {
    $this->name = $name;
    $this->age = $age;
    $this->ssn = $ssn;
    $this->salary = $salary;
    $this->category = $category;
  }
}

// ------------

$employees = array(
  new Employee('sdf', 27, 12345, 47000, 'Engineer'),
  new Employee('ajb', 32, 12376, 51000, 'Programmer'),
  new Employee('dgh', 31, 12355, 45000, 'Engineer'));

// ------------

$engineers = array_filter($employees,
                          create_function('$employee', 'return $employee->category == "Engineer";'));

// @@PLEAC@@_4.14
// PHP offers a rich set of sorting functions. Key features:
// * Inplace sorts; the original array, not a a copy, is sorted
// * Separate functions exist for sorting [both ascending and descending order]:
//   - By value, assign new keys / indices [sort, rsort]
//   - By key   [ksort, krsort] (for non-numerically indexed arrays)
//   - By value [asort, arsort]
//   - As above, but using a user-defined comparator [i.e. callback function]
//     [usort, uasort, uksort]
//   - Natural order sort [natsort]
// * Significantly, if sorting digit-only elements, whether strings or numbers,
//   'natural order' [i.e. 1 before 10 before 100 (ascending)] is retained. If
//   the elements are alphanumeric e.g. 'z1', 'z10' then 'natsort' should be
//   used [note: beware of 'natsort' with negative numbers; prefer 'sort' or 'asort']

$unsorted = array(7, 12, -13, 2, 100, 5, 1, -2, 23, 3, 6, 4);

sort($unsorted);                 // -13, -2, 1, 2, 3, 4, 5, 6, 7, 12, 23, 100
rsort($unsorted);                // 100, 23, 12, 7, 6, 5, 4, 3, 2, 1, -2, -13

asort($unsorted);                // -13, -2, 1, 2, 3, 4, 5, 6, 7, 12, 23, 100
arsort($unsorted);               // 100, 23, 12, 7, 6, 5, 4, 3, 2, 1, -2, -13

natsort($unsorted);              // -2, -13, 1, 2, 3, 4, 5, 6, 7, 12, 23, 100

// ------------

function ascend($left, $right) { return $left > $right; }
function descend($left, $right) { return $left < $right; }

// ------------

usort($unsorted, 'ascend');      // -13, -2, 1, 2, 3, 4, 5, 6, 7, 12, 23, 100
usort($unsorted, 'descend');     // 100, 23, 12, 7, 6, 5, 4, 3, 2, 1, -2, -13

uasort($unsorted, 'ascend');     // -13, -2, 1, 2, 3, 4, 5, 6, 7, 12, 23, 100
uasort($unsorted, 'descend');    // 100, 23, 12, 7, 6, 5, 4, 3, 2, 1, -2, -13

// ----------------------------

function kill_process($pid)
{
  // Is 'killable' ?
  if (!posix_kill($pid, 0)) return;

  // Ok, so kill in two stages
  posix_kill($pid, 15); // SIGTERM
  sleep(1);
  posix_kill($pid, 9);  // SIGKILL
}

function pid($pentry)
{
  $p = preg_split('/\s/', trim($pentry));
  return $p[0];
}

$processes = array_map('pid', array_slice(preg_split('/\n/', `ps ax`), 1, -1));
sort($processes);

echo join(' ,', $processes) . "\n";

echo 'Enter a pid to kill: ';
if (($pid = trim(fgets(STDIN))))
  kill_process($pid);

// @@PLEAC@@_4.15
// Tasks in this section would typically use the PHP 'usort' family of functions
// which are used with a comparator function so as to perform custom comparisions.
// A significant difference from the Perl examples is that these functions are
// inplace sorters, so it is the original array that is modified. Where this must
// be prevented a copy of the array can be made and sorted

function comparator($left, $right)
{
  ; // Compare '$left' with '$right' returning result
}

// ------------

$ordered = array_slice($unordered);
usort($ordered, 'comparator');

// ----------------------------

// The Perl example looks like it is creating a hash using computed values as the key,
// array values as the value, sorting on the computed key, then extracting the sorted
// values and placing them back into an array

function compute($value)
{
  ; // Return computed value utilising '$value'
}

// ------------

// Original numerically-indexed array [sample data used]
$unordered = array(5, 3, 7, 1, 4, 2, 6);

// Create hash using 'compute' function to generate the keys. This example assumes that
// each value in the '$unordered' array is used in generating the corresponding '$key'
foreach($unordered as $value)
{
  $precomputed[compute($value)] = $value;
}

// Copy the hash, and sort it by key
$ordered_precomputed = array_slice($precomputed, 0); ksort($ordered_precomputed);

// Extract the values of the hash in current order placing them in a new numerically-indexed
// array
$ordered = array_values($ordered_precomputed);

// ----------------------------

// As above, except uses 'array_update' and 'accum' to help create hash

function array_update($arr, $lambda, $updarr)
{
  foreach($arr as $key) $lambda($updarr, $key);
  return $updarr;
}

function accum(&$arr, $value)
{
  $arr[compute($value)] = $value;
}

// ------------

function compute($value)
{
  ; // Return computed value utilising '$value'
}

// ------------

// Original numerically-indexed array [sample data used]
$unordered = array(5, 3, 7, 1, 4, 2, 6);

// Create hash
$precomputed = array_update($unordered, 'accum', array());

// Copy the hash, and sort it by key
$ordered_precomputed = array_slice($precomputed, 0); ksort($ordered_precomputed);

// Extract the values of the hash in current order placing them in a new numerically-indexed
// array
$ordered = array_values($ordered_precomputed);

// ----------------------------

class Employee
{
  public $name, $age, $ssn, $salary;

  public function __construct($name, $age, $ssn, $salary)
  {
    $this->name = $name;
    $this->age = $age;
    $this->ssn = $ssn;
    $this->salary = $salary;
  }
}

// ------------

$employees = array(
  new Employee('sdf', 27, 12345, 47000),
  new Employee('ajb', 32, 12376, 51000),
  new Employee('dgh', 31, 12355, 45000));

// ------------

$ordered = array_slice($employees, 0);
usort($ordered, create_function('$left, $right', 'return $left->name > $right->name;'));

// ------------

$sorted_employees = array_slice($employees, 0);
usort($sorted_employees, create_function('$left, $right', 'return $left->name > $right->name;'));

$bonus = array(12376 => 5000, 12345 => 6000, 12355 => 0);

foreach($sorted_employees as $employee)
{
  echo "{$employee->name} earns \${$employee->salary}\n";
}

foreach($sorted_employees as $employee)
{
  if (($amount = $bonus[$employee->ssn]))
    echo "{$employee->name} got a bonus of: \${$amount}\n";
}

// ------------

$sorted = array_slice($employees, 0);
usort($sorted, create_function('$left, $right', 'return $left->name > $right->name || $left->age != $right->age;'));

// ----------------------------

// PHP offers a swag of POSIX functions for obtaining user information [i.e. they all read
// the '/etc/passwd' file for the relevant infroamtion], and it is these that should rightly
// be used for this purpose. However, since the intent of this section is to illustrate array
// manipulation, these functions won't be used. Instead a custom function mimicing Perl's
// 'getpwent' function will be implemented so the code presented here can more faithfully match
// the Perl code

function get_pw_entries()
{
  function normal_users_only($e)
  {
    $entry = split(':', $e); return $entry[2] > 100 && $entry[2] < 32768;
  }

  foreach(array_filter(file('/etc/passwd'), 'normal_users_only') as $entry)
    $users[] = split(':', trim($entry));

  return $users;
}

// ------------

$users = get_pw_entries();

usort($users, create_function('$left, $right', 'return $left[0] > $right[0];'));
foreach($users as $user) echo "{$user[0]}\n";

// ----------------------------

$names = array('sdf', 'ajb', 'dgh');

$sorted = array_slice($names, 0);
usort($sorted, create_function('$left, $right', 'return substr($left, 1, 1) > substr($right, 1, 1);'));

// ------------

$strings = array('bbb', 'aa', 'c');

$sorted = array_slice($strings, 0);
usort($sorted, create_function('$left, $right', 'return strlen($left) > strlen($right);'));

// ----------------------------

function array_update($arr, $lambda, $updarr)
{
  foreach($arr as $key) $lambda($updarr, $key);
  return $updarr;
}

function accum(&$arr, $value)
{
  $arr[strlen($value)] = $value;
}

// ----

$strings = array('bbb', 'aa', 'c');

$temp = array_update($strings, 'accum', array());
ksort($temp);
$sorted = array_values($temp);

// ----------------------------

function array_update($arr, $lambda, $updarr)
{
  foreach($arr as $key) $lambda($updarr, $key);
  return $updarr;
}

function accum(&$arr, $value)
{
  if (preg_match('/(\d+)/', $value, $matches))
    $arr[$matches[1]] = $value;
}

// ----

$fields = array('b1b2b', 'a4a', 'c9', 'ddd', 'a');

$temp = array_update($fields, 'accum', array());
ksort($temp);
$sorted_fields = array_values($temp);

// @@PLEAC@@_4.16
array_unshift($a1, array_pop($a1));  // last -> first
array_push($a1, array_shift($a1));   // first -> last

// ----------------------------

function grab_and_rotate(&$arr)
{
  $item = $arr[0];
  array_push($arr, array_shift($arr));
  return $item;
}

// ------------

$processes = array(1, 2, 3, 4, 5);

while (TRUE)
{
  $process = grab_and_rotate($processes);
  echo "Handling process {$process}\n";
  sleep(1);
}

// @@PLEAC@@_4.17
// PHP offers the 'shuffle' function to perform this task

$arr = array(1, 2, 3, 4, 5, 6, 7, 8, 9);

shuffle($arr);

echo join(' ', $arr) . "\n";

// ----------------------------

// Perl example equivalents
function fisher_yates_shuffle(&$a)
{
  $size = count($a) - 1;

  for($i = $size; $i >= 0; $i--)
  {
    if (($j = rand(0, $i)) != $i)
      list($a[$i], $a[$j]) = array($a[$j], $a[$i]);
  }
}

function naive_shuffle(&$a)
{
  $size = count($a);

  for($i = 0; $i < $size; $i++)
  {
    $j = rand(0, $size - 1);
    list($a[$i], $a[$j]) = array($a[$j], $a[$i]);
  }
}

// ------------

$arr = array(1, 2, 3, 4, 5, 6, 7, 8, 9);

fisher_yates_shuffle($arr);
echo join(' ', $arr) . "\n";

naive_shuffle($arr);
echo join(' ', $arr) . "\n";

// @@PLEAC@@_4.18
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_4.19
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_5.0
// PHP uses the term 'array' to refer to associative arrays - referred to in Perl
// as 'hashes' - and for the sake of avoiding confusion, the Perl terminology will
// be used. As a matter of interest, PHP does not sport a vector, matrix, or list
// type: the 'array' [Perl 'hash'] serves all these roles

$age = array('Nat' => 24, 'Jules' => 25, 'Josh' => 17);

$age['Nat'] = 24;
$age['Jules'] = 25;
$age['Josh'] = 17;

$age = array_combine(array('Nat', 'Jules', 'Josh'), array(24, 25, 17));

// ------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

$food_colour['Apple'] = 'red'; $food_colour['Banana'] = 'yellow';
$food_colour['Lemon'] = 'yellow'; $food_colour['Carrot'] = 'orange';

$food_colour = array_combine(array('Apple', 'Banana', 'Lemon', 'Carrot'),
                             array('red', 'yellow', 'yellow', 'orange'));

// @@PLEAC@@_5.1
$hash[$key] = $value;

// ------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

$food_colour['Raspberry'] = 'pink';

echo "Known foods:\n";
foreach($food_colour as $food => $colour) echo "{$food}\n";

// @@PLEAC@@_5.2
// Returns TRUE on all existing entries with non-NULL values
if (isset($hash[$key]))
  ; // entry exists  
else
  ; // no such entry 

// ------------

// Returns TRUE on all existing entries regardless of attached value
if (array_key_exists($key, $hash))
  ; // entry exists  
else
  ; // no such entry 

// ----------------------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

foreach(array('Banana', 'Martini') as $name)
{
  if (isset($food_colour[$name]))
    echo "{$name} is a food.\n";
  else
    echo "{$name} is a drink.\n";
}

// ----------------------------

$age = array('Toddler' => 3, 'Unborn' => 0, 'Phantasm' => NULL);

foreach(array('Toddler', 'Unborn', 'Phantasm', 'Relic') as $thing)
{
  echo "{$thing}:";
  if (array_key_exists($thing, $age)) echo ' exists';
  if (isset($age[$thing])) echo ' non-NULL';
  if ($age[$thing]) echo ' TRUE';
  echo "\n";
}

// @@PLEAC@@_5.3
// Remove one, or more, hash entries
unset($hash[$key]);

unset($hash[$key1], $hash[$key2], $hash[$key3]);

// Remove entire hash
unset($hash);

// ----------------------------

function print_foods()
{
  // Perl example uses a global variable
  global $food_colour;

  $foods = array_keys($food_colour);

  echo 'Foods:';
  foreach($foods as $food) echo " {$food}";

  echo "\nValues:\n";
  foreach($foods as $food)
  {
    $colour = $food_colour[$food];

    if (isset($colour))
      echo "  {$colour}\n";
    else
      echo "  nullified or removed\n";
  }
}

// ------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

echo "Initially:\n"; print_foods();

// Nullify an entry
$food_colour['Banana'] = NULL;
echo "\nWith 'Banana' nullified\n";
print_foods();

// Remove an entry
unset($food_colour['Banana']);
echo "\nWith 'Banana' removed\n";
print_foods();

// Destroy the hash
unset($food_colour);

// @@PLEAC@@_5.4
// Access keys and values
foreach($hash as $key => $value)
{
  ; // ...
}

// Access keys only
foreach(array_keys($hash) as $key)
{
  ; // ...
}

// Access values only
foreach($hash as $value)
{
  ; // ...
}

// ----------------------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

foreach($food_colour as $food => $colour)
{
  echo "{$food} is {$colour}\n";
}

foreach(array_keys($food_colour) as $food)
{
  echo "{$food} is {$food_colour[$food]}\n";
}

// ----------------------------

// 'countfrom' - count number of messages from each sender

$line = fgets(STDIN);

while (!feof(STDIN))
{
  if (preg_match('/^From: (.*)/', $line, $matches))
  {
    if (isset($from[$matches[1]]))
      $from[$matches[1]] += 1;
    else
      $from[$matches[1]] = 1;
  }

  $line = fgets(STDIN);
}

if (isset($from))
{
  echo "Senders:\n";  
  foreach($from as $sender => $count) echo "{$sender} : {$count}\n";
}
else
{
  echo "No valid data entered\n";
}

// @@PLEAC@@_5.5
// PHP offers, 'print_r', which prints hash contents in 'debug' form; it also
// works recursively, printing any contained arrays in similar form
//     Array
//     (
//         [key1] => value1 
//         [key2] => value2
//         ...
//     )

print_r($hash);

// ------------

// Based on Perl example; non-recursive, so contained arrays not printed correctly
foreach($hash as $key => $value)
{
  echo "{$key} => $value\n";
}

// ----------------------------

// Sorted by keys

// 1. Sort the original hash
ksort($hash);

// 2. Extract keys, sort, traverse original in key order
$keys = array_keys($hash); sort($keys);

foreach($keys as $key)
{
  echo "{$key} => {$hash[$key]}\n";
}

// Sorted by values

// 1. Sort the original hash
asort($hash);

// 2. Extract values, sort, traverse original in value order [warning: finds 
//    only first matching key in the case where duplicate values exist]
$values = array_values($hash); sort($values);

foreach($values as $value)
{
  echo $value . ' <= ' . array_search($value, $hash) . "\n";
}

// @@PLEAC@@_5.6
// Unless sorted, hash elements remain in the order of insertion. If care is taken to
// always add a new element to the end of the hash, then element order is the order
// of insertion. The following function, 'array_push_associative' [modified from original
// found at 'array_push' section of PHP documentation], does just that
function array_push_associative(&$arr)
{
  foreach (func_get_args() as $arg)
  {
    if (is_array($arg))
      foreach ($arg as $key => $value) { $arr[$key] = $value; $ret++; }
    else
      $arr[$arg] = '';
  }

  return $ret;
}

// ------------

$food_colour = array();

// Individual calls, or ...
array_push_associative($food_colour, array('Banana' => 'Yellow'));
array_push_associative($food_colour, array('Apple' => 'Green'));
array_push_associative($food_colour, array('Lemon' => 'Yellow'));

// ... one call, one array; physical order retained
// array_push_associative($food_colour, array('Banana' => 'Yellow', 'Apple' => 'Green', 'Lemon' => 'Yellow'));

print_r($food_colour);

echo "\nIn insertion order:\n";
foreach($food_colour as $food => $colour) echo "  {$food} => {$colour}\n";

$foods = array_keys($food_colour);

echo "\nStill in insertion order:\n";
foreach($foods as $food) echo "  {$food} => {$food_colour[$food]}\n";

// @@PLEAC@@_5.7
foreach(array_slice(preg_split('/\n/', `who`), 0, -1) as $entry)
{
  list($user, $tty) = preg_split('/\s/', $entry);
  $ttys[$user][] = $tty;

  // Could instead do this:
  // $user = array_slice(preg_split('/\s/', $entry), 0, 2);
  // $ttys[$user[0]][] = $user[1];
}

ksort($ttys);

// ------------

foreach($ttys as $user => $all_ttys)
{
  echo "{$user}: " . join(' ', $all_ttys) . "\n";
}

// ------------

foreach($ttys as $user => $all_ttys)
{
  echo "{$user}: " . join(' ', $all_ttys) . "\n";

  foreach($all_ttys as $tty)
  {
    $stat = stat('/dev/$tty');
    $pwent = posix_getpwuid($stat['uid']);
    $user = isset($pwent['name']) ? $pwent['name'] : 'Not available';
    echo "{$tty} owned by: {$user}\n";
  }
}

// @@PLEAC@@_5.8
// PHP offers the 'array_flip' function to perform the task of exchanging the keys / values
// of a hash i.e. invert or 'flip' a hash

$reverse = array_flip($hash);

// ----------------------------

$surname = array('Babe' => 'Ruth', 'Mickey' => 'Mantle'); 
$first_name = array_flip($surname);

echo "{$first_name['Mantle']}\n";

// ----------------------------

$argc == 2 || die("usage: {$argv[0]} food|colour\n");

$given = $argv[1];

$colour = array('Apple' => 'red', 'Banana' => 'yellow',
                'Lemon' => 'yellow', 'Carrot' => 'orange');

$food = array_flip($colour);

if (isset($colour[$given]))
  echo "{$given} is a food with colour: {$colour[$given]}\n";

if (isset($food[$given]))
  echo "{$food[$given]} is a food with colour: {$given}\n";

// ----------------------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

foreach($food_colour as $food => $colour)
{
  $foods_with_colour[$colour][] = $food;
}

$colour = 'yellow';
echo "foods with colour {$colour} were: " . join(' ', $foods_with_colour[$colour]) . "\n";

// @@PLEAC@@_5.9
// PHP implements a swag of sorting functions, most designed to work with numerically-indexed
// arrays. For sorting hashes, the 'key' sorting functions are required:
// * 'ksort', 'krsort', 'uksort'

// Ascending order
ksort($hash);

// Descending order [i.e. reverse sort]
krsort($hash);

// Comparator-based sort

function comparator($left, $right)
{
  // Compare left key with right key
  return $left > $right;
}

uksort($hash, 'comparator');

// ----------------------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

// ------------

ksort($food_colour);

foreach($food_colour as $food => $colour)
{
  echo "{$food} is {$colour}\n";
}

// ------------

uksort($food_colour, create_function('$left, $right', 'return $left > $right;'));

foreach($food_colour as $food => $colour)
{
  echo "{$food} is {$colour}\n";
}

// @@PLEAC@@_5.10
// PHP offers the 'array_merge' function for this task [a related function, 'array_combine',
// may be used to create a hash from an array of keys, and one of values, respectively]

// Merge two, or more, arrays
$merged = array_merge($a, $b, $c);

// Create a hash from array of keys, and of values, respectively
$hash = array_combine($keys, $values);

// ------------

// Can always merge arrays manually 
foreach(array($h1, $h2, $h3) as $hash)
{
  foreach($hash as $key => $value)
  {
    // If same-key values differ, only latest retained
    $merged[$key] = $value;

    // Do this to append values for that key
    // $merged[$key][] = $value;
  }
}

// ----------------------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

$drink_colour = array('Galliano' => 'yellow', 'Mai Tai' => 'blue');

// ------------

$ingested_colour = array_merge($food_colour, $drink_colour);

// ------------

$substance_colour = array();

foreach(array($food_colour, $drink_colour) as $hash)
{
  foreach($hash as $substance => $colour)
  {
    if (array_key_exists($substance, $substance_colour))
    {
      echo "Warning {$substance_colour[$substance]} seen twice. Using first definition.\n";
      continue;
    }
    $substance_colour[$substance] = $colour;
  }
}

// @@PLEAC@@_5.11
// PHP offers a number of array-based 'set operation' functions:
// * union:        array_merge
// * intersection: array_intersect and family
// * difference:   array_diff and family
// which may be used for this type of task

// Keys occurring in both hashes
$common = array_intersect_key($h1, $h2);

// Keys occurring in the first hash [left side], but not in the second hash
$this_not_that = array_diff_key($h1, $h2);

// ----------------------------

$food_colour = array('Apple' => 'red', 'Banana' => 'yellow',
                     'Lemon' => 'yellow', 'Carrot' => 'orange');

$citrus_colour = array('Lemon' => 'yellow', 'Orange' => 'orange', 'Lime' => 'green');

$non_citrus = array_diff_key($food_colour, $citrus_colour);

// @@PLEAC@@_5.12
// PHP implements a special type known as a 'resource' that encompasses things like file handles,
// sockets, database connections, and many others. The 'resource' type is, essentially, a
// reference variable that is not readily serialisable. That is to say:
// * A 'resource' may be converted to a string representation via the 'var_export' function
// * That same string cannot be converted back into a 'resource'
// So, in terms of array handling, 'resource' types may be stored as array reference values,
// but cannot be used as keys. 
//
// I suspect it is this type of problem that the Perl::Tie package helps resolve. However, since
// PHP doesn't, AFAIK, sport a similar facility, the examples in this section cannot be
// implemented using file handles as keys

$filenames = array('/etc/termcap', '/vmlinux', '/bin/cat');

foreach($filenames as $filename)
{
  if (!($fh = fopen($filename, 'r'))) continue;

  // Cannot do this as required by the Perl code:
  // $name[$fh] = $filename;

  // Ok
  $name[$filename] = $fh;
}

// Would traverse array via:
//
// foreach(array_keys($name) as $fh)
// ...
// or
//
// foreach($name as $fh => $filename)
// ...
// but since '$fh' cannot be a key, either of these will work:
//
// foreach($name as $filename => $fh)
// or
foreach(array_values($name) as $fh)
{
  fclose($fh);
}

// @@PLEAC@@_5.13
// PHP hashes are dynamic expanding and contracting as entries are added, and removed,
// respectively. Thus, there is no need to presize a hash, nor is there, AFAIK, any
// means of doing so except by the number of datums used when defining the hash

// zero elements
$hash = array();            

// ------------

// three elements
$hash = array('Apple' => 'red', 'Lemon' => 'yellow', 'Carrot' => 'orange');

// @@PLEAC@@_5.14
foreach($array as $element) $count[$element] += 1;

// @@PLEAC@@_5.15
$father = array('Cain' => 'Adam', 'Abel' => 'Adam', 'Seth' => 'Adam', 'Enoch' => 'Cain',
                'Irad' => 'Enoch', 'Mehujael' => 'Irad', 'Methusael'=> 'Mehujael',
                'Lamech' => 'Methusael', 'Jabal' => 'Lamech', 'Jubal' => 'Lamech',
                'Tubalcain' => 'Lamech', 'Enos' => 'Seth');

// ------------

$name = trim(fgets(STDIN));

while (!feof(STDIN))
{
  while (TRUE)
  {
    echo "$name\n";

    // Can use either:
    if (!isset($father[$name])) break;
    $name = $father[$name];

    // or:
    // if (!key_exists($name, $father)) break;
    // $name = $father[$name];

    // or combine the two lines:
    // if (!($name = $father[$name])) break;
  }

  echo "\n";
  $name = trim(fgets(STDIN));
}

// ----------------------------

define(SEP, ' ');

foreach($father as $child => $parent)
{
  if (!$children[$parent])
    $children[$parent] = $child;
  else
    $children[$parent] .= SEP . $child;
}

$name = trim(fgets(STDIN));

while (!feof(STDIN))
{
  echo $name . ' begat ';

  if (!$children[$name])
    echo "Nothing\n"
  else
    echo str_replace(SEP, ', ', $children[$name]) . "\n";

  $name = trim(fgets(STDIN));
}

// ----------------------------

define(SEP, ' ');

$files = array('/tmp/a', '/tmp/b', '/tmp/c');

foreach($files as $file)
{
  if (!is_file($file)) { echo "Skipping {$file}\n"; continue; }
  if (!($fh = fopen($file, 'r'))) { echo "Skipping {$file}\n"; continue; }

  $line = fgets($fh);

  while (!feof($fh))
  {
    if (preg_match('/^\s*#\s*include\s*<([^>]+)>/', $line, $matches))
    {
      if (isset($includes[$matches[1]]))
        $includes[$matches[1]] .= SEP . $file;
      else
        $includes[$matches[1]] = $file;
    }

    $line = fgets($fh);
  }

  fclose($fh);
}

print_r($includes);

// @@PLEAC@@_5.16
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_9.0
$entry = stat('/bin/vi');
$entry = stat('/usr/bin');
$entry = stat($argv[1]);

// ------------

$entry = stat('/bin/vi');

$ctime = $entry['ctime'];
$size = $entry['size'];

// ----------------------------

// For the simple task of determining whether a file contains, text', a simple
// function that searches for a newline could be implemented. Not exactly
// foolproof, but very simple, low overhead, no installation headaches ...
function containsText($file)
{
  $status = FALSE;

  if (($fp = fopen($file, 'r')))
  {
    while (FALSE !== ($char = fgetc($fp)))
    {
      if ($char == "\n") { $status = TRUE; break; }
    }

    fclose($fp);
  }

  return $status;
}

// PHP offers the [currently experimental] Fileinfo group of functions to
// determine file types based on their contents / 'magic numbers'. This
// is functionality similar to the *NIX, 'file' utility. Note that it must
// first be installed using the PEAR utility [see PHP documentation] 
function isTextFile($file)
{
  // Note: untested code, but I believe this is how it is supposed to work
  $finfo = finfo_open(FILEINFO_NONE);
  $status = (finfo_file($finfo, $file) == 'ASCII text');
  finfo_close($finfo);
  return $status;
}

// Alternatively, use the *NIX utility, 'file', directly
function isTextFile($file)
{
  return exec(trim('file -bN ' . escapeshellarg($file))) == 'ASCII text';
}

// ----

containsText($argv[1]) || die("File {$argv[1]} doesn't have any text in it\n");

isTextFile($argv[1]) || die("File {$argv[1]} doesn't have any text in it\n");

// ----------------------------

$dirname = '/usr/bin/';

($dirhdl = opendir($dirname)) || die("Couldn't open {$dirname}\n");

while (($file = readdir($dirhdl)) !== FALSE)
{
  printf("Inside %s is something called: %s\n", $dirname, $file);
}

closedir($dirhdl);

// @@PLEAC@@_9.1
$filename = 'example.txt';

// Get the file's current access and modification time, respectively
$fs = stat($filename);

$readtime = $fs['atime'];
$writetime = $fs['mtime'];

// Alter $writetime, and $readtime ...

// Update file timestamp
touch($filename, $writetime, $readtime);

// ----------------------------

$filename = 'example.txt';

// Get the file's current access and modification time, respectively
$fs = stat($filename);

$atime = $fs['atime'];
$mtime = $fs['mtime'];

// Dedicated functions also exist to retrieve this information:
//
// $atime = $fileatime($filename);
// $mtime = $filemtime($filename);
//

// Perform date arithmetic. Traditional approach where arithmetic is performed
// directly with Epoch Seconds [i.e. the *NIX time stamp value] will work ...

define('SECONDS_PER_DAY', 60 * 60 * 24);

// Set file's access and modification times to 1 week ago
$atime -= 7 * SECONDS_PER_DAY;
$mtime -= 7 * SECONDS_PER_DAY;

// ... but care must be taken to account for daylight saving. Therefore, the
// recommended approach is to use library functions to perform such tasks:

$atime = strtotime('-7 days', $atime);
$mtime = strtotime('-7 days', $mtime);

// Update file timestamp
touch($filename, $mtime, $atime);

// Good idea to clear the cache after such updates have occurred so fresh
// values will be retrieved on next access
clearstatcache();

// ----------------------------

$argc == 2 || die("usage: {$argv[0]} filename\n");

$filename = $argv[1];
$fs = stat($filename);

$atime = $fs['atime'];
$mtime = $fs['mtime'];

// Careful here: since interactive, use, 'system', not 'exec', to launch [latter
// does not work under *NIX - at least, not for me :)]
system(trim(getenv('EDITOR') . ' vi ' . escapeshellarg($filename)), $retcode);

touch($filename, $mtime, $atime) || die("Error updating timestamp on file, {$filename}!\n");

// @@PLEAC@@_9.2
// The 'unlink' function is used to delete regular files, whilst the 'rmdir' function
// does the same on non-empty directories. AFAIK, no recursive-deletion facility
// exists, and must be manually programmed

$filename = '...';

@unlink($filename) || die("Can't delete, {$filename}!\n");

// ------------

$files = glob('...');
$problem = FALSE;

// Could simply use a foreach loop
foreach($files as $filename) { @unlink($filename) || $problem = TRUE; }

//
// Alternatively, an applicative approach could be used, one closer in spirit to
// largely-functional languages like Scheme
//
// function is_all_deleted($deleted, $filename) { return @unlink($filename) && $deleted; }
// $problem = !array_reduce($files, 'is_all_deleted', TRUE);
//

if ($problem)
{
  fwrite(STDERR, 'Could not delete all of:');
  foreach($files as $filename) { fwrite(STDERR, ' ' . $filename); }
  fwrite(STDERR, "\n"); exit(1);
} 

// ------------

function rmAll($files)
{
  $count = 0;

  foreach($files as $filename) { @unlink($filename) && $count++; };

  return $count;

// An applicative alternative using 'create_function', PHP's rough equivalent of 'lambda' ...
//
//  return array_reduce($files,
//    create_function('$count, $filename', 'return @unlink($filename) && $count++;'), 0);
}

// ----

$files = glob('...');
$toBeDeleted = sizeof($files);
$count = rmAll($files);

($count == $toBeDeleted) || die("Could only delete {$count} of {$toBeDeleted} files\n");

// @@PLEAC@@_9.3
$oldfile = '/tmp/old'; $newfile = '/tmp/new';

copy($oldfile, $newfile) || die("Error copying file\n");

// ----------------------------

// All the following copy a file by copying its contents. Examples do so in a single
// operation, but it is also possible to copy arbitrary blocks, or, line-by-line in 
// the case of 'text' files
$oldfile = '/tmp/old'; $newfile = '/tmp/new';

if (is_file($oldfile))
  file_put_contents($newfile, file_get_contents($oldfile));
else
  die("Problem copying file {$oldfile} to file {$newfile}\n");

// ------------

$oldfile = '/tmp/old'; $newfile = '/tmp/new';

fwrite(($nh = fopen($newfile, 'wb')), fread(($oh = fopen($oldfile, 'rb')), filesize($oldfile)));
fclose($oh);
fclose($nh);

// ------------

// As above, but with some error checking / handling
$oldfile = '/tmp/old'; $newfile = '/tmp/new';

($oh = fopen($oldfile, 'rb')) || die("Problem opening input file {$oldfile}\n");
($nh = fopen($newfile, 'wb')) || die("Problem opening output file {$newfile}\n");

if (($filesize = filesize($oldfile)) > 0)
{
  fwrite($nh, fread($oh, $filesize)) || die("Problem reading / writing file data\n");
}

fclose($oh);
fclose($nh);

// ----------------------------

// Should there be platform-specfic problems copying 'very large' files, it is
// a simple matter to call a system command utility via, 'exec'

// *NIX-specific example. Could check whether, 'exec', succeeded, but checking whether
// a file exists after the operation might be a better approach
$oldfile = '/tmp/old'; $newfile = '/tmp/new';

is_file($newfile) && unlink($newfile);

exec(trim('cp --force ' . escapeshellarg($oldfile) . ' ' . escapeshellarg($newfile)));

is_file($newfile) || die("Problem copying file {$oldfile} to file {$newfile}\n");

// For other operating systems just change:
// * filenames
// * command being 'exec'ed
// as the rest of the code is platform independant

// @@PLEAC@@_9.4
function makeDevInodePair($filename)
{
  if (!($fs = @stat($filename))) return FALSE;
  return strval($fs['dev'] . $fs['ino']);
}

// ------------

function do_my_thing($filename)
{
  // Using a global variable to mimic Perl example, but could easily have passed
  // '$seen' as an argument
  global $seen;

  $devino = makeDevInodePair($filename);

  // Process $filename if it has not previously been seen, else just increment
  if (!isset($seen[$devino]))
  {
    // ... process $filename ...

    // Set initial count
    $seen[$devino] = 1;
  }
  else
  {
    // Otherwise, just increment the count
    $seen[$devino] += 1;
  }
}

// ----

// Simple example
$seen = array();

do_my_thing('/tmp/old');
do_my_thing('/tmp/old');
do_my_thing('/tmp/old');
do_my_thing('/tmp/new');

foreach($seen as $devino => $count)
{
  echo "{$devino} -> {$count}\n";
}

// ------------

// A variation on the above avoiding use of global variables, and illustrating use of
// easily-implemented 'higher order' techniques

// Helper function loosely modelled on, 'array_reduce', but using an array as
// 'accumulator', which is returned on completion
function array_update($arr, $lambda, $updarr)
{
  foreach($arr as $key) $lambda($updarr, $key);
  return $updarr;
}

function do_my_thing(&$seen, $filename)
{
  if (!array_key_exists(($devino = makeDevInodePair($filename)), $seen))
  {
    // ... processing $filename ...

    // Update $seen
    $seen[$devino] = 1;
  }
  else
  {
    // Update $seen
    $seen[$devino] += 1;
  }
}

// ----

// Simple example
$files = array('/tmp/old', '/tmp/old', '/tmp/old', '/tmp/new');

// Could do this ...
$seen = array();
array_update($files, 'do_my_thing', &$seen);

// or this:
$seen = array_update($files, 'do_my_thing', array());

// or a 'lambda' could be used:
array_update($files,
             create_function('$seen, $filename', '... code not shown ...'),
             &$seen);

foreach($seen as $devino => $count)
{
  echo "{$devino} -> {$count}\n";
}

// ----------------------------

$files = glob('/tmp/*');

define(SEP, ';');
$seen = array();

foreach($files as $filename)
{
  if (!array_key_exists(($devino = makeDevInodePair($filename)), $seen))
    $seen[$devino] = $filename;
  else
    $seen[$devino] = $seen[$devino] . SEP . $filename;
}

$devino = array_keys($seen);
sort($devino);

foreach($devino as $key)
{
  echo $key . ':';
  foreach(split(SEP, $seen[$key]) as $filename) echo ' ' . $filename;
  echo "\n";
}

// @@PLEAC@@_9.5
// Conventional POSIX-like approach to directory traversal
$dirname = '/usr/bin/';

($dirhdl = opendir($dirname)) || die("Couldn't open {$dirname}\n");

while (($file = readdir($dirhdl)) !== FALSE)
{
  ; // ... do something with $dirname/$file
    // ...
}

closedir($dirhdl);

// ------------

// Newer [post PHP 4], 'applicative' approach - an array of filenames is
// generated that may be processed via external loop ...

$dirname = '/usr/bin/';

foreach(scandir($dirname) as $file)
{
  ; // ... do something with $dirname/$file
    // ...
}

// .. or, via callback application, perhaps after massaging by one of the
// 'array' family of functions [also uses, 'array_update', from earlier section]

$newlist = array_update(array_reverse(scandir($dirname)),
                        create_function('$filelist, $file',  ' ; '),
                        array());

// And don't forget that the old standby, 'glob', that returns an array of
// paths filtered using the Bourne Shell-based wildcards, '?' and '*', is
// also available

foreach(glob($dirname . '*') as $path)
{
  ; // ... do something with $path
    // ...
}

// ----------------------------

// Uses, 'isTextFile', from an earlier section
$dirname = '/usr/bin/';

echo "Text files in {$dirname}:\n";

foreach(scandir($dirname) as $file)
{
  // Take care when constructing paths to ensure cross-platform operability 
  $path = $dirname . $file;

  if (is_file($path) && isTextFile($path)) echo $path . "\n";
}

// ----------------------------

function plain_files($dirname)
{
  ($dirlist = glob($dirname . '*')) || die("Couldn't glob {$dirname}\n");

  // Pass function name directly if only a single function performs filter test
  return array_filter($dirlist, 'is_file');

  // Use, 'create_function', if a multi-function test is needed
  //
  // return array_filter($dirlist, create_function('$path', 'return is_file($path);'));
  //
}

// ------------

foreach(plain_files('/tmp/') as $path)
{
  echo $path . "\n";
}

// @@PLEAC@@_9.6
$dirname = '/tmp/';

// Full paths
$pathlist = glob($dirname . '*.c');

// File names only - glob-based matching
$filelist = array_filter(scandir($dirname),
                         create_function('$file', 'return fnmatch("*.c", $file);'));

// ----------------------------

$dirname = '/tmp/';

// File names only - regex-based matching [case-insensitive]
$filelist = array_filter(scandir($dirname),
                         create_function('$file', 'return eregi("\.[ch]$", $file);'));

// ----------------------------

$dirname = '/tmp/';

// Directory names - all-digit names
$dirs = array_filter(glob($dirname . '*', GLOB_ONLYDIR),
                     create_function('$path', 'return ereg("^[0-9]+$", basename($path));'));

// @@PLEAC@@_9.7
// Recursive directory traversal function and helper: traverses a directory tree
// applying a function [and a variable number of accompanying arguments] to each
// file

class Accumulator
{
  public $value;
  public function __construct($start_value) { $this->value = $start_value; }
}

// ------------

function process_directory_($op, $func_args)
{
  if (is_dir($func_args[0]))
  {
    $current = $func_args[0];
    foreach(scandir($current) as $entry)
    {
      if ($entry == '.' || $entry == '..') continue;
      $func_args[0] = $current . '/' . $entry;
      process_directory_($op, $func_args);
    }
  }
  else
  {
    call_user_func_array($op, $func_args);
  }
}

function process_directory($op, $dir)
{
  if (!is_dir($dir)) return FALSE;
  $func_args = array_slice(func_get_args(), 1);
  process_directory_($op, $func_args);
  return TRUE;
}

// ----------------------------

$dirlist = array('/tmp/d1', '/tmp/d2', '/tmp/d3');

// Do something with each directory in the list
foreach($dirlist as $dir)
{
  ;
  // Delete directory [if empty]     -> rmdir($dir); 
  // Make it the 'current directory' -> chdir($dir);
  // Get list of files it contains   -> $filelist = scandir($dir);
  // Get directory metadata          -> $ds = stat($dir);
}

// ------------

$dirlist = array('/tmp/d1', '/tmp/d2', '/tmp/d3');

function pf($path)
{
  // ... do something to the file or directory ...
  printf("%s\n", $path);
}

// For each directory in the list ...
foreach($dirlist as $dir)
{
  // Is this a valid directory ?
  if (!is_dir($dir)) { printf("%s does not exist\n", $dir); continue; }

  // Ok, so get all the directory's entries
  $filelist = scandir($dir);

  // An 'empty' directory will contain at least two entries: '..' and '.'
  if (count($filelist) == 2) { printf("%s is empty\n", $dir); continue; }

  // For each file / directory in the directory ...
  foreach($filelist as $file)
  {
    // Ignore '..' and '.' entries
    if ($file == '.' || $file == '..') continue;

    // Apply function to process the file / directory
    pf($dir . '/' . $file);
  }
}

// ----------------------------

function accum_filesize($file, $accum)
{
  is_file($file) && ($accum->value += filesize($file));
}

// ------------

// Verify arguments ...
$argc == 2 || die("usage: {$argv[0]} dir\n");
$dir = $argv[1];

is_dir($dir) || die("{$dir} does not exist / not a directory\n");

// Collect data [use an object to accumulate results]
$dirsize = new Accumulator(0);
process_directory('accum_filesize', $dir, $dirsize); 

// Report results
printf("%s contains %d bytes\n", $dir, $dirsize->value);

// ----------------------------

function biggest_file($file, $accum)
{
  if (is_file($file))
  {
    $fs = filesize($file);
    if ($accum->value[1] < $fs) { $accum->value[0] = $file; $accum->value[1] = $fs; }
  }
}

// ------------

// Verify arguments ...
$argc == 2 || die("usage: {$argv[0]} dir\n");
$dir = $argv[1];

is_dir($dir) || die("{$dir} does not exist / not a directory\n");

// Collect data [use an object to accumulate results]
$biggest = new Accumulator(array('', 0));
process_directory('biggest_file', $dir, $biggest); 

// Report results
printf("Biggest file is %s containing %d bytes\n", $biggest->value[0], $biggest->value[1]);

// ----------------------------

function youngest_file($file, $accum)
{
  if (is_file($file))
  {
    $fct = filectime($file);
    if ($accum->value[1] > $fct) { $accum->value[0] = $file; $accum->value[1] = $fct; }
  }
}

// ------------

// Verify arguments ...
$argc == 2 || die("usage: {$argv[0]} dir\n");
$dir = $argv[1];

is_dir($dir) || die("{$dir} does not exist / not a directory\n");

// Collect data [use an object to accumulate results]
$youngest = new Accumulator(array('', 2147483647));
process_directory('youngest_file', $dir, $youngest); 

// Report results
printf("Youngest file is %s dating %s\n", $youngest->value[0], date(DATE_ATOM, $youngest->value[1]));

// @@PLEAC@@_9.8
// AFAICT, there is currently no library function that recursively removes a
// directory tree [i.e. a directory, it's subdirectories, and any other files]
// with a single call. Such a function needs to be custom built. PHP tools
// with which to do this:
// * 'unlink', 'rmdir', 'is_dir', and 'is_file' functions, will all take care
//   of the file testing and deletion
// * Actual directory traversal requires obtaining directory / subdirectory
//   lists, and here there is much choice available, though care must be taken
//   as each has it's own quirks
//   - 'opendir', 'readdir', 'closedir'
//   - 'scandir'
//   - 'glob'
//   - SPL 'directory iterator' classes [newish / experimental - not shown here]
//
// The PHP documentation for 'rmdir' contains several examples, each illustrating
// one of each approach; the example shown here is loosely based on one of these
// examples

// Recursor - recursively traverses directory tree
function rmtree_($dir)
{
  $dir = "$dir";

  if ($dh = opendir($dir))
  {
    while (FALSE !== ($item = readdir($dh)))
    {
      if ($item != '.' && $item != '..')
      {
        $subdir = $dir . '/' . "$item";

        if (is_dir($subdir)) rmtree_($subdir);
        else @unlink($subdir);
      }
    }

    closedir($dh); @rmdir($dir);
  }
}

// Launcher - performs validation then starts recursive routine
function rmtree($dir)
{
  if (is_dir($dir))
  {
    (substr($dir, -1, 1) == '/') && ($dir = substr($dir, 0, -1));
    rmtree_($dir); return !is_dir($dir);
  }

  return FALSE;
}

// ------------

$argc == 2 || die("usage: rmtree dir\n");

rmtree($argv[1]) || die("Could not remove directory {$argv[1]}\n");

// @@PLEAC@@_9.9
$filepairs = array('x.txt' => 'x2.txt', 'y.txt' => 'y.doc', 'zxc.txt' => 'cxz.txt');

foreach($filepairs as $oldfile => $newfile)
{
  @rename($oldfile, $newfile) || fwrite(STDERR, sprintf("Could not rename %s to %s\n", $oldfile, $newfile));
}

// ----------------------------

// Call a system command utility via, 'exec'. *NIX-specific example. Could check whether,
// 'exec', succeeded, but checking whether a renamed file exists after the operation might
// be a better approach

$oldfile = '/tmp/old'; $newfile = '/tmp/new';

is_file($newfile) && unlink($newfile);

exec(trim('mv --force ' . escapeshellarg($oldfile) . ' ' . escapeshellarg($newfile)));

is_file($oldfile) || die("Problem renaming file {$oldfile} to file {$newfile}\n");

// For other operating systems just change:
// * filenames
// * command being 'exec'ed
// as the rest of the code is platform independant

// ----------------------------

// A modified implementation of Larry's Filename Fixer. Rather than passing
// a single expression, a 'from' regexp is passed; each match in the file
// name(s) is changed to the value of 'to'. It otherwise behaves the same
//

$argc > 2 || die("usage: rename from to [file ...]\n");

$from = $argv[1];
$to = $argv[2]; 

if (count(($argv = array_slice($argv, 3))) < 1)
  while (!feof(STDIN)) $argv[] = substr(fgets(STDIN), 0, -1);

foreach($argv as $file)
{
  $was = $file;
  $file = ereg_replace($from, $to, $file);

  if (strcmp($was, $file) != 0)
    @rename($was, $file) || fwrite(STDERR, sprintf("Could not rename %s to %s\n", $was, $file));
}

// @@PLEAC@@_9.10
$base = basename($path);
$dir = dirname($path);

// PHP's equivalent to Perl's 'fileparse'
$pathinfo = pathinfo($path);

$base = $pathinfo['basename'];
$dir = $pathinfo['dirname'];
$ext = $pathinfo['extension'];

// ----------------------------

$path = '/usr/lib/libc.a';

printf("dir is %s, file is %s\n", dirname($path), basename($path));

// ------------

$path = '/usr/lib/libc.a';

$pathinfo = pathinfo($path);

printf("dir is %s, name is %s, extension is %s\n", $pathinfo['dirname'], $pathinfo['basename'], $pathinfo['extension']);

// ----------------------------

// Handle Mac example as a simple parse task. However, AFAIK, 'pathinfo' is cross-platform,
// so should handle file path format differences transparently
$path = 'Hard%20Drive:System%20Folder:README.txt';

$macp = array_combine(array('drive', 'folder', 'filename'), split("\:", str_replace('%20', ' ', $path)));
$macf = array_combine(array('name', 'extension'), split("\.", $macp['filename'])); 

printf("dir is %s, name is %s, extension is %s\n", ($macp['drive'] . ':' . $macp['folder']), $macf['name'], ('.' . $macf['extension']));

// ----------------------------

// Not really necessary since we have, 'pathinfo', but better matches Perl example
function file_extension($filename, $separator = '.')
{
  return end(split(("\\" . $separator), $filename));
}

// ----

echo file_extension('readme.txt') . "\n";

// @@PLEAC@@_9.11
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_9.12
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_10.0
// Since defined at outermost scope, $greeted may be considered a global variable
$greeted = 0;

// ------------

// Must use, 'global', keyword to inform functions that $greeted already exists as
// a global variable. If this is not done, a local variable of that name is implicitly
// defined
function howManyGreetings()
{
  global $greeted;
  return $greeted;
}

function hello()
{
  global $greeted;
  $greeted++;
  echo "high there!, this procedure has been called {$greeted} times\n";
}

// ------------

hello();
$greetings = howManyGreetings();
echo "bye there!, there have been {$greetings} greetings so far\n";

// @@PLEAC@@_10.1
// Conventionally-defined function together with parameter list
function hypotenuse($side1, $side2)
{
  return sqrt(pow($side1, 2) + pow($side2, 2));
}

// ----

// Alternative is to define the function without parameter list, then use
// 'func_get_arg' to extract arguments
function hypotenuse()
{
  // Could check number of arguments passed with: 'func_num_args', which
  // would be the approach used if dealing with variable number of arguments
  $side1 = func_get_arg(0); $side2 = func_get_arg(1);

  return sqrt(pow($side1, 2) + pow($side2, 2));
}

// ------------

// 1. Conventional function call
$diag = hypotenuse(3, 4);

// ------------

// 2. Function call using, 'call_user_func' library routines
$funcname = 'hypotenuse';

// a. Pass function name, and variable number of arguments
$diag = call_user_func($funcname, 3, 4);

// b. Package arguments as array, pass together with function name
$args = array(3, 4); 
$diag = call_user_func_array($funcname, $args);

// ----------------------------

$nums = array(1.4, 3.5, 6.7);

// ------------

// Pass-by-value
function int_all($arr)
{
  return array_map(create_function('$n', 'return (int) $n;'), $arr);
}

// Pass-by-reference
function trunc_em(&$n)
{
  foreach ($n as &$value) $value = (int) $value;
}

// ------------

// $nums untouched; $ints is new array
$ints = int_all($nums);

// $nums updated
trunc_em($nums);

// @@PLEAC@@_10.2
// Strictly-speaking, PHP is neither lexically [no environment capture] nor
// dynamically [no variable shadowing] scoped. A script in which several
// functions have been defined has two, entirely separate, scopes:
//
// * A 'top-level' scope i.e. everything outside each function
//
// * A 'local scope' within each function; each function is a self-contained
//   entity and cannot [via conventional means] access variables outside its
//   local scope. Accessing a variable that has not been locally defined
//   serves to define it i.e. accessing a variable assumed to be global
//   sees a local variable of that name defined
//
// The way 'global' variables are provided is via a predefined array of
// variable names, $GLOBALS [it is one of a special set of variables known
// as 'superglobals'; such variables *are* accessable in all scopes]. Each
// entry in this array is a 'global' variable name, and may be freely
// accessed / updated. A more convenient means of accessing such variables
// is via the 'global' keyword: one or more variables within a function is
// declared 'global', and those names are then taken to refer to entries
// in the $GLOBALS array rather than seeing local variables of that name
// accessed or defined

function some_func()
{
  // Variables declared within a function are local to that function
  $variable = 'something';
}

// ----------------------------

// Top-level declared variables
$name = $argv[1]; $age = $argv[2];

$c = fetch_time();

$condition = 0;

// ------------

function run_check()
{
  // The globally-declared variable, '$condition', is not accessable within
  // the function unless it declared as 'global. Had this not been done then
  // attempts to access, '$condition', would have seen a local variable
  // of that name declared and updated. Same applies to other variables
  global $condition, $name, $age, $c;

  $condition = 1;
  // ...
}

function check_x($x)
{
  $y = 'whatever';

  // This function only has access to the parameter, '$x', and the locally
  // declared variable, '$y'.

  // Whilst 'run_check' has access to several global variables, the current
  // function does not. For it to access the global variable, '$condition',
  // it must be declared 'global'
  run_check();

  global $condition;

  // 'run_check' will have updated, '$condition', and since it has been
  // declared 'global' here, it is accessable

  if ($condition)
  {
    ; // ...
  }
}

// @@PLEAC@@_10.3
// Local scopes are not created in the same way as in Perl [by simply enclosing
// within braces]: only via the creation of functions are local scopes created

// Doesn't create a local scope; '$myvariable' is created at top-level
{
  $myvariable = 7;
}

// '$myvariable' is accessable here
echo $myvariable . "\n";

// ------------

{
  $counter = 0;

  // Local scope created within function, but not within surrounding braces
  // so:
  // * '$counter' is actually a top-level variable, so globally accessable
  // * 'next_counter' has no implict access to '$counter'; must be granted
  //   via 'global' keyword

  function next_counter() { global $counter; $counter++; }
}

// ----------------------------

// PHP doesn't, AFAIK, offer an equivalent to Perl's BEGIN block. Similar
// behaviour may be obtained by defining a class, and including such code
// in its constructor

class BEGIN
{
  private $myvariable;

  function __construct()
  {
    $this->myvariable = 5;
  }

  function othersub()
  {
    echo $this->myvariable . "\n";
  }
}

// ------------

$b = new BEGIN();

$b->othersub();

// ----------------------------

// PHP, like C, supports 'static' local variables, that is, those that upon
// first access are initialised, and thence retain their value between function
// calls. However, the 'counter' example is better implemented as a class

class Counter
{
  private $counter;

  function __construct($counter_init)
  {
    $this->counter = $counter_init;
  }

  function next_counter() { $this->counter++; return $this->counter; }
  function prev_counter() { $this->counter; return $this->counter; }
}

// ------------

$counter = new Counter(42);
echo $counter->next_counter() . "\n";
echo $counter->next_counter() . "\n";
echo $counter->prev_counter() . "\n";

// @@PLEAC@@_10.4
// AFAICT there is no means of obtaining the name of the currently executing
// function, or, for that matter, perform any stack / activation record,
// inspection. It *is* possible to:
//
// * Obtain a list of the currently-defined functions ['get_defined_functions']
// * Check whether a specific function exists ['function_exists']
// * Use the 'Reflection API'
//
// So, to solve this problem would seem to require adopting a convention where
// a string representing the function name is passed as an argument, or a local
// variable [perhaps called, '$name'] is so set [contrived, and of limited use]

function whoami()
{
  $name = 'whoami';
  echo "I am: {$name}\n";
}

// ------------

whoami();

// @@PLEAC@@_10.5
// In PHP all items exist as 'memory references' [i.e. non-modifiable pointers],
// so when passing an item as a function argument, or returning an item from
// a function, it is this 'memory reference' that is passed, and *not* the
// contents of that item. Should several references to an item exist [e.g. if
// passed to a function then at least two such references would exist in
// different scopes] they would all be refering to the same copy of the item.
// However, if an attempt is made to alter the item is made, a copy is made
// and it is the copy that is altered, leaving the original intact.
// 
// The PHP reference mechanism is used to selectively prevent this behaviour,
// and ensure that if a change is made to an item that no copy is made, and that
// it is the original item that is changed. Importantly, there is no efficiency
// gain from passing function parameters using references if the parameter item
// is not altered.

// A copy of the item referred to by, '$arr', is made, and altered; original
// remains intact
function array_by_value($arr)
{
  $arr[0] = 7;
  echo $arr[0] . "\n"; 
}

// No copy is made; original item referred to by, '$arr', is altered
function array_by_ref(&$arr)
{
  $arr[0] = 7;
  echo $arr[0] . "\n"; 
}

// ------------

$arr = array(1, 2, 3);

echo $arr[0] . "\n";         // output: 1 
array_by_value($arr);        // output: 7
echo $arr[0] . "\n";         // output: 1 

$arr = array(1, 2, 3);

echo $arr[0] . "\n";         // output: 1 
array_by_ref($arr);          // output: 7
echo $arr[0] . "\n";         // output: 7 

// ----------------------------

// Since, 'add_vecpair', does not attempt to alter either, '$x' or '$y', it makes
// no difference whether they are 'passed by value', or 'passed by reference'
function add_vecpair($x, $y)
{
  $r = array();
  $length = count($x);
  for($i = 0; $i < $length; $i++) $r[$i] = $x[$i] + $y[$i];
  return $r;
}

// ...
count($arr1) == count($arr2) || die("usage: add_vecpair ARR1 ARR2\n");

// 'passed by value'
$arr3 = add_vecpair($arr1, $arr2);

// 'passed by reference' [also possible to override default 'passed by value'
// if required]
$arr3 = add_vecpair(&$arr1, &$arr2);

// @@PLEAC@@_10.6
// PHP can be described as a dynamically typed language because variables serve
// as identifiers, and the same variable may refer to data of various types.
// As such, the set of arguments passed to a function may vary in type between
// calls, as can the type of return value. Where this is likely to occur type
// checking should be performed either / both within the function body, and
// when obtaining it's return value. As for Perl-style 'return context', I
// don't believe it is supported by PHP

// Can return any type
function mysub()
{
  // ...
  return 5;
  // ...
  return array(5);
  // ...
  return '5';
}

// Throw away return type [i.e. returns a 'void' type ?]
mysub();

// Check return type. Can do via:
// * gettype($var)
// * is_xxx e.g. is_array($var), is_muneric($var), ...
$ret = mysub();

if (is_numeric($ret))
{
  ; // ...
}

if (is_array($ret))
{
  ; // ...
}

if (is_string($ret))
{
  ; // ...
}

// @@PLEAC@@_10.7
// PHP doesn't directly support named / keyword parameters, but these can be
// easily mimiced using a class of key / value pairs, and passing a variable
// number of arguments

class KeyedValue
{
  public $key, $value;
  public function __construct($key, $value) { $this->key = $key; $this->value = $value; }
}

function the_func()
{
  foreach (func_get_args() as $arg)
  {
    printf("Key: %10s|Value:%10s\n", $arg->key, $arg->value);
  }
}

// ----

the_func(new KeyedValue('name', 'Bob'),
         new KeyedValue('age', 36),
         new KeyedValue('income', 51000));

// ----------------------------

// Alternatively, an associative array of key / value pairs may be constructed.
// With the aid of the 'extract' built-in function, the key part of this array
// may be intsntiated to a variable name, thus more closely approximating the
// behaviour of true named parameters

function the_func($var_array)
{
  extract($var_array);

  if (isset($name)) printf("Name:   %s\n", $name);
  if (isset($age)) printf("Age:    %s\n", $age);
  if (isset($income)) printf("Income: %s\n", $income);
}

// ----

the_func(array('name' => 'Bob', 'age' => 36, 'income' => 51000));

// ----------------------------

class RaceTime
{
  public $time, $dim;
  public function __construct($time, $dim) { $this->time = $time; $this->dim = $dim; }
}

function the_func($var_array)
{
  extract($var_array);

  if (isset($start_time)) printf("start:  %d - %s\n", $start_time->time, $start_time->dim);
  if (isset($finish_time)) printf("finish: %d - %s\n", $finish_time->time, $finish_time->dim);
  if (isset($incr_time)) printf("incr:   %d - %s\n", $incr_time->time, $incr_time->dim);
}

// ----

the_func(array('start_time' => new RaceTime(20, 's'),
               'finish_time' => new RaceTime(5, 'm'),
               'incr_time' => new RaceTime(3, 'm')));

the_func(array('start_time' => new RaceTime(5, 'm'),
               'finish_time' => new RaceTime(30, 'm')));

the_func(array('start_time' => new RaceTime(30, 'm')));

// @@PLEAC@@_10.8
// The 'list' keyword [looks like a function but is actually a special language
// construct] may be used to perform multiple assignments from a numerically
// indexed array of values, and offers the added bonus of being able to skip
// assignment of one, or more, of those values

function func() { return array(3, 6, 9); }

// ------------

list($a, $b, $c) = array(6, 7, 8);

// Provided 'func' returns an numerically-indexed array, the following
// multiple assignment will work
list($a, $b, $c) = func();

// Any existing variables no longer wanted would need to be 'unset'
unset($b);

// As above, but second element of return array discarded
list($a,,$c) = func();

// ----------------------------

// Care needed to ensure returned array is numerically-indexed
list($dev, $ino,,,$uid) = array_slice(array_values(stat($filename)), 0, 13);

// @@PLEAC@@_10.9
// Multiple return values are possible via packing a set of values within a
// numerically-indexed array and using 'list' to extract them

function some_func() { return array(array(1, 2, 3), array('a' => 1, 'b' => 2)); }

// ------------

list($arr, $hash) = some_func();

// ----------------------------

function some_func(&$arr, &$hash) { return array($arr, $hash); }

// ------------

$arrin = array(1, 2, 3); $hashin = array('a' => 1, 'b' => 2);

list($arr, $hash) = some_func($arrin, $hashin);

// @@PLEAC@@_10.10
// AFAICT, most of the PHP library functions are designed to return some required 
// value on success, and FALSE on exit. Whilst it is possible to return NULL, or
// one of the recognised 'empty' values [e.g. '' or 0 or an empty array etc],
// FALSE actually seems to be the preferred means of indicating failure

function a_func() { return FALSE; }

a_func() || die("Function failed\n");

if (!a_func()) die("Function failed\n");

// @@PLEAC@@_10.11
// Whether PHP is seen to support prototyping depends on the accepted
// definition of this term:
//
// * Prototyping along the lines used in Ada, Modula X, and even C / C++,
//   in which a function's interface is declared separately from its
//   implementation, is *not* supported
//
// * Prototyping in which, as part of the function definition, parameter
//   information must be supplied. In PHP a function definition neither
//   parameter, nor return type, information needs to be supplied, though
//   it is usual to see a parameter list supplied [indicates the number,
//   positional order, and optionally, whether a parameter is passed by
//   reference; no type information is present]. In short, prototyping in
//   PHP is optional, and limited

function func_with_one_arg($arg1)
{
  ; // ...
}

function func_with_two_arg($arg1, $arg2)
{
  ; // ...
}

function func_with_three_arg($arg1, $arg2, $arg3)
{
  ; // ...
}

// The following may be interpreted as meaning a function accepting no
// arguments:
function func_with_no_arg()
{
  ; // ...
}

// whilst the following may mean a function taking zero or more arguments
function func_with_no_arg_information()
{
  ; // ...
}

// @@PLEAC@@_10.12
// Unlike in Perl, PHP's 'die' [actually an alias for 'exit'] doesn't throw
// an exception, but instead terminates the script, optionally either
// returning an integer value to the operating system, or printing a message.
// So, the following, does not exhibit the same behaviour as the Perl example

die("some message\n"); 

// Instead, like so many modern languages, PHP implements exception handling
// via the 'catch' and 'throw' keywords. Furthermore, a C++ or Java programmer
// would find PHP's exception handling facility remarkably similar to those
// of their respective languages. A simple, canonical example follows:

// Usual to derive new exception classes from the built-in, 'Exception',
// class
class MyException extends Exception
{
  // ...
}

// ...

try
{
  // ...
  if ($some_problem_detected) throw new MyException('some message', $some_error_code);
  // ..
}

catch (MyException $e)
{
  ; // ... handle the problem ...
}

// ----------------------------

class FullMoonException extends Exception
{
  // ...
}

// ...

try
{
  // ...
  if ($some_problem_detected) throw new FullMoonException('...', $full_moon_error_code);
  // ..
}

catch (FullMoonException $e)
{
  // ... rethrow the exception - will propagate to higher level ...
  throw $e;
}

// @@PLEAC@@_10.13
// Please refer to discussion about PHP scope in section two of this chapter.
// Briefly, PHP assumes a variable name within a function to be local unless
// it has been specifically declared with the, 'global', keyword, in which
// case it refers to a variable in the 'superglobal' array, '$GLOBALS'. Thus,
// inadvertant variable name shadowing cannot occur since it is it not possible 
// to use the same name to refer to both a local and a global variable. If
// accessing a global variable care should be taken to not accidentally update
// it. The techniques used in this section are simply not required.

// *** NOT TRANSLATED ***

// @@PLEAC@@_10.14
// In PHP once a function has been defined it remains defined. In other words,
// it cannot be undefined / deleted, nor can that particular function name be
// reused to reference another function body. Even the lambda-like functions
// created via the 'create_function' built-in, cannot be undefined [they exist
// until script termination, thus creating too many of these can actually
// exhaust memory !]. However, since the latter can be assigned to variables,
// the same variable name can be used to reference difference functions [and
// when this is done the reference to the previous function is lost (unless
// deliberately saved), though the function itself continues to exist].
//
// If, however, all that is needed is a simple function aliasing facility,
// then just assign the function name to a variable, and execute using the
// variable name

// Original function
function expand() { echo "expand\n"; }

// Prove that function exists
echo (function_exists('expand') ? 'yes' : 'no') . "\n";

// Use a variable to alias it
$grow = 'expand';

// Call function via original name, and variable, respectively
expand();

$grow(); 

// Remove alias variable
unset($grow);

// ----------------------------

function fred() { echo "fred\n"; }

$barney = 'fred';

$barney();

unset($barney);

fred();

// ------------

$fred = create_function('', 'echo "fred\n";');

$barney = $fred;

$barney();

unset($barney);

$fred();

// ----------------------------

function red($text) { return "<FONT COLOR='red'>$text</FONT>"; }

echo red('careful here') . "\n";

// ------------

$colour = 'red';

$$colour = create_function('$text', 'global $colour;
return "<FONT COLOR=\'$colour\'>$text</FONT>";');

echo $$colour('careful here') . "\n";

unset($$colour);

// ----

$colours = split(' ', 'red blue green yellow orange purple violet');

foreach ($colours as $colour)
{
  $$colour = create_function('$text', 'global $colour;
  return "<FONT COLOR=\'$colour\'>$text</FONT>";');
}

foreach ($colours as $colour) { echo $$colour("Careful with this $colour, James") . "\n"; }

foreach ($colours as $colour) { unset($$colour); }

// @@PLEAC@@_10.15
// PHP sports an AUTOLOAD facility that is quite easy to use, but, AFAICT, is geared
// towards the detection of unavailable classes rather than for individual functions.
// Here is a rudimentary example:

function __autoload($classname)
{
  if (!file_exists($classname))
  {
    // Class file does not exist, so handle situation; in this case,
    // issue error message, and exit program
    die("File for class: {$classname} not found - aborting\n");
  }
  else
  {
    // Class file exists, so load it
    require_once $classname;
  }
}

// ------------

// Attempt to instantiate object of undefined class 
new UnknownClassObject();

// Execution continues here if class exists
// ...

// ----------------------------

// It is also possible to perform [quite extensive] introspection on functions,
// variables etc, so it is possible to check whether a function exists before
// executing it, thus allowing a non-existent functions to be searched for and
// loaded from a source file, or perhaps dynamically defined. An example of what
// could be described as a custom autoload facility appears below.

$colours = array('red', 'blue', 'green', 'yellow', 'orange', 'purple', 'violet');

foreach ($colours as $colour)
{
  $$colour = create_function('$text', 'global $colour;
  return "<FONT COLOR=\'$colour\'>$text</FONT>";');
}

// Let's add a new colour to the list
array_push($colours, 'chartreuse'); 

foreach ($colours as $colour)
{
  // Checking whether function is defined
  if (!function_exists($$colour))
  {
    // Doesn't exist, so dynamically define it
    $$colour = create_function('$text', 'global $colour;
    return "<FONT COLOR=\'$colour\'>$text</FONT>";');

    // Alternatively, if it exists in a source file, 'include' the file:
    // include 'newcolours.php'
  }

  echo $$colour("Careful with this $colour, James") . "\n";
}

foreach ($colours as $colour) unset($$colour); 

// @@PLEAC@@_10.16
// *** Warning *** Whilst PHP *does* allow functions to be defined within other
// functions it needs to be clearly understood that these 'inner' functions:
// * Do not exist until the outer function is called a first time, at which time
//   they then remain defined
// * Are global in scope, so are accessable outside the function by their name;
//   the fact that they are nested within another function has, AFAICT, no bearing
//   on name resolution
// * Do not form a closure: the inner function is merely 'parked' within the
//   outer function, and has no implicit access to the outer function's variables
//   or other inner functions

function outer($arg)
{
  $x = $arg + 35;
  function inner() { return $x * 19; }

  // *** wrong *** 'inner' returns 0 * 19, not ($arg + 35) * 19
  return $x + inner();
}

// ----------------------------

function outer($arg)
{
  $x = $arg + 35;

  // No implicit access to outer function scope; any required data must be
  // explicity passed
  function inner($x) { return $x * 19; }

  return $x + inner($x);
}

// ------------ 

// Equivalent to previously-shown code
function inner($x)
{
  return $x * 19;
}

function outer($arg)
{
  $x = $arg + 35;
  return $x + inner($x);
}

// @@PLEAC@@_10.17
// @@INCOMPLETE@@
// @@INCOMPLETE@@

// @@PLEAC@@_16.1
// Run a command and return its results as a string.
$output_string = shell_exec('program args');

// Same as above, using backtick operator.
$output_string = `program args`;

// Run a command and return its results as a list of strings,
// one per line.
$output_lines = array();
exec('program args', $output_lines);

// -----------------------------

// The only way to execute a program without using the shell is to
// use pcntl_exec(). However, there is no way to do redirection, so
// you can't capture its output.

$pid = pcntl_fork();
if ($pid == -1) {
    die('cannot fork');
} elseif ($pid) {
    pcntl_waitpid($pid, $status);
} else {
    // Note that pcntl_exec() automatically prepends the program name
    // to the array of arguments; the program name cannot be spoofed.
    pcntl_exec($program, array($arg1, $arg2));
}

// @@PLEAC@@_16.2
// Run a simple command and retrieve its result code.
exec("vi $myfile", $output, $result_code);

// -----------------------------

// Use the shell to perform redirection.
exec('cmd1 args | cmd2 | cmd3 >outfile');
exec('cmd args <infile >outfile 2>errfile');

// -----------------------------

// Run a command, handling its result code or signal.
$pid = pcntl_fork();
if ($pid == -1) {
    die('cannot fork');
} elseif ($pid) {
    pcntl_waitpid($pid, $status);
    if (pcntl_wifexited($status)) {
        $status = pcntl_wexitstatus($status);
        echo "program exited with status $status\n";
    } elseif (pcntl_wifsignaled($status)) {
        $signal = pcntl_wtermsig($status);
        echo "program killed by signal $signal\n";
    } elseif (pcntl_wifstopped($status)) {
        $signal = pcntl_wstopsig($status);
        echo "program stopped by signal $signal\n";
    }
} else {
    pcntl_exec($program, $args);
}

// -----------------------------

// Run a command while blocking interrupt signals.
$pid = pcntl_fork();
if ($pid == -1) {
    die('cannot fork');
} elseif ($pid) {
    // parent catches INT and berates user
    declare(ticks = 1);
    function handle_sigint($signal) {
        echo "Tsk tsk, no process interruptus\n";
    }
    pcntl_signal(SIGINT, 'handle_sigint');
    while (!pcntl_waitpid($pid, $status, WNOHANG)) {}
} else {
    // child ignores INT and does its thing
    pcntl_signal(SIGINT, SIG_IGN);
    pcntl_exec('/bin/sleep', array('10'));
}

// -----------------------------

// Since there is no direct access to execv() and friends, and
// pcntl_exec() won't let us supply an alternate program name
// in the argument list, there is no way to run a command with
// a different name in the process table.

// @@PLEAC@@_16.3
// Transfer control to the shell to run another program.
pcntl_exec('/bin/sh', array('-c', 'archive *.data'));
// Transfer control directly to another program.
pcntl_exec('/path/to/archive', array('accounting.data'));

// @@PLEAC@@_16.4
// Handle each line in the output of a process.
$readme = popen('program arguments', 'r');
while (!feof($readme)) {
    $line = fgets($readme);
    if ($line === false) break;
    // ...
}
pclose($readme);

// -----------------------------

// Write to the input of a process.
$writeme = popen('program arguments', 'w');
fwrite($writeme, 'data');
pclose($writeme);

// -----------------------------

// Wait for a process to complete.
$f = popen('sleep 1000000', 'r');  // child goes to sleep
pclose($f);                        // and parent goes to lala land

// -----------------------------

$writeme = popen('program arguments', 'w');
fwrite($writeme, "hello\n");  // program will get hello\n on STDIN
pclose($writeme);             // program will get EOF on STDIN

// -----------------------------

// Output buffering callback that sends output to the pager.
function ob_pager($output, $mode) {
    static $pipe;
    if ($mode & PHP_OUTPUT_HANDLER_START) {
        $pager = getenv('PAGER');
        if (!$pager) $pager = '/usr/bin/less';  // XXX: might not exist
        $pipe = popen($pager, 'w');
    }
    fwrite($pipe, $output);
    if ($mode & PHP_OUTPUT_HANDLER_END) {
        pclose($pipe);
    }
}

// Redirect standard output to the pager.
ob_start('ob_pager');

// Do something useful that writes to standard output, then
// close the output buffer.
// ...
ob_end_flush();

// @@PLEAC@@_16.5
// Output buffering: Only display a certain number of lines of output.
class Head {
    function Head($lines=20) {
        $this->lines = $lines;
    }

    function filter($output, $mode) {
        $result = array();
        $newline = '';
        if (strlen($output) > 0 && $output[strlen($output) - 1] == "\n") {
            $newline = "\n";
            $output = substr($output, 0, -1);
        }
        foreach (explode("\n", $output) as $i => $line) {
            if ($this->lines > 0) {
                $this->lines--;
                $result[] = $line;
            }
        }
        return $result ? implode("\n", $result) . $newline : '';
    }
}

// Output buffering: Prepend line numbers to each line of output.
class Number {
    function Number() {
        $this->line_number = 0;
    }

    function filter($output, $mode) {
        $result = array();
        $newline = '';
        if (strlen($output) > 0 && $output[strlen($output) - 1] == "\n") {
            $newline = "\n";
            $output = substr($output, 0, -1);
        }
        foreach (explode("\n", $output) as $i => $line) {
            $this->line_number++;
            $result[] = $this->line_number . ': ' . $line;
        }
        return implode("\n", $result) . $newline;
    }
}

// Output buffering: Prepend "> " to each line of output.
class Quote {
    function Quote() {
    }

    function filter($output, $mode) {
        $result = array();
        $newline = '';
        if (strlen($output) > 0 && $output[strlen($output) - 1] == "\n") {
            $newline = "\n";
            $output = substr($output, 0, -1);
        }
        foreach (explode("\n", $output) as $i => $line) {
            $result[] = "> $line";
        }
        return implode("\n", $result) . $newline;
    }
}

// Use arrays as callbacks to register filter methods.
ob_start(array(new Head(100), 'filter'));
ob_start(array(new Number(), 'filter'));
ob_start(array(new Quote(), 'filter'));

// Act like /bin/cat.
while (!feof(STDIN)) {
    $line = fgets(STDIN);
    if ($line === false) break;
    echo $line;
}

// Should match number of calls to ob_start().
ob_end_flush();
ob_end_flush();
ob_end_flush();

// @@PLEAC@@_16.6
// Process command-line arguments using fopen(). PHP supports URLs for
// filenames as long as the "allow_url_fopen" configuration option is set.
//
// Valid URL protocols include:
//   - http://www.myserver.com/myfile.html
//   - ftp://ftp.myserver.com/myfile.txt
//   - compress.zlib://myfile.gz
//   - php://stdin
//
// See http://www.php.net/manual/en/wrappers.php for details.
//
$filenames = array_slice($argv, 1);
if (!$filenames) $filenames = array('php://stdin');
foreach ($filenames as $filename) {
    $handle = @fopen($filename, 'r');
    if ($handle) {
        while (!feof($handle)) {
            $line = fgets($handle);
            if ($line === false) break;
            // ...
        }
        fclose($handle);
    } else {
        die("can't open $filename\n");
    }
}

// @@PLEAC@@_16.7
$output = `cmd 2>&1`;                          // with backticks
// or
$ph = popen('cmd 2>&1');                       // with an open pipe
while (!feof($ph)) { $line = fgets($ph); }     // plus a read
// -----------------------------
$output = `cmd 2>/dev/null`;                   // with backticks
// or
$ph = popen('cmd 2>/dev/null');                // with an open pipe
while (!feof($ph)) { $line = fgets($ph); }     // plus a read
// -----------------------------
$output = `cmd 2>&1 1>/dev/null`;              // with backticks
// or
$ph = popen('cmd 2>&1 1>/dev/null');           // with an open pipe
while (!feof($ph)) { $line = fgets($ph); }     // plus a read
// -----------------------------
$output = `cmd 3>&1 1>&2 2>&3 3>&-`;           // with backticks
// or
$ph = popen('cmd 3>&1 1>&2 2>&3 3>&-|');       // with an open pipe
while (!feof($ph)) { $line = fgets($ph); }     // plus a read
// -----------------------------
exec('program args 1>/tmp/program.stdout 2>/tmp/program.stderr');
// -----------------------------
$output = `cmd 3>&1 1>&2 2>&3 3>&-`;
// -----------------------------
$fd3 = $fd1;
$fd1 = $fd2;
$fd2 = $fd3;
$fd3 = null;
// -----------------------------
exec('prog args 1>tmpfile 2>&1');
exec('prog args 2>&1 1>tmpfile');
// -----------------------------
// exec('prog args 1>tmpfile 2>&1');
$fd1 = "tmpfile";        // change stdout destination first
$fd2 = $fd1;             // now point stderr there, too
// -----------------------------
// exec('prog args 2>&1 1>tmpfile');
$fd2 = $fd1;             // stderr same destination as stdout
$fd1 = "tmpfile";        // but change stdout destination

// @@PLEAC@@_16.8
// Connect to input and output of a process.
$proc = proc_open($program,
                  array(0 => array('pipe', 'r'),
                        1 => array('pipe', 'w')),
                  $pipes);
if (is_resource($proc)) {
    fwrite($pipes[0], "here's your input\n");
    fclose($pipes[0]);
    echo stream_get_contents($pipes[1]);
    fclose($pipes[1]);
    $result_code = proc_close($proc);
    echo "$result_code\n";
}

// -----------------------------

$all = array();
$outlines = array();
$errlines = array();
exec("( $cmd | sed -e 's/^/stdout: /' ) 2>&1", $all);
foreach ($all as $line) {
    $pos = strpos($line, 'stdout: ');
    if ($pos !== false && $pos == 0) {
        $outlines[] = substr($line, 8);
    } else {
        $errlines[] = $line;
    }
}
print("STDOUT:\n");
print_r($outlines);
print("\n");
print("STDERR:\n");
print_r($errlines);
print("\n");

// @@PLEAC@@_16.9
$proc = proc_open($cmd,
                  array(0 => array('pipe', 'r'),
                        1 => array('pipe', 'w'),
                        2 => array('pipe', 'w')),
                  $pipes);

if (is_resource($proc)) {
    // give end of file to kid, or feed him
    fclose($pipes[0]);

    // read till EOF
    $outlines = array();
    while (!feof($pipes[1])) {
        $line = fgets($pipes[1]);
        if ($line === false) break;
        $outlines[] = rtrim($line);
    }

    // XXX: block potential if massive
    $errlines = array();
    while (!feof($pipes[2])) {
        $line = fgets($pipes[2]);
        if ($line === false) break;
        $errlines[] = rtrim($line);
    }

    fclose($pipes[1]);
    fclose($pipes[2]);
    proc_close($proc);

    print("STDOUT:\n");
    print_r($outlines);
    print("\n");
    print("STDERR:\n");
    print_r($errlines);
    print("\n");
}

// -----------------------------

// cmd3sel - control all three of kids in, out, and error.
$cmd = "grep vt33 /none/such - /etc/termcap";
$proc = proc_open($cmd,
                  array(0 => array('pipe', 'r'),
                        1 => array('pipe', 'w'),
                        2 => array('pipe', 'w')),
                  $pipes);

if (is_resource($proc)) {
    fwrite($pipes[0], "This line has a vt33 lurking in it\n");
    fclose($pipes[0]);

    $readers = array($pipes[1], $pipes[2]);
    while (stream_select($read=$readers,
                         $write=null,
                         $except=null,
                         0, 200000) > 0) {
        foreach ($read as $stream) {
            $line = fgets($stream);
            if ($line !== false) {
                if ($stream === $pipes[1]) {
                    print "STDOUT: $line";
                } else {
                    print "STDERR: $line";
                }
            }
            if (feof($stream)) {
                $readers = array_diff($readers, array($stream));
            }
        }
    }

    fclose($pipes[1]);
    fclose($pipes[2]);
    proc_close($proc);
}

// @@PLEAC@@_16.10
// PHP supports fork/exec/wait but not pipe. However, it does
// support socketpair, which can do everything pipes can as well
// as bidirectional communication. The original recipes have been
// modified here to use socketpair only.

// -----------------------------

// pipe1 - use socketpair and fork so parent can send to child
$sockets = array();
if (!socket_create_pair(AF_UNIX, SOCK_STREAM, 0, $sockets)) {
    die(socket_strerror(socket_last_error()));
}
list($reader, $writer) = $sockets;

$pid = pcntl_fork();
if ($pid == -1) {
    die('cannot fork');
} elseif ($pid) {
    socket_close($reader);
    $line = sprintf("Parent Pid %d is sending this\n", getmypid());
    if (!socket_write($writer, $line, strlen($line))) {
        socket_close($writer);
        die(socket_strerror(socket_last_error()));
    }
    socket_close($writer);
    pcntl_waitpid($pid, $status);
} else {
    socket_close($writer);
    $line = socket_read($reader, 1024, PHP_NORMAL_READ);
    printf("Child Pid %d just read this: `%s'\n", getmypid(), rtrim($line));
    socket_close($reader);  // this will happen anyway
    exit(0);
}

// -----------------------------

// pipe2 - use socketpair and fork so child can send to parent
$sockets = array();
if (!socket_create_pair(AF_UNIX, SOCK_STREAM, 0, $sockets)) {
    die(socket_strerror(socket_last_error()));
}
list($reader, $writer) = $sockets;

$pid = pcntl_fork();
if ($pid == -1) {
    die('cannot fork');
} elseif ($pid) {
    socket_close($writer);
    $line = socket_read($reader, 1024, PHP_NORMAL_READ);
    printf("Parent Pid %d just read this: `%s'\n", getmypid(), rtrim($line));
    socket_close($reader);
    pcntl_waitpid($pid, $status);
} else {
    socket_close($reader);
    $line = sprintf("Child Pid %d is sending this\n", getmypid());
    if (!socket_write($writer, $line, strlen($line))) {
        socket_close($writer);
        die(socket_strerror(socket_last_error()));
    }
    socket_close($writer);  // this will happen anyway
    exit(0);
}

// -----------------------------

// pipe3 and pipe4 demonstrate the use of perl's "forking open"
// feature to reimplement pipe1 and pipe2. pipe5 uses two pipes
// to simulate socketpair. Since PHP supports socketpair but not
// pipe, and does not have a "forking open" feature, these
// examples are skipped here.

// -----------------------------

// pipe6 - bidirectional communication using socketpair
$sockets = array();
if (!socket_create_pair(AF_UNIX, SOCK_STREAM, 0, $sockets)) {
    die(socket_strerror(socket_last_error()));
}
list($child, $parent) = $sockets;

$pid = pcntl_fork();
if ($pid == -1) {
    die('cannot fork');
} elseif ($pid) {
    socket_close($parent);
    $line = sprintf("Parent Pid %d is sending this\n", getmypid());
    if (!socket_write($child, $line, strlen($line))) {
        socket_close($child);
        die(socket_strerror(socket_last_error()));
    }
    $line = socket_read($child, 1024, PHP_NORMAL_READ);
    printf("Parent Pid %d just read this: `%s'\n", getmypid(), rtrim($line));
    socket_close($child);
    pcntl_waitpid($pid, $status);
} else {
    socket_close($child);
    $line = socket_read($parent, 1024, PHP_NORMAL_READ);
    printf("Child Pid %d just read this: `%s'\n", getmypid(), rtrim($line));
    $line = sprintf("Child Pid %d is sending this\n", getmypid());
    if (!socket_write($parent, $line, strlen($line))) {
        socket_close($parent);
        die(socket_strerror(socket_last_error()));
    }
    socket_close($parent);
    exit(0);
}

// @@PLEAC@@_16.11
// -----------------------------
// % mkfifo /path/to/named.pipe
// -----------------------------

$fifo = fopen('/path/to/named.pipe', 'r');
if ($fifo !== false) {
    while (!feof($fifo)) {
        $line = fgets($fifo);
        if ($line === false) break;
        echo "Got: $line";
    }
    fclose($fifo);
} else {
    die('could not open fifo for read');
}

// -----------------------------

$fifo = fopen('/path/to/named.pipe', 'w');
if ($fifo !== false) {
    fwrite($fifo, "Smoke this.\n");
    fclose($fifo);
} else {
    die('could not open fifo for write');
}

// -----------------------------
// % mkfifo ~/.plan                    #  isn't this everywhere yet?
// % mknod  ~/.plan p                  #  in case you don't have mkfifo
// -----------------------------

// dateplan - place current date and time in .plan file
while (true) {
    $home = getenv('HOME');
    $fifo = fopen("$home/.plan", 'w');
    if ($fifo === false) {
        die("Couldn't open $home/.plan for writing.\n");
    }
    fwrite($fifo,
           'The current time is '
           . strftime('%a, %d %b %Y %H:%M:%S %z')
           . "\n");
    fclose($fifo);
    sleep(1);
}

// -----------------------------

// fifolog - read and record log msgs from fifo

$fifo = null;

declare(ticks = 1);
function handle_alarm($signal) {
    global $fifo;
    if ($fifo) fclose($fifo);   // move on to the next queued process
}
pcntl_signal(SIGALRM, 'handle_alarm');

while (true) {
    pcntl_alarm(0);             // turn off alarm for blocking open
    $fifo = fopen('/tmp/log', 'r');
    if ($fifo === false) {
        die("can't open /tmp/log");
    }
    pcntl_alarm(1);             // you have 1 second to log

    $service = fgets($fifo);
    if ($service === false) continue; // interrupt or nothing logged
    $service = rtrim($service);

    $message = fgets($fifo);
    if ($message === false) continue; // interrupt or nothing logged
    $message = rtrim($message);

    pcntl_alarm(0);             // turn off alarms for message processing

    if ($service == 'http') {
        // ignoring
    } elseif ($service == 'login') {
        // log to /var/log/login
        $log = fopen('/var/log/login', 'a');
        if ($log !== false) {
            fwrite($log,
                   strftime('%a, %d %b %Y %H:%M:%S %z')
                   . " $service $message\n");
            fclose($log);
        } else {
            trigger_error("Couldn't log $service $message to /var/log/login\n",
                          E_USER_WARNING);
        }
    }
}

// @@PLEAC@@_16.12
// sharetest - test shared variables across forks

$SHM_KEY = ftok(__FILE__, chr(1));
$handle = sem_get($SHM_KEY);
$buffer = shm_attach($handle, 1024);

// The original recipe has an INT signal handler here. However, it
// causes erratic behavior with PHP, and PHP seems to do the right
// thing without it.

for ($i = 0; $i < 10; $i++) {
    $child = pcntl_fork();
    if ($child == -1) {
        die('cannot fork');
    } elseif ($child) {
        $kids[] = $child; // in case we care about their pids
    } else {
        squabble();
        exit();
    }
}

while (true) {
    print 'Buffer is ' . shm_get_var($buffer, 1) . "\n";
    sleep(1);
}
die('Not reached');

function squabble() {
    global $handle;
    global $buffer;
    $i = 0;
    $pid = getmypid();
    while (true) {
        if (preg_match("/^$pid\\b/", shm_get_var($buffer, 1))) continue;
        sem_acquire($handle);
        $i++;
        shm_put_var($buffer, 1, "$pid $i");
        sem_release($handle);
    }
}

// Buffer is 14357 1
// Buffer is 14355 3
// Buffer is 14355 4
// Buffer is 14354 5
// Buffer is 14353 6
// Buffer is 14351 8
// Buffer is 14351 9
// Buffer is 14350 10
// Buffer is 14348 11
// Buffer is 14348 12
// Buffer is 14357 10
// Buffer is 14357 11
// Buffer is 14355 13
// ...

// @@PLEAC@@_16.13
// Available signal constants
% php -r 'print_r(get_defined_constants());' | grep '\[SIG' | grep -v _
    [SIGHUP] => 1
    [SIGINT] => 2
    [SIGQUIT] => 3
    [SIGILL] => 4
    [SIGTRAP] => 5
    [SIGABRT] => 6
    [SIGIOT] => 6
    [SIGBUS] => 7
    [SIGFPE] => 8
    [SIGKILL] => 9
    [SIGUSR1] => 10
    [SIGSEGV] => 11
    [SIGUSR2] => 12
    [SIGPIPE] => 13
    [SIGALRM] => 14
    [SIGTERM] => 15
    [SIGSTKFLT] => 16
    [SIGCLD] => 17
    [SIGCHLD] => 17
    [SIGCONT] => 18
    [SIGSTOP] => 19
    [SIGTSTP] => 20
    [SIGTTIN] => 21
    [SIGTTOU] => 22
    [SIGURG] => 23
    [SIGXCPU] => 24
    [SIGXFSZ] => 25
    [SIGVTALRM] => 26
    [SIGPROF] => 27
    [SIGWINCH] => 28
    [SIGPOLL] => 29
    [SIGIO] => 29
    [SIGPWR] => 30
    [SIGSYS] => 31
    [SIGBABY] => 31

// Predefined signal handler constants
% php -r 'print_r(get_defined_constants());' | grep '\[SIG' | grep _
    [SIG_IGN] => 1
    [SIG_DFL] => 0
    [SIG_ERR] => -1

// @@PLEAC@@_16.14
// send pid a signal 9
posix_kill($pid, 9);
// send whole job a signal 1
posix_kill($pgrp, -1);
// send myself a SIGUSR1
posix_kill(getmypid(), SIGUSR1);
// send a SIGHUP to processes in pids
foreach ($pids as $pid) posix_kill($pid, SIGHUP);

// -----------------------------

// Use kill with pseudo-signal 0 to see if process is alive.
if (posix_kill($minion, 0)) {
    echo "$minion is alive!\n";
} else {
    echo "$minion is deceased.\n";
}

// @@PLEAC@@_16.15
// call got_sig_quit for every SIGQUIT
pcntl_signal(SIGQUIT, 'got_sig_quit');
// call got_sig_pipe for every SIGPIPE
pcntl_signal(SIGPIPE, 'got_sig_pipe');
// increment ouch for every SIGINT
function got_sig_int($signal) { global $ouch; $ouch++; }
pcntl_signal(SIGINT, 'got_sig_int');
// ignore the signal INT
pcntl_signal(SIGINT, SIG_IGN);
// restore default STOP signal handling
pcntl_signal(SIGSTOP, SIG_DFL);

// @@PLEAC@@_16.16
// the signal handler
function ding($signal) {
    fwrite(STDERR, "\x07Enter your name!\n");
}

// prompt for name, overriding SIGINT
function get_name() {
    declare(ticks = 1);
    pcntl_signal(SIGINT, 'ding');

    echo "Kindly Stranger, please enter your name: ";
    while (!@stream_select($read=array(STDIN),
                           $write=null,
                           $except=null,
                           1)) {
        // allow signals to be observed
    }
    $name = fgets(STDIN);

    // Since pcntl_signal() doesn't return the old signal handler, the
    // best we can do here is set it back to the default behavior.
    pcntl_signal(SIGINT, SIG_DFL);

    return $name;
}

// @@PLEAC@@_16.17
function got_int($signal) {
    pcntl_signal(SIGINT, 'got_int');  // but not for SIGCHLD!
    // ...
}
pcntl_signal(SIGINT, 'got_int');

// -----------------------------

declare(ticks = 1);
$interrupted = false;

function got_int($signal) {
    global $interrupted;
    $interrupted = true;
    // The third argument to pcntl_signal() determines if system calls
    // should be restarted after a signal. It defaults to true.
    pcntl_signal(SIGINT, 'got_int', false);  // or SIG_IGN
}
pcntl_signal(SIGINT, 'got_int', false);

// ... long-running code that you don't want to restart

if ($interrupted) {
    // deal with the signal
}

// @@PLEAC@@_16.18
// ignore signal INT
pcntl_signal(SIGINT, SIG_IGN);

// install signal handler
declare(ticks = 1);
function tsktsk($signal) {
    fwrite(STDERR, "\x07The long habit of living indisposeth us for dying.");
    pcntl_signal(SIGINT, 'tsktsk');
}
pcntl_signal(SIGINT, 'tsktsk');

// @@PLEAC@@_16.19
pcntl_signal(SIGCHLD, SIG_IGN);

// -----------------------------

declare(ticks = 1);
function reaper($signal) {
    $pid = pcntl_waitpid(-1, $status, WNOHANG);
    if ($pid > 0) {
        // ...
        reaper($signal);
    }
    // install *after* calling waitpid
    pcntl_signal(SIGCHLD, 'reaper');
}
pcntl_signal(SIGCHLD, 'reaper');

// -----------------------------

declare(ticks = 1);
function reaper($signal) {
    $pid = pcntl_waitpid(-1, $status, WNOHANG);
    if ($pid == -1) {
        // No child waiting. Ignore it.
    } else {
        if (pcntl_wifexited($signal)) {
            echo "Process $pid exited.\n";
        } else {
            echo "False alarm on $pid\n";
        }
        reaper($signal);
    }
    pcntl_signal(SIGCHLD, 'reaper');
}
pcntl_signal(SIGCHLD, 'reaper');

// @@PLEAC@@_16.20
// PHP does not support sigprocmask().

// @@PLEAC@@_16.21
declare(ticks = 1);
$aborted = false;

function handle_alarm($signal) {
    global $aborted;
    $aborted = true;
}
pcntl_signal(SIGALRM, 'handle_alarm');

pcntl_alarm(3600);
// long-time operations here
pcntl_alarm(0);
if ($aborted) {
    // timed out - do what you will here
}
