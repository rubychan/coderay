# -*- python -*-
# vim:set ft=python:

# @@PLEAC@@_NAME
# @@SKIP@@ Python

# @@PLEAC@@_WEB
# @@SKIP@@ http://www.python.org

# @@PLEAC@@_INTRO
# @@SKIP@@ The latest version of Python is 2.4 but users of 2.3 and 2.2 (and
# @@SKIP@@ in some cases earlier versions) can use the code herein.
# @@SKIP@@ Users of 2.2 and 2.3 should install or copy code from utils.py 
# @@SKIP@@ (http://aima.cs.berkeley.edu/python/utils.py)
# @@SKIP@@ [the first section provides compatability code with 2.4]
# @@SKIP@@ Users of 2.2 should install optik (http://optik.sourceforge.com) 
# @@SKIP@@ [for optparse and textwrap]
# @@SKIP@@ Where a 2.3 or 2.4 feature is unable to be replicated, an effort
# @@SKIP@@ has been made to provide a backward-compatible version in addition
# @@SKIP@@ to one using modern idioms.
# @@SKIP@@ Examples which translate the original Perl closely but which are
# @@SKIP@@ unPythonic are prefixed with a comment stating "DON'T DO THIS".
# @@SKIP@@ In some cases, it may be useful to know the techniques in these, 
# @@SKIP@@ though it's a bad solution for the specific problem.

# @@PLEAC@@_1.0
#-----------------------------
mystr = "\n"   # a newline character
mystr = r"\n"  # two characters, \ and n
#-----------------------------
mystr = "Jon 'Maddog' Orwant"  # literal single quote inside double quotes
mystr = 'Jon "Maddog" Orwant'  # literal double quote inside single quotes
#-----------------------------
mystr = 'Jon \'Maddog\' Orwant'  # escaped single quote
mystr = "Jon \"Maddog\" Orwant"  # escaped double quote
#-----------------------------
mystr = """
This is a multiline string literal
enclosed in triple double quotes.
"""
mystr = '''
And this is a multiline string literal
enclosed in triple single quotes.
'''
#-----------------------------

# @@PLEAC@@_1.1
#-----------------------------

# get a 5-char string, skip 3, then grab 2 8-char strings, then the rest
# Note that struct.unpack cannot use * for an unknown length.
# See http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/65224
import struct
(lead, s1, s2), tail = struct.unpack("5s 3x 8s 8s", data[:24]), data[24:]

# split at five-char boundaries
fivers = struct.unpack("5s" * (len(data)//5), data)
fivers = print [x[i*5:i*5+5] for i in range(len(x)/5)]

# chop string into individual characters
chars = list(data)
#-----------------------------
mystr = "This is what you have"
#       +012345678901234567890  Indexing forwards  (left to right)
#        109876543210987654321- Indexing backwards (right to left)
#         note that 0 means 10 or 20, etc. above

first = mystr[0]                            # "T"
start = mystr[5:7]                          # "is"
rest = mystr[13:]                           # "you have"
last = mystr[-1]                            # "e"
end = mystr[-4:]                            # "have"
piece = mystr[-8:-5]                        # "you"
#-----------------------------
# Python strings are immutable.
# In general, you should just do piecemeal reallocation:
mystr = "This is what you have"
mystr = mystr[:5] + "wasn't" + mystr[7:]

# Or replace and reallocate
mystr = "This is what you have"
mystr = mystr.replace(" is ", " wasn't ")

# DON'T DO THIS: In-place modification could be done using character arrays
import array
mystr = array.array("c", "This is what you have")
mystr[5:7] = array.array("c", "wasn't")
# mystr is now array('c', "This wasn't what you have")

# DON'T DO THIS: It could also be done using MutableString 
from UserString import MutableString
mystr = MutableString("This is what you have")
mystr[-12:] = "ondrous"
# mystr is now "This is wondrous"
#-----------------------------
# you can test simple substrings with "in" (for regex matching see ch.6):
if txt in mystr[-10:]:
    print "'%s' found in last 10 characters"%txt

# Or use the startswith() and endswith() string methods:
if mystr.startswith(txt):
    print "%s starts with %s."%(mystr, txt)
if mystr.endswith(txt):
    print "%s ends with %s."%(mystr, txt)

#-----------------------------

# @@PLEAC@@_1.2
#-----------------------------
# Introductory Note: quite a bit of this section is not terribly Pythonic
# as names must be set before being used. For instance, unless myvar has 
# been previously defined, these next lines will all raise NameError:
myvar = myvar or some_default
myvar2 = myvar or some_default
myvar |= some_default          # bitwise-or, not logical-or - for demo

# The standard way of setting a default is often:
myvar = default_value
if some_condition:
    pass                     # code which may set myvar to something else

# if myvar is returned from a function and may be empty/None, then use:
myvar = somefunc()
if not myvar:
    myvar = default_value

# If you want a default value that can be overridden by the person calling 
# your code, you can often wrap it in a function with a named parameter:
def myfunc(myvar="a"):
   return myvar + "b"
print myfunc(), myfunc("c")
#=> ab cb

# Note, though, that this won't work for mutable objects such as lists or
# dicts that are mutated in the function as the object is only created once 
# and repeated calls to the same function will return the same object.  This
# can be desired behaviour however - see section 10.3, for instance.
def myfunc(myvar=[]):
    myvar.append("x")
    return myvar
print myfunc(), myfunc()
#=> ['x'] ['x', 'x']

# You need to do:
def myfunc(myvar=None):
    if myvar is None:
        myvar = []
    myvar.append("x")
    return myvar
print myfunc(), myfunc()
#=> ['x'] ['x']

#=== Perl Equivalencies start here
# use b if b is true, otherwise use c
a = b or c

# as that is a little tricksy, the following may be preferred:
if b:
    a = b
else:
    a = c

# set x to y unless x is already true
if not x:
    x = y
#-----------------------------
# use b if b is defined, else c
try:
    a = b
except NameError:
    a = c
#-----------------------------
foo = bar or "DEFAULT VALUE"
#-----------------------------
# To get a user (for both UNIX and Windows), use:
import getpass
user = getpass.getuser()

# DON'T DO THIS: find the user name on Unix systems 
import os
user = os.environ.get("USER")
if user is None:
    user = os.environ.get("LOGNAME")
#-----------------------------
if not starting_point:
    starting_point = "Greenwich"
#-----------------------------
if not a:         # copy only if empty
    a = b

if b:             # assign b if nonempty, else c
    a = b
else:
    a = c
#-----------------------------

# @@PLEAC@@_1.3
#-----------------------------
v1, v2 = v2, v1
#-----------------------------
# DON'T DO THIS:
temp = a
a = b
b = temp
#-----------------------------
a = "alpha"
b = "omega"
a, b = b, a   # the first shall be last -- and versa vice 
#-----------------------------
alpha, beta, production = "January March August".split()
alpha, beta, production = beta, production, alpha
#-----------------------------

# @@PLEAC@@_1.4
#-----------------------------
num = ord(char)
char = chr(num)
#-----------------------------
char = "%c" % num
print "Number %d is character %c" % (num, num)
print "Number %(n)d is character %(n)c" % {"n": num}
print "Number %(num)d is character %(num)c" % locals()
#=> Number 101 is character e
#-----------------------------
ascii_character_numbers = [ord(c) for c in "sample"]
print ascii_character_numbers
#=> [115, 97, 109, 112, 108, 101]

word = "".join([chr(n) for n in ascii_character_numbers])
word = "".join([chr(n) for n in [115, 97, 109, 112, 108, 101]])
print word
#=> sample
#-----------------------------
hal = "HAL"
ibm = "".join([chr(ord(c)+1) for c in hal]) # add one to each ASCII value
print ibm   
#=> IBM
#-----------------------------

# @@PLEAC@@_1.5
#-----------------------------
mylist = list(mystr)
#-----------------------------
for char in mystr:
    pass # do something with char
#-----------------------------
mystr = "an apple a day"
uniq = sorted(set(mystr))
print "unique chars are: '%s'" % "".join(uniq)
#=> unique chars are: ' adelnpy'
#-----------------------------
ascvals = [ord(c) for c in mystr]
print "total is %s for '%s'."%(sum(ascvals), mystr)
#=> total is 1248 for 'an apple a day'.
#-----------------------------
# sysv checksum
def checksum(myfile):
    values = [ord(c) for line in myfile for c in line]
    return sum(values)%(2**16) - 1

import fileinput
print checksum(fileinput.input())   # data from sys.stdin

# Using a function means any iterable can be checksummed:
print checksum(open("C:/test.txt")  # data from file
print checksum("sometext")          # data from string
#-----------------------------
#!/usr/bin/python
# slowcat - emulate a   s l o w  line printer
# usage: slowcat [- DELAY] [files ...]
import sys, select
import re
DELAY = 1
if re.match("^-\d+$",sys.argv[1]):
    DELAY=-int(sys.argv[1])
    del sys.argv[1]
for ln in fileinput.input():
    for c in ln:
        sys.stdout.write(c)
        sys.stdout.flush()
        select.select([],[],[], 0.005 * DELAY)
#-----------------------------

# @@PLEAC@@_1.6
#-----------------------------
# 2.3+ only
revchars = mystr[::-1]  # extended slice - step is -1
revwords = " ".join(mystr.split(" ")[::-1])

# pre 2.3 version:
mylist = list(mystr)
mylist.reverse()
revbytes = "".join(mylist)

mylist = mystr.split()
mylist.reverse()
revwords = ' '.join(mylist)

# Alternative version using reversed():
revchars = "".join(reversed(mystr))
revwords = " ".join(reversed(mystr.split(" ")))

# reversed() makes an iterator, which means that the reversal
# happens as it is consumed.  This means that "print reversed(mystr)" is not
# the same as mystr[::-1].  Standard usage is:
for char in reversed(mystr):
   pass  # ... do something
#-----------------------------
# 2.3+ only
word = "reviver"
is_palindrome = (word == word[::-1])
#-----------------------------
# Generator version
def get_palindromes(fname):
    for line in open(fname):
        word = line.rstrip()
        if len(word) > 5 and word == word[::-1]:
            yield word
long_palindromes = list(get_palindromes("/usr/share/dict/words"))

# Simpler old-style version using 2.2 string reversal
def rev_string(mystr):
    mylist = list(mystr)
    mylist.reverse()
    return "".join(mylist)

long_palindromes=[]
for line in open("/usr/share/dict/words"):
    word = line.rstrip()
    if len(word) > 5 and word == rev_string(word):
        long_palindromes.append(word)
print long_palindromes
#-----------------------------

# @@PLEAC@@_1.7
#-----------------------------
mystr.expandtabs()
mystr.expandtabs(4)
#-----------------------------

# @@PLEAC@@_1.8
#-----------------------------
text = "I am %(rows)s high and %(cols)s long"%{"rows":24, "cols":80)
print text
#=> I am 24 high and 80 long

rows, cols = 24, 80
text = "I am %(rows)s high and %(cols)s long"%locals()
print text
#=> I am 24 high and 80 long
#-----------------------------
import re
print re.sub("\d+", lambda i: str(2 * int(i.group(0))), "I am 17 years old")
#=> I am 34 years old
#-----------------------------
# expand variables in text, but put an error message in
# if the variable isn't defined
class SafeDict(dict):
    def __getitem__(self, key):
        return self.get(key, "[No Variable: %s]"%key)
    
hi = "Hello"
text = "%(hi)s and %(bye)s!"%SafeDict(locals())
print text
#=> Hello and [No Variable: bye]!

#If you don't need a particular error message, just use the Template class:
from string import Template
x = Template("$hi and $bye!")
hi = "Hello"
print x.safe_substitute(locals())
#=> Hello and $bye!
print x.substitute(locals()) # will throw a KeyError

#-----------------------------

# @@PLEAC@@_1.9
#-----------------------------
mystr = "bo peep".upper()  # BO PEEP
mystr = mystr.lower()      # bo peep
mystr = mystr.capitalize() # Bo peep
#-----------------------------
beast = "python"
caprest = beast.capitalize().swapcase() # pYTHON
#-----------------------------
print "thIS is a loNG liNE".title()
#=> This Is A Long Line
#-----------------------------
if a.upper() == b.upper():
    print "a and b are the same"
#-----------------------------
import random
def randcase_one(letter):
    if random.randint(0,5):   # True on 1, 2, 3, 4
        return letter.lower()
    else:
        return letter.upper()

def randcase(myfile):
    for line in myfile:
        yield "".join(randcase_one(letter) for letter in line[:-1])

for line in randcase(myfile):
    print line
#-----------------------------

# @@PLEAC@@_1.10
#-----------------------------
"I have %d guanacos." % (n + 1)
print "I have", n+1, "guanacos."
#-----------------------------
#Python templates disallow in-string calculations (see PEP 292)
from string import Template

email_template = Template("""\
To: $address
From: Your Bank
CC: $cc_number
Date: $date

Dear $name,

Today you bounced check number $checknum to us.
Your account is now closed.

Sincerely,
the management
""")

import random
import datetime

person = {"address":"Joe@somewhere.com",
          "name": "Joe",
          "cc_number" : 1234567890,
          "checknum" : 500+random.randint(0,99)}

print email_template.substitute(person, date=datetime.date.today())
#-----------------------------

# @@PLEAC@@_1.11
#-----------------------------
# indenting here documents
#
# in python multiline strings can be used as here documents
var = """
      your text
      goes here
      """

# using regular expressions
import re
re_leading_blanks = re.compile("^\s+",re.MULTILINE)
var1 = re_leading_blanks.sub("",var)[:-1]

# using string methods 
# split into lines, use every line except first and last, left strip and rejoin.
var2 = "\n".join([line.lstrip() for line in var.split("\n")[1:-1]])

poem = """
       Here's your poem:
       Now far ahead the Road has gone,
          And I must follow, if I can,
       Pursuing it with eager feet,
          Until it joins some larger way
       Where many paths and errand meet.
          And whither then? I cannot say.
               --Bilbo in /usr/src/perl/pp_ctl.c  
       """

import textwrap
print textwrap.dedent(poem)[1:-1]
#-----------------------------
    

# @@PLEAC@@_1.12
#-----------------------------
from textwrap import wrap 
output = wrap(para,
              initial_indent=leadtab
              subsequent_indent=nexttab)
#-----------------------------
#!/usr/bin/env python
# wrapdemo - show how textwrap works

txt = """\
Folding and splicing is the work of an editor,
not a mere collection of silicon
and
mobile electrons!
"""

from textwrap import TextWrapper

wrapper = TextWrapper(width=20,
                      initial_indent=" "*4,
                      subsequent_indent=" "*2)

print "0123456789" * 2
print wrapper.fill(txt)

#-----------------------------
"""Expected result:

01234567890123456789
    Folding and
  splicing is the
  work of an editor,
  not a mere
  collection of
  silicon and mobile
  electrons!
"""

#-----------------------------
# merge multiple lines into one, then wrap one long line

from textwrap import fill
import fileinput

print fill("".join(fileinput.input()))

#-----------------------------
# Term::ReadKey::GetTerminalSize() isn't in the Perl standard library. 
# It isn't in the Python standard library either. Michael Hudson's 
# recipe from python-list #530228 is shown here.
# (http://aspn.activestate.com/ASPN/Mail/Message/python-list/530228)
# Be aware that this will work on Unix but not on Windows.

from termwrap import wrap
import struct, fcntl
def getheightwidth():
    height, width = struct.unpack(
        "hhhh", fcntl.ioctl(0, TERMIOS.TIOCGWINSZ ,"\000"*8))[0:2]
    return height, width

# PERL <>, $/, $\ emulation
import fileinput
import re

_, width = getheightwidth()
for para in re.split(r"\n{2,}", "".join(fileinput.input())):
    print fill(para, width)


# @@PLEAC@@_1.13
#-----------------------------
mystr = '''Mom said, "Don't do that."'''  #"
re.sub("['\"]", lambda i: "\\" + i.group(0), mystr)
re.sub("[A-Z]", lambda i: "\\" + i.group(0), mystr)
re.sub("\W", lambda i: "\\" + i.group(0), "is a test!") # no function like quotemeta?


# @@PLEAC@@_1.14
#-----------------------------
mystr = mystr.lstrip() # left
mystr = mystr.rstrip() # right
mystr = mystr.strip()  # both ends


# @@PLEAC@@_1.15
#-----------------------------
import csv
def parse_csv(line):
    reader = csv.reader([line], escapechar='\\')
    return reader.next()

line = '''XYZZY,"","O'Reilly, Inc","Wall, Larry","a \\"glug\\" bit,",5,"Error, Core Dumped,",''' #"

fields = parse_csv(line)

for i, field in enumerate(fields):
    print "%d : %s" % (i, field)

# pre-2.3 version of parse_csv
import re
def parse_csv(text):
    pattern = re.compile('''"([^"\\\]*(?:\\\.[^"\\\]*)*)",?|([^,]+),?|,''')
    mylist = ["".join(elem) 
              for elem in re.findall(pattern, text)]
    if text[-1] == ",": 
        mylist += ['']
    return mylist

# cvs.reader is meant to work for many lines, something like:
# (NB: in Python default, quotechar is *not* escaped by backslash,
#      but doubled instead. That's what Excel does.)
for fields in cvs.reader(lines, dialect="some"):
    for num, field in enumerate(fields):
        print num, ":", field
#-----------------------------

# @@PLEAC@@_1.16
#-----------------------------
def soundex(name, len=4):
    """ soundex module conforming to Knuth's algorithm
        implementation 2000-12-24 by Gregory Jorgensen
        public domain
    """

    # digits holds the soundex values for the alphabet
    digits = '01230120022455012623010202'
    sndx = ''
    fc = ''

    # translate alpha chars in name to soundex digits
    for c in name.upper():
        if c.isalpha():
            if not fc: 
                fc = c   # remember first letter
            d = digits[ord(c)-ord('A')]
            # duplicate consecutive soundex digits are skipped
            if not sndx or (d != sndx[-1]):
                sndx += d

    # replace first digit with first alpha character
    sndx = fc + sndx[1:]

    # remove all 0s from the soundex code
    sndx = sndx.replace('0','')

    # return soundex code padded to len characters
    return (sndx + (len * '0'))[:len]

user = raw_input("Lookup user: ")
if user == "":
    raise SystemExit

name_code = soundex(user)
for line in open("/etc/passwd"):
    line = line.split(":")
    for piece in line[4].split():
        if name_code == soundex(piece):
            print "%s: %s\n" % line[0], line[4])
#-----------------------------

# @@PLEAC@@_1.17
#-----------------------------
import sys, fileinput, re

data = """\
analysed        => analyzed
built-in        => builtin
chastized       => chastised
commandline     => command-line
de-allocate     => deallocate
dropin          => drop-in
hardcode        => hard-code
meta-data       => metadata
multicharacter  => multi-character
multiway        => multi-way
non-empty       => nonempty
non-profit      => nonprofit
non-trappable   => nontrappable
pre-define      => predefine
preextend       => pre-extend
re-compiling    => recompiling
reenter         => re-enter
turnkey         => turn-key
"""
mydict = {}
for line in data.split("\n"):
    if not line.strip():
        continue
    k, v = [word.strip() for word in line.split("=>")]
    mydict[k] = v
pattern_text = "(" + "|".join([re.escape(word) for word in mydict.keys()]) + ")"
pattern = re.compile(pattern_text)

args = sys.argv[1:]
verbose = 0
if args and args[0] == "-v":
    verbose = 1
    args = args[1:]

if not args:
    sys.stderr.write("%s: Reading from stdin\n" % sys.argv[0])

for line in fileinput.input(args, inplace=1, backup=".orig"):
    output = ""
    pos = 0
    while True:
        match = pattern.search(line, pos)
        if not match:
            output += line[pos:]
            break
        output += line[pos:match.start(0)] + mydict[match.group(1)]
        pos = match.end(0)
    sys.stdout.write(output)
#-----------------------------

# @@PLEAC@@_1.18
#-----------------------------
#!/usr/bin/python
# psgrep - print selected lines of ps output by
#          compiling user queries into code.
#
# examples :
# psgrep "uid<10"
import sys, os, re

class PsLineMatch:
    # each field from the PS header
    fieldnames = ("flags","uid","pid","ppid","pri","nice","size", \
                  "rss","wchan","stat","tty","time","command")
    numeric_fields = ("flags","uid","pid","ppid","pri","nice","size","rss")
    def __init__(self):
        self._fields = {}

    def new_line(self, ln):
        self._ln = ln.rstrip()
        # ps header for option "wwaxl" (different than in the perl code)
        """
          F   UID   PID  PPID PRI  NI   VSZ  RSS WCHAN  STAT TTY        TIME COMMAND"
        004     0     1     0  15   0   448  236 schedu S    ?          0:07 init"
        .   .     .     .     .   .   .     .    .      .    .    .          .
        """
        # because only the last entry might contain blanks, splitting
        # is safe
        data = self._ln.split(None,12)
        for fn, elem in zip(self.fieldnames, data):
            if fn in self.numeric_fields:  # make numbers integer 
                self._fields[fn] = int(elem)
            else:
                self._fields[fn] = elem

    def set_query(self, args):
        # assume args: "uid==500", "command ~ ^wm"
        conds=[]
        m = re.compile("(\w+)([=<>]+)(.+)")
        for a in args:
            try:
                (field,op,val) = m.match(a).groups()
            except:
                print "can't understand query \"%s\"" % (a)
                raise SystemExit
            if field in self.numeric_fields:
                conds.append(a)
            else:
                conds.append("%s%s'%s'",(field,op,val))
        self._desirable = compile("(("+")and(".join(conds)+"))", "<string>","eval")

    def is_desirable(self):
        return eval(self._desirable, {}, self._fields)

    def __str__(self):
        # to allow "print".
        return self._ln

if len(sys.argv)<=1:
    print """usage: %s criterion ...
    Each criterion is a Perl expression involving: 
    %s
    All criteria must be met for a line to be printed.""" \
    % (sys.argv[0], " ".join(PsLineMatch().fieldnames))
    raise SystemExit

psln = PsLineMatch()
psln.set_query(sys.argv[1:])
p = os.popen("ps wwaxl")
print p.readline()[:-1]        # emit header line
for ln in p.readlines():
    psln.new_line(ln)
    if psln.is_desirable():
        print psln
p.close()

# alternatively one could consider every argument being a string and
# support wildcards: "uid==500" "command~^wm" by means of re, but this
# does not show dynamic python code generation, although re.compile
# also precompiles.
#-----------------------------


# @@PLEAC@@_2.1
#-----------------------------
# The standard way of validating numbers is to convert them and catch
# an exception on failure

try:
    myfloat = float(mystr)
    print "is a decimal number" 
except TypeError:
    print "is not a decimal number"

try:
    myint = int(mystr)
    print "is an integer"
except TypeError:
    print "is not an integer"

# DON'T DO THIS. Explicit checking is prone to errors:
if mystr.isdigit():                         # Fails on "+4"
    print 'is a positive integer'   
else:
    print 'is not'

if re.match("[+-]?\d+$", mystr):            # Fails on "- 1" 
    print 'is an integer'           
else:
    print 'is not'

if re.match("-?(?:\d+(?:\.\d*)?|\.\d+)$", mystr):  # Opaque, and fails on "- 1"
    print 'is a decimal number'
else:
    print 'is not'

#-----------------------------

# @@PLEAC@@_2.2
#-----------------------------
# equal(num1, num2, accuracy) : returns true if num1 and num2 are
#   equal to accuracy number of decimal places

def equal(num1, num2, accuracy):
    return abs(num1 - num2) < 10**(-accuracy)
#-----------------------------
from __future__ import division  # use / for float div and // for int div

wage = 536                                      # $5.36/hour
week = 40 * wage                                # $214.40
print "One week's wage is: $%.2f" % (week/100)
#=> One week's wage is: $214.40
#-----------------------------

# @@PLEAC@@_2.3
#-----------------------------
rounded = round(num)            # rounds to integer
#-----------------------------
a = 0.255
b = "%.2f" % a
print "Unrounded: %f\nRounded: %s" % (a, b)
print "Unrounded: %f\nRounded: %.2f" % (a, a)
#=> Unrounded: 0.255000
#=> Rounded: 0.26
#=> Unrounded: 0.255000
#=> Rounded: 0.26
#-----------------------------
from math import floor, ceil

print "number\tint\tfloor\tceil"
a = [3.3, 3.5, 3.7, -3.3]
for n in a:
    print "% .1f\t% .1f\t% .1f\t% .1f" % (n, int(n), floor(n), ceil(n))
#=> number  int   floor ceil
#=>  3.3     3.0   3.0   4.0
#=>  3.5     3.0   3.0   4.0
#=>  3.7     3.0   3.0   4.0
#=> -3.3    -3.0  -4.0  -3.0
#-----------------------------

# @@PLEAC@@_2.4
#-----------------------------
# To convert a string in any base up to base 36, use the optional arg to int():
num = int('0110110', 2)   # num is 54

# To convert an int to an string representation in another base, you could use
# <http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/111286>:
import baseconvert 
def dec2bin(i):
    return baseconvert.baseconvert(i, baseconvert.BASE10, baseconvert.BASE2)

binstr = dec2bin(54)      # binstr is 110110
#-----------------------------

# @@PLEAC@@_2.5
#-----------------------------
for i in range(x,y):
    pass # i is set to every integer from x to y, excluding y

for i in range(x, y, 7):
    pass # i is set to every integer from x to y, stepsize = 7

print "Infancy is:",
for i in range(0,3):
    print i,
print

print "Toddling is:",
for i in range(3,5):
    print i,
print

# DON'T DO THIS:
print "Childhood is:",
i = 5
while i <= 12:
    print i
    i += 1

#=> Infancy is: 0 1 2
#=> Toddling is: 3 4
#=> Childhood is: 5 6 7 8 9 10 11 12
#-----------------------------

# @@PLEAC@@_2.6
#-----------------------------
# See http://www.faqts.com/knowledge_base/view.phtml/aid/4442
# for a module that does this
#-----------------------------

# @@PLEAC@@_2.7
#-----------------------------
import random          # use help(random) to see the (large) list of funcs

rand = random.randint(x, y)
#-----------------------------
rand = random.randint(25, 76)
print rand
#-----------------------------
elt = random.choice(mylist)
#-----------------------------
import string
chars = string.letters + string.digits + "!@$%^&*"
password = "".join([random.choice(chars) for i in range(8)])
#-----------------------------

# @@PLEAC@@_2.8
#-----------------------------
# Changes the default RNG
random.seed()

# Or you can create independent RNGs
gen1 = random.Random(6)
gen2 = random.Random(6)
gen3 = random.Random(10)
a1, b1 = gen1.random(), gen1.random()
a2, b2 = gen2.random(), gen2.random()
a3, b3 = gen3.random(), gen3.random()
# a1 == a2 and b1 == b2
#-----------------------------

# @@PLEAC@@_2.9
#-----------------------------
# see http://www.sbc.su.se/~per/crng/ or http://www.frohne.westhost.com/rv11reference.htm
#-----------------------------

# @@PLEAC@@_2.10
#-----------------------------
import random
mean = 25
sdev = 2
salary = random.gauss(mean, sdev)
print "You have been hired at %.2f" % salary
#-----------------------------

# @@PLEAC@@_2.11
#-----------------------------
radians = math.radians(degrees)
degrees = math.degrees(radians)

# pre-2.3:
from __future__ import division
import math
def deg2rad(degrees):
    return (degrees / 180) * math.pi
def rad2deg(radians):
    return (radians / math.pi) * 180
#-----------------------------
# Use deg2rad instead of math.radians if you have pre-2.3 Python.
import math
def degree_sine(degrees):
    radians = math.radians(degrees)
    return math.sin(radians)
#-----------------------------

# @@PLEAC@@_2.12
#-----------------------------
import math

# DON'T DO THIS.  Use math.tan() instead.
def tan(theta):
    return math.sin(theta) / math.cos(theta)
#----------------
# NOTE: this sets y to 16331239353195370.0
try:
  y = math.tan(math.pi/2)
except ValueError:
  y = None
#-----------------------------

# @@PLEAC@@_2.13
#-----------------------------
import math
log_e = math.log(VALUE)
#-----------------------------
log_10 = math.log10(VALUE)
#-----------------------------
def log_base(base, value):
    return math.log(value) / math.log(base)
#-----------------------------
# log_base defined as above
answer = log_base(10, 10000)
print "log10(10,000) =", answer
#=> log10(10,000) = 4.0
#-----------------------------

# @@PLEAC@@_2.14
#-----------------------------
# NOTE: must have NumPy installed.  See
#   http://www.pfdubois.com/numpy/

import Numeric
a = Numeric.array( ((3, 2, 3),
                    (5, 9, 8) ), "d")
b = Numeric.array( ((4, 7),
                    (9, 3),
                    (8, 1) ), "d")
c = Numeric.matrixmultiply(a, b)

print c
#=> [[  54.   30.]
#=>  [ 165.   70.]]

print a.shape, b.shape, c.shape
#=> (2, 3) (3, 2) (2, 2)
#-----------------------------

# @@PLEAC@@_2.15
#-----------------------------
a = 3+5j
b = 2-2j
c = a * b
print "c =", c
#=> c = (16+4j)

print c.real, c.imag, c.conjugate()
#=> 16.0 4.0 (16-4j)
#-----------------------------
import cmath
print cmath.sqrt(3+4j)
#=> (2+1j)
#-----------------------------

# @@PLEAC@@_2.16
#-----------------------------
number = int(hexadecimal, 16)
number = int(octal, 8)
s = hex(number)
s = oct(number)

num = raw_input("Gimme a number in decimal, octal, or hex: ").rstrip()
if num.startswith("0x"):
    num = int(num[2:], 16)
elif num.startswith("0"):
    num = int(num[1:], 8)
else:
    num = int(num)
print "%(num)d %(num)x %(num)o\n" % { "num": num }
#-----------------------------


# @@PLEAC@@_2.17
#-----------------------------
def commify(amount):
    amount = str(amount)
    firstcomma = len(amount)%3 or 3  # set to 3 if would make a leading comma
    first, rest = amount[:firstcomma], amount[firstcomma:]
    segments = [first] + [rest[i:i+3] for i in range(0, len(rest), 3)]
    return ",".join(segments)

print commify(12345678) 
#=> 12,345,678

# DON'T DO THIS. It works on 2.3+ only and is slower and less straightforward
# than the non-regex version above.
import re
def commify(amount):
    amount = str(amount)
    amount = amount[::-1]
    amount = re.sub(r"(\d\d\d)(?=\d)(?!\d*\.)", r"\1,", amount)
    return amount[::-1]

# @@PLEAC@@_2.18
# Printing Correct Plurals
#-----------------------------
def pluralise(value, root, singular="", plural="s"):
    if value == 1:
        return root + singular
    else:
        return root + plural

print "It took", duration, pluralise(duration, 'hour')

print "%d %s %s enough." % (duration, 
                            pluralise(duration, 'hour'), 
                            pluralise(duration, '', 'is', 'are'))
#-----------------------------
import re
def noun_plural(word):
    endings = [("ss", "sses"),
               ("([psc]h)", r"\1es"),
               ("z", "zes"),
               ("ff", "ffs"),
               ("f", "ves"),
               ("ey", "eys"),
               ("y", "ies"),
               ("ix", "ices"),
               ("([sx])", r"\1es"),
               ("", "s")]
    for singular, plural in endings:
        ret, found = re.subn("%s$"%singular, plural, word)
        if found:
            return ret
    
verb_singular = noun_plural;       # make function alias
#-----------------------------

# @@PLEAC@@_2.19
# Program: Calculating Prime Factors
#-----------------------------
#% bigfact 8 9 96 2178
#8          2**3
#
#9          3**2
#
#96         2**5 3
#
#2178       2 3**2 11**2
#-----------------------------
#% bigfact 239322000000000000000000
#239322000000000000000000 2**19 3 5**18 39887 
#
#
#% bigfact 25000000000000000000000000
#25000000000000000000000000 2**24 5**26
#-----------------------------
import sys

def factorise(num):
    factors = {}
    orig = num
    print num, '\t',

    # we take advantage of the fact that (i +1)**2 = i**2 + 2*i +1
    i, sqi = 2, 4
    while sqi <= num:
        while not num%i:
            num /= i
            factors[i] = factors.get(i, 0) + 1

        sqi += 2*i + 1
        i += 1

    if num != 1 and num != orig:
        factors[num] = factors.get(num, 0) + 1

    if not factors:
        print "PRIME"

    for factor in sorted(factors):
        if factor:
            tmp = str(factor)
            if factors[factor]>1: tmp += "**" + str(factors[factor])
            print tmp,
    print
    
#--------
if __name__ == '__main__':
    if len(sys.argv) == 1:
        print "Usage:", sys.argv[0], " number [number, ]"
    else:
        for strnum in sys.argv[1:]:
            try:
                num = int(strnum)
                factorise(num)
            except ValueError:
                print strnum, "is not an integer"
#-----------------------------
# A more Pythonic variant (which separates calculation from printing):
def format_factor(base, exponent):
    if exponent > 1:
        return "%s**%s"%(base, exponent)
    return str(base)

def factorise(num):
    factors = {}
    orig = num

    # we take advantage of the fact that (i+1)**2 = i**2 + 2*i +1
    i, sqi = 2, 4
    while sqi <= num:
        while not num%i:
            num /= i
            factors[i] = factors.get(i, 0) + 1
        sqi += 2*i + 1
        i += 1

    if num not in (1, orig):
        factors[num] = factors.get(num, 0) + 1

    if not factors:
        return ["PRIME"]

    out = [format_factor(base, exponent)
           for base, exponent in sorted(factors.items())]
    return out

def print_factors(value):
    try:
        num = int(value)
        if num != float(value):
            raise ValueError
    except (ValueError, TypeError):
        raise ValueError("Can only factorise an integer")
    factors = factorise(num) 
    print num, "\t", " ".join(factors)

# @@PLEAC@@_3.0
#----------------------------- 
#introduction
# There are three common ways of manipulating dates in Python
# mxDateTime - a popular third-party module (not discussed here) 
# time - a fairly low-level standard library module 
# datetime - a new library module for Python 2.3 and used for most of these samples 
# (I will use full names to show which module they are in, but you can also use
# from datetime import datetime, timedelta and so on for convenience) 

import time
import datetime

print "Today is day", time.localtime()[7], "of the current year" 
# Today is day 218 of the current year

today = datetime.date.today()
print "Today is day", today.timetuple()[7], "of ", today.year
# Today is day 218 of 2003

print "Today is day", today.strftime("%j"), "of the current year" 
# Today is day 218 of the current year
 

# @@PLEAC@@_3.1
#----------------------------- 
# Finding todays date

today = datetime.date.today()
print "The date is", today 
#=> The date is 2003-08-06

# the function strftime() (string-format time) produces nice formatting
# All codes are detailed at http://www.python.org/doc/current/lib/module-time.html
print t.strftime("four-digit year: %Y, two-digit year: %y, month: %m, day: %d") 
#=> four-digit year: 2003, two-digit year: 03, month: 08, day: 06


# @@PLEAC@@_3.2
#----------------------------- 
# Converting DMYHMS to Epoch Seconds
# To work with Epoch Seconds, you need to use the time module

# For the local timezone
t = datetime.datetime.now()
print "Epoch Seconds:", time.mktime(t.timetuple())
#=> Epoch Seconds: 1060199000.0

# For UTC
t = datetime.datetime.utcnow()
print "Epoch Seconds:", time.mktime(t.timetuple())
#=> Epoch Seconds: 1060195503.0


# @@PLEAC@@_3.3
#----------------------------- 
# Converting Epoch Seconds to DMYHMS

now = datetime.datetime.fromtimestamp(EpochSeconds)
#or use datetime.datetime.utcfromtimestamp()
print now
#=> datetime.datetime(2003, 8, 6, 20, 43, 20)
print now.ctime()
#=> Wed Aug  6 20:43:20 2003

# or with the time module
oldtimetuple = time.localtime(EpochSeconds)
# oldtimetuple contains (year, month, day, hour, minute, second, weekday, yearday, daylightSavingAdjustment) 
print oldtimetuple 
#=> (2003, 8, 6, 20, 43, 20, 2, 218, 1)


# @@PLEAC@@_3.4
#----------------------------- 
# Adding to or Subtracting from a Date
# Use the rather nice datetime.timedelta objects

now = datetime.date(2003, 8, 6)
difference1 = datetime.timedelta(days=1)
difference2 = datetime.timedelta(weeks=-2)

print "One day in the future is:", now + difference1
#=> One day in the future is: 2003-08-07

print "Two weeks in the past is:", now + difference2
#=> Two weeks in the past is: 2003-07-23

print datetime.date(2003, 8, 6) - datetime.date(2000, 8, 6)
#=> 1095 days, 0:00:00

#----------------------------- 
birthtime = datetime.datetime(1973, 01, 18, 3, 45, 50)   # 1973-01-18 03:45:50

interval = datetime.timedelta(seconds=5, minutes=17, hours=2, days=55) 
then = birthtime + interval

print "Then is", then.ctime()
#=> Then is Wed Mar 14 06:02:55 1973

print "Then is", then.strftime("%A %B %d %I:%M:%S %p %Y")
#=> Then is Wednesday March 14 06:02:55 AM 1973

#-----------------------------
when = datetime.datetime(1973, 1, 18) + datetime.timedelta(days=55) 
print "Nat was 55 days old on:", when.strftime("%m/%d/%Y").lstrip("0")
#=> Nat was 55 days old on: 3/14/1973


# @@PLEAC@@_3.5
#----------------------------- 
# Dates produce timedeltas when subtracted.

diff = date2 - date1
diff = datetime.date(year1, month1, day1) - datetime.date(year2, month2, day2)
#----------------------------- 

bree = datetime.datetime(1981, 6, 16, 4, 35, 25)
nat  = datetime.datetime(1973, 1, 18, 3, 45, 50)

difference = bree - nat
print "There were", difference, "minutes between Nat and Bree"
#=> There were 3071 days, 0:49:35 between Nat and Bree

weeks, days = divmod(difference.days, 7)

minutes, seconds = divmod(difference.seconds, 60)
hours, minutes = divmod(minutes, 60)

print "%d weeks, %d days, %d:%d:%d" % (weeks, days, hours, minutes, seconds)
#=> 438 weeks, 5 days, 0:49:35

#----------------------------- 
print "There were", difference.days, "days between Bree and Nat." 
#=> There were 3071 days between bree and nat


# @@PLEAC@@_3.6
#----------------------------- 
# Day in a Week/Month/Year or Week Number

when = datetime.date(1981, 6, 16)

print "16/6/1981 was:"
print when.strftime("Day %w of the week (a %A). Day %d of the month (%B).")
print when.strftime("Day %j of the year (%Y), in week %W of the year.")

#=> 16/6/1981 was:
#=> Day 2 of the week (a Tuesday). Day 16 of the month (June).
#=> Day 167 of the year (1981), in week 24 of the year.


# @@PLEAC@@_3.7
#----------------------------- 
# Parsing Dates and Times from Strings

time.strptime("Tue Jun 16 20:18:03 1981")
# (1981, 6, 16, 20, 18, 3, 1, 167, -1)

time.strptime("16/6/1981", "%d/%m/%Y")
# (1981, 6, 16, 0, 0, 0, 1, 167, -1)
# strptime() can use any of the formatting codes from time.strftime()

# The easiest way to convert this to a datetime seems to be; 
now = datetime.datetime(*time.strptime("16/6/1981", "%d/%m/%Y")[0:5])
# the '*' operator unpacks the tuple, producing the argument list.


# @@PLEAC@@_3.8
#----------------------------- 
# Printing a Date
# Use datetime.strftime() - see helpfiles in distro or at python.org

print datetime.datetime.now().strftime("The date is %A (%a) %d/%m/%Y") 
#=> The date is Friday (Fri) 08/08/2003

# @@PLEAC@@_3.9
#----------------------------- 
# High Resolution Timers

t1 = time.clock()
# Do Stuff Here
t2 = time.clock()
print t2 - t1

# 2.27236813618
# Accuracy will depend on platform and OS,
# but time.clock() uses the most accurate timer it can

time.clock(); time.clock()
# 174485.51365466841
# 174485.55702610247

#----------------------------- 
# Also useful;
import timeit
code = '[x for x in range(10) if x % 2 == 0]'
eval(code)
# [0, 2, 4, 6, 8]

t = timeit.Timer(code)
print "10,000 repeats of that code takes:", t.timeit(10000), "seconds" 
print "1,000,000 repeats of that code takes:", t.timeit(), "seconds"

# 10,000 repeats of that code takes: 0.128238644856 seconds
# 1,000,000 repeats of that code takes:  12.5396490336 seconds

#----------------------------- 
import timeit
code = 'import random; l = random.sample(xrange(10000000), 1000); l.sort()' 
t = timeit.Timer(code)

print "Create a list of a thousand random numbers. Sort the list. Repeated a thousand times." 
print "Average Time:", t.timeit(1000) / 1000
# Time taken: 5.24391507859


# @@PLEAC@@_3.10
#----------------------------- 
# Short Sleeps

seconds = 3.1
time.sleep(seconds)
print "boo"

# @@PLEAC@@_3.11
#----------------------------- 
# Program HopDelta
# Save a raw email to disk and run "python hopdelta.py FILE"
# and it will process the headers and show the time taken
# for each server hop (nb: if server times are wrong, negative dates
# might appear in the output).

import datetime, email, email.Utils
import os, sys, time

def extract_date(hop):
    # According to RFC822, the date will be prefixed with
    # a semi-colon, and is the last part of a received
    # header.
    date_string = hop[hop.find(';')+2:]
    date_string = date_string.strip()
    time_tuple = email.Utils.parsedate(date_string)

    # convert time_tuple to datetime
    EpochSeconds = time.mktime(time_tuple) 
    dt = datetime.datetime.fromtimestamp(EpochSeconds)
    return dt

def process(filename):
    # Main email file processing
    # read the headers and process them
    f = file(filename, 'rb')
    msg = email.message_from_file(f)

    hops = msg.get_all('received')
    
    # in reverse order, get the server(s) and date/time involved
    hops.reverse()
    results = []
    for hop in hops:
        hop = hop.lower()
        
        if hop.startswith('by'):  # 'Received: by' line
            sender = "start"
            receiver = hop[3:hop.find(' ',3)]
            date = extract_date(hop)

        else:  # 'Received: from' line
            sender = hop[5:hop.find(' ',5)]
            by = hop.find('by ')+3
            receiver = hop[by:hop.find(' ', by)]
            date = extract_date(hop)

        results.append((sender, receiver, date))
    output(results)

def output(results):
    print "Sender, Recipient, Time, Delta"
    print
    previous_dt = delta = 0
    for (sender, receiver, date) in results:
        if previous_dt:
            delta = date - previous_dt
        
        print "%s, %s, %s, %s" % (sender,
                               receiver,
                               date.strftime("%Y/%d/%m %H:%M:%S"),
                               delta)
        print
        previous_dt = date   
            
def main():
    # Perform some basic argument checking
    if len(sys.argv) != 2:
        print "Usage: mailhop.py FILENAME"

    else:
        filename = sys.argv[1]
        if os.path.isfile(filename):
            process(filename)
        else:
            print filename, "doesn't seem to be a valid file."

if __name__ == '__main__':
    main()


# @@PLEAC@@_4.0
#-----------------------------
# Python does not automatically flatten lists, in other words
# in the following, non-nested contains four elements and
# nested contains three elements, the third element of which
# is itself a list containing two elements:
non_nested = ["this", "that", "the", "other"]
nested = ["this", "that", ["the", "other"]]
#-----------------------------
tune = ["The", "Star-Spangled", "Banner"]
#-----------------------------

# @@PLEAC@@_4.1
#-----------------------------
a = ["quick", "brown", "fox"]
a = "Why are you teasing me?".split()

text = """
    The boy stood on the burning deck,
    It was as hot as glass.
"""
lines = [line.lstrip() for line in text.strip().split("\n")]
#-----------------------------
biglist = [line.rstrip() for line in open("mydatafile")]
#-----------------------------
banner = "The Mines of Moria"
banner = 'The Mines of Moria'
#-----------------------------
name = "Gandalf"
banner = "Speak, " + name + ", and enter!"
banner = "Speak, %s, and welcome!" % name
#-----------------------------
his_host = "www.python.org"
import os
host_info = os.popen("nslookup " + his_host).read()

# NOTE: not really relevant to Python (no magic '$$' variable)
python_info = os.popen("ps %d" % os.getpid()).read()
shell_info = os.popen("ps $$").read()
#-----------------------------
# NOTE: not really relevant to Python (no automatic interpolation)
banner = ["Costs", "only", "$4.95"]
banner = "Costs only $4.95".split()
#-----------------------------
brax = """ ' " ( ) < > { } [ ] """.split()            #"""
brax = list("""'"()<>{}[]""")                         #"""
rings = '''They're  "Nenya Narya Vilya"'''.split()    #'''
tags   = 'LI TABLE TR TD A IMG H1 P'.split()
sample = r'The backslash (\) is often used in regular expressions.'.split()

#-----------------------------
banner = "The backslash (\\) is often used in regular expressions.".split()
#-----------------------------
ships = u"Niña Pinta Santa María".split()          # WRONG (only three ships)
ships = [u"Niña", u"Pinta", u"Santa María"]        # right
#-----------------------------

# @@PLEAC@@_4.2
#-----------------------------
def commify_series(args):
    n = len(args)
    if n == 0: 
        return ""
    elif n == 1: 
        return args[0]
    elif n == 2: 
        return args[0] + " and " + args[1]
    return ", ".join(args[:-1]) + ", and " + args[-1]

commify_series([])
commify_series(["red"])
commify_series(["red", "yellow"])
commify_series(["red", "yellow", "green"])
#-----------------------------
mylist = ["red", "yellow", "green"]
print "I have", mylist, "marbles."
print "I have", " ".join(mylist), "marbles."
#=> I have ['red', 'yellow', 'green'] marbles.
#=> I have red yellow green marbles.

#-----------------------------
#!/usr/bin/env python
# commify_series - show proper comma insertion in list output
data = (
    ( 'just one thing', ),
    ( 'Mutt Jeff'.split() ),
    ( 'Peter Paul Mary'.split() ),
    ( 'To our parents', 'Mother Theresa', 'God' ),
    ( 'pastrami', 'ham and cheese', 'peanut butter and jelly', 'tuna' ),
    ( 'recycle tired, old phrases', 'ponder big, happy thoughts' ),
    ( 'recycle tired, old phrases',
      'ponder big, happy thoughts',
      'sleep and dream peacefully' ),
    )

def commify_series(terms):
    for term in terms:
        if "," in term:
            sepchar = "; "
            break
    else:
        sepchar = ", "

    n = len(terms)
    if n == 0: 
        return ""
    elif n == 1:
        return terms[0]
    elif n == 2:
        return " and ".join(terms)
    return "%s%sand %s" % (sepchar.join(terms[:-1]), sepchar, terms[-1])

for item in data:
    print "The list is: %s." % commify_series(item)

#=> The list is: just one thing.
#=> The list is: Mutt and Jeff.
#=> The list is: Peter, Paul, and Mary.
#=> The list is: To our parents, Mother Theresa, and God.
#=> The list is: pastrami, ham and cheese, peanut butter and jelly, and tuna.
#=> The list is: recycle tired, old phrases and ponder big, happy thoughts.
#=> The list is: recycle tired, old phrases; ponder big, happy thoughts; and
#   sleep and dream peacefully.
#-----------------------------

# @@PLEAC@@_4.3
#-----------------------------
# Python allocates more space than is necessary every time a list needs to
# grow and only shrinks lists when more than half the available space is
# unused.  This means that adding or removing an element will in most cases
# not force a reallocation.

del mylist[size:]         # shrink mylist
mylist += [None] * size   # grow mylist by appending 'size' None elements

# To add an element to the end of a list, use the append method:
mylist.append(4)

# To insert an element, use the insert method:
mylist.insert(0, 10) # Insert 10 at the beginning of the list

# To extend one list with the contents of another, use the extend method:
list2 = [1,2,3]
mylist.extend(list2)

# To insert the contents of one list into another, overwriting zero or 
# more elements, specify a slice:
mylist[1:1] = list2   # Don't overwrite anything; grow mylist if needed
mylist[2:3] = list2   # Overwrite mylist[2] and grow mylist if needed

# To remove one element from the middle of a list:
# To remove elements from the middle of a list:
del mylist[idx1:idx2]  # 0 or more
x = mylist.pop(idx)    # remove mylist[idx] and assign it to x

# You cannot assign to or get a non-existent element:
# >>> x = []
# >>> x[4] = 5
#
# Traceback (most recent call last):
#   File "<pyshell#1>", line 1, in -toplevel-
#     x[4] = 5
# IndexError: list assignment index out of range
#
# >>> print x[1000]
#
# Traceback (most recent call last):
#  File "<pyshell#16>", line 1, in -toplevel-
#    print x[1000]
# IndexError: list index out of range
#-----------------------------
def what_about_that_list(terms):
    print "The list now has", len(terms), "elements."
    print "The index of the last element is", len(terms)-1, "(or -1)."
    print "Element #3 is %s." % terms[3]

people = "Crosby Stills Nash Young".split()
what_about_that_list(people)
#-----------------------------
#=> The list now has 4 elements.
#=> The index of the last element is 3 (or -1).
#=> Element #3 is Young.
#-----------------------------
people.pop()
what_about_that_list(people)
#-----------------------------
people += [None] * (10000 - len(people))
#-----------------------------
#>>> people += [None] * (10000 - len(people))
#>>> what_about_that_list(people)
#The list now has 10000 elements.
#The index of the last element is 9999 (or -1).
#Element #3 is None.
#-----------------------------

# @@PLEAC@@_4.4
#-----------------------------
for item in mylist:
    pass # do something with item
#-----------------------------
for user in bad_users:
    complain(user)
#-----------------------------
import os
for (key, val) in sorted(os.environ.items()):
    print "%s=%s" % (key, val)
#-----------------------------
for user in all_users:
    disk_space = get_usage(user)    # find out how much disk space in use
    if disk_space > MAX_QUOTA:      # if it's more than we want ...
        complain(user)              # ... then object vociferously
#-----------------------------
import os
for line in os.popen("who"):
    if "dalke" in line:
        print line,  # or print line[:-1]

# or:
print "".join([line for line in os.popen("who")
                   if "dalke" in line]),

#-----------------------------
for line in myfile:
    for word in line.split(): # Split on whitespace
        print word[::-1],     # reverse word
    print

# pre 2.3:
for line in myfile:
    for word in line.split(): # Split on whitespace
        chars = list(word)    # Turn the string into a list of characters
        chars.reverse()
        print "".join(chars),
    print
#-----------------------------
for item in mylist:
    print "i =", item
#-----------------------------
# NOTE: you can't modify in place the way Perl does:
# data = [1, 2, 3]
# for elem in data:
#     elem -= 1
#print data
#=>[1, 2, 3]

data = [1, 2, 3]
data = [i-1 for i in data]
print data
#=>[0, 1, 2]

# or
for i, elem in enumerate(data):
    data[i] = elem - 1
#-----------------------------
# NOTE: strings are immutable in Python so this doesn't translate well.
s = s.strip()
data = [s.strip() for s in data]
for k, v in mydict.items():
    mydict[k] = v.strip()
#-----------------------------

# @@PLEAC@@_4.5
#-----------------------------
fruits = ["Apple", "Blackberry"]
for fruit in fruits:
    print fruit, "tastes good in a pie."
#=> Apple tastes good in a pie.
#=> Blackberry tastes good in a pie.
#-----------------------------
# DON'T DO THIS:
for i in range(len(fruits)):
    print fruits[i], "tastes good in a pie."

# If you must explicitly index, use enumerate():
for i, fruit in enumerate(fruits):
    print "%s) %s tastes good in a pie."%(i+1, fruit)
#-----------------------------
rogue_cats = ["Morris", "Felix"]
namedict = { "felines": rogue_cats }
for cat in namedict["felines"]:
    print cat, "purrs hypnotically."
print "--More--\nYou are controlled."
#-----------------------------
# As noted before, if you need an index, use enumerate() and not this:
for i in range(len(namedict["felines"])):
    print namedict["felines"][i], "purrs hypnotically."
#-----------------------------

# @@PLEAC@@_4.6
#-----------------------------
uniq = list(set(mylist))
#-----------------------------
# See http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/259174
# for a more heavyweight version of a bag
seen = {}
for item in mylist:
    seen[item] = seen.get(item, 0) + 1

uniq = seen.keys()
#-----------------------------
seen = {}
uniq = []
for item in mylist:
    count = seen.get(item, 0)
    if count == 0:
        uniq.append(item)
    seen[item] = count + 1
#-----------------------------
# generate a list of users logged in, removing duplicates
import os
usernames = [line.split()[0] for line in os.popen("who")]
uniq = sorted(set(usernames))
print "users logged in:", " ".join(uniq)

# DON'T DO THIS:
import os
ucnt = {}
for line in os.popen("who"):
    username = line.split()[0]  # Get the first word
    ucnt[username] = ucnt.get(username, 0) + 1 # record the users' presence

# extract and print unique keys
users = ucnt.keys()
users.sort()
print "users logged in:", " ".join(users)
#-----------------------------

# @@PLEAC@@_4.7
#-----------------------------
# assume a_list and b_list are already loaded
aonly = [item for item in a_list if item not in b_list]

# A slightly more complex Pythonic version using sets - if you had a few
# lists, subtracting sets would be clearer than the listcomp version above
a_set = set(a_list)
b_set = set(b_list)
aonly = list(a_set - b_set)  # Elements in a_set but not in b_set

# DON'T DO THIS.
seen = {}                 # lookup table to test membership of B
aonly = []                # answer

#    build lookup table
for item in b_list:
    seen[item] = 1

#    find only elements in a_list and not in b_list
for item in a_list:
    if not item not in seen:
        # it's not in 'seen', so add to 'aonly'
        aonly.append(item)
#-----------------------------
# DON'T DO THIS.  There's lots of ways not to do it.
seen = {}   # lookup table
aonly = []  # answer

#     build lookup table - unnecessary and poor Python style
[seen.update({x: 1}) for x in b_list]

aonly = [item for item in a_list if item not in seen]

#-----------------------------
aonly = list(set(a_list))

# DON'T DO THIS.
seen = {}
aonly = []
for item in a_list:
    if item not in seen:
        aonly.append(item)
    seen[item] = 1                    # mark as seen
#-----------------------------
mydict["key1"] = 1
mydict["key2"] = 2
#-----------------------------
mydict[("key1", "key2")] = (1,2)
#-----------------------------
# DON'T DO THIS:
seen = dict.fromkeys(B.keys())

# DON'T DO THIS pre-2.3:
seen = {}
for term in B:
    seen[term] = None
#-----------------------------
# DON'T DO THIS:
seen = {}
for k, v in B:
    seen[k] = 1
#-----------------------------

# @@PLEAC@@_4.8
#-----------------------------
a = (1, 3, 5, 6, 7, 8)
b = (2, 3, 5, 7, 9)

a_set = set(a)
b_set = set(b)

union = a_set | b_set   # or a_set.union(b_set)
isect = a_set & b_set   # or a_set.intersection(b_set) 
diff = a_set ^ b_set    # or a_set.symmetric_difference(b_set)


# DON'T DO THIS:
union_list = []; isect_list = []; diff = []
union_dict = {}; isect_dict = {}
count = {}
#-----------------------------
# DON'T DO THIS:
for e in a:
    union_dict[e] = 1

for e in b:
    if union_dict.has_key(e):
        isect_dict[e] = 1
    union_dict[e] = 1

union_list = union_dict.keys()
isect_list = isect_dict.keys()
#-----------------------------
# DON'T DO THIS:
for e in a + b:
    if union.get(e, 0) == 0:
        isect[e] = 1
    union[e] = 1

union = union.keys()
isect = isect.keys()
#-----------------------------
# DON'T DO THIS:
count = {}
for e in a + b:
    count[e] = count.get(e, 0) + 1

union = []; isect = []; diff = []

for e in count.keys():
    union.append(e)
    if count[e] == 2:
        isect.append(e)
    else:
        diff.append(e)
#-----------------------------
# DON'T DO THIS:
isect = []; diff = []; union = []
count = {}
for e in a + b:
    count[e] = count.get(e, 0) + 1

for e, num in count.items():
    union.append(e)
    [None, diff, isect][num].append(e)
#-----------------------------

# @@PLEAC@@_4.9
#-----------------------------
# "append" for a single term and
# "extend" for many terms
mylist1.extend(mylist2)
#-----------------------------
mylist1 = mylist1 + mylist2
mylist1 += mylist2
#-----------------------------
members = ["Time", "Flies"]
initiates = ["An", "Arrow"]
members.extend(initiates)
# members is now ["Time", "Flies", "An", "Arrow"]
#-----------------------------
members[2:] = ["Like"] + initiates
print " ".join(members)
members[:1] = ["Fruit"]           # or members[1] = "Fruit"
members[-2:] = ["A", "Banana"]
print " ".join(members)
#-----------------------------
#=> Time Flies Like An Arrow
#=> Fruit Flies Like A Banana
#-----------------------------

# @@PLEAC@@_4.10
#-----------------------------
# reverse mylist into revlist

revlist = mylist[::-1]

# or
revlist = list(reversed(mylist))

# or pre-2.3
revlist = mylist[:]    # shallow copy
revlist.reverse()
#-----------------------------
for elem in reversed(mylist):
    pass # do something with elem

# or
for elem in mylist[::-1]:
    pass # do something with elem

# if you need the index and the list won't take too much memory:
for i, elem in reversed(list(enumerate(mylist))):
    pass

# If you absolutely must explicitly index:
for i in range(len(mylist)-1, -1, -1):
    pass
#-----------------------------
descending = sorted(users, reverse=True)
#-----------------------------

# @@PLEAC@@_4.11
#-----------------------------
# remove n elements from the front of mylist
mylist[:n] = []       # or del mylist[:n]

# remove n elements from front of mylist, saving them into front
front, mylist[:n] = mylist[:n], []

# remove 1 element from the front of mylist, saving it in front:
front = mylist.pop(0)

# remove n elements from the end of mylist
mylist[-n:] = []      # or del mylist[-n:]

# remove n elements from the end of mylist, saving them in end
end, mylist[-n:] = mylist[-n:], []

# remove 1 element from the end of mylist, saving it in end:
end = mylist.pop()

#-----------------------------
def shift2(terms):
    front = terms[:2]
    terms[:2] = []
    return front

def pop2(terms):
    back = terms[-2:]
    terms[-2:] = []
    return back
#-----------------------------
friends = "Peter Paul Mary Jim Tim".split()
this, that = shift2(friends)
# 'this' contains Peter, 'that' has Paul, and
# 'friends' has Mary, Jim, and Tim

beverages = "Dew Jolt Cola Sprite Fresca".split()
pair = pop2(beverages)
# pair[0] contains Sprite, pair[1] has Fresca,
# and 'beverages' has (Dew, Jolt, Cola)

# In general you probably shouldn't do things that way because it's 
# not clear from these calls that the lists are modified.
#-----------------------------

# @@PLEAC@@_4.12
for item in mylist:
    if criterion:
        pass    # do something with matched item
        break
else:
    pass     # unfound
#-----------------------------
for idx, elem in enumerate(mylist):
    if criterion:
        pass    # do something with elem found at mylist[idx]
        break
else:
    pass ## unfound
#-----------------------------
# Assuming employees are sorted high->low by wage.
for employee in employees:
    if employee.category == 'engineer':
        highest_engineer = employee
        break

print "Highest paid engineer is:", highest_engineer.name
#-----------------------------
# If you need the index, use enumerate:
for i, employee in enumerate(employees):
    if employee.category == 'engineer':
        highest_engineer = employee
        break
print "Highest paid engineer is: #%s - %s" % (i, highest_engineer.name)


# The following is rarely appropriate:
for i in range(len(mylist)):
    if criterion:
        pass    # do something
        break
else:
    pass ## not found
#-----------------------------


# @@PLEAC@@_4.13
matching = [term for term in mylist if test(term)]
#-----------------------------
matching = []
for term in mylist:
    if test(term):
        matching.append(term)
#-----------------------------
bigs = [num for num in nums if num > 1000000]
pigs = [user for (user, val) in users.items() if val > 1e7]
#-----------------------------
import os
matching = [line for line in os.popen("who") 
                if line.startswith("gnat ")]
#-----------------------------
engineers = [employee for employee in employees
                 if employee.position == "Engineer"]
#-----------------------------
secondary_assistance = [applicant for applicant in applicants
                            if 26000 <= applicant.income < 30000]
#-----------------------------

# @@PLEAC@@_4.14
sorted_list = sorted(unsorted_list)
#-----------------------------
# pids is an unsorted list of process IDs
import os, signal, time
for pid in sorted(pids):
    print pid

pid = raw_input("Select a process ID to kill: ")
try:
    pid = int(pid)
except ValueError:
    raise SystemExit("Exiting ... ")
os.kill(pid, signal.SIGTERM)
time.sleep(2)
try:
    os.kill(pid, signal.SIGKILL)
except OSError, err:
    if err.errno != 3:  # was it already killed?
        raise
#-----------------------------
descending = sorted(unsorted_list, reverse=True)
#-----------------------------
allnums = [4, 19, 8, 3]
allnums.sort(reverse=True)              # inplace
#-----------------------------
# pre 2.3
allnums.sort()                          # inplace
allnums.reverse()                       # inplace
#or
allnums = sorted(allnums, reverse=True) # reallocating
#-----------------------------

# @@PLEAC@@_4.15
ordered = sorted(unordered, cmp=compare)
#-----------------------------
ordered = sorted(unordered, key=compute)

# ...which is somewhat equivalent to: 
precomputed = [(compute(x), x) for x in unordered]
precomputed.sort(lambda a, b: cmp(a[0], b[0]))
ordered = [v for k,v in precomputed.items()]
#-----------------------------
# DON'T DO THIS.
def functional_sort(mylist, function):
    mylist.sort(function)
    return mylist

ordered = [v for k,v in functional_sort([(compute(x), x) for x in unordered],
                                        lambda a, b: cmp(a[0], b[0]))]
#-----------------------------
ordered = sorted(employees, key=lambda x: x.name)
#-----------------------------
for employee in sorted(employees, key=lambda x: x.name):
    print "%s earns $%s" % (employee.name, employee.salary)
#-----------------------------
sorted_employees = sorted(employees, key=lambda x: x.name):
for employee in sorted_employees:
    print "%s earns $%s" % (employee.name, employee.salary)

# load bonus
for employee in sorted_employees:
    if bonus(employee.ssn):
        print employee.name, "got a bonus!"
#-----------------------------
sorted_employees = sorted(employees, key=lambda x: (x.name, x.age)):
#-----------------------------
# NOTE: Python should allow access to the pwd fields by name
# as well as by position.
import pwd
# fetch all users
users = pwd.getpwall()
for user in sorted(users, key=lambda x: x[0]):
    print user[0]
#-----------------------------
sorted_list = sorted(names, key=lambda x: x[:1])
#-----------------------------
sorted_list = sorted(strings, key=len)
#-----------------------------
# DON'T DO THIS.
temp = [(len(s), s) for s in strings]
temp.sort(lambda a, b: cmp(a[0], b[0]))
sorted_list = [x[1] for x in temp]
#-----------------------------
# DON'T DO THIS.
def functional_sort(mylist, function):
    mylist.sort(function)
    return mylist

sorted_fields = [v for k,v in functional_sort(
              [(int(re.search(r"(\d+)", x).group(1)), x) for x in fields],
                                   lambda a, b: cmp(a[0], b[0]))]
#-----------------------------
entries = [line[:-1].split() for line in open("/etc/passwd")]

for entry in sorted(entries, key=lambda x: (x[3], x[2], x[0])):
    print entry
#-----------------------------

# @@PLEAC@@_4.16
#-----------------------------
import itertools
for process in itertools.cycle([1, 2, 3, 4, 5]):
    print "Handling process", process
    time.sleep(1)

# pre 2.3:
import time
class Circular(object):
    def __init__(self, data):
        assert len(data) >= 1, "Cannot use an empty list"
        self.data = data

    def __iter__(self):
        while True:
            for elem in self.data:
                yield elem

circular = Circular([1, 2, 3, 4, 5])

for process in circular:
    print "Handling process", process
    time.sleep(1)

# DON'T DO THIS. All those pops and appends mean that the list needs to be 
# constantly reallocated.  This is rather bad if your list is large:
import time
class Circular(object):
    def __init__(self, data):
        assert len(data) >= 1, "Cannot use an empty list"
        self.data = data

    def next(self):
        head = self.data.pop(0)
        self.data.append(head)
        return head

circular = Circular([1, 2, 3, 4, 5])
while True:
    process = circular.next()
    print "Handling process", process
    time.sleep(1)
#-----------------------------

# @@PLEAC@@_4.17
#-----------------------------
# generate a random permutation of mylist in place
import random
random.shuffle(mylist)
#-----------------------------

# @@PLEAC@@_4.18
#-----------------------------
import sys

def make_columns(mylist, screen_width=78):
    if mylist:
        maxlen = max([len(elem) for elem in mylist])
        maxlen += 1   # to make extra space

        cols = max(1, screen_width/maxlen) 
        rows = 1 + len(mylist)/cols

        # pre-create mask for faster computation
        mask = "%%-%ds " % (maxlen-1)

        for n in range(rows):
            row = [mask%elem
                       for elem in mylist[n::rows]]
            yield "".join(row).rstrip()

for row in make_columns(sys.stdin.readlines(), screen_width=50):
    print row


# A more literal translation
import sys

# subroutine to check whether at last item on line
def EOL(item):
    return (item+1) % cols == 0

# Might not be portable to non-linux systems
def getwinsize():
    # Use the curses module if installed
    try:
        import curses
        stdscr = curses.initscr()
        rows, cols = stdscr.getmaxyx()
        return cols
    except ImportError:
        pass

    # Nope, so deal with ioctl directly.  What value for TIOCGWINSZ?
    try:
        import termios
        TIOCGWINSZ = termios.TIOCGWINSZ
    except ImportError:
        TIOCGWINSZ = 0x40087468  # This is Linux specific

    import struct, fcntl
    s = struct.pack("HHHH", 0, 0, 0, 0)
    try:
        x = fcntl.ioctl(sys.stdout.fileno(), TIOCGWINSZ, s)
    except IOError:
        return 80
    rows, cols = struct.unpack("HHHH", x)[:2]
    return cols

cols = getwinsize()

data = [s.rstrip() for s in sys.stdin.readlines()]
if not data:
    maxlen = 1
else:
    maxlen = max(map(len, data))

maxlen += 1       # to make extra space

# determine boundaries of screen
cols = (cols / maxlen) or 1
rows = (len(data)+cols) / cols

# pre-create mask for faster computation
mask = "%%-%ds " % (maxlen-1)

# now process each item, picking out proper piece for this position
for item in range(rows * cols):
    target = (item % cols) * rows + (item/cols)
    if target < len(data):
        piece = mask % data[target]
    else:
        piece = mask % ""
    if EOL(item):
        piece = piece.rstrip()  # don't blank-pad to EOL
    sys.stdout.write(piece)
    if EOL(item):
        sys.stdout.write("\n")

if EOL(item):
  sys.stdout.write("\n")
#-----------------------------

# @@PLEAC@@_4.19
#-----------------------------
def factorial(n):
    s = 1
    while n:
        s *= n
        n -= 1
    return s   
#-----------------------------
def permute(alist, blist=[]):
    if not alist:
        yield blist
    for i, elem in enumerate(alist):
        for elem in permute(alist[:i] + alist[i+1:], blist + [elem]):
            yield elem

for permutation in permute(range(4)):
    print permutation
#-----------------------------
# DON'T DO THIS
import fileinput

# Slightly modified from
#   http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/66463
def print_list(alist, blist=[]):
    if not alist:
        print ' '.join(blist)
    for i in range(len(alist)):
        blist.append(alist.pop(i))
        print_list(alist, blist)
        alist.insert(i, blist.pop())

for line in fileinput.input():
    words = line.split()
    print_list(words)
#-----------------------------
class FactorialMemo(list):
    def __init__(self):
        self.append(1)
        
    def __call__(self, n):
        try:
            return self[n]
        except IndexError:
            ret = n * self(n-1)
            self.append(ret)
            return ret

factorial = FactorialMemo()

import sys
import time
sys.setrecursionlimit(10000)

start = time.time()
factorial(2000)
f1 = time.time() - start
factorial(2100)                 # First 2000 values are cached already
f2 = time.time() - f1 - start
print "Slow first time:", f1
print "Quicker the second time:", f2
#-----------------------------

class MemoizedPermutations(list):
    def __init__(self, alist):
        self.permute(alist, [])
        
    def permute(self, alist, blist):
        if not alist:
            self.append(blist)
        for i, elem in enumerate(alist):
            self.permute(alist[:i] + alist[i+1:], blist + [elem])

    def __call__(self, seq, idx):
        return [seq[n] for n in self[idx]]


p5 = MemoizedPermutations(range(5))

words = "This sentence has five words".split()
print p5(words, 17)
print p5(words, 81)
#-----------------------------

# @@PLEAC@@_5.0
#-----------------------------
# dictionaries
age = {"Nat": 24,
       "Jules": 24,
       "Josh": 17}
#-----------------------------
age = {}
age["Nat"] = 24
age["Jules"] = 25
age["Josh"] = 17
#-----------------------------
food_color = {"Apple":  "red",
              "Banana": "yellow",
              "Lemon":  "yellow",
              "Carrot": "orange"
             }
#-----------------------------
# NOTE: keys must be quoted in Python


# @@PLEAC@@_5.1
mydict[key] = value
#-----------------------------
# food_color defined per the introduction
food_color["Raspberry"] = "pink"
print "Known foods:"
for food in food_color:
    print food

#=> Known foods:
#=> Raspberry
#=> Carrot
#=> Lemon
#=> Apple
#=> Banana
#-----------------------------

# @@PLEAC@@_5.2
# does mydict have a value for key?
if key in mydict:
    pass # it exists
else:
    pass # it doesn't

#-----------------------------
# food_color per the introduction
for name in ("Banana", "Martini"):
    if name in food_color:
        print name, "is a food."
    else:
        print name, "is a drink."

#=> Banana is a food.
#=> Martini is a drink.
#-----------------------------
age = {}
age["Toddler"] = 3
age["Unborn"] = 0
age["Phantasm"] = None

for thing in ("Toddler", "Unborn", "Phantasm", "Relic"):
    print ("%s:"%thing),
    if thing in age:
        print "Exists",
        if age[thing] is not None:
            print "Defined",
        if age[thing]:
            print "True",
    print
#=> Toddler: Exists Defined True
#=> Unborn: Exists Defined
#=> Phantasm: Exists
#=> Relic:
#-----------------------------
# Get file sizes for the requested filenames
import fileinput, os
size = {}
for line in fileinput.input():
    filename = line.rstrip()
    if filename in size:
        continue
    size[filename] = os.path.getsize(filename)


# @@PLEAC@@_5.3
# remove key and its value from mydict
del mydict[key]
#-----------------------------
# food_color as per Introduction
def print_foods():
    foods = food_color.keys()

    print "Keys:", " ".join(foods)
    print "Values:",

    for food in foods:
        color = food_color[food]
        if color is not None:
            print color,
        else:
            print "(undef)",
    print

print "Initially:"
print_foods()

print "\nWith Banana set to None"
food_color["Banana"] = None
print_foods()

print "\nWith Banana deleted"
del food_color["Banana"]
print_foods()

#=> Initially:
#=> Keys: Carrot Lemon Apple Banana
#=> Values: orange yellow red yellow
#=> 
#=> With Banana set to None
#=> Keys: Carrot Lemon Apple Banana
#=> Values: orange yellow red (undef)
#=> 
#=> With Banana deleted
#=> Keys: Carrot Lemon Apple
#=> Values: orange yellow red
#-----------------------------
for key in ["Banana", "Apple", "Cabbage"]:
    del food_color[key]
#-----------------------------


# @@PLEAC@@_5.4
#-----------------------------
for key, value in mydict.items():  
    pass # do something with key and value

# If mydict is large, use iteritems() instead
for key, value in mydict.iteritems():  
    pass # do something with key and value

#-----------------------------
# DON'T DO THIS:
for key in mydict.keys():
    value = mydict[key]
    # do something with key and value
#-----------------------------
# food_color per the introduction
for food, color in food_color.items():
    print "%s is %s." % (food, color)

# DON'T DO THIS:
for food in food_color:
    color = food_color[food]
    print "%s is %s." % (food, color)

#-----------------------------
print """%(food)s

is

%(color)s.
""" % vars()
#-----------------------------
for food, color in sorted(food_color.items()):
    print "%s is %s." % (food, color)

#-----------------------------
#!/usr/bin/env python
# countfrom - count number of messages from each sender

import sys
if len(sys.argv) > 1:
    infile = open(sys.argv[1])
else:
    infile = sys.stdin

counts = {}
for line in infile:
    if line.startswith("From: "):
        name = line[6:-1]
        counts[name] = counts.get(name, 0) + 1

for (name, count) in sorted(counts.items()):
    print "%s: %s" % (name, count)

#-----------------------------


# @@PLEAC@@_5.5
for key, val in mydict.items():
    print key, "=>", val
#-----------------------------
print "\n".join([("%s => %s" % item) for item in mydict.items()])
#-----------------------------
print mydict
#=> {'firstname': 'Andrew', 'login': 'dalke', 'state': 'New Mexico', 'lastname': 'Dalke'}
#-----------------------------
import pprint
pprint.pprint(dict)
#=> {'firstname': 'Andrew',
#=>  'lastname': 'Dalke',
#=>  'login': 'dalke',
#=>  'state': 'New Mexico'}
#-----------------------------


# @@PLEAC@@_5.6
#-----------------------------
class SequenceDict(dict):
    """
    Dictionary that remembers the insertion order.
    The lists returned by keys(), values() and items() are
    in the insertion order.
    """
    def __init__(self, *args):
        self._keys={} # key --> id
        self._ids={}      # id  --> key
        self._next_id=0
        
    def __setitem__(self, key, value):
        self._keys[key]=self._next_id
        self._ids[self._next_id]=key
        self._next_id+=1
        return dict.__setitem__(self, key, value)
    
    def __delitem__(self, key):
        id=self._keys[key]
        del(self._keys[key])
        del(self._ids[id])
        return dict.__delitem__(self, key)

    def values(self):
        values=[]
        ids=list(self._ids.items())
        ids.sort()
        for id, key in ids:
            values.append(self[key])
        return values

    def items(self):
        items=[]
        ids=list(self._ids.items())
        ids.sort()
        for id, key in ids:
            items.append((key, self[key]))
        return items

    def keys(self):
        ids=list(self._ids.items())
        ids.sort()
        keys=[]
        for id, key in ids:
            keys.append(key)
        return keys

    def update(self, d):
        for key, value in d.items():
            self[key]=value

    def clear(self):
        dict.clear(self)
        self._keys={}
        self._ids={}
        self._next_id=0
        
def testSequenceDict():
    sd=SequenceDict()

    # First Test
    sd[3]="first"
    sd[2]="second"
    sd[1]="third"
    print sd.keys()
    print sd.items()
    print sd.values()

    del(sd[1])
    del(sd[2])
    del(sd[3])

    print sd.keys(), sd.items(), sd.values()
    print sd._ids, sd._keys

    print "---------------"
    # Second Test
    sd["b"]="first"
    sd["a"]="second"
    sd.update({"c": "third"})
    print sd.keys()
    print sd.items()
    print sd.values()

    del(sd["b"])
    del(sd["a"])
    del(sd["c"])

    print sd.keys(), sd.items(), sd.values()
    print sd._ids, sd._keys

def likePerlCookbook():
    food_color=SequenceDict()
    food_color["Banana"]="Yellow";
    food_color["Apple"]="Green";
    food_color["Lemon"]="Yellow"
    print "In insertion order, the foods' color are:"
    for food, color in food_color.items():
        print "%s is colored %s" % (food, color)

if __name__=="__main__":
    #testSequenceDict()
    likePerlCookbook()
    

# @@PLEAC@@_5.7
import os
ttys = {}

who = os.popen("who")

for line in who:
    user, tty = line.split()[:2]
    ttys.setdefault(user, []).append(tty)

for (user, tty_list) in sorted(ttys.items()):
    print user + ": " + " ".join(tty_list)
#-----------------------------
import pwd
for (user, tty_list) in ttys.items():
    print user + ":", len(tty_list), "ttys."
    for tty in sorted(tty_list):
        try:
            uid = os.stat("/dev/" + tty).st_uid
            user = pwd.getpwuid(uid)[0]
        except os.error:
            user = "(not available)"
        print "\t%s (owned by %s)" % (tty, user)

# @@PLEAC@@_5.8
# lookup_dict maps keys to values
reverse = dict([(val, key) for (key, val) in lookup_dict.items()])
#-----------------------------
surname = {"Mickey": "Mantle", "Babe": "Ruth"}
first_name = dict([(last, first) for (first, last) in surname.items()])

print first_name["Mantle"]
#=> Mickey
#-----------------------------
#!/usr/bin/perl -w
# foodfind - find match for food or color

import sys
if not sys.argv[1:]:
    raise SystemExit("usage: foodfind food_or_color")
given = sys.argv[1]

color_dict = {"Apple":  "red",
              "Banana": "yellow",
              "Lemon":  "yellow",
              "Carrot": "orange",
             }
food_dict = dict([(color, food) for (food, color) in color_dict.items()])

if given in color_dict:
    print given, "is a food with color", color_dict[given]
elif given in food_dict:
    print food_dict[given], "is a food with color", given
#-----------------------------
# food_color as per the introduction
foods_with_color = {}
for food, color in food_color.items():
    foods_with_color.setdefault(color, []).append(food)

print " ".join(foods_with_color["yellow"]), "were yellow foods."
#-----------------------------

# @@PLEAC@@_5.9
#-----------------------------
# mydict is the hash to sort
for key, value in sorted(mydict.items()):
    # do something with key, value
#-----------------------------
# food_color as per section 5.8
for food, color in sorted(food_color.items()):
    print "%s is %s." % (food, color)
#-----------------------------
# NOTE: alternative version
for item in sorted(food_color.items()):
    print "%s is %s." % item
#-----------------------------
# NOTE: alternative version showing a user-defined function
def food_cmp(x, y):
    return cmp(x, y)

for food, color in sorted(food_color, cmp=food_cmp):
    print "%s is %s." % (food, color)
#-----------------------------
def food_len_cmp(x, y):
    return cmp(len(x), len(y))

for food in sorted(food_color, cmp=food_len_cmp):
    print "%s is %s." % (food, food_color[food])

# In this instance, however, the following is both simpler and faster:
for food in sorted(food_color, key=len):
    print "%s is %s." % (food, food_color[food])
#-----------------------------


# @@PLEAC@@_5.10
#-----------------------------
merged = {}
merged.update(a_dict)
merged.update(b_dict)

#-----------------------------
# NOTE: alternative version
merged = a_dict.copy()
merged.update(b_dict)
#-----------------------------
# DON'T DO THIS:

merged = {}
for k, v in a_dict.items():
    merged[k] = v
for k, v in b_dict.items():
    merged[k] = v
#-----------------------------
# food_color as per section 5.8
drink_color = {"Galliano": "yellow",
               "Mai Tai": "blue"}

ingested_color = drink_color.copy()
ingested_color.update(food_color)
#-----------------------------
# DON'T DO THIS:
drink_color = {"Galliano": "yellow",
               "Mai Tai": "blue"}

substance_color = {}
for k, v in food_color.items():
    substance_color[k] = v
for k, v in drink_color.items():
    substance_color[k] = v
#-----------------------------
# DON'T DO THIS:
substance_color = {}
for mydict in (food_color, drink_color):
    for k, v in mydict:
        substance_color[k] = v
#-----------------------------
# DON'T DO THIS:
substance_color = {}
for item in food_color.items() + drink_color.items():
    for k, v in mydict:
        substance_color[k] = v
#-----------------------------
substance_color = {}
for mydict in (food_color, drink_color):
    for k, v in mydict.items():
        if substance_color.has_key(k):
            print "Warning:", k, "seen twice.  Using the first definition."
            continue
        substance_color[k] = v

# I think it's a copy, in which case
all_colors = new_colors.copy()


# @@PLEAC@@_5.11
common = [k for k in dict1 if k in dict2]
#-----------------------------
this_not_that = [k for k in dict1 if k not in dict2]
#-----------------------------
# citrus_color is a dict mapping citrus food name to its color.
citrus_color = {"Lemon":  "yellow",
                "Orange": "orange",
                "Lime":   "green"}

# build up a list of non-citrus foods
non_citrus = [k for k in food_color if k not in citruscolor]
#-----------------------------

# @@PLEAC@@_5.12
#-----------------------------
# references as keys of dictionaries is no pb in python

name = {}
for filename in ("/etc/termcap", "/vmunix", "/bin/cat"):
    try:
        myfile = open(filename)
    except IOError:
        pass
    else:
        names[myfile] = filename

print "open files:", ", ".join(name.values())
for f, fname in name.items():
    f.seek(0, 2)       # seek to the end
    print "%s is %d bytes long." % (fname, f.tell())
#-----------------------------

# @@PLEAC@@_5.13
# Python doesn't allow presizing of dicts, but hashing is efficient -
# it only re-sizes at intervals, not every time an item is added.

# @@PLEAC@@_5.14
count = {}
for element in mylist:
    count[element] = count.get(element, 0) + 1

# @@PLEAC@@_5.15
#-----------------------------
import fileinput

father = {'Cain': 'Adam',
          'Abel': 'Adam',
          'Seth': 'Adam',
          'Enoch': 'Cain',
          'Irad': 'Enoch',
          'Mehujael': 'Irad',
          'Methusael': 'Mehujael',
          'Lamech': 'Methusael',
          'Jabal': 'Lamech',
          'Tubalcain': 'Lamech',
          'Enos': 'Seth',
         }

for line in fileinput.input():
    person = line.rstrip()
    while person:                    # as long as we have people,
        print person,                # print the current name
        person = father.get(person)  # set the person to the person's father
    print

#-----------------------------
import fileinput

children = {}
for k, v in father.items():
    children.setdefault(v, []).append(k)

for line in fileinput.input():
    person = line.rstrip()
    kids = children.get(person, ["nobody"])
    print person, "begat", ", ".join(kids)

#-----------------------------
import sys, re
pattern = re.compile(r'^\s*#\s*include\s*<([^>]+)')
includes = {}
for filename in filenames:
    try:
        infile = open(filename)
    except IOError, err:
        print>>sys.stderr, err
        continue
    for line in infile:
        match = pattern.match(line)
        if match:
            includes.setdefault(match.group(1), []).append(filename)
#-----------------------------
# list of files that don't include others
mydict = {}
for e in reduce(lambda a,b: a + b, includes.values()):
    if not includes.has_key(e):
        mydict[e] = 1
include_free = mydict.keys()
include_free.sort()

# @@PLEAC@@_5.16
#-----------------------------
#!/usr/bin/env python -w
# dutree - print sorted indented rendition of du output
import os, sys

def get_input(args):
    # NOTE: This is insecure - use only from trusted code!
    cmd = "du " + " ".join(args)
    infile = os.popen(cmd)

    dirsize = {}
    kids = {}
    for line in infile:
        size, name = line[:-1].split("\t", 1)
        dirsize[name] = int(size)
        parent = os.path.dirname(name)
        kids.setdefault(parent, []).append(name)
    # Remove the last field added, which is the root
    kids[parent].pop()
    if not kids[parent]: 
        del kids[parent]

    return name, dirsize, kids

def getdots(root, dirsize, kids):
    size = cursize = dirsize[root]
    if kids.has_key(root):
        for kid in kids[root]:
            cursize -= dirsize[kid]
            getdots(kid, dirsize, kids)
    if size != cursize:
        dot = root + "/."
        dirsize[dot] = cursize
        kids[root].append(dot)

def output(root, dirsize, kids, prefix = "", width = 0):
    path = os.path.basename(root)
    size = dirsize[root]
    fmt = "%" + str(width) + "d %s"
    line = fmt % (size, path)
    print prefix + line

    prefix += (" " * (width-1)) + "| "  + (" " * len(path))

    if kids.has_key(root):
        kid_list = kids[root]
        kid_list.sort(lambda x, y, dirsize=dirsize:
                          cmp(dirsize[x], dirsize[y]))
        width = len(str(dirsize[kid_list[-1]]))
        for kid in kid_list:
            output(kid, dirsize, kids, prefix, width)

def main():
    root, dirsize, kids = get_input(sys.argv[1:])
    getdots(root, dirsize, kids)
    output(root, dirsize, kids)

if __name__ == "__main__":
    main()


# @@PLEAC@@_6.0
# Note: regexes are used less often in Python than in Perl as tasks are often
# covered by string methods, or specialised objects, modules, or packages.

import re                   # "re" is the regular expression module.
re.search("sheep",meadow)   # returns a MatchObject is meadow contains "sheep".
if not re.search("sheep",meadow):
    print "no sheep on this meadow only a fat python."
# replacing strings is not done by "re"gular expressions.
meadow = meadow.replace("old","new")   # replace "old" with "new" and assign result.
#-----------------------------
re.search("ovine",meadow)

meadow = """Fine bovines demand fine toreadors.
Muskoxen are polar ovibovine species.
Grooviness went out of fashion decades ago."""

meadow = "Ovines are found typically in ovaries."

if re.search(r"\bovines\b",meadow,re.I) : print "Here be sheep!"
#-----------------------------
# The tricky bit
mystr = "good food"
re.sub("o*","e",mystr,1) # gives 'egood food'

echo ababacaca | python -c "import sys,re; print re.search('(a|ba|b)+(a|ac)+',sys.stdin.read()).group()"
#-----------------------------
# pattern matching modifiers
# assume perl code iterates over some file
import re, fileinput
for ln = fileinput.input():
    fnd = re.findall("(\d+)",ln)
    if len(fnd) > 0:
        print "Found number %s" % (fnd[0])
# ----------------------------
digits = "123456789"
nonlap = re.findall("(\d\d\d)", digits)
yeslap = ["not yet"]
print "Non-overlapping:",",".join(nonlap)
print "Overlapping    :",",".join(yeslap)
# ----------------------------
mystr = "And little lambs eat ivy"
fnd = re.search("(l[^s]*s)", mystr)
print "(%s) (%s) (%s)" % (mystr[:fnd.start()], fnd.group(), mystr[fnd.end():])
# (And ) (little lambs) ( eat ivy)


# @@PLEAC@@_6.1
import re
dst = re.sub("this","that",src)
#-----------------------------
# strip to basename
basename = re.sub(".*/(?=[^/]+)","",progname)

# Make All Words Title-Cased
# DON'T DO THIS - use str.title() instead
def cap(mo): return mo.group().capitalize()
re.sub("(?P<n>\w+)",cap,"make all words title-cased")

# /usr/man/man3/foo.1 changes to /usr/man/cat3/foo.1
manpage = "/usr/man/man3/foo.1"
catpage  = re.sub("man(?=\d)","cat",manpage)
#-----------------------------
bindirs = "/usr/bin /bin /usr/local/bin".split()
libdirs = [d.replace("bin", "lib") for d in bindirs]

print " ".join(libdirs)
#=> /usr/lib /lib /usr/local/lib
#-----------------------------
# strings are never modified in place.
#-----------------------------

# @@PLEAC@@_6.2
##---------------------------

# DON'T DO THIS.  use line[:-1].isalpha() [this probably goes for the
#    remainder of this section too!]
import re
if re.match("^[A-Za-z]+$",line):
    print "pure alphabetic"
##---------------------------
if re.match(r"^[^\W\d_]+$", line, re.LOCALE):
    print "pure alphabetic"
##---------------------------
import re
import locale

try:
    locale.setlocale(locale.LC_ALL, 'fr_CA.ISO8859-1')
except:
    print "couldn't set locale to French Cnadian"
    raise SystemExit

DATA="""
silly
façade
coöperate
niño
Renée
Molière 
hæmoglobin
naïve
tschüß
random!stuff#here
"""

for ln in DATA.split():
    ln = ln.rstrip()
    if re.match(r"^[^\W\d_]+$",ln,re.LOCALE):
        print "%s: alphabetic" % (ln)
    else:
        print "%s: line noise" % (ln)
# although i dont think "coöperate" should be in canadian
##---------------------------

# @@PLEAC@@_6.3
# Matching Words
"\S+"          # as many non-whitespace bytes as possible
"[A-Za-z'-]+"  # as many letters, apostrophes, and hyphens

# string split is similar to splitting on "\s+"
"A text   with some\tseparator".split()

"\b*([A-Za-z]+)\b*"   # word boundaries 
"\s*([A-Za-z]+)\s*"   # might work too as on letters are allowed.

re.search("\Bis\B","this thistle") # matches on thistle not on this
re.search("\Bis\B","vis-a-vis")    # does not match

# @@PLEAC@@_6.4
#-----------------------------
#!/usr/bin/python
# resname - change all "foo.bar.com" style names in the input stream
# into "foo.bar.com [204.148.40.9]" (or whatever) instead

import socket               # load inet_addr
import fileinput
import re

match = re.compile("""(?P<hostname>  # capture hostname
                         (?:         # these parens for grouping only
                            [\w-]+   # hostname component
                            \.       # ant the domain dot
                         ) +         # now repeat that whole thing a bunch of times
                         [A-Za-z]    # next must be a letter
                         [\w-] +     # now trailing domain part
                      )              # end of hostname capture
                   """,re.VERBOSE)   # for nice formatting

def repl(match_obj):
    orig_hostname = match_obj.group("hostname")
    try:
        addr = socket.gethostbyname(orig_hostname)
    except socket.gaierror:
        addr = "???"
    return "%s [%s]" % (orig_hostname, addr)

for ln in fileinput.input():
    print match.sub(repl, ln)
#-----------------------------
re.sub("""(?x)     # nicer formatting
          \#       #   a pound sign
          (\w+)    #   the variable name
          \#       #   another pound sign
          """,
          lambda m: eval(m.group(1)),  # replace with the value of the global variable
          line
      )
##-----------------------------
re.sub("""(?x)     # nicer formatting
          \#       #   a pound sign
          (\w+)    #   the variable name
          \#       #   another pound sign
          """,
          lambda m: eval(eval(m.group(1))),  # replace with the value of *any* variable
          line
      )
##-----------------------------

# @@PLEAC@@_6.5
import re
pond = "one fish two fish red fish blue fish"
fishes = re.findall(r"(?i)(\w+)\s+fish\b",pond)
if len(fishes)>2:
    print "The third fish is a %s one." % (fishes[2])
##-----------------------------
re.findall(r"(?i)(?:\w+\s+fish\s+){2}(\w+)\s+fish",pond)
##-----------------------------
count = 0
for match_object in re.finditer(r"PAT", mystr):
    count += 1   # or whatever you want to do here

# "progressive" matching might be better if one wants match 5 from 50.
# to count use
count = len(re.findall(r"PAT",mystr))
count = len(re.findall(r"aba","abaababa"))

# "count" overlapping matches
count = len(re.findall(r"(?=aba)","abaababa"))

# FASTEST non-overlapping might be str.count
"abaababa".count("aba")
##-----------------------------
pond = "one fish two fish red fish blue fish"
colors = re.findall(r"(?i)(\w+)\s+fish\b",pond)   # get all matches
color = colors[2]                                 # then the one we want

# or without a temporary list
color = re.findall(r"(?i)(\w+)\s+fish\b",pond)[2] # just grab element 3

print "The third fish in the pond is %s." % (color)
##-----------------------------
import re

pond = "one fish two fish red fish blue fish"
matches = re.findall(r"(\w+)\s+fish\b",pond)
evens = [fish for (i, fish) in enumerate(matches) if i%2]
print "Even numbered fish are %s." % (" ".join(evens))
##-----------------------------
count = 0
def four_is_sushi(match_obj):
    global count
    count += 1
    if count==4:
        return "sushi%s" % (match_obj.group(2))
    return "".join(match_obj.groups())

re.sub(r"""(?x)               # VERBOSE
           \b                 # makes next \w more efficient
           ( \w+ )            # this is what we'll be changing
           (
             \s+ fish \b
           )""",
           four_is_sushi,
           pond)
# one fish two fish red fish sushi fish
##-----------------------------
# greedily
last_fish = re.findall(r"(?i).*\b(\w+)\s+fish\b",pond)
##-----------------------------
pond = "One fish two fish red fish blue fish swim here"
color = re.findall(r"(?i)\b(\w+)\s+fish\b",pond)[-1]
print "Last fish is "+color+"."
# FASTER using string.
lastfish = pond.rfind("fish")
color = pond[:lastfish].split()[-1]
##-----------------------------
r"""(?x)
    A             # find some pattern A
    (?!           # mustn't be able to find
      .*          # something
      A           # and A
    )
    $             # through the end of string
 """

pond = "One fish two fish red fish blue fish swim here"
fnd = re.findall(r"""(?xis)                # VERBOSE, CASEINSENSITIVE, DOTALL
                  \b ( \w+ ) \s+ fish \b
                  (?! .* \b fish \b )""",
                  pond)
if len(fnd):
    print "Last fish is %s." % (fnd[0])
else:
    print "Failed!"


# @@PLEAC@@_6.6
# Matching Multiple Lines
#
#!/usr/bin/python
# killtags - very bad html tag killer
import re
import sys

text = open(sys.argv[1]).read()        # read the whole file
text = re.sub("(?ms)<.*?>","",text)    # strip tags (terrible
print text
## ----------------------------
#!/usr/bin/python
# headerfy: change certain chapter headers to html
import sys, re

match = re.compile(r"""(?xms)          # re.VERBOSE, re.MULTILINE, and re.DOTALL
                       \A              # start of the string
                       (?P<chapter>    # capture in g<chapter>
                         Chapter       # literal string
                         \s+           # mandatory whitespace
                         \d+           # decimal number
                         \s*           # optional whitespace
                         :             # a real colon
                         . *           # anything not a newline till end of line
                       )
                    """)
text = open(sys.argv[1]).read()        # read the whole file
for paragraph in text.split("\n"):   # split on unix end of lines
    p = match.sub("<h1>\g<chapter></h1>",paragraph)
    print p
## ----------------------------
# the one liner does not run.
# python -c 'import sys,re; for p in open(sys.argv[1]).read().split("\n\n"): print re.sub(r"(?ms)\A(Chapter\s+\d+\s*:.*)","<h1>\g0</h1>",p)'
## ----------------------------
match = re.compile(r"(?ms)^START(.*?)^END")
     # s makes . span line boundaries
     # m makes ^ match at the beginning of the string and at the beginning of each line

chunk = 0
for paragraph in open(sys.argv[1]).read().split("\n\n"):
    chunk += 1
    fnd = match.findall(paragraph)
    if fnd:
        print "chunk %d in %s has <<%s>>" % (chunk,sys.argv[1],">>,<<".join(fnd))
## ----------------------------

# @@PLEAC@@_6.7
import sys
# Read the whole file and split
chunks = open(sys.argv[1]).read().split()      # on whitespace
chunks = open(sys.argv[1]).read().split("\n")  # on line ends

# splitting on pattern
import re
pattern = r"x"
chunks = re.split(pattern, open(sys.argv[1]).read())
##-----------------------------
chunks = re.split(r"(?m)^\.(Ch|Se|Ss)$",open(sys.argv[1]).read())
print "I read %d chunks." % (len(chunks))
# without delimiters
chunks = re.split(r"(?m)^\.(?:Ch|Se|Ss)$",open(sys.argv[1]).read())

# with delimiters
chunks = re.split(r"(?m)^(\.(?:Ch|Se|Ss))$",open(sys.argv[1]).read())

# with delimiters at chunkstart
chunks = re.findall(r"""(?xms)       # multiline, dot matches lineend, allow comments
                          ((?:^\.)?  # consume the separator if present
                           .*?)      # match everything but not greedy
                          (?=        # end the match on this but dont consume it
                            (?:                  # dont put into group [1]
                               ^\.(?:Ch|Se|Ss)$  # either end on one of the roff commands
                               |\Z               # or end of text
                            )
                          )""",
                    open(sys.argv[1]).read())
# [1] if "?:" is removed the result holds tuples: ('.Ch\nchapter x','.Ch')
#     which might be more usefull. 

# @@PLEAC@@_6.8
##-----------------------------
# Python doesn't have perl's range operators
# If you want to only use a selected line range, use enumerate
# (though note that indexing starts at zero:
for i, line in enumerate(myfile):
    if firstlinenum <= i < lastlinenum:
        dosomethingwith(line)

# Using patterned ranges is slightly trickier -
# You need to search for the first pattern then
# search for the next pattern:
import re
for line in myfile:
    if re.match(pat1, line):
        break

dosomethingwith(line)    # Only if pat1 can be on same line as pat2

for line in myfile:
    if re.match(pat2, line):
        break
    dosomethingwith(line)
##-----------------------------
# If you need to extract ranges a lot, the following generator funcs
# may be useful:
def extract_range(myfile, start, finish):
    for i, line in enumerate(myfile):
        if start <= i < finish:
            yield line
        elif i == finish:
            break

for line in extract_range(open("/etc/passwd"), 3, 5):
    print line

def patterned_range(myfile, startpat, endpat=None):
    startpat = re.compile(startpat)
    if endpat is not None:
        endpat = re.compile(endpat)
    in_range = False
    for line in myfile:
        if re.match(startpat, line):
            in_range = True
        if in_range:
            yield line
        if endpat is not None and re.match(endpat, line):
            break

# DO NOT DO THIS.  Use the email module instead
for line in patterned_range(msg, "^From:?", "^$"):
    pass #...


# @@PLEAC@@_6.9
tests = (("list.?",r"^list\..$"),
        ("project.*",r"^project\..*$"),
        ("*old",r"^.*old$"),
        ("type*.[ch]",r"^type.*\.[ch]$"),
        ("*.*",r"^.*\..*$"),
        ("*",r"^.*$"),
        )

# The book says convert "*","?","[","]" all other characters will be quoted.
# The book uses "\Q" which escapes any characters that would otherwise be
# treated as regular expression.
# Escaping every char fails as "\s" is not "s" in a regex.

def glob2pat(globstr):
    pat = globstr.replace("\\",r"\\")
    pat = pat.replace(".",r"\.").replace("?",r".").replace("*",r".*")
    
    return "^"+pat+"$"

for globstr, patstr in tests:
    g2p = glob2pat(globstr)
    if g2p != patstr:
        print globstr, "failed! Should be", patstr, "but was", g2p


# @@PLEAC@@_6.10

# download the following standalone program
#!/usr/bin/python
# popgrep1 - grep for abbreviations of places that say "pop"
# version 1: slow but obvious way
import fileinput
import re
popstates = ["CO","ON","MI","WI","MN"]
for line in fileinput.input():
    for state in popstates:
        if re.search(r"\b"+state+r"\b",line):
            print line



#-----------------------------
# download the following standalone program
#!/usr/bin/python
# popgrep2 - grep for abbreviations of places that say "pop"
# version 2: compile the patterns
import fileinput
import re
popstates = ["CO","ON","MI","WI","MN"]
state_re = []
for state in popstates:
    state_re.append(re.compile(r"\b"+state+r"\b"))
for line in fileinput.input():
    for state in state_re:
        if state.search(line):
            print line


#-----------------------------
# download the following standalone program
#!/usr/bin/python
# popgrep3 - grep for abbreviations of places that say "pop"
# version 3: compile a single pattern
import fileinput
import re
popstates = ["CO","ON","MI","WI","MN"]
state_re = re.compile(r"\b(?:"+"|".join(popstates)+r")\b")
for line in fileinput.input():
    if state_re.search(line):
        print line


#-----------------------------
# download the following standalone program
#!/usr/bin/python
# grepauth - print lines that mention both Tom and Nat
import fileinput
import re

def build_match_any(words):
    return re.compile("|".join(words))
def uniq(arr):
    seen = {}
    for item in arr:
        seen[item] = seen.get(item, 0) + 1
    return seen.keys()
def build_match_all(words):
    r = re.compile("|".join(words))
    c = lambda line: len(uniq(r.findall(line)))>=len(words)
    return c

any = build_match_any(("Tom","Nat"))
all = build_match_all(("Tom","Nat"))
for line in fileinput.input():
    if any.search(line):
        print "any:", line
    if all(line):
        print "all:", line



#-----------------------------


# @@PLEAC@@_6.11
# Testing for a Valid Pattern

import re
while True:
    pat = raw_input("Pattern? ")
    try:
        re.compile(pat)
    except re.error, err:
        print "INVALID PATTERN", err
        continue
    break

# ----
def is_valid_pattern(pat):
    try:
        re.compile(pat)
    except re.error:
        return False
    return True

# ----

# download the following standalone program
#!/usr/bin/python
# paragrep - trivial paragraph grepper
#
# differs from perl version in parano.
# python version displays paragraph in current file.

import sys, os.path, re
if len(sys.argv)<=1:
        print "usage: %s pat [files]\n" % sys.argv[0]
        sys.exit(1)

pat = sys.argv[1]
try:
        pat_re = re.compile(pat)
except:
        print "%s: bad pattern %s: %s" % (sys.argv[1], pat, sys.exc_info()[1])
        sys.exit(1)
for filename in filter(os.path.isfile,sys.argv[2:]):
        parano = 0
        for para in open(filename).read().split("\n\n"):
                parano += 1
                if pat_re.search(para):
                        print filename, parano, para, "\n"
                        


# ----

# as we dont evaluate patterns the attack ::
#
#   $pat = "You lose @{[ system('rm -rf *']} big here";
#
# does not work.


# @@PLEAC@@_6.12

# download the following standalone program
#!/usr/bin/python
# localeg - demonstrates locale effects
#
# re must be told to respect locale either in the regexp
# "(?L)" or as flag to the call (python 2.4) "re.LOCALE".

import sys
import re, string
from locale import LC_CTYPE, setlocale, getlocale

name = "andreas k\xF6nig"
locale = {"German" : "de_DE.ISO_8859-1", "English" : "en_US"}
# us-ascii is not supported on linux py23
# none works in activestate py24

try:
    setlocale(LC_CTYPE, locale["English"])
except:
    print "Invalid locale %s" % locale["English"]
    sys.exit(1)
english_names = []
for n in re.findall(r"(?L)\b(\w+)\b",name):
    english_names.append(n.capitalize())

try:
    setlocale(LC_CTYPE, locale["German"])
except:
    print "Invalid locale %s" % locale["German"]
    sys.exit(1)
german_names = map(string.capitalize, re.findall(r"(?L)\b(\w+)\b",name))

print "English names: %s" % " ".join(english_names)
print "German names: %s" % " ".join(german_names)


# @@PLEAC@@_6.13
##-----------------------------
import difflib
matchlist = ["ape", "apple", "lapel", "peach", "puppy"]
print difflib.get_close_matches("appel", matchlist)
#=> ['lapel', 'apple', 'ape']
##-----------------------------
# Also see:
#     http://www.personal.psu.edu/staff/i/u/iua1/python/apse/
#     http://www.bio.cam.ac.uk/~mw263/pyagrep.html

# @@PLEAC@@_6.14
##-----------------------------
# To search (potentially) repeatedly for a pattern, use re.finditer():

# DO NOT DO THIS.  Split on commas and convert elems using int()
mystr = "3,4,5,9,120"
for match in re.finditer("(\d+)", mystr):
    n = match.group(0)
    if n == "9":
        break # '120' will never be matched
    print "Found number", n

# matches know their end position
mystr = "The year 1752 lost 10 days on the 3rd of September"
x = re.finditer("(\d+)", mystr)
for match in x:
    n = match.group(0)
    print "Found number", n

tail = re.match("(\S+)", mystr[match.end():])
if tail:
    print "Found %s after the last number."%tail.group(0)


# @@PLEAC@@_6.15
# Python's regexes are based on Perl's, so it has the non-greedy 
# '*?', '+?', and '??' versions of '*', '+', and '?'.
# DO NOT DO THIS. import htmllib, formatter, etc, instead
#-----------------------------
# greedy pattern
txt = re.sub("<.*>", "", txt) # try to remove tags, very badly

# non-greedy pattern
txt = re.sub("<.*?>", "", txt) # try to remove tags, still rather badly
#-----------------------------
txt = "<b><i>this</i> and <i>that</i> are important</b> Oh, <b><i>me too!</i></b>"

print re.findall("<b><i>(.*?)</i></b>", txt
##-----------------------------
print re.findall("/BEGIN((?:(?!BEGIN).)*)END/", txt)
##-----------------------------
print re.findall("<b><i>((?:(?!<b>|<i>).)*)</i></b>", txt)
##-----------------------------
print re.findall("<b><i>((?:(?!<[ib]>).)*)</i></b>", txt)
##-----------------------------
print re.findall("""
    <b><i> 
    [^<]*  # stuff not possibly bad, and not possibly the end.
    (?:    # at this point, we can have '<' if not part of something bad
     (?!  </?[ib]>  )   # what we can't have
     <                  # okay, so match the '<'
     [^<]*              # and continue with more safe stuff
    ) *
    </i></b>
    """, re.VERBOSE, txt)
##-----------------------------

# @@PLEAC@@_6.16
##-----------------------------
text = """
This is a test
test of the duplicate word finder.
"""
words = text.split()
for curr, next in zip(words[:-1], words[1:]):
    if curr.upper() == next.upper():
            print "Duplicate word '%s' found." % curr

# DON'T DO THIS
import re
pat = r"""
      \b            # start at a word boundary (begin letters)
      (\S+)         # find chunk of non-whitespace
      \b            # until another word boundary (end letters)
      (
          \s+       # separated by some whitespace
          \1        # and that very same chunk again
          \b        # until another word boundary
      ) +           # one or more sets of those
      """
for match in re.finditer(pat, text, flags=re.VERBOSE|re.IGNORECASE):
    print "Duplicate word '%s' found." % match.group(1)
##-----------------------------
a = 'nobody';
b = 'bodysnatcher';

text = a+" "+b
pat = r"^(\w+)(\w+) \2(\w+)$"
for match in re.finditer(pat, text):
    m1, m2, m3 = match.groups()
    print m2, "overlaps in %s-%s-%s"%(m1, m2, m3)
##-----------------------------
pat = r"^(\w+?)(\w+) \2(\w+)$"
##-----------------------------
try:
    while True:
        factor = re.match(r"^(oo+?)\1+$", n).group(1)
        n = re.sub(factor, "o", n)
        print len(factor)
except AttributeError:
    print len(n)
##-----------------------------
def diaphantine(n, x, y, z):
    pat = r"^(o*)\1{%s}(o*)\2{%s}(o*)\3{%s}$"%(x-1, y-1, z-1)
    text = "o"*n
    try:
        vals = [len(v) for v in re.match(pat, text).groups()]
    except ValueError:
        print "No solutions."
    else:
        print "One solution is: x=%s, y=%s, z=%s."%tuple(vals)
        
diaphantine(n=281, x=12, y=15, z=16)

# @@PLEAC@@_6.17
##-----------------------------
# Pass any of the following patterns to re.match(), etc
pat = "ALPHA|BETA"
pat = "^(?=.*ALPHA)(?=.*BETA)"
pat = "ALPHA.*BETA|BETA.*ALPHA"
pat = "^(?:(?!PAT).)*$"
pat = "(?=^(?:(?!BAD).)*$)GOOD"
##-----------------------------
if not re.match(pattern, text):
    something()
##-----------------------------
if re.match(pat1, text) and re.match(pat2, text):
    something()
##-----------------------------
if re.match(pat1, text) or re.match(pat2, text):
    something()
##-----------------------------
# DON'T DO THIS.
"""minigrep - trivial grep"""
import sys, re

pat = sys.argv[1]
for line in sys.stdin:
    if re.match(pat, line):
        print line[:-1]
##-----------------------------
if re.match(r"^(?=.*bell)(?=.*lab)", "labelled"):
    something()
##-----------------------------
if re.search("bell", s) and re.search("lab", s):
    something()
##-----------------------------
if re.match("""
             ^              # start of string
            (?=             # zero-width lookahead
                .*          # any amount of intervening stuff
                bell        # the desired bell string
            )               # rewind, since we were only looking
            (?=             # and do the same thing
                .*          # any amount of intervening stuff
                lab         # and the lab part
            )
            """,
            murray_hill,
            re.DOTALL | re.VERBOSE):
    print "Looks like Bell Labs might be in Murray Hill!"
##-----------------------------
if re.match(r"(?:^.*bell.*lab)|(?:^.*lab.*bell)", "labelled"):
    something()
##-----------------------------
brand = "labelled"
if re.match("""
            (?:                 # non-capturing grouper
                ^ .*?           # any amount of stuff at the front
                bell            # look for a bell
                .*?             # followed by any amount of anything
                lab             # look for a lab
            )                   # end grouper
            |                   # otherwise, try the other direction
            (?:                 # non-capturing grouper
                ^ .*?           # any amount of stuff at the front
                lab             # look for a lab
                .*?             # followed by any amount of anything
                bell            # followed by a bell
            )                   # end grouper
            """,
            brand,
            re.DOTALL | re.VERBOSE):
    print "Our brand has bell and lab separate."
##-----------------------------
x = "odlaw"
if re.match("^(?:(?!waldo).)*$", x):
   print "There's no waldo here!"
##-----------------------------
if re.match("""
            ^                   # start of string
            (?:                 # non-capturing grouper
                (?!             # look ahead negation
                    waldo       # is he ahead of us now?
                )               # is so, the negation failed
                .               # any character (cuzza /s)
            ) *                 # repeat that grouping 0 or more
            $                   # through the end of the string
            """,
            x,
            re.VERBOSE | re.DOTALL):
    print "There's no waldo here!\n";
##-----------------------------

# @@PLEAC@@_6.18
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_6.19
##-----------------------------
from email._parseaddr import AddressList

print AddressList("fred&barney@stonehenge.com").addresslist[0]

print AddressList("fred&barney@stonehenge.com (Hanna Barbara)").addresslist[0]

name, address = AddressList("Mr Fooby Blah <me@nowhere.com>").addresslist[0]
print "%s's address is '%s'"%(name, address)

# @@PLEAC@@_6.20
##-----------------------------
# Assuming the strings all start with different letters, or you don't
# mind there being precedence, use the startswith string method:

def get_action(answer):
    answer = answer.lower()
    actions = ["send", "stop", "abort", "list", "end"]
    for action in actions:
        if action.startswith(answer):
            return action

print "Action is %s."%get_action("L")
#=> Action is list.
##-----------------------------
#DON'T DO THIS:
import re
answer = "ab"
answer = re.escape(answer.strip())
for action in ("SEND", "STOP", "ABORT", "LIST", "EDIT"):
    if re.match(answer, action, flags=re.IGNORECASE):
        print "Action is %s."%action.lower()
##-----------------------------
import re, sys
def handle_cmd(cmd):    
    cmd = re.escape(cmd.strip())
    for name, action in {"edit": invoke_editor,
                         "send": deliver_message,
                         "list": lambda: system(pager, myfile),
                         "abort": sys.exit,
                         }
        if re.match(cmd, name, flags=re.IGNORECASE):
            action()
            break
    else:
        print "Unknown command:", cmd
handle_cmd("ab")

# @@PLEAC@@_6.21
##-----------------------------
# urlify - wrap HTML links around URL-like constructs
import re, sys, fileinput

def urlify_string(s):
    urls = r'(http|telnet|gopher|file|wais|ftp)'
    
    ltrs = r'\w';
    gunk = r'/#~:.?+=&%@!\-'
    punc = r'.:?\-'
    any  = ltrs + gunk + punc 

    pat = re.compile(r"""
      \b                    # start at word boundary
      (                     # begin \1  {
       %(urls)s  :          # need resource and a colon
       [%(any)s] +?         # followed by one or more
                            #  of any valid character, but
                            #  be conservative and take only
                            #  what you need to....
      )                     # end   \1  }
      (?=                   # look-ahead non-consumptive assertion
       [%(punc)s]*          # either 0 or more punctuation
       [^%(any)s]           #   followed by a non-url char
       |                    # or else
       $                    #   then end of the string
      )
    """%locals(), re.VERBOSE | re.IGNORECASE)
    return re.sub(pat, r"<A HREF=\1>\1</A>", s)

if __name__ == "__main__":
    for line in fileinput.input():
        print urlify_string(line)


# @@PLEAC@@_6.22
##-----------------------------
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_6.23
# The majority of regexes in this section are either partially
# or completely The Wrong Thing to Do.
##-----------------------------
# DON'T DO THIS.  Use a Roman Numeral module, etc. (since
# you need one anyway to calculate values)
pat = r"^m*(d?c{0,3}|c[dm])(l?x{0,3}|x[lc])(v?i{0,3}|i[vx])$"
re.match(pat, "mcmlxcvii")
##-----------------------------
txt = "one two three four five"

# If the words are cleanly delimited just split and rejoin:
word1, word2, rest = txt.split(" ", 2)
print " ".join([word2, word1, rest])

# Otherwise:
frompat = r"(\S+)(\s+)(\S+)"
topat =  r"\3\2\1"
print re.sub(frompat, topat, txt)

##-----------------------------
print str.split("=")

# DON'T DO THIS
pat = r"(\w+)\s*=\s*(.*)\s*$"
print re.match(pat, "key=val").groups()
##-----------------------------
line = "such a very very very very very very very very very very very very very long line"
if len(line) > 80:
    process(line)

# DON'T DO THIS
pat = ".{80,}"
if re.match(pat, line):
    process(line)
##-----------------------------
dt = time.strptime("12/11/05 12:34:56", "%d/%m/%y %H:%M:%S")

# DON'T DO THIS
pat = r"(\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+)"
dt = re.match(pat, "12/11/05 12:34:56").groups()
##-----------------------------
txt = "/usr/bin/python"
print txt.replace("/usr/bin", "/usr/local/bin")
# Alternatively for file operations use os.path, shutil, etc.

# DON'T DO THIS
print re.sub("/usr/bin", "/usr/local/bin", txt)
##-----------------------------
import re

def unescape_hex(matchobj):
    return chr(int(matchobj.groups(0)[0], 16))
txt = re.sub(r"%([0-9A-Fa-f][0-9A-Fa-f])", unescape_hex, txt)

# Assuming that the hex escaping is well-behaved, an alternative is:
def unescape_hex(seg):
    return chr(int(seg[:2], 16)) + seg[2:]

segs = txt.split("%")
txt = segs[0] + "".join(unescape_hex(seg) for seg in segs[1:])
##-----------------------------
txt = re.sub(r"""
             /\*                    # Match the opening delimiter
             .*?                    # Match a minimal number of characters
             \*/                    # Match the closing delimiter
             """, "", txt, re.VERBOSE)
##-----------------------------
txt.strip()

# DON'T DO THIS
txt = re.sub(r"^\s+", "", txt)
txt = re.sub(r"\s+$", "", txt)
##-----------------------------
txt.replace("\\n", "\n")

# DON'T DO THIS
txt = re.sub("\\n", "\n", txt)
##-----------------------------
txt = re.sub("^.*::", "")
##-----------------------------
import socket
socket.inet_aton(txt) # Will raise an error if incorrect

# DON'T DO THIS.
octseg =r"([01]?\d\d|2[0-4]\d|25[0-5])"
dot = r"\."
pat = "^" + octseg + dot + octseg + dot + octseg + dot + octseg + "$"

if not re.match(pat, txt, re.VERBOSE)
   raise ValueError

# Defitely DON'T DO THIS.
pat = r"""^([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])\.
          ([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])$"""
##-----------------------------
fname = os.path.basename(path)

# DON'T DO THIS.
fname = re.sub("^.*/", "", path)
##-----------------------------
import os
try:
    tc = os.environ["TERMCAP"]
except KeyError:
    cols = 80
else:
    cols = re.match(":co#(\d+):").groups(1)
##-----------------------------
# (not quite equivalent to the Perl version)
name = os.path.basename(sys.argv[0])

# DON'T DO THIS.
name = re.sub("^.*/", "", sys.argv[0])
##-----------------------------
if sys.platform != "linux":
    raise SystemExit("This isn't Linux")
##-----------------------------
txt = re.sub(r"\n\s+", " ", txt)

# In many cases you could just use:
txt = txt.replace("\n", " ")
##-----------------------------
nums = re.findall(r"\d+\.?\d*|\.\d+", txt)
##-----------------------------
# If the words are clearly delimited just use:
capwords = [word for word in txt.split() if word.isupper()]

# Otherwise
capwords = [word for word in re.findall(r"\b(\S+)\b", txt) if word.isupper()]

# (probably) DON'T DO THIS. 
capwords = re.findall(r"(\b[^\Wa-z0-9_]+\b)", txt)
##-----------------------------
# If the words are clearly delimited just use:
lowords = [word for word in txt.split() if word.islower()]

# Otherwise
lowords = [word for word in re.findall(r"\b(\S+)\b", txt) if word.islower()]

# (probably) DON'T DO THIS. 
lowords = re.findall(r"(\b[^\WA-Z0-9_]+\b)", txt)
##-----------------------------
# If the words are clearly delimited just use:
icwords = [word for word in txt.split() if word.istitle()]

# Otherwise
icwords = [word for word in re.finditer(r"\b(\S+)\b") if word.istitle()]

# DON'T DO THIS. 
icwords = re.findall(r"(\b[^\Wa-z0-9_][^\WA-Z0-9_]*\b)", txt)
##-----------------------------
# DON'T DO THIS - use HTMLParser, etc.
links = re.findall(r"""<A[^>]+?HREF\s*=\s*["']?([^'" >]+?)[ '"]?>""", txt)
##-----------------------------
names = txt.split()
if len(names) == 3:
    initial = names[1][0]
else:
    initial = ""

# DON'T DO THIS. 
pat = "^\S+\s+(\S)\S*\s+\S"
try:
    initial = re.match(pat, txt).group(1)
except AttributeError:
    initial = ""
##-----------------------------
txt = re.sub('"([^"]*)"', "``\1''", txt)
##-----------------------------
sentences = [elem[0] for elem in re.findall(r"(.*?[!?.])(  |\Z)", s)]
##-----------------------------
import time
dt = time.strptime(txt, "%Y-%m-%d")

# DON'T DO THIS.
year, month, day = re.match(r"(\d{4})-(\d\d)-(\d\d)", txt).groups()
##-----------------------------
pat = r"""
      ^
      (?:
       1 \s (?: \d\d\d \s)?            # 1, or 1 and area code
       |                               # ... or ...
       \(\d\d\d\) \s                   # area code with parens
       |                               # ... or ...
       (?: \+\d\d?\d? \s)?             # optional +country code
       \d\d\d ([\s\-])                 # and area code
      )
      \d\d\d (\s|\1)                   # prefix (and area code separator)
      \d\d\d\d                         # exchange
        $
      """
re.match(pat, txt, re.VERBOSE)
##-----------------------------
re.match(r"\boh\s+my\s+gh?o(d(dess(es)?|s?)|odness|sh)\b", txt, re.IGNORECASE)
##-----------------------------
for line in file(fname, "Ur"):          #Universal newlines
    process(line)

# DON'T DO THIS
lines = [re.sub(r"^([^\012\015]*)(\012\015?|\015\012?)", "", line) 
         for line in file(fname)]
##-----------------------------


# @@PLEAC@@_7.0
for line in open("/usr/local/widgets/data"):
    if blue in line:
        print line[:-1]
#---------
import sys, re
pattern = re.compile(r"\d")
for line in sys.stdin:
    if not pattern.search(line):
        sys.stderr.write("No digit found.\n")
    sys.stdout.write("Read: " + line)
sys.stdout.close()
#---------
logfile = open("/tmp/log", "w")
#---------
logfile.close()
#---------
print>>logfile, "Countdown initiated ..."
print "You have 30 seconds to reach minimum safety distance."

# DONT DO THIS
import sys
old_output, sys.stdout = sys.stdout, logfile
print "Countdown initiated ..."
sys.stdout = old_output
print "You have 30 seconds to reach minimum safety distance."
#---------

# @@PLEAC@@_7.1
# Python's open() function somewhat covers both perl's open() and 
# sysopen() as it has optional arguments for mode and buffering.
source = open(path)
sink = open(path, "w")
#---------
# NOTE: almost no one uses the low-level os.open and os.fdopen
# commands, so their inclusion here is just silly.  If 
# os.fdopen(os.open(...)) were needed often, it would be turned
# into its own function.  Instead, I'll use 'fd' to hint that
# os.open returns a file descriptor
import os
source_fd = os.open(path, os.O_RDONLY)
source = os.fdopen(fd)
sink_fd = os.open(path, os.O_WRONLY)
sink = os.fdopen(sink_fd)
#---------
myfile = open(filename, "w")
fd = os.open(filename, os.O_WRONLY | os.O_CREAT)
myfile = open(filename, "r+")
#---------
fd = os.open(name, flags)
fd = os.open(name, flags, mode)
#---------
myfile = open(path)
fd = os.open(path, os.O_RDONLY)
#-----------------------------
myfile = open(path, "w")
fd = os.open(path, os.O_WRONLY|os.O_TRUNC|os.O_CREAT)
fd = os.open(path, os.O_WRONLY|os.O_TRUNC|os.O_CREAT, 0600)
#-----------------------------
fd = os.open(path, os.O_WRONLY|os.O_EXCL|os.O_CREAT)
fd = os.open(path, os.O_WRONLY|os.O_EXCL|os.O_CREAT, 0600)
#-----------------------------
myfile = open(path, "a")
fd = os.open(path, os.O_WRONLY|os.O_APPEND|os.O_CREAT)
fd = os.open(path, os.O_WRONLY|os.O_APPEND|s.O_CREAT, 0600)
#-----------------------------
fd = os.open(path, os.O_WRONLY|os.O_APPEND)
#-----------------------------
myfile = open(path, "rw")
fd = os.open(path, os.O_RDWR)
#-----------------------------
fd = os.open(path, os.O_RDWR|os.O_CREAT)
fd = os.open(path, os.O_RDWR|os.O_CREAT, 0600)
#-----------------------------
fd = os.open(path, os.O_RDWR|os.O_EXCL|os.O_CREAT)
fd = os.open(path, os.O_RDWR|os.O_EXCL|os.O_CREAT, 0600)
#-----------------------------

# @@PLEAC@@_7.2
# Nothing different needs to be done with Python

# @@PLEAC@@_7.3
import os
filename = os.path.expanduser(filename)

# @@PLEAC@@_7.4
myfile = open(filename)   # raise an exception on error

try:
    myfile = open(filename)
except IOError, err:
    raise AssertionError("Couldn't open %s for reading : %s" %
                         (filename, err.strerror))

# @@PLEAC@@_7.5
import tempfile

myfile = tempfile.TemporaryFile()

#-----------------------------
# NOTE: The TemporaryFile() call is much more appropriate
# I would not suggest using this code for real work.
import os, tempfile

while True:
    name = os.tmpnam()
    try:
        fd = os.open(name, os.O_RDWR|os.O_CREAT|os.O_EXCL)
        break
    except os.error:
        pass
myfile = tempfile.TemporaryFileWrapper(os.fdopen(fd), name)

# now go on to use the file ...
#-----------------------------
import os
while True:
    tmpname = os.tmpnam()
    fd = os.open(tmpnam, os.O_RDWR | os.O_CREAT | os.O_EXCL)
    if fd:
        tmpfile = os.fdopen(fd)
        break

os.remove(tmpnam)

#-----------------------------
import tempfile

myfile = tempfile.TemporaryFile(bufsize = 0)
for i in range(10):
    print>>myfile, i
myfile.seek(0)
print "Tmp file has:", myfile.read()
#-----------------------------

# @@PLEAC@@_7.6
DATA = """\
your data goes here
"""
for line in DATA.split("\n"):
    pass # process the line

# @@PLEAC@@_7.7

for line in sys.stdin:
    pass # do something with the line

# processing a list of files from commandline
import fileinput
for line in fileinput.input():
     do something with the line

#-----------------------------
import sys

def do_with(myfile):
    for line in myfile:
        print line[:-1]

filenames = sys.argv[1:]
if filenames:
    for filename in filenames:
        try:
            do_with(open(filename))
        except IOError, err:
            sys.stderr.write("Can't open %s: %s\n" % (filename, err.strerror))
            continue
else:
    do_with(sys.stdin)

#-----------------------------
import sys, glob
ARGV = sys.argv[1:] or glob.glob("*.[Cch]")
#-----------------------------
# NOTE: the getopt module is the prefered mechanism for reading
# command line arguments
import sys
args = sys.argv[1:]
chop_first = 0

if args and args[0] == "-c":
    chop_first += 1
    args = args[1:]

# arg demo 2: Process optional -NUMBER flag

# NOTE: You just wouldn't process things this way for Python,
# but I'm trying to preserve the same semantics.

import sys, re
digit_pattern = re.compile(r"-(\d+)$")

args = sys.argv[1:]
if args:
    match = digit_pattern.match(args[0])
    if match:
        columns = int(match.group(1))
        args = args[1:]

# NOTE: here's the more idiomatic way, which also checks
# for the "--" or a non "-" argument to stop processing

args = sys.argv[1:]
for i in range(len(args)):
    arg = args[i]
    if arg == "--" or not arg.startwith("-"):
        break
    if arg[1:].isdigit():
        columns = int(arg[1:])
        continue



# arg demo 3: Process clustering -a, -i, -n, or -u flags
import sys, getopt
try:
    args, filenames = getopt.getopt(sys.argv[1:], "ainu")
except getopt.error:
    raise SystemExit("usage: %s [-ainu] [filenames] ..." % sys.argv[0])

append = ignore_ints = nostdout = unbuffer = 0
for k, v in args:
    if k == "-a": append += 1
    elif k == "-i": ignore_ints += 1
    elif k == "-n": nostdout += 1
    elif k == "-u": unbuffer += 1
    else:
        raise AssertionError("Unexpected argument: %s" % k)

#-----------------------------
# Note: Idiomatic Perl get translated to idiomatic Python
import fileinput
for line in fileinput.input():
    sys.stdout.write("%s:%s:%s" %
                     (fileinput.filename(), fileinput.filelineno(), line))
#-----------------------------
#!/usr/bin/env python
# findlogin1 - print all lines containing the string "login"
for line in fileinput.input(): # loop over files on command line
    if line.find("login") != -1:
        sys.stdout.write(line)

#-----------------------------
#!/usr/bin/env python
# lowercase - turn all lines into lowercase
### NOTE: I don't know how to do locales in Python
for line in fileinput.input(): # loop over files on command line
    sys.stdout.write(line.lower())

#-----------------------------
#!/usr/bin/env python
# NOTE: The Perl code appears buggy, in that "Q__END__W" is considered
#       to be a __END__ and words after the __END__ on the same line
#       are included in the count!!!
# countchunks - count how many words are used.
# skip comments, and bail on file if __END__
# or __DATA__ seen.
chunks = 0
for line in fileinput.input():
    for word in line.split():
        if word.startswith("#"):
            continue
        if word in ("__DATA__", "__END__"):
            fileinput.close()
            break
        chunks += 1
print "Found", chunks, "chunks"


# @@PLEAC@@_7.8
import shutil

old = open("old")
new = open("new","w")

for line in old:
    new.writeline(line)
new.close()
old.close()

shutil.copyfile("old", "old.orig")
shutil.copyfile("new", "old")

# insert lines at line 20:
for i, line in enumerate(old):
    if i == 20:
        print>>new, "Extra line 1\n"
        print>>new, "Extra line 2\n"
    print>>new, line


# or delete lines 20 through 30:
for i, line in enumerate(old):
    if 20 <= i <= 30:
        continue
    print>>new, line


# @@PLEAC@@_7.9
# modifying with "-i" commandline switch is a perl feature
# python has fileinput
import fileinput, sys, time
today = time.strftime("%Y-%m-%d",time.localtime())
for line in fileinput.input(inplace=1, backup=".orig"):
    sys.stdout.write(line.replace("DATE",today))

# set up to iterate over the *.c files in the current directory,
# editing in place and saving the old file with a .orig extension.
import glob, re
match = re.compile("(?<=[pP])earl")
files = fileinput.FileInput(glob.glob("*.c"), inplace=1, backup=".orig")
while True:
    line = files.readline()
    sys.stderr.write(line)
    if not line:
        break
    if files.isfirstline():
        sys.stdout.write("This line should appear at the top of each file\n")
    sys.stdout.write(match.sub("erl",line))


# @@PLEAC@@_7.10
#-----------------------------
myfile = open(filename, "r+")
data = myfile.read()
# change data here
myfile.seek(0, 0)
myfile.write(data)
myfile.truncate(myfile.tell())
myfile.close()
#-----------------------------
myfile = open(filename, "r+")
data = [process(line) for line in myfile]
myfile.seek(0, 0)
myfile.writelines(data)
myfile.truncate(myfile.tell())
myfile.close()
#-----------------------------

# @@PLEAC@@_7.11
                                                                                                                                                                                                                                                               
import fcntl
myfile = open(somepath, 'r+')
fcntl.flock(myfile, fcntl.LOCK_EX)
# update file, then...
myfile.close()
#-----------------------------
fcntl.LOCK_SH
fcntl.LOCK_EX
fcntl.LOCK_NB
fcntl.LOCK_UN
#-----------------------------
import warnings
try:
    fcntl.flock(myfile, fcntl.LOCK_EX|fcntl.LOCK_NB)
except IOError:
    warnings.warn("can't immediately write-lock the file ($!), blocking ...")
    fcntl.flock(myfile, fcntl.LOCK_EX)
#-----------------------------
fcntl.flock(myfile, fcntl.LOCK_UN)
#-----------------------------
# option "r+" instead "w+" stops python from truncating the file on opening
# when another process might well hold an advisory exclusive lock on it.
myfile = open(somepath, "r+")
fcntl.flock(myfile, fcntl.LOCK_EX)
myfile.seek(0, 0)
myfile.truncate(0)
print>>myfile, "\n"   # or myfile.write("\n")
myfile.close()
#-----------------------------

# @@PLEAC@@_7.12
# Python doesn't have command buffering.  Files can have buffering set,
# when opened:
myfile = open(filename, "r", buffering=0)   #Unbuffered
myfile = open(filename, "r", buffering=1)   #Line buffered
myfile = open(filename, "r", buffering=100) #Use buffer of (approx) 100 bytes
myfile = open(filename, "r", buffering=-1)  #Use system default

myfile.flush()  # Flush the I/O buffer

# stdout is treated as a file.  If you ever need to flush it, do so:
import sys
sys.stdout.flush()

# DON'T DO THIS.  Use urllib, etc.
import socket
mysock = socket.socket()
mysock.connect(('www.perl.com', 80))
# mysock.setblocking(True)
mysock.send("GET /index.html http/1.1\n\n")
f = mysock.makefile()
print "Doc is:"
for line in f:
    print line[:-1]

# @@PLEAC@@_7.13
import select
while True:
    rlist, wlist, xlist = select.select([file1, file2, file3], [], [], 0)
    for r in rlist:
        pass # Do something with the file handle

# @@PLEAC@@_7.14
# @@SKIP@@ Use select.poll() on Unix systems.
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_7.15
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_7.16
# NOTE: this is all much easier in Python
def subroutine(myfile):
    print>>myfile, "Hello, file"

variable = myfile
subroutine(variable)

# @@PLEAC@@_7.17
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_7.18
for myfile in files:
    print>>myfile, stuff_to_print

# NOTE: This is unix specific
import os
file = os.popen("tee file1 file2 file3 >/dev/null", "w")
print>>myfile, "whatever"

# NOTE: the "make STDOUT go to three files" is bad programming style
import os, sys
sys.stdout.file = os.popen("tee file1 file2 file3", "w")
print "whatever"
sys.stdout.close()

# You could use a utility object to redirect writes:
class FileDispatcher(object):
    def __init__(self, *files):
        self.files = files

    def write(self, msg):
        for f in self.files:
            f.write(msg)

    def close(self):
        for f in self.files:
            f.close()

x = open("C:/test1.txt", "w")
y = open("C:/test2.txt", "w")
z = open("C:/test3.txt", "w")

fd = FileDispatcher(x, y, z)
print>>fd, "Foo"     # equiv to fd.write("Foo"); fd.write("\n")
print>>fd, "Testing"  
fd.close()

# @@PLEAC@@_7.19
import os
myfile = os.fdopen(fdnum) # open the descriptor itself
myfile = os.fdopen(os.dup(fdnum)) # open to a copy of the descriptor

###
outcopy = os.fdopen(os.dup(sys.stdin.fileno()), "w")
incopy = os.fdopen(os.dup(sys.stdin.fileno()), "r")

# @@PLEAC@@_7.20
original = open("C:/test.txt")
alias = original
alias.close()
print original.closed
#=>True

import copy

original = open("C:/test.txt")
dupe = copy.copy(original)
dupe.close()
print original.closed
#=>False

# DON'T DO THIS.
import sys
oldstderr = sys.stderr
oldstdout = sys.stdout

sys.stderr = open("C:/stderrfile.txt")
sys.stdout = open("C:/stdoutfile.txt")

print "Blah"  # Will be written to C:/stdoutfile.txt
sys.stdout.close()

sys.stdout = oldstdout
sys.stderr = oldstderr


# @@PLEAC@@_7.21
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_7.22
# On Windows:
import msvcrt
myfile.seek(5, 0)
msvcrt.locking(myfile.fileno(), msvcrt.LK_NBLCK, 3)

# On Unix:
import fcntl
fcntl.lockf(myfile.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB, 3, 5)


# ^^PLEAC^^_8.0
#-----------------------------
for line in DATAFILE:
    line = line.rstrip()
    size = len(line)
    print size        # output size of line

#-----------------------------
for line in datafile:
    print length(line.rstrip())     # output size of line
#-----------------------------
lines = datafile.readlines()
#-----------------------------
whole_file = myfile.read()
#-----------------------------
## No direct equivalent in Python
#% perl -040 -e '$word = <>; print "First word is $word\n";'
#-----------------------------
## No direct equivalent in Python
#% perl -ne 'BEGIN { $/="%%\n" } chomp; print if /Unix/i' fortune.dat
#-----------------------------
print>>myfile, "One", "two", "three"  # "One two three"
print "Baa baa black sheep."         # Sent to default output file
#-----------------------------
buffer = myfile.read(4096)
rv = len(buffer)
#-----------------------------
myfile.truncate(length)
open("/tmp/%d.pid" % os.getpid(), "a").truncate(length)
#-----------------------------
pos = myfile.tell()
print "I'm", pos, "bytes from the start of DATAFILE."
#-----------------------------
logfile.seek(0, 2)   # Seek to the end
datafile.seek(pos)   # Seek to a given byte
outfile.seek(-20, 1) # Seek back 20 bytes
#-----------------------------
written = os.write(datafile.fileno(), mystr)
if written != len(mystr):
    warnings.warn("only read %s bytes, not %s" % (written, len(mystr)))
#-----------------------------
pos = os.lseek(myfile.fileno(), 0, 1)       # don't change position
#-----------------------------

 
# ^^PLEAC^^_8.1
def ContReader(infile):
    lines = []
    for line in infile:
        line = line.rstrip()
        if line.endswith("\\"):
            lines.append(line[:-1])
            continue
        lines.append(line)
        yield "".join(lines)
        lines = []
    if lines:
        yield "".join(lines)

for line in ContReader(datafile):
    pass # process full record in 'line' here

# ^^PLEAC^^_8.2
import os
count = int(os.popen("wc -l < " + filename).read())
#-----------------------------
for count, line in enumerate(open(filename)):
    pass
count += 1  # indexing is zero based
#-----------------------------
myfile = open(filename)
count = 0
for line in myfile:
    count += 1
# 'count' now holds the number of lines read
#-----------------------------
myfile = open(filename)
count = 0
while True:
    line = myfile.readline()
    if not line:
        break
    count += 1
#-----------------------------
count = 0
while True:
    s = myfile.read(2**16)
    count += s.count("\n")
#-----------------------------
for line, count in zip(open(filename), xrange(1, sys.maxint)):
    pass
# 'count' now holds the number of lines read
#-----------------------------
import fileinput
fi = fileinput.FileInput(filename)
while fi.readline(): pass

count = fi.lineno()
#-----------------------------
def SepReader(infile, sep = "\n\n"):
    text = infile.read(10000)
    if not text:
        return
    while True:
        fields = text.split(sep)
        for field in fields[:-1]:
            yield field
        text = fields[-1]
        new_text = infile.read(10000)
        if not new_text:
            yield text
            break
        text += new_text

para_count = 0
for para in SepReader(open(filename)):
    para_count += 1
# FIXME: For my test case (Python-pre2.2 README from CVS) this
# returns 175 paragraphs while Perl returns 174.
#-----------------------------

 
# ^^PLEAC^^_8.3
for line in sys.stdin:
    for word in line.split():
        pass # do something with 'chunk'
#-----------------------------
pat = re.compile(r"(\w[\w'-]*)")
for line in sys.stdin:
    pos = 0
    while True:
        match = pat.search(line, pos)
        if not match:
            break
        pos = match.end(1)
        # do something with match.group(1)

# EXPERIMENTAL in the sre implementation but
# likely to be included in future (post-2.2) releases.
pat = re.compile(r"(\w[\w'-]*)")
for line in sys.stdin:
    scanner = pat.scanner(line)
    while True:
        match = scanner.search()
        if not match:
            break
        # do something with match.group(1)


#-----------------------------
# Make a word frequency count
import fileinput, re
pat = re.compile(r"(\w[\w'-]*)")
seen = {}
for line in fileinput.input():
    pos = 0
    while True:
        match = pat.search(line, pos)
        if not match:
            break
        pos = match.end(1)
        text = match.group(1).lower()
        seen[text] = seen.get(text, 0) + 1

# output dict in a descending numeric sort of its values
for text, count in sorted(seen.items, key=lambda item: item[1]):
    print "%5d %s" % (count, text)

#-----------------------------
# Line frequency count
import fileinput, sys
seen = {}
for line in fileinput.input():
    text = line.lower()
    seen[text] = seen.get(text, 0) + 1

for text, count in sorted(seen.items, key=lambda item: item[1]):
    sys.stdout.write("%5d %s" % (count, text))

#-----------------------------

 
# ^^PLEAC^^_8.4
lines = myfile.readlines()
while lines:
    line = lines.pop()
    # do something with 'line'

#-----------------------------
for line in reversed(myfile):
    pass  # do something with line
#-----------------------------
for i in range(len(lines)):
    line = lines[-i]
#-----------------------------
for paragraph in sorted(SepReader(infile)):
    pass # do something
#-----------------------------

 

# ^^PLEAC^^_8.5
import time
while True:
    for line in infile:
        pass # do something with the line
    time.sleep(SOMETIME)
    infile.seek(0, 1)
#-----------------------------
import time
naptime = 1

logfile = open("/tmp/logfile")
while True:
    for line in logfile:
        print line.rstrip()
    time.sleep(naptime)
    infile.seek(0, 1)
#-----------------------------
while True:
    curpos = logfile.tell()
    while True:
        line = logfile.readline()
        if not line:
            break
        curpos = logfile.tell()
    sleep(naptime)
    logfile.seek(curpos, 0)  # seek to where we had been
#-----------------------------
import os
if os.stat(LOGFILENAME).st_nlink == 0:
    raise SystemExit
#-----------------------------

 
# ^^PLEAC^^_8.6
import random, fileinput
text = None
for line in fileinput.input():
    if random.randrange(fileinput.lineno()) == 0:
        text = line
# 'text' is the random line
#-----------------------------
# XXX is the perl code correct?  Where is the fortunes file opened?
import sys
adage = None
for i, rec in enumerate(SepReader(open("/usr/share/games/fortunes"), "%\n")):
    if random.randrange(i+1) == 0:
        adage = rec
print adage
#-----------------------------

 
# ^^PLEAC^^_8.7
import random
lines = data.readlines()
random.shuffle(lines)
for line in lines:
    print line.rstrip()
#-----------------------------

 

# ^^PLEAC^^_8.8
# using efficient caching system
import linecache
linecache.getline(filename, DESIRED_LINE_NUMBER)

# or doing it more oldskool
lineno = 0
while True:
    line = infile.readline()
    if not line or lineno == DESIRED_LINE_NUMBER:
        break
    lineno += 1
#-----------------------------
lines = infile.readlines()
line = lines[DESIRED_LINE_NUMBER]
#-----------------------------
for i in range(DESIRED_LINE_NUMBER):
    line = infile.readline()
    if not line:
        break
#-----------------------------

## Not sure what this thing is doing.  Allow fast access to a given
## line number?

# usage: build_index(*DATA_HANDLE, *INDEX_HANDLE)

# ^^PLEAC^^_8.9
# given $RECORD with field separated by PATTERN,
# extract @FIELDS.
fields = re.split(pattern_string, text)
#-----------------------------
pat = re.compile(pattern_string)
fields = pat.split(text)
#-----------------------------
re.split(r"([+-])", "3+5-2")
#-----------------------------
[3, '+', 5, '-', 2]
#-----------------------------
fields = record.split(":")
#-----------------------------
fields = re.split(r":", record)
#-----------------------------
fields = re.split(r"\s+", record)
#-----------------------------
fields = record.split(" ")
#-----------------------------

 
# ^^PLEAC^^_8.10
myfile = open(filename, "r")
prev_pos = pos = 0
while True:
    line = myfile.readline()
    if not line:
        break
    prev_pos = pos
    pos = myfile.tell()
myfile = open(filename, "a")
myfile.truncate(prev_pos)
#-----------------------------

 

# ^^PLEAC^^_8.11
open(filename, "rb")
open(filename, "wb")
#-----------------------------
gifname = "picture.gif"
gif_file = open(gifname, "rb")

# Don't think there's an equivalent for these in Python
#binmode(GIF);               # now DOS won't mangle binary input from GIF
#binmode(STDOUT);            # now DOS won't mangle binary output to STDOUT

#-----------------------------
while True:
    buff = gif.read(8 * 2**10)
    if not buff:
        break
    sys.stdout.write(buff)
#-----------------------------

 

# ^^PLEAC^^_8.12
address = recsize * recno
myfile.seek(address, 0)
buffer = myfile.read(recsize)
#-----------------------------
address = recsize * (recno-1)
#-----------------------------

 

# ^^PLEAC^^_8.13
import posixfile
address = recsize * recno
myfile.seek(address)
buffer = myfile.read(recsize)
# ... work with the buffer, then turn it back into a string and ...
myfile.seek(-recsize, posixfile.SEEK_CUR)
myfile.write(buffer)
myfile.close()
#-----------------------------
## Not yet implemented
# weekearly -- set someone's login date back a week
# @@INCOMPLETE@@


# ^^PLEAC^^_8.14
## Note: this isn't optimal -- the 's+=c' may go O(N**2) so don't
## use for large strings.
myfile.seek(addr)
s = ""
while True:
    c = myfile.read(1)
    if not c or c == "\0":
        break
    s += c
#-----------------------------
myfile.seek(addr)
offset = 0
while True:
    s = myfile.read(1000)
    x = s.find("\0")
    if x != -1:
        offset += x
        break
    offset += len(s)
    if len(s) != 1000:  # EOF
        break
myfile.seek(addr)
s = myfile.read(offset - 1)
myfile.read(1)

#-----------------------------
## Not Implemented
# bgets - get a string from an address in a binary file
#-----------------------------
#!/usr/bin/perl
# strings - pull strings out of a binary file
import re, sys

## Assumes SepReader from above

pat = re.compile(r"([\040-\176\s]{4,})")
for block in SepReader(sys.stdin, "\0"):
    pos = 0
    while True:
        match = pat.search(block, pos)
        if not match:
            break
        print match.group(1)
        pos = match.end(1)
#-----------------------------
 

# @@PLEAC@@_8.15

# RECORDSIZE is the length of a record, in bytes.
# TEMPLATE is the unpack template for the record
# FILE is the file to read from
# FIELDS is a tuple, one element per field
import struct
RECORDSIZE= struct.calcsize(TEMPLATE)
while True:
    record = FILE.read(RECORDSIZE):
    if len(record)!=RECORDSIZE:
        raise "short read"
    FIELDS = struct.unpack(TEMPLATE, record)
# ----


# ^^PLEAC^^_8.16
# NOTE: to parse INI file, see the stanard ConfigParser module.
import re
pat = re.compile(r"\s*=\s*")
for line in config_file:
    if "#" in line:         # no comments
        line = line[:line.index("#")]
    line = line.strip()     # no leading or trailing white
    if not line:            # anything left?
        continue
    m = pat.search(line)
    var = line[:m.start()]
    value = line[m.end():]
    User_Preferences[var] = value


# ^^PLEAC^^_8.17
import os

mode, ino, dev, nlink, uid, gid, size, \
atime, mtime, ctime = os.stat(filename)

mode &= 07777               # discard file type info

#-----------------------------
info = os.stat(filename)
if info.st_uid == 0:
    print "Superuser owns", filename
if info.st_atime > info.st_mtime:
    print filename, "has been read since it was written."
#-----------------------------
import os
def is_safe(path):
    info = os.stat(path)

    # owner neither superuser nor me 
    # the real uid is in stored in the $< variable
    if info.st_uid not in (0, os.getuid()):
        return False

    # check whether group or other can write file.
    # use 066 to detect either reading or writing
    if info.st_mode & 022:  # someone else can write this
        if not os.path.isdir(path):  # non-directories aren't safe
            return False
        # but directories with the sticky bit (01000) are
        if not (info.st_mode & 01000):
            return False
    return True
#-----------------------------
## XXX What is '_PC_CHOWN_RESTRICTED'?

def is_verysafe(path):
    terms = []
    while True:
        path, ending = os.path.split(path)
        if not ending:
            break
        terms.insert(0, ending)
    for term in terms:
        path = os.path.join(path, term)
        if not is_safe(path):
            return False
    return True
#-----------------------------

# Program: tctee
# Not Implemented (requires reimplementing Perl's builtin '>>', '|',
# etc. semantics)

# @@PLEAC@@_8.18
#!/usr/bin/python
# tailwtmp - watch for logins and logouts;
# uses linux utmp structure, from /usr/include/bits/utmp.h

# /* The structure describing an entry in the user accounting database.  */
# struct utmp
# {
#   short int ut_type;            /* Type of login.  */
#   pid_t ut_pid;                 /* Process ID of login process.  */
#   char ut_line[UT_LINESIZE];    /* Devicename.  */
#   char ut_id[4];                /* Inittab ID.  */
#   char ut_user[UT_NAMESIZE];    /* Username.  */
#   char ut_host[UT_HOSTSIZE];    /* Hostname for remote login.  */
#   struct exit_status ut_exit;   /* Exit status of a process marked
#                                    as DEAD_PROCESS.  */
#   long int ut_session;          /* Session ID, used for windowing.  */
#   struct timeval ut_tv;         /* Time entry was made.  */
#   int32_t ut_addr_v6[4];        /* Internet address of remote host.  */
#   char __unused[20];            /* Reserved for future use.  */
# };

# /* Values for the `ut_type' field of a `struct utmp'.  */
# #define EMPTY       0   /* No valid user accounting information.  */
# 
# #define RUN_LVL     1   /* The system's runlevel.  */
# #define BOOT_TIME   2   /* Time of system boot.  */
# #define NEW_TIME    3   /* Time after system clock changed.  */
# #define OLD_TIME    4   /* Time when system clock changed.  */
# 
# #define INIT_PROCESS    5   /* Process spawned by the init process.  */
# #define LOGIN_PROCESS   6   /* Session leader of a logged in user.  */
# #define USER_PROCESS    7   /* Normal process.  */
# #define DEAD_PROCESS    8   /* Terminated process.  */
# 
# #define ACCOUNTING  9

import time
import struct
import os

class WTmpRecord:
    fmt = "hI32s4s32s256siili4l20s";
    _fieldnames = ["type","PID","Line","inittab","User","Hostname",
                    "exit_status", "session", "time", "addr" ]
    def __init__(self):
        self._rec_size = struct.calcsize(self.fmt)
    def size(self):
        return self._rec_size
    def unpack(self, bin_data):
        rec = struct.unpack(self.fmt, bin_data)
        self._rec = []
        for i in range(len(rec)):
            if i in (2,3,4,5):
                # remove character zeros from strings
                self._rec.append( rec[i].split("\0")[0] )
            else:
                self._rec.append(rec[i])
        return self._rec
    def fieldnames(self):
        return self._fieldnames
    def __getattr__(self,name):
        return self._rec[self._fieldnames.index(name)]
        
rec = WTmpRecord()
f = open("/var/log/wtmp","rb")
f.seek(0,2)
while True:
    while True:
        bin = f.read(rec.size())
        if len(bin) != rec.size():
            break
        rec.unpack(bin)
        if rec.type != 0:
            print " %1d %-8s %-12s %-24s %-20s %5d %08x" % \
                (rec.type, rec.User, rec.Line, 
                 time.strftime("%a %Y-%m-%d %H:%M:%S",time.localtime(rec.time)),
                 rec.Hostname, rec.PID, rec.addr)
    time.sleep(1)
f.close()

# @@PLEAC@@_8.19
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_8.20
#!/usr/bin/python
# laston - find out when given user last logged on
import sys
import struct
import pwd
import time
import re

f = open("/var/log/lastlog","rb")

fmt = "L32s256s"
rec_size = struct.calcsize(fmt)

for user in sys.argv[1:]:
    if re.match(r"^\d+$", user):
        user_id = int(user)
    else:
        try:
            user_id = pwd.getpwnam(user)[2]
        except:
            print "no such uid %s" % (user)
            continue
    f.seek(rec_size * user_id)
    bin = f.read(rec_size)
    if len(bin) == rec_size:
        data = struct.unpack(fmt, bin)
        if data[0]:
            logged_in = "at %s" % (time.strftime("%a %H:%M:%S %Y-%m-%d",
                                    time.localtime(data[0])))
            line = " on %s" % (data[1])
            host = " from %s" % (data[2])
        else:
            logged_in = "never logged in"
            line = ""
            host = ""
        print "%-8s UID %5d %s%s%s" % (user, user_id, logged_in, line, host)
    else:
        print "Read failed."
f.close()


# ^^PLEAC^^_9.0
#-----------------------------
entry = os.stat("/usr/bin/vi")
#-----------------------------
entry = os.stat("/usr/bin")
#-----------------------------
entry = os.stat(INFILE.name)
#-----------------------------
entry = os.stat("/usr/bin/vi")
ctime = entry.st_ino
size = entry.st_size
#-----------------------------
f = open(filename)

f.seek(0, 2)
if not f.tell():
    raise SystemExit("%s doesn't have text in it."%filename)
#-----------------------------

for filename in os.listdir("/usr/bin"):
    print "Inside /usr/bin is something called", filename
#-----------------------------

# ^^PLEAC^^_9.1
#-----------------------------
fstat = os.stat(filename)
readtime = fstat.st_atime
writetime = fstat.st_mtime

os.utime(filename, (newreadtime, newwritetime))

#DON'T DO THIS:
readtime, writetime = os.stat(filename)[7:9]
#-----------------------------
SECONDS_PER_DAY = 60 * 60 * 24
fstat = os.stat(filename)
atime = fstat.st_atime - 7 * SECONDS_PER_DAY
mtime = fstat.st_mtime - 7 * SECONDS_PER_DAY

os.utime(filename, (atime, mtime))     
#-----------------------------
mtime = os.stat(filename).st_mtime
utime(filename, (time.time(), mtime))
#-----------------------------
#!/usr/bin/perl -w
# uvi - vi a file without changing its access times

import sys, os
if len(sys.argv) != 2:
    raise SystemExit("usage: uvi filename")
filename = argv[1]
fstat = os.stat(filename)
# WARNING: potential security risk
os.system( (os.environ.get("EDITOR") or "vi") + " " + filename)
os.utime(filename, (fstat.st_atime, fstat.st_mtime))
#-----------------------------

# ^^PLEAC^^_9.2
#-----------------------------
os.remove(filename)

err_flg = 0
for filename in filenames:
    try:
        os.remove(filename)
    except OSError, err:
        err_flg = 1
if err_flg:
    raise OSError("Couldn't remove all of %s: %s" % (filenames, err))
#-----------------------------
os.remove(filename)
#-----------------------------
success = 0
for filename in filenames:
    try:
        os.remove(filename)
        success += 1
    except OSError, err:
        pass
if success != len(filenames):
    sys.stderr.write("could only delete %d of %d files" % \
                     (success, len(filenames)))

#-----------------------------

# ^^PLEAC^^_9.3
#-----------------------------
import shutil
shutil.copy(oldfile, newfile)
#-----------------------------
## NOTE: this doesn't do the same thing as the Perl code,
## eg, handling of partial writes.
infile = open(oldfile)
outfile = open(newfile, "w")

blksize = 16384          # preferred block size?

while True:
    buf = infile.read(blksize)
    if not buf:
        break
    outfile.write(buf)

infile.close()
outfile.close()
#-----------------------------
# WARNING: these are insecure - do not use in hostile environments
os.system("cp %s %s" % (oldfile, newfile))       # unix
os.system("copy %s %s" % (oldfile, newfile))     # dos, vms
#-----------------------------
import shutil

shutil.copy("datafile.dat", "datafile.bak")

shutil.copy("datafile.new", "datafile.dat")
os.remove("datafile.new")

#-----------------------------

# ^^PLEAC^^_9.4
#-----------------------------
import os
seen = {}

def do_my_thing(filename):
    fstat = os.stat(filename)
    key = (fstat.st_ino, fstat.st_dev)
    if not seen.get(key):
        # do something with filename because we haven't
        # seen it before
        pass
    seen[key] = seen.get(key, 0 ) + 1

#-----------------------------
for filename in files:
    fstat = os.stat(filename)
    key = (fstat.st_ino, fstat.st_dev)
    seen.setdefault(key, []).append(filename)

keys = seen.keys()
keys.sort()
for inodev in keys:
    ino, dev = inodev
    filenames = seen[inodev]
    if len(filenames) > 1:
        # 'filenames' is a list of filenames for the same file
        pass
#-----------------------------

# ^^PLEAC^^_9.5
#-----------------------------
for filename in os.listdir(dirname):
    # do something with "$dirname/$file"
    pass
#-----------------------------
# XXX No -T equivalent in Python
#-----------------------------
# 'readir' always skipes '.' and '..' on OSes where those are
# standard directory names
for filename in os.listdir(dirname):
    pass
#-----------------------------
# XX Not Implemented -- need to know what DirHandle does
# use DirHandle;

#-----------------------------

# ^^PLEAC^^_9.6
#-----------------------------
import glob
filenames = glob.glob("*.c")
#-----------------------------
filenames = [filename for filename in os.listdir(path) if filename.endswith(".c")] 
#-----------------------------
import re
allowed_name = re.compile(r"\.[ch]$", re.I).search
filenames = [f for f in os.listdir(path) if allowed_name(f)]
#-----------------------------
import re, os
allowed_name = re.compile(r"\.[ch]$", re.I).search

fnames = [os.path.join(dirname, fname) 
              for fname in os.listdir(dirname)
              if allowed_name(fname)]
#-----------------------------
dirs = [os.path.join(path, f)
            for f in os.listdir(path) if f.isdigit()]
dirs = [d for d in dirs if os.path.isdir(d)]
dirs = sorted(dirs, key=int)    # Sort by numeric value - "9" before "11"
#-----------------------------

# @@PLEAC@@_9.7
# Processing All Files in a Directory Recursively

# os.walk is new in 2.3.

# For pre-2.3 code, there is os.path.walk, which is
# little harder to use.

#-----------------------------
import os
for root, dirs, files in os.walk(top):
    pass # do whatever

#-----------------------------
import os, os.path
for root, dirs, files in os.walk(top):
    for name in dirs:
        print os.path.join(root, name) + '/'
    for name in files:
        print os.path.join(root, name)

#-----------------------------
import os, os.path
numbytes = 0
for root, dirs, files in os.walk(top):
    for name in files:
        path = os.path.join(root, name)
        numbytes += os.path.getsize(path)
print "%s contains %s bytes" % (top, numbytes)

#-----------------------------
import os, os.path
saved_size, saved_name = -1, ''
for root, dirs, files in os.walk(top):
    for name in files:
        path = os.path.join(root, name)
        size = os.path.getsize(path)
        if size > saved_size:
            saved_size = size
            saved_name = path
print "Biggest file %s in %s is %s bytes long" % (
    saved_name, top, saved_size)

#-----------------------------
import os, os.path, time
saved_age, saved_name = None, ''
for root, dirs, files in os.walk(top):
    for name in files:
        path = os.path.join(root, name)
        age = os.path.getmtime(path)
        if saved_age is None or age > saved_age:
            saved_age = age
            saved_name = path
print "%s %s" % (saved_name, time.ctime(saved_age))

#-----------------------------
#!/usr/bin/env python
# fdirs - find all directories
import sys, os, os.path
argv = sys.argv[1:] or ['.']
for top in argv:
    for root, dirs, files in os.walk(top):
        for name in dirs:
            path = os.path.join(root, name)
            print path


# ^^PLEAC^^_9.8
#-----------------------------
# DeleteDir - remove whole directory trees like rm -r
import shutil
shutil.rmtree(path)

# DON'T DO THIS:
import os, sys
def DeleteDir(dir):
    for name in os.listdir(dir):
        file = os.path.join(dir, name)
        if not os.path.islink(file) and os.path.isdir(file):
            DeleteDir(file)
        else:
            os.remove(file)
    os.rmdir(dir)

# @@PLEAC@@_9.9
# Renaming Files

# code sample one to one from my perlcookbook
# looks strange to me.
import os
for fname in fnames:
    newname = fname
    # change the file's name
    try:
        os.rename(fname, newname)
    except OSError, err:
        print "Couldn't rename %s to %s: %s!" % \
                (fname, newfile, err)

# use os.renames if newname needs directory creation.

#A vaguely Pythonic solution is:
import glob
def rename(files, transfunc)
    for fname in fnames:
        newname = transfunc(fname)
        try:
            os.rename(fname, newname)
        except OSError, err:
            print "Couldn't rename %s to %s: %s!" % \
                  (fname, newfile, err)

def transfunc(fname): 
    return fname[:-5]
rename(glob.glob("*.orig"), transfunc) 

def transfunc(fname): 
    return fname.lower()
rename([f for f in glob.glob("*") if not f.startswith("Make)], transfunc) 

def transfunc(fname): 
    return fname + ".bad"
rename(glob.glob("*.f"), transfunc) 

def transfunc(fname): 
    answer = raw_input(fname + ": ")
    if answer.upper().startswith("Y"):
        return fname.replace("foo", "bar")
rename(glob.glob("*"), transfunc) 

def transfunc(fname):
    return ".#" + fname[:-1]
rename(glob.glob("/tmp/*~"), transfunc) 

# This _could_ be made to eval code taken directly from the command line, 
# but it would be fragile
#-----------------------------

# ^^PLEAC^^_9.10
#-----------------------------
import os

base = os.path.basename(path)
dirname = os.path.dirname(path)
dirname, filename = os.path.split(path)
base, ext = os.path.splitext(filename)

#-----------------------------
path = '/usr/lib/libc.a'
filename = os.path.basename(path)
dirname = os.path.dirname(path)

print "dir is %s, file is %s" % (dirname, filename)
# dir is /usr/lib, file is libc.a
#-----------------------------
path = '/usr/lib/libc.a'
dirname, filename = os.path.split(path)
name, ext = os.path.splitext(filename)

print "dir is %s, name is %s, extension is %s" % (dirname, name, ext)
#   NOTE: The Python code prints
# dir is /usr/lib, name is libc, extension is .a
#   while the Perl code prints a '/' after the directory name
# dir is /usr/lib/, name is libc, extension is .a
#-----------------------------
import macpath
path = "Hard%20Drive:System%20Folder:README.txt"
dirname, base = macpath.split(path)
name, ext = macpath.splitext(base)

print "dir is %s, name is %s, extension is %s" % (dirname, name, ext)
# dir is Hard%20Drive:System%20Folder, name is README, extension is .txt
#-----------------------------
# DON'T DO THIS - it's not portable.
def extension(path):
    pos = path.find(".")
    if pos == -1:
        return ""
    ext = path[pos+1:]
    if "/" in ext:
        # wasn't passed a basename -- this is of the form 'x.y/z'
        return ""
    return ext
#-----------------------------

# @@PLEAC@@_9.11

#!/usr/bin/python
# sysmirror - build spectral forest of symlinks
import sys, os, os.path

pgmname = sys.argv[0]
if len(sys.argv)!=3:
    print "usage: %s realdir mirrordir" % pgmname
    raise SystemExit

(srcdir, dstdir) = sys.argv[1:3]
if not os.path.isdir(srcdir):
    print "%s: %s is not a directory" % (pgmname,srcdir)
    raise SystemExit
if not os.path.isdir(dstdir):
    try:
        os.mkdir(dstdir)
    except OSError:
        print "%s: can't make directory %s" % (pgmname,dstdir)
          raise SystemExit

# fix relative paths
srcdir = os.path.abspath(srcdir)
dstdir = os.path.abspath(dstdir)

def wanted(arg, dirname, names):
    for direntry in names:
        relname = "%s/%s" % (dirname, direntry)
        if os.path.isdir(relname):
            mode = os.stat(relname).st_mode
            try:
                os.mkdir("%s/%s" % (dstdir,relname), mode)
            except:
                print "can't mkdir %s/%s" % (dstdir,relname)
                raise SystemExit
        else:
            if relname[:2] == "./":
                relname = relname[2:]
            os.symlink("%s/%s" % (srcdir, relname), "%s/%s" % (dstdir,relname))

os.chdir(srcdir)
os.path.walk(".",wanted,None)

# @@PLEAC@@_9.12
# @@INCOMPLETE@@
# @@INCOMPLETE@@


# ^^PLEAC^^_10.0
#-----------------------------
# DO NOT DO THIS...
greeted = 0
def hello():
    global greeted
    greeted += 1
    print "hi there"

#... as using a callable object to save state is cleaner
# class hello
#     def __init__(self):
#         self.greeted = 0
#     def __call__(self):
#         self.greeted += 1
#         print "hi there"
# hello = hello()
#-----------------------------
hello()                 # call subroutine hello with no arguments/parameters
#-----------------------------

# ^^PLEAC^^_10.1
#-----------------------------
import math
# Provided for demonstration purposes only.  Use math.hypot() instead.
def hypotenuse(side1, side2):
    return math.sqrt(side1**2 + side2**2)

diag = hypotenuse(3, 4)  # diag is 5.0
#-----------------------------
print hypotenuse(3, 4)               # prints 5.0

a = (3, 4)
print hypotenuse(*a)                 # prints 5.0
#-----------------------------
both = men + women
#-----------------------------
nums = [1.4, 3.5, 6.7]
# Provided for demonstration purposes only.  Use:
#     ints = [int(num) for num in nums] 
def int_all(nums):
    retlist = []            # make new list for return
    for n in nums:
        retlist.append(int(n))
    return retlist
ints = int_all(nums)        # nums unchanged
#-----------------------------
nums = [1.4, 3.5, 6.7]

def trunc_em(nums):
    for i,elem in enumerate(nums):
        nums[i] = int(elem)
trunc_em(nums)               # nums now [1,3,6]

#-----------------------------
# By convention, if a method (or function) modifies an object
# in-place, it returns None rather than the modified object.
# None of Python's built-in functions modify in-place; methods
# such as list.sort() are somewhat more common.
mylist = [3,2,1]
mylist = mylist.sort()   # incorrect - returns None
mylist = sorted(mylist)  # correct - returns sorted copy
mylist.sort()            # correct - sorts in-place
#-----------------------------

# ^^PLEAC^^_10.2
#-----------------------------
# Using global variables is discouraged - by default variables
# are visible only at and below the scope at which they are declared.
# Global variables modified by a function or method must be declared 
# using the "global" keyword if they are modified
def somefunc():
    variable = something  # variable is invisible outside of somefunc
#-----------------------------
import sys
name, age = sys.args[1:]  # assumes two and only two command line parameters
start = fetch_time()
#-----------------------------
a, b = pair
c = fetch_time()

def check_x(x):
    y = "whatever"
    run_check()
    if condition:
        print "got", x
#-----------------------------
def save_list(*args):
    Global_List.extend(args)
#-----------------------------

# ^^PLEAC^^_10.3
#-----------------------------
## Python allows static nesting of scopes for reading but not writing,
## preferring to use objects.  The closest equivalent to:
#{
#    my $counter;
#    sub next_counter { return ++$counter }
#}
## is:
def next_counter(counter=[0]):  # default lists are created once only.
    counter[0] += 1
    return counter[0]

# As that's a little tricksy (and can't make more than one counter),
# many Pythonistas would prefer either:
def make_counter():
    counter = 0
    while True:
        counter += 1
        yield counter
next_counter = make_counter().next

# Or:
class Counter:
    def __init__(self):
        self.counter = 0
    def __call__(self):
        self.counter += 1
        return self.counter
next_counter = Counter()

#-----------------------------
## A close equivalent of
#BEGIN {
#    my $counter = 42;
#    sub next_counter { return ++$counter }
#    sub prev_counter { return --$counter }
#}
## is to use a list (to save the counter) and closured functions:
def make_counter(start=0):
    counter = [start]
    def next_counter():
        counter[0] += 1
        return counter[0]
    def prev_counter():
        counter[0] -= 1
        return counter[0]
    return next_counter, prev_counter
next_counter, prev_counter = make_counter()

## A clearer way uses a class:
class Counter:
    def __init__(self, start=0):
        self.value = start
    def next(self):
        self.value += 1
        return self.value
    def prev(self):
        self.value -= 1
        return self.value
    def __int__(self):
        return self.value

counter = Counter(42)
next_counter = counter.next
prev_counter = counter.prev
#-----------------------------

# ^^PLEAC^^_10.4
## This sort of code inspection is liable to change as
## Python evolves.  There may be cleaner ways to do this.
## This also may not work for code called from functions
## written in C.
#-----------------------------
import sys
this_function = sys._getframe(0).f_code.co_name
#-----------------------------
i = 0 # how far up the call stack to look
module = sys._getframe(i).f_globals["__name__"]
filename = sys._getframe(i).f_code.co_filename
line = sys._getframe(i).f_lineno
subr = sys._getframe(i).f_code.co_name
has_args = bool(sys._getframe(i+1).f_code.co_argcount)

# 'wantarray' is Perl specific

#-----------------------------
me = whoami()
him = whowasi()

def whoami():
    sys._getframe(1).f_code.co_name
def whowasi():
    sys._getframe(2).f_code.co_name
#-----------------------------

# ^^PLEAC^^_10.5
#-----------------------------
# Every variable name is a reference to an object, thus nothing special
# needs to be done to pass a list or a dict as a parameter.
list_diff(list1, list2)
#-----------------------------
# Note: if one parameter to zip() is longer it will be truncated
def add_vecpair(x, y):
    return [x1+y1 for x1, y1 in zip(x, y)]

a = [1, 2]
b = [5, 8]
print " ".join([str(n) for n in add_vecpair(a, b)])
#=> 6 10
#-----------------------------
# DO NOT DO THIS:
assert isinstance(x, type([])) and isinstance(y, type([])), \
    "usage: add_vecpair(list1, list2)"
#-----------------------------

# ^^PLEAC^^_10.6
#-----------------------------
# perl return context is not something standard in python...
# but still you can achieve something alike if you really need it
# (but you must really need it badly since you should never use this!!)
#
# see http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/284742 for more
#
# NB: it has been tested under Python 2.3.x and no guarantees can be given
#     that it works under any future Python version.
import inspect,dis

def expecting():
    """Return how many values the caller is expecting"""
    f = inspect.currentframe().f_back.f_back
    bytecode = f.f_code.co_code
    i = f.f_lasti
    instruction = ord(bytecode[i+3])
    if instruction == dis.opmap['UNPACK_SEQUENCE']:
        howmany = ord(bytecode[i+4])
        return howmany
    elif instruction == dis.opmap['POP_TOP']:
        return 0
    return 1

def cleverfunc():
    howmany = expecting()
    if howmany == 0:
        print "return value discarded"
    if howmany == 2:
        return 1,2
    elif howmany == 3:
        return 1,2,3
    return 1

cleverfunc()
x = cleverfunc()
print x
x,y = cleverfunc()
print x,y
x,y,z = cleverfunc()
print x,y,z

# ^^PLEAC^^_10.7
#-----------------------------
thefunc(increment= "20s", start="+5m", finish="+30m")
thefunc(start= "+5m",finish="+30m")
thefunc(finish= "+30m")
thefunc(start="+5m", increment="15s")
#-----------------------------
def thefunc(increment='10s',
            finish='0',
            start='0'):
    if increment.endswith("m"):
        pass
#-----------------------------

# ^^PLEAC^^_10.8
#-----------------------------
a, _, c = func()       # Use _ as a placeholder...
a, ignore, c = func()  # ...or assign to an otherwise unused variable
#-----------------------------

# ^^PLEAC^^_10.9
#-----------------------------
def somefunc():
    mylist = []
    mydict = {}
    # ...
    return mylist, mydict

mylist, mydict = somefunc()
#-----------------------------
def fn():
    return a, b, c

#-----------------------------
h0, h1, h2 = fn()
tuple_of_dicts = fn()   # eg: tuple_of_dicts[2]["keystring"]
r0, r1, r2 = fn()       # eg: r2["keystring"]

#-----------------------------

# ^^PLEAC^^_10.10
#-----------------------------
# Note: Exceptions are almost always preferred to error values
return
#-----------------------------
def empty_retval():
    return None

def empty_retval():
    return          # identical to return None

def empty_retval():
    pass            # None returned by default (empty func needs pass)
#-----------------------------
a = yourfunc()
if a:
    pass
#-----------------------------
a = sfunc()
if not a:
    raise AssertionError("sfunc failed")

assert sfunc(), "sfunc failed"
#-----------------------------

# ^^PLEAC^^_10.11
# Prototypes are inapplicable to Python as Python disallows calling
# functions without using brackets, and user functions are able to
# mimic built-in functions with no special actions required as they
# only flatten lists (and convert dicts to named arguments) if
# explicitly told to do so.  Python functions use named parameters
# rather than shifting arguments:

def myfunc(a, b, c=4):
   print a, b, c

mylist = [1,2]

mydict1 = {"b": 2, "c": 3}
mydict2 = {"b": 2}

myfunc(1,2,3)
#=> 1 2 3

myfunc(1,2)
#=> 1 2 4

myfunc(*mylist)
#=> 1 2 4

myfunc(5, *mylist)
#=> 5, 1, 2

myfunc(5, **mydict1)
#=> 5, 2, 3

myfunc(5, **mydict2)
#=> 5, 2, 4

myfunc(c=3, b=2, a=1)
#=> 1, 2, 3

myfunc(b=2, a=1)
#=> 1, 2, 4

myfunc(mylist, mydict1)
#=> [1, 2] {'c': 3, 'b': 2} 4

# For demonstration purposes only - don't do this
def mypush(mylist, *vals):
   mylist.extend(vals)

mylist = []
mypush(mylist, 1, 2, 3, 4, 5)
print mylist
#=> [1, 2, 3, 4, 5]

# ^^PLEAC^^_10.12
#-----------------------------
raise ValueError("some message")  # specific exception class
raise Exception("use me rarely")  # general exception
raise "don't use me"              # string exception (deprecated)
#-----------------------------
# Note that bare excepts are considered bad style.  Normally you should
# trap specific exceptions.  For instance these bare excepts will
# catch KeyboardInterrupt, SystemExit, and MemoryError as well as
# more common errors.  In addition they force you to import sys to
# get the error message.
import warnings, sys
try:
    func()
except:
    warnings.warn("func raised an exception: " + str(sys.exc_info()[1]))
#-----------------------------
try:
    func()
except:
    warnings.warn("func blew up: " + str(sys.exc_info()[1]))
#-----------------------------
class MoonPhaseError(Exception):
    def __init__(self, phase):
        self.phase = phase
class FullMoonError(MoonPhaseError):
    def __init__(self):
        MoonPhaseError.__init__("full moon")

def func():
    raise FullMoonError()

# Ignore only FullMoonError exceptions
try:
    func()
except FullMoonError:
    pass
#-----------------------------
# Ignore only MoonPhaseError for a full moon
try:
    func()
except MoonPhaseError, err:
    if err.phase != "full moon":
        raise
#-----------------------------

# ^^PLEAC^^_10.13
# There is no direct equivalent to 'local' in Python, and
# it's impossible to write your own.  But then again, even in
# Perl it's considered poor style.

# DON'T DO THIS (You probably shouldn't use global variables anyway):
class Local(object):
    def __init__(self, globalname, val):
        self.globalname = globalname
        self.globalval = globals()[globalname]
        globals()[globalname] = val
        
    def __del__(self):
        globals()[self.globalname] = self.globalval

foo = 4

def blah():
    print foo

def blech():
    temp = Local("foo", 6)
    blah()

blah()
blech()
blah()

#-----------------------------

# ^^PLEAC^^_10.14
#-----------------------------
grow = expand
grow()                     # calls expand()

#-----------------------------
one.var = two.table   # make one.var the same as two.table
one.big = two.small   # make one.big the same as two.small
#-----------------------------
fred = barney     # alias fred to barney
#-----------------------------
s = red("careful here")
print s
#> <FONT COLOR='red'>careful here</FONT>
#-----------------------------
# Note: the 'text' should be HTML escaped if it can contain
# any of the characters '<', '>' or '&'
def red(text):
    return "<FONT COLOR='red'>" + text + "</FONT>"
#-----------------------------
def color_font(color, text):
    return "<FONT COLOR='%s'>%s</FONT>" % (color, text)

def red(text): return color_font("red", text)
def green(text): return color_font("green", text)
def blue(text): return color_font("blue", text)
def purple(text): return color_font("purple", text)
# etc
#-----------------------------
# This is done in Python by making an object, instead of
# saving state in a local anonymous context.
class ColorFont:
    def __init__(self, color):
        self.color = color
    def __call__(self, text):
        return "<FONT COLOR='%s'>%s</FONT>" % (self.color, text)

colors = "red blue green yellow orange purple violet".split(" ")
for name in colors:
    globals()[name] = ColorFont(name)
#-----------------------------
# If you really don't want to make a new class, you can
# fake it somewhat by passing in default args.
colors = "red blue green yellow orange purple violet".split(" ")
for name in colors:
    def temp(text, color = name):
        return "<FONT COLOR='%s'>%s</FONT>" % (color, text)
    globals()[name] = temp

#-----------------------------

# ^^PLEAC^^_10.15

# Python has the ability to derive from ModuleType and add
# new __getattr__ and __setattr__ methods.  I don't know the
# expected way to use them to emulate Perl's AUTOLOAD.  Instead,
# here's how something similar would be done in Python.  This
# uses the ColorFont defined above.

#-----------------------------
class AnyColor:
    def __getattr__(self, name):
        return ColorFont(name)

colors = AnyColor()

print colors.chartreuse("stuff")

#-----------------------------
## Skipping this translation because 'local' is too Perl
## specific, and there isn't enough context to figure out
## what this is supposed to do.
#{
#    local *yellow = \&violet;
#    local (*red, *green) = (\&green, \&red);
#    print_stuff();
#}
#-----------------------------

# ^^PLEAC^^_10.16
#-----------------------------
def outer(arg1):
    x = arg1 + 35
    def inner():
        return x * 19
    return x + inner()
#-----------------------------

# ^^PLEAC^^_10.17
#-----------------------------
import mailbox, sys
mbox = mailbox.PortableUnixMailbox(sys.stdin)

def extract_data(msg, idx):
    subject = msg.getheader("Subject", "").strip()
    if subject[:3].lower() == "re:":
        subject = subject[3:].lstrip()
    text = msg.fp.read()
    return subject, idx, msg, text
messages = [extract_data(idx, msg) for idx, msg in enumerate(mbox)]

#-----------------------------
# Sorts by subject then by original position in the list
for subject, pos, msg, text in sorted(messages):
    print "%s\n%s"%(msg, text)

#-----------------------------
# Sorts by subject then date then original position
def subject_date_position(elem):
    return (elem[0], elem[2].getdate("Date"), elem[1])
messages.sort(key=subject_date_position)

# Pre 2.4:
messages = sorted(messages, key=subject_date_position)
#-----------------------------

# @@PLEAC@@_11.0
#Introduction.
#   In Python, all names are references.
#   All objects are inherently anonymous, they don't know what names refer to them.
print ref   # prints the value that the name ref refers to. 
ref = 3     # assigns the name ref to the value 3.
#-----------------------------
aref = mylist
#-----------------------------
aref = [3, 4, 5]    # aref is a name for this list
href = {"How": "Now", "Brown": "Cow"} # href is a name for this dictionary
#-----------------------------
#   Python doesn't have autovivification as (for simple types) there is no difference between a name and a reference.
#   If we try the equivalent of the Perl code we get the list, not a reference to the list.
#-----------------------------
#   To handle multidimensional arrays, you should use an extension to Python,
#   such as numarray (http://www.stsci.edu/resources/software_hardware/numarray)
#-----------------------------
#   In Python, assignment doesn't return anything. 
#-----------------------------
Nat = { "Name": "Leonhard Euler",
        "Address": "1729 Ramanujan Lane\nMathworld, PI 31416",
        "Birthday": 0x5bb5580
}
#-----------------------------

# @@PLEAC@@_11.1
aref = mylist
anon_list = [1, 3, 5, 7, 9]
anon_copy = anon_list
implicit_creation = [2, 4, 6, 8, 10]
#-----------------------------
anon_list.append(11)
#-----------------------------
two = implicit_creation[0]
#-----------------------------
#  To get the last index of a list, you can use len() 
# [or list.__len__() - but don't] directly
last_idx = len(aref) - 1

# Normally, though, you'd use an index of -1 for the last
# element, -2 for the second last, etc.
print implicit_creation[-1]
#=> 10

num_items = len(aref)
#-----------------------------
last_idx = aref.__len__() - 1
num_items = aref.__len__()
#-----------------------------
if not isinstance(someVar, type([])):
    print "Expected a list"
#-----------------------------
print list_ref
#-----------------------------
#   sort is in place.
list_ref.sort()
#-----------------------------
list_ref.append(item)
#-----------------------------
def list_ref():
    return []

aref1 = list_ref()
aref2 = list_ref()
#   aref1 and aref2 point to different lists.
#-----------------------------
list_ref[N] # refers to the Nth item in the list_ref list.
#-----------------------------
# The following two statements are equivalent and return up to 3 elements
# at indices 3, 4, and 5 (if they exist).
pie[3:6]
pie[3:6:1]
#-----------------------------
#   This will insert 3 elements, overwriting elements at indices 3,4, or 5 - if they exist.
pie[3:6] = ["blackberry", "blueberry", "pumpkin"]
#-----------------------------
for item in pie:
    print item

# DON'T DO THIS (this type of indexing should be done with enumerate)
# xrange does not create a list 0..len(pie) - 1, it creates an object 
# that returns one index at a time.
for idx in xrange(len(pie)):
    print pie[idx]

# @@PLEAC@@_11.2
# Making Hashes of Arrays

hash["KEYNAME"].append("new value")

for mystr in hash.keys():
    print "%s: %s" % (mystr, hash[mystr])

hash["a key"] = [3, 4, 5]

values = hash["a key"]

hash["a key"].append(value)

# autovivification also does not work in python.
residents = phone2name[number]
# do this instead
residents = phone2name.get(number, [])


# @@PLEAC@@_11.3
# Taking References to Hashes

href = hash
anon_hash = { "key1":"value1", "key2" : "value2 ..." }
anon_hash_copy = anon_hash.copy()

hash = href
value = href[key]
slice = [href[k] for k in (key1, key2, key3)]
keys = hash.keys()

import types
if type(someref) != types.DictType:
    raise "Expected a dictionary, not %s" % type(someref)
if isinstance(someref,dict):
    raise "Expected a dictionary, not %s" % type(someref)

for href in ( ENV, INC ):
    for key in href.keys():
        print "%s => %s" % (key, href[key])

values = [hash_ref[k] for k in (key1, key2, key3)]

for key in ("key1", "key2", "key3"):
    hash_ref[k] += 7    # not like in perl but the same result.
#-----------------------------

# @@PLEAC@@_11.4
#-----------------------------
cref = func
cref = lambda a, b: ...
#-----------------------------
returned = cref(arguments)
#-----------------------------
funcname = "thefunc"
locals()[funcname]();
#-----------------------------
commands = {
    'happy': joy,
    'sad': sullen,
    'done': (lambda : sys.exit()),  # In this case "done: sys.exit" would suffice
    'mad': angry,
    }

print "How are you?",
cmd = raw_input()
if cmd in commands:
    commands[cmd]()
else:
    print "No such command: %s" % cmd
#-----------------------------
def counter_maker():
    start = [0]
    def counter_function():
        # start refers to the variable defined in counter_maker, but
        # we can't reassign or increment variables in parent scopes.
        # By using a one-element list we can modify the list without
        # reassigning the variable.  This way of using a list is very
        # like a reference.
        start[0] += 1
        return start[0]-1
    return counter_function

counter = counter_maker()
for i in range(5):
    print counter()
#-----------------------------
counter1 = counter_maker()
counter2 = counter_maker()

for i in range(5):
    print counter1()
print counter1(), counter2()
#=> 0
#=> 1
#=> 2
#=> 3
#=> 4
#=> 5 0
#-----------------------------
import time
def timestamp():
    start_time = time.time()
    def elapsed():
        return time.time() - start_time
    return elapsed
early = timestamp()
time.sleep(20)
later = timestamp()
time.sleep(10)
print "It's been %d seconds since early" % early()
print "It's been %d seconds since later" % later()
#=> It's been 30 seconds since early.
#=> It's been 10 seconds since later.
#-----------------------------

# @@PLEAC@@_11.5
# A name is a reference to an object and an object can be referred to
# by any number of names. There is no way to manipulate pointers or
# an object's id.  This section is thus inapplicable.
x = 1
y = x
print x, id(x), y, id(y)
x += 1    # "x" now refers to a different object than y
print x, id(x), y, id(y)
y = 4     # "y" now refers to a different object than it did before
print x, id(x), y, id(y)

# Some objects (including ints and strings) are immutable, however, which
# can give the illusion of a by-value/by-reference distinction:
a = x = [1]
b = y = 1
c = z = "s"
print a, b, c
#=> [1] 1 s

x += x      # calls list.__iadd__ which is inplace.
y += y      # can't find int.__iadd__ so calls int.__add__ which isn't inplace
z += z      # can't find str.__iadd__ so calls str.__add__ which isn't inplace              
print a, b, c
#=> [1, 1] 1 s

# @@PLEAC@@_11.6
# As indicated by the previous section, everything is referenced, so
# just create a list as normal, and beware that augmented assignment
# works differently with immutable objects to mutable ones:
mylist = [1, "s", [1]]
print mylist
#=> [1, s, [1]]

for elem in mylist:
    elem *= 2
print mylist
#=> [1, s, [1, 1]]

mylist[0] *= 2
mylist[-1] *= 2
print mylist
#=> [1, s, [1, 1, 1, 1]]

# If you need to modify every value in a list, you should use a list comprehension
# which does NOT modify inplace:
import math
mylist = [(val**3 * 4/3*math.pi) for val in mylist]

# @@PLEAC@@_11.7
#-----------------------------
c1 = mkcounter(20)
c2 = mkcounter(77)

print "next c1: %d" % c1['next']()  # 21
print "next c2: %d" % c2['next']()  # 78
print "next c1: %d" % c1['next']()  # 22
print "last c1: %d" % c1['prev']()  # 21
print "old  c2: %d" % c2['reset']() # 77
#-----------------------------
# DON'T DO THIS.  Use an object instead  
def mkcounter(start):
    count = [start]
    def next():
        count[0] += 1
        return count[0]
    def prev():
        count[0] -= 1
        return count[0]
    def get():
        return count[0]
    def set(value):
        count[0] = value
        return count[0]
    def bump(incr):
        count[0] += incr
        return count[0]
    def reset():
        count[0] = start
        return count[0]
    return {
        'next': next, 'prev': prev, 'get': get, 'set': set,
        'bump': bump, 'reset': reset, 'last': prev}
#-----------------------------

# @@PLEAC@@_11.8
#-----------------------------
mref = obj.meth
# later...
mref("args", "go", "here")
#-----------------------------

# @@PLEAC@@_11.9
#-----------------------------
record = {
    "name": "Jason",
    "empno": 132,
    "title": "deputy peon",
    "age": 23,
    "salary": 37000,
    "pals": ["Norbert", "Rhys", "Phineas"],
}
print "I am %s, and my pals are %s." % (record["name"],
                                        ", ".join(record["pals"]))
#-----------------------------
byname = {}
byname[record["name"]] = record

rp = byname.get("Aron")
if rp:
     print "Aron is employee %d."% rp["empno"]

byname["Jason"]["pals"].append("Theodore")
print "Jason now has %d pals." % len(byname["Jason"]["pals"])

for name, record in byname.items():
    print "%s is employee number %d." % (name, record["empno"])

employees = {}
employees[record["empno"]] = record;

# lookup by id
rp = employees.get(132)
if (rp):
    print "Employee number 132 is %s." % rp["name"]

byname["Jason"]["salary"] *= 1.035

peons = [r for r in employees.values() if r["title"] == "peon"]
tsevens = [r for r in employees.values() if r["age"] == 27]

# Go through all records
print employees.values()

for rp in sorted(employees.values(), key=lambda x:x["age"]):
    print "%s is age %d."%(rp["name"], rp["age"])

# use @byage, an array of arrays of records
byage = {}
byage[record["age"]] = byage.get(record["age"], []) + [record]

for age, records in byage.items():
    print records
    print "Age %s:"%age,
    for rp in records:
        print rp["name"],
    print
#-----------------------------

# @@PLEAC@@_11.10
#-----------------------------
FieldName: Value
#-----------------------------
for record in list_of_records:
    # Note: sorted added in Python 2.4
    for key in sorted(record.keys()):
        print "%s: %s" % (key, record[key])
    print
#-----------------------------
import re
list_of_records = [{}]
while True:
    line = sys.stdin.readline()
    if not line:
        # EOF
        break
    # Remove trailing \n:
    line = line[:1]
    if not line.strip():
        # New record
        list_of_records.append({})
        continue
    key, value = re.split(r':\s*', line, 1)
    # Assign the key/value to the last item in the list_of_records:
    list_of_records[-1][key] = value
#-----------------------------
# @@PLEAC@@_11.11
import pprint

mylist = [[1,2,3], [4, [5,6,7], 8,9, [0,3,5]], 7, 8]
mydict = {"abc": "def", "ghi":[1,2,3]}
pprint.pprint(mylist, width=1)

fmtdict = pprint.pformat(mydict, width=1)
print fmtdict
# "import pprint; help(pprint)" for more details

# @@INCOMPLETE@@
# Note that pprint does not currently handle user objects

#-----------------------------
# @@PLEAC@@_11.12
newlist = list(mylist) # shallow copy
newdict = dict(mydict) # shallow copy

# Pre 2.3:
import copy
newlist = copy.copy(mylist) # shallow copy
newdict = copy.copy(mydict) # shallow copy

# shallow copies copy a data structure, but don't copy the items in those
# data structures so if there are nested data structures, both copy and
# original will refer to the same object
mylist = ["1", "2", "3"]
newlist = list(mylist)
mylist[0] = "0"
print mylist, newlist
#=> ['0', '2', '3'] ['1', '2', '3']

mylist = [["1", "2", "3"], 4]
newlist = list(mylist)
mylist[0][0] = "0"
print mylist, newlist
#=> [['0', '2', '3'], 4] [['0', '2', '3'], 4]
#-----------------------------
import copy
newlist = copy.deepcopy(mylist) # deep copy
newdict = copy.deepcopy(mydict) # deep copy

# deep copies copy a data structure recursively:
import copy

mylist = [["1", "2", "3"], 4]
newlist = copy.deepcopy(mylist)
mylist[0][0] = "0"
print mylist, newlist
#=> [['0', '2', '3'], 4] [['1', '2', '3'], 4]
#-----------------------------
# @@PLEAC@@_11.13
import pickle
class Foo(object):
    def __init__(self):
        self.val = 1

x = Foo()
x.val = 3
p_x = pickle.dumps(x)  # Also pickle.dump(x, myfile) which writes to myfile
del x
x = pickle.loads(p_x)  # Also x = pickle.load(myfile) which loads from myfile
print x.val
#=> 3
#-----------------------------
# @@PLEAC@@_11.14
import os, shelve
fname = "testfile.db"
if not os.path.exists(fname):
    d = shelve.open("testfile.db")
    for i in range(100000):
        d[str(i)] = i
    d.close()

d = shelve.open("testfile.db")
print d["100"]
print d["1212010201"] # KeyError
#-----------------------------

# @@PLEAC@@_11.15
# bintree - binary tree demo program
# Use the heapq module instead?
import random
import warnings

class BTree(object):
    def __init__(self):
        self.value = None
    
    ### insert given value into proper point of
    ### the tree, extending this node if necessary.
    def insert(self, value):
        if self.value is None:
            self.left = BTree()
            self.right = BTree()
            self.value = value
        elif self.value > value:
            self.left.insert(value)
        elif self.value < value:
            self.right.insert(value)
        else:
            warnings.warn("Duplicate insertion of %s."%value)
            
    # recurse on left child, 
    # then show current value, 
    # then recurse on right child.
    def in_order(self):
       if self.value is not None:
           self.left.in_order()
           print self.value,
           self.right.in_order()

    # show current value, 
    # then recurse on left child, 
    # then recurse on right child.
    def pre_order(self):
        if self.value is not None:
            print self.value,
            self.left.pre_order()
            self.right.pre_order()
    
    # recurse on left child, 
    # then recurse on right child,
    # then show current value. 
    def post_order(self):
        if self.value is not None:
            self.left.post_order()
            self.right.post_order()
            print self.value,

    # find out whether provided value is in the tree.
    # if so, return the node at which the value was found.
    # cut down search time by only looking in the correct
    # branch, based on current value.
    def search(self, value):
        if self.value is not None:
            if self.value == value:
                return self
            if value < self.value:
                return self.left.search(value)
            else:
                return self.right.search(value)

def test():
    root = BTree()

    for i in range(20):
        root.insert(random.randint(1, 1000))

    # now dump out the tree all three ways
    print "Pre order: ", root.pre_order()
    print "In order:  ", root.in_order()
    print "Post order:", root.post_order()

    ### prompt until empty line
    while True:
        val = raw_input("Search? ").strip()
        if not val:
            break
        val = int(val)
        found = root.search(val)
        if found:
            print "Found %s at %s, %s"%(val, found, found.value)
        else:
            print "No %s in tree" % val
            
if __name__ == "__main__":
    test()


# ^^PLEAC^^_12.0
#-----------------------------
## Python's "module" is the closest equivalent to Perl's "package"


#=== In the file "Alpha.py"
name = "first"

#=== End of file

#=== In the file "Omega.py"

name = "last"
#=== End of file

import Alpha, Omega
print "Alpha is %s, Omega is %s." % (Alpha.name, Omega.name)
#> Alpha is first, Omega is last.
#-----------------------------
# Python does not have an equivalent to "compile-time load"
import sys

# Depending on the implementation, this could use a builtin
# module or load a file with the extension .py, .pyc, pyo, .pyd,
# .so, .dll, or (with imputils) load from other files.
import Cards.Poker

#-----------------------------
#=== In the file Cards/Poker.py
__all__ = ["card_deck", "shuffle"]  # not usually needed
card_deck = []
def shuffle():
    pass

#-----------------------------

# ^^PLEAC^^_12.1
#-----------------------------
#== In the file "YourModule.py"

__version__ = (1, 0)          # Or higher
__all__ = ["...", "..."]      # Override names included in "... import *"
                              #   Note: 'import *' is considered poor style
                              #   and it is rare to use this variable.
########################
# your code goes here
########################

#-----------------------------
import YourModule             # Import the module into my package
                              #  (does not import any of its symbols)

import YourModule as Module   # Use a different name for the module

from YourModule import *      # Import all module symbols not starting
                              #  with an underscore (default); if __all__
                              #  is defined, only imports those symbols.
                              # Using this is discouraged unless the 
                              #  module is specifically designed for it.

from YourModule import name1, name2, xxx
                              # Import the named symbols from the module

from YourModule import name1 as name2
                              # Import the named object, but use a
                              #  different name to access it locally.

#-----------------------------
__all__ = ["F1", "F2", "List"]
#-----------------------------
__all__ = ["Op_Func", "Table"]
#-----------------------------
from YourModule import Op_Func, Table, F1
#-----------------------------
from YourModule import Functions, Table
#-----------------------------

# ^^PLEAC^^_12.2
#-----------------------------
# no import
mod = "module"
try:
    __import__(mod)
except ImportError, err:
    raise ImportError("couldn't load %s: %s" % (mod, err))

# imports into current package
try:
    import module
except ImportError, err:
    raise ImportError("couldn't load 'module': %s" % (err, ))

# imports into current package, if the name is known
try:
    import module
except ImportError, err:
    raise ImportError("couldn't load 'module': %s" % (err, ))

# Use a fixed local name for a named module
mod = "module"
try:
    local_name = __import__(mod)
except ImportError, err:
    raise ImportError("couldn't load %s: %s" % (mod, err))

# Use the given name for the named module.
# (You probably don't need to do this.)
mod = "module"
try:
    globals()[mod] = __import__(mod)
except ImportError, err:
    raise ImportError("couldn't load %s: %s" % (mod, err))

#-----------------------------
DBs = "Giant.Eenie Giant.Meanie Mouse.Mynie Moe".split()
for mod in DBs.split():
    try:
        loaded_module = __import__(mod)
    except ImportError:
        continue
    # __import__ returns a reference to the top-most module
    # Need to get the actual submodule requested.
    for term in mod.split(".")[:-1]:
        loaded_module = getattr(loaded_module, term)
    break
else:
    raise ImportError("None of %s loaded" % DBs)
#-----------------------------

# ^^PLEAC^^_12.3
#-----------------------------
import sys
if __name__ == "__main__":
    if len(sys.argv) != 3 or not sys.argv[1].isdigit() \
                          or not sys.argv[2].isdigit():
        raise SystemExit("usage: %s num1 num2" % sys.argv[0])

import Some.Module
import More.Modules
#-----------------------------
if opt_b:
    import math
#-----------------------------
from os import O_EXCL, O_CREAT, O_RDWR

#-----------------------------
import os
O_EXCL = os.O_EXCL
O_CREAT = os.O_CREAT
O_RDWR = os.O_RDWR
#-----------------------------
import os
O_EXCL, O_CREAT, O_RDWR = os.O_EXCL, os.O_CREAT, os.O_RDWR
#-----------------------------
load_module('os', "O_EXCL O_CREAT O_RDWR".split())

def load_module(module_name, symbols):
    module = __import__(module_name)
    for symbol in symbols:
        globals()[symbol] = getattr(module, symbol)
#-----------------------------

# ^^PLEAC^^_12.4
#-----------------------------
# Python doesn't have Perl-style packages

# Flipper.py
__version__ = (1, 0)

__all__ = ["flip_boundary", "flip_words"]

Separatrix = ' '  # default to blank

def flip_boundary(sep = None):
    prev_sep = Separatrix
    if sep is not None:
        global Separatrix
        Separatrix = sep
    return prev_sep

def flip_words(line):
    words = line.split(Separatrix)
    words.reverse()
    return Separatrix.join(words)
#-----------------------------

# ^^PLEAC^^_12.5
#-----------------------------
this_pack = __name__
#-----------------------------
that_pack = sys._getframe(1).f_globals.get("__name__", "<string>")
#-----------------------------
print "I am in package", __name__
#-----------------------------
def nreadline(count, myfile):
    if count <= 0:
        raise ValueError("Count must be > 0")
    return [myfile.readline() for i in range(count)]

def main():
    myfile = open("/etc/termcap")
    a, b, c = nreadline(3, myfile)
    myfile.close()

if __name__ == "__main__":
    main()

# DON'T DO THIS:
import sys

def nreadline(count, handle_name):
    assert count > 0, "count must be > 0"
    locals = sys._getframe(1).f_locals
    if not locals.has_key(handle_name):
        raise AssertionError("need open filehandle")
    infile = locals[handle_name]
    retlist = []
    for line in infile:
        retlist.append(line)
        count -= 1
        if count == 0:
            break
    return retlist

def main():
    FH = open("/etc/termcap")
    a, b, c = nreadline(3, "FH")

if __name__ == "__main__":
    main()
#-----------------------------

# ^^PLEAC^^_12.6
#-----------------------------
## There is no direct equivalent in Python to an END block
import time, os, sys

# Tricks to ensure the needed functions exist during module cleanup
def _getgmtime(asctime=time.asctime, gmtime=time.gmtime,
               t=time.time):
    return asctime(gmtime(t()))

class Logfile:
    def __init__(self, file):
        self.file = file

    def _logmsg(self, msg, argv0=sys.argv[0], pid=os.getpid(),
                _getgmtime=_getgmtime):
        # more tricks to keep all needed references
        now = _getgmtime()
        print>>self.file, argv0, pid, now + ":", msg

    def logmsg(self, msg):
        self._logmsg(self.file, msg)

    def __del__(self):
        self._logmsg("shutdown")
        self.file.close()

    def __getattr__(self, attr):
        # forward everything else to the file handle
        return getattr(self.file, attr)

# 0 means unbuffered
LF = Logfile(open("/tmp/mylog", "a+", 0))
logmsg = LF.logmsg

#-----------------------------
## It is more appropriate to use try/finally around the
## main code, so the order of initialization and finalization
## can be specified.
if __name__ == "__main__":
    import logger
    logger.init("/tmp/mylog")
    try:
        main()
    finally:
        logger.close()

#-----------------------------

# ^^PLEAC^^_12.7
#-----------------------------
#% python -c 'import sys\
for i, name in zip(xrange(sys.maxint), sys.path):\
    print i, repr(name)
#> 0 ''
#> 1 '/usr/lib/python2.2'
#> 2 '/usr/lib/python2.2/plat-linux2'
#> 3 '/usr/lib/python2.2/lib-tk'
#-----------------------------
# syntax for sh, bash, ksh, or zsh
#$ export PYTHONPATH=$HOME/pythonlib

# syntax for csh or tcsh
#% setenv PYTHONPATH ~/pythonlib
#-----------------------------
import sys
sys.path.insert(0, "/projects/spectre/lib")
#-----------------------------
import FindBin
sys.path.insert(0, FindBin.Bin)
#-----------------------------
import FindBin
Bin = "Name"
bin = getattr(FindBin, Bin)
sys.path.insert(0, bin + "/../lib")
#-----------------------------

# ^^PLEAC^^_12.8
#-----------------------------
#% h2xs -XA -n Planets
#% h2xs -XA -n Astronomy::Orbits
#-----------------------------
# @@INCOMPLETE@@
# @@INCOMPLETE@@
# Need a distutils example
#-----------------------------

# ^^PLEAC^^_12.9
#-----------------------------
# Python compiles a file to bytecode the first time it is imported and 
# stores this compiled form in a .pyc file.  There is thus less need for
# incremental compilation as once there is a .pyc file, the sourcecode
# is only recompiled if it is modified.  

# ^^PLEAC^^_12.10
#-----------------------------
# See previous section

# ^^PLEAC^^_12.11
#-----------------------------
## Any definition in a Python module overrides the builtin
## for that module

#=== In MyModule
def open():
    pass # TBA
#-----------------------------
from MyModule import open
file = open()
#-----------------------------

# ^^PLEAC^^_12.12
#-----------------------------
def even_only(n):
    if n & 1:     # one way to test
        raise AssertionError("%s is not even" % (n,))
    #....

#-----------------------------
def even_only(n):
    if n % 2:    # here's another
        # choice of exception depends on the problem
        raise TypeError("%s is not even" % (n,))
    #....

#-----------------------------
import warnings
def even_only(n):
    if n & 1:           # test whether odd number
        warnings.warn("%s is not even, continuing" % (n))
        n += 1
    #....
#-----------------------------
warnings.filterwarnings("ignore")
#-----------------------------

# ^^PLEAC^^_12.13
#-----------------------------
val = getattr(__import__(packname), varname)
vals =  getattr(__import__(packname), aryname)
getattr(__import__(packname), funcname)("args")

#-----------------------------
# DON'T DO THIS [Use math.log(val, base) instead]
import math
def make_log(n):
   def logn(val):
      return math.log(val, n)
   return logn

# Modifying the global dictionary - this could also be done
# using locals(), or someobject.__dict__
globaldict = globals()
for i in range(2, 1000):
    globaldict["log%s"%i] = make_log(i)

# DON'T DO THIS
for i in range(2,1000):
    exec "log%s = make_log(i)"%i in globals()
    
print log20(400)
#=>2.0
#-----------------------------
blue = colours.blue
someobject.blue = colours.azure  # someobject could be a module...
#-----------------------------

# ^^PLEAC^^_12.14
#-----------------------------
# Python extension modules can be imported and used just like
# a pure python module.
#
# See http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/ for
# information on how to create extension modules in Pyrex [a
# language that's basically Python with type definitions which
# converts to compiled C code]
#
# See http://www.boost.org/libs/python/doc/ for information on how
# to create extension modules in C++.
#
# See http://www.swig.org/Doc1.3/Python.html for information on how
# to create extension modules in C/C++
#
# See http://docs.python.org/ext/ext.html for information on how to
# create extension modules in C/C++ (manual reference count management).
#
# See http://cens.ioc.ee/projects/f2py2e/ for information on how to
# create extension modules in Fortran
#
# See http://www.scipy.org/Weave for information on how to 
# include inline C code in Python code.
#
# @@INCOMPLETE@@ Need examples of FineTime extensions using the different methods...
#-----------------------------

# ^^PLEAC^^_12.15
#-----------------------------
# See previous section
#-----------------------------

# ^^PLEAC^^_12.16
#-----------------------------
# To document code, use docstrings. A docstring is a bare string that
# is placed at the beginning of a module or immediately after the 
# definition line of a class, method, or function. Normally, the
# first line is a brief description of the object; if a longer
# description is needed, it commences on the third line (the second
# line being left blank).  Multiline comments should use triple
# quoted strings.
# 
# Docstrings are automagically assigned to an object's __doc__ property.
#
# In other words these three classes are identical:
class Foo(object):
    "A class demonstrating docstrings."

class Foo(object):
    __doc__ = "A class demonstrating docstrings."

class Foo(object):
    pass
Foo.__doc__ = "A class demonstrating docstrings."

# as are these two functions:
def foo():
    "A function demonstrating docstrings."

def foo():
    pass
foo.__doc__ = "A function demonstrating docstrings."

# the pydoc module is used to display a range of information about 
# an object including its docstrings:
import pydoc 
print pydoc.getdoc(int)
pydoc.help(int)

# In the interactive interpreter, objects' documentation can be 
# using the help function:
help(int)

#-----------------------------

# ^^PLEAC^^_12.17
#-----------------------------
# Recent Python distributions are built and installed with disutils.
# 
# To build and install under unix
# 
# % python setup.py install
# 
# If you want to build under one login and install under another
# 
# % python setup.py build
# $ python setup.py install
# 
# A package may also be available prebuilt, eg, as an RPM or Windows
# installer.  Details will be specific to the operating system.

#-----------------------------
# % python setup.py --prefix ~/python-lib
#-----------------------------


# ^^PLEAC^^_12.18
#-----------------------------
#== File Some/Module.py

# There are so many differences between Python and Perl that
# it isn't worthwhile trying to come up with an equivalent to
# this Perl code.  The Python code is much smaller, and there's
# no need to have a template.

#-----------------------------

# ^^PLEAC^^_12.19
#-----------------------------
#% pmdesc
#-----------------------------
import sys, pydoc

def print_module_info(path, modname, desc):
   # Skip files starting with "test_"
   if modname.split(".")[-1].startswith("test_"):
       return
   try:
       # This assumes the modules are safe for importing,
       # in that they don't have side effects.  Could also
       # grep the file for the __version__ line.
       mod = pydoc.safeimport(modname)
   except pydoc.ErrorDuringImport:
       return
   version = getattr(mod, "__version__", "unknown")
   if isinstance(version, type("")):
       # Use the string if it's given
       pass
   else:
       # Assume it's a list of version numbers, from major to minor
       ".".join(map(str, version))
   synopsis, text = pydoc.splitdoc(desc)
   print "%s (%s) - %s" % (modname, version, synopsis)

scanner = pydoc.ModuleScanner()
scanner.run(print_module_info)

#-----------------------------


# ^^PLEAC^^_13.0
#-----------------------------
# Inside a module named 'Data' / file named 'Data.py'
class Encoder(object):
    pass
#-----------------------------
obj = [3, 5]
print type(obj), id(obj), ob[1]

## Changing the class of builtin types is not supported
## in Python.

#-----------------------------
obj.Stomach = "Empty"    # directly accessing an object's contents
obj.NAME = "Thag"        # uppercase field name to make it stand out
(optional)
#-----------------------------
encoded = object.encode("data")
#-----------------------------
encoded = Data.Encoder.encode("data")
#-----------------------------
class Class(object):
    def __init__(self):
        pass
#-----------------------------
object = Class()
#-----------------------------
class Class(object):
    def class_only_method():
        pass # more code here
    class_only_method = staticmethod(class_only_method)

#-----------------------------
class Class(object):
    def instance_only_method(self):
        pass # more code here
#-----------------------------
lector = Human.Cannibal()
lector.feed("Zak")
lector.move("New York")
#-----------------------------
# NOTE: it is rare to use these forms except inside of
# methods to call specific methods from a parent class
lector = Human.Cannibal()
Human.Cannibal.feed(lector, "Zak")
Human.Cannibal.move(lector, "New York")
#-----------------------------
print>>sys.stderr, "stuff here\n"

# ^^PLEAC^^_13.1
#-----------------------------
class Class(object):
    pass
#-----------------------------
import time
class Class(object):
    def __init__(self):
        self.start = time.time()  # init data fields
        self.age = 0
#-----------------------------
import time
class Class(object):
    def __init__(self, **kwargs):
        # Sets self.start to the current time, and self.age to 0.  If called
        # with arguments, interpret them as key+value pairs to
        # initialize the object with
        self.age = 0
        self.__dict__.update(kwargs)
#-----------------------------

# ^^PLEAC^^_13.2
#-----------------------------
import time
class Class(object):
    def __del__(self):
        print self, "dying at", time.ctime()
#-----------------------------
## Why is the perl code introducing a cycle?  I guess it's an
## example of how to keep from calling the finalizer
self.WHATEVER = self
#-----------------------------

# ^^PLEAC^^_13.3
#-----------------------------
# It is standard practice to access attributes directly:
class MyClass(object)
    def __init__(self):
        self.name = "default"
        self.age = 0
obj = MyClass()
obj.name = "bob"
print obj.name
obj.age += 1

# If you later find that you need to compute an attribute, you can always 
# retrofit a property(), leaving user code untouched:
class MyClass(object):
    def __init__(self):
        self._name = "default"
        self._age = 0

    def get_name(self):
        return self._name
    def set_name(self, name):
        self._name = name.title()
    name = property(get_name, set_name)

    def get_age(self):
        return self._age
    def set_age(self, val):
        if val < 0:
            raise ValueError("Invalid age: %s" % val)
        self._age = val
    age = property(get_age, set_age)
obj = MyClass()
obj.name = "bob"
print obj.name
obj.age += 1

# DON'T DO THIS - explicit getters and setters should not be used:
class MyClass(object):
    def __init__(self):
        self.name = "default"
    def get_name(self):
        return self.name
    def set_name(self, name):
        self.name = name.title()
obj = MyClass()
obj.set_name("bob")
print obj.get_name()
#-----------------------------
## DON'T DO THIS (It's complex, ugly, and unnecessary):
class MyClass(object):
    def __init__(self):
        self.age = 0
    def name(self, *args):
        if len(args) == 0:
            return self.name
        elif len(args) == 1:
            self.name = args[0]
        else:
            raise TypeError("name only takes 0 or 1 arguments")
    def age(self, *args):
        prev = self.age
        if args:
            self.age = args[0]
        return prev

# sample call of get and set: happy birthday!
obj.age(1 + obj.age())

#-----------------------------
him = Person()
him.NAME = "Sylvester"
him.AGE = 23
#-----------------------------
# Here's another way to implement the 'obj.method()' is a getter
# and 'obj.method(value)' is a settor.  Again, this is not a
# common Python idiom and should not be used.  See below for a
# more common way to do parameter checking of attribute assignment.

import re, sys

def carp(s):
    sys.stderr.write("WARNING: " + s + "\n")

class Class:
    no_name = []

    def name(self, value = no_name):
        if value is Class.no_name:
            return self.NAME
        value = self._enforce_name_value(value)
        self.NAME = value

    def _enforce_name_value(self, value):
        if re.search(r"[^\s\w'-]", value):
            carp("funny characters in name")
        if re.search(r"\d", value):
            carp("numbers in name")
        if not re.search(r"\S+(\s+\S+)+", value):
            carp("prefer multiword name")
        if not re.search(r"\S", value):
            carp("name is blank")
        return value.upper()   # enforce capitalization
#-----------------------------
# A more typical way to enforce restrictions on a value
# to set
class Class:
    def __setattr__(self, name, value):
        if name == "name":
            value = self._enforce_name_value(value)  # Do any conversions
        self.__dict__[name] = value  # Do the default __setattr__ action

    def _enforce_name_value(self, value):
        if re.search(r"[^\s\w'-]", value):
            carp("funny characters in name")
        if re.search(r"\d", value):
            carp("numbers in name")
        if not re.search(r"\S+(\s+\S+)+", value):
            carp("prefer multiword name")
        if not re.search(r"\S", value):
            carp("name is blank")
        return value.upper()   # enforce capitalization

#-----------------------------
class Person:
    def __init__(self, name = None, age = None, peers = None):
        if peers is None: peers = []  # See Python FAQ 6.25
        self.name = name
        self.age = age
        self.peers = peers

    def exclaim(self):
        return "Hi, I'm %s, age %d, working with %s" % \
            (self.name, self.age, ", ".join(self.peers))

    def happy_birthday(self):
        self.age += 1
        return self.age
#-----------------------------

# ^^PLEAC^^_13.4
#-----------------------------
## In the module named 'Person' ...
def population():
    return Person.body_count[0]

class Person(object):
    body_count = [0]        # class variable - shared across all instances

    def __init__(self):
        self.body_count[0] += 1

    def __del__(self):      # Beware - may be non-deterministic (Jython)!
        self.body_count[0] -= 1

# later, the user can say this:
import Person
people = []
for i in range(10):
    people.append(Person.Person())
print "There are", Person.population(), "people alive."

#=> There are 10 people alive.
#-----------------------------
him = Person()
him.gender = "male"

her = Person()
her.gender = "female"

#-----------------------------
FixedArray.max_bounds = 100                # set for whole class
alpha = FixedArray.FixedArray()
print "Bound on alpha is", alpha.max_bounds
#=>100

beta = FixedArray.FixedArray()
beta.max_bounds = 50                      # still sets for whole class
print "Bound on alpha is", alpha.max_bounds
#=>50
#-----------------------------
# In the module named 'FixedArray'

class FixedArray(object):
    _max_bounds = [7]        # Shared across whole class
    
    def __init__(self, bounds=None):
        if bounds is not None:
            self.max_bounds = bounds

    def get_max_bounds(self):
        return self._max_bounds[0]
    def set_max_bounds(self, val):
        self._max_bounds[0] = val
    max_bounds = property(get_max_bounds, set_max_bounds)
#-----------------------------

# ^^PLEAC^^_13.5
#-----------------------------
# There isn't the severe separation between scalar, arrays and hashs
# in Python, so there isn't a direct equivalent to the Perl code.
class Person:
    def __init__(self, name=None, age=None, peers=None):
        if peers is None: 
            peers = []
        self.name = name
        self.age = age
        self.peers = peers

p = Person("Jason Smythe", 13, ["Wilbur", "Ralph", "Fred"])

# or this way.  (This is not the prefered style as objects should
# be constructed with all the appropriate data, if possible.)

p = Person()  # allocate an empty Person
p.name = "Jason Smythe"                         # set its name field
p.age = 13                                      # set its age field
p.peers.extend( ["Wilbur", "Ralph", "Fred" ] )  # set its peers field

p.peers = ["Wilbur", "Ralph", "Fred"]

p.peers[:]= ["Wilbur", "Ralph", "Fred"]

# fetch various values, including the zeroth friend
print "At age %d, %s's first friend is %s." % \
    (p.age, p.name, p.peers[0])
#-----------------------------
# This isn't very Pythonic - should create objects with the
# needed data, and not depend on defaults and modifing the object.
import sys
def carp(s):
    sys.stderr.write("WARNING: " + s + "\n")

class Person:
    def __init__(self, name = "", age = 0):
        self.name = name
        self.age = age
    def __setattr__(self, name, value):
        if name == "age":
            # This is very unpythonic
            if not isinstance(value, type(0)):
                carp("age '%s' isn't numeric" % (value,))
            if value > 150: carp("age '%s' is unreasonable" % (value,))
        self.__dict__[name] = value

class Family:
    def __init__(self, head = None, address = "", members = None):
        if members is None: members = []
        self.head = head or Person()
        self.address = address
        self.members = members

folks = Family()

dad = folks.head
dad.name = "John"
dad.age = 34

print "%s's age is %d" % (folks.head.name, folks.head.age)
#-----------------------------
class Card:
    def __init__(self, name=None, color=None, cost=None,
                 type=None, release=None, text=None):
        self.name = name
        self.color = color
        self.cost = cost
        self.type = type
        self.release = release
        self.type = type
#-----------------------------
# For positional args
class Card:
    _names = ("name", "color", "cost", "type", "release", "type")
    def __init__(self, *args):
        assert len(args) <= len(self._names)
        for k, v in zip(self._names, args):
            setattr(self, k, None)
#-----------------------------
# For keyword args
class Card:
    _names = ("name", "color", "cost", "type", "release", "type")
    def __init__(self, **kwargs):
        for k in self._names:  # Set the defaults
            setattr(self, k, None)
        for k, v in kwargs.items():  # add in the kwargs
            assert k in self._names, "Unexpected kwarg: " + k
            setattr(self, k, v)
#-----------------------------
class hostent:
    def __init__(self, addr_list = None, length = None,
                 addrtype = None, aliases = None, name = None):
        self.addr_list = addr_list or []
        self.length = length or 0
        self.addrtype = addrtype or ""
        self.aliases = aliases or []
        self.name = name or ""
#-----------------------------
## XXX What do I do with these?
#define h_type h_addrtype
#define h_addr h_addr_list[0]
#-----------------------------
# make (hostent object)->type() same as (hostent object)->addrtype()
#
# *hostent::type = \&hostent::addrtype;
#
# # make (hostenv object)->
# addr()
#  same as (hostenv object)->addr_list(0)
#sub hostent::addr { shift->addr_list(0,@_) }
#-----------------------------
# No equivalent to Net::hostent (Python uses an unnamed tuple)
#package Extra::hostent;
#use Net::hostent;
#@ISA = qw(hostent);
#sub addr { shift->addr_list(0,@_) }
#1;
#-----------------------------

# ^^PLEAC^^_13.6
#-----------------------------
class Class(Parent):
    pass
#-----------------------------
## Note: this is unusual in Python code
ob1 = SomeClass()
# later on
ob2 = ob1.__class__()
#-----------------------------
## Note: this is unusual in Python code
ob1 = Widget()
ob2 = ob1.__class__()
#-----------------------------
# XXX I do not know the intent of the original Perl code
# Do not use this style of programming in Python.
import time
class Person(possible,base,classes):
    def __init__(self, *args, **kwargs):
        # Call the parents' constructors, if there are any
        for baseclass in self.__class__.__bases__:
            init = getattr(baseclass, "__init__")
            if init is not None:
                init(self, *args, **kwargs)
        self.PARENT = parent      # init data fields
        self.START = time.time()
        self.AGE = 0
#-----------------------------

# ^^PLEAC^^_13.7
#-----------------------------
methname = "flicker"
getattr(obj, methname)(10)    # calls obj->flicker(10);

# call three methods on the object, by name
for m in ("start", "run", "stop"):
    getattr(obj, m)()
#-----------------------------
methods = ("name", "rank", "serno")
his_info = {}
for m in methods:
   his_info[m] = getattr(ob, m)()

# same as this:

his_info = {
    'name': ob.name(),
    'rank': ob.rank(),
    'serno': ob.serno(),
}
#-----------------------------
fnref = ob.method
#-----------------------------
fnref(10, "fred")
#-----------------------------
obj.method(10, "fred")
#-----------------------------
# XXX Not sure if this is the correct translation.
# XXX Is 'can' special?
if isinstance(obj_target, obj.__class__):
    obj.can('method_name')(obj_target, *arguments)
#-----------------------------

# ^^PLEAC^^_13.8
#-----------------------------
isinstance(obj, mimetools.Message)
issubclass(obj.__class__, mimetools.Message)

if hasattr(obj, "method_name"):  # check method validity
    pass
#-----------------------------
## Explicit type checking is needed fewer times than you think.
his_print_method = getattr(obj, "as_string", None)
#-----------------------------
__version__ = (3, 0)
Some_Module.__version__

# Almost never used, and doesn't work for builtin types, which don't
# have a __module__.

his_vers = obj.__module__.__version__
#-----------------------------
if Some_Module.__version__ < (3, 0):
  raise ImportError("Some_Module version %s is too old, expected (3, 0)" %
                    (Some_Module.__version__,))
# or more simply
assert Some_Module.__version__ >= (3, 0), "version too old"

#-----------------------------
__VERSION__ = '1.01'
#-----------------------------

# ^^PLEAC^^_13.9
#-----------------------------
# Note: This uses the standard Python idiom of accessing the
# attributes directly rather than going through a method call.
# See earlier in this chapter for examples of how this does
# not break encapsulation.
class Person:
    def __init__(self, name = "", age = 0):
        self.name = name
        self.age = age
#-----------------------------
# Prefered: dude = Person("Jason", 23)
dude = Person()
dude.name = "Jason"
dude.age = 23
print "%s is age %d." % (dude.name, dude.age)
#-----------------------------
class Employee(Person):
    pass
#-----------------------------
# Prefered: empl = Employee("Jason", 23)
emp = Employee()
empl.name = "Jason"
empl.age = 23
print "%s is age %d." % (empl.name, empl.age)
#-----------------------------

# ^^PLEAC^^_13.10
#-----------------------------
# This doesn't need to be done since if 'method' doesn't
# exist in the Class it will be looked for in its BaseClass(es)
class Class(BaseClass):
    def method(self, *args, **kwargs):
        BaseClass.method(self, *args, **kwargs)

# This lets you pick the specific method in one of the base classes
class Class(BaseClass1, BaseClass2):
    def method(self, *args, **kwargs):
        BaseClass2.method(self, *args, **kwargs)

# This looks for the first method in the base class(es) without
# specifically knowing which base class.  This reimplements
# the default action so isn't really needed.
class Class(BaseClass1, BaseClass2, BaseClass3):
    def method(self, *args, **kwargs):
        for baseclass in self.__class__.__bases__:
            f = getattr(baseclass, "method")
            if f is not None:
                return f(*args, **kwargs)
        raise NotImplementedError("method")

#-----------------------------
self.meth()   # Call wherever first meth is found

Where.meth(self)  # Call in the base class "Where"

# XXX Does Perl only have single inheritence?  Or does
# it check all base classes?  No directly equivalent way
# to do this in Python, but see above.
#-----------------------------
import time

# The Perl code calls a private '_init' function, but in
# Python there's need for the complexity of 'new' mechanism
# so it's best just to put the '_init' code in '__init__'.
class Class:
    def __init__(self, *args):
        # init data fields
        self.START = time.time()
        self.AGE = 0
        self.EXTRA = args          # anything extra
#-----------------------------
obj = Widget(haircolor = "red", freckles = 121)
#-----------------------------
class Class(Base1, Base2, Base3):
    def __init__(self, *args, **kwargs):
        for base in self.__class__.__bases__:
            f = getattr(base, "__init__")
            if f is not None:
                f(self, *args, **kwargs)
#-----------------------------

# ^^PLEAC^^_13.11
#-----------------------------
# NOTE: Python prefers direct attribute lookup rather than
# method calls.  Python 2.2 will introduce a 'get_set' which
# *may* be equivalent, but I don't know enough about it.  So
# instead I'll describe a class that lets you restrict access
# to only specific attributes.

class Private:
    def __init__(self, names):
        self.__names = names
        self.__data = {}
    def __getattr__(self, name):
        if name in self.__names:
            return self.__data[name]
        raise AttributeError(name)
    def __setattr__(self, name, value):
        if name.startswith("_Private"):
            self.__dict__[name] = value
            return
        if name in self.__names:
            self.__data[name] = value
            return
        raise TypeError("cannot set the attribute %r" % (name,))

class Person(Private):
    def __init__(self, parent = None):
        Private.__init__(self, ["name", "age", "peers", "parent"])
        self.parent = parent
    def new_child(self):
        return Person(self)
#-----------------------------
dad = Person()
dad.name = "Jason"
dad.age = 23
kid = dad.new_child()
kid.name = "Rachel"
kid.age = 2
print "Kid's parent is", kid.parent.name
#=>Kid's parent is Jason

# ^^PLEAC^^_13.12
#-----------------------------
## XXX No clue on what this does.  For that matter, what's
## "The Data Inheritance Problem"?

# ^^PLEAC^^_13.13
#-----------------------------
node.NEXT = node
#-----------------------------
# This is not a faithful copy of the Perl code, but it does
# show how to have the container's __del__ remove cycles in
# its contents.  Note that Python 2.0 includes a garbage
# collector that is able to remove these sorts of cycles, but
# it's still best to prevent cycles in your code.
class Node:
    def __init__(self, value = None):
        self.next = self
        self.prev = self
        self.value = value

class Ring:
    def __init__(self):
        self.ring = None
        self.count = 0

    def __str__(self):
        # Helpful when debugging, to print the contents of the ring
        s = "#%d: " % self.count
        x = self.ring
        if x is None:
            return s
        values = []
        while True:
            values.append(x.value)
            x = x.next
            if x is self.ring:
                break
        return s + " -> ".join(map(str, values)) + " ->"

    def search(self, value):
        node = self.ring
        while True:
            if node.value == value:
                return node
            node = node.next
            if node is self.ring:
                break

    def insert_value(self, value):
        node = Node(value)
        if self.ring is not None:
            node.prev, node.next = self.ring.prev, self.ring
            self.ring.prev.next = self.ring.prev = node
        self.ring = node
        self.count += 1

    def delete_value(self, value):
        node = self.search(value)
        if node is not None:
            self.delete_node(node)

    def delete_node(self, node):
        if node is node.next:
            node.next = node.prev = None
            self.ring = None
        else:
            node.prev.next, node.next.prev = node.next, node.prev
            if node is self.ring:
                self.ring = node.next
        self.count -= 1

    def __del__(self):
        while self.ring is not None:
            self.delete_node(self.ring)

COUNT = 1000
for rep in range(20):
    r = Ring()
    for i in range(COUNT):
        r.insert_value(i)
#-----------------------------

# ^^PLEAC^^_13.14
#-----------------------------
import UserString
class MyString(UserString.UserString):
    def __cmp__(self, other):
        return cmp(self.data.upper(), other.upper())

class Person:
    def __init__(self, name, idnum):
        self.name = name
        self.idnum = idnum
    def __str__(self):
        return "%s (%05d)" % (self.name.lower().capitalize(), self.idnum)

#-----------------------------
class TimeNumber:
    def __init__(self, hours, minutes, seconds):
        assert minutes < 60 and seconds < 60
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    def __str__(self):
        return "%d:%02d:%02d" % (self.hours, self.minutes, self.seconds)
    def __add__(self, other):
        seconds = self.seconds + other.seconds
        minutes = self.minutes + other.minutes
        hours = self.hours + other.hours
        if seconds >= 60:
            seconds %= 60
            minutes += 1
        if minutes >= 60:
            minutes %= 60
            hours += 1
        return TimeNumber(hours, minutes, seconds)

    def __sub__(self, other):
        raise NotImplementedError

    def __mul__(self, other):
        raise NotImplementedError

    def __div__(self, other):
        raise NotImplementedError

t1 = TimeNumber(0, 58, 59)
sec = TimeNumber(0, 0, 1)
min = TimeNumber(0, 1, 0)
print t1 + sec + min + min
# 1:01:00

#-----------------------------
# For demo purposes only - the StrNum class is superfluous in this
# case as plain strings would give the same result.
class StrNum:
    def __init__(self, value):
        self.value = value

    def __cmp__(self, other):  # both <=> and cmp
        # providing <=> gives us <, ==, etc. for free.
        # __lt__, __eq__, and __gt__ can also be individually specified
        return cmp(self.value, other.value)

    def __str__(self):  # ""
        return self.value

    def __nonzero__(self, other):   # bool
        return bool(self.value)

    def __int__(self, other):   # 0+
        return int(self.value)

    def __add__(self, other):   # +
        return StrNum(self.value + other.value)

    def __radd__(self, other):   # +, inverted
        return StrNum(other.value + self.value)

    def __mul__(self, other):   # *
        return StrNum(self.value * other)

    def __rmul__(self, other):   # *, inverted
        return StrNum(self.value * other)


def demo():
    # show_strnum - demo operator overloading
    x = StrNum("Red")
    y = StrNum("Black")
    z = x + y
    r = z * 3
    print "values are %s, %s, %s, and %s" % (x, y, z, r)
    if x < y:
        s = "LT"
    else:
        s = "GE"
    print x, "is", s, y

if __name__ == "__main__":
    demo()
# values are Red, Black, RedBlack, and RedBlackRedBlackRedBlack
# Red is GE Black

#-----------------------------
#!/usr/bin/env python
# demo_fixnum - show operator overloading

# sum of STRFixNum: 40 and STRFixNum: 12 is STRFixNum: 52
# product of STRFixNum: 40 and STRFixNum: 12 is STRFixNum: 480
# STRFixNum: 3 has 0 places
# div of STRFixNum: 40 by STRFixNum: 12 is STRFixNum: 3.33
# square of that is  STRFixNum: 11.11

# This isn't excatly the same as the original Perl code since
# I couldn't figure out why the PLACES variable was used.
#-----------------------------
import re
_places_re = re.compile(r"\.(\d+)")

default_places = 0

class FixNum:
    def __init__(self, value, places = None):
        self.value = value
        if places is None:
            # get from the value
            m = _places_re.search(str(value))
            if m:
                places = int(m.group(1))
            else:
                places = default_places
        self.places = places

    def __add__(self, other):
        return FixNum(self.value + other.value,
                      max(self.places, other.places))

    def __mul__(self, other):
        return FixNum(self.value * other.value,
                      max(self.places, other.places))

    def __div__(self, other):
        # Force to use floating point, since 2/3 in Python is 0
        # Don't use float() since that will convert strings
        return FixNum((self.value+0.0) / other.value,
                      max(self.places, other.places))

    def __str__(self):
        return "STR%s: %.*f" % (self.__class__.__name__,
                                self.places, self.value)
    def __int__(self):
        return int(self.value)

    def __float__(self):
        return self.value

def demo():
    x = FixNum(40)
    y = FixNum(12, 0)

    print "sum of", x, "and", y, "is", x+y
    print "product of", x, "and", y, "is", x*y

    z = x/y
    print "%s has %d places" % (z, z.places)
    if not z.places:
        z.places = 2

    print "div of", x, "by", y, "is", z
    print "square of that is ", z*z

if __name__ == "__main__":
    demo()


# ^^PLEAC^^_13.15
# You can't tie a variable, but you can use properties.  
import itertools
class ValueRing(object):
    def __init__(self, colours):
        self.colourcycle = itertools.cycle(colours)

    def next_colour(self):
        return self.colourcycle.next()
    colour = property(next_colour)
vr = ValueRing(["red", "blue"])
for i in range(6):
    print vr.colour,
print

# Note that you MUST refer directly to the property
x = vr.colour
print x, x, x
#-------------------------------------
# Ties are generally unnecessary in Python because of its strong OO support -
# The resulting code is MUCH shorter:
class AppendDict(dict):
    def __setitem__(self, key, val):
        if key in self:
            self[key].append(val)
        else:
            super(AppendDict, self).__setitem__(key, [val])
tab = AppendDict()
tab["beer"] = "guinness"
tab["food"] = "potatoes"
tab["food"] = "peas"

for key, val in tab.items():
    print key, "=>", val
#-------------------------------------
class CaselessDict(dict):
    def __setitem__(self, key, val):
        super(CaselessDict, self).__setitem__(key.lower(), val)
    def __getitem__(self, key):
        return super(CaselessDict, self).__getitem__(key.lower())

tab = CaselessDict()
tab["VILLAIN"] = "big "
tab["herOine"] = "red riding hood"
tab["villain"] = "bad wolf"

for key, val in tab.items():
    print key, "is", val
#=>villain is bad wolf
#=>heroine is red riding hood
#-------------------------------------
class RevDict(dict):
    def __setitem__(self, key, val):
        super(RevDict, self).__setitem__(key, val)
        super(RevDict, self).__setitem__(val, key)

tab = RevDict()
tab["red"] = "rojo"
tab["blue"] = "azul"
tab["green"] = "verde"
tab["evil"] = ("No Way!", "Way!")

for key, val in tab.items():
    print key, "is", val
#=>blue is azul
#=>('No Way!', 'Way!') is evil
#=>rojo is red
#=>evil is ('No Way!', 'Way!')
#=>azul is blue
#=>verde is green
#=>green is verde
#=>red is rojo
#-------------------------------------
import itertools
for elem in itertools.count():
    print "Got", elem
#-------------------------------------
# You could use FileDispatcher from section 7.18
tee = FileDispatcher(sys.stderr, sys.stdout)
#-------------------------------------
# @@PLEAC@@_14.0

# See http://www.python.org/doc/topics/database/ for Database Interfaces details.
# currently listed on http://www.python.org/doc/topics/database/modules/
#
#  DB/2, Informix, Interbase, Ingres, JDBC, MySQL, pyodbc, mxODBC, ODBC Interface,
#  DCOracle, DCOracle2, PyGresQL, psycopg, PySQLite, sapdbapi, Sybase, ThinkSQL.
#

# @@PLEAC@@_14.1
#-------------------------------------
import anydbm
filename = "test.db"
try:
    db = anydbm.open(filename)
except anydbm, err:
    print "Can't open %s: %s!" % (filename, err)

db["key"] = "value"        # put value into database
if "key" in db:            # check whether in database
    val = db.pop("key")    # retrieve and remove from database
db.close()                 # close the database
#-------------------------------------
# download the following standalone program
#!/usr/bin/python
# userstats - generates statistics on who logged in.
# call with an argument to display totals

import sys, os, anydbm, re

db_file = '/tmp/userstats.db'       # where data is kept between runs

try:
    db = anydbm.open(db_file,'c')   # open, create if it does not exist
except:
    print "Can't open db %s: %s!" % (db_file, sys.exc_info()[1])
    sys.exit(1)

if len(sys.argv) > 1:
    if sys.argv[1] == 'ALL':
        userlist = db.keys()
    else:
        userlist = sys.argv[1:]
    userlist.sort()
    for user in userlist:
        if db.has_key(user):
            print "%s\t%s" % (user, db[user])
        else:
            print "%s\t%s" % (user, 0)
else:
    who = os.popen('who').readlines()  # run who(1)
    if len(who)<1:
        print "error running who"       # exit
        sys.exit(1)
    # extract username (first thin on the line) and update
    user_re = re.compile("^(\S+)")
    for line in who:
        fnd = user_re.search(line)
        if not fnd:
            print "Bad line from who: %s" % line
            sys.exit(1)
        user = fnd.groups()[0]
        if not db.has_key(user):
            db[user] = "0"
        db[user] = str(int(db[user])+1) # only strings are allowed
db.close()
    



# @@PLEAC@@_14.2
# Emptying a DBM File

import anydbm

try:
    db = anydbm.open(FILENAME,'w')   # open, for writing
except anydbm.error, err:
    print "Can't open db %s: %s!" % (filename, err)
    raise SystemExit(1)

db.clear()
db.close()
# -------------------------------
try:
    db = anydbm.open(filename,'n')   # open, always create a new empty db
except anydbm.error, err:
    print "Can't open db %s: %s!" % (filename, err)
    raise SystemExit(1)

db.close()
# -------------------------------
import os
try:
    os.remove(FILENAME)
except OSError, err:
    print "Couldn't remove %s to empty the database: %s!" % (FILENAME,
        err)
    raise SystemExit

try:
    db = anydbm.open(FILENAME,'n')   # open, flways create a new empty db
except anydbm.error, err:
    print "Couldn't create %s database: %s!" % (FILENAME, err)
    raise SystemExit

# @@PLEAC@@_14.3
# Converting Between DBM Files

# download the following standalone program
#!/usr/bin/python
# db2gdbm: converts DB to GDBM

import sys
import dbm, gdbm

if len(sys.argv)<3:
    print "usage: db2gdbm infile outfile"
    sys.exit(1)

(infile, outfile) = sys.argv[1:]

# open the files
try:
    db_in = dbm.open(infile)
except:
    print "Can't open infile %s: %s!" % (infile, sys.exc_info()[1])
    sys.exit(1)
try:
    db_out = dbm.open(outfile,"n")
except:
    print "Can't open outfile %s: %s!" % (outfile, sys.exc_info()[1])
    sys.exit(1)

# copy (don't use db_out = db_in because it's slow on big databases)
# is this also so for python ?
for k in db_in.keys():
    db_out[k] = db_in[k]

# these close happen automatically at program exit
db_out.close()
db_in.close()



# @@PLEAC@@_14.4

OUTPUT.update(INPUT1)
OUTPUT.update(INPUT2)

OUTPUT = anydbm.open("OUT","n")
for INPUT in (INPUT1, INPUT2, INPUT1):
    for key, value in INPUT.iteritems():
        if OUTPUT.has_key(key):
            # decide which value to use and set OUTPUT[key] if necessary
            print "key %s already present: %s, new: %s" % (
                    key, OUTPUT[key], value )
        else:
            OUTPUT[key] = value

# @@PLEAC@@_14.5
# On systems where the Berkeley DB supports it, dbhash takes an
# "l" flag:
import dbhash
dbhash.open("mydb.db", "cl") # 'c': create if doesn't exist

# @@INCOMPLETE@@

# @@PLEAC@@_14.6
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_14.7
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_14.8
# shelve uses anydbm to access and chooses between DBMs.
# anydbm detect file formats automatically.
import shelve
db = shelve.open("celebrities.db")

name1 = "Greg Stein"
name2 = "Greg Ward"

# shelve uses pickle to convert objects into strings and back.
# This is automatic.
db[name1] = ["of ViewCVS fame", "gstein@lyra.org"]
db[name2] = ["of Distutils fame", "gward@python.net"]

greg1 = db[name1]
greg2 = db[name2]

print "Two Gregs: %x %x" % (id(greg1), id(greg2))

if greg1 == greg2:
    print "You're having runtime fun with one Greg made two."
else:
    print "No two Gregs are ever alike."

# Changes to mutable entries are not written back by default.
# You can get the copy, change it, and put it back.
entry = db[name1]
entry[0] = "of Subversion fame"
db[name1] = entry

# Or you can open shelve with writeback option. Then you can
# change mutable entries directly. (New in 2.3)
db = shelve.open("celebrities.db", writeback=True)
db[name2][0] = "of Optik fame"

# However, writeback option can consume vast amounts of memory
# to do its magic. You can clear cache with sync().
db.sync()
#-----------------------------

# @@PLEAC@@_14.9
# DON'T DO THIS.
import os as _os, shelve as _shelve

_fname = "persist.db"
if not _os.path.exists(_fname):
    var1 = "foo"
    var2 = "bar"
_d = _shelve.open("persist.db")
globals().update(_d)

print "var1 is %s; var2 is %s"%(var1, var2)
var1 = raw_input("New var1: ")
var2 = raw_input("New var2: ")

for key, val in globals().items():
    if not key.startswith("_"):
        _d[key] = val
# @@INCOMPLETE@@

# @@PLEAC@@_14.10
#-----------------------------
import dbmodule

dbconn = dbmodule.connect(arguments...)

cursor = dbconn.cursor()
cursor.execute(sql)

while True:
   row = cursor.fetchone()
   if row is None:
       break
   ...

cursor.close()
dbconn.close()

#-----------------------------
import MySQLdb
import pwd

dbconn = MySQLdb.connect(db='dbname', host='mysqlserver.domain.com',
                        port=3306, user='user', passwd='password')

cursor = dbconn.cursor()
cursor.execute("CREATE TABLE users (uid INT, login CHAR(8))")

# Note: some databases use %s for parameters, some use ? or other
# formats
sql_fmt = "INSERT INTO users VALUES( %s, %s )"

for userent in pwd.getpwall():
   # the second argument contains a list of parameters which will
   # be quoted before being put in the query
   cursor.execute(sql_fmt, (userent.pw_uid, userent.pw_name))

cursor.execute("SELECT * FROM users WHERE uid < 50")

for row in cursor.fetchall():
   # NULL will be displayed as None
   print ", ".join(map(str, row))

cursor.execute("DROP TABLE users")
cursor.close()
dbconn.close()
#-----------------------------

# @@PLEAC@@_14.11
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_15.1
#-----------------------------
# Parsing program arguments
# -- getopt way (All Python versions)

#-----------------------------
# Preamble

import sys
import getopt

# getopt() explicitly receives arguments for it to process.
# No magic. Explicit is better than implicit.

# PERL: @ARGV
argv = sys.argv[1:]

# Note that sys.argv[0] is the script name, and need to be
# stripped.

#-----------------------------
# Short options

# PERL: getopt("vDo");
# Polluting the caller's namespace is evil. Don't do that.

# PERL: getopt("vDo:", \%opts);
opts, rest = getopt.getopt(argv, "vDo:")

# If you want switches to take arguments, you must say so.
# Unlike PERL, which silently performs its magic, switches
# specified without trailing colons are considered boolean
# flags by default.

# PERL: getopt("vDo", \%opts);
opts, rest = getopt.getopt(argv, "v:D:o:")

# PERL: getopts("vDo:", \%opts);
# getopt/getopts distinction is not present in Python 'getopt'
# module.

#-----------------------------
# getopt() return values, compared to PERL

# getopt() returns two values. The first is a list of
# (option, value) pair. (Not a dictionary, i.e. Python hash.)
# The second is the list of arguments left unprocessed.

# Example
# >>> argv = "-v ARG1 -D ARG2 -o ARG3".split()
# >>> opts, rest = getopt.getopt(argv, "v:D:o:")
# >>> print opts
# [('-v', 'ARG1'), ('-D', 'ARG2'), ('-o', 'ARG3')]

#-----------------------------
# Long options

# getopt() handles long options too. Pass a list of option
# names as the third argument. If an option takes an argument,
# append an equal sign.

opts, rest = getopt.getopt(argv, "", [
    "verbose", "Debug", "output="])

#-----------------------------
# Switch clustering

# getopt() does switch clustering just fine.

# Example
# >>> argv1 = '-r -f /tmp/testdir'.split()
# >>> argv2 = '-rf /tmp/testdir'.split()
# >>> print getopt.getopt(argv1, 'rf')
# ([('-r', ''), ('-f', '')], ['/tmp/testdir'])
# >>> print getopt.getopt(argv2, 'rf')
# ([('-r', ''), ('-f', '')], ['/tmp/testdir'])

#-----------------------------
# @@INCOMPLETE@@

# TODO: Complete this section using 'getopt'. Show how to
# use the parsed result.

# http://www.python.org/doc/current/lib/module-getopt.html
# Python library reference has a "typical usage" demo.

# TODO: Introduce 'optparse', a very powerful command line
# option parsing module. New in 2.3.


# @@PLEAC@@_15.2
##------------------
import sys

def is_interactive_python():
    try:
        ps = sys.ps1
    except:
        return False
    return True
##------------------
import sys
def is_interactive():
    # only False if stdin is redirected like "-t" in perl.
    return sys.stdin.isatty()

# Or take advantage of Python's Higher Order Functions:
is_interactive = sys.stdin.isatty
##------------------
import posix
def is_interactive_posix():
    tty = open("/dev/tty")
    tpgrp = posix.tcgetpgrp(tty.fileno())
    pgrp = posix.getpgrp()
    tty.close()
    return (tpgrp == pgrp)

# test with:
#  python 15.2.py
#  echo "dummy" | python 15.2.py | cat
print "is python shell:", is_interactive_python()
print "is a tty:", is_interactive()
print "has no tty:", is_interactive_posix()

if is_interactive():
    while True:
        try:
            ln = raw_input("Prompt:")
        except:
            break
        print "you typed:", ln


# @@PLEAC@@_15.3

# Python has no Term::Cap module.
# One could use the curses, but this was not ported to windows,
# use console.

# just run clear
import os
os.system("clear")
# cache output
clear = os.popen("clear").read()
print clear
# or to avoid print's newline
sys.stdout.write(clear)

# @@PLEAC@@_15.4
# Determining Terminal or Window Size

# eiter use ioctl
import struct, fcntl, termios, sys

s = struct.pack("HHHH", 0, 0, 0, 0)
hchar, wchar = struct.unpack("HHHH", fcntl.ioctl(sys.stdout.fileno(),
                                 termios.TIOCGWINSZ, s))[:2]
# or curses
import curses
(hchar,wchar) = curses.getmaxyx()

# graph contents of values
import struct, fcntl, termios, sys
width = struct.unpack("HHHH", fcntl.ioctl(sys.stdout.fileno(),
                                 termios.TIOCGWINSZ, 
                                 struct.pack("HHHH", 0, 0, 0, 0)))[1]
if width<10:
    print "You must have at least 10 characters"
    raise SystemExit

max_value = 0                    
for v in values:
    max_value = max(max_value,v)
    
ratio = (width-10)/max_value   # chars per unit
for v in values:
    print "%8.1f %s" % (v, "*"*(v*ratio))

# @@PLEAC@@_15.5

# there seems to be no standard ansi module
# and BLINK does not blink here.
RED = '\033[31m'
RESET = '\033[0;0m'
BLINK = '\033[05m'
NOBLINK = '\033[25m'

print RED+"DANGER, Will Robinson!"+RESET
print "This is just normal text"
print "Will ``"+BLINK+"Do you hurt yet?"+NOBLINK+"'' and back"

# @@PLEAC@@_15.6

# Show ASCII values for keypresses

# _Getch is from http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/134892
class _Getch:
    """Gets a single character from standard input.  Doesn't echo to screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self):
        return self.impl()


class _GetchUnix:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt
        return msvcrt.getch()


getch = _Getch()

print "Press keys to see their ASCII values.  Use Ctrl-C to quit.\n"
try:
    while True:
        char = ord(getch())
        if char == 3:
            break
        print " Decimal: %3d   Octal: %3o   Hex: x%02x" % (char, char, char)
except KeyboardError:
    pass
#----------------------------------------

# @@PLEAC@@_15.7
print "\aWake up!\n";
#----------------------------------------
# @@INCOMPLETE@@

# @@PLEAC@@_15.8
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_15.9
# On Windows
import msvcrt
if msvcrt.kbhit():
    c = msvcrt.getch

# See http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/134892
# @@INCOMPLETE@@


# @@PLEAC@@_15.10
#----------------------------------------
import getpass
import pwd
import crypt
password = getpass.getpass('Enter your password: ')
username = getpass.getuser()
encrypted = pwd.getpwnam(username).pw_passwd
if not encrypted or encrypted == 'x':
    # If using shadow passwords, this will be empty or 'x'
    print "Cannot verify password"
elif crypt.crypt(password, encrypted) != encrypted:
    print "You are not", username
else:
    print "Welcome,", username
#----------------------------------------

# @@PLEAC@@_15.11

# simply importing readline gives line edit capabilities to raw_
import readline
readline.add_history("fake line")
line = raw_input()

# download the following standalone program
#!/usr/bin/python
# vbsh - very bad shell

import os
import readline

while True:
    try:
        cmd = raw_input('$ ')
    except EOFError:
        break
    status = os.system(cmd)
    exit_value = status >> 8
    signal_num = status & 127
    dumped_core = status & 128 and "(core dumped)" or ""
    print "Program terminated with status %d from signal %d%s\n" % (
            exit_value, signal_num, dumped_core)



readline.add_history("some line!")
readline.remove_history_item(position)
line = readline.get_history_item(index)

# an interactive python shell would be
import code, readline
code.InteractiveConsole().interact("code.InteractiveConsole")

# @@PLEAC@@_15.12
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_15.13
#----------------------------------------
# This entry uses pexpect, a pure Python Expect-like module.
# http://pexpect.sourceforge.net/

# for more information, check pexpect's documentation and example.

import pexpect

#----------------------------------------
# spawn program
try:
    command = pexpect.spawn("program to run")
except pexpect.ExceptionPexpect:
    # couldn't spawn program
    pass

#----------------------------------------
# you can pass any filelike object to setlog
# passing None will stop logging

# stop logging
command.setlog(None)

# log to stdout
import sys
command.setlog(sys.stdout)

# log to specific file
fp = file("pexpect.log", "w")
command.setlog(fp)

#----------------------------------------
# expecting simple string
command.expect("ftp>")

# expecting regular expression
# actually, string is always treated as regular expression

# so it's the same thing
command.expect("Name.*:")

# you can do it this way, too
import re
regex = re.compile("Name.*:")
command.expect(regex)

#----------------------------------------
# expecting with timeout
try:
    command.expect("Password:", 10)
except pexpect.TIMEOUT:
    # timed out
    pass

# setting default timeout
command.timeout = 10

# since we set default timeout, following does same as above
try:
    command.expect("Password:")
except pexpect.TIMEOUT:
    # timed out
    pass

#----------------------------------------
# what? do you *really* want to wait forever?

#----------------------------------------
# sending line: normal way
command.sendline("get spam_and_ham")

# you can also treat it as file
print>>command, "get spam_and_ham"

#----------------------------------------
# finalization

# close connection with child process
# (that is, freeing file descriptor)
command.close()

# kill child process
import signal
command.kill(signal.SIGKILL)

#----------------------------------------
# expecting multiple choices
which = command.expect(["invalid", "success", "error", "boom"])

# return value is index of matched choice
# 0: invalid
# 1: success
# 2: error
# 3: boom

#----------------------------------------
# avoiding exception handling
choices = ["invalid", "success", "error", "boom"]
choices.append(pexpect.TIMEOUT)
choices.append(pexpect.EOF)

which = command.expect(choices)

# if TIMEOUT or EOF occurs, appropriate index is returned
# (instead of raising exception)
# 4: TIMEOUT
# 5: EOF

# @@PLEAC@@_15.14
from Tkinter import *

def print_callback():
    print "print_callback"

main = Tk()

menubar = Menu(main)
main.config(menu=menubar)

file_menu = Menu(menubar)
menubar.add_cascade(label="File", underline=1, menu=file_menu)
file_menu.add_command(label="Print", command=print_callback)

main.mainloop()

# using a class
from Tkinter import *

class Application(Tk):
    def print_callback(self):
        print "print_callback"
    def debug_callback(self):
        print "debug:", self.debug.get()
        print "debug level:", self.debug_level.get()

    def createWidgets(self):
        menubar = Menu(self)
        self.config(menu=menubar)
        file_menu = Menu(menubar)
        menubar.add_cascade(label="File",      
                    underline=1, menu=file_menu)
        file_menu.add_command(label="Print",
                command=self.print_callback)
        file_menu.add_command(label="Quit Immediately",
                command=sys.exit)
        # 
        options_menu = Menu(menubar)
        menubar.add_cascade(label="Options",
                underline=0, menu=options_menu)
        options_menu.add_checkbutton(
                label="Create Debugging File",
                variable=self.debug,
                command=self.debug_callback,
                onvalue=1, offvalue=0)
        options_menu.add_separator()
        options_menu.add_radiobutton(
                label = "Level 1",
                variable = self.debug_level,
                value = 1
                )
        options_menu.add_radiobutton(
                label = "Level 2",
                variable = self.debug_level,
                value = 2
                )
        options_menu.add_radiobutton(
                label = "Level 3",
                variable = self.debug_level,
                value = 3
                )

    def __init__(self, master=None):
        Tk.__init__(self, master)
        # bound variables must be IntVar, StrVar, ...
        self.debug = IntVar()
        self.debug.set(0)
        self.debug_level = IntVar()
        self.debug_level.set(1)
        self.createWidgets()

app = Application()
app.mainloop()

# @@PLEAC@@_15.15
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_15.16
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_15.17
# Start Python scripts without the annoying DOS window on win32
# Use extension ".pyw" on files - eg: "foo.pyw" instead of "foo.py"
# Or run programs using "pythonw.exe" rather than "python.exe" 

# @@PLEAC@@_15.18
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_15.19
# @@INCOMPLETE@@
# @@INCOMPLETE@@


# @@PLEAC@@_16.1
import popen2

# other popen methods than popen4 can lead to deadlocks
# if there is much data on stdout and stderr

(err_out, stdin) = popen2.popen4("program args")
lines = err_out.read() # collect output into one multiline string

(err_out, stdin) = popen2.popen4("program args")
lines = err_out.readlines() # collect output into a list, one line per element

#-----------------------------

(err_out, stdin) = popen2.popen4("program args")
output = []
while True:
    line = err_out.readline()
    if not line:
        break
    output.appen(line)
output = ''.join(output)

# @@PLEAC@@_16.2
import os
myfile = "foo.txt"
status = os.system("vi %s" % myfile)

#-----------------------------
import os
os.system("cmd1 args | cmd2 | cmd3 >outfile")
os.system("cmd args <infile >outfile 2>errfile")

status = os.system("%s %s %s" % (program, arg1, arg2))
if status != 0:
    print "%s exited funny: %s" % (program, status)
    raise SystemExit
    

# @@PLEAC@@_16.3
# -----------------------------
import os
import sys
import glob

args = glob.glob("*.data")
try:
    os.execvp("archive", args)
except OSError, e:
    print "Couldn't replace myself with archive: %s" % err
    raise SystemExit

# The error message does not contain the line number like the "die" in
# perl. But if you want to show more information for debugging, you can
# delete the try...except and you get a nice traceback which shows all
# line numbers and filenames.

# -----------------------------
os.execvp("archive", ["accounting.data"])

# @@PLEAC@@_16.4
# -------------------------
# Read from a child process

import sys
import popen2
pipe = popen2.Popen4("program arguments")
pid = pipe.pid
for line in pipe.fromchild.readlines():
    sys.stdout.write(line)

# Popen4 provides stdout and stderr.
# This avoids deadlocks if you get data
# from both streams.
#
# If you don't need the pid, you
# can use popen2.popen4(...)

# -----------------------------
# Write to a child process

import popen2

pipe = popen2.Popen4("gzip > foo.gz")
pid = pipe.pid
pipe.tochild.write("Hello zipped world!\n")
pipe.tochild.close() # programm will get EOF on STDIN

# @@PLEAC@@_16.5
class OutputFilter(object):
    def __init__(self, target, *args, **kwds):
        self.target = target
        self.setup(*args, **kwds)
        self.textbuffer = ""

    def setup(self, *args, **kwds):
        pass
    
    def write(self, data):
        if data.endswith("\n"):
            data = self.process(self.textbuffer + data)
            self.textbuffer = ""
            if data is not None:
                self.target.write(data)
        else:
            self.textbuffer += data

    def process(self, data):
        return data

class HeadFilter(OutputFilter):
    def setup(self, maxcount):
        self.count = 0
        self.maxcount = maxcount

    def process(self, data):
        if self.count < self.maxcount:
            self.count += 1
            return data

class NumberFilter(OutputFilter):
    def setup(self):
        self.count=0

    def process(self, data):
        self.count += 1
        return "%s: %s"%(self.count, data)

class QuoteFilter(OutputFilter):
    def process(self, data):
        return "> " + data

import sys
f = HeadFilter(sys.stdout, 100)
for i in range(130):
    print>>f, i

print

txt = """Welcome to Linux, version 2.0.33 on a i686

"The software required `Windows 95 or better', 
so I installed Linux." """
f1 = NumberFilter(sys.stdout)
f2 = QuoteFilter(f1)
for line in txt.split("\n"):
    print>>f2, line
print
f1 = QuoteFilter(sys.stdout)
f2 = NumberFilter(f1)
for line in txt.split("\n"):
    print>>f2, line


# @@PLEAC@@_16.6
# This script accepts several filenames
# as argument. If the file is zipped, unzip
# it first. Then read each line if the file
import os
import sys
import popen2

for file in sys.argv[1:]:
    if file.endswith(".gz") or file.endswith(".Z"):
        (stdout, stdin) = popen2.popen2("gzip -dc '%s'" % file)
        fd = stdout
    else:
        fd = open(file)
    for line in fd:
        # ....
        sys.stdout.write(line)
    fd.close()
#-----------------------------

#-----------------------------
# Ask for filename and open it
import sys
print "File, please?"
line = sys.stdin.readline()
file = line.strip() # chomp
open(file)

# @@PLEAC@@_16.7
# Execute foo_command and read the output

import popen2
(stdout_err, stdin) = popen2.popen4("foo_command")
for line in stdout_err.readlines():
    # ....

# @@PLEAC@@_16.8
# Open command in a pipe
# which reads from stdin and writes to stdout

import popen2
pipe = popen2.Popen4("wc -l") # Unix command
pipe.tochild.write("line 1\nline 2\nline 3\n")
pipe.tochild.close()
output = pipe.fromchild.read()

# @@PLEAC@@_16.9

# popen3: get stdout and stderr of new process
# Attetion: This can lead to deadlock,
# since the buffer of stderr or stdout might get filled.
# You need to use select if you want to avoid this.

import popen2
(child_stdout, child_stdin, child_stderr) = popen2.popen3(...)

# @@PLEAC@@_16.10
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_16.11
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_16.12
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_16.13
#
# Print available signals and their value
# See "man signal" "man kill" on unix.

import signal
for name in dir(signal):
    if name.startswith("SIG"):
        value = getattr(signal, name)
        print "%s=%s" % (name, value)

# @@PLEAC@@_16.14
# You can send signals to processes
# with os.kill(pid, signal)


# @@PLEAC@@_16.15
import signal

def get_sig_quit(signum, frame):
    ....

signal.signal(signal.SIGQUIT, get_sig_quit)   # Install handler

signal.signal(signal.SIGINT, signal.SIG_IGN)  # Ignore this signal
signal.signal(signal.SIGSTOP, signal.SIG_DFL) # Restore to default handling

# @@PLEAC@@_16.16
# Example of handler: User must Enter Name ctrl-c does not help

import sys
import signal

def ding(signum, frame):
    print "\aEnter your name!"
    return

signal.signal(signal.SIGINT, ding)
print "Please enter your name:"

name = ""
while not name:
    try:
        name = sys.stdin.readline().strip()
    except:
        pass

print "Hello: %s" % name

# @@PLEAC@@_16.17
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_16.18
import signal

# ignore signal INT
signal.signal(signal.SIGINT, signal.SIG_IGN)

# Install signal handler
def tsktsk(signum, frame):
    print "..."

signal.signal(signal.SIGINT, tsktsk)

# @@PLEAC@@_16.19
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_16.20
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_16.21
import signal

def handler(signum, frame):
    raise "timeout"

signal.signal(signal.SIGALRM, handler)

try:
    signal.alarm(5) # signal.alarm(3600)

    # long-time operation
    while True:
        print "foo"

    signal.alarm(0)
except:
    signal.alarm(0)
    print "timed out"
else:
    print "no time out"

# @@PLEAC@@_16.22
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.0
# Socket Programming (tcp/ip and udp/ip)

import socket

# Convert human readable form to 32 bit value
packed_ip = socket.inet_aton("208.146.240.1")
packed_ip = socket.inet_aton("www.oreilly.com")

# Convert 32 bit value to ip adress
ip_adress = socket.inet_ntoa(packed_ip)

# Create socket object
socketobj = socket(family, type) # Example socket.AF_INT, socket.SOCK_STREAM
       
# Get socketname
socketobj.getsockname() # Example, get port adress of client

# @@PLEAC@@_17.1

# Example: Connect to a server (tcp)
# Connect to a smtp server at localhost and send an email.
# For real applications you should use smtplib.

import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", 25)) # SMTP
print s.recv(1024)
s.send("mail from: <pleac@localhost>\n")
print s.recv(1024)
s.send("rcpt to: <guettli@localhost>\n")
print s.recv(1024)
s.send("data\n")
print s.recv(1024)
s.send("From: Python Lover\nSubject: Python is better then perl\n\nYES!\n.\n")
print s.recv(1024)
s.close()

# @@PLEAC@@_17.2

# Create a Server, calling handler for every client
# You can test it with "telnet localhost 1029"

from SocketServer import TCPServer
from SocketServer import BaseRequestHandler

class MyHandler(BaseRequestHandler):
    def handle(self):
        print "I got an request"
        
server = TCPServer(("127.0.0.1", 1029), MyHandler)
server.serve_forever()

# @@PLEAC@@_17.3
# This is the continuation of 17.2

import time
from SocketServer import TCPServer
from SocketServer import BaseRequestHandler

class MyHandler(BaseRequestHandler):
    def handle(self):
        # self.request is the socket object
        print "%s I got an request from ip=%s port=%s" % (
            time.strftime("%Y-%m-%d %H:%M:%S"),
            self.client_address[0],
            self.client_address[1]
            )
        self.request.send("What is your name?\n")
        bufsize=1024
        response=self.request.recv(bufsize).strip() # or recv(bufsize, flags)
        data_to_send="Welcome %s!\n" % response
        self.request.send(data_to_send) # or send(data, flags)
        print "%s connection finnished" % self.client_address[0]
        
server = TCPServer(("127.0.0.1", 1028), MyHandler)
server.serve_forever()

# -----------------
# Using select

import select
import socket

in_list = []
in_list.append(mysocket)
in_list.append(myfile)
# ...

out_list = []
out_list.append(...)

except_list = []
except_list.append(...)

(in_, out_, exc_) = select.select(in_list, out_list, except_list, timeout)

for fd in in_:
    print "Can read", fd
for fd in out_:
    print "Can write", fd
for fd in exc_:
    print "Exception on", fd

# Missing: setting TCP_NODELAY

# @@PLEAC@@_17.4

import socket
# Set up a UDP socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# send 
MSG = 'Hello'
HOSTNAME = '127.0.0.1'
PORTNO = 10000
s.connect((HOSTNAME, PORTNO))
if len(MSG) != s.send(MSG):
    # where to get error message "$!".
    print "cannot send to %s(%d):" % (HOSTNAME,PORTNO)
    raise SystemExit(1)
MAXLEN = 1024
(data,addr) = s.recvfrom(MAXLEN)
s.close()
print '%s(%d) said "%s"' % (addr[0],addr[1], data)

# download the following standalone program
#!/usr/bin/python
# clockdrift - compare another system's clock with this one

import socket
import struct
import sys
import time

if len(sys.argv)>1:
    him = sys.argv[1]
else:
    him = '127.1'

SECS_of_70_YEARS = 2208988800

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect((him,socket.getservbyname('time','udp')))
s.send('')
(ptime, src) = s.recvfrom(4)
host = socket.gethostbyaddr(src[0])
delta = struct.unpack("!L", ptime)[0] - SECS_of_70_YEARS - time.time()
print "Clock on %s is %d seconds ahead of this one." % (host[0], delta)



# @@PLEAC@@_17.5

import socket
import sys

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
try:
    s.bind(('', server_port))
except socket.error, err:
    print "Couldn't be a udp server on port %d : %s" % (
            server_port, err)
    raise SystemExit

while True:
    datagram = s.recv(MAX_TO_READ)
    if not datagram:
        break
    # do something
s.close()

# or 
import SocketServer

class handler(SocketServer.DatagramRequestHandler):
    def handle(self):
        # do something (with self.request[0])

s = SocketServer.UDPServer(('',10000), handler)
s.serve_forever()

# download the following standalone program
#!/usr/bin/python
# udpqotd - UDP message server

import SocketServer

PORTNO = 5151

class handler(SocketServer.DatagramRequestHandler):
    def handle(self):
        newmsg = self.rfile.readline().rstrip()
        print "Client %s said ``%s''" % (self.client_address[0], newmsg)
        self.wfile.write(self.server.oldmsg)
        self.server.oldmsg = newmsg

s = SocketServer.UDPServer(('',PORTNO), handler)
print "Awaiting UDP messages on port %d" % PORTNO
s.oldmsg = "This is the starting message."
s.serve_forever()


# download the following standalone program
#!/usr/bin/python
# udpmsg - send a message to the udpquotd server

import socket
import sys

MAXLEN = 1024
PORTNO = 5151
TIMEOUT = 5

server_host = sys.argv[1]
msg = " ".join(sys.argv[2:])

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(TIMEOUT)
sock.connect((server_host, PORTNO))
sock.send(msg)
try:
    msg = sock.recv(MAXLEN)
    ipaddr, port = sock.getpeername()
    hishost = socket.gethostbyaddr(ipaddr)
    print "Server %s responded ``%s''" % ( hishost[0], msg)
except:
    print "recv from %s failed (timeout or no server running)." % (
            server_host )
sock.close()


# @@PLEAC@@_17.6

import socket
import os, os.path

if os.path.exists("/tmp/mysock"):
    os.remove("/tmp/mysock")
        
server = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
server.bind("/tmp/mysock")

client = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
client.connect("/tmp/mysock")
        
# @@PLEAC@@_17.7

ipaddr, port = s.getpeername()
hostname, aliaslist, ipaddrlist = socket.gethostbyaddr(ipaddr)
ipaddr = socket.gethostbyname('www.python.org')
# '194.109.137.226'
hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex('www.python.org')
# ('fang.python.org', ['www.python.org'], ['194.109.137.226'])
socket.gethostbyname_ex('www.google.org')
# ('www.l.google.com', ['www.google.org', 'www.google.com'], 
#  ['64.233.161.147','64.233.161.104', '64.233.161.99'])

# @@PLEAC@@_17.8

import os

kernel, hostname, release, version, hardware = os.uname()

import socket

address = socket.gethostbyname(hostname)
hostname = socket.gethostbyaddr(address)
hostname, aliaslist, ipaddrlist = socket.gethostbyname_ex(hostname)
# e.g. ('lx3.local', ['lx3', 'b70'], ['192.168.0.13', '192.168.0.70'])

# @@PLEAC@@_17.9

socket.shutdown(0)   # Further receives are disallowed
socket.shutdown(1)   # Further sends are disallowed.
socket.shutdown(2)   # Further sends and receives are disallowed.

#

server.send("my request\n")  # send some data
server.shutdown(1)           # send eof; no more writing
answer = server.recv(1000)   # but you can still read

# @@PLEAC@@_17.10
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.11
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.12
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.13
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.14
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.15
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_17.16
#------------------------------
# Restart programm on signal SIGHUP
# Script must be executable: chmod a+x foo.py

#!/usr/bin/env python
import os
import sys
import time
import signal

def phoenix(signum, frame):
    print "Restarting myself: %s %s" % (self, args)
    os.execv(self, args)

self = os.path.abspath(sys.argv[0])
args = sys.argv[:]
signal.signal(signal.SIGHUP, phoenix)

while True:
    print "work"
    time.sleep(1)

#--------------------
# Read config file on SIGHUP
import signal

config_file = "/usr/local/etc/myprog/server_conf.py"

def read_config():
    execfile(config_file)

signal.signal(signal.SIGHUP, read_config)

# @@PLEAC@@_17.17

# chroot

import os

try:
    os.chroot("/var/daemon")
except Exception:
    print "Could not chroot"
    raise SystemExit(1)

#-----------------------------
# fork (Unix): Create a new process
# if pid == 0 --> parent process
# else child process

import os

pid = os.fork()
if pid:
    print "I am the new child %s" % pid
    raise SystemExit
else:
    print "I am still the parent"
    

# ----------------------------
# setsid (Unix): Create a new session
import os
id=os.setsid()

# ----------------------------
# Work until INT TERM or HUP signal is received
import time
import signal

time_to_die = 0

def sighandler(signum, frame):
    print "time to die"
    global time_to_die
    time_to_die = 1

signal.signal(signal.SIGINT, sighandler)
signal.signal(signal.SIGTERM, sighandler)
signal.signal(signal.SIGHUP, sighandler)

while not time_to_die:
    print "work"
    time.sleep(1)

# @@PLEAC@@_17.18
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_18.1

import socket
try:
    host_info = socket.gethostbyname_ex(name)
    # (hostname, aliaslist, ipaddrlist)
except socket.gaierror, err:
    print "Can't resolve hostname %s: %s" % (name, err[1])
                    
# if you only need the first one
import socket
try:
    address = socket.gethostbyname(name)
except socket.gaierror, err:
    print "Can't resolve hostname %s: %s" % (name, err[1])

# if you have an ip address
try:
    host_info = socket.gethostbyaddr(address)
    # (hostname, aliaslist, ipaddrlist)
except socket.gaierror, err:
    print "Can't resolve address %s: %s" % (address, err[1])
                    
# checking back
import socket
try:
    host_info = socket.gethostbyaddr(address)
except socket.gaierror, err:
    print "Can't look up %s: %s" % (address, err[1])
    raise SystemExit(1)
try:
    host_info = socket.gethostbyname_ex(name)
except:
    print "Can't look up %s: %s" % (name, err[1])
    raise SystemExit(1)

found = address in host_info[2]

# use dnspython for more complex jobs.
# download the following standalone program
#!/usr/bin/python
# mxhost - find mx exchangers for a host

import sys

import dns
import dns.resolver

answers = dns.resolver.query(sys.argv[1], 'MX')
for rdata in answers:
    print rdata.preference, rdata.exchange



# download the following standalone program
#!/usr/bin/python
# hostaddrs - canonize name and show addresses

import sys
import socket
name = sys.argv[1]
hent = socket.gethostbyname_ex(name)
print "%s aliases: %s => %s" % (
            hent[0],
            len(hent[1])==0 and "None" or ",".join(hent[1]),
            ",".join(hent[2]) )


# @@PLEAC@@_18.2
import ftplib
ftp = ftplib.FTP("ftp.host.com")
ftp.login(username, password)
ftp.cwd(directory)

# get file
outfile = open(filename, "wb")
ftp.retrbinary("RETR %s" % filename, outfile.write)
outfile.close()

# upload file
upfile = open(upfilename, "rb")
ftp.storbinary("STOR %s" % upfilename, upfile)
upfile.close()

ftp.quit()


# @@PLEAC@@_18.3
import smtplib
from email.MIMEText import MIMEText

msg = MIMEText(body)
msg['From'] = from_address
msg['To'] = to_address
msg['Subject'] = subject

mailer = smtplib.SMTP()
mailer.connect()
mailer.sendmail(from_address, [to_address], msg.as_string())

# @@PLEAC@@_18.4
import nntplib

# You can except nntplib.NNTPError to process errors
# instead of displaying traceback.

server = nntplib.NNTP("news.example.com")
response, count, first, last, name = server.group("misc.test")
headers = server.head(first)
bodytext = server.body(first)
article = server.article(first)

f = file("article.txt")
server.post(f)

response, grouplist = server.list()
for group in grouplist:
    name, last, first, flag = group
    if flag == 'y':
        pass  # I can post to group

# @@PLEAC@@_18.5
import poplib

pop = poplib.POP3("mail.example.com")
pop.user(username)
pop.pass_(password)
count, size = pop.stat()
for i in range(1, count+1):
    reponse, message, octets = pop.retr(i)
    # message is a list of lines
    pop.dele(i)

# You must quit, otherwise mailbox remains locked.
pop.quit()

# @@PLEAC@@_18.6

import telnetlib

tn = telnetlib.Telnet(hostname)

tn.read_until("login: ")
tn.write(user + "\n")
tn.read_until("Password: ")
tn.write(password + "\n")
# read the logon message up to the prompt
d = tn.expect([prompt,], 10)
tn.write("ls\n")
files = d[2].split()
print len(files), "files"
tn.write("exit\n")
print tn.read_all() # blocks till eof

# @@PLEAC@@_18.7
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_18.8
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_18.9
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_19.0
# Introduction
#
# There is no standard cgi/web framework in python,
# this is reason for ranting now and then.
#
# See `PyWebOff <http://pyre.third-bit.com/pyweb/index.html>`__
# which compares CherryPy, Quixote, Twisted, WebWare and Zope
# Karrigell and print stantements. 
#
# Then there is Nevow and Standalone ZPT.

# @@PLEAC@@_19.1
# Partial implementation of PLEAC Python section 19.1
# Written by Seo Sanghyeon

# Standard CGI module is where PERL shines. Python
# module, cgi, is nothing but a form parser. So it is
# not really fair to compare these two. But I hesitate
# to introduce any non-standard module. After all,
# which one should I choose?

# I would stick to simple print statements. I believe
# the following is close to how these tasks are usually
# done in Python.

#-----------------------------
#!/usr/bin/env python
# hiweb - using FieldStorage class to get at form data

import cgi
form = cgi.FieldStorage()

# get a value from the form
value = form.getvalue("PARAM_NAME")

# print a standard header
print "Content-Type: text/html"
print

# print a document
print "<P>You typed: <TT>%s</TT></P>" % (
    cgi.escape(value),
    )

#-----------------------------
import cgi
form = cgi.FieldStorage()

who = form.getvalue("Name")
phone = form.getvalue("Number")
picks = form.getvalue("Choices")

# if you want to assure `picks' to be a list
picks = form.getlist("Choices")

#-----------------------------
# Not Implemented

# To implement -EXPIRES => '+3d', I need to study about
import cgi
import datetime

time_format = "%a, %d %b %Y %H:%M:%S %Z"
print "Expires: %s" % (
        (datetime.datetime.now()
        + datetime.timedelta(+3)).strftime(time_format)
        )
print "Date: %s" % (datetime.datetime.now().strftime(time_format))
print "Content-Type: text/plain; charset=ISO-8859-1"

#-----------------------------
# NOTES

# CGI::param() is a multi-purpose function. Here I want to
# note which Python functions correspond to it.

# PERL version 5.6.1, CGI.pm version 2.80.
# Python version 2.2.3. cgi.py CVS revision 1.68.

# Assume that `form' is the FieldStorage instance.

# param() with zero argument returns parameter names as
# a list. It is `form.keys()' in Python, following Python's
# usual mapping interface.

# param() with one argument returns the value of the named
# parameter. It is `form.getvalue()', but there are some
# twists:

# 1) A single value is passed.
# No problem.

# 2) Multiple values are passed.
# PERL: in LIST context, you get a list. in SCALAR context,
#       you get the first value from the list.
# Python: `form.getvalue()' returns a list if multiple
#         values are passed, a raw value if a single value
#         is passed. With `form.getlist()', you always
#         get a list. (When a single value is passed, you
#         get a list with one element.) With `form.getfirst()',
#         you always get a value. (When multiple values are
#         passed, you get the first one.)

# 3) Parameter name is given, but no value is passed.
# PERL: returns an empty string, not undef. POD says this
#       feature is new in 2.63, and was introduced to avoid
#       "undefined value" warnings when running with the
#       -w switch.
# Python: tricky. If you want black values to be retained,
#         you should pass a nonzero `keep_blank_values' keyword
#         argument. Default is not to retain blanks. In case
#         values are not retained, see below.

# 4) Even parameter name is never mentioned.
# PERL: returns undef.
# Python: returns None, or whatever you passed as the second
#         argument, or `default` keyword argument. This is
#         consistent with `get()' method of the Python mapping
#         interface.

# param() with more than one argument modifies the already
# set form data. This functionality is not available in Python
# cgi module.


# @@PLEAC@@_19.2
# enable() from 'cgitb' module, by default, redirects traceback
# to the browser. It is defined as 'enable(display=True, logdir=None,
# context=5)'.

# equivalent to importing CGI::Carp::fatalsToBrowser.
import cgitb
cgitb.enable()

# to suppress browser output, you should explicitly say so.
import cgitb
cgitb.enable(display=False)

# equivalent to call CGI::Carp::carpout with temporary files.
import cgitb
cgitb.enable(logdir="/var/local/cgi-logs/")

# Python exception, traceback facilities are much richer than PERL's
# die and its friends. You can use your custom exception formatter
# by replacing sys.excepthook. (equivalent to CGI::Carp::set_message.)
# Default formatter is available as traceback.print_exc() in pure
# Python. In fact, what cgitb.enable() does is replacing excepthook
# to cgitb.handler(), which knows how to format exceptions to HTML.

# If this is not enough, (usually this is enough!) Python 2.3 comes
# with a new standard module called 'logging', which is complex, but
# very flexible and entirely customizable.

# @@PLEAC@@_19.3
#
# download the following standalone program
#!/usr/bin/python
# webwhoami - show web users id
import getpass
print "Content-Type: text/plain\n"
print "Running as %s\n" % getpass.getuser()



# STDOUT/ERR flushing
#
# In contrast to what the perl cookbook says, modpython.org tells
# STDERR is buffered too.

# @@PLEAC@@_19.4
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_19.5

# use mod_python in the Apache web server.

# Load the module in httpd.conf or apache.conf

LoadModule python_module libexec/mod_python.so

<Directory /some/directory/htdocs/test>
    AddHandler mod_python .py
    PythonHandler mptest
    PythonDebug On
</Directory>

# test.py file in /some/directory/htdocs/test
from mod_python import apache

def handler(req):
    req.write("Hello World!")
    return apache.OK

# @@PLEAC@@_19.6

import os
os.system("command %s %s" % (input, " ".join(files))) # UNSAFE

# python doc lib cgi-security it says
#
# To be on the safe side, if you must pass a string gotten from a form to a shell
# command, you should make sure the string contains only alphanumeric characters, dashes,
# underscores, and periods.
import re
cmd = "command %s %s" % (input, " ".join(files))
if re.search(r"[^a-zA-Z0-9._\-]", cmd):
    print "rejected"
    sys.exit(1)
os.system(cmd)
trans = string.maketrans(string.ascii_letters+string.digits+"-_.",

# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_19.7
#-----------------------------
# This uses nevow's (http://nevow.com) stan; there's no standard
# way to generate HTML, though there are many implementations of
# this basic idea.
from nevow import tags as T
print T.ol[T.li['red'], T.li['blue'], T.li['green']]
# <ol><li>red</li><li>blue</li><li>green</li></ol>

names = 'Larry Moe Curly'.split()
print T.ul[ [T.li(type="disc")[name] for name in names] ]
# <ul><li type="disc">Larry</li><li type="disc">Moe</li>
#     <li type="disc">Curly</li></ul>
#-----------------------------
print T.li["alpha"]
#     <li>alpha</li>

print T.li['alpha'], T.li['omega']
#     <li>alpha</li> <li>omega</li>
#-----------------------------
states = {
    "Wisconsin":  [ "Superior", "Lake Geneva", "Madison" ],
    "Colorado":   [ "Denver", "Fort Collins", "Boulder" ],
    "Texas":      [ "Plano", "Austin", "Fort Stockton" ],
    "California": [ "Sebastopol", "Santa Rosa", "Berkeley" ],
}

print "<TABLE> <CAPTION>Cities I Have Known</CAPTION>";
print T.tr[T.th('State'), T.th('Cities')]
for k in sorted(states.keys()):
    print T.tr[ [T.th(k)] + [T.td(city) for city in sorted(states[k])] ]
print "</TABLE>";
#-----------------------------
# <TABLE> <CAPTION>Cities I Have Known</CAPTION>
#
#     <TR><TH>State</TH> <TH>Cities</TH></TR>
#
#     <TR><TH>California</TH> <TD>Berkeley</TD> <TD>Santa Rosa</TD>
#
#         <TD>Sebastopol</TD> </TR>
#
#     <TR><TH>Colorado</TH> <TD>Boulder</TD> <TD>Denver</TD>
#
#         <TD>Fort Collins</TD> </TR>
#
#     <TR><TH>Texas</TH> <TD>Austin</TD> <TD>Fort Stockton</TD>
#
#         <TD>Plano</TD></TR>
#
#     <TR><TH>Wisconsin</TH> <TD>Lake Geneva</TD> <TD>Madison</TD>
#
#         <TD>Superior</TD></TR>
#
# </TABLE>
#-----------------------------
print T.table[
        [T.caption['Cities I have Known'],
         T.tr[T.th['State'], T.th['Cities']] ] +
        [T.tr[ [T.th(k)] + [T.td(city) for city in sorted(states[k])]]
         for k in sorted(states.keys())]]
#-----------------------------
# salcheck - check for salaries
import MySQLdb
import cgi

form = cgi.FieldStorage()

if 'limit' in form:
    limit = int(form['limit'].value)
else:
    limit = ''

# There's not a good way to start an HTML/XML construct with stan
# without completing it.
print '<html><head><title>Salary Query</title></head><body>'
print T.h1['Search']
print '<form>'
print T.p['Enter minimum salary',
          T.input(type="text", name="limit", value=limit)]
print T.input(type="submit")
print '</form>'

if limit:
    dbconn = MySQLdb.connect(db='somedb', host='server.host.dom',
                             port=3306, user='username',
                             passwd='password')
    cursor = dbconn.cursor()
    cursor.execute("""
    SELECT name, salary FROM employees
    WHERE salary > %s""", (limit,))

    print T.h1["Results"]
    print "<TABLE BORDER=1>"

    for row in cursor.fetchall():
        print T.tr[ [T.td(cell) for cell in row] ]

    print "</TABLE>\n";
    cursor.close()
    dbconn.close()

print '</body></html>'
#-----------------------------

# @@PLEAC@@_19.8
#-----------------------------
url = "http://python.org/pypi"
print "Location: %s\n" % url
raise SystemExit
#-----------------------------
# oreobounce - set a cookie and redirect the browser
import Cookie
import time

c = Cookie.SimpleCookie()
c['filling'] = 'vanilla cr?me'
now = time.time()
future = now + 3*(60*60*24*30) # 3 months
expire_date = time.strftime('%a %d %b %Y %H:%M:%S GMT', future)
c['filling']['expires'] = expire_date
c['filling']['domain'] = '.python.org'

whither  = "http://somewhere.python.org/nonesuch.html"

# Prints the cookie header
print 'Status: 302 Moved Temporarily'
print c
print 'Location:', whither
print

#-----------------------------
#Status: 302 Moved Temporarily
#Set-Cookie: filling=vanilla%20cr%E4me; domain=.perl.com;
#    expires=Tue, 21-Jul-1998 11:58:55 GMT
#Location: http://somewhere.perl.com/nonesuch.html
#-----------------------------
# os_snipe - redirect to a Jargon File entry about current OS
import os, re
dir = 'http://www.wins.uva.nl/%7Emes/jargon'
matches = [
    (r'Mac', 'm/Macintrash.html'),
    (r'Win(dows )?NT', 'e/evilandrude.html'),
    (r'Win|MSIE|WebTV', 'm/MicroslothWindows.html'),
    (r'Linux', 'l/Linux.html'),
    (r'HP-UX', 'h/HP-SUX.html'),
    (r'SunOS', 's/ScumOS.html'),
    (None, 'a/AppendixB.html'),
    ]

for regex, page in matches:
    if not regex: # default
        break
    if re.search(regex, os.environ['HTTP_USER_AGENT']):
        break
print 'Location: %s/%s\n' % (dir, page)
#-----------------------------
# There's no special way to print headers
print 'Status: 204 No response'
print
#-----------------------------
#Status: 204 No response
#-----------------------------

# @@PLEAC@@_19.9
# download the following standalone program
#!/usr/bin/python
# dummyhttpd - start a HTTP daemon and print what the client sends

import SocketServer
# or use BaseHTTPServer, SimpleHTTPServer, CGIHTTPServer

def adr_str(adr):
    return "%s:%d" % adr

class RequestHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        print "client access from %s" % adr_str(self.client_address)
        print self.request.recv(10000)
        self.request.send("Content-Type: text/plain\n"
                          "Server: dymmyhttpd/1.0.0\n"
                          "\n...\n")
        self.request.close()


adr = ('127.0.0.1', 8001)
print "Please contact me at <http://%s>" % adr_str(adr)
server = SocketServer.TCPServer(adr, RequestHandler)
server.serve_forever()
server.server_close()


# @@PLEAC@@_19.10

import Cookie
cookies = Cookie.SimpleCookie()
# SimpleCookie is more secure, but does not support all characters.
cookies["preference-name"] = "whatever you'd like" 
print cookies

# download the following standalone program
#!/usr/bin/python
# ic_cookies - sample CGI script that uses a cookie

import cgi
import os
import Cookie
import datetime

cookname = "favorite-ice-cream"  # SimpleCookie does not support blanks
fieldname = "flavor"

cookies = Cookie.SimpleCookie(os.environ.get("HTTP_COOKIE",""))
if cookies.has_key(cookname):
    favorite = cookies[cookname].value
else:
    favorite = "mint"

form = cgi.FieldStorage()
if not form.has_key(fieldname):
    print "Content-Type: text/html"
    print "\n"
    print "<html><body>"
    print "<h1>Hello Ice Cream</h1>"
    print "<form>"
    print 'Please select a flavor: <input type="text" name="%s" value="%s" />' % (
            fieldname, favorite )
    print "</form>"
    print "<hr />"
    print "</body></html>"
else:
    favorite = form[fieldname].value
    cookies[cookname] = favorite
    expire = datetime.datetime.now() + datetime.timedelta(730)
    cookies[cookname]["expires"] = expire.strftime("%a, %d %b %Y %H:00:00 GMT")
    cookies[cookname]["path"] = "/"
    print "Content-Type: text/html"
    print cookies
    print "\n"
    print "<html><body>"
    print "<h1>Hello Ice Cream</h1>"
    print "<p>You chose as your favorite flavor \"%s\"</p>" % favorite
    print "</body></html>"


# @@PLEAC@@_19.11
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_19.12
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_19.13
#-----------------------------
# first open and exclusively lock the file
import os, cgi, fcntl, cPickle
fh = open('/tmp/formlog', 'ab')
fcntl.flock(fh.fileno(), fcntl.LOCK_EX)

form = cgi.FieldStorage()
# This doesn't produce a readable file; we copy the environment so
# that we save a plain dictionary (os.environ is a dictionary-like
# object).
cPickle.dump((form, os.environ.copy()) fh)
fh.close()
#-----------------------------
import cgi, smtplib, sys

form = cgi.FieldStorage()
email = """\
From: %S
To: hisname@hishost.com
Subject: mailed form submission

""" % sys.argv[0]

for key in form:
    values = form[key]
    if not isinstance(values, list):
        value = [values.value]
    else:
        value = [v.value for v in values]
    for item in values:
        email += '\n%s: %s' % (key, value)

server = smtplib.SMTP('localhost')
server.sendmail(sys.argv[0], ['hisname@hishost.com'], email)
server.quit()
#-----------------------------
# @@INCOMPLETE@@ I don't get the point of these:
# param("_timestamp", scalar localtime);
# param("_environs", %ENV);
#-----------------------------
import fcntl, cPickle
fh = open('/tmp/formlog', 'rb')
fcntl.flock(fh.fileno(), fcntl.LOCK_SH)

count = 0
while True:
    try:
        form, environ = cPickle.load(fh)
    except EOFError:
        break
    if environ.get('REMOTE_HOST').endswith('perl.com'):
        continue
    if 'items requested' in form:
        count += int(form['items requested'].value)
print 'Total orders:', count
#-----------------------------

# @@PLEAC@@_19.14
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_20.1
#-----------------------------
import urllib
content = urllib.urlopen(url).read()

try:
    import urllib
    content = urllib.urlopen(url).read()
except IOError:
    print "could not get %s" % url

#-----------------------------
# download the following standalone program
#!/usr/bin/python
# titlebytes - find the title and size of documents
#
# differences to perl
# 
# * no URI::Heuristics
# * perl LWP supports fetching files from local system
# * fetching a title from ftp or file doesnt work in perl either.

import sys, urllib2, HTMLParser
if len(sys.argv)<=1:
    print "usage: %s url" % sys.argv[0]
    sys.exit(1)
raw_url = sys.argv[1] 

# python has no equivalent to pearls URI::Heuristics, which
# would do some guessing like :
#
#   perl            -> http://www.perl.com
#   www.oreilly.com -> http://www.oreilly.com
#   ftp.funet.fi    -> ftp://ftp.funet.fi
#   /etc/passwd     -> file:/etc/passwd

# simple but pedantic html parser: tpj.com breaks it.
class html(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self._data = {}
        self._open_tags = []
    def handle_starttag(self, tag, attrs):
        self._open_tags.append(tag)
    def handle_endtag(self, tag):
        if len(self._open_tags)>0:
            self._open_tags.pop()
    def handle_data(self, data):
        if len(self._open_tags)>0:
            self._data[self._open_tags[-1]] = data
    def __getattr__(self,attr):
        if not self._data.has_key(attr):
            return ""
        return self._data[attr]

url = raw_url
print "%s =>\n\t" % url,
# TODO fake user agent "Schmozilla/v9.17 Platinum"
# TODO referer "http://wizard.yellowbrick.oz"
# as we only do http httplib would do also
try:
        response = urllib2.urlopen(url)
except:
        print " %s" % sys.exc_info()[1].reason[1]
        sys.exit(1)
# title is not in response
data = response.read()
parser = html()
parser.feed(data)
parser.close()  # force processing all data
count = len(data.split("\n"))
bytes = len(data)
print "%s (%d lines, %d bytes)" % (parser.title, 
        count, 
        bytes)

# omly bytes is in response.info()


# @@PLEAC@@_20.2

# GET method
import httplib
conn = httplib.HTTPConnection('www.perl.com')
conn.request('GET','/cgi-bin/cpan_mod?module=DB_File&readme=1')
r1 = conn.getresponse()
content = r1.read()

# POST method
import urllib
params = urllib.urlencode({'module': 'DB_File', 'readme': 1})
content = urllib.urlopen('http://www.perl.com', params).read()

# fields must be properly escaped
# script.cgi?field1?arg=%22this%20isn%27t%20%3CEASY%3E%22

# proxies can be taken from environment, or specified
# as the optional thrid parameter to urlopen.

# @@PLEAC@@_20.3
# download the following standalone program
#!/usr/bin/python
# xurl - extract unique, sorted list of links from URL

from HTMLParser import HTMLParser
import urllib
from sets import Set as set # not needed in 2.4
class myParser(HTMLParser):
    def __init__(self, url):
        self.baseUrl = url[:url.rfind('/')]
        HTMLParser.__init__(self)
    def reset(self):
        self.urls = set()
        HTMLParser.reset(self)
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            if attrs[0][0] == 'href':
                if attrs[0][1].find(':') == -1:
                    # we need to add the base URL.
                    self.urls.add(self.baseUrl + '/' + attrs[0][1])
                else:
                    self.urls.add(attrs[0][1])
url = 'http://www.perl.com/CPAN'
p = myParser(url)
s = urllib.urlopen(url)
data = s.read()
p.feed(data)
urllist = p.urls._data.keys()
urllist.sort()
print '\n'.join(urllist)



# @@PLEAC@@_20.4
# Converting ASCII to HTML

# download the following standalone program
#!/usr/bin/python
# text2html - trivial html encoding of normal text

import sys
import re

# precompile regular expressions
re_quoted = re.compile(r"(?m)^(>.*?)$")
re_url = re.compile(r"<URL:(.*)>")
re_http = re.compile(r"(http:\S+)")
re_strong = re.compile(r"\*(\S+)\*")
re_em = re.compile(r"\b_(\S+)_\b")

# split paragraphs
for para in open(sys.argv[1]).read().split("\n\n"):
    # TODO encode entities: dont encode "<>" but do "&"
    if para.startswith(" "):
        print "<pre>\n%s\n</pre>" % para
    else:
        para = re_quoted.sub(r"\1<br />", para)          # quoted text
        para = re_url.sub(r'<a href="\1">\1</a>', para)  # embedded URL
        para = re_http.sub(r'<a href="\1">\1</a>', para) # guessed URL
        para = re_strong.sub(r"<strong>\1</strong>",para)   # this is *bold* here
        para = re_em.sub(r"<em>\1</em>",para)            # this is _italic_ here
        print "<p>\n%s\n</p>" % para                     # add paragraph tags



#-----------------------------
import sys, re
import htmlentitydefs

def encode_entities(s):
    for k,v in htmlentitydefs.codepoint2name.items():
        if k<256: # no unicodes
            s = s.replace(chr(k),"&%s;"%v)
    return s

print "<table>"
text = sys.stdin.read()
text = encode_entities(text)
text = re.sub(r"(\n[ \t]+)"," . ",text)   # continuation lines
text = re.sub(r"(?m)^(\S+?:)\s*(.*?)$",
              r'<tr><th align="left">\1</th><td>\2</td></tr>',
                            text);
print text    
print "</table>"
                            
# @@PLEAC@@_20.5
# Converting HTML to ASCII

#-----------------------------
import os
ascii = os.popen("lynx -dump " + filename).read()

#-----------------------------
import formatter
import htmllib

w = formatter.DumbWriter()
f = formatter.AbstractFormatter(w)
p = htmllib.HTMLParser(f)
p.feed(html)
p.close()

# Above is a bare minimum to use writer/formatter/parser
# framework of Python.

# Search Python Cookbook for more details, like writing
# your own writers or formatters.

# Recipe #52297 has TtyFormatter, formatting underline
# and bold in Terminal. Recipe #135005 has a writer
# accumulating text instead of printing.

# @@PLEAC@@_20.6

import re

plain_text = re.sub(r"<[^>]*>","",html_text) #WRONG

# using HTMLParser
import sys, HTMLParser

class html(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self._plaintext = ""
        self._ignore = False
    def handle_starttag(self, tag, attrs):
        if tag == "script":
            self._ignore = True
    def handle_endtag(self, tag):
        if tag == "script":
            self._ignore = False
    def handle_data(self, data):
        if len(data)>0 and not self._ignore:
            self._plaintext += data
    def get_plaintext(self):
        return self._plaintext
    def error(self,msg):
        # ignore all errors
        pass

html_text = open(sys.argv[1]).read()

parser = html()
parser.feed(html_text)
parser.close()  # force processing all data
print parser.get_plaintext()

title_s = re.search(r"(?i)<title>\s*(.*?)\s*</title>", text)
title = title_s and title_s.groups()[0] or "NO TITLE"

# download the following standalone program
#!/usr/bin/python
# htitlebytes - get html title from URL
#

import sys, urllib2, HTMLParser
if len(sys.argv)<=1:
    print "usage: %s url ..." % sys.argv[0]
    sys.exit(1)

# simple but pedantic html parser: tpj.com breaks it.
class html(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self._data = {}
        self._open_tags = []
    def handle_starttag(self, tag, attrs):
        self._open_tags.append(tag)
    def handle_endtag(self, tag):
        if len(self._open_tags)>0:
            self._open_tags.pop()
    def handle_data(self, data):
        if len(self._open_tags)>0:
            self._data[self._open_tags[-1]] = data
    def __getattr__(self,attr):
        if not self._data.has_key(attr):
            return ""
        return self._data[attr]
    def error(self,msg):
        # ignore all errors
        pass

for url in sys.argv[1:]:
    print "%s: " % url,
    # TODO fake user agent "Schmozilla/v9.17 Platinum"
    # TODO referer "http://wizard.yellowbrick.oz"
    # as we only do http httplib would do also
    try:
        response = urllib2.urlopen(url)
    except:
        print " %s" % sys.exc_info()[1]
        sys.exit(1)
    # title is not in response
    parser = html()
    parser.feed(response.read())
    parser.close()  # force processing all data
    print parser.title 



# @@PLEAC@@_20.7
# download the following standalone program
#!/usr/bin/python
# churl - check urls

import sys

# head request
import urllib
def valid(url):
    try:
        conn = urllib.urlopen(url)
        return 1
    except:
        return 0

# parser class as in xurl
from HTMLParser import HTMLParser
from sets import Set as set # not needed in 2.4
class myParser(HTMLParser):
    def __init__(self, url):
        self.baseUrl = url[:url.rfind('/')]
        HTMLParser.__init__(self)
    def reset(self):
        self.urls = set()
        HTMLParser.reset(self)
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            if attrs[0][0] == 'href':
                if attrs[0][1].find(':') == -1:
                    # we need to add the base URL.
                    self.urls.add(self.baseUrl + '/' + attrs[0][1])
                else:
                    self.urls.add(attrs[0][1])

if len(sys.argv)<=1:
    print "usage: %s <start_url>" % (sys.argv[0])
    sys.exit(1)
    
base_url = sys.argv[1]
print base_url+":"
p = myParser(base_url)
s = urllib.urlopen(base_url)
data = s.read()
p.feed(data)
for link in p.urls._data.keys():
    state = "UNKNOWN URL"
    if link.startswith("http:"):
        state = "BAD"
        if valid(link):
            state = "OK"
    print "  %s: %s" % (link, state)



# @@PLEAC@@_20.8
# download the following standalone program
#!/usr/bin/python
# surl - sort URLs by their last modification date

import urllib
import time
import sys

Date = {}
while 1:
    # we only read from stdin not from argv.
    ln = sys.stdin.readline()
    if not ln:
        break
    ln = ln.strip()
    try:
        u = urllib.urlopen(ln)
        date = time.mktime(u.info().getdate("date"))
        if not Date.has_key(date):
            Date[date] = []
        Date[date].append(ln)
    except:
        sys.stderr.write("%s: %s!\n" % (ln, sys.exc_info()[1]))

dates = Date.keys()
dates.sort()    # python 2.4 would have sorted
for d in dates:
    print "%s  %s" % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(d)),
                    ", ".join(Date[d]))


# @@PLEAC@@_20.9
import re

def template(filename, fillings):
    text = open(filename).read()
    def repl(matchobj):
        if fillings.has_key(matchobj.group(1)):
            return str(fillings[matchobj.group(1)])
        return ""
    # replace quoted words with value from fillings dictionary
    text = re.sub("%%(.+?)%%", repl, text)
    return text

fields = { "username":"peter", "count":"23", "total": "1234"}
print template("/home/httpd/templates/simple.template", fields)

# download the following standalone program
#!/usr/bin/python
# userrep1 - report duration of user logins using SQL database

import MySQLdb
import cgi
import re
import sys

def template(filename, fillings):
    text = open(filename).read()
    def repl(matchobj):
        if fillings.has_key(matchobj.group(1)):
            return str(fillings[matchobj.group(1)])
        return ""
    # replace quoted words with value from fillings dictionary
    text = re.sub("%%(.+?)%%", repl, text)
    return text

fields = cgi.FieldStorage()
if not fields.has_key("user"):
    print "Content-Type: text/plain\n"
    print "No username"
    sys.exit(1)

def get_userdata(username):
    db = MySQLdb.connect(passwd="",db="connections", user="bert")
    db.query("select count(duration) as count,"
            +" sum(duration) as total from logins"
            +" where username='%s'" % username)
    res = db.store_result().fetch_row(maxrows=1,how=1)
    res[0]["username"] = username
    db.close()
    return res[0]
                        
print "Content-Type: text/html\n"

print template("report.tpl", get_userdata(fields["user"].value))

# @@INCOMPLETE@@

# @@PLEAC@@_20.10
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_20.11
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_20.12

# sample data, use ``LOGFILE = open(sys.argv[1])`` in real life
LOGFILE = [
        '127.0.0.1 - - [04/Sep/2005:20:50:31 +0200] "GET /bus HTTP/1.1" 301 303\n',
        '127.0.0.1 - - [04/Sep/2005:20:50:31 +0200] "GET /bus HTTP/1.1" 301 303 "-" "Opera/8.02 (X11; Linux i686; U; en)"\n',
        '192.168.0.1 - - [04/Sep/2005:20:50:36 +0200] "GET /bus/libjs/layersmenu-library.js HTTP/1.1" 200 6228\n',
        '192.168.0.1 - - [04/Sep/2005:20:50:36 +0200] "GET /bus/libjs/layersmenu-library.js HTTP/1.1" 200 6228 "http://localhost/bus/" "Opera/8.02 (X11; Linux i686; U; en)"\n',
    ]

import re

# similar too perl version.
web_server_log_re = re.compile(r'^(\S+) (\S+) (\S+) \[([^:]+):(\d+:\d+:\d+) ([^\]]+)\] "(\S+) (.*?) (\S+)" (\S+) (\S+)$')
    
# with group naming.
split_re = re.compile(r'''(?x)         # allow nicer formatting (but requires escaping blanks)
                       ^(?P<client>\S+)\s
                       (?P<identuser>\S+)\s
                       (?P<authuser>\S+)\s
                       \[
                         (?P<date>[^:]+):
                         (?P<time>[\d:]+)\s
                         (?P<tz>[^\]]+)
                       \]\s
                       "
                         (?P<method>\S+)\s
                         (?P<url>.*?)\s
                         (?P<protocol>\S+)
                       "\s
                       (?P<status>\S+)\s
                       (?P<bytes>\S+)
                       (?:
                         \s
                         "
                           (?P<referrer>[^"]+)
                         "\s
                         "
                           (?P<agent>[^"]+)
                         "
                       )?''')
for line in LOGFILE:
    f = split_re.match(line)
    if f:
        print "agent = %s" % f.groupdict()['agent']

# @@PLEAC@@_20.13
# @@INCOMPLETE@@
# @@INCOMPLETE@@

# @@PLEAC@@_20.14
# @@INCOMPLETE@@
# @@INCOMPLETE@@

