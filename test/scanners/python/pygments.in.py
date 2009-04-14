#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Generate Pygments Documentation
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Generates a bunch of html files containing the documentation.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import sys
from datetime import datetime
from cgi import escape

from docutils import nodes
from docutils.parsers.rst import directives
from docutils.core import publish_parts
from docutils.writers import html4css1

from jinja import from_string

from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter


LEXERDOC = '''
`%s`
%s
    :Short names: %s
    :Filename patterns: %s
    :Mimetypes: %s

'''

def generate_lexer_docs():
    from pygments.lexers import LEXERS

    out = []

    modules = {}
    moduledocstrings = {}
    for classname, data in sorted(LEXERS.iteritems(), key=lambda x: x[0]):
        module = data[0]
        mod = __import__(module, None, None, [classname])
        cls = getattr(mod, classname)
        if not cls.__doc__:
            print "Warning: %s does not have a docstring." % classname
        modules.setdefault(module, []).append((
            classname,
            cls.__doc__,
            ', '.join(data[2]) or 'None',
            ', '.join(data[3]).replace('*', '\\*') or 'None',
            ', '.join(data[4]) or 'None'))
        if module not in moduledocstrings:
            moduledocstrings[module] = mod.__doc__

    for module, lexers in sorted(modules.iteritems(), key=lambda x: x[0]):
        heading = moduledocstrings[module].splitlines()[4].strip().rstrip('.')
        out.append('\n' + heading + '\n' + '-'*len(heading) + '\n')
        for data in lexers:
            out.append(LEXERDOC % data)
    return ''.join(out)

def generate_formatter_docs():
    from pygments.formatters import FORMATTERS

    out = []
    for cls, data in sorted(FORMATTERS.iteritems(),
                            key=lambda x: x[0].__name__):
        heading = cls.__name__
        out.append('`' + heading + '`\n' + '-'*(2+len(heading)) + '\n')
        out.append(cls.__doc__)
        out.append('''
    :Short names: %s
    :Filename patterns: %s


''' % (', '.join(data[1]) or 'None', ', '.join(data[2]).replace('*', '\\*') or 'None'))
    return ''.join(out)

def generate_filter_docs():
    from pygments.filters import FILTERS

    out = []
    for name, cls in FILTERS.iteritems():
        out.append('''
`%s`
%s
    :Name: %s
''' % (cls.__name__, cls.__doc__, name))
    return ''.join(out)

def generate_changelog():
    fn = os.path.abspath(os.path.join(os.path.dirname(__file__), '..',
                         'CHANGES'))
    f = file(fn)
    result = []
    in_header = False
    header = True
    for line in f:
        if header:
            if not in_header and line.strip():
                in_header = True
            elif in_header and not line.strip():
                header = False
        else:
            result.append(line.rstrip())
    f.close()
    return '\n'.join(result)

def generate_authors():
    fn = os.path.abspath(os.path.join(os.path.dirname(__file__), '..',
                         'AUTHORS'))
    f = file(fn)
    r = f.read().rstrip()
    f.close()
    return r

LEXERDOCS = generate_lexer_docs()
FORMATTERDOCS = generate_formatter_docs()
FILTERDOCS = generate_filter_docs()
CHANGELOG = generate_changelog()
AUTHORS = generate_authors()


PYGMENTS_FORMATTER = HtmlFormatter(style='pastie', cssclass='syntax')

USAGE = '''\
Usage: %s <mode> <destination> [<source.txt> ...]

Generate either python or html files out of the documentation.

Mode can either be python or html.\
''' % sys.argv[0]

TEMPLATE = '''\
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <title>{{ title }} &mdash; Pygments</title>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <style type="text/css">
    {{ style }}
  </style>
</head>
<body>
  <div id="content">
    <h1 class="heading">Pygments</h1>
    <h2 class="subheading">{{ title }}</h2>
    {% if file_id != "index" %}
      <a id="backlink" href="index.html">&laquo; Back To Index</a>
    {% endif %}
    {% if toc %}
      <div class="toc">
        <h2>Contents</h2>
        <ul class="contents">
        {% for key, value in toc %}
          <li><a href="{{ key }}">{{ value }}</a></li>
        {% endfor %}
        </ul>
      </div>
    {% endif %}
    {{ body }}
  </div>
</body>
<!-- generated on: {{ generation_date }}
     file id: {{ file_id }} -->
</html>\
'''

STYLESHEET = '''\
body {
    background-color: #f2f2f2;
    margin: 0;
    padding: 0;
    font-family: 'Georgia', serif;
    color: #111;
}

#content {
    background-color: white;
    padding: 20px;
    margin: 20px auto 20px auto;
    max-width: 800px;
    border: 4px solid #ddd;
}

h1 {
    font-weight: normal;
    font-size: 40px;
    color: #09839A;
}

h2 {
    font-weight: normal;
    font-size: 30px;
    color: #C73F00;
}

h1.heading {
    margin: 0 0 30px 0;
}

h2.subheading {
    margin: -30px 0 0 45px;
}

h3 {
    margin-top: 30px;
}

table.docutils {
    border-collapse: collapse;
    border: 2px solid #aaa;
    margin: 0.5em 1.5em 0.5em 1.5em;
}

table.docutils td {
    padding: 2px;
    border: 1px solid #ddd;
}

p, li, dd, dt, blockquote {
    font-size: 15px;
    color: #333;
}

p {
    line-height: 150%;
    margin-bottom: 0;
    margin-top: 10px;
}

hr {
    border-top: 1px solid #ccc;
    border-bottom: 0;
    border-right: 0;
    border-left: 0;
    margin-bottom: 10px;
    margin-top: 20px;
}

dl {
    margin-left: 10px;
}

li, dt {
    margin-top: 5px;
}

dt {
    font-weight: bold;
}

th {
    text-align: left;
}

a {
    color: #990000;
}

a:hover {
    color: #c73f00;
}

pre {
    background-color: #f9f9f9;
    border-top: 1px solid #ccc;
    border-bottom: 1px solid #ccc;
    padding: 5px;
    font-size: 13px;
    font-family: Bitstream Vera Sans Mono,monospace;
}

tt {
    font-size: 13px;
    font-family: Bitstream Vera Sans Mono,monospace;
    color: black;
    padding: 1px 2px 1px 2px;
    background-color: #f0f0f0;
}

cite {
    /* abusing <cite>, it's generated by ReST for `x` */
    font-size: 13px;
    font-family: Bitstream Vera Sans Mono,monospace;
    font-weight: bold;
    font-style: normal;
}

#backlink {
    float: right;
    font-size: 11px;
    color: #888;
}

div.toc {
    margin: 0 0 10px 0;
}

div.toc h2 {
    font-size: 20px;
}
''' #'


def pygments_directive(name, arguments, options, content, lineno,
                      content_offset, block_text, state, state_machine):
    try:
        lexer = get_lexer_by_name(arguments[0])
    except ValueError:
        # no lexer found
        lexer = get_lexer_by_name('text')
    parsed = highlight(u'\n'.join(content), lexer, PYGMENTS_FORMATTER)
    return [nodes.raw('', parsed, format="html")]
pygments_directive.arguments = (1, 0, 1)
pygments_directive.content = 1
directives.register_directive('sourcecode', pygments_directive)


def create_translator(link_style):
    class Translator(html4css1.HTMLTranslator):
        def visit_reference(self, node):
            refuri = node.get('refuri')
            if refuri is not None and '/' not in refuri and refuri.endswith('.txt'):
                node['refuri'] = link_style(refuri[:-4])
            html4css1.HTMLTranslator.visit_reference(self, node)
    return Translator


class DocumentationWriter(html4css1.Writer):

    def __init__(self, link_style):
        html4css1.Writer.__init__(self)
        self.translator_class = create_translator(link_style)

    def translate(self):
        html4css1.Writer.translate(self)
        # generate table of contents
        contents = self.build_contents(self.document)
        contents_doc = self.document.copy()
        contents_doc.children = contents
        contents_visitor = self.translator_class(contents_doc)
        contents_doc.walkabout(contents_visitor)
        self.parts['toc'] = self._generated_toc

    def build_contents(self, node, level=0):
        sections = []
        i = len(node) - 1
        while i >= 0 and isinstance(node[i], nodes.section):
            sections.append(node[i])
            i -= 1
        sections.reverse()
        toc = []
        for section in sections:
            try:
                reference = nodes.reference('', '', refid=section['ids'][0], *section[0])
            except IndexError:
                continue
            ref_id = reference['refid']
            text = escape(reference.astext().encode('utf-8'))
            toc.append((ref_id, text))

        self._generated_toc = [('#%s' % href, caption) for href, caption in toc]
        # no further processing
        return []


def generate_documentation(data, link_style):
    writer = DocumentationWriter(link_style)
    data = data.replace('[builtin_lexer_docs]', LEXERDOCS).\
                replace('[builtin_formatter_docs]', FORMATTERDOCS).\
                replace('[builtin_filter_docs]', FILTERDOCS).\
                replace('[changelog]', CHANGELOG).\
                replace('[authors]', AUTHORS)
    parts = publish_parts(
        data,
        writer=writer,
        settings_overrides={
            'initial_header_level': 3,
            'field_name_limit': 50,
        }
    )
    return {
        'title':        parts['title'].encode('utf-8'),
        'body':         parts['body'].encode('utf-8'),
        'toc':          parts['toc']
    }


def handle_python(filename, fp, dst):
    now = datetime.now()
    title = os.path.basename(filename)[:-4]
    content = fp.read()
    def urlize(href):
        # create links for the pygments webpage
        if href == 'index.txt':
            return '/docs/'
        else:
            return '/docs/%s/' % href
    parts = generate_documentation(content, urlize)
    result = file(os.path.join(dst, title + '.py'), 'w')
    result.write('# -*- coding: utf-8 -*-\n')
    result.write('"""\n    Pygments Documentation - %s\n' % title)
    result.write('    %s\n\n' % ('~' * (24 + len(title))))
    result.write('    Generated on: %s\n"""\n\n' % now)
    result.write('import datetime\n')
    result.write('DATE = %r\n' % now)
    result.write('TITLE = %r\n' % parts['title'])
    result.write('TOC = %r\n' % parts['toc'])
    result.write('BODY = %r\n' % parts['body'])
    result.close()


def handle_html(filename, fp, dst):
    now = datetime.now()
    title = os.path.basename(filename)[:-4]
    content = fp.read()
    c = generate_documentation(content, (lambda x: './%s.html' % x))
    result = file(os.path.join(dst, title + '.html'), 'w')
    c['style'] = STYLESHEET + PYGMENTS_FORMATTER.get_style_defs('.syntax')
    c['generation_date'] = now
    c['file_id'] = title
    t = from_string(TEMPLATE)
    result.write(t.render(c).encode('utf-8'))
    result.close()


def run(handle_file, dst, sources=()):
    path = os.path.abspath(os.path.join(os.path.dirname(__file__), 'src'))
    if not sources:
        sources = [os.path.join(path, fn) for fn in os.listdir(path)]
    for fn in sources:
        if not os.path.isfile(fn):
            continue
        print 'Processing %s' % fn
        f = open(fn)
        try:
            handle_file(fn, f, dst)
        finally:
            f.close()


def main(mode, dst='build/', *sources):
    try:
        handler = {
            'html':         handle_html,
            'python':       handle_python
        }[mode]
    except KeyError:
        print 'Error: unknown mode "%s"' % mode
        sys.exit(1)
    run(handler, os.path.realpath(dst), sources)


if __name__ == '__main__':
    if len(sys.argv) == 1:
        print USAGE
    else:
        main(*sys.argv[1:])
# -*- coding: utf-8 -*-
"""
    The Pygments Markdown Preprocessor
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    This fragment is a Markdown_ preprocessor that renders source code
    to HTML via Pygments.  To use it, invoke Markdown like so::

        from markdown import Markdown

        md = Markdown()
        md.textPreprocessors.insert(0, CodeBlockPreprocessor())
        html = md.convert(someText)

    markdown is then a callable that can be passed to the context of
    a template and used in that template, for example.

    This uses CSS classes by default, so use
    ``pygmentize -S <some style> -f html > pygments.css``
    to create a stylesheet to be added to the website.

    You can then highlight source code in your markdown markup::

        [sourcecode:lexer]
        some code
        [/sourcecode]

    .. _Markdown: http://www.freewisdom.org/projects/python-markdown/

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

# Options
# ~~~~~~~

# Set to True if you want inline CSS styles instead of classes
INLINESTYLES = False


import re

from markdown import TextPreprocessor

from pygments import highlight
from pygments.formatters import HtmlFormatter
from pygments.lexers import get_lexer_by_name, TextLexer


class CodeBlockPreprocessor(TextPreprocessor):

    pattern = re.compile(
        r'\[sourcecode:(.+?)\](.+?)\[/sourcecode\]', re.S)

    formatter = HtmlFormatter(noclasses=INLINESTYLES)

    def run(self, lines):
        def repl(m):
            try:
                lexer = get_lexer_by_name(m.group(1))
            except ValueError:
                lexer = TextLexer()
            code = highlight(m.group(2), lexer, self.formatter)
            code = code.replace('\n\n', '\n&nbsp;\n').replace('\n', '<br />')
            return '\n\n<div class="code">%s</div>\n\n' % code
        return self.pattern.sub(
            repl, lines)# -*- coding: utf-8 -*-
"""
    The Pygments MoinMoin Parser
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    This is a MoinMoin parser plugin that renders source code to HTML via
    Pygments; you need Pygments 0.7 or newer for this parser to work.

    To use it, set the options below to match your setup and put this file in
    the data/plugin/parser subdirectory of your Moin instance, and give it the
    name that the parser directive should have. For example, if you name the
    file ``code.py``, you can get a highlighted Python code sample with this
    Wiki markup::

        {{{
        #!code python
        [...]
        }}}

    Additionally, if you set ATTACHMENTS below to True, Pygments will also be
    called for all attachments for whose filenames there is no other parser
    registered.

    You are responsible for including CSS rules that will map the Pygments CSS
    classes to colors. You can output a stylesheet file with `pygmentize`, put
    it into the `htdocs` directory of your Moin instance and then include it in
    the `stylesheets` configuration option in the Moin config, e.g.::

        stylesheets = [('screen', '/htdocs/pygments.css')]

    If you do not want to do that and are willing to accept larger HTML
    output, you can set the INLINESTYLES option below to True.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

# Options
# ~~~~~~~

# Set to True if you want to highlight attachments, in addition to
# {{{ }}} blocks.
ATTACHMENTS = True

# Set to True if you want inline CSS styles instead of classes
INLINESTYLES = False


import sys

from pygments import highlight
from pygments.lexers import get_lexer_by_name, get_lexer_for_filename, TextLexer
from pygments.formatters import HtmlFormatter
from pygments.util import ClassNotFound


# wrap lines in <span>s so that the Moin-generated line numbers work
class MoinHtmlFormatter(HtmlFormatter):
    def wrap(self, source, outfile):
        for line in source:
            yield 1, '<span class="line">' + line[1] + '</span>'

htmlformatter = MoinHtmlFormatter(noclasses=INLINESTYLES)
textlexer = TextLexer()
codeid = [0]


class Parser:
    """
    MoinMoin Pygments parser.
    """
    if ATTACHMENTS:
        extensions = '*'
    else:
        extensions = []

    Dependencies = []

    def __init__(self, raw, request, **kw):
        self.raw = raw
        self.req = request
        if "format_args" in kw:
            # called from a {{{ }}} block
            try:
                self.lexer = get_lexer_by_name(kw['format_args'].strip())
            except ClassNotFound:
                self.lexer = textlexer
            return
        if "filename" in kw:
            # called for an attachment
            filename = kw['filename']
        else:
            # called for an attachment by an older moin
            # HACK: find out the filename by peeking into the execution
            #       frame which might not always work
            try:
                frame = sys._getframe(1)
                filename = frame.f_locals['filename']
            except:
                filename = 'x.txt'
        try:
            self.lexer = get_lexer_for_filename(filename)
        except ClassNotFound:
            self.lexer = textlexer

    def format(self, formatter):
        codeid[0] += 1
        id = "pygments_%s" % codeid[0]
        w = self.req.write
        w(formatter.code_area(1, id, start=1, step=1))
        w(formatter.rawHTML(highlight(self.raw, self.lexer, htmlformatter)))
        w(formatter.code_area(0, id))
# -*- coding: utf-8 -*-
"""
    The Pygments reStructuredText directive
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    This fragment is a Docutils_ 0.4 directive that renders source code
    (to HTML only, currently) via Pygments.

    To use it, adjust the options below and copy the code into a module
    that you import on initialization.  The code then automatically
    registers a ``sourcecode`` directive that you can use instead of
    normal code blocks like this::

        .. sourcecode:: python

            My code goes here.

    If you want to have different code styles, e.g. one with line numbers
    and one without, add formatters with their names in the VARIANTS dict
    below.  You can invoke them instead of the DEFAULT one by using a
    directive option::

        .. sourcecode:: python
            :linenos:

            My code goes here.

    Look at the `directive documentation`_ to get all the gory details.

    .. _Docutils: http://docutils.sf.net/
    .. _directive documentation:
       http://docutils.sourceforge.net/docs/howto/rst-directives.html

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

# Options
# ~~~~~~~

# Set to True if you want inline CSS styles instead of classes
INLINESTYLES = False

from pygments.formatters import HtmlFormatter

# The default formatter
DEFAULT = HtmlFormatter(noclasses=INLINESTYLES)

# Add name -> formatter pairs for every variant you want to use
VARIANTS = {
    # 'linenos': HtmlFormatter(noclasses=INLINESTYLES, linenos=True),
}


from docutils import nodes
from docutils.parsers.rst import directives

from pygments import highlight
from pygments.lexers import get_lexer_by_name, TextLexer

def pygments_directive(name, arguments, options, content, lineno,
                       content_offset, block_text, state, state_machine):
    try:
        lexer = get_lexer_by_name(arguments[0])
    except ValueError:
        # no lexer found - use the text one instead of an exception
        lexer = TextLexer()
    # take an arbitrary option if more than one is given
    formatter = options and VARIANTS[options.keys()[0]] or DEFAULT
    parsed = highlight(u'\n'.join(content), lexer, formatter)
    return [nodes.raw('', parsed, format='html')]

pygments_directive.arguments = (1, 0, 1)
pygments_directive.content = 1
pygments_directive.options = dict([(key, directives.flag) for key in VARIANTS])

directives.register_directive('sourcecode', pygments_directive)
#!python
"""Bootstrap setuptools installation

If you want to use setuptools in your package's setup.py, just include this
file in the same directory with it, and add this to the top of your setup.py::

    from ez_setup import use_setuptools
    use_setuptools()

If you want to require a specific version of setuptools, set a download
mirror, or use an alternate download directory, you can do so by supplying
the appropriate options to ``use_setuptools()``.

This file can also be run as a script to install or upgrade setuptools.
"""
import sys
DEFAULT_VERSION = "0.6c9"
DEFAULT_URL     = "http://pypi.python.org/packages/%s/s/setuptools/" % sys.version[:3]

md5_data = {
    'setuptools-0.6b1-py2.3.egg': '8822caf901250d848b996b7f25c6e6ca',
    'setuptools-0.6b1-py2.4.egg': 'b79a8a403e4502fbb85ee3f1941735cb',
    'setuptools-0.6b2-py2.3.egg': '5657759d8a6d8fc44070a9d07272d99b',
    'setuptools-0.6b2-py2.4.egg': '4996a8d169d2be661fa32a6e52e4f82a',
    'setuptools-0.6b3-py2.3.egg': 'bb31c0fc7399a63579975cad9f5a0618',
    'setuptools-0.6b3-py2.4.egg': '38a8c6b3d6ecd22247f179f7da669fac',
    'setuptools-0.6b4-py2.3.egg': '62045a24ed4e1ebc77fe039aa4e6f7e5',
    'setuptools-0.6b4-py2.4.egg': '4cb2a185d228dacffb2d17f103b3b1c4',
    'setuptools-0.6c1-py2.3.egg': 'b3f2b5539d65cb7f74ad79127f1a908c',
    'setuptools-0.6c1-py2.4.egg': 'b45adeda0667d2d2ffe14009364f2a4b',
    'setuptools-0.6c2-py2.3.egg': 'f0064bf6aa2b7d0f3ba0b43f20817c27',
    'setuptools-0.6c2-py2.4.egg': '616192eec35f47e8ea16cd6a122b7277',
    'setuptools-0.6c3-py2.3.egg': 'f181fa125dfe85a259c9cd6f1d7b78fa',
    'setuptools-0.6c3-py2.4.egg': 'e0ed74682c998bfb73bf803a50e7b71e',
    'setuptools-0.6c3-py2.5.egg': 'abef16fdd61955514841c7c6bd98965e',
    'setuptools-0.6c4-py2.3.egg': 'b0b9131acab32022bfac7f44c5d7971f',
    'setuptools-0.6c4-py2.4.egg': '2a1f9656d4fbf3c97bf946c0a124e6e2',
    'setuptools-0.6c4-py2.5.egg': '8f5a052e32cdb9c72bcf4b5526f28afc',
    'setuptools-0.6c5-py2.3.egg': 'ee9fd80965da04f2f3e6b3576e9d8167',
    'setuptools-0.6c5-py2.4.egg': 'afe2adf1c01701ee841761f5bcd8aa64',
    'setuptools-0.6c5-py2.5.egg': 'a8d3f61494ccaa8714dfed37bccd3d5d',
    'setuptools-0.6c6-py2.3.egg': '35686b78116a668847237b69d549ec20',
    'setuptools-0.6c6-py2.4.egg': '3c56af57be3225019260a644430065ab',
    'setuptools-0.6c6-py2.5.egg': 'b2f8a7520709a5b34f80946de5f02f53',
    'setuptools-0.6c7-py2.3.egg': '209fdf9adc3a615e5115b725658e13e2',
    'setuptools-0.6c7-py2.4.egg': '5a8f954807d46a0fb67cf1f26c55a82e',
    'setuptools-0.6c7-py2.5.egg': '45d2ad28f9750e7434111fde831e8372',
    'setuptools-0.6c8-py2.3.egg': '50759d29b349db8cfd807ba8303f1902',
    'setuptools-0.6c8-py2.4.egg': 'cba38d74f7d483c06e9daa6070cce6de',
    'setuptools-0.6c8-py2.5.egg': '1721747ee329dc150590a58b3e1ac95b',
    'setuptools-0.6c9-py2.3.egg': 'a83c4020414807b496e4cfbe08507c03',
    'setuptools-0.6c9-py2.4.egg': '260a2be2e5388d66bdaee06abec6342a',
    'setuptools-0.6c9-py2.5.egg': 'fe67c3e5a17b12c0e7c541b7ea43a8e6',
    'setuptools-0.6c9-py2.6.egg': 'ca37b1ff16fa2ede6e19383e7b59245a',
}

import sys, os
try: from hashlib import md5
except ImportError: from md5 import md5

def _validate_md5(egg_name, data):
    if egg_name in md5_data:
        digest = md5(data).hexdigest()
        if digest != md5_data[egg_name]:
            print >>sys.stderr, (
                "md5 validation of %s failed!  (Possible download problem?)"
                % egg_name
            )
            sys.exit(2)
    return data

def use_setuptools(
    version=DEFAULT_VERSION, download_base=DEFAULT_URL, to_dir=os.curdir,
    download_delay=15
):
    """Automatically find/download setuptools and make it available on sys.path

    `version` should be a valid setuptools version number that is available
    as an egg for download under the `download_base` URL (which should end with
    a '/').  `to_dir` is the directory where setuptools will be downloaded, if
    it is not already available.  If `download_delay` is specified, it should
    be the number of seconds that will be paused before initiating a download,
    should one be required.  If an older version of setuptools is installed,
    this routine will print a message to ``sys.stderr`` and raise SystemExit in
    an attempt to abort the calling script.
    """
    was_imported = 'pkg_resources' in sys.modules or 'setuptools' in sys.modules
    def do_download():
        egg = download_setuptools(version, download_base, to_dir, download_delay)
        sys.path.insert(0, egg)
        import setuptools; setuptools.bootstrap_install_from = egg
    try:
        import pkg_resources
    except ImportError:
        return do_download()       
    try:
        pkg_resources.require("setuptools>="+version); return
    except pkg_resources.VersionConflict, e:
        if was_imported:
            print >>sys.stderr, (
            "The required version of setuptools (>=%s) is not available, and\n"
            "can't be installed while this script is running. Please install\n"
            " a more recent version first, using 'easy_install -U setuptools'."
            "\n\n(Currently using %r)"
            ) % (version, e.args[0])
            sys.exit(2)
        else:
            del pkg_resources, sys.modules['pkg_resources']    # reload ok
            return do_download()
    except pkg_resources.DistributionNotFound:
        return do_download()

def download_setuptools(
    version=DEFAULT_VERSION, download_base=DEFAULT_URL, to_dir=os.curdir,
    delay = 15
):
    """Download setuptools from a specified location and return its filename

    `version` should be a valid setuptools version number that is available
    as an egg for download under the `download_base` URL (which should end
    with a '/'). `to_dir` is the directory where the egg will be downloaded.
    `delay` is the number of seconds to pause before an actual download attempt.
    """
    import urllib2, shutil
    egg_name = "setuptools-%s-py%s.egg" % (version,sys.version[:3])
    url = download_base + egg_name
    saveto = os.path.join(to_dir, egg_name)
    src = dst = None
    if not os.path.exists(saveto):  # Avoid repeated downloads
        try:
            from distutils import log
            if delay:
                log.warn("""
---------------------------------------------------------------------------
This script requires setuptools version %s to run (even to display
help).  I will attempt to download it for you (from
%s), but
you may need to enable firewall access for this script first.
I will start the download in %d seconds.

(Note: if this machine does not have network access, please obtain the file

   %s

and place it in this directory before rerunning this script.)
---------------------------------------------------------------------------""",
                    version, download_base, delay, url
                ); from time import sleep; sleep(delay)
            log.warn("Downloading %s", url)
            src = urllib2.urlopen(url)
            # Read/write all in one block, so we don't create a corrupt file
            # if the download is interrupted.
            data = _validate_md5(egg_name, src.read())
            dst = open(saveto,"wb"); dst.write(data)
        finally:
            if src: src.close()
            if dst: dst.close()
    return os.path.realpath(saveto)




































def main(argv, version=DEFAULT_VERSION):
    """Install or upgrade setuptools and EasyInstall"""
    try:
        import setuptools
    except ImportError:
        egg = None
        try:
            egg = download_setuptools(version, delay=0)
            sys.path.insert(0,egg)
            from setuptools.command.easy_install import main
            return main(list(argv)+[egg])   # we're done here
        finally:
            if egg and os.path.exists(egg):
                os.unlink(egg)
    else:
        if setuptools.__version__ == '0.0.1':
            print >>sys.stderr, (
            "You have an obsolete version of setuptools installed.  Please\n"
            "remove it from your system entirely before rerunning this script."
            )
            sys.exit(2)

    req = "setuptools>="+version
    import pkg_resources
    try:
        pkg_resources.require(req)
    except pkg_resources.VersionConflict:
        try:
            from setuptools.command.easy_install import main
        except ImportError:
            from easy_install import main
        main(list(argv)+[download_setuptools(delay=0)])
        sys.exit(0) # try to force an exit
    else:
        if argv:
            from setuptools.command.easy_install import main
            main(argv)
        else:
            print "Setuptools version",version,"or greater has been installed."
            print '(Run "ez_setup.py -U setuptools" to reinstall or upgrade.)'

def update_md5(filenames):
    """Update our built-in md5 registry"""

    import re

    for name in filenames:
        base = os.path.basename(name)
        f = open(name,'rb')
        md5_data[base] = md5(f.read()).hexdigest()
        f.close()

    data = ["    %r: %r,\n" % it for it in md5_data.items()]
    data.sort()
    repl = "".join(data)

    import inspect
    srcfile = inspect.getsourcefile(sys.modules[__name__])
    f = open(srcfile, 'rb'); src = f.read(); f.close()

    match = re.search("\nmd5_data = {\n([^}]+)}", src)
    if not match:
        print >>sys.stderr, "Internal error!"
        sys.exit(2)

    src = src[:match.start(1)] + repl + src[match.end(1):]
    f = open(srcfile,'w')
    f.write(src)
    f.close()


if __name__=='__main__':
    if len(sys.argv)>2 and sys.argv[1]=='--md5update':
        update_md5(sys.argv[2:])
    else:
        main(sys.argv[1:])






# -*- coding: utf-8 -*-
"""
    Pygments
    ~~~~~~~~

    Pygments is a syntax highlighting package written in Python.

    It is a generic syntax highlighter for general use in all kinds of software
    such as forum systems, wikis or other applications that need to prettify
    source code. Highlights are:

    * a wide range of common languages and markup formats is supported
    * special attention is paid to details, increasing quality by a fair amount
    * support for new languages and formats are added easily
    * a number of output formats, presently HTML, LaTeX, RTF, SVG and ANSI sequences
    * it is usable as a command-line tool and as a library
    * ... and it highlights even Brainfuck!

    The `Pygments tip`_ is installable with ``easy_install Pygments==dev``.

    .. _Pygments tip: http://dev.pocoo.org/hg/pygments-main/archive/tip.tar.gz#egg=Pygments-dev

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

__version__ = '1.1'
__docformat__ = 'restructuredtext'

__all__ = ['lex', 'format', 'highlight']


import sys, os

from pygments.util import StringIO, BytesIO


def lex(code, lexer):
    """
    Lex ``code`` with ``lexer`` and return an iterable of tokens.
    """
    try:
        return lexer.get_tokens(code)
    except TypeError, err:
        if isinstance(err.args[0], str) and \
           'unbound method get_tokens' in err.args[0]:
            raise TypeError('lex() argument must be a lexer instance, '
                            'not a class')
        raise


def format(tokens, formatter, outfile=None):
    """
    Format a tokenlist ``tokens`` with the formatter ``formatter``.

    If ``outfile`` is given and a valid file object (an object
    with a ``write`` method), the result will be written to it, otherwise
    it is returned as a string.
    """
    try:
        if not outfile:
            #print formatter, 'using', formatter.encoding
            realoutfile = formatter.encoding and BytesIO() or StringIO()
            formatter.format(tokens, realoutfile)
            return realoutfile.getvalue()
        else:
            formatter.format(tokens, outfile)
    except TypeError, err:
        if isinstance(err.args[0], str) and \
           'unbound method format' in err.args[0]:
            raise TypeError('format() argument must be a formatter instance, '
                            'not a class')
        raise


def highlight(code, lexer, formatter, outfile=None):
    """
    Lex ``code`` with ``lexer`` and format it with the formatter ``formatter``.

    If ``outfile`` is given and a valid file object (an object
    with a ``write`` method), the result will be written to it, otherwise
    it is returned as a string.
    """
    return format(lex(code, lexer), formatter, outfile)


if __name__ == '__main__':
    from pygments.cmdline import main
    sys.exit(main(sys.argv))
# -*- coding: utf-8 -*-
"""
    pygments.cmdline
    ~~~~~~~~~~~~~~~~

    Command line interface.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import sys
import getopt
from textwrap import dedent

from pygments import __version__, highlight
from pygments.util import ClassNotFound, OptionError, docstring_headline
from pygments.lexers import get_all_lexers, get_lexer_by_name, get_lexer_for_filename, \
     find_lexer_class, guess_lexer, TextLexer
from pygments.formatters import get_all_formatters, get_formatter_by_name, \
     get_formatter_for_filename, find_formatter_class, \
     TerminalFormatter  # pylint:disable-msg=E0611
from pygments.filters import get_all_filters, find_filter_class
from pygments.styles import get_all_styles, get_style_by_name


USAGE = """\
Usage: %s [-l <lexer> | -g] [-F <filter>[:<options>]] [-f <formatter>]
          [-O <options>] [-P <option=value>] [-o <outfile>] [<infile>]

       %s -S <style> -f <formatter> [-a <arg>] [-O <options>] [-P <option=value>]
       %s -L [<which> ...]
       %s -N <filename>
       %s -H <type> <name>
       %s -h | -V

Highlight the input file and write the result to <outfile>.

If no input file is given, use stdin, if -o is not given, use stdout.

<lexer> is a lexer name (query all lexer names with -L). If -l is not
given, the lexer is guessed from the extension of the input file name
(this obviously doesn't work if the input is stdin).  If -g is passed,
attempt to guess the lexer from the file contents, or pass through as
plain text if this fails (this can work for stdin).

Likewise, <formatter> is a formatter name, and will be guessed from
the extension of the output file name. If no output file is given,
the terminal formatter will be used by default.

With the -O option, you can give the lexer and formatter a comma-
separated list of options, e.g. ``-O bg=light,python=cool``.

The -P option adds lexer and formatter options like the -O option, but
you can only give one option per -P. That way, the option value may
contain commas and equals signs, which it can't with -O, e.g.
``-P "heading=Pygments, the Python highlighter".

With the -F option, you can add filters to the token stream, you can
give options in the same way as for -O after a colon (note: there must
not be spaces around the colon).

The -O, -P and -F options can be given multiple times.

With the -S option, print out style definitions for style <style>
for formatter <formatter>. The argument given by -a is formatter
dependent.

The -L option lists lexers, formatters, styles or filters -- set
`which` to the thing you want to list (e.g. "styles"), or omit it to
list everything.

The -N option guesses and prints out a lexer name based solely on
the given filename. It does not take input or highlight anything.
If no specific lexer can be determined "text" is returned.

The -H option prints detailed help for the object <name> of type <type>,
where <type> is one of "lexer", "formatter" or "filter".

The -h option prints this help.
The -V option prints the package version.
"""


def _parse_options(o_strs):
    opts = {}
    if not o_strs:
        return opts
    for o_str in o_strs:
        if not o_str:
            continue
        o_args = o_str.split(',')
        for o_arg in o_args:
            o_arg = o_arg.strip()
            try:
                o_key, o_val = o_arg.split('=')
                o_key = o_key.strip()
                o_val = o_val.strip()
            except ValueError:
                opts[o_arg] = True
            else:
                opts[o_key] = o_val
    return opts


def _parse_filters(f_strs):
    filters = []
    if not f_strs:
        return filters
    for f_str in f_strs:
        if ':' in f_str:
            fname, fopts = f_str.split(':', 1)
            filters.append((fname, _parse_options([fopts])))
        else:
            filters.append((f_str, {}))
    return filters


def _print_help(what, name):
    try:
        if what == 'lexer':
            cls = find_lexer_class(name)
            print "Help on the %s lexer:" % cls.name
            print dedent(cls.__doc__)
        elif what == 'formatter':
            cls = find_formatter_class(name)
            print "Help on the %s formatter:" % cls.name
            print dedent(cls.__doc__)
        elif what == 'filter':
            cls = find_filter_class(name)
            print "Help on the %s filter:" % name
            print dedent(cls.__doc__)
    except AttributeError:
        print >>sys.stderr, "%s not found!" % what


def _print_list(what):
    if what == 'lexer':
        print
        print "Lexers:"
        print "~~~~~~~"

        info = []
        for fullname, names, exts, _ in get_all_lexers():
            tup = (', '.join(names)+':', fullname,
                   exts and '(filenames ' + ', '.join(exts) + ')' or '')
            info.append(tup)
        info.sort()
        for i in info:
            print ('* %s\n    %s %s') % i

    elif what == 'formatter':
        print
        print "Formatters:"
        print "~~~~~~~~~~~"

        info = []
        for cls in get_all_formatters():
            doc = docstring_headline(cls)
            tup = (', '.join(cls.aliases) + ':', doc, cls.filenames and
                   '(filenames ' + ', '.join(cls.filenames) + ')' or '')
            info.append(tup)
        info.sort()
        for i in info:
            print ('* %s\n    %s %s') % i

    elif what == 'filter':
        print
        print "Filters:"
        print "~~~~~~~~"

        for name in get_all_filters():
            cls = find_filter_class(name)
            print "* " + name + ':'
            print "    %s" % docstring_headline(cls)

    elif what == 'style':
        print
        print "Styles:"
        print "~~~~~~~"

        for name in get_all_styles():
            cls = get_style_by_name(name)
            print "* " + name + ':'
            print "    %s" % docstring_headline(cls)


def main(args=sys.argv):
    """
    Main command line entry point.
    """
    # pylint: disable-msg=R0911,R0912,R0915

    usage = USAGE % ((args[0],) * 6)

    try:
        popts, args = getopt.getopt(args[1:], "l:f:F:o:O:P:LS:a:N:hVHg")
    except getopt.GetoptError, err:
        print >>sys.stderr, usage
        return 2
    opts = {}
    O_opts = []
    P_opts = []
    F_opts = []
    for opt, arg in popts:
        if opt == '-O':
            O_opts.append(arg)
        elif opt == '-P':
            P_opts.append(arg)
        elif opt == '-F':
            F_opts.append(arg)
        opts[opt] = arg

    if not opts and not args:
        print usage
        return 0

    if opts.pop('-h', None) is not None:
        print usage
        return 0

    if opts.pop('-V', None) is not None:
        print 'Pygments version %s, (c) 2006-2008 by Georg Brandl.' % __version__
        return 0

    # handle ``pygmentize -L``
    L_opt = opts.pop('-L', None)
    if L_opt is not None:
        if opts:
            print >>sys.stderr, usage
            return 2

        # print version
        main(['', '-V'])
        if not args:
            args = ['lexer', 'formatter', 'filter', 'style']
        for arg in args:
            _print_list(arg.rstrip('s'))
        return 0

    # handle ``pygmentize -H``
    H_opt = opts.pop('-H', None)
    if H_opt is not None:
        if opts or len(args) != 2:
            print >>sys.stderr, usage
            return 2

        what, name = args
        if what not in ('lexer', 'formatter', 'filter'):
            print >>sys.stderr, usage
            return 2

        _print_help(what, name)
        return 0

    # parse -O options
    parsed_opts = _parse_options(O_opts)
    opts.pop('-O', None)

    # parse -P options
    for p_opt in P_opts:
        try:
            name, value = p_opt.split('=', 1)
        except ValueError:
            parsed_opts[p_opt] = True
        else:
            parsed_opts[name] = value
    opts.pop('-P', None)

    # handle ``pygmentize -N``
    infn = opts.pop('-N', None)
    if infn is not None:
        try:
            lexer = get_lexer_for_filename(infn, **parsed_opts)
        except ClassNotFound, err:
            lexer = TextLexer()
        except OptionError, err:
            print >>sys.stderr, 'Error:', err
            return 1

        print lexer.aliases[0]
        return 0

    # handle ``pygmentize -S``
    S_opt = opts.pop('-S', None)
    a_opt = opts.pop('-a', None)
    if S_opt is not None:
        f_opt = opts.pop('-f', None)
        if not f_opt:
            print >>sys.stderr, usage
            return 2
        if opts or args:
            print >>sys.stderr, usage
            return 2

        try:
            parsed_opts['style'] = S_opt
            fmter = get_formatter_by_name(f_opt, **parsed_opts)
        except ClassNotFound, err:
            print >>sys.stderr, err
            return 1

        arg = a_opt or ''
        try:
            print fmter.get_style_defs(arg)
        except Exception, err:
            print >>sys.stderr, 'Error:', err
            return 1
        return 0

    # if no -S is given, -a is not allowed
    if a_opt is not None:
        print >>sys.stderr, usage
        return 2

    # parse -F options
    F_opts = _parse_filters(F_opts)
    opts.pop('-F', None)

    # select formatter
    outfn = opts.pop('-o', None)
    fmter = opts.pop('-f', None)
    if fmter:
        try:
            fmter = get_formatter_by_name(fmter, **parsed_opts)
        except (OptionError, ClassNotFound), err:
            print >>sys.stderr, 'Error:', err
            return 1

    if outfn:
        if not fmter:
            try:
                fmter = get_formatter_for_filename(outfn, **parsed_opts)
            except (OptionError, ClassNotFound), err:
                print >>sys.stderr, 'Error:', err
                return 1
        try:
            outfile = open(outfn, 'wb')
        except Exception, err:
            print >>sys.stderr, 'Error: cannot open outfile:', err
            return 1
    else:
        if not fmter:
            fmter = TerminalFormatter(**parsed_opts)
        outfile = sys.stdout

    # select lexer
    lexer = opts.pop('-l', None)
    if lexer:
        try:
            lexer = get_lexer_by_name(lexer, **parsed_opts)
        except (OptionError, ClassNotFound), err:
            print >>sys.stderr, 'Error:', err
            return 1

    if args:
        if len(args) > 1:
            print >>sys.stderr, usage
            return 2

        infn = args[0]
        try:
            code = open(infn, 'rb').read()
        except Exception, err:
            print >>sys.stderr, 'Error: cannot read infile:', err
            return 1

        if not lexer:
            try:
                lexer = get_lexer_for_filename(infn, code, **parsed_opts)
            except ClassNotFound, err:
                if '-g' in opts:
                    try:
                        lexer = guess_lexer(code)
                    except ClassNotFound:
                        lexer = TextLexer()
                else:
                    print >>sys.stderr, 'Error:', err
                    return 1
            except OptionError, err:
                print >>sys.stderr, 'Error:', err
                return 1

    else:
        if '-g' in opts:
            code = sys.stdin.read()
            try:
                lexer = guess_lexer(code)
            except ClassNotFound:
                lexer = TextLexer()
        elif not lexer:
            print >>sys.stderr, 'Error: no lexer name given and reading ' + \
                                'from stdin (try using -g or -l <lexer>)'
            return 2
        else:
            code = sys.stdin.read()

    # No encoding given? Use latin1 if output file given,
    # stdin/stdout encoding otherwise.
    # (This is a compromise, I'm not too happy with it...)
    if 'encoding' not in parsed_opts and 'outencoding' not in parsed_opts:
        if outfn:
            # encoding pass-through
            fmter.encoding = 'latin1'
        else:
            if sys.version_info < (3,):
                # use terminal encoding; Python 3's terminals already do that
                lexer.encoding = getattr(sys.stdin, 'encoding',
                                         None) or 'ascii'
                fmter.encoding = getattr(sys.stdout, 'encoding',
                                         None) or 'ascii'

    # ... and do it!
    try:
        # process filters
        for fname, fopts in F_opts:
            lexer.add_filter(fname, **fopts)
        highlight(code, lexer, fmter, outfile)
    except Exception, err:
        import traceback
        info = traceback.format_exception(*sys.exc_info())
        msg = info[-1].strip()
        if len(info) >= 3:
            # extract relevant file and position info
            msg += '\n   (f%s)' % info[-2].split('\n')[0].strip()[1:]
        print >>sys.stderr
        print >>sys.stderr, '*** Error while highlighting:'
        print >>sys.stderr, msg
        return 1

    return 0
# -*- coding: utf-8 -*-
"""
    pygments.console
    ~~~~~~~~~~~~~~~~

    Format colored console output.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

esc = "\x1b["

codes = {}
codes[""]          = ""
codes["reset"]     = esc + "39;49;00m"

codes["bold"]      = esc + "01m"
codes["faint"]     = esc + "02m"
codes["standout"]  = esc + "03m"
codes["underline"] = esc + "04m"
codes["blink"]     = esc + "05m"
codes["overline"]  = esc + "06m"

dark_colors  = ["black", "darkred", "darkgreen", "brown", "darkblue",
                "purple", "teal", "lightgray"]
light_colors = ["darkgray", "red", "green", "yellow", "blue",
                "fuchsia", "turquoise", "white"]

x = 30
for d, l in zip(dark_colors, light_colors):
    codes[d] = esc + "%im" % x
    codes[l] = esc + "%i;01m" % x
    x += 1

del d, l, x

codes["darkteal"]   = codes["turquoise"]
codes["darkyellow"] = codes["brown"]
codes["fuscia"]     = codes["fuchsia"]
codes["white"]      = codes["bold"]


def reset_color():
    return codes["reset"]


def colorize(color_key, text):
    return codes[color_key] + text + codes["reset"]


def ansiformat(attr, text):
    """
    Format ``text`` with a color and/or some attributes::

        color       normal color
        *color*     bold color
        _color_     underlined color
        +color+     blinking color
    """
    result = []
    if attr[:1] == attr[-1:] == '+':
        result.append(codes['blink'])
        attr = attr[1:-1]
    if attr[:1] == attr[-1:] == '*':
        result.append(codes['bold'])
        attr = attr[1:-1]
    if attr[:1] == attr[-1:] == '_':
        result.append(codes['underline'])
        attr = attr[1:-1]
    result.append(codes[attr])
    result.append(text)
    result.append(codes['reset'])
    return ''.join(result)
# -*- coding: utf-8 -*-
"""
    pygments.filter
    ~~~~~~~~~~~~~~~

    Module that implements the default filter.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""


def apply_filters(stream, filters, lexer=None):
    """
    Use this method to apply an iterable of filters to
    a stream. If lexer is given it's forwarded to the
    filter, otherwise the filter receives `None`.
    """
    def _apply(filter_, stream):
        for token in filter_.filter(lexer, stream):
            yield token
    for filter_ in filters:
        stream = _apply(filter_, stream)
    return stream


def simplefilter(f):
    """
    Decorator that converts a function into a filter::

        @simplefilter
        def lowercase(lexer, stream, options):
            for ttype, value in stream:
                yield ttype, value.lower()
    """
    return type(f.__name__, (FunctionFilter,), {
                'function':     f,
                '__module__':   getattr(f, '__module__'),
                '__doc__':      f.__doc__
            })


class Filter(object):
    """
    Default filter. Subclass this class or use the `simplefilter`
    decorator to create own filters.
    """

    def __init__(self, **options):
        self.options = options

    def filter(self, lexer, stream):
        raise NotImplementedError()


class FunctionFilter(Filter):
    """
    Abstract class used by `simplefilter` to create simple
    function filters on the fly. The `simplefilter` decorator
    automatically creates subclasses of this class for
    functions passed to it.
    """
    function = None

    def __init__(self, **options):
        if not hasattr(self, 'function'):
            raise TypeError('%r used without bound function' %
                            self.__class__.__name__)
        Filter.__init__(self, **options)

    def filter(self, lexer, stream):
        # pylint: disable-msg=E1102
        for ttype, value in self.function(lexer, stream, self.options):
            yield ttype, value
# -*- coding: utf-8 -*-
"""
    pygments.filters
    ~~~~~~~~~~~~~~~~

    Module containing filter lookup functions and default
    filters.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
try:
    set
except NameError:
    from sets import Set as set

import re
from pygments.token import String, Comment, Keyword, Name, Error, Whitespace, \
    string_to_tokentype
from pygments.filter import Filter
from pygments.util import get_list_opt, get_int_opt, get_bool_opt, get_choice_opt, \
     ClassNotFound, OptionError
from pygments.plugin import find_plugin_filters


def find_filter_class(filtername):
    """
    Lookup a filter by name. Return None if not found.
    """
    if filtername in FILTERS:
        return FILTERS[filtername]
    for name, cls in find_plugin_filters():
        if name == filtername:
            return cls
    return None


def get_filter_by_name(filtername, **options):
    """
    Return an instantiated filter. Options are passed to the filter
    initializer if wanted. Raise a ClassNotFound if not found.
    """
    cls = find_filter_class(filtername)
    if cls:
        return cls(**options)
    else:
        raise ClassNotFound('filter %r not found' % filtername)


def get_all_filters():
    """
    Return a generator of all filter names.
    """
    for name in FILTERS:
        yield name
    for name, _ in find_plugin_filters():
        yield name


def _replace_special(ttype, value, regex, specialttype,
                     replacefunc=lambda x: x):
    last = 0
    for match in regex.finditer(value):
        start, end = match.start(), match.end()
        if start != last:
            yield ttype, value[last:start]
        yield specialttype, replacefunc(value[start:end])
        last = end
    if last != len(value):
        yield ttype, value[last:]


class CodeTagFilter(Filter):
    """
    Highlight special code tags in comments and docstrings.

    Options accepted:

    `codetags` : list of strings
       A list of strings that are flagged as code tags.  The default is to
       highlight ``XXX``, ``TODO``, ``BUG`` and ``NOTE``.
    """

    def __init__(self, **options):
        Filter.__init__(self, **options)
        tags = get_list_opt(options, 'codetags',
                            ['XXX', 'TODO', 'BUG', 'NOTE'])
        self.tag_re = re.compile(r'\b(%s)\b' % '|'.join([
            re.escape(tag) for tag in tags if tag
        ]))

    def filter(self, lexer, stream):
        regex = self.tag_re
        for ttype, value in stream:
            if ttype in String.Doc or \
               ttype in Comment and \
               ttype not in Comment.Preproc:
                for sttype, svalue in _replace_special(ttype, value, regex,
                                                       Comment.Special):
                    yield sttype, svalue
            else:
                yield ttype, value


class KeywordCaseFilter(Filter):
    """
    Convert keywords to lowercase or uppercase or capitalize them, which
    means first letter uppercase, rest lowercase.

    This can be useful e.g. if you highlight Pascal code and want to adapt the
    code to your styleguide.

    Options accepted:

    `case` : string
       The casing to convert keywords to. Must be one of ``'lower'``,
       ``'upper'`` or ``'capitalize'``.  The default is ``'lower'``.
    """

    def __init__(self, **options):
        Filter.__init__(self, **options)
        case = get_choice_opt(options, 'case', ['lower', 'upper', 'capitalize'], 'lower')
        self.convert = getattr(unicode, case)

    def filter(self, lexer, stream):
        for ttype, value in stream:
            if ttype in Keyword:
                yield ttype, self.convert(value)
            else:
                yield ttype, value


class NameHighlightFilter(Filter):
    """
    Highlight a normal Name token with a different token type.

    Example::

        filter = NameHighlightFilter(
            names=['foo', 'bar', 'baz'],
            tokentype=Name.Function,
        )

    This would highlight the names "foo", "bar" and "baz"
    as functions. `Name.Function` is the default token type.

    Options accepted:

    `names` : list of strings
      A list of names that should be given the different token type.
      There is no default.
    `tokentype` : TokenType or string
      A token type or a string containing a token type name that is
      used for highlighting the strings in `names`.  The default is
      `Name.Function`.
    """

    def __init__(self, **options):
        Filter.__init__(self, **options)
        self.names = set(get_list_opt(options, 'names', []))
        tokentype = options.get('tokentype')
        if tokentype:
            self.tokentype = string_to_tokentype(tokentype)
        else:
            self.tokentype = Name.Function

    def filter(self, lexer, stream):
        for ttype, value in stream:
            if ttype is Name and value in self.names:
                yield self.tokentype, value
            else:
                yield ttype, value


class ErrorToken(Exception):
    pass

class RaiseOnErrorTokenFilter(Filter):
    """
    Raise an exception when the lexer generates an error token.

    Options accepted:

    `excclass` : Exception class
      The exception class to raise.
      The default is `pygments.filters.ErrorToken`.

    *New in Pygments 0.8.*
    """

    def __init__(self, **options):
        Filter.__init__(self, **options)
        self.exception = options.get('excclass', ErrorToken)
        try:
            # issubclass() will raise TypeError if first argument is not a class
            if not issubclass(self.exception, Exception):
                raise TypeError
        except TypeError:
            raise OptionError('excclass option is not an exception class')

    def filter(self, lexer, stream):
        for ttype, value in stream:
            if ttype is Error:
                raise self.exception(value)
            yield ttype, value


class VisibleWhitespaceFilter(Filter):
    """
    Convert tabs, newlines and/or spaces to visible characters.

    Options accepted:

    `spaces` : string or bool
      If this is a one-character string, spaces will be replaces by this string.
      If it is another true value, spaces will be replaced by ``·`` (unicode
      MIDDLE DOT).  If it is a false value, spaces will not be replaced.  The
      default is ``False``.
    `tabs` : string or bool
      The same as for `spaces`, but the default replacement character is ``»``
      (unicode RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK).  The default value
      is ``False``.  Note: this will not work if the `tabsize` option for the
      lexer is nonzero, as tabs will already have been expanded then.
    `tabsize` : int
      If tabs are to be replaced by this filter (see the `tabs` option), this
      is the total number of characters that a tab should be expanded to.
      The default is ``8``.
    `newlines` : string or bool
      The same as for `spaces`, but the default replacement character is ``¶``
      (unicode PILCROW SIGN).  The default value is ``False``.
    `wstokentype` : bool
      If true, give whitespace the special `Whitespace` token type.  This allows
      styling the visible whitespace differently (e.g. greyed out), but it can
      disrupt background colors.  The default is ``True``.

    *New in Pygments 0.8.*
    """

    def __init__(self, **options):
        Filter.__init__(self, **options)
        for name, default in {'spaces': u'·', 'tabs': u'»', 'newlines': u'¶'}.items():
            opt = options.get(name, False)
            if isinstance(opt, basestring) and len(opt) == 1:
                setattr(self, name, opt)
            else:
                setattr(self, name, (opt and default or ''))
        tabsize = get_int_opt(options, 'tabsize', 8)
        if self.tabs:
            self.tabs += ' '*(tabsize-1)
        if self.newlines:
            self.newlines += '\n'
        self.wstt = get_bool_opt(options, 'wstokentype', True)

    def filter(self, lexer, stream):
        if self.wstt:
            spaces = self.spaces or ' '
            tabs = self.tabs or '\t'
            newlines = self.newlines or '\n'
            regex = re.compile(r'\s')
            def replacefunc(wschar):
                if wschar == ' ':
                    return spaces
                elif wschar == '\t':
                    return tabs
                elif wschar == '\n':
                    return newlines
                return wschar

            for ttype, value in stream:
                for sttype, svalue in _replace_special(ttype, value, regex,
                                                       Whitespace, replacefunc):
                    yield sttype, svalue
        else:
            spaces, tabs, newlines = self.spaces, self.tabs, self.newlines
            # simpler processing
            for ttype, value in stream:
                if spaces:
                    value = value.replace(' ', spaces)
                if tabs:
                    value = value.replace('\t', tabs)
                if newlines:
                    value = value.replace('\n', newlines)
                yield ttype, value


FILTERS = {
    'codetagify':     CodeTagFilter,
    'keywordcase':    KeywordCaseFilter,
    'highlight':      NameHighlightFilter,
    'raiseonerror':   RaiseOnErrorTokenFilter,
    'whitespace':     VisibleWhitespaceFilter,
}
# -*- coding: utf-8 -*-
"""
    pygments.formatter
    ~~~~~~~~~~~~~~~~~~

    Base formatter class.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import codecs

from pygments.util import get_bool_opt
from pygments.styles import get_style_by_name

__all__ = ['Formatter']


def _lookup_style(style):
    if isinstance(style, basestring):
        return get_style_by_name(style)
    return style


class Formatter(object):
    """
    Converts a token stream to text.

    Options accepted:

    ``style``
        The style to use, can be a string or a Style subclass
        (default: "default"). Not used by e.g. the
        TerminalFormatter.
    ``full``
        Tells the formatter to output a "full" document, i.e.
        a complete self-contained document. This doesn't have
        any effect for some formatters (default: false).
    ``title``
        If ``full`` is true, the title that should be used to
        caption the document (default: '').
    ``encoding``
        If given, must be an encoding name. This will be used to
        convert the Unicode token strings to byte strings in the
        output. If it is "" or None, Unicode strings will be written
        to the output file, which most file-like objects do not
        support (default: None).
    ``outencoding``
        Overrides ``encoding`` if given.
    """

    #: Name of the formatter
    name = None

    #: Shortcuts for the formatter
    aliases = []

    #: fn match rules
    filenames = []

    #: If True, this formatter outputs Unicode strings when no encoding
    #: option is given.
    unicodeoutput = True

    def __init__(self, **options):
        self.style = _lookup_style(options.get('style', 'default'))
        self.full  = get_bool_opt(options, 'full', False)
        self.title = options.get('title', '')
        self.encoding = options.get('encoding', None) or None
        self.encoding = options.get('outencoding', None) or self.encoding
        self.options = options

    def get_style_defs(self, arg=''):
        """
        Return the style definitions for the current style as a string.

        ``arg`` is an additional argument whose meaning depends on the
        formatter used. Note that ``arg`` can also be a list or tuple
        for some formatters like the html formatter.
        """
        return ''

    def format(self, tokensource, outfile):
        """
        Format ``tokensource``, an iterable of ``(tokentype, tokenstring)``
        tuples and write it into ``outfile``.
        """
        if self.encoding:
            # wrap the outfile in a StreamWriter
            outfile = codecs.lookup(self.encoding)[3](outfile)
        return self.format_unencoded(tokensource, outfile)
# -*- coding: utf-8 -*-
"""
    pygments.formatters
    ~~~~~~~~~~~~~~~~~~~

    Pygments formatters.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import os.path
import fnmatch

from pygments.formatters._mapping import FORMATTERS
from pygments.plugin import find_plugin_formatters
from pygments.util import docstring_headline, ClassNotFound

ns = globals()
for fcls in FORMATTERS:
    ns[fcls.__name__] = fcls
del fcls

__all__ = ['get_formatter_by_name', 'get_formatter_for_filename',
           'get_all_formatters'] + [cls.__name__ for cls in FORMATTERS]


_formatter_alias_cache = {}
_formatter_filename_cache = []

def _init_formatter_cache():
    if _formatter_alias_cache:
        return
    for cls in get_all_formatters():
        for alias in cls.aliases:
            _formatter_alias_cache[alias] = cls
        for fn in cls.filenames:
            _formatter_filename_cache.append((fn, cls))


def find_formatter_class(name):
    _init_formatter_cache()
    cls = _formatter_alias_cache.get(name, None)
    return cls


def get_formatter_by_name(name, **options):
    _init_formatter_cache()
    cls = _formatter_alias_cache.get(name, None)
    if not cls:
        raise ClassNotFound("No formatter found for name %r" % name)
    return cls(**options)


def get_formatter_for_filename(fn, **options):
    _init_formatter_cache()
    fn = os.path.basename(fn)
    for pattern, cls in _formatter_filename_cache:
        if fnmatch.fnmatch(fn, pattern):
            return cls(**options)
    raise ClassNotFound("No formatter found for file name %r" % fn)


def get_all_formatters():
    """Return a generator for all formatters."""
    for formatter in FORMATTERS:
        yield formatter
    for _, formatter in find_plugin_formatters():
        yield formatter
# -*- coding: utf-8 -*-
"""
    pygments.formatters._mapping
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Formatter mapping defintions. This file is generated by itself. Everytime
    you change something on a builtin formatter defintion, run this script from
    the formatters folder to update it.

    Do not alter the FORMATTERS dictionary by hand.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.util import docstring_headline

# start
from pygments.formatters.bbcode import BBCodeFormatter
from pygments.formatters.html import HtmlFormatter
from pygments.formatters.img import BmpImageFormatter
from pygments.formatters.img import GifImageFormatter
from pygments.formatters.img import ImageFormatter
from pygments.formatters.img import JpgImageFormatter
from pygments.formatters.latex import LatexFormatter
from pygments.formatters.other import NullFormatter
from pygments.formatters.other import RawTokenFormatter
from pygments.formatters.rtf import RtfFormatter
from pygments.formatters.svg import SvgFormatter
from pygments.formatters.terminal import TerminalFormatter
from pygments.formatters.terminal256 import Terminal256Formatter

FORMATTERS = {
    BBCodeFormatter: ('BBCode', ('bbcode', 'bb'), (), 'Format tokens with BBcodes. These formatting codes are used by many bulletin boards, so you can highlight your sourcecode with pygments before posting it there.'),
    BmpImageFormatter: ('img_bmp', ('bmp', 'bitmap'), ('*.bmp',), 'Create a bitmap image from source code. This uses the Python Imaging Library to generate a pixmap from the source code.'),
    GifImageFormatter: ('img_gif', ('gif',), ('*.gif',), 'Create a GIF image from source code. This uses the Python Imaging Library to generate a pixmap from the source code.'),
    HtmlFormatter: ('HTML', ('html',), ('*.html', '*.htm'), "Format tokens as HTML 4 ``<span>`` tags within a ``<pre>`` tag, wrapped in a ``<div>`` tag. The ``<div>``'s CSS class can be set by the `cssclass` option."),
    ImageFormatter: ('img', ('img', 'IMG', 'png'), ('*.png',), 'Create a PNG image from source code. This uses the Python Imaging Library to generate a pixmap from the source code.'),
    JpgImageFormatter: ('img_jpg', ('jpg', 'jpeg'), ('*.jpg',), 'Create a JPEG image from source code. This uses the Python Imaging Library to generate a pixmap from the source code.'),
    LatexFormatter: ('LaTeX', ('latex', 'tex'), ('*.tex',), 'Format tokens as LaTeX code. This needs the `fancyvrb` and `color` standard packages.'),
    NullFormatter: ('Text only', ('text', 'null'), ('*.txt',), 'Output the text unchanged without any formatting.'),
    RawTokenFormatter: ('Raw tokens', ('raw', 'tokens'), ('*.raw',), 'Format tokens as a raw representation for storing token streams.'),
    RtfFormatter: ('RTF', ('rtf',), ('*.rtf',), 'Format tokens as RTF markup. This formatter automatically outputs full RTF documents with color information and other useful stuff. Perfect for Copy and Paste into Microsoft\xc2\xae Word\xc2\xae documents.'),
    SvgFormatter: ('SVG', ('svg',), ('*.svg',), 'Format tokens as an SVG graphics file.  This formatter is still experimental. Each line of code is a ``<text>`` element with explicit ``x`` and ``y`` coordinates containing ``<tspan>`` elements with the individual token styles.'),
    Terminal256Formatter: ('Terminal256', ('terminal256', 'console256', '256'), (), 'Format tokens with ANSI color sequences, for output in a 256-color terminal or console. Like in `TerminalFormatter` color sequences are terminated at newlines, so that paging the output works correctly.'),
    TerminalFormatter: ('Terminal', ('terminal', 'console'), (), 'Format tokens with ANSI color sequences, for output in a text console. Color sequences are terminated at newlines, so that paging the output works correctly.')
}

if __name__ == '__main__':
    import sys
    import os

    # lookup formatters
    found_formatters = []
    imports = []
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))
    for filename in os.listdir('.'):
        if filename.endswith('.py') and not filename.startswith('_'):
            module_name = 'pygments.formatters.%s' % filename[:-3]
            print module_name
            module = __import__(module_name, None, None, [''])
            for formatter_name in module.__all__:
                imports.append((module_name, formatter_name))
                formatter = getattr(module, formatter_name)
                found_formatters.append(
                    '%s: %r' % (formatter_name,
                                (formatter.name,
                                 tuple(formatter.aliases),
                                 tuple(formatter.filenames),
                                 docstring_headline(formatter))))
    # sort them, that should make the diff files for svn smaller
    found_formatters.sort()
    imports.sort()

    # extract useful sourcecode from this file
    f = open(__file__)
    try:
        content = f.read()
    finally:
        f.close()
    header = content[:content.find('# start')]
    footer = content[content.find("if __name__ == '__main__':"):]

    # write new file
    f = open(__file__, 'w')
    f.write(header)
    f.write('# start\n')
    f.write('\n'.join(['from %s import %s' % imp for imp in imports]))
    f.write('\n\n')
    f.write('FORMATTERS = {\n    %s\n}\n\n' % ',\n    '.join(found_formatters))
    f.write(footer)
    f.close()
# -*- coding: utf-8 -*-
"""
    pygments.formatters.bbcode
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

    BBcode formatter.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""


from pygments.formatter import Formatter
from pygments.util import get_bool_opt

__all__ = ['BBCodeFormatter']


class BBCodeFormatter(Formatter):
    """
    Format tokens with BBcodes. These formatting codes are used by many
    bulletin boards, so you can highlight your sourcecode with pygments before
    posting it there.

    This formatter has no support for background colors and borders, as there
    are no common BBcode tags for that.

    Some board systems (e.g. phpBB) don't support colors in their [code] tag,
    so you can't use the highlighting together with that tag.
    Text in a [code] tag usually is shown with a monospace font (which this
    formatter can do with the ``monofont`` option) and no spaces (which you
    need for indentation) are removed.

    Additional options accepted:

    `style`
        The style to use, can be a string or a Style subclass (default:
        ``'default'``).

    `codetag`
        If set to true, put the output into ``[code]`` tags (default:
        ``false``)

    `monofont`
        If set to true, add a tag to show the code with a monospace font
        (default: ``false``).
    """
    name = 'BBCode'
    aliases = ['bbcode', 'bb']
    filenames = []

    def __init__(self, **options):
        Formatter.__init__(self, **options)
        self._code = get_bool_opt(options, 'codetag', False)
        self._mono = get_bool_opt(options, 'monofont', False)

        self.styles = {}
        self._make_styles()

    def _make_styles(self):
        for ttype, ndef in self.style:
            start = end = ''
            if ndef['color']:
                start += '[color=#%s]' % ndef['color']
                end = '[/color]' + end
            if ndef['bold']:
                start += '[b]'
                end = '[/b]' + end
            if ndef['italic']:
                start += '[i]'
                end = '[/i]' + end
            if ndef['underline']:
                start += '[u]'
                end = '[/u]' + end
            # there are no common BBcodes for background-color and border

            self.styles[ttype] = start, end

    def format_unencoded(self, tokensource, outfile):
        if self._code:
            outfile.write('[code]')
        if self._mono:
            outfile.write('[font=monospace]')

        lastval = ''
        lasttype = None

        for ttype, value in tokensource:
            while ttype not in self.styles:
                ttype = ttype.parent
            if ttype == lasttype:
                lastval += value
            else:
                if lastval:
                    start, end = self.styles[lasttype]
                    outfile.write(''.join((start, lastval, end)))
                lastval = value
                lasttype = ttype

        if lastval:
            start, end = self.styles[lasttype]
            outfile.write(''.join((start, lastval, end)))

        if self._mono:
            outfile.write('[/font]')
        if self._code:
            outfile.write('[/code]')
        if self._code or self._mono:
            outfile.write('\n')
# -*- coding: utf-8 -*-
"""
    pygments.formatters.html
    ~~~~~~~~~~~~~~~~~~~~~~~~

    Formatter for HTML output.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import sys, os
import StringIO

try:
    set
except NameError:
    from sets import Set as set

from pygments.formatter import Formatter
from pygments.token import Token, Text, STANDARD_TYPES
from pygments.util import get_bool_opt, get_int_opt, get_list_opt, bytes


__all__ = ['HtmlFormatter']


def escape_html(text):
    """Escape &, <, > as well as single and double quotes for HTML."""
    return text.replace('&', '&amp;').  \
                replace('<', '&lt;').   \
                replace('>', '&gt;').   \
                replace('"', '&quot;'). \
                replace("'", '&#39;')


def get_random_id():
    """Return a random id for javascript fields."""
    from random import random
    from time import time
    try:
        from hashlib import sha1 as sha
    except ImportError:
        import sha
        sha = sha.new
    return sha('%s|%s' % (random(), time())).hexdigest()


def _get_ttype_class(ttype):
    fname = STANDARD_TYPES.get(ttype)
    if fname:
        return fname
    aname = ''
    while fname is None:
        aname = '-' + ttype[-1] + aname
        ttype = ttype.parent
        fname = STANDARD_TYPES.get(ttype)
    return fname + aname


CSSFILE_TEMPLATE = '''\
td.linenos { background-color: #f0f0f0; padding-right: 10px; }
span.lineno { background-color: #f0f0f0; padding: 0 5px 0 5px; }
pre { line-height: 125%%; }
%(styledefs)s
'''

DOC_HEADER = '''\
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">

<html>
<head>
  <title>%(title)s</title>
  <meta http-equiv="content-type" content="text/html; charset=%(encoding)s">
  <style type="text/css">
''' + CSSFILE_TEMPLATE + '''
  </style>
</head>
<body>
<h2>%(title)s</h2>

'''

DOC_HEADER_EXTERNALCSS = '''\
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">

<html>
<head>
  <title>%(title)s</title>
  <meta http-equiv="content-type" content="text/html; charset=%(encoding)s">
  <link rel="stylesheet" href="%(cssfile)s" type="text/css">
</head>
<body>
<h2>%(title)s</h2>

'''

DOC_FOOTER = '''\
</body>
</html>
'''


class HtmlFormatter(Formatter):
    r"""
    Format tokens as HTML 4 ``<span>`` tags within a ``<pre>`` tag, wrapped
    in a ``<div>`` tag. The ``<div>``'s CSS class can be set by the `cssclass`
    option.

    If the `linenos` option is set to ``"table"``, the ``<pre>`` is
    additionally wrapped inside a ``<table>`` which has one row and two
    cells: one containing the line numbers and one containing the code.
    Example:

    .. sourcecode:: html

        <div class="highlight" >
        <table><tr>
          <td class="linenos" title="click to toggle"
            onclick="with (this.firstChild.style)
                     { display = (display == '') ? 'none' : '' }">
            <pre>1
            2</pre>
          </td>
          <td class="code">
            <pre><span class="Ke">def </span><span class="NaFu">foo</span>(bar):
              <span class="Ke">pass</span>
            </pre>
          </td>
        </tr></table></div>

    (whitespace added to improve clarity).

    Wrapping can be disabled using the `nowrap` option.

    A list of lines can be specified using the `hl_lines` option to make these
    lines highlighted (as of Pygments 0.11).

    With the `full` option, a complete HTML 4 document is output, including
    the style definitions inside a ``<style>`` tag, or in a separate file if
    the `cssfile` option is given.

    The `get_style_defs(arg='')` method of a `HtmlFormatter` returns a string
    containing CSS rules for the CSS classes used by the formatter. The
    argument `arg` can be used to specify additional CSS selectors that
    are prepended to the classes. A call `fmter.get_style_defs('td .code')`
    would result in the following CSS classes:

    .. sourcecode:: css

        td .code .kw { font-weight: bold; color: #00FF00 }
        td .code .cm { color: #999999 }
        ...

    If you have Pygments 0.6 or higher, you can also pass a list or tuple to the
    `get_style_defs()` method to request multiple prefixes for the tokens:

    .. sourcecode:: python

        formatter.get_style_defs(['div.syntax pre', 'pre.syntax'])

    The output would then look like this:

    .. sourcecode:: css

        div.syntax pre .kw,
        pre.syntax .kw { font-weight: bold; color: #00FF00 }
        div.syntax pre .cm,
        pre.syntax .cm { color: #999999 }
        ...

    Additional options accepted:

    `nowrap`
        If set to ``True``, don't wrap the tokens at all, not even inside a ``<pre>``
        tag. This disables most other options (default: ``False``).

    `full`
        Tells the formatter to output a "full" document, i.e. a complete
        self-contained document (default: ``False``).

    `title`
        If `full` is true, the title that should be used to caption the
        document (default: ``''``).

    `style`
        The style to use, can be a string or a Style subclass (default:
        ``'default'``). This option has no effect if the `cssfile`
        and `noclobber_cssfile` option are given and the file specified in
        `cssfile` exists.

    `noclasses`
        If set to true, token ``<span>`` tags will not use CSS classes, but
        inline styles. This is not recommended for larger pieces of code since
        it increases output size by quite a bit (default: ``False``).

    `classprefix`
        Since the token types use relatively short class names, they may clash
        with some of your own class names. In this case you can use the
        `classprefix` option to give a string to prepend to all Pygments-generated
        CSS class names for token types.
        Note that this option also affects the output of `get_style_defs()`.

    `cssclass`
        CSS class for the wrapping ``<div>`` tag (default: ``'highlight'``).
        If you set this option, the default selector for `get_style_defs()`
        will be this class.

        *New in Pygments 0.9:* If you select the ``'table'`` line numbers, the
        wrapping table will have a CSS class of this string plus ``'table'``,
        the default is accordingly ``'highlighttable'``.

    `cssstyles`
        Inline CSS styles for the wrapping ``<div>`` tag (default: ``''``).

    `prestyles`
        Inline CSS styles for the ``<pre>`` tag (default: ``''``).  *New in
        Pygments 0.11.*

    `cssfile`
        If the `full` option is true and this option is given, it must be the
        name of an external file. If the filename does not include an absolute
        path, the file's path will be assumed to be relative to the main output
        file's path, if the latter can be found. The stylesheet is then written
        to this file instead of the HTML file. *New in Pygments 0.6.*

    `noclobber_cssfile'
        If `cssfile` is given and the specified file exists, the css file will
        not be overwritten. This allows the use of the `full` option in
        combination with a user specified css file. Default is ``False``.
        *New in Pygments 1.1.*

    `linenos`
        If set to ``'table'``, output line numbers as a table with two cells,
        one containing the line numbers, the other the whole code.  This is
        copy-and-paste-friendly, but may cause alignment problems with some
        browsers or fonts.  If set to ``'inline'``, the line numbers will be
        integrated in the ``<pre>`` tag that contains the code (that setting
        is *new in Pygments 0.8*).

        For compatibility with Pygments 0.7 and earlier, every true value
        except ``'inline'`` means the same as ``'table'`` (in particular, that
        means also ``True``).

        The default value is ``False``, which means no line numbers at all.

        **Note:** with the default ("table") line number mechanism, the line
        numbers and code can have different line heights in Internet Explorer
        unless you give the enclosing ``<pre>`` tags an explicit ``line-height``
        CSS property (you get the default line spacing with ``line-height:
        125%``).

    `hl_lines`
        Specify a list of lines to be highlighted.  *New in Pygments 0.11.*

    `linenostart`
        The line number for the first line (default: ``1``).

    `linenostep`
        If set to a number n > 1, only every nth line number is printed.

    `linenospecial`
        If set to a number n > 0, every nth line number is given the CSS
        class ``"special"`` (default: ``0``).

    `nobackground`
        If set to ``True``, the formatter won't output the background color
        for the wrapping element (this automatically defaults to ``False``
        when there is no wrapping element [eg: no argument for the
        `get_syntax_defs` method given]) (default: ``False``). *New in
        Pygments 0.6.*

    `lineseparator`
        This string is output between lines of code. It defaults to ``"\n"``,
        which is enough to break a line inside ``<pre>`` tags, but you can
        e.g. set it to ``"<br>"`` to get HTML line breaks. *New in Pygments
        0.7.*

    `lineanchors`
        If set to a nonempty string, e.g. ``foo``, the formatter will wrap each
        output line in an anchor tag with a ``name`` of ``foo-linenumber``.
        This allows easy linking to certain lines. *New in Pygments 0.9.*

    `anchorlinenos`
        If set to `True`, will wrap line numbers in <a> tags. Used in
        combination with `linenos` and `lineanchors`.


    **Subclassing the HTML formatter**

    *New in Pygments 0.7.*

    The HTML formatter is now built in a way that allows easy subclassing, thus
    customizing the output HTML code. The `format()` method calls
    `self._format_lines()` which returns a generator that yields tuples of ``(1,
    line)``, where the ``1`` indicates that the ``line`` is a line of the
    formatted source code.

    If the `nowrap` option is set, the generator is the iterated over and the
    resulting HTML is output.

    Otherwise, `format()` calls `self.wrap()`, which wraps the generator with
    other generators. These may add some HTML code to the one generated by
    `_format_lines()`, either by modifying the lines generated by the latter,
    then yielding them again with ``(1, line)``, and/or by yielding other HTML
    code before or after the lines, with ``(0, html)``. The distinction between
    source lines and other code makes it possible to wrap the generator multiple
    times.

    The default `wrap()` implementation adds a ``<div>`` and a ``<pre>`` tag.

    A custom `HtmlFormatter` subclass could look like this:

    .. sourcecode:: python

        class CodeHtmlFormatter(HtmlFormatter):

            def wrap(self, source, outfile):
                return self._wrap_code(source)

            def _wrap_code(self, source):
                yield 0, '<code>'
                for i, t in source:
                    if i == 1:
                        # it's a line of formatted code
                        t += '<br>'
                    yield i, t
                yield 0, '</code>'

    This results in wrapping the formatted lines with a ``<code>`` tag, where the
    source lines are broken using ``<br>`` tags.

    After calling `wrap()`, the `format()` method also adds the "line numbers"
    and/or "full document" wrappers if the respective options are set. Then, all
    HTML yielded by the wrapped generator is output.
    """

    name = 'HTML'
    aliases = ['html']
    filenames = ['*.html', '*.htm']

    def __init__(self, **options):
        Formatter.__init__(self, **options)
        self.title = self._decodeifneeded(self.title)
        self.nowrap = get_bool_opt(options, 'nowrap', False)
        self.noclasses = get_bool_opt(options, 'noclasses', False)
        self.classprefix = options.get('classprefix', '')
        self.cssclass = self._decodeifneeded(options.get('cssclass', 'highlight'))
        self.cssstyles = self._decodeifneeded(options.get('cssstyles', ''))
        self.prestyles = self._decodeifneeded(options.get('prestyles', ''))
        self.cssfile = self._decodeifneeded(options.get('cssfile', ''))
        self.noclobber_cssfile = get_bool_opt(options, 'noclobber_cssfile', False)

        linenos = options.get('linenos', False)
        if linenos == 'inline':
            self.linenos = 2
        elif linenos:
            # compatibility with <= 0.7
            self.linenos = 1
        else:
            self.linenos = 0
        self.linenostart = abs(get_int_opt(options, 'linenostart', 1))
        self.linenostep = abs(get_int_opt(options, 'linenostep', 1))
        self.linenospecial = abs(get_int_opt(options, 'linenospecial', 0))
        self.nobackground = get_bool_opt(options, 'nobackground', False)
        self.lineseparator = options.get('lineseparator', '\n')
        self.lineanchors = options.get('lineanchors', '')
        self.anchorlinenos = options.get('anchorlinenos', False)
        self.hl_lines = set()
        for lineno in get_list_opt(options, 'hl_lines', []):
            try:
                self.hl_lines.add(int(lineno))
            except ValueError:
                pass

        self._class_cache = {}
        self._create_stylesheet()

    def _get_css_class(self, ttype):
        """Return the css class of this token type prefixed with
        the classprefix option."""
        if ttype in self._class_cache:
            return self._class_cache[ttype]
        return self.classprefix + _get_ttype_class(ttype)

    def _create_stylesheet(self):
        t2c = self.ttype2class = {Token: ''}
        c2s = self.class2style = {}
        cp = self.classprefix
        for ttype, ndef in self.style:
            name = cp + _get_ttype_class(ttype)
            style = ''
            if ndef['color']:
                style += 'color: #%s; ' % ndef['color']
            if ndef['bold']:
                style += 'font-weight: bold; '
            if ndef['italic']:
                style += 'font-style: italic; '
            if ndef['underline']:
                style += 'text-decoration: underline; '
            if ndef['bgcolor']:
                style += 'background-color: #%s; ' % ndef['bgcolor']
            if ndef['border']:
                style += 'border: 1px solid #%s; ' % ndef['border']
            if style:
                t2c[ttype] = name
                # save len(ttype) to enable ordering the styles by
                # hierarchy (necessary for CSS cascading rules!)
                c2s[name] = (style[:-2], ttype, len(ttype))

    def get_style_defs(self, arg=None):
        """
        Return CSS style definitions for the classes produced by the current
        highlighting style. ``arg`` can be a string or list of selectors to
        insert before the token type classes.
        """
        if arg is None:
            arg = ('cssclass' in self.options and '.'+self.cssclass or '')
        if isinstance(arg, basestring):
            args = [arg]
        else:
            args = list(arg)

        def prefix(cls):
            if cls:
                cls = '.' + cls
            tmp = []
            for arg in args:
                tmp.append((arg and arg + ' ' or '') + cls)
            return ', '.join(tmp)

        styles = [(level, ttype, cls, style)
                  for cls, (style, ttype, level) in self.class2style.iteritems()
                  if cls and style]
        styles.sort()
        lines = ['%s { %s } /* %s */' % (prefix(cls), style, repr(ttype)[6:])
                 for (level, ttype, cls, style) in styles]
        if arg and not self.nobackground and \
           self.style.background_color is not None:
            text_style = ''
            if Text in self.ttype2class:
                text_style = ' ' + self.class2style[self.ttype2class[Text]][0]
            lines.insert(0, '%s { background: %s;%s }' %
                         (prefix(''), self.style.background_color, text_style))
        if self.style.highlight_color is not None:
            lines.insert(0, '%s.hll { background-color: %s }' %
                         (prefix(''), self.style.highlight_color))
        return '\n'.join(lines)

    def _decodeifneeded(self, value):
        if isinstance(value, bytes):
            if self.encoding:
                return value.decode(self.encoding)
            return value.decode()
        return value

    def _wrap_full(self, inner, outfile):
        if self.cssfile:
            if os.path.isabs(self.cssfile):
                # it's an absolute filename
                cssfilename = self.cssfile
            else:
                try:
                    filename = outfile.name
                    if not filename or filename[0] == '<':
                        # pseudo files, e.g. name == '<fdopen>'
                        raise AttributeError
                    cssfilename = os.path.join(os.path.dirname(filename),
                                               self.cssfile)
                except AttributeError:
                    print >>sys.stderr, 'Note: Cannot determine output file name, ' \
                          'using current directory as base for the CSS file name'
                    cssfilename = self.cssfile
            # write CSS file only if noclobber_cssfile isn't given as an option.
            try:
                if not os.path.exists(cssfilename) or not self.noclobber_cssfile:
                    cf = open(cssfilename, "w")
                    cf.write(CSSFILE_TEMPLATE %
                            {'styledefs': self.get_style_defs('body')})
                    cf.close()
            except IOError, err:
                err.strerror = 'Error writing CSS file: ' + err.strerror
                raise

            yield 0, (DOC_HEADER_EXTERNALCSS %
                      dict(title     = self.title,
                           cssfile   = self.cssfile,
                           encoding  = self.encoding))
        else:
            yield 0, (DOC_HEADER %
                      dict(title     = self.title,
                           styledefs = self.get_style_defs('body'),
                           encoding  = self.encoding))

        for t, line in inner:
            yield t, line
        yield 0, DOC_FOOTER

    def _wrap_tablelinenos(self, inner):
        dummyoutfile = StringIO.StringIO()
        lncount = 0
        for t, line in inner:
            if t:
                lncount += 1
            dummyoutfile.write(line)

        fl = self.linenostart
        mw = len(str(lncount + fl - 1))
        sp = self.linenospecial
        st = self.linenostep
        la = self.lineanchors
        aln = self.anchorlinenos
        if sp:
            lines = []

            for i in range(fl, fl+lncount):
                if i % st == 0:
                    if i % sp == 0:
                        if aln:
                            lines.append('<a href="#%s-%d" class="special">%*d</a>' %
                                         (la, i, mw, i))
                        else:
                            lines.append('<span class="special">%*d</span>' % (mw, i))
                    else:
                        if aln:
                            lines.append('<a href="#%s-%d">%*d</a>' % (la, i, mw, i))
                        else:
                            lines.append('%*d' % (mw, i))
                else:
                    lines.append('')
            ls = '\n'.join(lines)
        else:
            lines = []
            for i in range(fl, fl+lncount):
                if i % st == 0:
                    if aln:
                        lines.append('<a href="#%s-%d">%*d</a>' % (la, i, mw, i))
                    else:
                        lines.append('%*d' % (mw, i))
                else:
                    lines.append('')
            ls = '\n'.join(lines)

        # in case you wonder about the seemingly redundant <div> here: since the
        # content in the other cell also is wrapped in a div, some browsers in
        # some configurations seem to mess up the formatting...
        yield 0, ('<table class="%stable">' % self.cssclass +
                  '<tr><td class="linenos"><div class="linenodiv"><pre>' +
                  ls + '</pre></div></td><td class="code">')
        yield 0, dummyoutfile.getvalue()
        yield 0, '</td></tr></table>'

    def _wrap_inlinelinenos(self, inner):
        # need a list of lines since we need the width of a single number :(
        lines = list(inner)
        sp = self.linenospecial
        st = self.linenostep
        num = self.linenostart
        mw = len(str(len(lines) + num - 1))

        if sp:
            for t, line in lines:
                yield 1, '<span class="lineno%s">%*s</span> ' % (
                    num%sp == 0 and ' special' or '', mw,
                    (num%st and ' ' or num)) + line
                num += 1
        else:
            for t, line in lines:
                yield 1, '<span class="lineno">%*s</span> ' % (
                    mw, (num%st and ' ' or num)) + line
                num += 1

    def _wrap_lineanchors(self, inner):
        s = self.lineanchors
        i = 0
        for t, line in inner:
            if t:
                i += 1
                yield 1, '<a name="%s-%d"></a>' % (s, i) + line
            else:
                yield 0, line

    def _wrap_div(self, inner):
        yield 0, ('<div' + (self.cssclass and ' class="%s"' % self.cssclass)
                  + (self.cssstyles and ' style="%s"' % self.cssstyles) + '>')
        for tup in inner:
            yield tup
        yield 0, '</div>\n'

    def _wrap_pre(self, inner):
        yield 0, ('<pre'
                  + (self.prestyles and ' style="%s"' % self.prestyles) + '>')
        for tup in inner:
            yield tup
        yield 0, '</pre>'

    def _format_lines(self, tokensource):
        """
        Just format the tokens, without any wrapping tags.
        Yield individual lines.
        """
        nocls = self.noclasses
        lsep = self.lineseparator
        # for <span style=""> lookup only
        getcls = self.ttype2class.get
        c2s = self.class2style

        lspan = ''
        line = ''
        for ttype, value in tokensource:
            if nocls:
                cclass = getcls(ttype)
                while cclass is None:
                    ttype = ttype.parent
                    cclass = getcls(ttype)
                cspan = cclass and '<span style="%s">' % c2s[cclass][0] or ''
            else:
                cls = self._get_css_class(ttype)
                cspan = cls and '<span class="%s">' % cls or ''

            parts = escape_html(value).split('\n')

            # for all but the last line
            for part in parts[:-1]:
                if line:
                    if lspan != cspan:
                        line += (lspan and '</span>') + cspan + part + \
                                (cspan and '</span>') + lsep
                    else: # both are the same
                        line += part + (lspan and '</span>') + lsep
                    yield 1, line
                    line = ''
                elif part:
                    yield 1, cspan + part + (cspan and '</span>') + lsep
                else:
                    yield 1, lsep
            # for the last line
            if line and parts[-1]:
                if lspan != cspan:
                    line += (lspan and '</span>') + cspan + parts[-1]
                    lspan = cspan
                else:
                    line += parts[-1]
            elif parts[-1]:
                line = cspan + parts[-1]
                lspan = cspan
            # else we neither have to open a new span nor set lspan

        if line:
            yield 1, line + (lspan and '</span>') + lsep

    def _highlight_lines(self, tokensource):
        """
        Highlighted the lines specified in the `hl_lines` option by
        post-processing the token stream coming from `_format_lines`.
        """
        hls = self.hl_lines

        for i, (t, value) in enumerate(tokensource):
            if t != 1:
                yield t, value
            if i + 1 in hls: # i + 1 because Python indexes start at 0
                yield 1, '<span class="hll">%s</span>' % value
            else:
                yield 1, value

    def wrap(self, source, outfile):
        """
        Wrap the ``source``, which is a generator yielding
        individual lines, in custom generators. See docstring
        for `format`. Can be overridden.
        """
        return self._wrap_div(self._wrap_pre(source))

    def format_unencoded(self, tokensource, outfile):
        """
        The formatting process uses several nested generators; which of
        them are used is determined by the user's options.

        Each generator should take at least one argument, ``inner``,
        and wrap the pieces of text generated by this.

        Always yield 2-tuples: (code, text). If "code" is 1, the text
        is part of the original tokensource being highlighted, if it's
        0, the text is some piece of wrapping. This makes it possible to
        use several different wrappers that process the original source
        linewise, e.g. line number generators.
        """
        source = self._format_lines(tokensource)
        if self.hl_lines:
            source = self._highlight_lines(source)
        if not self.nowrap:
            if self.linenos == 2:
                source = self._wrap_inlinelinenos(source)
            if self.lineanchors:
                source = self._wrap_lineanchors(source)
            source = self.wrap(source, outfile)
            if self.linenos == 1:
                source = self._wrap_tablelinenos(source)
            if self.full:
                source = self._wrap_full(source, outfile)

        for t, piece in source:
            outfile.write(piece)
# -*- coding: utf-8 -*-
"""
    pygments.formatters.img
    ~~~~~~~~~~~~~~~~~~~~~~~

    Formatter for Pixmap output.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import sys
from commands import getstatusoutput

from pygments.formatter import Formatter
from pygments.util import get_bool_opt, get_int_opt, get_choice_opt

# Import this carefully
try:
    import Image, ImageDraw, ImageFont
    pil_available = True
except ImportError:
    pil_available = False

try:
    import _winreg
except ImportError:
    _winreg = None

__all__ = ['ImageFormatter', 'GifImageFormatter', 'JpgImageFormatter',
           'BmpImageFormatter']


# For some unknown reason every font calls it something different
STYLES = {
    'NORMAL':     ['', 'Roman', 'Book', 'Normal', 'Regular', 'Medium'],
    'ITALIC':     ['Oblique', 'Italic'],
    'BOLD':       ['Bold'],
    'BOLDITALIC': ['Bold Oblique', 'Bold Italic'],
}

# A sane default for modern systems
DEFAULT_FONT_NAME_NIX = 'Bitstream Vera Sans Mono'
DEFAULT_FONT_NAME_WIN = 'Courier New'


class PilNotAvailable(ImportError):
    """When Python imaging library is not available"""


class FontNotFound(Exception):
    """When there are no usable fonts specified"""


class FontManager(object):
    """
    Manages a set of fonts: normal, italic, bold, etc...
    """

    def __init__(self, font_name, font_size=14):
        self.font_name = font_name
        self.font_size = font_size
        self.fonts = {}
        self.encoding = None
        if sys.platform.startswith('win'):
            if not font_name:
                self.font_name = DEFAULT_FONT_NAME_WIN
            self._create_win()
        else:
            if not font_name:
                self.font_name = DEFAULT_FONT_NAME_NIX
            self._create_nix()

    def _get_nix_font_path(self, name, style):
        exit, out = getstatusoutput('fc-list "%s:style=%s" file' %
                                    (name, style))
        if not exit:
            lines = out.splitlines()
            if lines:
                path = lines[0].strip().strip(':')
                return path

    def _create_nix(self):
        for name in STYLES['NORMAL']:
            path = self._get_nix_font_path(self.font_name, name)
            if path is not None:
                self.fonts['NORMAL'] = ImageFont.truetype(path, self.font_size)
                break
        else:
            raise FontNotFound('No usable fonts named: "%s"' %
                               self.font_name)
        for style in ('ITALIC', 'BOLD', 'BOLDITALIC'):
            for stylename in STYLES[style]:
                path = self._get_nix_font_path(self.font_name, stylename)
                if path is not None:
                    self.fonts[style] = ImageFont.truetype(path, self.font_size)
                    break
            else:
                if style == 'BOLDITALIC':
                    self.fonts[style] = self.fonts['BOLD']
                else:
                    self.fonts[style] = self.fonts['NORMAL']

    def _lookup_win(self, key, basename, styles, fail=False):
        for suffix in ('', ' (TrueType)'):
            for style in styles:
                try:
                    valname = '%s%s%s' % (basename, style and ' '+style, suffix)
                    val, _ = _winreg.QueryValueEx(key, valname)
                    return val
                except EnvironmentError:
                    continue
        else:
            if fail:
                raise FontNotFound('Font %s (%s) not found in registry' %
                                   (basename, styles[0]))
            return None

    def _create_win(self):
        try:
            key = _winreg.OpenKey(
                _winreg.HKEY_LOCAL_MACHINE,
                r'Software\Microsoft\Windows NT\CurrentVersion\Fonts')
        except EnvironmentError:
            try:
                key = _winreg.OpenKey(
                    _winreg.HKEY_LOCAL_MACHINE,
                    r'Software\Microsoft\Windows\CurrentVersion\Fonts')
            except EnvironmentError:
                raise FontNotFound('Can\'t open Windows font registry key')
        try:
            path = self._lookup_win(key, self.font_name, STYLES['NORMAL'], True)
            self.fonts['NORMAL'] = ImageFont.truetype(path, self.font_size)
            for style in ('ITALIC', 'BOLD', 'BOLDITALIC'):
                path = self._lookup_win(key, self.font_name, STYLES[style])
                if path:
                    self.fonts[style] = ImageFont.truetype(path, self.font_size)
                else:
                    if style == 'BOLDITALIC':
                        self.fonts[style] = self.fonts['BOLD']
                    else:
                        self.fonts[style] = self.fonts['NORMAL']
        finally:
            _winreg.CloseKey(key)

    def get_char_size(self):
        """
        Get the character size.
        """
        return self.fonts['NORMAL'].getsize('M')

    def get_font(self, bold, oblique):
        """
        Get the font based on bold and italic flags.
        """
        if bold and oblique:
            return self.fonts['BOLDITALIC']
        elif bold:
            return self.fonts['BOLD']
        elif oblique:
            return self.fonts['ITALIC']
        else:
            return self.fonts['NORMAL']


class ImageFormatter(Formatter):
    """
    Create a PNG image from source code. This uses the Python Imaging Library to
    generate a pixmap from the source code.

    *New in Pygments 0.10.*

    Additional options accepted:

    `image_format`
        An image format to output to that is recognised by PIL, these include:

        * "PNG" (default)
        * "JPEG"
        * "BMP"
        * "GIF"

    `line_pad`
        The extra spacing (in pixels) between each line of text.

        Default: 2

    `font_name`
        The font name to be used as the base font from which others, such as
        bold and italic fonts will be generated.  This really should be a
        monospace font to look sane.

        Default: "Bitstream Vera Sans Mono"

    `font_size`
        The font size in points to be used.

        Default: 14

    `image_pad`
        The padding, in pixels to be used at each edge of the resulting image.

        Default: 10

    `line_numbers`
        Whether line numbers should be shown: True/False

        Default: True

    `line_number_step`
        The step used when printing line numbers.

        Default: 1

    `line_number_bg`
        The background colour (in "#123456" format) of the line number bar, or
        None to use the style background color.

        Default: "#eed"

    `line_number_fg`
        The text color of the line numbers (in "#123456"-like format).

        Default: "#886"

    `line_number_chars`
        The number of columns of line numbers allowable in the line number
        margin.

        Default: 2

    `line_number_bold`
        Whether line numbers will be bold: True/False

        Default: False

    `line_number_italic`
        Whether line numbers will be italicized: True/False

        Default: False

    `line_number_separator`
        Whether a line will be drawn between the line number area and the
        source code area: True/False

        Default: True

    `line_number_pad`
        The horizontal padding (in pixels) between the line number margin, and
        the source code area.

        Default: 6
    """

    # Required by the pygments mapper
    name = 'img'
    aliases = ['img', 'IMG', 'png']
    filenames = ['*.png']

    unicodeoutput = False

    default_image_format = 'png'

    def __init__(self, **options):
        """
        See the class docstring for explanation of options.
        """
        if not pil_available:
            raise PilNotAvailable(
                'Python Imaging Library is required for this formatter')
        Formatter.__init__(self, **options)
        # Read the style
        self.styles = dict(self.style)
        if self.style.background_color is None:
            self.background_color = '#fff'
        else:
            self.background_color = self.style.background_color
        # Image options
        self.image_format = get_choice_opt(
            options, 'image_format', ['png', 'jpeg', 'gif', 'bmp'],
            self.default_image_format, normcase=True)
        self.image_pad = get_int_opt(options, 'image_pad', 10)
        self.line_pad = get_int_opt(options, 'line_pad', 2)
        # The fonts
        fontsize = get_int_opt(options, 'font_size', 14)
        self.fonts = FontManager(options.get('font_name', ''), fontsize)
        self.fontw, self.fonth = self.fonts.get_char_size()
        # Line number options
        self.line_number_fg = options.get('line_number_fg', '#886')
        self.line_number_bg = options.get('line_number_bg', '#eed')
        self.line_number_chars = get_int_opt(options,
                                        'line_number_chars', 2)
        self.line_number_bold = get_bool_opt(options,
                                        'line_number_bold', False)
        self.line_number_italic = get_bool_opt(options,
                                        'line_number_italic', False)
        self.line_number_pad = get_int_opt(options, 'line_number_pad', 6)
        self.line_numbers = get_bool_opt(options, 'line_numbers', True)
        self.line_number_separator = get_bool_opt(options,
                                        'line_number_separator', True)
        self.line_number_step = get_int_opt(options, 'line_number_step', 1)
        if self.line_numbers:
            self.line_number_width = (self.fontw * self.line_number_chars +
                                   self.line_number_pad * 2)
        else:
            self.line_number_width = 0
        self.drawables = []

    def get_style_defs(self, arg=''):
        raise NotImplementedError('The -S option is meaningless for the image '
                                  'formatter. Use -O style=<stylename> instead.')

    def _get_line_height(self):
        """
        Get the height of a line.
        """
        return self.fonth + self.line_pad

    def _get_line_y(self, lineno):
        """
        Get the Y coordinate of a line number.
        """
        return lineno * self._get_line_height() + self.image_pad

    def _get_char_width(self):
        """
        Get the width of a character.
        """
        return self.fontw

    def _get_char_x(self, charno):
        """
        Get the X coordinate of a character position.
        """
        return charno * self.fontw + self.image_pad + self.line_number_width

    def _get_text_pos(self, charno, lineno):
        """
        Get the actual position for a character and line position.
        """
        return self._get_char_x(charno), self._get_line_y(lineno)

    def _get_linenumber_pos(self, lineno):
        """
        Get the actual position for the start of a line number.
        """
        return (self.image_pad, self._get_line_y(lineno))

    def _get_text_color(self, style):
        """
        Get the correct color for the token from the style.
        """
        if style['color'] is not None:
            fill = '#' + style['color']
        else:
            fill = '#000'
        return fill

    def _get_style_font(self, style):
        """
        Get the correct font for the style.
        """
        return self.fonts.get_font(style['bold'], style['italic'])

    def _get_image_size(self, maxcharno, maxlineno):
        """
        Get the required image size.
        """
        return (self._get_char_x(maxcharno) + self.image_pad,
                self._get_line_y(maxlineno + 0) + self.image_pad)

    def _draw_linenumber(self, lineno):
        """
        Remember a line number drawable to paint later.
        """
        self._draw_text(
            self._get_linenumber_pos(lineno),
            str(lineno + 1).rjust(self.line_number_chars),
            font=self.fonts.get_font(self.line_number_bold,
                                     self.line_number_italic),
            fill=self.line_number_fg,
        )

    def _draw_text(self, pos, text, font, **kw):
        """
        Remember a single drawable tuple to paint later.
        """
        self.drawables.append((pos, text, font, kw))

    def _create_drawables(self, tokensource):
        """
        Create drawables for the token content.
        """
        lineno = charno = maxcharno = 0
        for ttype, value in tokensource:
            while ttype not in self.styles:
                ttype = ttype.parent
            style = self.styles[ttype]
            # TODO: make sure tab expansion happens earlier in the chain.  It
            # really ought to be done on the input, as to do it right here is
            # quite complex.
            value = value.expandtabs(4)
            lines = value.splitlines(True)
            #print lines
            for i, line in enumerate(lines):
                temp = line.rstrip('\n')
                if temp:
                    self._draw_text(
                        self._get_text_pos(charno, lineno),
                        temp,
                        font = self._get_style_font(style),
                        fill = self._get_text_color(style)
                    )
                    charno += len(temp)
                    maxcharno = max(maxcharno, charno)
                if line.endswith('\n'):
                    # add a line for each extra line in the value
                    charno = 0
                    lineno += 1
        self.maxcharno = maxcharno
        self.maxlineno = lineno

    def _draw_line_numbers(self):
        """
        Create drawables for the line numbers.
        """
        if not self.line_numbers:
            return
        for i in xrange(self.maxlineno):
            if ((i + 1) % self.line_number_step) == 0:
                self._draw_linenumber(i)

    def _paint_line_number_bg(self, im):
        """
        Paint the line number background on the image.
        """
        if not self.line_numbers:
            return
        if self.line_number_fg is None:
            return
        draw = ImageDraw.Draw(im)
        recth = im.size[-1]
        rectw = self.image_pad + self.line_number_width - self.line_number_pad
        draw.rectangle([(0, 0),
                        (rectw, recth)],
             fill=self.line_number_bg)
        draw.line([(rectw, 0), (rectw, recth)], fill=self.line_number_fg)
        del draw

    def format(self, tokensource, outfile):
        """
        Format ``tokensource``, an iterable of ``(tokentype, tokenstring)``
        tuples and write it into ``outfile``.

        This implementation calculates where it should draw each token on the
        pixmap, then calculates the required pixmap size and draws the items.
        """
        self._create_drawables(tokensource)
        self._draw_line_numbers()
        im = Image.new(
            'RGB',
            self._get_image_size(self.maxcharno, self.maxlineno),
            self.background_color
        )
        self._paint_line_number_bg(im)
        draw = ImageDraw.Draw(im)
        for pos, value, font, kw in self.drawables:
            draw.text(pos, value, font=font, **kw)
        im.save(outfile, self.image_format.upper())


# Add one formatter per format, so that the "-f gif" option gives the correct result
# when used in pygmentize.

class GifImageFormatter(ImageFormatter):
    """
    Create a GIF image from source code. This uses the Python Imaging Library to
    generate a pixmap from the source code.

    *New in Pygments 1.0.* (You could create GIF images before by passing a
    suitable `image_format` option to the `ImageFormatter`.)
    """

    name = 'img_gif'
    aliases = ['gif']
    filenames = ['*.gif']
    default_image_format = 'gif'


class JpgImageFormatter(ImageFormatter):
    """
    Create a JPEG image from source code. This uses the Python Imaging Library to
    generate a pixmap from the source code.

    *New in Pygments 1.0.* (You could create JPEG images before by passing a
    suitable `image_format` option to the `ImageFormatter`.)
    """

    name = 'img_jpg'
    aliases = ['jpg', 'jpeg']
    filenames = ['*.jpg']
    default_image_format = 'jpeg'


class BmpImageFormatter(ImageFormatter):
    """
    Create a bitmap image from source code. This uses the Python Imaging Library to
    generate a pixmap from the source code.

    *New in Pygments 1.0.* (You could create bitmap images before by passing a
    suitable `image_format` option to the `ImageFormatter`.)
    """

    name = 'img_bmp'
    aliases = ['bmp', 'bitmap']
    filenames = ['*.bmp']
    default_image_format = 'bmp'
# -*- coding: utf-8 -*-
"""
    pygments.formatters.latex
    ~~~~~~~~~~~~~~~~~~~~~~~~~

    Formatter for LaTeX fancyvrb output.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.formatter import Formatter
from pygments.token import Token, STANDARD_TYPES
from pygments.util import get_bool_opt, get_int_opt, StringIO


__all__ = ['LatexFormatter']


def escape_tex(text, commandprefix):
    return text.replace('@', '\x00').    \
                replace('[', '\x01').    \
                replace(']', '\x02').    \
                replace('\x00', '@%sZat[]' % commandprefix).\
                replace('\x01', '@%sZlb[]' % commandprefix).\
                replace('\x02', '@%sZrb[]' % commandprefix)


DOC_TEMPLATE = r'''
\documentclass{%(docclass)s}
\usepackage{fancyvrb}
\usepackage{color}
\usepackage[%(encoding)s]{inputenc}
%(preamble)s

%(styledefs)s

\begin{document}

\section*{%(title)s}

%(code)s
\end{document}
'''

## Small explanation of the mess below :)
#
# The previous version of the LaTeX formatter just assigned a command to
# each token type defined in the current style.  That obviously is
# problematic if the highlighted code is produced for a different style
# than the style commands themselves.
#
# This version works much like the HTML formatter which assigns multiple
# CSS classes to each <span> tag, from the most specific to the least
# specific token type, thus falling back to the parent token type if one
# is not defined.  Here, the classes are there too and use the same short
# forms given in token.STANDARD_TYPES.
#
# Highlighted code now only uses one custom command, which by default is
# \PY and selectable by the commandprefix option (and in addition the
# escapes \PYZat, \PYZlb and \PYZrb which haven't been renamed for
# backwards compatibility purposes).
#
# \PY has two arguments: the classes, separated by +, and the text to
# render in that style.  The classes are resolved into the respective
# style commands by magic, which serves to ignore unknown classes.
#
# The magic macros are:
# * \PY@it, \PY@bf, etc. are unconditionally wrapped around the text
#   to render in \PY@do.  Their definition determines the style.
# * \PY@reset resets \PY@it etc. to do nothing.
# * \PY@toks parses the list of classes, using magic inspired by the
#   keyval package (but modified to use plusses instead of commas
#   because fancyvrb redefines commas inside its environments).
# * \PY@tok processes one class, calling the \PY@tok@classname command
#   if it exists.
# * \PY@tok@classname sets the \PY@it etc. to reflect the chosen style
#   for its class.
# * \PY resets the style, parses the classnames and then calls \PY@do.

STYLE_TEMPLATE = r'''
\makeatletter
\def\%(cp)s@reset{\let\%(cp)s@it=\relax \let\%(cp)s@bf=\relax%%
    \let\%(cp)s@ul=\relax \let\%(cp)s@tc=\relax%%
    \let\%(cp)s@bc=\relax \let\%(cp)s@ff=\relax}
\def\%(cp)s@tok#1{\csname %(cp)s@tok@#1\endcsname}
\def\%(cp)s@toks#1+{\ifx\relax#1\empty\else%%
    \%(cp)s@tok{#1}\expandafter\%(cp)s@toks\fi}
\def\%(cp)s@do#1{\%(cp)s@bc{\%(cp)s@tc{\%(cp)s@ul{%%
    \%(cp)s@it{\%(cp)s@bf{\%(cp)s@ff{#1}}}}}}}
\def\%(cp)s#1#2{\%(cp)s@reset\%(cp)s@toks#1+\relax+\%(cp)s@do{#2}}

%(styles)s

\def\%(cp)sZat{@}
\def\%(cp)sZlb{[}
\def\%(cp)sZrb{]}
\makeatother
'''


def _get_ttype_name(ttype):
    fname = STANDARD_TYPES.get(ttype)
    if fname:
        return fname
    aname = ''
    while fname is None:
        aname = ttype[-1] + aname
        ttype = ttype.parent
        fname = STANDARD_TYPES.get(ttype)
    return fname + aname


class LatexFormatter(Formatter):
    r"""
    Format tokens as LaTeX code. This needs the `fancyvrb` and `color`
    standard packages.

    Without the `full` option, code is formatted as one ``Verbatim``
    environment, like this:

    .. sourcecode:: latex

        \begin{Verbatim}[commandchars=@\[\]]
        @PY[k][def ]@PY[n+nf][foo](@PY[n][bar]):
            @PY[k][pass]
        \end{Verbatim}

    The special command used here (``@PY``) and all the other macros it needs
    are output by the `get_style_defs` method.

    With the `full` option, a complete LaTeX document is output, including
    the command definitions in the preamble.

    The `get_style_defs()` method of a `LatexFormatter` returns a string
    containing ``\def`` commands defining the macros needed inside the
    ``Verbatim`` environments.

    Additional options accepted:

    `style`
        The style to use, can be a string or a Style subclass (default:
        ``'default'``).

    `full`
        Tells the formatter to output a "full" document, i.e. a complete
        self-contained document (default: ``False``).

    `title`
        If `full` is true, the title that should be used to caption the
        document (default: ``''``).

    `docclass`
        If the `full` option is enabled, this is the document class to use
        (default: ``'article'``).

    `preamble`
        If the `full` option is enabled, this can be further preamble commands,
        e.g. ``\usepackage`` (default: ``''``).

    `linenos`
        If set to ``True``, output line numbers (default: ``False``).

    `linenostart`
        The line number for the first line (default: ``1``).

    `linenostep`
        If set to a number n > 1, only every nth line number is printed.

    `verboptions`
        Additional options given to the Verbatim environment (see the *fancyvrb*
        docs for possible values) (default: ``''``).

    `commandprefix`
        The LaTeX commands used to produce colored output are constructed
        using this prefix and some letters (default: ``'PY'``).
        *New in Pygments 0.7.*

        *New in Pygments 0.10:* the default is now ``'PY'`` instead of ``'C'``.
    """
    name = 'LaTeX'
    aliases = ['latex', 'tex']
    filenames = ['*.tex']

    def __init__(self, **options):
        Formatter.__init__(self, **options)
        self.docclass = options.get('docclass', 'article')
        self.preamble = options.get('preamble', '')
        self.linenos = get_bool_opt(options, 'linenos', False)
        self.linenostart = abs(get_int_opt(options, 'linenostart', 1))
        self.linenostep = abs(get_int_opt(options, 'linenostep', 1))
        self.verboptions = options.get('verboptions', '')
        self.nobackground = get_bool_opt(options, 'nobackground', False)
        self.commandprefix = options.get('commandprefix', 'PY')

        self._create_stylesheet()


    def _create_stylesheet(self):
        t2n = self.ttype2name = {Token: ''}
        c2d = self.cmd2def = {}
        cp = self.commandprefix

        def rgbcolor(col):
            if col:
                return ','.join(['%.2f' %(int(col[i] + col[i + 1], 16) / 255.0)
                                 for i in (0, 2, 4)])
            else:
                return '1,1,1'

        for ttype, ndef in self.style:
            name = _get_ttype_name(ttype)
            cmndef = ''
            if ndef['bold']:
                cmndef += r'\let\$$@bf=\textbf'
            if ndef['italic']:
                cmndef += r'\let\$$@it=\textit'
            if ndef['underline']:
                cmndef += r'\let\$$@ul=\underline'
            if ndef['roman']:
                cmndef += r'\let\$$@ff=\textrm'
            if ndef['sans']:
                cmndef += r'\let\$$@ff=\textsf'
            if ndef['mono']:
                cmndef += r'\let\$$@ff=\textsf'
            if ndef['color']:
                cmndef += (r'\def\$$@tc##1{\textcolor[rgb]{%s}{##1}}' %
                           rgbcolor(ndef['color']))
            if ndef['border']:
                cmndef += (r'\def\$$@bc##1{\fcolorbox[rgb]{%s}{%s}{##1}}' %
                           (rgbcolor(ndef['border']),
                            rgbcolor(ndef['bgcolor'])))
            elif ndef['bgcolor']:
                cmndef += (r'\def\$$@bc##1{\colorbox[rgb]{%s}{##1}}' %
                           rgbcolor(ndef['bgcolor']))
            if cmndef == '':
                continue
            cmndef = cmndef.replace('$$', cp)
            t2n[ttype] = name
            c2d[name] = cmndef

    def get_style_defs(self, arg=''):
        """
        Return the command sequences needed to define the commands
        used to format text in the verbatim environment. ``arg`` is ignored.
        """
        cp = self.commandprefix
        styles = []
        for name, definition in self.cmd2def.iteritems():
            styles.append(r'\def\%s@tok@%s{%s}' % (cp, name, definition))
        return STYLE_TEMPLATE % {'cp': self.commandprefix,
                                 'styles': '\n'.join(styles)}

    def format_unencoded(self, tokensource, outfile):
        # TODO: add support for background colors
        t2n = self.ttype2name
        cp = self.commandprefix

        if self.full:
            realoutfile = outfile
            outfile = StringIO()

        outfile.write(r'\begin{Verbatim}[commandchars=@\[\]')
        if self.linenos:
            start, step = self.linenostart, self.linenostep
            outfile.write(',numbers=left' +
                          (start and ',firstnumber=%d' % start or '') +
                          (step and ',stepnumber=%d' % step or ''))
        if self.verboptions:
            outfile.write(',' + self.verboptions)
        outfile.write(']\n')

        for ttype, value in tokensource:
            value = escape_tex(value, self.commandprefix)
            styles = []
            while ttype is not Token:
                try:
                    styles.append(t2n[ttype])
                except KeyError:
                    # not in current style
                    styles.append(_get_ttype_name(ttype))
                ttype = ttype.parent
            styleval = '+'.join(reversed(styles))
            if styleval:
                spl = value.split('\n')
                for line in spl[:-1]:
                    if line:
                        outfile.write("@%s[%s][%s]" % (cp, styleval, line))
                    outfile.write('\n')
                if spl[-1]:
                    outfile.write("@%s[%s][%s]" % (cp, styleval, spl[-1]))
            else:
                outfile.write(value)

        outfile.write('\\end{Verbatim}\n')

        if self.full:
            realoutfile.write(DOC_TEMPLATE %
                dict(docclass  = self.docclass,
                     preamble  = self.preamble,
                     title     = self.title,
                     encoding  = self.encoding or 'latin1',
                     styledefs = self.get_style_defs(),
                     code      = outfile.getvalue()))
# -*- coding: utf-8 -*-
"""
    pygments.formatters.other
    ~~~~~~~~~~~~~~~~~~~~~~~~~

    Other formatters: NullFormatter, RawTokenFormatter.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.formatter import Formatter
from pygments.util import OptionError, get_choice_opt, b
from pygments.token import Token
from pygments.console import colorize

__all__ = ['NullFormatter', 'RawTokenFormatter']


class NullFormatter(Formatter):
    """
    Output the text unchanged without any formatting.
    """
    name = 'Text only'
    aliases = ['text', 'null']
    filenames = ['*.txt']

    def format(self, tokensource, outfile):
        enc = self.encoding
        for ttype, value in tokensource:
            if enc:
                outfile.write(value.encode(enc))
            else:
                outfile.write(value)


class RawTokenFormatter(Formatter):
    r"""
    Format tokens as a raw representation for storing token streams.

    The format is ``tokentype<TAB>repr(tokenstring)\n``. The output can later
    be converted to a token stream with the `RawTokenLexer`, described in the
    `lexer list <lexers.txt>`_.

    Only two options are accepted:

    `compress`
        If set to ``'gz'`` or ``'bz2'``, compress the output with the given
        compression algorithm after encoding (default: ``''``).
    `error_color`
        If set to a color name, highlight error tokens using that color.  If
        set but with no value, defaults to ``'red'``.
        *New in Pygments 0.11.*

    """
    name = 'Raw tokens'
    aliases = ['raw', 'tokens']
    filenames = ['*.raw']

    unicodeoutput = False

    def __init__(self, **options):
        Formatter.__init__(self, **options)
        if self.encoding:
            raise OptionError('the raw formatter does not support the '
                              'encoding option')
        self.encoding = 'ascii'  # let pygments.format() do the right thing
        self.compress = get_choice_opt(options, 'compress',
                                       ['', 'none', 'gz', 'bz2'], '')
        self.error_color = options.get('error_color', None)
        if self.error_color is True:
            self.error_color = 'red'
        if self.error_color is not None:
            try:
                colorize(self.error_color, '')
            except KeyError:
                raise ValueError("Invalid color %r specified" %
                                 self.error_color)

    def format(self, tokensource, outfile):
        try:
            outfile.write(b(''))
        except TypeError:
            raise TypeError('The raw tokens formatter needs a binary '
                            'output file')
        if self.compress == 'gz':
            import gzip
            outfile = gzip.GzipFile('', 'wb', 9, outfile)
            def write(text):
                outfile.write(text.encode())
            flush = outfile.flush
        elif self.compress == 'bz2':
            import bz2
            compressor = bz2.BZ2Compressor(9)
            def write(text):
                outfile.write(compressor.compress(text.encode()))
            def flush():
                outfile.write(compressor.flush())
                outfile.flush()
        else:
            def write(text):
                outfile.write(text.encode())
            flush = outfile.flush

        lasttype = None
        lastval = u''
        if self.error_color:
            for ttype, value in tokensource:
                line = "%s\t%r\n" % (ttype, value)
                if ttype is Token.Error:
                    write(colorize(self.error_color, line))
                else:
                    write(line)
        else:
            for ttype, value in tokensource:
                write("%s\t%r\n" % (ttype, value))
        flush()
# -*- coding: utf-8 -*-
"""
    pygments.formatters.rtf
    ~~~~~~~~~~~~~~~~~~~~~~~

    A formatter that generates RTF files.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.formatter import Formatter


__all__ = ['RtfFormatter']


class RtfFormatter(Formatter):
    """
    Format tokens as RTF markup. This formatter automatically outputs full RTF
    documents with color information and other useful stuff. Perfect for Copy and
    Paste into Microsoft® Word® documents.

    *New in Pygments 0.6.*

    Additional options accepted:

    `style`
        The style to use, can be a string or a Style subclass (default:
        ``'default'``).

    `fontface`
        The used font famliy, for example ``Bitstream Vera Sans``. Defaults to
        some generic font which is supposed to have fixed width.
    """
    name = 'RTF'
    aliases = ['rtf']
    filenames = ['*.rtf']

    unicodeoutput = False

    def __init__(self, **options):
        """
        Additional options accepted:

        ``fontface``
            Name of the font used. Could for example be ``'Courier New'``
            to further specify the default which is ``'\fmodern'``. The RTF
            specification claims that ``\fmodern`` are "Fixed-pitch serif
            and sans serif fonts". Hope every RTF implementation thinks
            the same about modern...
        """
        Formatter.__init__(self, **options)
        self.fontface = options.get('fontface') or ''

    def _escape(self, text):
        return text.replace('\\', '\\\\') \
                   .replace('{', '\\{') \
                   .replace('}', '\\}')

    def _escape_text(self, text):
        # empty strings, should give a small performance improvment
        if not text:
            return ''

        # escape text
        text = self._escape(text)
        if self.encoding in ('utf-8', 'utf-16', 'utf-32'):
            encoding = 'iso-8859-15'
        else:
            encoding = self.encoding or 'iso-8859-15'

        buf = []
        for c in text:
            if ord(c) > 128:
                ansic = c.encode(encoding, 'ignore') or '?'
                if ord(ansic) > 128:
                    ansic = '\\\'%x' % ord(ansic)
                else:
                    ansic = c
                buf.append(r'\ud{\u%d%s}' % (ord(c), ansic))
            else:
                buf.append(str(c))

        return ''.join(buf).replace('\n', '\\par\n')

    def format_unencoded(self, tokensource, outfile):
        # rtf 1.8 header
        outfile.write(r'{\rtf1\ansi\deff0'
                      r'{\fonttbl{\f0\fmodern\fprq1\fcharset0%s;}}'
                      r'{\colortbl;' % (self.fontface and
                                        ' ' + self._escape(self.fontface) or
                                        ''))

        # convert colors and save them in a mapping to access them later.
        color_mapping = {}
        offset = 1
        for _, style in self.style:
            for color in style['color'], style['bgcolor'], style['border']:
                if color and color not in color_mapping:
                    color_mapping[color] = offset
                    outfile.write(r'\red%d\green%d\blue%d;' % (
                        int(color[0:2], 16),
                        int(color[2:4], 16),
                        int(color[4:6], 16)
                    ))
                    offset += 1
        outfile.write(r'}\f0')

        # highlight stream
        for ttype, value in tokensource:
            while not self.style.styles_token(ttype) and ttype.parent:
                ttype = ttype.parent
            style = self.style.style_for_token(ttype)
            buf = []
            if style['bgcolor']:
                buf.append(r'\cb%d' % color_mapping[style['bgcolor']])
            if style['color']:
                buf.append(r'\cf%d' % color_mapping[style['color']])
            if style['bold']:
                buf.append(r'\b')
            if style['italic']:
                buf.append(r'\i')
            if style['underline']:
                buf.append(r'\ul')
            if style['border']:
                buf.append(r'\chbrdr\chcfpat%d' %
                           color_mapping[style['border']])
            start = ''.join(buf)
            if start:
                outfile.write('{%s ' % start)
            outfile.write(self._escape_text(value))
            if start:
                outfile.write('}')

        outfile.write('}')
# -*- coding: utf-8 -*-
"""
    pygments.formatters.svg
    ~~~~~~~~~~~~~~~~~~~~~~~

    Formatter for SVG output.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.formatter import Formatter
from pygments.util import get_bool_opt, get_int_opt

__all__ = ['SvgFormatter']


def escape_html(text):
    """Escape &, <, > as well as single and double quotes for HTML."""
    return text.replace('&', '&amp;').  \
                replace('<', '&lt;').   \
                replace('>', '&gt;').   \
                replace('"', '&quot;'). \
                replace("'", '&#39;')


class2style = {}

class SvgFormatter(Formatter):
    """
    Format tokens as an SVG graphics file.  This formatter is still experimental.
    Each line of code is a ``<text>`` element with explicit ``x`` and ``y``
    coordinates containing ``<tspan>`` elements with the individual token styles.

    By default, this formatter outputs a full SVG document including doctype
    declaration and the ``<svg>`` root element.

    *New in Pygments 0.9.*

    Additional options accepted:

    `nowrap`
        Don't wrap the SVG ``<text>`` elements in ``<svg><g>`` elements and
        don't add a XML declaration and a doctype.  If true, the `fontfamily`
        and `fontsize` options are ignored.  Defaults to ``False``.

    `fontfamily`
        The value to give the wrapping ``<g>`` element's ``font-family``
        attribute, defaults to ``"monospace"``.

    `fontsize`
        The value to give the wrapping ``<g>`` element's ``font-size``
        attribute, defaults to ``"14px"``.

    `xoffset`
        Starting offset in X direction, defaults to ``0``.

    `yoffset`
        Starting offset in Y direction, defaults to the font size if it is given
        in pixels, or ``20`` else.  (This is necessary since text coordinates
        refer to the text baseline, not the top edge.)

    `ystep`
        Offset to add to the Y coordinate for each subsequent line.  This should
        roughly be the text size plus 5.  It defaults to that value if the text
        size is given in pixels, or ``25`` else.

    `spacehack`
        Convert spaces in the source to ``&160;``, which are non-breaking
        spaces.  SVG provides the ``xml:space`` attribute to control how
        whitespace inside tags is handled, in theory, the ``preserve`` value
        could be used to keep all whitespace as-is.  However, many current SVG
        viewers don't obey that rule, so this option is provided as a workaround
        and defaults to ``True``.
    """
    name = 'SVG'
    aliases = ['svg']
    filenames = ['*.svg']

    def __init__(self, **options):
        # XXX outencoding
        Formatter.__init__(self, **options)
        self.nowrap = get_bool_opt(options, 'nowrap', False)
        self.fontfamily = options.get('fontfamily', 'monospace')
        self.fontsize = options.get('fontsize', '14px')
        self.xoffset = get_int_opt(options, 'xoffset', 0)
        fs = self.fontsize.strip()
        if fs.endswith('px'): fs = fs[:-2].strip()
        try:
            int_fs = int(fs)
        except:
            int_fs = 20
        self.yoffset = get_int_opt(options, 'yoffset', int_fs)
        self.ystep = get_int_opt(options, 'ystep', int_fs + 5)
        self.spacehack = get_bool_opt(options, 'spacehack', True)
        self._stylecache = {}

    def format_unencoded(self, tokensource, outfile):
        """
        Format ``tokensource``, an iterable of ``(tokentype, tokenstring)``
        tuples and write it into ``outfile``.

        For our implementation we put all lines in their own 'line group'.
        """
        x = self.xoffset
        y = self.yoffset
        if not self.nowrap:
            if self.encoding:
                outfile.write('<?xml version="1.0" encoding="%s"?>\n' %
                              self.encoding)
            else:
                outfile.write('<?xml version="1.0"?>\n')
            outfile.write('<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" '
                          '"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/'
                          'svg10.dtd">\n')
            outfile.write('<svg xmlns="http://www.w3.org/2000/svg">\n')
            outfile.write('<g font-family="%s" font-size="%s">\n' %
                          (self.fontfamily, self.fontsize))
        outfile.write('<text x="%s" y="%s" xml:space="preserve">' % (x, y))
        for ttype, value in tokensource:
            style = self._get_style(ttype)
            tspan = style and '<tspan' + style + '>' or ''
            tspanend = tspan and '</tspan>' or ''
            value = escape_html(value)
            if self.spacehack:
                value = value.expandtabs().replace(' ', '&#160;')
            parts = value.split('\n')
            for part in parts[:-1]:
                outfile.write(tspan + part + tspanend)
                y += self.ystep
                outfile.write('</text>\n<text x="%s" y="%s" '
                              'xml:space="preserve">' % (x, y))
            outfile.write(tspan + parts[-1] + tspanend)
        outfile.write('</text>')

        if not self.nowrap:
            outfile.write('</g></svg>\n')

    def _get_style(self, tokentype):
        if tokentype in self._stylecache:
            return self._stylecache[tokentype]
        otokentype = tokentype
        while not self.style.styles_token(tokentype):
            tokentype = tokentype.parent
        value = self.style.style_for_token(tokentype)
        result = ''
        if value['color']:
            result = ' fill="#' + value['color'] + '"'
        if value['bold']:
            result += ' font-weight="bold"'
        if value['italic']:
            result += ' font-style="italic"'
        self._stylecache[otokentype] = result
        return result
# -*- coding: utf-8 -*-
"""
    pygments.formatters.terminal
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Formatter for terminal output with ANSI sequences.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.formatter import Formatter
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Token, Whitespace
from pygments.console import ansiformat
from pygments.util import get_choice_opt


__all__ = ['TerminalFormatter']


#: Map token types to a tuple of color values for light and dark
#: backgrounds.
TERMINAL_COLORS = {
    Token:              ('',            ''),

    Whitespace:         ('lightgray',   'darkgray'),
    Comment:            ('lightgray',   'darkgray'),
    Comment.Preproc:    ('teal',        'turquoise'),
    Keyword:            ('darkblue',    'blue'),
    Keyword.Type:       ('teal',        'turquoise'),
    Operator.Word:      ('purple',      'fuchsia'),
    Name.Builtin:       ('teal',        'turquoise'),
    Name.Function:      ('darkgreen',   'green'),
    Name.Namespace:     ('_teal_',      '_turquoise_'),
    Name.Class:         ('_darkgreen_', '_green_'),
    Name.Exception:     ('teal',        'turquoise'),
    Name.Decorator:     ('darkgray',    'lightgray'),
    Name.Variable:      ('darkred',     'red'),
    Name.Constant:      ('darkred',     'red'),
    Name.Attribute:     ('teal',        'turquoise'),
    Name.Tag:           ('blue',        'blue'),
    String:             ('brown',       'brown'),
    Number:             ('darkblue',    'blue'),

    Generic.Deleted:    ('red',        'red'),
    Generic.Inserted:   ('darkgreen',  'green'),
    Generic.Heading:    ('**',         '**'),
    Generic.Subheading: ('*purple*',   '*fuchsia*'),
    Generic.Error:      ('red',        'red'),

    Error:              ('_red_',      '_red_'),
}


class TerminalFormatter(Formatter):
    r"""
    Format tokens with ANSI color sequences, for output in a text console.
    Color sequences are terminated at newlines, so that paging the output
    works correctly.

    The `get_style_defs()` method doesn't do anything special since there is
    no support for common styles.

    Options accepted:

    `bg`
        Set to ``"light"`` or ``"dark"`` depending on the terminal's background
        (default: ``"light"``).

    `colorscheme`
        A dictionary mapping token types to (lightbg, darkbg) color names or
        ``None`` (default: ``None`` = use builtin colorscheme).
    """
    name = 'Terminal'
    aliases = ['terminal', 'console']
    filenames = []

    def __init__(self, **options):
        Formatter.__init__(self, **options)
        self.darkbg = get_choice_opt(options, 'bg',
                                     ['light', 'dark'], 'light') == 'dark'
        self.colorscheme = options.get('colorscheme', None) or TERMINAL_COLORS

    def format(self, tokensource, outfile):
        # hack: if the output is a terminal and has an encoding set,
        # use that to avoid unicode encode problems
        if not self.encoding and hasattr(outfile, "encoding") and \
           hasattr(outfile, "isatty") and outfile.isatty():
            self.encoding = outfile.encoding
        return Formatter.format(self, tokensource, outfile)

    def format_unencoded(self, tokensource, outfile):
        for ttype, value in tokensource:
            color = self.colorscheme.get(ttype)
            while color is None:
                ttype = ttype[:-1]
                color = self.colorscheme.get(ttype)
            if color:
                color = color[self.darkbg]
                spl = value.split('\n')
                for line in spl[:-1]:
                    if line:
                        outfile.write(ansiformat(color, line))
                    outfile.write('\n')
                if spl[-1]:
                    outfile.write(ansiformat(color, spl[-1]))
            else:
                outfile.write(value)
# -*- coding: utf-8 -*-
"""
    pygments.formatters.terminal256
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Formatter for 256-color terminal output with ANSI sequences.

    RGB-to-XTERM color conversion routines adapted from xterm256-conv
    tool (http://frexx.de/xterm-256-notes/data/xterm256-conv2.tar.bz2)
    by Wolfgang Frisch.

    Formatter version 1.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

# TODO:
#  - Options to map style's bold/underline/italic/border attributes
#    to some ANSI attrbutes (something like 'italic=underline')
#  - An option to output "style RGB to xterm RGB/index" conversion table
#  - An option to indicate that we are running in "reverse background"
#    xterm. This means that default colors are white-on-black, not
#    black-on-while, so colors like "white background" need to be converted
#    to "white background, black foreground", etc...

from pygments.formatter import Formatter


__all__ = ['Terminal256Formatter']


class EscapeSequence:
    def __init__(self, fg=None, bg=None, bold=False, underline=False):
        self.fg = fg
        self.bg = bg
        self.bold = bold
        self.underline = underline

    def escape(self, attrs):
        if len(attrs):
            return "\x1b[" + ";".join(attrs) + "m"
        return ""

    def color_string(self):
        attrs = []
        if self.fg is not None:
            attrs.extend(("38", "5", "%i" % self.fg))
        if self.bg is not None:
            attrs.extend(("48", "5", "%i" % self.bg))
        if self.bold:
            attrs.append("01")
        if self.underline:
            attrs.append("04")
        return self.escape(attrs)

    def reset_string(self):
        attrs = []
        if self.fg is not None:
            attrs.append("39")
        if self.bg is not None:
            attrs.append("49")
        if self.bold or self.underline:
            attrs.append("00")
        return self.escape(attrs)

class Terminal256Formatter(Formatter):
    r"""
    Format tokens with ANSI color sequences, for output in a 256-color
    terminal or console. Like in `TerminalFormatter` color sequences
    are terminated at newlines, so that paging the output works correctly.

    The formatter takes colors from a style defined by the `style` option
    and converts them to nearest ANSI 256-color escape sequences. Bold and
    underline attributes from the style are preserved (and displayed).

    *New in Pygments 0.9.*

    Options accepted:

    `style`
        The style to use, can be a string or a Style subclass (default:
        ``'default'``).
    """
    name = 'Terminal256'
    aliases = ['terminal256', 'console256', '256']
    filenames = []

    def __init__(self, **options):
        Formatter.__init__(self, **options)

        self.xterm_colors = []
        self.best_match = {}
        self.style_string = {}

        self.usebold = 'nobold' not in options
        self.useunderline = 'nounderline' not in options

        self._build_color_table() # build an RGB-to-256 color conversion table
        self._setup_styles() # convert selected style's colors to term. colors

    def _build_color_table(self):
        # colors 0..15: 16 basic colors

        self.xterm_colors.append((0x00, 0x00, 0x00)) # 0
        self.xterm_colors.append((0xcd, 0x00, 0x00)) # 1
        self.xterm_colors.append((0x00, 0xcd, 0x00)) # 2
        self.xterm_colors.append((0xcd, 0xcd, 0x00)) # 3
        self.xterm_colors.append((0x00, 0x00, 0xee)) # 4
        self.xterm_colors.append((0xcd, 0x00, 0xcd)) # 5
        self.xterm_colors.append((0x00, 0xcd, 0xcd)) # 6
        self.xterm_colors.append((0xe5, 0xe5, 0xe5)) # 7
        self.xterm_colors.append((0x7f, 0x7f, 0x7f)) # 8
        self.xterm_colors.append((0xff, 0x00, 0x00)) # 9
        self.xterm_colors.append((0x00, 0xff, 0x00)) # 10
        self.xterm_colors.append((0xff, 0xff, 0x00)) # 11
        self.xterm_colors.append((0x5c, 0x5c, 0xff)) # 12
        self.xterm_colors.append((0xff, 0x00, 0xff)) # 13
        self.xterm_colors.append((0x00, 0xff, 0xff)) # 14
        self.xterm_colors.append((0xff, 0xff, 0xff)) # 15

        # colors 16..232: the 6x6x6 color cube

        valuerange = (0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff)

        for i in range(217):
            r = valuerange[(i // 36) % 6]
            g = valuerange[(i // 6) % 6]
            b = valuerange[i % 6]
            self.xterm_colors.append((r, g, b))

        # colors 233..253: grayscale

        for i in range(1, 22):
            v = 8 + i * 10
            self.xterm_colors.append((v, v, v))

    def _closest_color(self, r, g, b):
        distance = 257*257*3 # "infinity" (>distance from #000000 to #ffffff)
        match = 0

        for i in range(0, 254):
            values = self.xterm_colors[i]

            rd = r - values[0]
            gd = g - values[1]
            bd = b - values[2]
            d = rd*rd + gd*gd + bd*bd

            if d < distance:
                match = i
                distance = d
        return match

    def _color_index(self, color):
        index = self.best_match.get(color, None)
        if index is None:
            try:
                rgb = int(str(color), 16)
            except ValueError:
                rgb = 0

            r = (rgb >> 16) & 0xff
            g = (rgb >> 8) & 0xff
            b = rgb & 0xff
            index = self._closest_color(r, g, b)
            self.best_match[color] = index
        return index

    def _setup_styles(self):
        for ttype, ndef in self.style:
            escape = EscapeSequence()
            if ndef['color']:
                escape.fg = self._color_index(ndef['color'])
            if ndef['bgcolor']:
                escape.bg = self._color_index(ndef['bgcolor'])
            if self.usebold and ndef['bold']:
                escape.bold = True
            if self.useunderline and ndef['underline']:
                escape.underline = True
            self.style_string[str(ttype)] = (escape.color_string(),
                                             escape.reset_string())

    def format(self, tokensource, outfile):
        # hack: if the output is a terminal and has an encoding set,
        # use that to avoid unicode encode problems
        if not self.encoding and hasattr(outfile, "encoding") and \
           hasattr(outfile, "isatty") and outfile.isatty():
            self.encoding = outfile.encoding
        return Formatter.format(self, tokensource, outfile)

    def format_unencoded(self, tokensource, outfile):
        for ttype, value in tokensource:
            not_found = True
            while ttype and not_found:
                try:
                    #outfile.write( "<" + str(ttype) + ">" )
                    on, off = self.style_string[str(ttype)]

                    # Like TerminalFormatter, add "reset colors" escape sequence
                    # on newline.
                    spl = value.split('\n')
                    for line in spl[:-1]:
                        if line:
                            outfile.write(on + line + off)
                        outfile.write('\n')
                    if spl[-1]:
                        outfile.write(on + spl[-1] + off)

                    not_found = False
                    #outfile.write( '#' + str(ttype) + '#' )

                except KeyError:
                    #ottype = ttype
                    ttype = ttype[:-1]
                    #outfile.write( '!' + str(ottype) + '->' + str(ttype) + '!' )

            if not_found:
                outfile.write(value)
# -*- coding: utf-8 -*-
"""
    pygments.lexer
    ~~~~~~~~~~~~~~

    Base lexer classes.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import re

try:
    set
except NameError:
    from sets import Set as set

from pygments.filter import apply_filters, Filter
from pygments.filters import get_filter_by_name
from pygments.token import Error, Text, Other, _TokenType
from pygments.util import get_bool_opt, get_int_opt, get_list_opt, \
     make_analysator


__all__ = ['Lexer', 'RegexLexer', 'ExtendedRegexLexer', 'DelegatingLexer',
           'LexerContext', 'include', 'flags', 'bygroups', 'using', 'this']


_default_analyse = staticmethod(lambda x: 0.0)


class LexerMeta(type):
    """
    This metaclass automagically converts ``analyse_text`` methods into
    static methods which always return float values.
    """

    def __new__(cls, name, bases, d):
        if 'analyse_text' in d:
            d['analyse_text'] = make_analysator(d['analyse_text'])
        return type.__new__(cls, name, bases, d)


class Lexer(object):
    """
    Lexer for a specific language.

    Basic options recognized:
    ``stripnl``
        Strip leading and trailing newlines from the input (default: True).
    ``stripall``
        Strip all leading and trailing whitespace from the input
        (default: False).
    ``tabsize``
        If given and greater than 0, expand tabs in the input (default: 0).
    ``encoding``
        If given, must be an encoding name. This encoding will be used to
        convert the input string to Unicode, if it is not already a Unicode
        string (default: ``'latin1'``).
        Can also be ``'guess'`` to use a simple UTF-8 / Latin1 detection, or
        ``'chardet'`` to use the chardet library, if it is installed.
    """

    #: Name of the lexer
    name = None

    #: Shortcuts for the lexer
    aliases = []

    #: fn match rules
    filenames = []

    #: fn alias filenames
    alias_filenames = []

    #: mime types
    mimetypes = []

    __metaclass__ = LexerMeta

    def __init__(self, **options):
        self.options = options
        self.stripnl = get_bool_opt(options, 'stripnl', True)
        self.stripall = get_bool_opt(options, 'stripall', False)
        self.tabsize = get_int_opt(options, 'tabsize', 0)
        self.encoding = options.get('encoding', 'latin1')
        # self.encoding = options.get('inencoding', None) or self.encoding
        self.filters = []
        for filter_ in get_list_opt(options, 'filters', ()):
            self.add_filter(filter_)

    def __repr__(self):
        if self.options:
            return '<pygments.lexers.%s with %r>' % (self.__class__.__name__,
                                                     self.options)
        else:
            return '<pygments.lexers.%s>' % self.__class__.__name__

    def add_filter(self, filter_, **options):
        """
        Add a new stream filter to this lexer.
        """
        if not isinstance(filter_, Filter):
            filter_ = get_filter_by_name(filter_, **options)
        self.filters.append(filter_)

    def analyse_text(text):
        """
        Has to return a float between ``0`` and ``1`` that indicates
        if a lexer wants to highlight this text. Used by ``guess_lexer``.
        If this method returns ``0`` it won't highlight it in any case, if
        it returns ``1`` highlighting with this lexer is guaranteed.

        The `LexerMeta` metaclass automatically wraps this function so
        that it works like a static method (no ``self`` or ``cls``
        parameter) and the return value is automatically converted to
        `float`. If the return value is an object that is boolean `False`
        it's the same as if the return values was ``0.0``.
        """

    def get_tokens(self, text, unfiltered=False):
        """
        Return an iterable of (tokentype, value) pairs generated from
        `text`. If `unfiltered` is set to `True`, the filtering mechanism
        is bypassed even if filters are defined.

        Also preprocess the text, i.e. expand tabs and strip it if
        wanted and applies registered filters.
        """
        if not isinstance(text, unicode):
            if self.encoding == 'guess':
                try:
                    text = text.decode('utf-8')
                    if text.startswith(u'\ufeff'):
                        text = text[len(u'\ufeff'):]
                except UnicodeDecodeError:
                    text = text.decode('latin1')
            elif self.encoding == 'chardet':
                try:
                    import chardet
                except ImportError:
                    raise ImportError('To enable chardet encoding guessing, '
                                      'please install the chardet library '
                                      'from http://chardet.feedparser.org/')
                enc = chardet.detect(text)
                text = text.decode(enc['encoding'])
            else:
                text = text.decode(self.encoding)
        # text now *is* a unicode string
        text = text.replace('\r\n', '\n')
        text = text.replace('\r', '\n')
        if self.stripall:
            text = text.strip()
        elif self.stripnl:
            text = text.strip('\n')
        if self.tabsize > 0:
            text = text.expandtabs(self.tabsize)
        if not text.endswith('\n'):
            text += '\n'

        def streamer():
            for i, t, v in self.get_tokens_unprocessed(text):
                yield t, v
        stream = streamer()
        if not unfiltered:
            stream = apply_filters(stream, self.filters, self)
        return stream

    def get_tokens_unprocessed(self, text):
        """
        Return an iterable of (tokentype, value) pairs.
        In subclasses, implement this method as a generator to
        maximize effectiveness.
        """
        raise NotImplementedError


class DelegatingLexer(Lexer):
    """
    This lexer takes two lexer as arguments. A root lexer and
    a language lexer. First everything is scanned using the language
    lexer, afterwards all ``Other`` tokens are lexed using the root
    lexer.

    The lexers from the ``template`` lexer package use this base lexer.
    """

    def __init__(self, _root_lexer, _language_lexer, _needle=Other, **options):
        self.root_lexer = _root_lexer(**options)
        self.language_lexer = _language_lexer(**options)
        self.needle = _needle
        Lexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        buffered = ''
        insertions = []
        lng_buffer = []
        for i, t, v in self.language_lexer.get_tokens_unprocessed(text):
            if t is self.needle:
                if lng_buffer:
                    insertions.append((len(buffered), lng_buffer))
                    lng_buffer = []
                buffered += v
            else:
                lng_buffer.append((i, t, v))
        if lng_buffer:
            insertions.append((len(buffered), lng_buffer))
        return do_insertions(insertions,
                             self.root_lexer.get_tokens_unprocessed(buffered))


#-------------------------------------------------------------------------------
# RegexLexer and ExtendedRegexLexer
#


class include(str):
    """
    Indicates that a state should include rules from another state.
    """
    pass


class combined(tuple):
    """
    Indicates a state combined from multiple states.
    """

    def __new__(cls, *args):
        return tuple.__new__(cls, args)

    def __init__(self, *args):
        # tuple.__init__ doesn't do anything
        pass


class _PseudoMatch(object):
    """
    A pseudo match object constructed from a string.
    """

    def __init__(self, start, text):
        self._text = text
        self._start = start

    def start(self, arg=None):
        return self._start

    def end(self, arg=None):
        return self._start + len(self._text)

    def group(self, arg=None):
        if arg:
            raise IndexError('No such group')
        return self._text

    def groups(self):
        return (self._text,)

    def groupdict(self):
        return {}


def bygroups(*args):
    """
    Callback that yields multiple actions for each group in the match.
    """
    def callback(lexer, match, ctx=None):
        for i, action in enumerate(args):
            if action is None:
                continue
            elif type(action) is _TokenType:
                data = match.group(i + 1)
                if data:
                    yield match.start(i + 1), action, data
            else:
                if ctx:
                    ctx.pos = match.start(i + 1)
                for item in action(lexer, _PseudoMatch(match.start(i + 1),
                                   match.group(i + 1)), ctx):
                    if item:
                        yield item
        if ctx:
            ctx.pos = match.end()
    return callback


class _This(object):
    """
    Special singleton used for indicating the caller class.
    Used by ``using``.
    """
this = _This()


def using(_other, **kwargs):
    """
    Callback that processes the match with a different lexer.

    The keyword arguments are forwarded to the lexer, except `state` which
    is handled separately.

    `state` specifies the state that the new lexer will start in, and can
    be an enumerable such as ('root', 'inline', 'string') or a simple
    string which is assumed to be on top of the root state.

    Note: For that to work, `_other` must not be an `ExtendedRegexLexer`.
    """
    gt_kwargs = {}
    if 'state' in kwargs:
        s = kwargs.pop('state')
        if isinstance(s, (list, tuple)):
            gt_kwargs['stack'] = s
        else:
            gt_kwargs['stack'] = ('root', s)

    if _other is this:
        def callback(lexer, match, ctx=None):
            # if keyword arguments are given the callback
            # function has to create a new lexer instance
            if kwargs:
                # XXX: cache that somehow
                kwargs.update(lexer.options)
                lx = lexer.__class__(**kwargs)
            else:
                lx = lexer
            s = match.start()
            for i, t, v in lx.get_tokens_unprocessed(match.group(), **gt_kwargs):
                yield i + s, t, v
            if ctx:
                ctx.pos = match.end()
    else:
        def callback(lexer, match, ctx=None):
            # XXX: cache that somehow
            kwargs.update(lexer.options)
            lx = _other(**kwargs)

            s = match.start()
            for i, t, v in lx.get_tokens_unprocessed(match.group(), **gt_kwargs):
                yield i + s, t, v
            if ctx:
                ctx.pos = match.end()
    return callback


class RegexLexerMeta(LexerMeta):
    """
    Metaclass for RegexLexer, creates the self._tokens attribute from
    self.tokens on the first instantiation.
    """

    def _process_state(cls, unprocessed, processed, state):
        assert type(state) is str, "wrong state name %r" % state
        assert state[0] != '#', "invalid state name %r" % state
        if state in processed:
            return processed[state]
        tokens = processed[state] = []
        rflags = cls.flags
        for tdef in unprocessed[state]:
            if isinstance(tdef, include):
                # it's a state reference
                assert tdef != state, "circular state reference %r" % state
                tokens.extend(cls._process_state(unprocessed, processed, str(tdef)))
                continue

            assert type(tdef) is tuple, "wrong rule def %r" % tdef

            try:
                rex = re.compile(tdef[0], rflags).match
            except Exception, err:
                raise ValueError("uncompilable regex %r in state %r of %r: %s" %
                                 (tdef[0], state, cls, err))

            assert type(tdef[1]) is _TokenType or callable(tdef[1]), \
                   'token type must be simple type or callable, not %r' % (tdef[1],)

            if len(tdef) == 2:
                new_state = None
            else:
                tdef2 = tdef[2]
                if isinstance(tdef2, str):
                    # an existing state
                    if tdef2 == '#pop':
                        new_state = -1
                    elif tdef2 in unprocessed:
                        new_state = (tdef2,)
                    elif tdef2 == '#push':
                        new_state = tdef2
                    elif tdef2[:5] == '#pop:':
                        new_state = -int(tdef2[5:])
                    else:
                        assert False, 'unknown new state %r' % tdef2
                elif isinstance(tdef2, combined):
                    # combine a new state from existing ones
                    new_state = '_tmp_%d' % cls._tmpname
                    cls._tmpname += 1
                    itokens = []
                    for istate in tdef2:
                        assert istate != state, 'circular state ref %r' % istate
                        itokens.extend(cls._process_state(unprocessed,
                                                          processed, istate))
                    processed[new_state] = itokens
                    new_state = (new_state,)
                elif isinstance(tdef2, tuple):
                    # push more than one state
                    for state in tdef2:
                        assert (state in unprocessed or
                                state in ('#pop', '#push')), \
                               'unknown new state ' + state
                    new_state = tdef2
                else:
                    assert False, 'unknown new state def %r' % tdef2
            tokens.append((rex, tdef[1], new_state))
        return tokens

    def process_tokendef(cls, name, tokendefs=None):
        processed = cls._all_tokens[name] = {}
        tokendefs = tokendefs or cls.tokens[name]
        for state in tokendefs.keys():
            cls._process_state(tokendefs, processed, state)
        return processed

    def __call__(cls, *args, **kwds):
        if not hasattr(cls, '_tokens'):
            cls._all_tokens = {}
            cls._tmpname = 0
            if hasattr(cls, 'token_variants') and cls.token_variants:
                # don't process yet
                pass
            else:
                cls._tokens = cls.process_tokendef('', cls.tokens)

        return type.__call__(cls, *args, **kwds)


class RegexLexer(Lexer):
    """
    Base for simple stateful regular expression-based lexers.
    Simplifies the lexing process so that you need only
    provide a list of states and regular expressions.
    """
    __metaclass__ = RegexLexerMeta

    #: Flags for compiling the regular expressions.
    #: Defaults to MULTILINE.
    flags = re.MULTILINE

    #: Dict of ``{'state': [(regex, tokentype, new_state), ...], ...}``
    #:
    #: The initial state is 'root'.
    #: ``new_state`` can be omitted to signify no state transition.
    #: If it is a string, the state is pushed on the stack and changed.
    #: If it is a tuple of strings, all states are pushed on the stack and
    #: the current state will be the topmost.
    #: It can also be ``combined('state1', 'state2', ...)``
    #: to signify a new, anonymous state combined from the rules of two
    #: or more existing ones.
    #: Furthermore, it can be '#pop' to signify going back one step in
    #: the state stack, or '#push' to push the current state on the stack
    #: again.
    #:
    #: The tuple can also be replaced with ``include('state')``, in which
    #: case the rules from the state named by the string are included in the
    #: current one.
    tokens = {}

    def get_tokens_unprocessed(self, text, stack=('root',)):
        """
        Split ``text`` into (tokentype, text) pairs.

        ``stack`` is the inital stack (default: ``['root']``)
        """
        pos = 0
        tokendefs = self._tokens
        statestack = list(stack)
        statetokens = tokendefs[statestack[-1]]
        while 1:
            for rexmatch, action, new_state in statetokens:
                m = rexmatch(text, pos)
                if m:
                    if type(action) is _TokenType:
                        yield pos, action, m.group()
                    else:
                        for item in action(self, m):
                            yield item
                    pos = m.end()
                    if new_state is not None:
                        # state transition
                        if isinstance(new_state, tuple):
                            for state in new_state:
                                if state == '#pop':
                                    statestack.pop()
                                elif state == '#push':
                                    statestack.append(statestack[-1])
                                else:
                                    statestack.append(state)
                        elif isinstance(new_state, int):
                            # pop
                            del statestack[new_state:]
                        elif new_state == '#push':
                            statestack.append(statestack[-1])
                        else:
                            assert False, "wrong state def: %r" % new_state
                        statetokens = tokendefs[statestack[-1]]
                    break
            else:
                try:
                    if text[pos] == '\n':
                        # at EOL, reset state to "root"
                        pos += 1
                        statestack = ['root']
                        statetokens = tokendefs['root']
                        yield pos, Text, u'\n'
                        continue
                    yield pos, Error, text[pos]
                    pos += 1
                except IndexError:
                    break


class LexerContext(object):
    """
    A helper object that holds lexer position data.
    """

    def __init__(self, text, pos, stack=None, end=None):
        self.text = text
        self.pos = pos
        self.end = end or len(text) # end=0 not supported ;-)
        self.stack = stack or ['root']

    def __repr__(self):
        return 'LexerContext(%r, %r, %r)' % (
            self.text, self.pos, self.stack)


class ExtendedRegexLexer(RegexLexer):
    """
    A RegexLexer that uses a context object to store its state.
    """

    def get_tokens_unprocessed(self, text=None, context=None):
        """
        Split ``text`` into (tokentype, text) pairs.
        If ``context`` is given, use this lexer context instead.
        """
        tokendefs = self._tokens
        if not context:
            ctx = LexerContext(text, 0)
            statetokens = tokendefs['root']
        else:
            ctx = context
            statetokens = tokendefs[ctx.stack[-1]]
            text = ctx.text
        while 1:
            for rexmatch, action, new_state in statetokens:
                m = rexmatch(text, ctx.pos, ctx.end)
                if m:
                    if type(action) is _TokenType:
                        yield ctx.pos, action, m.group()
                        ctx.pos = m.end()
                    else:
                        for item in action(self, m, ctx):
                            yield item
                        if not new_state:
                            # altered the state stack?
                            statetokens = tokendefs[ctx.stack[-1]]
                    # CAUTION: callback must set ctx.pos!
                    if new_state is not None:
                        # state transition
                        if isinstance(new_state, tuple):
                            ctx.stack.extend(new_state)
                        elif isinstance(new_state, int):
                            # pop
                            del ctx.stack[new_state:]
                        elif new_state == '#push':
                            ctx.stack.append(ctx.stack[-1])
                        else:
                            assert False, "wrong state def: %r" % new_state
                        statetokens = tokendefs[ctx.stack[-1]]
                    break
            else:
                try:
                    if ctx.pos >= ctx.end:
                        break
                    if text[ctx.pos] == '\n':
                        # at EOL, reset state to "root"
                        ctx.pos += 1
                        ctx.stack = ['root']
                        statetokens = tokendefs['root']
                        yield ctx.pos, Text, u'\n'
                        continue
                    yield ctx.pos, Error, text[ctx.pos]
                    ctx.pos += 1
                except IndexError:
                    break


def do_insertions(insertions, tokens):
    """
    Helper for lexers which must combine the results of several
    sublexers.

    ``insertions`` is a list of ``(index, itokens)`` pairs.
    Each ``itokens`` iterable should be inserted at position
    ``index`` into the token stream given by the ``tokens``
    argument.

    The result is a combined token stream.

    TODO: clean up the code here.
    """
    insertions = iter(insertions)
    try:
        index, itokens = insertions.next()
    except StopIteration:
        # no insertions
        for item in tokens:
            yield item
        return

    realpos = None
    insleft = True

    # iterate over the token stream where we want to insert
    # the tokens from the insertion list.
    for i, t, v in tokens:
        # first iteration. store the postition of first item
        if realpos is None:
            realpos = i
        oldi = 0
        while insleft and i + len(v) >= index:
            tmpval = v[oldi:index - i]
            yield realpos, t, tmpval
            realpos += len(tmpval)
            for it_index, it_token, it_value in itokens:
                yield realpos, it_token, it_value
                realpos += len(it_value)
            oldi = index - i
            try:
                index, itokens = insertions.next()
            except StopIteration:
                insleft = False
                break  # not strictly necessary
        yield realpos, t, v[oldi:]
        realpos += len(v) - oldi

    # leftover tokens
    if insleft:
        # no normal tokens, set realpos to zero
        realpos = realpos or 0
        for p, t, v in itokens:
            yield realpos, t, v
            realpos += len(v)
# -*- coding: utf-8 -*-
"""
    pygments.lexers
    ~~~~~~~~~~~~~~~

    Pygments lexers.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import sys
import fnmatch
import types
from os.path import basename

try:
    set
except NameError:
    from sets import Set as set

from pygments.lexers._mapping import LEXERS
from pygments.plugin import find_plugin_lexers
from pygments.util import ClassNotFound, bytes


__all__ = ['get_lexer_by_name', 'get_lexer_for_filename', 'find_lexer_class',
           'guess_lexer'] + LEXERS.keys()

_lexer_cache = {}


def _load_lexers(module_name):
    """
    Load a lexer (and all others in the module too).
    """
    mod = __import__(module_name, None, None, ['__all__'])
    for lexer_name in mod.__all__:
        cls = getattr(mod, lexer_name)
        _lexer_cache[cls.name] = cls


def get_all_lexers():
    """
    Return a generator of tuples in the form ``(name, aliases,
    filenames, mimetypes)`` of all know lexers.
    """
    for item in LEXERS.itervalues():
        yield item[1:]
    for lexer in find_plugin_lexers():
        yield lexer.name, lexer.aliases, lexer.filenames, lexer.mimetypes


def find_lexer_class(name):
    """
    Lookup a lexer class by name. Return None if not found.
    """
    if name in _lexer_cache:
        return _lexer_cache[name]
    # lookup builtin lexers
    for module_name, lname, aliases, _, _ in LEXERS.itervalues():
        if name == lname:
            _load_lexers(module_name)
            return _lexer_cache[name]
    # continue with lexers from setuptools entrypoints
    for cls in find_plugin_lexers():
        if cls.name == name:
            return cls


def get_lexer_by_name(_alias, **options):
    """
    Get a lexer by an alias.
    """
    # lookup builtin lexers
    for module_name, name, aliases, _, _ in LEXERS.itervalues():
        if _alias in aliases:
            if name not in _lexer_cache:
                _load_lexers(module_name)
            return _lexer_cache[name](**options)
    # continue with lexers from setuptools entrypoints
    for cls in find_plugin_lexers():
        if _alias in cls.aliases:
            return cls(**options)
    raise ClassNotFound('no lexer for alias %r found' % _alias)


def get_lexer_for_filename(_fn, code=None, **options):
    """
    Get a lexer for a filename.  If multiple lexers match the filename
    pattern, use ``analyze_text()`` to figure out which one is more
    appropriate.
    """
    matches = []
    fn = basename(_fn)
    for modname, name, _, filenames, _ in LEXERS.itervalues():
        for filename in filenames:
            if fnmatch.fnmatch(fn, filename):
                if name not in _lexer_cache:
                    _load_lexers(modname)
                matches.append(_lexer_cache[name])
    for cls in find_plugin_lexers():
        for filename in cls.filenames:
            if fnmatch.fnmatch(fn, filename):
                matches.append(cls)

    if sys.version_info > (3,) and isinstance(code, bytes):
        # decode it, since all analyse_text functions expect unicode
        code = code.decode('latin1')

    def get_rating(cls):
        # The class _always_ defines analyse_text because it's included in
        # the Lexer class.  The default implementation returns None which
        # gets turned into 0.0.  Run scripts/detect_missing_analyse_text.py
        # to find lexers which need it overridden.
        d = cls.analyse_text(code)
        #print "Got %r from %r" % (d, cls)
        return d

    if code:
        matches.sort(key=get_rating)
    if matches:
        #print "Possible lexers, after sort:", matches
        return matches[-1](**options)
    raise ClassNotFound('no lexer for filename %r found' % _fn)


def get_lexer_for_mimetype(_mime, **options):
    """
    Get a lexer for a mimetype.
    """
    for modname, name, _, _, mimetypes in LEXERS.itervalues():
        if _mime in mimetypes:
            if name not in _lexer_cache:
                _load_lexers(modname)
            return _lexer_cache[name](**options)
    for cls in find_plugin_lexers():
        if _mime in cls.mimetypes:
            return cls(**options)
    raise ClassNotFound('no lexer for mimetype %r found' % _mime)


def _iter_lexerclasses():
    """
    Return an iterator over all lexer classes.
    """
    for module_name, name, _, _, _ in LEXERS.itervalues():
        if name not in _lexer_cache:
            _load_lexers(module_name)
        yield _lexer_cache[name]
    for lexer in find_plugin_lexers():
        yield lexer


def guess_lexer_for_filename(_fn, _text, **options):
    """
    Lookup all lexers that handle those filenames primary (``filenames``)
    or secondary (``alias_filenames``). Then run a text analysis for those
    lexers and choose the best result.

    usage::

        >>> from pygments.lexers import guess_lexer_for_filename
        >>> guess_lexer_for_filename('hello.html', '<%= @foo %>')
        <pygments.lexers.templates.RhtmlLexer object at 0xb7d2f32c>
        >>> guess_lexer_for_filename('hello.html', '<h1>{{ title|e }}</h1>')
        <pygments.lexers.templates.HtmlDjangoLexer object at 0xb7d2f2ac>
        >>> guess_lexer_for_filename('style.css', 'a { color: <?= $link ?> }')
        <pygments.lexers.templates.CssPhpLexer object at 0xb7ba518c>
    """
    fn = basename(_fn)
    primary = None
    matching_lexers = set()
    for lexer in _iter_lexerclasses():
        for filename in lexer.filenames:
            if fnmatch.fnmatch(fn, filename):
                matching_lexers.add(lexer)
                primary = lexer
        for filename in lexer.alias_filenames:
            if fnmatch.fnmatch(fn, filename):
                matching_lexers.add(lexer)
    if not matching_lexers:
        raise ClassNotFound('no lexer for filename %r found' % fn)
    if len(matching_lexers) == 1:
        return matching_lexers.pop()(**options)
    result = []
    for lexer in matching_lexers:
        rv = lexer.analyse_text(_text)
        if rv == 1.0:
            return lexer(**options)
        result.append((rv, lexer))
    result.sort()
    if not result[-1][0] and primary is not None:
        return primary(**options)
    return result[-1][1](**options)


def guess_lexer(_text, **options):
    """
    Guess a lexer by strong distinctions in the text (eg, shebang).
    """
    best_lexer = [0.0, None]
    for lexer in _iter_lexerclasses():
        rv = lexer.analyse_text(_text)
        if rv == 1.0:
            return lexer(**options)
        if rv > best_lexer[0]:
            best_lexer[:] = (rv, lexer)
    if not best_lexer[0] or best_lexer[1] is None:
        raise ClassNotFound('no lexer matching the text found')
    return best_lexer[1](**options)


class _automodule(types.ModuleType):
    """Automatically import lexers."""

    def __getattr__(self, name):
        info = LEXERS.get(name)
        if info:
            _load_lexers(info[0])
            cls = _lexer_cache[info[1]]
            setattr(self, name, cls)
            return cls
        raise AttributeError(name)


import sys
oldmod = sys.modules['pygments.lexers']
newmod = _automodule('pygments.lexers')
newmod.__dict__.update(oldmod.__dict__)
sys.modules['pygments.lexers'] = newmod
del newmod.newmod, newmod.oldmod, newmod.sys, newmod.types
# -*- coding: utf-8 -*-
"""
    pygments.lexers._clbuiltins
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ANSI Common Lisp builtins.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

BUILTIN_FUNCTIONS = [ # 638 functions
    '<', '<=', '=', '>', '>=', '-', '/', '/=', '*', '+', '1-', '1+',
    'abort', 'abs', 'acons', 'acos', 'acosh', 'add-method', 'adjoin',
    'adjustable-array-p', 'adjust-array', 'allocate-instance',
    'alpha-char-p', 'alphanumericp', 'append', 'apply', 'apropos',
    'apropos-list', 'aref', 'arithmetic-error-operands',
    'arithmetic-error-operation', 'array-dimension', 'array-dimensions',
    'array-displacement', 'array-element-type', 'array-has-fill-pointer-p',
    'array-in-bounds-p', 'arrayp', 'array-rank', 'array-row-major-index',
    'array-total-size', 'ash', 'asin', 'asinh', 'assoc', 'assoc-if',
    'assoc-if-not', 'atan', 'atanh', 'atom', 'bit', 'bit-and', 'bit-andc1',
    'bit-andc2', 'bit-eqv', 'bit-ior', 'bit-nand', 'bit-nor', 'bit-not',
    'bit-orc1', 'bit-orc2', 'bit-vector-p', 'bit-xor', 'boole',
    'both-case-p', 'boundp', 'break', 'broadcast-stream-streams',
    'butlast', 'byte', 'byte-position', 'byte-size', 'caaaar', 'caaadr',
    'caaar', 'caadar', 'caaddr', 'caadr', 'caar', 'cadaar', 'cadadr',
    'cadar', 'caddar', 'cadddr', 'caddr', 'cadr', 'call-next-method', 'car',
    'cdaaar', 'cdaadr', 'cdaar', 'cdadar', 'cdaddr', 'cdadr', 'cdar',
    'cddaar', 'cddadr', 'cddar', 'cdddar', 'cddddr', 'cdddr', 'cddr', 'cdr',
    'ceiling', 'cell-error-name', 'cerror', 'change-class', 'char', 'char<',
    'char<=', 'char=', 'char>', 'char>=', 'char/=', 'character',
    'characterp', 'char-code', 'char-downcase', 'char-equal',
    'char-greaterp', 'char-int', 'char-lessp', 'char-name',
    'char-not-equal', 'char-not-greaterp', 'char-not-lessp', 'char-upcase',
    'cis', 'class-name', 'class-of', 'clear-input', 'clear-output',
    'close', 'clrhash', 'code-char', 'coerce', 'compile',
    'compiled-function-p', 'compile-file', 'compile-file-pathname',
    'compiler-macro-function', 'complement', 'complex', 'complexp',
    'compute-applicable-methods', 'compute-restarts', 'concatenate',
    'concatenated-stream-streams', 'conjugate', 'cons', 'consp',
    'constantly', 'constantp', 'continue', 'copy-alist', 'copy-list',
    'copy-pprint-dispatch', 'copy-readtable', 'copy-seq', 'copy-structure',
    'copy-symbol', 'copy-tree', 'cos', 'cosh', 'count', 'count-if',
    'count-if-not', 'decode-float', 'decode-universal-time', 'delete',
    'delete-duplicates', 'delete-file', 'delete-if', 'delete-if-not',
    'delete-package', 'denominator', 'deposit-field', 'describe',
    'describe-object', 'digit-char', 'digit-char-p', 'directory',
    'directory-namestring', 'disassemble', 'documentation', 'dpb',
    'dribble', 'echo-stream-input-stream', 'echo-stream-output-stream',
    'ed', 'eighth', 'elt', 'encode-universal-time', 'endp',
    'enough-namestring', 'ensure-directories-exist',
    'ensure-generic-function', 'eq', 'eql', 'equal', 'equalp', 'error',
    'eval', 'evenp', 'every', 'exp', 'export', 'expt', 'fboundp',
    'fceiling', 'fdefinition', 'ffloor', 'fifth', 'file-author',
    'file-error-pathname', 'file-length', 'file-namestring',
    'file-position', 'file-string-length', 'file-write-date',
    'fill', 'fill-pointer', 'find', 'find-all-symbols', 'find-class',
    'find-if', 'find-if-not', 'find-method', 'find-package', 'find-restart',
    'find-symbol', 'finish-output', 'first', 'float', 'float-digits',
    'floatp', 'float-precision', 'float-radix', 'float-sign', 'floor',
    'fmakunbound', 'force-output', 'format', 'fourth', 'fresh-line',
    'fround', 'ftruncate', 'funcall', 'function-keywords',
    'function-lambda-expression', 'functionp', 'gcd', 'gensym', 'gentemp',
    'get', 'get-decoded-time', 'get-dispatch-macro-character', 'getf',
    'gethash', 'get-internal-real-time', 'get-internal-run-time',
    'get-macro-character', 'get-output-stream-string', 'get-properties',
    'get-setf-expansion', 'get-universal-time', 'graphic-char-p',
    'hash-table-count', 'hash-table-p', 'hash-table-rehash-size',
    'hash-table-rehash-threshold', 'hash-table-size', 'hash-table-test',
    'host-namestring', 'identity', 'imagpart', 'import',
    'initialize-instance', 'input-stream-p', 'inspect',
    'integer-decode-float', 'integer-length', 'integerp',
    'interactive-stream-p', 'intern', 'intersection',
    'invalid-method-error', 'invoke-debugger', 'invoke-restart',
    'invoke-restart-interactively', 'isqrt', 'keywordp', 'last', 'lcm',
    'ldb', 'ldb-test', 'ldiff', 'length', 'lisp-implementation-type',
    'lisp-implementation-version', 'list', 'list*', 'list-all-packages',
    'listen', 'list-length', 'listp', 'load',
    'load-logical-pathname-translations', 'log', 'logand', 'logandc1',
    'logandc2', 'logbitp', 'logcount', 'logeqv', 'logical-pathname',
    'logical-pathname-translations', 'logior', 'lognand', 'lognor',
    'lognot', 'logorc1', 'logorc2', 'logtest', 'logxor', 'long-site-name',
    'lower-case-p', 'machine-instance', 'machine-type', 'machine-version',
    'macroexpand', 'macroexpand-1', 'macro-function', 'make-array',
    'make-broadcast-stream', 'make-concatenated-stream', 'make-condition',
    'make-dispatch-macro-character', 'make-echo-stream', 'make-hash-table',
    'make-instance', 'make-instances-obsolete', 'make-list',
    'make-load-form', 'make-load-form-saving-slots', 'make-package',
    'make-pathname', 'make-random-state', 'make-sequence', 'make-string',
    'make-string-input-stream', 'make-string-output-stream', 'make-symbol',
    'make-synonym-stream', 'make-two-way-stream', 'makunbound', 'map',
    'mapc', 'mapcan', 'mapcar', 'mapcon', 'maphash', 'map-into', 'mapl',
    'maplist', 'mask-field', 'max', 'member', 'member-if', 'member-if-not',
    'merge', 'merge-pathnames', 'method-combination-error',
    'method-qualifiers', 'min', 'minusp', 'mismatch', 'mod',
    'muffle-warning', 'name-char', 'namestring', 'nbutlast', 'nconc',
    'next-method-p', 'nintersection', 'ninth', 'no-applicable-method',
    'no-next-method', 'not', 'notany', 'notevery', 'nreconc', 'nreverse',
    'nset-difference', 'nset-exclusive-or', 'nstring-capitalize',
    'nstring-downcase', 'nstring-upcase', 'nsublis', 'nsubst', 'nsubst-if',
    'nsubst-if-not', 'nsubstitute', 'nsubstitute-if', 'nsubstitute-if-not',
    'nth', 'nthcdr', 'null', 'numberp', 'numerator', 'nunion', 'oddp',
    'open', 'open-stream-p', 'output-stream-p', 'package-error-package',
    'package-name', 'package-nicknames', 'packagep',
    'package-shadowing-symbols', 'package-used-by-list', 'package-use-list',
    'pairlis', 'parse-integer', 'parse-namestring', 'pathname',
    'pathname-device', 'pathname-directory', 'pathname-host',
    'pathname-match-p', 'pathname-name', 'pathnamep', 'pathname-type',
    'pathname-version', 'peek-char', 'phase', 'plusp', 'position',
    'position-if', 'position-if-not', 'pprint', 'pprint-dispatch',
    'pprint-fill', 'pprint-indent', 'pprint-linear', 'pprint-newline',
    'pprint-tab', 'pprint-tabular', 'prin1', 'prin1-to-string', 'princ',
    'princ-to-string', 'print', 'print-object', 'probe-file', 'proclaim',
    'provide', 'random', 'random-state-p', 'rassoc', 'rassoc-if',
    'rassoc-if-not', 'rational', 'rationalize', 'rationalp', 'read',
    'read-byte', 'read-char', 'read-char-no-hang', 'read-delimited-list',
    'read-from-string', 'read-line', 'read-preserving-whitespace',
    'read-sequence', 'readtable-case', 'readtablep', 'realp', 'realpart',
    'reduce', 'reinitialize-instance', 'rem', 'remhash', 'remove',
    'remove-duplicates', 'remove-if', 'remove-if-not', 'remove-method',
    'remprop', 'rename-file', 'rename-package', 'replace', 'require',
    'rest', 'restart-name', 'revappend', 'reverse', 'room', 'round',
    'row-major-aref', 'rplaca', 'rplacd', 'sbit', 'scale-float', 'schar',
    'search', 'second', 'set', 'set-difference',
    'set-dispatch-macro-character', 'set-exclusive-or',
    'set-macro-character', 'set-pprint-dispatch', 'set-syntax-from-char',
    'seventh', 'shadow', 'shadowing-import', 'shared-initialize',
    'short-site-name', 'signal', 'signum', 'simple-bit-vector-p',
    'simple-condition-format-arguments', 'simple-condition-format-control',
    'simple-string-p', 'simple-vector-p', 'sin', 'sinh', 'sixth', 'sleep',
    'slot-boundp', 'slot-exists-p', 'slot-makunbound', 'slot-missing',
    'slot-unbound', 'slot-value', 'software-type', 'software-version',
    'some', 'sort', 'special-operator-p', 'sqrt', 'stable-sort',
    'standard-char-p', 'store-value', 'stream-element-type',
    'stream-error-stream', 'stream-external-format', 'streamp', 'string',
    'string<', 'string<=', 'string=', 'string>', 'string>=', 'string/=',
    'string-capitalize', 'string-downcase', 'string-equal',
    'string-greaterp', 'string-left-trim', 'string-lessp',
    'string-not-equal', 'string-not-greaterp', 'string-not-lessp',
    'stringp', 'string-right-trim', 'string-trim', 'string-upcase',
    'sublis', 'subseq', 'subsetp', 'subst', 'subst-if', 'subst-if-not',
    'substitute', 'substitute-if', 'substitute-if-not', 'subtypep','svref',
    'sxhash', 'symbol-function', 'symbol-name', 'symbolp', 'symbol-package',
    'symbol-plist', 'symbol-value', 'synonym-stream-symbol', 'syntax:',
    'tailp', 'tan', 'tanh', 'tenth', 'terpri', 'third',
    'translate-logical-pathname', 'translate-pathname', 'tree-equal',
    'truename', 'truncate', 'two-way-stream-input-stream',
    'two-way-stream-output-stream', 'type-error-datum',
    'type-error-expected-type', 'type-of', 'typep', 'unbound-slot-instance',
    'unexport', 'unintern', 'union', 'unread-char', 'unuse-package',
    'update-instance-for-different-class',
    'update-instance-for-redefined-class', 'upgraded-array-element-type',
    'upgraded-complex-part-type', 'upper-case-p', 'use-package',
    'user-homedir-pathname', 'use-value', 'values', 'values-list', 'vector',
    'vectorp', 'vector-pop', 'vector-push', 'vector-push-extend', 'warn',
    'wild-pathname-p', 'write', 'write-byte', 'write-char', 'write-line',
    'write-sequence', 'write-string', 'write-to-string', 'yes-or-no-p',
    'y-or-n-p', 'zerop',
]

SPECIAL_FORMS = [
    'block', 'catch', 'declare', 'eval-when', 'flet', 'function', 'go', 'if',
    'labels', 'lambda', 'let', 'let*', 'load-time-value', 'locally', 'macrolet',
    'multiple-value-call', 'multiple-value-prog1', 'progn', 'progv', 'quote',
    'return-from', 'setq', 'symbol-macrolet', 'tagbody', 'the', 'throw',
    'unwind-protect',
]

MACROS = [
    'and', 'assert', 'call-method', 'case', 'ccase', 'check-type', 'cond',
    'ctypecase', 'decf', 'declaim', 'defclass', 'defconstant', 'defgeneric',
    'define-compiler-macro', 'define-condition', 'define-method-combination',
    'define-modify-macro', 'define-setf-expander', 'define-symbol-macro',
    'defmacro', 'defmethod', 'defpackage', 'defparameter', 'defsetf',
    'defstruct', 'deftype', 'defun', 'defvar', 'destructuring-bind', 'do',
    'do*', 'do-all-symbols', 'do-external-symbols', 'dolist', 'do-symbols',
    'dotimes', 'ecase', 'etypecase', 'formatter', 'handler-bind',
    'handler-case', 'ignore-errors', 'incf', 'in-package', 'lambda', 'loop',
    'loop-finish', 'make-method', 'multiple-value-bind', 'multiple-value-list',
    'multiple-value-setq', 'nth-value', 'or', 'pop',
    'pprint-exit-if-list-exhausted', 'pprint-logical-block', 'pprint-pop',
    'print-unreadable-object', 'prog', 'prog*', 'prog1', 'prog2', 'psetf',
    'psetq', 'push', 'pushnew', 'remf', 'restart-bind', 'restart-case',
    'return', 'rotatef', 'setf', 'shiftf', 'step', 'time', 'trace', 'typecase',
    'unless', 'untrace', 'when', 'with-accessors', 'with-compilation-unit',
    'with-condition-restarts', 'with-hash-table-iterator',
    'with-input-from-string', 'with-open-file', 'with-open-stream',
    'with-output-to-string', 'with-package-iterator', 'with-simple-restart',
    'with-slots', 'with-standard-io-syntax',
]

LAMBDA_LIST_KEYWORDS = [
    '&allow-other-keys', '&aux', '&body', '&environment', '&key', '&optional',
    '&rest', '&whole',
]

DECLARATIONS = [
    'dynamic-extent', 'ignore', 'optimize', 'ftype', 'inline', 'special',
    'ignorable', 'notinline', 'type',
]

BUILTIN_TYPES = [
    'atom', 'boolean', 'base-char', 'base-string', 'bignum', 'bit',
    'compiled-function', 'extended-char', 'fixnum', 'keyword', 'nil',
    'signed-byte', 'short-float', 'single-float', 'double-float', 'long-float',
    'simple-array', 'simple-base-string', 'simple-bit-vector', 'simple-string',
    'simple-vector', 'standard-char', 'unsigned-byte',

    # Condition Types
    'arithmetic-error', 'cell-error', 'condition', 'control-error',
    'division-by-zero', 'end-of-file', 'error', 'file-error',
    'floating-point-inexact', 'floating-point-overflow',
    'floating-point-underflow', 'floating-point-invalid-operation',
    'parse-error', 'package-error', 'print-not-readable', 'program-error',
    'reader-error', 'serious-condition', 'simple-condition', 'simple-error',
    'simple-type-error', 'simple-warning', 'stream-error', 'storage-condition',
    'style-warning', 'type-error', 'unbound-variable', 'unbound-slot',
    'undefined-function', 'warning',
]

BUILTIN_CLASSES = [
    'array', 'broadcast-stream', 'bit-vector', 'built-in-class', 'character',
    'class', 'complex', 'concatenated-stream', 'cons', 'echo-stream',
    'file-stream', 'float', 'function', 'generic-function', 'hash-table',
    'integer', 'list', 'logical-pathname', 'method-combination', 'method',
    'null', 'number', 'package', 'pathname', 'ratio', 'rational', 'readtable',
    'real', 'random-state', 'restart', 'sequence', 'standard-class',
    'standard-generic-function', 'standard-method', 'standard-object',
    'string-stream', 'stream', 'string', 'structure-class', 'structure-object',
    'symbol', 'synonym-stream', 't', 'two-way-stream', 'vector',
]
# -*- coding: utf-8 -*-
"""
    pygments.lexers._luabuiltins
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    This file contains the names and modules of lua functions
    It is able to re-generate itself, but for adding new functions you
    probably have to add some callbacks (see function module_callbacks).

    Do not edit the MODULES dict by hand.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

MODULES = {'basic': ['_G',
           '_VERSION',
           'assert',
           'collectgarbage',
           'dofile',
           'error',
           'getfenv',
           'getmetatable',
           'ipairs',
           'load',
           'loadfile',
           'loadstring',
           'next',
           'pairs',
           'pcall',
           'print',
           'rawequal',
           'rawget',
           'rawset',
           'select',
           'setfenv',
           'setmetatable',
           'tonumber',
           'tostring',
           'type',
           'unpack',
           'xpcall'],
 'coroutine': ['coroutine.create',
               'coroutine.resume',
               'coroutine.running',
               'coroutine.status',
               'coroutine.wrap',
               'coroutine.yield'],
 'debug': ['debug.debug',
           'debug.getfenv',
           'debug.gethook',
           'debug.getinfo',
           'debug.getlocal',
           'debug.getmetatable',
           'debug.getregistry',
           'debug.getupvalue',
           'debug.setfenv',
           'debug.sethook',
           'debug.setlocal',
           'debug.setmetatable',
           'debug.setupvalue',
           'debug.traceback'],
 'io': ['file:close',
        'file:flush',
        'file:lines',
        'file:read',
        'file:seek',
        'file:setvbuf',
        'file:write',
        'io.close',
        'io.flush',
        'io.input',
        'io.lines',
        'io.open',
        'io.output',
        'io.popen',
        'io.read',
        'io.tmpfile',
        'io.type',
        'io.write'],
 'math': ['math.abs',
          'math.acos',
          'math.asin',
          'math.atan2',
          'math.atan',
          'math.ceil',
          'math.cosh',
          'math.cos',
          'math.deg',
          'math.exp',
          'math.floor',
          'math.fmod',
          'math.frexp',
          'math.huge',
          'math.ldexp',
          'math.log10',
          'math.log',
          'math.max',
          'math.min',
          'math.modf',
          'math.pi',
          'math.pow',
          'math.rad',
          'math.random',
          'math.randomseed',
          'math.sinh',
          'math.sin',
          'math.sqrt',
          'math.tanh',
          'math.tan'],
 'modules': ['module',
             'require',
             'package.cpath',
             'package.loaded',
             'package.loadlib',
             'package.path',
             'package.preload',
             'package.seeall'],
 'os': ['os.clock',
        'os.date',
        'os.difftime',
        'os.execute',
        'os.exit',
        'os.getenv',
        'os.remove',
        'os.rename',
        'os.setlocale',
        'os.time',
        'os.tmpname'],
 'string': ['string.byte',
            'string.char',
            'string.dump',
            'string.find',
            'string.format',
            'string.gmatch',
            'string.gsub',
            'string.len',
            'string.lower',
            'string.match',
            'string.rep',
            'string.reverse',
            'string.sub',
            'string.upper'],
 'table': ['table.concat',
           'table.insert',
           'table.maxn',
           'table.remove',
           'table.sort']}

if __name__ == '__main__':
    import re
    import urllib
    import pprint

    # you can't generally find out what module a function belongs to if you
    # have only its name. Because of this, here are some callback functions
    # that recognize if a gioven function belongs to a specific module
    def module_callbacks():
        def is_in_coroutine_module(name):
            return name.startswith('coroutine.')

        def is_in_modules_module(name):
            if name in ['require', 'module'] or name.startswith('package'):
                return True
            else:
                return False

        def is_in_string_module(name):
            return name.startswith('string.')

        def is_in_table_module(name):
            return name.startswith('table.')

        def is_in_math_module(name):
            return name.startswith('math')

        def is_in_io_module(name):
            return name.startswith('io.') or name.startswith('file:')

        def is_in_os_module(name):
            return name.startswith('os.')

        def is_in_debug_module(name):
            return name.startswith('debug.')

        return {'coroutine': is_in_coroutine_module,
                'modules': is_in_modules_module,
                'string': is_in_string_module,
                'table': is_in_table_module,
                'math': is_in_math_module,
                'io': is_in_io_module,
                'os': is_in_os_module,
                'debug': is_in_debug_module}



    def get_newest_version():
        f = urllib.urlopen('http://www.lua.org/manual/')
        r = re.compile(r'^<A HREF="(\d\.\d)/">Lua \1</A>')
        for line in f:
            m = r.match(line)
            if m is not None:
                return m.groups()[0]

    def get_lua_functions(version):
        f = urllib.urlopen('http://www.lua.org/manual/%s/' % version)
        r = re.compile(r'^<A HREF="manual.html#pdf-(.+)">\1</A>')
        functions = []
        for line in f:
            m = r.match(line)
            if m is not None:
                functions.append(m.groups()[0])
        return functions

    def get_function_module(name):
        for mod, cb in module_callbacks().iteritems():
            if cb(name):
                return mod
        if '.' in name:
            return name.split('.')[0]
        else:
            return 'basic'

    def regenerate(filename, modules):
        f = open(filename)
        try:
            content = f.read()
        finally:
            f.close()

        header = content[:content.find('MODULES = {')]
        footer = content[content.find("if __name__ == '__main__':"):]


        f = open(filename, 'w')
        f.write(header)
        f.write('MODULES = %s\n\n' % pprint.pformat(modules))
        f.write(footer)
        f.close()

    def run():
        version = get_newest_version()
        print '> Downloading function index for Lua %s' % version
        functions = get_lua_functions(version)
        print '> %d functions found:' % len(functions)

        modules = {}
        for full_function_name in functions:
            print '>> %s' % full_function_name
            m = get_function_module(full_function_name)
            modules.setdefault(m, []).append(full_function_name)

        regenerate(__file__, modules)


    run()
# -*- coding: utf-8 -*-
"""
    pygments.lexers._mapping
    ~~~~~~~~~~~~~~~~~~~~~~~~

    Lexer mapping defintions. This file is generated by itself. Everytime
    you change something on a builtin lexer defintion, run this script from
    the lexers folder to update it.

    Do not alter the LEXERS dictionary by hand.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

LEXERS = {
    'ABAPLexer': ('pygments.lexers.other', 'ABAP', ('abap',), ('*.abap',), ('text/x-abap',)),
    'ActionScript3Lexer': ('pygments.lexers.web', 'ActionScript 3', ('as3', 'actionscript3'), ('*.as',), ('application/x-actionscript', 'text/x-actionscript', 'text/actionscript')),
    'ActionScriptLexer': ('pygments.lexers.web', 'ActionScript', ('as', 'actionscript'), ('*.as',), ('application/x-actionscript', 'text/x-actionscript', 'text/actionscript')),
    'AntlrActionScriptLexer': ('pygments.lexers.parsers', 'ANTLR With ActionScript Target', ('antlr-as', 'antlr-actionscript'), ('*.G', '*.g'), ()),
    'AntlrCSharpLexer': ('pygments.lexers.parsers', 'ANTLR With C# Target', ('antlr-csharp', 'antlr-c#'), ('*.G', '*.g'), ()),
    'AntlrCppLexer': ('pygments.lexers.parsers', 'ANTLR With CPP Target', ('antlr-cpp',), ('*.G', '*.g'), ()),
    'AntlrJavaLexer': ('pygments.lexers.parsers', 'ANTLR With Java Target', ('antlr-java',), ('*.G', '*.g'), ()),
    'AntlrLexer': ('pygments.lexers.parsers', 'ANTLR', ('antlr',), (), ()),
    'AntlrObjectiveCLexer': ('pygments.lexers.parsers', 'ANTLR With ObjectiveC Target', ('antlr-objc',), ('*.G', '*.g'), ()),
    'AntlrPerlLexer': ('pygments.lexers.parsers', 'ANTLR With Perl Target', ('antlr-perl',), ('*.G', '*.g'), ()),
    'AntlrPythonLexer': ('pygments.lexers.parsers', 'ANTLR With Python Target', ('antlr-python',), ('*.G', '*.g'), ()),
    'AntlrRubyLexer': ('pygments.lexers.parsers', 'ANTLR With Ruby Target', ('antlr-ruby', 'antlr-rb'), ('*.G', '*.g'), ()),
    'ApacheConfLexer': ('pygments.lexers.text', 'ApacheConf', ('apacheconf', 'aconf', 'apache'), ('.htaccess', 'apache.conf', 'apache2.conf'), ('text/x-apacheconf',)),
    'AppleScriptLexer': ('pygments.lexers.other', 'AppleScript', ('applescript',), ('*.applescript',), ()),
    'BBCodeLexer': ('pygments.lexers.text', 'BBCode', ('bbcode',), (), ('text/x-bbcode',)),
    'BaseMakefileLexer': ('pygments.lexers.text', 'Makefile', ('basemake',), (), ()),
    'BashLexer': ('pygments.lexers.other', 'Bash', ('bash', 'sh'), ('*.sh',), ('application/x-sh', 'application/x-shellscript')),
    'BashSessionLexer': ('pygments.lexers.other', 'Bash Session', ('console',), ('*.sh-session',), ('application/x-shell-session',)),
    'BatchLexer': ('pygments.lexers.other', 'Batchfile', ('bat',), ('*.bat', '*.cmd'), ('application/x-dos-batch',)),
    'BefungeLexer': ('pygments.lexers.other', 'Befunge', ('befunge',), ('*.befunge',), ('application/x-befunge',)),
    'BooLexer': ('pygments.lexers.dotnet', 'Boo', ('boo',), ('*.boo',), ('text/x-boo',)),
    'BrainfuckLexer': ('pygments.lexers.other', 'Brainfuck', ('brainfuck', 'bf'), ('*.bf', '*.b'), ('application/x-brainfuck',)),
    'CLexer': ('pygments.lexers.compiled', 'C', ('c',), ('*.c', '*.h'), ('text/x-chdr', 'text/x-csrc')),
    'CObjdumpLexer': ('pygments.lexers.asm', 'c-objdump', ('c-objdump',), ('*.c-objdump',), ('text/x-c-objdump',)),
    'CSharpAspxLexer': ('pygments.lexers.dotnet', 'aspx-cs', ('aspx-cs',), ('*.aspx', '*.asax', '*.ascx', '*.ashx', '*.asmx', '*.axd'), ()),
    'CSharpLexer': ('pygments.lexers.dotnet', 'C#', ('csharp', 'c#'), ('*.cs',), ('text/x-csharp',)),
    'CheetahHtmlLexer': ('pygments.lexers.templates', 'HTML+Cheetah', ('html+cheetah', 'html+spitfire'), (), ('text/html+cheetah', 'text/html+spitfire')),
    'CheetahJavascriptLexer': ('pygments.lexers.templates', 'JavaScript+Cheetah', ('js+cheetah', 'javascript+cheetah', 'js+spitfire', 'javascript+spitfire'), (), ('application/x-javascript+cheetah', 'text/x-javascript+cheetah', 'text/javascript+cheetah', 'application/x-javascript+spitfire', 'text/x-javascript+spitfire', 'text/javascript+spitfire')),
    'CheetahLexer': ('pygments.lexers.templates', 'Cheetah', ('cheetah', 'spitfire'), ('*.tmpl', '*.spt'), ('application/x-cheetah', 'application/x-spitfire')),
    'CheetahXmlLexer': ('pygments.lexers.templates', 'XML+Cheetah', ('xml+cheetah', 'xml+spitfire'), (), ('application/xml+cheetah', 'application/xml+spitfire')),
    'ClojureLexer': ('pygments.lexers.agile', 'Clojure', ('clojure', 'clj'), ('*.clj',), ('text/x-clojure', 'application/x-clojure')),
    'CommonLispLexer': ('pygments.lexers.functional', 'Common Lisp', ('common-lisp', 'cl'), ('*.cl', '*.lisp', '*.el'), ('text/x-common-lisp',)),
    'CppLexer': ('pygments.lexers.compiled', 'C++', ('cpp', 'c++'), ('*.cpp', '*.hpp', '*.c++', '*.h++', '*.cc', '*.hh', '*.cxx', '*.hxx'), ('text/x-c++hdr', 'text/x-c++src')),
    'CppObjdumpLexer': ('pygments.lexers.asm', 'cpp-objdump', ('cpp-objdump', 'c++-objdumb', 'cxx-objdump'), ('*.cpp-objdump', '*.c++-objdump', '*.cxx-objdump'), ('text/x-cpp-objdump',)),
    'CssDjangoLexer': ('pygments.lexers.templates', 'CSS+Django/Jinja', ('css+django', 'css+jinja'), (), ('text/css+django', 'text/css+jinja')),
    'CssErbLexer': ('pygments.lexers.templates', 'CSS+Ruby', ('css+erb', 'css+ruby'), (), ('text/css+ruby',)),
    'CssGenshiLexer': ('pygments.lexers.templates', 'CSS+Genshi Text', ('css+genshitext', 'css+genshi'), (), ('text/css+genshi',)),
    'CssLexer': ('pygments.lexers.web', 'CSS', ('css',), ('*.css',), ('text/css',)),
    'CssPhpLexer': ('pygments.lexers.templates', 'CSS+PHP', ('css+php',), (), ('text/css+php',)),
    'CssSmartyLexer': ('pygments.lexers.templates', 'CSS+Smarty', ('css+smarty',), (), ('text/css+smarty',)),
    'CythonLexer': ('pygments.lexers.compiled', 'Cython', ('cython', 'pyx'), ('*.pyx', '*.pxd', '*.pxi'), ('text/x-cython', 'application/x-cython')),
    'DLexer': ('pygments.lexers.compiled', 'D', ('d',), ('*.d', '*.di'), ('text/x-dsrc',)),
    'DObjdumpLexer': ('pygments.lexers.asm', 'd-objdump', ('d-objdump',), ('*.d-objdump',), ('text/x-d-objdump',)),
    'DarcsPatchLexer': ('pygments.lexers.text', 'Darcs Patch', ('dpatch',), ('*.dpatch', '*.darcspatch'), ()),
    'DebianControlLexer': ('pygments.lexers.text', 'Debian Control file', ('control',), ('control',), ()),
    'DelphiLexer': ('pygments.lexers.compiled', 'Delphi', ('delphi', 'pas', 'pascal', 'objectpascal'), ('*.pas',), ('text/x-pascal',)),
    'DiffLexer': ('pygments.lexers.text', 'Diff', ('diff', 'udiff'), ('*.diff', '*.patch'), ('text/x-diff', 'text/x-patch')),
    'DjangoLexer': ('pygments.lexers.templates', 'Django/Jinja', ('django', 'jinja'), (), ('application/x-django-templating', 'application/x-jinja')),
    'DylanLexer': ('pygments.lexers.compiled', 'Dylan', ('dylan',), ('*.dylan',), ('text/x-dylan',)),
    'ErbLexer': ('pygments.lexers.templates', 'ERB', ('erb',), (), ('application/x-ruby-templating',)),
    'ErlangLexer': ('pygments.lexers.functional', 'Erlang', ('erlang',), ('*.erl', '*.hrl'), ('text/x-erlang',)),
    'ErlangShellLexer': ('pygments.lexers.functional', 'Erlang erl session', ('erl',), ('*.erl-sh',), ('text/x-erl-shellsession',)),
    'EvoqueHtmlLexer': ('pygments.lexers.templates', 'HTML+Evoque', ('html+evoque',), ('*.html',), ('text/html+evoque',)),
    'EvoqueLexer': ('pygments.lexers.templates', 'Evoque', ('evoque',), ('*.evoque',), ('application/x-evoque',)),
    'EvoqueXmlLexer': ('pygments.lexers.templates', 'XML+Evoque', ('xml+evoque',), ('*.xml',), ('application/xml+evoque',)),
    'FortranLexer': ('pygments.lexers.compiled', 'Fortran', ('fortran',), ('*.f', '*.f90'), ('text/x-fortran',)),
    'GLShaderLexer': ('pygments.lexers.compiled', 'GLSL', ('glsl',), ('*.vert', '*.frag', '*.geo'), ('text/x-glslsrc',)),
    'GasLexer': ('pygments.lexers.asm', 'GAS', ('gas',), ('*.s', '*.S'), ('text/x-gas',)),
    'GenshiLexer': ('pygments.lexers.templates', 'Genshi', ('genshi', 'kid', 'xml+genshi', 'xml+kid'), ('*.kid',), ('application/x-genshi', 'application/x-kid')),
    'GenshiTextLexer': ('pygments.lexers.templates', 'Genshi Text', ('genshitext',), (), ('application/x-genshi-text', 'text/x-genshi')),
    'GettextLexer': ('pygments.lexers.text', 'Gettext Catalog', ('pot', 'po'), ('*.pot', '*.po'), ('application/x-gettext', 'text/x-gettext', 'text/gettext')),
    'GnuplotLexer': ('pygments.lexers.other', 'Gnuplot', ('gnuplot',), ('*.plot', '*.plt'), ('text/x-gnuplot',)),
    'GroffLexer': ('pygments.lexers.text', 'Groff', ('groff', 'nroff', 'man'), ('*.[1234567]', '*.man'), ('application/x-troff', 'text/troff')),
    'HaskellLexer': ('pygments.lexers.functional', 'Haskell', ('haskell', 'hs'), ('*.hs',), ('text/x-haskell',)),
    'HtmlDjangoLexer': ('pygments.lexers.templates', 'HTML+Django/Jinja', ('html+django', 'html+jinja'), (), ('text/html+django', 'text/html+jinja')),
    'HtmlGenshiLexer': ('pygments.lexers.templates', 'HTML+Genshi', ('html+genshi', 'html+kid'), (), ('text/html+genshi',)),
    'HtmlLexer': ('pygments.lexers.web', 'HTML', ('html',), ('*.html', '*.htm', '*.xhtml', '*.xslt'), ('text/html', 'application/xhtml+xml')),
    'HtmlPhpLexer': ('pygments.lexers.templates', 'HTML+PHP', ('html+php',), ('*.phtml',), ('application/x-php', 'application/x-httpd-php', 'application/x-httpd-php3', 'application/x-httpd-php4', 'application/x-httpd-php5')),
    'HtmlSmartyLexer': ('pygments.lexers.templates', 'HTML+Smarty', ('html+smarty',), (), ('text/html+smarty',)),
    'IniLexer': ('pygments.lexers.text', 'INI', ('ini', 'cfg'), ('*.ini', '*.cfg', '*.properties'), ('text/x-ini',)),
    'IoLexer': ('pygments.lexers.agile', 'Io', ('io',), ('*.io',), ('text/x-iosrc',)),
    'IrcLogsLexer': ('pygments.lexers.text', 'IRC logs', ('irc',), ('*.weechatlog',), ('text/x-irclog',)),
    'JavaLexer': ('pygments.lexers.compiled', 'Java', ('java',), ('*.java',), ('text/x-java',)),
    'JavascriptDjangoLexer': ('pygments.lexers.templates', 'JavaScript+Django/Jinja', ('js+django', 'javascript+django', 'js+jinja', 'javascript+jinja'), (), ('application/x-javascript+django', 'application/x-javascript+jinja', 'text/x-javascript+django', 'text/x-javascript+jinja', 'text/javascript+django', 'text/javascript+jinja')),
    'JavascriptErbLexer': ('pygments.lexers.templates', 'JavaScript+Ruby', ('js+erb', 'javascript+erb', 'js+ruby', 'javascript+ruby'), (), ('application/x-javascript+ruby', 'text/x-javascript+ruby', 'text/javascript+ruby')),
    'JavascriptGenshiLexer': ('pygments.lexers.templates', 'JavaScript+Genshi Text', ('js+genshitext', 'js+genshi', 'javascript+genshitext', 'javascript+genshi'), (), ('application/x-javascript+genshi', 'text/x-javascript+genshi', 'text/javascript+genshi')),
    'JavascriptLexer': ('pygments.lexers.web', 'JavaScript', ('js', 'javascript'), ('*.js',), ('application/x-javascript', 'text/x-javascript', 'text/javascript')),
    'JavascriptPhpLexer': ('pygments.lexers.templates', 'JavaScript+PHP', ('js+php', 'javascript+php'), (), ('application/x-javascript+php', 'text/x-javascript+php', 'text/javascript+php')),
    'JavascriptSmartyLexer': ('pygments.lexers.templates', 'JavaScript+Smarty', ('js+smarty', 'javascript+smarty'), (), ('application/x-javascript+smarty', 'text/x-javascript+smarty', 'text/javascript+smarty')),
    'JspLexer': ('pygments.lexers.templates', 'Java Server Page', ('jsp',), ('*.jsp',), ('application/x-jsp',)),
    'LighttpdConfLexer': ('pygments.lexers.text', 'Lighttpd configuration file', ('lighty', 'lighttpd'), (), ('text/x-lighttpd-conf',)),
    'LiterateHaskellLexer': ('pygments.lexers.functional', 'Literate Haskell', ('lhs', 'literate-haskell'), ('*.lhs',), ('text/x-literate-haskell',)),
    'LlvmLexer': ('pygments.lexers.asm', 'LLVM', ('llvm',), ('*.ll',), ('text/x-llvm',)),
    'LogtalkLexer': ('pygments.lexers.other', 'Logtalk', ('logtalk',), ('*.lgt',), ('text/x-logtalk',)),
    'LuaLexer': ('pygments.lexers.agile', 'Lua', ('lua',), ('*.lua',), ('text/x-lua', 'application/x-lua')),
    'MOOCodeLexer': ('pygments.lexers.other', 'MOOCode', ('moocode',), ('*.moo',), ('text/x-moocode',)),
    'MakefileLexer': ('pygments.lexers.text', 'Makefile', ('make', 'makefile', 'mf', 'bsdmake'), ('*.mak', 'Makefile', 'makefile', 'Makefile.*', 'GNUmakefile'), ('text/x-makefile',)),
    'MakoCssLexer': ('pygments.lexers.templates', 'CSS+Mako', ('css+mako',), (), ('text/css+mako',)),
    'MakoHtmlLexer': ('pygments.lexers.templates', 'HTML+Mako', ('html+mako',), (), ('text/html+mako',)),
    'MakoJavascriptLexer': ('pygments.lexers.templates', 'JavaScript+Mako', ('js+mako', 'javascript+mako'), (), ('application/x-javascript+mako', 'text/x-javascript+mako', 'text/javascript+mako')),
    'MakoLexer': ('pygments.lexers.templates', 'Mako', ('mako',), ('*.mao',), ('application/x-mako',)),
    'MakoXmlLexer': ('pygments.lexers.templates', 'XML+Mako', ('xml+mako',), (), ('application/xml+mako',)),
    'MatlabLexer': ('pygments.lexers.math', 'Matlab', ('matlab', 'octave'), ('*.m',), ('text/matlab',)),
    'MatlabSessionLexer': ('pygments.lexers.math', 'Matlab session', ('matlabsession',), (), ()),
    'MiniDLexer': ('pygments.lexers.agile', 'MiniD', ('minid',), ('*.md',), ('text/x-minidsrc',)),
    'ModelicaLexer': ('pygments.lexers.other', 'Modelica', ('modelica',), ('*.mo',), ('text/x-modelica',)),
    'MoinWikiLexer': ('pygments.lexers.text', 'MoinMoin/Trac Wiki markup', ('trac-wiki', 'moin'), (), ('text/x-trac-wiki',)),
    'MuPADLexer': ('pygments.lexers.math', 'MuPAD', ('mupad',), ('*.mu',), ()),
    'MxmlLexer': ('pygments.lexers.web', 'MXML', ('mxml',), ('*.mxml',), ()),
    'MySqlLexer': ('pygments.lexers.other', 'MySQL', ('mysql',), (), ('text/x-mysql',)),
    'MyghtyCssLexer': ('pygments.lexers.templates', 'CSS+Myghty', ('css+myghty',), (), ('text/css+myghty',)),
    'MyghtyHtmlLexer': ('pygments.lexers.templates', 'HTML+Myghty', ('html+myghty',), (), ('text/html+myghty',)),
    'MyghtyJavascriptLexer': ('pygments.lexers.templates', 'JavaScript+Myghty', ('js+myghty', 'javascript+myghty'), (), ('application/x-javascript+myghty', 'text/x-javascript+myghty', 'text/javascript+mygthy')),
    'MyghtyLexer': ('pygments.lexers.templates', 'Myghty', ('myghty',), ('*.myt', 'autodelegate'), ('application/x-myghty',)),
    'MyghtyXmlLexer': ('pygments.lexers.templates', 'XML+Myghty', ('xml+myghty',), (), ('application/xml+myghty',)),
    'NasmLexer': ('pygments.lexers.asm', 'NASM', ('nasm',), ('*.asm', '*.ASM'), ('text/x-nasm',)),
    'NginxConfLexer': ('pygments.lexers.text', 'Nginx configuration file', ('nginx',), (), ('text/x-nginx-conf',)),
    'NumPyLexer': ('pygments.lexers.math', 'NumPy', ('numpy',), (), ()),
    'ObjdumpLexer': ('pygments.lexers.asm', 'objdump', ('objdump',), ('*.objdump',), ('text/x-objdump',)),
    'ObjectiveCLexer': ('pygments.lexers.compiled', 'Objective-C', ('objective-c', 'objectivec', 'obj-c', 'objc'), ('*.m',), ('text/x-objective-c',)),
    'OcamlLexer': ('pygments.lexers.compiled', 'OCaml', ('ocaml',), ('*.ml', '*.mli', '*.mll', '*.mly'), ('text/x-ocaml',)),
    'OcamlLexer': ('pygments.lexers.functional', 'OCaml', ('ocaml',), ('*.ml', '*.mli', '*.mll', '*.mly'), ('text/x-ocaml',)),
    'PerlLexer': ('pygments.lexers.agile', 'Perl', ('perl', 'pl'), ('*.pl', '*.pm'), ('text/x-perl', 'application/x-perl')),
    'PhpLexer': ('pygments.lexers.web', 'PHP', ('php', 'php3', 'php4', 'php5'), ('*.php', '*.php[345]'), ('text/x-php',)),
    'PovrayLexer': ('pygments.lexers.other', 'POVRay', ('pov',), ('*.pov', '*.inc'), ('text/x-povray',)),
    'PrologLexer': ('pygments.lexers.compiled', 'Prolog', ('prolog',), ('*.prolog', '*.pro', '*.pl'), ('text/x-prolog',)),
    'Python3Lexer': ('pygments.lexers.agile', 'Python 3', ('python3', 'py3'), (), ('text/x-python3', 'application/x-python3')),
    'Python3TracebackLexer': ('pygments.lexers.agile', 'Python 3.0 Traceback', ('py3tb',), ('*.py3tb',), ('text/x-python3-traceback',)),
    'PythonConsoleLexer': ('pygments.lexers.agile', 'Python console session', ('pycon',), (), ('text/x-python-doctest',)),
    'PythonLexer': ('pygments.lexers.agile', 'Python', ('python', 'py'), ('*.py', '*.pyw', '*.sc', 'SConstruct', 'SConscript'), ('text/x-python', 'application/x-python')),
    'PythonTracebackLexer': ('pygments.lexers.agile', 'Python Traceback', ('pytb',), ('*.pytb',), ('text/x-python-traceback',)),
    'RagelCLexer': ('pygments.lexers.parsers', 'Ragel in C Host', ('ragel-c',), ('*.rl',), ()),
    'RagelCppLexer': ('pygments.lexers.parsers', 'Ragel in CPP Host', ('ragel-cpp',), ('*.rl',), ()),
    'RagelDLexer': ('pygments.lexers.parsers', 'Ragel in D Host', ('ragel-d',), ('*.rl',), ()),
    'RagelEmbeddedLexer': ('pygments.lexers.parsers', 'Embedded Ragel', ('ragel-em',), ('*.rl',), ()),
    'RagelJavaLexer': ('pygments.lexers.parsers', 'Ragel in Java Host', ('ragel-java',), ('*.rl',), ()),
    'RagelLexer': ('pygments.lexers.parsers', 'Ragel', ('ragel',), (), ()),
    'RagelObjectiveCLexer': ('pygments.lexers.parsers', 'Ragel in Objective C Host', ('ragel-objc',), ('*.rl',), ()),
    'RagelRubyLexer': ('pygments.lexers.parsers', 'Ragel in Ruby Host', ('ragel-ruby', 'ragel-rb'), ('*.rl',), ()),
    'RawTokenLexer': ('pygments.lexers.special', 'Raw token data', ('raw',), (), ('application/x-pygments-tokens',)),
    'RebolLexer': ('pygments.lexers.other', 'REBOL', ('rebol',), ('*.r', '*.r3'), ('text/x-rebol',)),
    'RedcodeLexer': ('pygments.lexers.other', 'Redcode', ('redcode',), ('*.cw',), ()),
    'RhtmlLexer': ('pygments.lexers.templates', 'RHTML', ('rhtml', 'html+erb', 'html+ruby'), ('*.rhtml',), ('text/html+ruby',)),
    'RstLexer': ('pygments.lexers.text', 'reStructuredText', ('rst', 'rest', 'restructuredtext'), ('*.rst', '*.rest'), ('text/x-rst', 'text/prs.fallenstein.rst')),
    'RubyConsoleLexer': ('pygments.lexers.agile', 'Ruby irb session', ('rbcon', 'irb'), (), ('text/x-ruby-shellsession',)),
    'RubyLexer': ('pygments.lexers.agile', 'Ruby', ('rb', 'ruby'), ('*.rb', '*.rbw', 'Rakefile', '*.rake', '*.gemspec', '*.rbx'), ('text/x-ruby', 'application/x-ruby')),
    'SLexer': ('pygments.lexers.math', 'S', ('splus', 's', 'r'), ('*.S', '*.R'), ('text/S-plus', 'text/S', 'text/R')),
    'ScalaLexer': ('pygments.lexers.compiled', 'Scala', ('scala',), ('*.scala',), ('text/x-scala',)),
    'SchemeLexer': ('pygments.lexers.functional', 'Scheme', ('scheme', 'scm'), ('*.scm',), ('text/x-scheme', 'application/x-scheme')),
    'SmalltalkLexer': ('pygments.lexers.other', 'Smalltalk', ('smalltalk', 'squeak'), ('*.st',), ('text/x-smalltalk',)),
    'SmartyLexer': ('pygments.lexers.templates', 'Smarty', ('smarty',), ('*.tpl',), ('application/x-smarty',)),
    'SourcesListLexer': ('pygments.lexers.text', 'Debian Sourcelist', ('sourceslist', 'sources.list'), ('sources.list',), ()),
    'SqlLexer': ('pygments.lexers.other', 'SQL', ('sql',), ('*.sql',), ('text/x-sql',)),
    'SqliteConsoleLexer': ('pygments.lexers.other', 'sqlite3con', ('sqlite3',), ('*.sqlite3-console',), ('text/x-sqlite3-console',)),
    'SquidConfLexer': ('pygments.lexers.text', 'SquidConf', ('squidconf', 'squid.conf', 'squid'), ('squid.conf',), ('text/x-squidconf',)),
    'TclLexer': ('pygments.lexers.agile', 'Tcl', ('tcl',), ('*.tcl',), ('text/x-tcl', 'text/x-script.tcl', 'application/x-tcl')),
    'TcshLexer': ('pygments.lexers.other', 'Tcsh', ('tcsh', 'csh'), ('*.tcsh', '*.csh'), ('application/x-csh',)),
    'TexLexer': ('pygments.lexers.text', 'TeX', ('tex', 'latex'), ('*.tex', '*.aux', '*.toc'), ('text/x-tex', 'text/x-latex')),
    'TextLexer': ('pygments.lexers.special', 'Text only', ('text',), ('*.txt',), ('text/plain',)),
    'VbNetAspxLexer': ('pygments.lexers.dotnet', 'aspx-vb', ('aspx-vb',), ('*.aspx', '*.asax', '*.ascx', '*.ashx', '*.asmx', '*.axd'), ()),
    'VbNetLexer': ('pygments.lexers.dotnet', 'VB.net', ('vb.net', 'vbnet'), ('*.vb', '*.bas'), ('text/x-vbnet', 'text/x-vba')),
    'VimLexer': ('pygments.lexers.text', 'VimL', ('vim',), ('*.vim', '.vimrc'), ('text/x-vim',)),
    'XmlDjangoLexer': ('pygments.lexers.templates', 'XML+Django/Jinja', ('xml+django', 'xml+jinja'), (), ('application/xml+django', 'application/xml+jinja')),
    'XmlErbLexer': ('pygments.lexers.templates', 'XML+Ruby', ('xml+erb', 'xml+ruby'), (), ('application/xml+ruby',)),
    'XmlLexer': ('pygments.lexers.web', 'XML', ('xml',), ('*.xml', '*.xsl', '*.rss', '*.xslt', '*.xsd', '*.wsdl'), ('text/xml', 'application/xml', 'image/svg+xml', 'application/rss+xml', 'application/atom+xml', 'application/xsl+xml', 'application/xslt+xml')),
    'XmlPhpLexer': ('pygments.lexers.templates', 'XML+PHP', ('xml+php',), (), ('application/xml+php',)),
    'XmlSmartyLexer': ('pygments.lexers.templates', 'XML+Smarty', ('xml+smarty',), (), ('application/xml+smarty',)),
    'XsltLexer': ('pygments.lexers.web', 'XSLT', ('xslt',), ('*.xsl', '*.xslt'), ('text/xml', 'application/xml', 'image/svg+xml', 'application/rss+xml', 'application/atom+xml', 'application/xsl+xml', 'application/xslt+xml')),
    'YamlLexer': ('pygments.lexers.text', 'YAML', ('yaml',), ('*.yaml', '*.yml'), ('text/x-yaml',))
}

if __name__ == '__main__':
    import sys
    import os

    # lookup lexers
    found_lexers = []
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))
    for filename in os.listdir('.'):
        if filename.endswith('.py') and not filename.startswith('_'):
            module_name = 'pygments.lexers.%s' % filename[:-3]
            print module_name
            module = __import__(module_name, None, None, [''])
            for lexer_name in module.__all__:
                lexer = getattr(module, lexer_name)
                found_lexers.append(
                    '%r: %r' % (lexer_name,
                                (module_name,
                                 lexer.name,
                                 tuple(lexer.aliases),
                                 tuple(lexer.filenames),
                                 tuple(lexer.mimetypes))))
    # sort them, that should make the diff files for svn smaller
    found_lexers.sort()

    # extract useful sourcecode from this file
    f = open(__file__)
    try:
        content = f.read()
    finally:
        f.close()
    header = content[:content.find('LEXERS = {')]
    footer = content[content.find("if __name__ == '__main__':"):]

    # write new file
    f = open(__file__, 'w')
    f.write(header)
    f.write('LEXERS = {\n    %s\n}\n\n' % ',\n    '.join(found_lexers))
    f.write(footer)
    f.close()
# -*- coding: utf-8 -*-
"""
    pygments.lexers._phpbuiltins
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    This file loads the function names and their modules from the
    php webpage and generates itself.

    Do not alter the MODULES dict by hand!

    WARNING: the generation transfers quite much data over your
             internet connection. don't run that at home, use
             a server ;-)

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""


MODULES = {'.NET': ['dotnet_load'],
 'APD': ['apd_breakpoint',
         'apd_callstack',
         'apd_clunk',
         'apd_continue',
         'apd_croak',
         'apd_dump_function_table',
         'apd_dump_persistent_resources',
         'apd_dump_regular_resources',
         'apd_echo',
         'apd_get_active_symbols',
         'apd_set_pprof_trace',
         'apd_set_session',
         'apd_set_session_trace',
         'apd_set_socket_session_trace',
         'override_function',
         'rename_function'],
 'Apache': ['apache_child_terminate',
            'apache_get_modules',
            'apache_get_version',
            'apache_getenv',
            'apache_lookup_uri',
            'apache_note',
            'apache_request_headers',
            'apache_reset_timeout',
            'apache_response_headers',
            'apache_setenv',
            'ascii2ebcdic',
            'ebcdic2ascii',
            'getallheaders',
            'virtual'],
 'Arrays': ['array',
            'array_change_key_case',
            'array_chunk',
            'array_combine',
            'array_count_values',
            'array_diff',
            'array_diff_assoc',
            'array_diff_key',
            'array_diff_uassoc',
            'array_diff_ukey',
            'array_fill',
            'array_filter',
            'array_flip',
            'array_intersect',
            'array_intersect_assoc',
            'array_intersect_key',
            'array_intersect_uassoc',
            'array_intersect_ukey',
            'array_key_exists',
            'array_keys',
            'array_map',
            'array_merge',
            'array_merge_recursive',
            'array_multisort',
            'array_pad',
            'array_pop',
            'array_push',
            'array_rand',
            'array_reduce',
            'array_reverse',
            'array_search',
            'array_shift',
            'array_slice',
            'array_splice',
            'array_sum',
            'array_udiff',
            'array_udiff_assoc',
            'array_udiff_uassoc',
            'array_uintersect',
            'array_uintersect_assoc',
            'array_uintersect_uassoc',
            'array_unique',
            'array_unshift',
            'array_values',
            'array_walk',
            'array_walk_recursive',
            'arsort',
            'asort',
            'compact',
            'count',
            'current',
            'each',
            'end',
            'extract',
            'in_array',
            'key',
            'krsort',
            'ksort',
            'list',
            'natcasesort',
            'natsort',
            'next',
            'pos',
            'prev',
            'range',
            'reset',
            'rsort',
            'shuffle',
            'sizeof',
            'sort',
            'uasort',
            'uksort',
            'usort'],
 'Aspell': ['aspell_check',
            'aspell_check_raw',
            'aspell_new',
            'aspell_suggest'],
 'BC math': ['bcadd',
             'bccomp',
             'bcdiv',
             'bcmod',
             'bcmul',
             'bcpow',
             'bcpowmod',
             'bcscale',
             'bcsqrt',
             'bcsub'],
 'Bzip2': ['bzclose',
           'bzcompress',
           'bzdecompress',
           'bzerrno',
           'bzerror',
           'bzerrstr',
           'bzflush',
           'bzopen',
           'bzread',
           'bzwrite'],
 'CCVS': ['ccvs_add',
          'ccvs_auth',
          'ccvs_command',
          'ccvs_count',
          'ccvs_delete',
          'ccvs_done',
          'ccvs_init',
          'ccvs_lookup',
          'ccvs_new',
          'ccvs_report',
          'ccvs_return',
          'ccvs_reverse',
          'ccvs_sale',
          'ccvs_status',
          'ccvs_textvalue',
          'ccvs_void'],
 'COM': ['com_addref',
         'com_create_guid',
         'com_event_sink',
         'com_get',
         'com_get_active_object',
         'com_invoke',
         'com_isenum',
         'com_load',
         'com_load_typelib',
         'com_message_pump',
         'com_print_typeinfo',
         'com_propget',
         'com_propput',
         'com_propset',
         'com_release',
         'com_set',
         'variant_abs',
         'variant_add',
         'variant_and',
         'variant_cast',
         'variant_cat',
         'variant_cmp',
         'variant_date_from_timestamp',
         'variant_date_to_timestamp',
         'variant_div',
         'variant_eqv',
         'variant_fix',
         'variant_get_type',
         'variant_idiv',
         'variant_imp',
         'variant_int',
         'variant_mod',
         'variant_mul',
         'variant_neg',
         'variant_not',
         'variant_or',
         'variant_pow',
         'variant_round',
         'variant_set',
         'variant_set_type',
         'variant_sub',
         'variant_xor'],
 'CURL': ['curl_close',
          'curl_copy_handle',
          'curl_errno',
          'curl_error',
          'curl_exec',
          'curl_getinfo',
          'curl_init',
          'curl_multi_add_handle',
          'curl_multi_close',
          'curl_multi_exec',
          'curl_multi_getcontent',
          'curl_multi_info_read',
          'curl_multi_init',
          'curl_multi_remove_handle',
          'curl_multi_select',
          'curl_setopt',
          'curl_version'],
 'Calendar': ['cal_days_in_month',
              'cal_from_jd',
              'cal_info',
              'cal_to_jd',
              'easter_date',
              'easter_days',
              'frenchtojd',
              'gregoriantojd',
              'jddayofweek',
              'jdmonthname',
              'jdtofrench',
              'jdtogregorian',
              'jdtojewish',
              'jdtojulian',
              'jdtounix',
              'jewishtojd',
              'juliantojd',
              'unixtojd'],
 'Classes/Objects': ['call_user_method',
                     'call_user_method_array',
                     'class_exists',
                     'get_class',
                     'get_class_methods',
                     'get_class_vars',
                     'get_declared_classes',
                     'get_declared_interfaces',
                     'get_object_vars',
                     'get_parent_class',
                     'interface_exists',
                     'is_a',
                     'is_subclass_of',
                     'method_exists'],
 'Classkit': ['classkit_import',
              'classkit_method_add',
              'classkit_method_copy',
              'classkit_method_redefine',
              'classkit_method_remove',
              'classkit_method_rename'],
 'ClibPDF': ['cpdf_add_annotation',
             'cpdf_add_outline',
             'cpdf_arc',
             'cpdf_begin_text',
             'cpdf_circle',
             'cpdf_clip',
             'cpdf_close',
             'cpdf_closepath',
             'cpdf_closepath_fill_stroke',
             'cpdf_closepath_stroke',
             'cpdf_continue_text',
             'cpdf_curveto',
             'cpdf_end_text',
             'cpdf_fill',
             'cpdf_fill_stroke',
             'cpdf_finalize',
             'cpdf_finalize_page',
             'cpdf_global_set_document_limits',
             'cpdf_import_jpeg',
             'cpdf_lineto',
             'cpdf_moveto',
             'cpdf_newpath',
             'cpdf_open',
             'cpdf_output_buffer',
             'cpdf_page_init',
             'cpdf_place_inline_image',
             'cpdf_rect',
             'cpdf_restore',
             'cpdf_rlineto',
             'cpdf_rmoveto',
             'cpdf_rotate',
             'cpdf_rotate_text',
             'cpdf_save',
             'cpdf_save_to_file',
             'cpdf_scale',
             'cpdf_set_action_url',
             'cpdf_set_char_spacing',
             'cpdf_set_creator',
             'cpdf_set_current_page',
             'cpdf_set_font',
             'cpdf_set_font_directories',
             'cpdf_set_font_map_file',
             'cpdf_set_horiz_scaling',
             'cpdf_set_keywords',
             'cpdf_set_leading',
             'cpdf_set_page_animation',
             'cpdf_set_subject',
             'cpdf_set_text_matrix',
             'cpdf_set_text_pos',
             'cpdf_set_text_rendering',
             'cpdf_set_text_rise',
             'cpdf_set_title',
             'cpdf_set_viewer_preferences',
             'cpdf_set_word_spacing',
             'cpdf_setdash',
             'cpdf_setflat',
             'cpdf_setgray',
             'cpdf_setgray_fill',
             'cpdf_setgray_stroke',
             'cpdf_setlinecap',
             'cpdf_setlinejoin',
             'cpdf_setlinewidth',
             'cpdf_setmiterlimit',
             'cpdf_setrgbcolor',
             'cpdf_setrgbcolor_fill',
             'cpdf_setrgbcolor_stroke',
             'cpdf_show',
             'cpdf_show_xy',
             'cpdf_stringwidth',
             'cpdf_stroke',
             'cpdf_text',
             'cpdf_translate'],
 'Crack': ['crack_check',
           'crack_closedict',
           'crack_getlastmessage',
           'crack_opendict'],
 'Cybercash': ['cybercash_base64_decode',
               'cybercash_base64_encode',
               'cybercash_decr',
               'cybercash_encr'],
 'Cyrus IMAP': ['cyrus_authenticate',
                'cyrus_bind',
                'cyrus_close',
                'cyrus_connect',
                'cyrus_query',
                'cyrus_unbind'],
 'DB++': ['dbplus_add',
          'dbplus_aql',
          'dbplus_chdir',
          'dbplus_close',
          'dbplus_curr',
          'dbplus_errcode',
          'dbplus_errno',
          'dbplus_find',
          'dbplus_first',
          'dbplus_flush',
          'dbplus_freealllocks',
          'dbplus_freelock',
          'dbplus_freerlocks',
          'dbplus_getlock',
          'dbplus_getunique',
          'dbplus_info',
          'dbplus_last',
          'dbplus_lockrel',
          'dbplus_next',
          'dbplus_open',
          'dbplus_prev',
          'dbplus_rchperm',
          'dbplus_rcreate',
          'dbplus_rcrtexact',
          'dbplus_rcrtlike',
          'dbplus_resolve',
          'dbplus_restorepos',
          'dbplus_rkeys',
          'dbplus_ropen',
          'dbplus_rquery',
          'dbplus_rrename',
          'dbplus_rsecindex',
          'dbplus_runlink',
          'dbplus_rzap',
          'dbplus_savepos',
          'dbplus_setindex',
          'dbplus_setindexbynumber',
          'dbplus_sql',
          'dbplus_tcl',
          'dbplus_tremove',
          'dbplus_undo',
          'dbplus_undoprepare',
          'dbplus_unlockrel',
          'dbplus_unselect',
          'dbplus_update',
          'dbplus_xlockrel',
          'dbplus_xunlockrel'],
 'DBM': ['dblist',
         'dbmclose',
         'dbmdelete',
         'dbmexists',
         'dbmfetch',
         'dbmfirstkey',
         'dbminsert',
         'dbmnextkey',
         'dbmopen',
         'dbmreplace'],
 'DOM': ['dom_import_simplexml'],
 'DOM XML': ['domxml_new_doc',
             'domxml_open_file',
             'domxml_open_mem',
             'domxml_version',
             'domxml_xmltree',
             'domxml_xslt_stylesheet',
             'domxml_xslt_stylesheet_doc',
             'domxml_xslt_stylesheet_file',
             'xpath_eval',
             'xpath_eval_expression',
             'xpath_new_context',
             'xptr_eval',
             'xptr_new_context'],
 'Date/Time': ['checkdate',
               'date',
               'date_sunrise',
               'date_sunset',
               'getdate',
               'gettimeofday',
               'gmdate',
               'gmmktime',
               'gmstrftime',
               'idate',
               'localtime',
               'microtime',
               'mktime',
               'strftime',
               'strptime',
               'strtotime',
               'time'],
 'Direct IO': ['dio_close',
               'dio_fcntl',
               'dio_open',
               'dio_read',
               'dio_seek',
               'dio_stat',
               'dio_tcsetattr',
               'dio_truncate',
               'dio_write'],
 'Directories': ['chdir',
                 'chroot',
                 'closedir',
                 'getcwd',
                 'opendir',
                 'readdir',
                 'rewinddir',
                 'scandir'],
 'Errors and Logging': ['debug_backtrace',
                        'debug_print_backtrace',
                        'error_log',
                        'error_reporting',
                        'restore_error_handler',
                        'restore_exception_handler',
                        'set_error_handler',
                        'set_exception_handler',
                        'trigger_error',
                        'user_error'],
 'Exif': ['exif_imagetype',
          'exif_read_data',
          'exif_tagname',
          'exif_thumbnail',
          'read_exif_data'],
 'FDF': ['fdf_add_doc_javascript',
         'fdf_add_template',
         'fdf_close',
         'fdf_create',
         'fdf_enum_values',
         'fdf_errno',
         'fdf_error',
         'fdf_get_ap',
         'fdf_get_attachment',
         'fdf_get_encoding',
         'fdf_get_file',
         'fdf_get_flags',
         'fdf_get_opt',
         'fdf_get_status',
         'fdf_get_value',
         'fdf_get_version',
         'fdf_header',
         'fdf_next_field_name',
         'fdf_open',
         'fdf_open_string',
         'fdf_remove_item',
         'fdf_save',
         'fdf_save_string',
         'fdf_set_ap',
         'fdf_set_encoding',
         'fdf_set_file',
         'fdf_set_flags',
         'fdf_set_javascript_action',
         'fdf_set_on_import_javascript',
         'fdf_set_opt',
         'fdf_set_status',
         'fdf_set_submit_form_action',
         'fdf_set_target_frame',
         'fdf_set_value',
         'fdf_set_version'],
 'FTP': ['ftp_alloc',
         'ftp_cdup',
         'ftp_chdir',
         'ftp_chmod',
         'ftp_close',
         'ftp_connect',
         'ftp_delete',
         'ftp_exec',
         'ftp_fget',
         'ftp_fput',
         'ftp_get',
         'ftp_get_option',
         'ftp_login',
         'ftp_mdtm',
         'ftp_mkdir',
         'ftp_nb_continue',
         'ftp_nb_fget',
         'ftp_nb_fput',
         'ftp_nb_get',
         'ftp_nb_put',
         'ftp_nlist',
         'ftp_pasv',
         'ftp_put',
         'ftp_pwd',
         'ftp_quit',
         'ftp_raw',
         'ftp_rawlist',
         'ftp_rename',
         'ftp_rmdir',
         'ftp_set_option',
         'ftp_site',
         'ftp_size',
         'ftp_ssl_connect',
         'ftp_systype'],
 'Filesystem': ['basename',
                'chgrp',
                'chmod',
                'chown',
                'clearstatcache',
                'copy',
                'delete',
                'dirname',
                'disk_free_space',
                'disk_total_space',
                'diskfreespace',
                'fclose',
                'feof',
                'fflush',
                'fgetc',
                'fgetcsv',
                'fgets',
                'fgetss',
                'file',
                'file_exists',
                'file_get_contents',
                'file_put_contents',
                'fileatime',
                'filectime',
                'filegroup',
                'fileinode',
                'filemtime',
                'fileowner',
                'fileperms',
                'filesize',
                'filetype',
                'flock',
                'fnmatch',
                'fopen',
                'fpassthru',
                'fputcsv',
                'fputs',
                'fread',
                'fscanf',
                'fseek',
                'fstat',
                'ftell',
                'ftruncate',
                'fwrite',
                'glob',
                'is_dir',
                'is_executable',
                'is_file',
                'is_link',
                'is_readable',
                'is_uploaded_file',
                'is_writable',
                'is_writeable',
                'link',
                'linkinfo',
                'lstat',
                'mkdir',
                'move_uploaded_file',
                'parse_ini_file',
                'pathinfo',
                'pclose',
                'popen',
                'readfile',
                'readlink',
                'realpath',
                'rename',
                'rewind',
                'rmdir',
                'set_file_buffer',
                'stat',
                'symlink',
                'tempnam',
                'tmpfile',
                'touch',
                'umask',
                'unlink'],
 'Firebird/InterBase': ['ibase_add_user',
                        'ibase_affected_rows',
                        'ibase_backup',
                        'ibase_blob_add',
                        'ibase_blob_cancel',
                        'ibase_blob_close',
                        'ibase_blob_create',
                        'ibase_blob_echo',
                        'ibase_blob_get',
                        'ibase_blob_import',
                        'ibase_blob_info',
                        'ibase_blob_open',
                        'ibase_close',
                        'ibase_commit',
                        'ibase_commit_ret',
                        'ibase_connect',
                        'ibase_db_info',
                        'ibase_delete_user',
                        'ibase_drop_db',
                        'ibase_errcode',
                        'ibase_errmsg',
                        'ibase_execute',
                        'ibase_fetch_assoc',
                        'ibase_fetch_object',
                        'ibase_fetch_row',
                        'ibase_field_info',
                        'ibase_free_event_handler',
                        'ibase_free_query',
                        'ibase_free_result',
                        'ibase_gen_id',
                        'ibase_maintain_db',
                        'ibase_modify_user',
                        'ibase_name_result',
                        'ibase_num_fields',
                        'ibase_num_params',
                        'ibase_param_info',
                        'ibase_pconnect',
                        'ibase_prepare',
                        'ibase_query',
                        'ibase_restore',
                        'ibase_rollback',
                        'ibase_rollback_ret',
                        'ibase_server_info',
                        'ibase_service_attach',
                        'ibase_service_detach',
                        'ibase_set_event_handler',
                        'ibase_timefmt',
                        'ibase_trans',
                        'ibase_wait_event'],
 'FriBiDi': ['fribidi_log2vis'],
 'FrontBase': ['fbsql_affected_rows',
               'fbsql_autocommit',
               'fbsql_blob_size',
               'fbsql_change_user',
               'fbsql_clob_size',
               'fbsql_close',
               'fbsql_commit',
               'fbsql_connect',
               'fbsql_create_blob',
               'fbsql_create_clob',
               'fbsql_create_db',
               'fbsql_data_seek',
               'fbsql_database',
               'fbsql_database_password',
               'fbsql_db_query',
               'fbsql_db_status',
               'fbsql_drop_db',
               'fbsql_errno',
               'fbsql_error',
               'fbsql_fetch_array',
               'fbsql_fetch_assoc',
               'fbsql_fetch_field',
               'fbsql_fetch_lengths',
               'fbsql_fetch_object',
               'fbsql_fetch_row',
               'fbsql_field_flags',
               'fbsql_field_len',
               'fbsql_field_name',
               'fbsql_field_seek',
               'fbsql_field_table',
               'fbsql_field_type',
               'fbsql_free_result',
               'fbsql_get_autostart_info',
               'fbsql_hostname',
               'fbsql_insert_id',
               'fbsql_list_dbs',
               'fbsql_list_fields',
               'fbsql_list_tables',
               'fbsql_next_result',
               'fbsql_num_fields',
               'fbsql_num_rows',
               'fbsql_password',
               'fbsql_pconnect',
               'fbsql_query',
               'fbsql_read_blob',
               'fbsql_read_clob',
               'fbsql_result',
               'fbsql_rollback',
               'fbsql_select_db',
               'fbsql_set_lob_mode',
               'fbsql_set_password',
               'fbsql_set_transaction',
               'fbsql_start_db',
               'fbsql_stop_db',
               'fbsql_tablename',
               'fbsql_username',
               'fbsql_warnings'],
 'Function handling': ['call_user_func',
                       'call_user_func_array',
                       'create_function',
                       'func_get_arg',
                       'func_get_args',
                       'func_num_args',
                       'function_exists',
                       'get_defined_functions',
                       'register_shutdown_function',
                       'register_tick_function',
                       'unregister_tick_function'],
 'GMP': ['gmp_abs',
         'gmp_add',
         'gmp_and',
         'gmp_clrbit',
         'gmp_cmp',
         'gmp_com',
         'gmp_div',
         'gmp_div_q',
         'gmp_div_qr',
         'gmp_div_r',
         'gmp_divexact',
         'gmp_fact',
         'gmp_gcd',
         'gmp_gcdext',
         'gmp_hamdist',
         'gmp_init',
         'gmp_intval',
         'gmp_invert',
         'gmp_jacobi',
         'gmp_legendre',
         'gmp_mod',
         'gmp_mul',
         'gmp_neg',
         'gmp_or',
         'gmp_perfect_square',
         'gmp_popcount',
         'gmp_pow',
         'gmp_powm',
         'gmp_prob_prime',
         'gmp_random',
         'gmp_scan0',
         'gmp_scan1',
         'gmp_setbit',
         'gmp_sign',
         'gmp_sqrt',
         'gmp_sqrtrem',
         'gmp_strval',
         'gmp_sub',
         'gmp_xor'],
 'Hyperwave': ['hw_array2objrec',
               'hw_changeobject',
               'hw_children',
               'hw_childrenobj',
               'hw_close',
               'hw_connect',
               'hw_connection_info',
               'hw_cp',
               'hw_deleteobject',
               'hw_docbyanchor',
               'hw_docbyanchorobj',
               'hw_document_attributes',
               'hw_document_bodytag',
               'hw_document_content',
               'hw_document_setcontent',
               'hw_document_size',
               'hw_dummy',
               'hw_edittext',
               'hw_error',
               'hw_errormsg',
               'hw_free_document',
               'hw_getanchors',
               'hw_getanchorsobj',
               'hw_getandlock',
               'hw_getchildcoll',
               'hw_getchildcollobj',
               'hw_getchilddoccoll',
               'hw_getchilddoccollobj',
               'hw_getobject',
               'hw_getobjectbyquery',
               'hw_getobjectbyquerycoll',
               'hw_getobjectbyquerycollobj',
               'hw_getobjectbyqueryobj',
               'hw_getparents',
               'hw_getparentsobj',
               'hw_getrellink',
               'hw_getremote',
               'hw_getremotechildren',
               'hw_getsrcbydestobj',
               'hw_gettext',
               'hw_getusername',
               'hw_identify',
               'hw_incollections',
               'hw_info',
               'hw_inscoll',
               'hw_insdoc',
               'hw_insertanchors',
               'hw_insertdocument',
               'hw_insertobject',
               'hw_mapid',
               'hw_modifyobject',
               'hw_mv',
               'hw_new_document',
               'hw_objrec2array',
               'hw_output_document',
               'hw_pconnect',
               'hw_pipedocument',
               'hw_root',
               'hw_setlinkroot',
               'hw_stat',
               'hw_unlock',
               'hw_who'],
 'Hyperwave API': ['hwapi_hgcsp'],
 'IMAP': ['imap_8bit',
          'imap_alerts',
          'imap_append',
          'imap_base64',
          'imap_binary',
          'imap_body',
          'imap_bodystruct',
          'imap_check',
          'imap_clearflag_full',
          'imap_close',
          'imap_createmailbox',
          'imap_delete',
          'imap_deletemailbox',
          'imap_errors',
          'imap_expunge',
          'imap_fetch_overview',
          'imap_fetchbody',
          'imap_fetchheader',
          'imap_fetchstructure',
          'imap_get_quota',
          'imap_get_quotaroot',
          'imap_getacl',
          'imap_getmailboxes',
          'imap_getsubscribed',
          'imap_header',
          'imap_headerinfo',
          'imap_headers',
          'imap_last_error',
          'imap_list',
          'imap_listmailbox',
          'imap_listscan',
          'imap_listsubscribed',
          'imap_lsub',
          'imap_mail',
          'imap_mail_compose',
          'imap_mail_copy',
          'imap_mail_move',
          'imap_mailboxmsginfo',
          'imap_mime_header_decode',
          'imap_msgno',
          'imap_num_msg',
          'imap_num_recent',
          'imap_open',
          'imap_ping',
          'imap_qprint',
          'imap_renamemailbox',
          'imap_reopen',
          'imap_rfc822_parse_adrlist',
          'imap_rfc822_parse_headers',
          'imap_rfc822_write_address',
          'imap_scanmailbox',
          'imap_search',
          'imap_set_quota',
          'imap_setacl',
          'imap_setflag_full',
          'imap_sort',
          'imap_status',
          'imap_subscribe',
          'imap_thread',
          'imap_timeout',
          'imap_uid',
          'imap_undelete',
          'imap_unsubscribe',
          'imap_utf7_decode',
          'imap_utf7_encode',
          'imap_utf8'],
 'IRC Gateway': ['ircg_channel_mode',
                 'ircg_disconnect',
                 'ircg_eval_ecmascript_params',
                 'ircg_fetch_error_msg',
                 'ircg_get_username',
                 'ircg_html_encode',
                 'ircg_ignore_add',
                 'ircg_ignore_del',
                 'ircg_invite',
                 'ircg_is_conn_alive',
                 'ircg_join',
                 'ircg_kick',
                 'ircg_list',
                 'ircg_lookup_format_messages',
                 'ircg_lusers',
                 'ircg_msg',
                 'ircg_names',
                 'ircg_nick',
                 'ircg_nickname_escape',
                 'ircg_nickname_unescape',
                 'ircg_notice',
                 'ircg_oper',
                 'ircg_part',
                 'ircg_pconnect',
                 'ircg_register_format_messages',
                 'ircg_set_current',
                 'ircg_set_file',
                 'ircg_set_on_die',
                 'ircg_topic',
                 'ircg_who',
                 'ircg_whois'],
 'Image': ['gd_info',
           'getimagesize',
           'image2wbmp',
           'image_type_to_extension',
           'image_type_to_mime_type',
           'imagealphablending',
           'imageantialias',
           'imagearc',
           'imagechar',
           'imagecharup',
           'imagecolorallocate',
           'imagecolorallocatealpha',
           'imagecolorat',
           'imagecolorclosest',
           'imagecolorclosestalpha',
           'imagecolorclosesthwb',
           'imagecolordeallocate',
           'imagecolorexact',
           'imagecolorexactalpha',
           'imagecolormatch',
           'imagecolorresolve',
           'imagecolorresolvealpha',
           'imagecolorset',
           'imagecolorsforindex',
           'imagecolorstotal',
           'imagecolortransparent',
           'imagecopy',
           'imagecopymerge',
           'imagecopymergegray',
           'imagecopyresampled',
           'imagecopyresized',
           'imagecreate',
           'imagecreatefromgd',
           'imagecreatefromgd2',
           'imagecreatefromgd2part',
           'imagecreatefromgif',
           'imagecreatefromjpeg',
           'imagecreatefrompng',
           'imagecreatefromstring',
           'imagecreatefromwbmp',
           'imagecreatefromxbm',
           'imagecreatefromxpm',
           'imagecreatetruecolor',
           'imagedashedline',
           'imagedestroy',
           'imageellipse',
           'imagefill',
           'imagefilledarc',
           'imagefilledellipse',
           'imagefilledpolygon',
           'imagefilledrectangle',
           'imagefilltoborder',
           'imagefilter',
           'imagefontheight',
           'imagefontwidth',
           'imageftbbox',
           'imagefttext',
           'imagegammacorrect',
           'imagegd',
           'imagegd2',
           'imagegif',
           'imageinterlace',
           'imageistruecolor',
           'imagejpeg',
           'imagelayereffect',
           'imageline',
           'imageloadfont',
           'imagepalettecopy',
           'imagepng',
           'imagepolygon',
           'imagepsbbox',
           'imagepsencodefont',
           'imagepsextendfont',
           'imagepsfreefont',
           'imagepsloadfont',
           'imagepsslantfont',
           'imagepstext',
           'imagerectangle',
           'imagerotate',
           'imagesavealpha',
           'imagesetbrush',
           'imagesetpixel',
           'imagesetstyle',
           'imagesetthickness',
           'imagesettile',
           'imagestring',
           'imagestringup',
           'imagesx',
           'imagesy',
           'imagetruecolortopalette',
           'imagettfbbox',
           'imagettftext',
           'imagetypes',
           'imagewbmp',
           'imagexbm',
           'iptcembed',
           'iptcparse',
           'jpeg2wbmp',
           'png2wbmp'],
 'Informix': ['ifx_affected_rows',
              'ifx_blobinfile_mode',
              'ifx_byteasvarchar',
              'ifx_close',
              'ifx_connect',
              'ifx_copy_blob',
              'ifx_create_blob',
              'ifx_create_char',
              'ifx_do',
              'ifx_error',
              'ifx_errormsg',
              'ifx_fetch_row',
              'ifx_fieldproperties',
              'ifx_fieldtypes',
              'ifx_free_blob',
              'ifx_free_char',
              'ifx_free_result',
              'ifx_get_blob',
              'ifx_get_char',
              'ifx_getsqlca',
              'ifx_htmltbl_result',
              'ifx_nullformat',
              'ifx_num_fields',
              'ifx_num_rows',
              'ifx_pconnect',
              'ifx_prepare',
              'ifx_query',
              'ifx_textasvarchar',
              'ifx_update_blob',
              'ifx_update_char',
              'ifxus_close_slob',
              'ifxus_create_slob',
              'ifxus_free_slob',
              'ifxus_open_slob',
              'ifxus_read_slob',
              'ifxus_seek_slob',
              'ifxus_tell_slob',
              'ifxus_write_slob'],
 'Ingres II': ['ingres_autocommit',
               'ingres_close',
               'ingres_commit',
               'ingres_connect',
               'ingres_fetch_array',
               'ingres_fetch_object',
               'ingres_fetch_row',
               'ingres_field_length',
               'ingres_field_name',
               'ingres_field_nullable',
               'ingres_field_precision',
               'ingres_field_scale',
               'ingres_field_type',
               'ingres_num_fields',
               'ingres_num_rows',
               'ingres_pconnect',
               'ingres_query',
               'ingres_rollback'],
 'Java': ['java_last_exception_clear', 'java_last_exception_get'],
 'LDAP': ['ldap_8859_to_t61',
          'ldap_add',
          'ldap_bind',
          'ldap_close',
          'ldap_compare',
          'ldap_connect',
          'ldap_count_entries',
          'ldap_delete',
          'ldap_dn2ufn',
          'ldap_err2str',
          'ldap_errno',
          'ldap_error',
          'ldap_explode_dn',
          'ldap_first_attribute',
          'ldap_first_entry',
          'ldap_first_reference',
          'ldap_free_result',
          'ldap_get_attributes',
          'ldap_get_dn',
          'ldap_get_entries',
          'ldap_get_option',
          'ldap_get_values',
          'ldap_get_values_len',
          'ldap_list',
          'ldap_mod_add',
          'ldap_mod_del',
          'ldap_mod_replace',
          'ldap_modify',
          'ldap_next_attribute',
          'ldap_next_entry',
          'ldap_next_reference',
          'ldap_parse_reference',
          'ldap_parse_result',
          'ldap_read',
          'ldap_rename',
          'ldap_sasl_bind',
          'ldap_search',
          'ldap_set_option',
          'ldap_set_rebind_proc',
          'ldap_sort',
          'ldap_start_tls',
          'ldap_t61_to_8859',
          'ldap_unbind'],
 'LZF': ['lzf_compress', 'lzf_decompress', 'lzf_optimized_for'],
 'Lotus Notes': ['notes_body',
                 'notes_copy_db',
                 'notes_create_db',
                 'notes_create_note',
                 'notes_drop_db',
                 'notes_find_note',
                 'notes_header_info',
                 'notes_list_msgs',
                 'notes_mark_read',
                 'notes_mark_unread',
                 'notes_nav_create',
                 'notes_search',
                 'notes_unread',
                 'notes_version'],
 'MCAL': ['mcal_append_event',
          'mcal_close',
          'mcal_create_calendar',
          'mcal_date_compare',
          'mcal_date_valid',
          'mcal_day_of_week',
          'mcal_day_of_year',
          'mcal_days_in_month',
          'mcal_delete_calendar',
          'mcal_delete_event',
          'mcal_event_add_attribute',
          'mcal_event_init',
          'mcal_event_set_alarm',
          'mcal_event_set_category',
          'mcal_event_set_class',
          'mcal_event_set_description',
          'mcal_event_set_end',
          'mcal_event_set_recur_daily',
          'mcal_event_set_recur_monthly_mday',
          'mcal_event_set_recur_monthly_wday',
          'mcal_event_set_recur_none',
          'mcal_event_set_recur_weekly',
          'mcal_event_set_recur_yearly',
          'mcal_event_set_start',
          'mcal_event_set_title',
          'mcal_expunge',
          'mcal_fetch_current_stream_event',
          'mcal_fetch_event',
          'mcal_is_leap_year',
          'mcal_list_alarms',
          'mcal_list_events',
          'mcal_next_recurrence',
          'mcal_open',
          'mcal_popen',
          'mcal_rename_calendar',
          'mcal_reopen',
          'mcal_snooze',
          'mcal_store_event',
          'mcal_time_valid',
          'mcal_week_of_year'],
 'MS SQL Server': ['mssql_bind',
                   'mssql_close',
                   'mssql_connect',
                   'mssql_data_seek',
                   'mssql_execute',
                   'mssql_fetch_array',
                   'mssql_fetch_assoc',
                   'mssql_fetch_batch',
                   'mssql_fetch_field',
                   'mssql_fetch_object',
                   'mssql_fetch_row',
                   'mssql_field_length',
                   'mssql_field_name',
                   'mssql_field_seek',
                   'mssql_field_type',
                   'mssql_free_result',
                   'mssql_free_statement',
                   'mssql_get_last_message',
                   'mssql_guid_string',
                   'mssql_init',
                   'mssql_min_error_severity',
                   'mssql_min_message_severity',
                   'mssql_next_result',
                   'mssql_num_fields',
                   'mssql_num_rows',
                   'mssql_pconnect',
                   'mssql_query',
                   'mssql_result',
                   'mssql_rows_affected',
                   'mssql_select_db'],
 'Mail': ['ezmlm_hash', 'mail'],
 'Math': ['abs',
          'acos',
          'acosh',
          'asin',
          'asinh',
          'atan',
          'atan2',
          'atanh',
          'base_convert',
          'bindec',
          'ceil',
          'cos',
          'cosh',
          'decbin',
          'dechex',
          'decoct',
          'deg2rad',
          'exp',
          'expm1',
          'floor',
          'fmod',
          'getrandmax',
          'hexdec',
          'hypot',
          'is_finite',
          'is_infinite',
          'is_nan',
          'lcg_value',
          'log',
          'log10',
          'log1p',
          'max',
          'min',
          'mt_getrandmax',
          'mt_rand',
          'mt_srand',
          'octdec',
          'pi',
          'pow',
          'rad2deg',
          'rand',
          'round',
          'sin',
          'sinh',
          'sqrt',
          'srand',
          'tan',
          'tanh'],
 'Memcache': ['memcache_debug'],
 'Mimetype': ['mime_content_type'],
 'Ming (flash)': ['ming_setcubicthreshold',
                  'ming_setscale',
                  'ming_useswfversion',
                  'swfaction',
                  'swfbitmap',
                  'swfbutton',
                  'swffill',
                  'swffont',
                  'swfgradient',
                  'swfmorph',
                  'swfmovie',
                  'swfshape',
                  'swfsprite',
                  'swftext',
                  'swftextfield'],
 'Misc.': ['connection_aborted',
           'connection_status',
           'connection_timeout',
           'constant',
           'define',
           'defined',
           'die',
           'eval',
           'exit',
           'get_browser',
           'highlight_file',
           'highlight_string',
           'ignore_user_abort',
           'pack',
           'php_check_syntax',
           'php_strip_whitespace',
           'show_source',
           'sleep',
           'time_nanosleep',
           'uniqid',
           'unpack',
           'usleep'],
 'Msession': ['msession_connect',
              'msession_count',
              'msession_create',
              'msession_destroy',
              'msession_disconnect',
              'msession_find',
              'msession_get',
              'msession_get_array',
              'msession_get_data',
              'msession_inc',
              'msession_list',
              'msession_listvar',
              'msession_lock',
              'msession_plugin',
              'msession_randstr',
              'msession_set',
              'msession_set_array',
              'msession_set_data',
              'msession_timeout',
              'msession_uniq',
              'msession_unlock'],
 'Multibyte String': ['mb_convert_case',
                      'mb_convert_encoding',
                      'mb_convert_kana',
                      'mb_convert_variables',
                      'mb_decode_mimeheader',
                      'mb_decode_numericentity',
                      'mb_detect_encoding',
                      'mb_detect_order',
                      'mb_encode_mimeheader',
                      'mb_encode_numericentity',
                      'mb_ereg',
                      'mb_ereg_match',
                      'mb_ereg_replace',
                      'mb_ereg_search',
                      'mb_ereg_search_getpos',
                      'mb_ereg_search_getregs',
                      'mb_ereg_search_init',
                      'mb_ereg_search_pos',
                      'mb_ereg_search_regs',
                      'mb_ereg_search_setpos',
                      'mb_eregi',
                      'mb_eregi_replace',
                      'mb_get_info',
                      'mb_http_input',
                      'mb_http_output',
                      'mb_internal_encoding',
                      'mb_language',
                      'mb_list_encodings',
                      'mb_output_handler',
                      'mb_parse_str',
                      'mb_preferred_mime_name',
                      'mb_regex_encoding',
                      'mb_regex_set_options',
                      'mb_send_mail',
                      'mb_split',
                      'mb_strcut',
                      'mb_strimwidth',
                      'mb_strlen',
                      'mb_strpos',
                      'mb_strrpos',
                      'mb_strtolower',
                      'mb_strtoupper',
                      'mb_strwidth',
                      'mb_substitute_character',
                      'mb_substr',
                      'mb_substr_count'],
 'MySQL': ['mysql_affected_rows',
           'mysql_change_user',
           'mysql_client_encoding',
           'mysql_close',
           'mysql_connect',
           'mysql_create_db',
           'mysql_data_seek',
           'mysql_db_name',
           'mysql_db_query',
           'mysql_drop_db',
           'mysql_errno',
           'mysql_error',
           'mysql_escape_string',
           'mysql_fetch_array',
           'mysql_fetch_assoc',
           'mysql_fetch_field',
           'mysql_fetch_lengths',
           'mysql_fetch_object',
           'mysql_fetch_row',
           'mysql_field_flags',
           'mysql_field_len',
           'mysql_field_name',
           'mysql_field_seek',
           'mysql_field_table',
           'mysql_field_type',
           'mysql_free_result',
           'mysql_get_client_info',
           'mysql_get_host_info',
           'mysql_get_proto_info',
           'mysql_get_server_info',
           'mysql_info',
           'mysql_insert_id',
           'mysql_list_dbs',
           'mysql_list_fields',
           'mysql_list_processes',
           'mysql_list_tables',
           'mysql_num_fields',
           'mysql_num_rows',
           'mysql_pconnect',
           'mysql_ping',
           'mysql_query',
           'mysql_real_escape_string',
           'mysql_result',
           'mysql_select_db',
           'mysql_stat',
           'mysql_tablename',
           'mysql_thread_id',
           'mysql_unbuffered_query'],
 'NSAPI': ['nsapi_request_headers', 'nsapi_response_headers', 'nsapi_virtual'],
 'Ncurses': ['ncurses_addch',
             'ncurses_addchnstr',
             'ncurses_addchstr',
             'ncurses_addnstr',
             'ncurses_addstr',
             'ncurses_assume_default_colors',
             'ncurses_attroff',
             'ncurses_attron',
             'ncurses_attrset',
             'ncurses_baudrate',
             'ncurses_beep',
             'ncurses_bkgd',
             'ncurses_bkgdset',
             'ncurses_border',
             'ncurses_bottom_panel',
             'ncurses_can_change_color',
             'ncurses_cbreak',
             'ncurses_clear',
             'ncurses_clrtobot',
             'ncurses_clrtoeol',
             'ncurses_color_content',
             'ncurses_color_set',
             'ncurses_curs_set',
             'ncurses_def_prog_mode',
             'ncurses_def_shell_mode',
             'ncurses_define_key',
             'ncurses_del_panel',
             'ncurses_delay_output',
             'ncurses_delch',
             'ncurses_deleteln',
             'ncurses_delwin',
             'ncurses_doupdate',
             'ncurses_echo',
             'ncurses_echochar',
             'ncurses_end',
             'ncurses_erase',
             'ncurses_erasechar',
             'ncurses_filter',
             'ncurses_flash',
             'ncurses_flushinp',
             'ncurses_getch',
             'ncurses_getmaxyx',
             'ncurses_getmouse',
             'ncurses_getyx',
             'ncurses_halfdelay',
             'ncurses_has_colors',
             'ncurses_has_ic',
             'ncurses_has_il',
             'ncurses_has_key',
             'ncurses_hide_panel',
             'ncurses_hline',
             'ncurses_inch',
             'ncurses_init',
             'ncurses_init_color',
             'ncurses_init_pair',
             'ncurses_insch',
             'ncurses_insdelln',
             'ncurses_insertln',
             'ncurses_insstr',
             'ncurses_instr',
             'ncurses_isendwin',
             'ncurses_keyok',
             'ncurses_keypad',
             'ncurses_killchar',
             'ncurses_longname',
             'ncurses_meta',
             'ncurses_mouse_trafo',
             'ncurses_mouseinterval',
             'ncurses_mousemask',
             'ncurses_move',
             'ncurses_move_panel',
             'ncurses_mvaddch',
             'ncurses_mvaddchnstr',
             'ncurses_mvaddchstr',
             'ncurses_mvaddnstr',
             'ncurses_mvaddstr',
             'ncurses_mvcur',
             'ncurses_mvdelch',
             'ncurses_mvgetch',
             'ncurses_mvhline',
             'ncurses_mvinch',
             'ncurses_mvvline',
             'ncurses_mvwaddstr',
             'ncurses_napms',
             'ncurses_new_panel',
             'ncurses_newpad',
             'ncurses_newwin',
             'ncurses_nl',
             'ncurses_nocbreak',
             'ncurses_noecho',
             'ncurses_nonl',
             'ncurses_noqiflush',
             'ncurses_noraw',
             'ncurses_pair_content',
             'ncurses_panel_above',
             'ncurses_panel_below',
             'ncurses_panel_window',
             'ncurses_pnoutrefresh',
             'ncurses_prefresh',
             'ncurses_putp',
             'ncurses_qiflush',
             'ncurses_raw',
             'ncurses_refresh',
             'ncurses_replace_panel',
             'ncurses_reset_prog_mode',
             'ncurses_reset_shell_mode',
             'ncurses_resetty',
             'ncurses_savetty',
             'ncurses_scr_dump',
             'ncurses_scr_init',
             'ncurses_scr_restore',
             'ncurses_scr_set',
             'ncurses_scrl',
             'ncurses_show_panel',
             'ncurses_slk_attr',
             'ncurses_slk_attroff',
             'ncurses_slk_attron',
             'ncurses_slk_attrset',
             'ncurses_slk_clear',
             'ncurses_slk_color',
             'ncurses_slk_init',
             'ncurses_slk_noutrefresh',
             'ncurses_slk_refresh',
             'ncurses_slk_restore',
             'ncurses_slk_set',
             'ncurses_slk_touch',
             'ncurses_standend',
             'ncurses_standout',
             'ncurses_start_color',
             'ncurses_termattrs',
             'ncurses_termname',
             'ncurses_timeout',
             'ncurses_top_panel',
             'ncurses_typeahead',
             'ncurses_ungetch',
             'ncurses_ungetmouse',
             'ncurses_update_panels',
             'ncurses_use_default_colors',
             'ncurses_use_env',
             'ncurses_use_extended_names',
             'ncurses_vidattr',
             'ncurses_vline',
             'ncurses_waddch',
             'ncurses_waddstr',
             'ncurses_wattroff',
             'ncurses_wattron',
             'ncurses_wattrset',
             'ncurses_wborder',
             'ncurses_wclear',
             'ncurses_wcolor_set',
             'ncurses_werase',
             'ncurses_wgetch',
             'ncurses_whline',
             'ncurses_wmouse_trafo',
             'ncurses_wmove',
             'ncurses_wnoutrefresh',
             'ncurses_wrefresh',
             'ncurses_wstandend',
             'ncurses_wstandout',
             'ncurses_wvline'],
 'Network': ['checkdnsrr',
             'closelog',
             'debugger_off',
             'debugger_on',
             'define_syslog_variables',
             'dns_check_record',
             'dns_get_mx',
             'dns_get_record',
             'fsockopen',
             'gethostbyaddr',
             'gethostbyname',
             'gethostbynamel',
             'getmxrr',
             'getprotobyname',
             'getprotobynumber',
             'getservbyname',
             'getservbyport',
             'header',
             'headers_list',
             'headers_sent',
             'inet_ntop',
             'inet_pton',
             'ip2long',
             'long2ip',
             'openlog',
             'pfsockopen',
             'setcookie',
             'setrawcookie',
             'socket_get_status',
             'socket_set_blocking',
             'socket_set_timeout',
             'syslog'],
 'OCI8': ['oci_bind_by_name',
          'oci_cancel',
          'oci_close',
          'oci_commit',
          'oci_connect',
          'oci_define_by_name',
          'oci_error',
          'oci_execute',
          'oci_fetch',
          'oci_fetch_all',
          'oci_fetch_array',
          'oci_fetch_assoc',
          'oci_fetch_object',
          'oci_fetch_row',
          'oci_field_is_null',
          'oci_field_name',
          'oci_field_precision',
          'oci_field_scale',
          'oci_field_size',
          'oci_field_type',
          'oci_field_type_raw',
          'oci_free_statement',
          'oci_internal_debug',
          'oci_lob_copy',
          'oci_lob_is_equal',
          'oci_new_collection',
          'oci_new_connect',
          'oci_new_cursor',
          'oci_new_descriptor',
          'oci_num_fields',
          'oci_num_rows',
          'oci_parse',
          'oci_password_change',
          'oci_pconnect',
          'oci_result',
          'oci_rollback',
          'oci_server_version',
          'oci_set_prefetch',
          'oci_statement_type',
          'ocibindbyname',
          'ocicancel',
          'ocicloselob',
          'ocicollappend',
          'ocicollassign',
          'ocicollassignelem',
          'ocicollgetelem',
          'ocicollmax',
          'ocicollsize',
          'ocicolltrim',
          'ocicolumnisnull',
          'ocicolumnname',
          'ocicolumnprecision',
          'ocicolumnscale',
          'ocicolumnsize',
          'ocicolumntype',
          'ocicolumntyperaw',
          'ocicommit',
          'ocidefinebyname',
          'ocierror',
          'ociexecute',
          'ocifetch',
          'ocifetchinto',
          'ocifetchstatement',
          'ocifreecollection',
          'ocifreecursor',
          'ocifreedesc',
          'ocifreestatement',
          'ociinternaldebug',
          'ociloadlob',
          'ocilogoff',
          'ocilogon',
          'ocinewcollection',
          'ocinewcursor',
          'ocinewdescriptor',
          'ocinlogon',
          'ocinumcols',
          'ociparse',
          'ociplogon',
          'ociresult',
          'ocirollback',
          'ocirowcount',
          'ocisavelob',
          'ocisavelobfile',
          'ociserverversion',
          'ocisetprefetch',
          'ocistatementtype',
          'ociwritelobtofile',
          'ociwritetemporarylob'],
 'ODBC': ['odbc_autocommit',
          'odbc_binmode',
          'odbc_close',
          'odbc_close_all',
          'odbc_columnprivileges',
          'odbc_columns',
          'odbc_commit',
          'odbc_connect',
          'odbc_cursor',
          'odbc_data_source',
          'odbc_do',
          'odbc_error',
          'odbc_errormsg',
          'odbc_exec',
          'odbc_execute',
          'odbc_fetch_array',
          'odbc_fetch_into',
          'odbc_fetch_object',
          'odbc_fetch_row',
          'odbc_field_len',
          'odbc_field_name',
          'odbc_field_num',
          'odbc_field_precision',
          'odbc_field_scale',
          'odbc_field_type',
          'odbc_foreignkeys',
          'odbc_free_result',
          'odbc_gettypeinfo',
          'odbc_longreadlen',
          'odbc_next_result',
          'odbc_num_fields',
          'odbc_num_rows',
          'odbc_pconnect',
          'odbc_prepare',
          'odbc_primarykeys',
          'odbc_procedurecolumns',
          'odbc_procedures',
          'odbc_result',
          'odbc_result_all',
          'odbc_rollback',
          'odbc_setoption',
          'odbc_specialcolumns',
          'odbc_statistics',
          'odbc_tableprivileges',
          'odbc_tables'],
 'Object Aggregation': ['aggregate',
                        'aggregate_info',
                        'aggregate_methods',
                        'aggregate_methods_by_list',
                        'aggregate_methods_by_regexp',
                        'aggregate_properties',
                        'aggregate_properties_by_list',
                        'aggregate_properties_by_regexp',
                        'aggregation_info',
                        'deaggregate'],
 'Object overloading': ['overload'],
 'OpenSSL': ['openssl_csr_export',
             'openssl_csr_export_to_file',
             'openssl_csr_new',
             'openssl_csr_sign',
             'openssl_error_string',
             'openssl_free_key',
             'openssl_get_privatekey',
             'openssl_get_publickey',
             'openssl_open',
             'openssl_pkcs7_decrypt',
             'openssl_pkcs7_encrypt',
             'openssl_pkcs7_sign',
             'openssl_pkcs7_verify',
             'openssl_pkey_export',
             'openssl_pkey_export_to_file',
             'openssl_pkey_get_private',
             'openssl_pkey_get_public',
             'openssl_pkey_new',
             'openssl_private_decrypt',
             'openssl_private_encrypt',
             'openssl_public_decrypt',
             'openssl_public_encrypt',
             'openssl_seal',
             'openssl_sign',
             'openssl_verify',
             'openssl_x509_check_private_key',
             'openssl_x509_checkpurpose',
             'openssl_x509_export',
             'openssl_x509_export_to_file',
             'openssl_x509_free',
             'openssl_x509_parse',
             'openssl_x509_read'],
 'Oracle': ['ora_bind',
            'ora_close',
            'ora_columnname',
            'ora_columnsize',
            'ora_columntype',
            'ora_commit',
            'ora_commitoff',
            'ora_commiton',
            'ora_do',
            'ora_error',
            'ora_errorcode',
            'ora_exec',
            'ora_fetch',
            'ora_fetch_into',
            'ora_getcolumn',
            'ora_logoff',
            'ora_logon',
            'ora_numcols',
            'ora_numrows',
            'ora_open',
            'ora_parse',
            'ora_plogon',
            'ora_rollback'],
 'Output Control': ['flush',
                    'ob_clean',
                    'ob_end_clean',
                    'ob_end_flush',
                    'ob_flush',
                    'ob_get_clean',
                    'ob_get_contents',
                    'ob_get_flush',
                    'ob_get_length',
                    'ob_get_level',
                    'ob_get_status',
                    'ob_gzhandler',
                    'ob_implicit_flush',
                    'ob_list_handlers',
                    'ob_start',
                    'output_add_rewrite_var',
                    'output_reset_rewrite_vars'],
 'OvrimosSQL': ['ovrimos_close',
                'ovrimos_commit',
                'ovrimos_connect',
                'ovrimos_cursor',
                'ovrimos_exec',
                'ovrimos_execute',
                'ovrimos_fetch_into',
                'ovrimos_fetch_row',
                'ovrimos_field_len',
                'ovrimos_field_name',
                'ovrimos_field_num',
                'ovrimos_field_type',
                'ovrimos_free_result',
                'ovrimos_longreadlen',
                'ovrimos_num_fields',
                'ovrimos_num_rows',
                'ovrimos_prepare',
                'ovrimos_result',
                'ovrimos_result_all',
                'ovrimos_rollback'],
 'PCNTL': ['pcntl_alarm',
           'pcntl_exec',
           'pcntl_fork',
           'pcntl_getpriority',
           'pcntl_setpriority',
           'pcntl_signal',
           'pcntl_wait',
           'pcntl_waitpid',
           'pcntl_wexitstatus',
           'pcntl_wifexited',
           'pcntl_wifsignaled',
           'pcntl_wifstopped',
           'pcntl_wstopsig',
           'pcntl_wtermsig'],
 'PCRE': ['preg_grep',
          'preg_match',
          'preg_match_all',
          'preg_quote',
          'preg_replace',
          'preg_replace_callback',
          'preg_split'],
 'PDF': ['pdf_add_annotation',
         'pdf_add_bookmark',
         'pdf_add_launchlink',
         'pdf_add_locallink',
         'pdf_add_note',
         'pdf_add_outline',
         'pdf_add_pdflink',
         'pdf_add_thumbnail',
         'pdf_add_weblink',
         'pdf_arc',
         'pdf_arcn',
         'pdf_attach_file',
         'pdf_begin_page',
         'pdf_begin_pattern',
         'pdf_begin_template',
         'pdf_circle',
         'pdf_clip',
         'pdf_close',
         'pdf_close_image',
         'pdf_close_pdi',
         'pdf_close_pdi_page',
         'pdf_closepath',
         'pdf_closepath_fill_stroke',
         'pdf_closepath_stroke',
         'pdf_concat',
         'pdf_continue_text',
         'pdf_curveto',
         'pdf_delete',
         'pdf_end_page',
         'pdf_end_pattern',
         'pdf_end_template',
         'pdf_endpath',
         'pdf_fill',
         'pdf_fill_stroke',
         'pdf_findfont',
         'pdf_get_buffer',
         'pdf_get_font',
         'pdf_get_fontname',
         'pdf_get_fontsize',
         'pdf_get_image_height',
         'pdf_get_image_width',
         'pdf_get_majorversion',
         'pdf_get_minorversion',
         'pdf_get_parameter',
         'pdf_get_pdi_parameter',
         'pdf_get_pdi_value',
         'pdf_get_value',
         'pdf_initgraphics',
         'pdf_lineto',
         'pdf_makespotcolor',
         'pdf_moveto',
         'pdf_new',
         'pdf_open_ccitt',
         'pdf_open_file',
         'pdf_open_gif',
         'pdf_open_image',
         'pdf_open_image_file',
         'pdf_open_jpeg',
         'pdf_open_memory_image',
         'pdf_open_pdi',
         'pdf_open_pdi_page',
         'pdf_open_tiff',
         'pdf_place_image',
         'pdf_place_pdi_page',
         'pdf_rect',
         'pdf_restore',
         'pdf_rotate',
         'pdf_save',
         'pdf_scale',
         'pdf_set_border_color',
         'pdf_set_border_dash',
         'pdf_set_border_style',
         'pdf_set_char_spacing',
         'pdf_set_duration',
         'pdf_set_horiz_scaling',
         'pdf_set_info',
         'pdf_set_info_author',
         'pdf_set_info_creator',
         'pdf_set_info_keywords',
         'pdf_set_info_subject',
         'pdf_set_info_title',
         'pdf_set_leading',
         'pdf_set_parameter',
         'pdf_set_text_matrix',
         'pdf_set_text_pos',
         'pdf_set_text_rendering',
         'pdf_set_text_rise',
         'pdf_set_value',
         'pdf_set_word_spacing',
         'pdf_setcolor',
         'pdf_setdash',
         'pdf_setflat',
         'pdf_setfont',
         'pdf_setgray',
         'pdf_setgray_fill',
         'pdf_setgray_stroke',
         'pdf_setlinecap',
         'pdf_setlinejoin',
         'pdf_setlinewidth',
         'pdf_setmatrix',
         'pdf_setmiterlimit',
         'pdf_setpolydash',
         'pdf_setrgbcolor',
         'pdf_setrgbcolor_fill',
         'pdf_setrgbcolor_stroke',
         'pdf_show',
         'pdf_show_boxed',
         'pdf_show_xy',
         'pdf_skew',
         'pdf_stringwidth',
         'pdf_stroke',
         'pdf_translate'],
 'PHP Options/Info': ['assert',
                      'assert_options',
                      'dl',
                      'extension_loaded',
                      'get_cfg_var',
                      'get_current_user',
                      'get_defined_constants',
                      'get_extension_funcs',
                      'get_include_path',
                      'get_included_files',
                      'get_loaded_extensions',
                      'get_magic_quotes_gpc',
                      'get_magic_quotes_runtime',
                      'get_required_files',
                      'getenv',
                      'getlastmod',
                      'getmygid',
                      'getmyinode',
                      'getmypid',
                      'getmyuid',
                      'getopt',
                      'getrusage',
                      'ini_alter',
                      'ini_get',
                      'ini_get_all',
                      'ini_restore',
                      'ini_set',
                      'main',
                      'memory_get_usage',
                      'php_ini_scanned_files',
                      'php_logo_guid',
                      'php_sapi_name',
                      'php_uname',
                      'phpcredits',
                      'phpinfo',
                      'phpversion',
                      'putenv',
                      'restore_include_path',
                      'set_include_path',
                      'set_magic_quotes_runtime',
                      'set_time_limit',
                      'version_compare',
                      'zend_logo_guid',
                      'zend_version'],
 'POSIX': ['posix_ctermid',
           'posix_get_last_error',
           'posix_getcwd',
           'posix_getegid',
           'posix_geteuid',
           'posix_getgid',
           'posix_getgrgid',
           'posix_getgrnam',
           'posix_getgroups',
           'posix_getlogin',
           'posix_getpgid',
           'posix_getpgrp',
           'posix_getpid',
           'posix_getppid',
           'posix_getpwnam',
           'posix_getpwuid',
           'posix_getrlimit',
           'posix_getsid',
           'posix_getuid',
           'posix_isatty',
           'posix_kill',
           'posix_mkfifo',
           'posix_setegid',
           'posix_seteuid',
           'posix_setgid',
           'posix_setpgid',
           'posix_setsid',
           'posix_setuid',
           'posix_strerror',
           'posix_times',
           'posix_ttyname',
           'posix_uname'],
 'POSIX Regex': ['ereg',
                 'ereg_replace',
                 'eregi',
                 'eregi_replace',
                 'split',
                 'spliti',
                 'sql_regcase'],
 'Parsekit': ['parsekit_compile_file',
              'parsekit_compile_string',
              'parsekit_func_arginfo'],
 'PostgreSQL': ['pg_affected_rows',
                'pg_cancel_query',
                'pg_client_encoding',
                'pg_close',
                'pg_connect',
                'pg_connection_busy',
                'pg_connection_reset',
                'pg_connection_status',
                'pg_convert',
                'pg_copy_from',
                'pg_copy_to',
                'pg_dbname',
                'pg_delete',
                'pg_end_copy',
                'pg_escape_bytea',
                'pg_escape_string',
                'pg_fetch_all',
                'pg_fetch_array',
                'pg_fetch_assoc',
                'pg_fetch_object',
                'pg_fetch_result',
                'pg_fetch_row',
                'pg_field_is_null',
                'pg_field_name',
                'pg_field_num',
                'pg_field_prtlen',
                'pg_field_size',
                'pg_field_type',
                'pg_free_result',
                'pg_get_notify',
                'pg_get_pid',
                'pg_get_result',
                'pg_host',
                'pg_insert',
                'pg_last_error',
                'pg_last_notice',
                'pg_last_oid',
                'pg_lo_close',
                'pg_lo_create',
                'pg_lo_export',
                'pg_lo_import',
                'pg_lo_open',
                'pg_lo_read',
                'pg_lo_read_all',
                'pg_lo_seek',
                'pg_lo_tell',
                'pg_lo_unlink',
                'pg_lo_write',
                'pg_meta_data',
                'pg_num_fields',
                'pg_num_rows',
                'pg_options',
                'pg_parameter_status',
                'pg_pconnect',
                'pg_ping',
                'pg_port',
                'pg_put_line',
                'pg_query',
                'pg_result_error',
                'pg_result_seek',
                'pg_result_status',
                'pg_select',
                'pg_send_query',
                'pg_set_client_encoding',
                'pg_trace',
                'pg_tty',
                'pg_unescape_bytea',
                'pg_untrace',
                'pg_update',
                'pg_version'],
 'Printer': ['printer_abort',
             'printer_close',
             'printer_create_brush',
             'printer_create_dc',
             'printer_create_font',
             'printer_create_pen',
             'printer_delete_brush',
             'printer_delete_dc',
             'printer_delete_font',
             'printer_delete_pen',
             'printer_draw_bmp',
             'printer_draw_chord',
             'printer_draw_elipse',
             'printer_draw_line',
             'printer_draw_pie',
             'printer_draw_rectangle',
             'printer_draw_roundrect',
             'printer_draw_text',
             'printer_end_doc',
             'printer_end_page',
             'printer_get_option',
             'printer_list',
             'printer_logical_fontheight',
             'printer_open',
             'printer_select_brush',
             'printer_select_font',
             'printer_select_pen',
             'printer_set_option',
             'printer_start_doc',
             'printer_start_page',
             'printer_write'],
 'Program Execution': ['escapeshellarg',
                       'escapeshellcmd',
                       'exec',
                       'passthru',
                       'proc_close',
                       'proc_get_status',
                       'proc_nice',
                       'proc_open',
                       'proc_terminate',
                       'shell_exec',
                       'system'],
 'Pspell': ['pspell_add_to_personal',
            'pspell_add_to_session',
            'pspell_check',
            'pspell_clear_session',
            'pspell_config_create',
            'pspell_config_data_dir',
            'pspell_config_dict_dir',
            'pspell_config_ignore',
            'pspell_config_mode',
            'pspell_config_personal',
            'pspell_config_repl',
            'pspell_config_runtogether',
            'pspell_config_save_repl',
            'pspell_new',
            'pspell_new_config',
            'pspell_new_personal',
            'pspell_save_wordlist',
            'pspell_store_replacement',
            'pspell_suggest'],
 'Rar': ['rar_close', 'rar_entry_get', 'rar_list', 'rar_open'],
 'Readline': ['readline',
              'readline_add_history',
              'readline_callback_handler_install',
              'readline_callback_handler_remove',
              'readline_callback_read_char',
              'readline_clear_history',
              'readline_completion_function',
              'readline_info',
              'readline_list_history',
              'readline_on_new_line',
              'readline_read_history',
              'readline_redisplay',
              'readline_write_history'],
 'Recode': ['recode', 'recode_file', 'recode_string'],
 'SESAM': ['sesam_affected_rows',
           'sesam_commit',
           'sesam_connect',
           'sesam_diagnostic',
           'sesam_disconnect',
           'sesam_errormsg',
           'sesam_execimm',
           'sesam_fetch_array',
           'sesam_fetch_result',
           'sesam_fetch_row',
           'sesam_field_array',
           'sesam_field_name',
           'sesam_free_result',
           'sesam_num_fields',
           'sesam_query',
           'sesam_rollback',
           'sesam_seek_row',
           'sesam_settransaction'],
 'SNMP': ['snmp_get_quick_print',
          'snmp_get_valueretrieval',
          'snmp_read_mib',
          'snmp_set_enum_print',
          'snmp_set_oid_numeric_print',
          'snmp_set_quick_print',
          'snmp_set_valueretrieval',
          'snmpget',
          'snmpgetnext',
          'snmprealwalk',
          'snmpset',
          'snmpwalk',
          'snmpwalkoid'],
 'SOAP': ['is_soap_fault'],
 'SQLite': ['sqlite_array_query',
            'sqlite_busy_timeout',
            'sqlite_changes',
            'sqlite_close',
            'sqlite_column',
            'sqlite_create_aggregate',
            'sqlite_create_function',
            'sqlite_current',
            'sqlite_error_string',
            'sqlite_escape_string',
            'sqlite_exec',
            'sqlite_factory',
            'sqlite_fetch_all',
            'sqlite_fetch_array',
            'sqlite_fetch_column_types',
            'sqlite_fetch_object',
            'sqlite_fetch_single',
            'sqlite_fetch_string',
            'sqlite_field_name',
            'sqlite_has_more',
            'sqlite_has_prev',
            'sqlite_last_error',
            'sqlite_last_insert_rowid',
            'sqlite_libencoding',
            'sqlite_libversion',
            'sqlite_next',
            'sqlite_num_fields',
            'sqlite_num_rows',
            'sqlite_open',
            'sqlite_popen',
            'sqlite_prev',
            'sqlite_query',
            'sqlite_rewind',
            'sqlite_seek',
            'sqlite_single_query',
            'sqlite_udf_decode_binary',
            'sqlite_udf_encode_binary',
            'sqlite_unbuffered_query'],
 'SWF': ['swf_actiongeturl',
         'swf_actiongotoframe',
         'swf_actiongotolabel',
         'swf_actionnextframe',
         'swf_actionplay',
         'swf_actionprevframe',
         'swf_actionsettarget',
         'swf_actionstop',
         'swf_actiontogglequality',
         'swf_actionwaitforframe',
         'swf_addbuttonrecord',
         'swf_addcolor',
         'swf_closefile',
         'swf_definebitmap',
         'swf_definefont',
         'swf_defineline',
         'swf_definepoly',
         'swf_definerect',
         'swf_definetext',
         'swf_endbutton',
         'swf_enddoaction',
         'swf_endshape',
         'swf_endsymbol',
         'swf_fontsize',
         'swf_fontslant',
         'swf_fonttracking',
         'swf_getbitmapinfo',
         'swf_getfontinfo',
         'swf_getframe',
         'swf_labelframe',
         'swf_lookat',
         'swf_modifyobject',
         'swf_mulcolor',
         'swf_nextid',
         'swf_oncondition',
         'swf_openfile',
         'swf_ortho',
         'swf_ortho2',
         'swf_perspective',
         'swf_placeobject',
         'swf_polarview',
         'swf_popmatrix',
         'swf_posround',
         'swf_pushmatrix',
         'swf_removeobject',
         'swf_rotate',
         'swf_scale',
         'swf_setfont',
         'swf_setframe',
         'swf_shapearc',
         'swf_shapecurveto',
         'swf_shapecurveto3',
         'swf_shapefillbitmapclip',
         'swf_shapefillbitmaptile',
         'swf_shapefilloff',
         'swf_shapefillsolid',
         'swf_shapelinesolid',
         'swf_shapelineto',
         'swf_shapemoveto',
         'swf_showframe',
         'swf_startbutton',
         'swf_startdoaction',
         'swf_startshape',
         'swf_startsymbol',
         'swf_textwidth',
         'swf_translate',
         'swf_viewport'],
 'Semaphore': ['ftok',
               'msg_get_queue',
               'msg_receive',
               'msg_remove_queue',
               'msg_send',
               'msg_set_queue',
               'msg_stat_queue',
               'sem_acquire',
               'sem_get',
               'sem_release',
               'sem_remove',
               'shm_attach',
               'shm_detach',
               'shm_get_var',
               'shm_put_var',
               'shm_remove',
               'shm_remove_var'],
 'Sessions': ['session_cache_expire',
              'session_cache_limiter',
              'session_commit',
              'session_decode',
              'session_destroy',
              'session_encode',
              'session_get_cookie_params',
              'session_id',
              'session_is_registered',
              'session_module_name',
              'session_name',
              'session_regenerate_id',
              'session_register',
              'session_save_path',
              'session_set_cookie_params',
              'session_set_save_handler',
              'session_start',
              'session_unregister',
              'session_unset',
              'session_write_close'],
 'SimpleXML': ['simplexml_import_dom',
               'simplexml_load_file',
               'simplexml_load_string'],
 'Sockets': ['socket_accept',
             'socket_bind',
             'socket_clear_error',
             'socket_close',
             'socket_connect',
             'socket_create',
             'socket_create_listen',
             'socket_create_pair',
             'socket_get_option',
             'socket_getpeername',
             'socket_getsockname',
             'socket_last_error',
             'socket_listen',
             'socket_read',
             'socket_recv',
             'socket_recvfrom',
             'socket_select',
             'socket_send',
             'socket_sendto',
             'socket_set_block',
             'socket_set_nonblock',
             'socket_set_option',
             'socket_shutdown',
             'socket_strerror',
             'socket_write'],
 'Streams': ['stream_context_create',
             'stream_context_get_default',
             'stream_context_get_options',
             'stream_context_set_option',
             'stream_context_set_params',
             'stream_copy_to_stream',
             'stream_filter_append',
             'stream_filter_prepend',
             'stream_filter_register',
             'stream_filter_remove',
             'stream_get_contents',
             'stream_get_filters',
             'stream_get_line',
             'stream_get_meta_data',
             'stream_get_transports',
             'stream_get_wrappers',
             'stream_register_wrapper',
             'stream_select',
             'stream_set_blocking',
             'stream_set_timeout',
             'stream_set_write_buffer',
             'stream_socket_accept',
             'stream_socket_client',
             'stream_socket_enable_crypto',
             'stream_socket_get_name',
             'stream_socket_pair',
             'stream_socket_recvfrom',
             'stream_socket_sendto',
             'stream_socket_server',
             'stream_wrapper_register',
             'stream_wrapper_restore',
             'stream_wrapper_unregister'],
 'Strings': ['addcslashes',
             'addslashes',
             'bin2hex',
             'chop',
             'chr',
             'chunk_split',
             'convert_cyr_string',
             'convert_uudecode',
             'convert_uuencode',
             'count_chars',
             'crc32',
             'crypt',
             'echo',
             'explode',
             'fprintf',
             'get_html_translation_table',
             'hebrev',
             'hebrevc',
             'html_entity_decode',
             'htmlentities',
             'htmlspecialchars',
             'implode',
             'join',
             'levenshtein',
             'localeconv',
             'ltrim',
             'md5',
             'md5_file',
             'metaphone',
             'money_format',
             'nl2br',
             'nl_langinfo',
             'number_format',
             'ord',
             'parse_str',
             'print',
             'printf',
             'quoted_printable_decode',
             'quotemeta',
             'rtrim',
             'setlocale',
             'sha1',
             'sha1_file',
             'similar_text',
             'soundex',
             'sprintf',
             'sscanf',
             'str_ireplace',
             'str_pad',
             'str_repeat',
             'str_replace',
             'str_rot13',
             'str_shuffle',
             'str_split',
             'str_word_count',
             'strcasecmp',
             'strchr',
             'strcmp',
             'strcoll',
             'strcspn',
             'strip_tags',
             'stripcslashes',
             'stripos',
             'stripslashes',
             'stristr',
             'strlen',
             'strnatcasecmp',
             'strnatcmp',
             'strncasecmp',
             'strncmp',
             'strpbrk',
             'strpos',
             'strrchr',
             'strrev',
             'strripos',
             'strrpos',
             'strspn',
             'strstr',
             'strtok',
             'strtolower',
             'strtoupper',
             'strtr',
             'substr',
             'substr_compare',
             'substr_count',
             'substr_replace',
             'trim',
             'ucfirst',
             'ucwords',
             'vfprintf',
             'vprintf',
             'vsprintf',
             'wordwrap'],
 'Sybase': ['sybase_affected_rows',
            'sybase_close',
            'sybase_connect',
            'sybase_data_seek',
            'sybase_deadlock_retry_count',
            'sybase_fetch_array',
            'sybase_fetch_assoc',
            'sybase_fetch_field',
            'sybase_fetch_object',
            'sybase_fetch_row',
            'sybase_field_seek',
            'sybase_free_result',
            'sybase_get_last_message',
            'sybase_min_client_severity',
            'sybase_min_error_severity',
            'sybase_min_message_severity',
            'sybase_min_server_severity',
            'sybase_num_fields',
            'sybase_num_rows',
            'sybase_pconnect',
            'sybase_query',
            'sybase_result',
            'sybase_select_db',
            'sybase_set_message_handler',
            'sybase_unbuffered_query'],
 'TCP Wrappers': ['tcpwrap_check'],
 'Tokenizer': ['token_get_all', 'token_name'],
 'URLs': ['base64_decode',
          'base64_encode',
          'get_headers',
          'get_meta_tags',
          'http_build_query',
          'parse_url',
          'rawurldecode',
          'rawurlencode',
          'urldecode',
          'urlencode'],
 'Variables handling': ['debug_zval_dump',
                        'doubleval',
                        'empty',
                        'floatval',
                        'get_defined_vars',
                        'get_resource_type',
                        'gettype',
                        'import_request_variables',
                        'intval',
                        'is_array',
                        'is_bool',
                        'is_callable',
                        'is_double',
                        'is_float',
                        'is_int',
                        'is_integer',
                        'is_long',
                        'is_null',
                        'is_numeric',
                        'is_object',
                        'is_real',
                        'is_resource',
                        'is_scalar',
                        'is_string',
                        'isset',
                        'print_r',
                        'serialize',
                        'settype',
                        'strval',
                        'unserialize',
                        'unset',
                        'var_dump',
                        'var_export'],
 'Verisign Payflow Pro': ['pfpro_cleanup',
                          'pfpro_init',
                          'pfpro_process',
                          'pfpro_process_raw',
                          'pfpro_version'],
 'W32api': ['w32api_deftype',
            'w32api_init_dtype',
            'w32api_invoke_function',
            'w32api_register_function',
            'w32api_set_call_method'],
 'WDDX': ['wddx_add_vars',
          'wddx_deserialize',
          'wddx_packet_end',
          'wddx_packet_start',
          'wddx_serialize_value',
          'wddx_serialize_vars'],
 'XML': ['utf8_decode',
         'utf8_encode',
         'xml_error_string',
         'xml_get_current_byte_index',
         'xml_get_current_column_number',
         'xml_get_current_line_number',
         'xml_get_error_code',
         'xml_parse',
         'xml_parse_into_struct',
         'xml_parser_create',
         'xml_parser_create_ns',
         'xml_parser_free',
         'xml_parser_get_option',
         'xml_parser_set_option',
         'xml_set_character_data_handler',
         'xml_set_default_handler',
         'xml_set_element_handler',
         'xml_set_end_namespace_decl_handler',
         'xml_set_external_entity_ref_handler',
         'xml_set_notation_decl_handler',
         'xml_set_object',
         'xml_set_processing_instruction_handler',
         'xml_set_start_namespace_decl_handler',
         'xml_set_unparsed_entity_decl_handler'],
 'XML-RPC': ['xmlrpc_decode',
             'xmlrpc_decode_request',
             'xmlrpc_encode',
             'xmlrpc_encode_request',
             'xmlrpc_get_type',
             'xmlrpc_is_fault',
             'xmlrpc_parse_method_descriptions',
             'xmlrpc_server_add_introspection_data',
             'xmlrpc_server_call_method',
             'xmlrpc_server_create',
             'xmlrpc_server_destroy',
             'xmlrpc_server_register_introspection_callback',
             'xmlrpc_server_register_method',
             'xmlrpc_set_type'],
 'XSL': ['xsl_xsltprocessor_get_parameter',
         'xsl_xsltprocessor_has_exslt_support',
         'xsl_xsltprocessor_import_stylesheet',
         'xsl_xsltprocessor_register_php_functions',
         'xsl_xsltprocessor_remove_parameter',
         'xsl_xsltprocessor_set_parameter',
         'xsl_xsltprocessor_transform_to_doc',
         'xsl_xsltprocessor_transform_to_uri',
         'xsl_xsltprocessor_transform_to_xml'],
 'XSLT': ['xslt_backend_info',
          'xslt_backend_name',
          'xslt_backend_version',
          'xslt_create',
          'xslt_errno',
          'xslt_error',
          'xslt_free',
          'xslt_getopt',
          'xslt_process',
          'xslt_set_base',
          'xslt_set_encoding',
          'xslt_set_error_handler',
          'xslt_set_log',
          'xslt_set_object',
          'xslt_set_sax_handler',
          'xslt_set_sax_handlers',
          'xslt_set_scheme_handler',
          'xslt_set_scheme_handlers',
          'xslt_setopt'],
 'YAZ': ['yaz_addinfo',
         'yaz_ccl_conf',
         'yaz_ccl_parse',
         'yaz_close',
         'yaz_connect',
         'yaz_database',
         'yaz_element',
         'yaz_errno',
         'yaz_error',
         'yaz_es_result',
         'yaz_get_option',
         'yaz_hits',
         'yaz_itemorder',
         'yaz_present',
         'yaz_range',
         'yaz_record',
         'yaz_scan',
         'yaz_scan_result',
         'yaz_schema',
         'yaz_search',
         'yaz_set_option',
         'yaz_sort',
         'yaz_syntax',
         'yaz_wait'],
 'YP/NIS': ['yp_all',
            'yp_cat',
            'yp_err_string',
            'yp_errno',
            'yp_first',
            'yp_get_default_domain',
            'yp_master',
            'yp_match',
            'yp_next',
            'yp_order'],
 'Zip': ['zip_close',
         'zip_entry_close',
         'zip_entry_compressedsize',
         'zip_entry_compressionmethod',
         'zip_entry_filesize',
         'zip_entry_name',
         'zip_entry_open',
         'zip_entry_read',
         'zip_open',
         'zip_read'],
 'Zlib': ['gzclose',
          'gzcompress',
          'gzdeflate',
          'gzencode',
          'gzeof',
          'gzfile',
          'gzgetc',
          'gzgets',
          'gzgetss',
          'gzinflate',
          'gzopen',
          'gzpassthru',
          'gzputs',
          'gzread',
          'gzrewind',
          'gzseek',
          'gztell',
          'gzuncompress',
          'gzwrite',
          'readgzfile',
          'zlib_get_coding_type'],
 'bcompiler': ['bcompiler_load',
               'bcompiler_load_exe',
               'bcompiler_parse_class',
               'bcompiler_read',
               'bcompiler_write_class',
               'bcompiler_write_constant',
               'bcompiler_write_exe_footer',
               'bcompiler_write_footer',
               'bcompiler_write_function',
               'bcompiler_write_functions_from_file',
               'bcompiler_write_header'],
 'ctype': ['ctype_alnum',
           'ctype_alpha',
           'ctype_cntrl',
           'ctype_digit',
           'ctype_graph',
           'ctype_lower',
           'ctype_print',
           'ctype_punct',
           'ctype_space',
           'ctype_upper',
           'ctype_xdigit'],
 'dBase': ['dbase_add_record',
           'dbase_close',
           'dbase_create',
           'dbase_delete_record',
           'dbase_get_header_info',
           'dbase_get_record',
           'dbase_get_record_with_names',
           'dbase_numfields',
           'dbase_numrecords',
           'dbase_open',
           'dbase_pack',
           'dbase_replace_record'],
 'dba': ['dba_close',
         'dba_delete',
         'dba_exists',
         'dba_fetch',
         'dba_firstkey',
         'dba_handlers',
         'dba_insert',
         'dba_key_split',
         'dba_list',
         'dba_nextkey',
         'dba_open',
         'dba_optimize',
         'dba_popen',
         'dba_replace',
         'dba_sync'],
 'dbx': ['dbx_close',
         'dbx_compare',
         'dbx_connect',
         'dbx_error',
         'dbx_escape_string',
         'dbx_fetch_row',
         'dbx_query',
         'dbx_sort'],
 'fam': ['fam_cancel_monitor',
         'fam_close',
         'fam_monitor_collection',
         'fam_monitor_directory',
         'fam_monitor_file',
         'fam_next_event',
         'fam_open',
         'fam_pending',
         'fam_resume_monitor',
         'fam_suspend_monitor'],
 'filePro': ['filepro',
             'filepro_fieldcount',
             'filepro_fieldname',
             'filepro_fieldtype',
             'filepro_fieldwidth',
             'filepro_retrieve',
             'filepro_rowcount'],
 'gettext': ['bind_textdomain_codeset',
             'bindtextdomain',
             'dcgettext',
             'dcngettext',
             'dgettext',
             'dngettext',
             'gettext',
             'ngettext',
             'textdomain'],
 'iconv': ['iconv',
           'iconv_get_encoding',
           'iconv_mime_decode',
           'iconv_mime_decode_headers',
           'iconv_mime_encode',
           'iconv_set_encoding',
           'iconv_strlen',
           'iconv_strpos',
           'iconv_strrpos',
           'iconv_substr',
           'ob_iconv_handler'],
 'id3': ['id3_get_frame_long_name',
         'id3_get_frame_short_name',
         'id3_get_genre_id',
         'id3_get_genre_list',
         'id3_get_genre_name',
         'id3_get_tag',
         'id3_get_version',
         'id3_remove_tag',
         'id3_set_tag'],
 'mSQL': ['msql',
          'msql_affected_rows',
          'msql_close',
          'msql_connect',
          'msql_create_db',
          'msql_createdb',
          'msql_data_seek',
          'msql_db_query',
          'msql_dbname',
          'msql_drop_db',
          'msql_error',
          'msql_fetch_array',
          'msql_fetch_field',
          'msql_fetch_object',
          'msql_fetch_row',
          'msql_field_flags',
          'msql_field_len',
          'msql_field_name',
          'msql_field_seek',
          'msql_field_table',
          'msql_field_type',
          'msql_fieldflags',
          'msql_fieldlen',
          'msql_fieldname',
          'msql_fieldtable',
          'msql_fieldtype',
          'msql_free_result',
          'msql_list_dbs',
          'msql_list_fields',
          'msql_list_tables',
          'msql_num_fields',
          'msql_num_rows',
          'msql_numfields',
          'msql_numrows',
          'msql_pconnect',
          'msql_query',
          'msql_regcase',
          'msql_result',
          'msql_select_db',
          'msql_tablename'],
 'mailparse': ['mailparse_determine_best_xfer_encoding',
               'mailparse_msg_create',
               'mailparse_msg_extract_part',
               'mailparse_msg_extract_part_file',
               'mailparse_msg_free',
               'mailparse_msg_get_part',
               'mailparse_msg_get_part_data',
               'mailparse_msg_get_structure',
               'mailparse_msg_parse',
               'mailparse_msg_parse_file',
               'mailparse_rfc822_parse_addresses',
               'mailparse_stream_encode',
               'mailparse_uudecode_all'],
 'mcrypt': ['mcrypt_cbc',
            'mcrypt_cfb',
            'mcrypt_create_iv',
            'mcrypt_decrypt',
            'mcrypt_ecb',
            'mcrypt_enc_get_algorithms_name',
            'mcrypt_enc_get_block_size',
            'mcrypt_enc_get_iv_size',
            'mcrypt_enc_get_key_size',
            'mcrypt_enc_get_modes_name',
            'mcrypt_enc_get_supported_key_sizes',
            'mcrypt_enc_is_block_algorithm',
            'mcrypt_enc_is_block_algorithm_mode',
            'mcrypt_enc_is_block_mode',
            'mcrypt_enc_self_test',
            'mcrypt_encrypt',
            'mcrypt_generic',
            'mcrypt_generic_deinit',
            'mcrypt_generic_end',
            'mcrypt_generic_init',
            'mcrypt_get_block_size',
            'mcrypt_get_cipher_name',
            'mcrypt_get_iv_size',
            'mcrypt_get_key_size',
            'mcrypt_list_algorithms',
            'mcrypt_list_modes',
            'mcrypt_module_close',
            'mcrypt_module_get_algo_block_size',
            'mcrypt_module_get_algo_key_size',
            'mcrypt_module_get_supported_key_sizes',
            'mcrypt_module_is_block_algorithm',
            'mcrypt_module_is_block_algorithm_mode',
            'mcrypt_module_is_block_mode',
            'mcrypt_module_open',
            'mcrypt_module_self_test',
            'mcrypt_ofb',
            'mdecrypt_generic'],
 'mhash': ['mhash',
           'mhash_count',
           'mhash_get_block_size',
           'mhash_get_hash_name',
           'mhash_keygen_s2k'],
 'mnoGoSearch': ['udm_add_search_limit',
                 'udm_alloc_agent',
                 'udm_alloc_agent_array',
                 'udm_api_version',
                 'udm_cat_list',
                 'udm_cat_path',
                 'udm_check_charset',
                 'udm_check_stored',
                 'udm_clear_search_limits',
                 'udm_close_stored',
                 'udm_crc32',
                 'udm_errno',
                 'udm_error',
                 'udm_find',
                 'udm_free_agent',
                 'udm_free_ispell_data',
                 'udm_free_res',
                 'udm_get_doc_count',
                 'udm_get_res_field',
                 'udm_get_res_param',
                 'udm_hash32',
                 'udm_load_ispell_data',
                 'udm_open_stored',
                 'udm_set_agent_param'],
 'muscat': ['muscat_close',
            'muscat_get',
            'muscat_give',
            'muscat_setup',
            'muscat_setup_net'],
 'mysqli': ['mysqli_affected_rows',
            'mysqli_autocommit',
            'mysqli_bind_param',
            'mysqli_bind_result',
            'mysqli_change_user',
            'mysqli_character_set_name',
            'mysqli_client_encoding',
            'mysqli_close',
            'mysqli_commit',
            'mysqli_connect',
            'mysqli_connect_errno',
            'mysqli_connect_error',
            'mysqli_data_seek',
            'mysqli_debug',
            'mysqli_disable_reads_from_master',
            'mysqli_disable_rpl_parse',
            'mysqli_dump_debug_info',
            'mysqli_embedded_connect',
            'mysqli_enable_reads_from_master',
            'mysqli_enable_rpl_parse',
            'mysqli_errno',
            'mysqli_error',
            'mysqli_escape_string',
            'mysqli_execute',
            'mysqli_fetch',
            'mysqli_fetch_array',
            'mysqli_fetch_assoc',
            'mysqli_fetch_field',
            'mysqli_fetch_field_direct',
            'mysqli_fetch_fields',
            'mysqli_fetch_lengths',
            'mysqli_fetch_object',
            'mysqli_fetch_row',
            'mysqli_field_count',
            'mysqli_field_seek',
            'mysqli_field_tell',
            'mysqli_free_result',
            'mysqli_get_client_info',
            'mysqli_get_client_version',
            'mysqli_get_host_info',
            'mysqli_get_metadata',
            'mysqli_get_proto_info',
            'mysqli_get_server_info',
            'mysqli_get_server_version',
            'mysqli_info',
            'mysqli_init',
            'mysqli_insert_id',
            'mysqli_kill',
            'mysqli_master_query',
            'mysqli_more_results',
            'mysqli_multi_query',
            'mysqli_next_result',
            'mysqli_num_fields',
            'mysqli_num_rows',
            'mysqli_options',
            'mysqli_param_count',
            'mysqli_ping',
            'mysqli_prepare',
            'mysqli_query',
            'mysqli_real_connect',
            'mysqli_real_escape_string',
            'mysqli_real_query',
            'mysqli_report',
            'mysqli_rollback',
            'mysqli_rpl_parse_enabled',
            'mysqli_rpl_probe',
            'mysqli_rpl_query_type',
            'mysqli_select_db',
            'mysqli_send_long_data',
            'mysqli_send_query',
            'mysqli_server_end',
            'mysqli_server_init',
            'mysqli_set_opt',
            'mysqli_sqlstate',
            'mysqli_ssl_set',
            'mysqli_stat',
            'mysqli_stmt_affected_rows',
            'mysqli_stmt_bind_param',
            'mysqli_stmt_bind_result',
            'mysqli_stmt_close',
            'mysqli_stmt_data_seek',
            'mysqli_stmt_errno',
            'mysqli_stmt_error',
            'mysqli_stmt_execute',
            'mysqli_stmt_fetch',
            'mysqli_stmt_free_result',
            'mysqli_stmt_init',
            'mysqli_stmt_num_rows',
            'mysqli_stmt_param_count',
            'mysqli_stmt_prepare',
            'mysqli_stmt_reset',
            'mysqli_stmt_result_metadata',
            'mysqli_stmt_send_long_data',
            'mysqli_stmt_sqlstate',
            'mysqli_stmt_store_result',
            'mysqli_store_result',
            'mysqli_thread_id',
            'mysqli_thread_safe',
            'mysqli_use_result',
            'mysqli_warning_count'],
 'openal': ['openal_buffer_create',
            'openal_buffer_data',
            'openal_buffer_destroy',
            'openal_buffer_get',
            'openal_buffer_loadwav',
            'openal_context_create',
            'openal_context_current',
            'openal_context_destroy',
            'openal_context_process',
            'openal_context_suspend',
            'openal_device_close',
            'openal_device_open',
            'openal_listener_get',
            'openal_listener_set',
            'openal_source_create',
            'openal_source_destroy',
            'openal_source_get',
            'openal_source_pause',
            'openal_source_play',
            'openal_source_rewind',
            'openal_source_set',
            'openal_source_stop',
            'openal_stream'],
 'qtdom': ['qdom_error', 'qdom_tree'],
 'shmop': ['shmop_close',
           'shmop_delete',
           'shmop_open',
           'shmop_read',
           'shmop_size',
           'shmop_write'],
 'spl': ['class_implements',
         'class_parents',
         'iterator-to-array',
         'iterator_count',
         'spl_classes'],
 'ssh2': ['ssh2_auth_none',
          'ssh2_auth_password',
          'ssh2_auth_pubkey_file',
          'ssh2_connect',
          'ssh2_exec',
          'ssh2_fetch_stream',
          'ssh2_fingerprint',
          'ssh2_methods_negotiated',
          'ssh2_scp_recv',
          'ssh2_scp_send',
          'ssh2_sftp',
          'ssh2_sftp_lstat',
          'ssh2_sftp_mkdir',
          'ssh2_sftp_readlink',
          'ssh2_sftp_realpath',
          'ssh2_sftp_rename',
          'ssh2_sftp_rmdir',
          'ssh2_sftp_stat',
          'ssh2_sftp_symlink',
          'ssh2_sftp_unlink',
          'ssh2_shell',
          'ssh2_tunnel'],
 'tidy': ['ob_tidyhandler',
          'tidy_access_count',
          'tidy_clean_repair',
          'tidy_config_count',
          'tidy_diagnose',
          'tidy_error_count',
          'tidy_get_body',
          'tidy_get_config',
          'tidy_get_error_buffer',
          'tidy_get_head',
          'tidy_get_html',
          'tidy_get_html_ver',
          'tidy_get_output',
          'tidy_get_release',
          'tidy_get_root',
          'tidy_get_status',
          'tidy_getopt',
          'tidy_is_xhtml',
          'tidy_is_xml',
          'tidy_load_config',
          'tidy_parse_file',
          'tidy_parse_string',
          'tidy_repair_file',
          'tidy_repair_string',
          'tidy_reset_config',
          'tidy_save_config',
          'tidy_set_encoding',
          'tidy_setopt',
          'tidy_warning_count'],
 'unknown': ['bcompile_write_file',
             'com',
             'dir',
             'dotnet',
             'hw_api_attribute',
             'hw_api_content',
             'hw_api_object',
             'imagepscopyfont',
             'mcve_adduser',
             'mcve_adduserarg',
             'mcve_bt',
             'mcve_checkstatus',
             'mcve_chkpwd',
             'mcve_chngpwd',
             'mcve_completeauthorizations',
             'mcve_connect',
             'mcve_connectionerror',
             'mcve_deleteresponse',
             'mcve_deletetrans',
             'mcve_deleteusersetup',
             'mcve_deluser',
             'mcve_destroyconn',
             'mcve_destroyengine',
             'mcve_disableuser',
             'mcve_edituser',
             'mcve_enableuser',
             'mcve_force',
             'mcve_getcell',
             'mcve_getcellbynum',
             'mcve_getcommadelimited',
             'mcve_getheader',
             'mcve_getuserarg',
             'mcve_getuserparam',
             'mcve_gft',
             'mcve_gl',
             'mcve_gut',
             'mcve_initconn',
             'mcve_initengine',
             'mcve_initusersetup',
             'mcve_iscommadelimited',
             'mcve_liststats',
             'mcve_listusers',
             'mcve_maxconntimeout',
             'mcve_monitor',
             'mcve_numcolumns',
             'mcve_numrows',
             'mcve_override',
             'mcve_parsecommadelimited',
             'mcve_ping',
             'mcve_preauth',
             'mcve_preauthcompletion',
             'mcve_qc',
             'mcve_responseparam',
             'mcve_return',
             'mcve_returncode',
             'mcve_returnstatus',
             'mcve_sale',
             'mcve_setblocking',
             'mcve_setdropfile',
             'mcve_setip',
             'mcve_setssl',
             'mcve_setssl_files',
             'mcve_settimeout',
             'mcve_settle',
             'mcve_text_avs',
             'mcve_text_code',
             'mcve_text_cv',
             'mcve_transactionauth',
             'mcve_transactionavs',
             'mcve_transactionbatch',
             'mcve_transactioncv',
             'mcve_transactionid',
             'mcve_transactionitem',
             'mcve_transactionssent',
             'mcve_transactiontext',
             'mcve_transinqueue',
             'mcve_transnew',
             'mcve_transparam',
             'mcve_transsend',
             'mcve_ub',
             'mcve_uwait',
             'mcve_verifyconnection',
             'mcve_verifysslcert',
             'mcve_void',
             'mysqli()',
             'pdf_open',
             'pdf_open_png',
             'pdf_set_font',
             'php_register_url_stream_wrapper',
             'php_stream_can_cast',
             'php_stream_cast',
             'php_stream_close',
             'php_stream_closedir',
             'php_stream_copy_to_mem',
             'php_stream_copy_to_stream',
             'php_stream_eof',
             'php_stream_filter_register_factory',
             'php_stream_filter_unregister_factory',
             'php_stream_flush',
             'php_stream_fopen_from_file',
             'php_stream_fopen_temporary_file',
             'php_stream_fopen_tmpfile',
             'php_stream_getc',
             'php_stream_gets',
             'php_stream_is',
             'php_stream_is_persistent',
             'php_stream_make_seekable',
             'php_stream_open_wrapper',
             'php_stream_open_wrapper_as_file',
             'php_stream_open_wrapper_ex',
             'php_stream_opendir',
             'php_stream_passthru',
             'php_stream_read',
             'php_stream_readdir',
             'php_stream_rewinddir',
             'php_stream_seek',
             'php_stream_sock_open_from_socket',
             'php_stream_sock_open_host',
             'php_stream_sock_open_unix',
             'php_stream_stat',
             'php_stream_stat_path',
             'php_stream_tell',
             'php_stream_write',
             'php_unregister_url_stream_wrapper',
             'swfbutton_keypress',
             'swfdisplayitem',
             'variant'],
 'vpopmail': ['vpopmail_add_alias_domain',
              'vpopmail_add_alias_domain_ex',
              'vpopmail_add_domain',
              'vpopmail_add_domain_ex',
              'vpopmail_add_user',
              'vpopmail_alias_add',
              'vpopmail_alias_del',
              'vpopmail_alias_del_domain',
              'vpopmail_alias_get',
              'vpopmail_alias_get_all',
              'vpopmail_auth_user',
              'vpopmail_del_domain',
              'vpopmail_del_domain_ex',
              'vpopmail_del_user',
              'vpopmail_error',
              'vpopmail_passwd',
              'vpopmail_set_user_quota'],
 'xattr': ['xattr_get',
           'xattr_list',
           'xattr_remove',
           'xattr_set',
           'xattr_supported'],
 'xdiff': ['xdiff_file_diff',
           'xdiff_file_diff_binary',
           'xdiff_file_merge3',
           'xdiff_file_patch',
           'xdiff_file_patch_binary',
           'xdiff_string_diff',
           'xdiff_string_diff_binary',
           'xdiff_string_merge3',
           'xdiff_string_patch',
           'xdiff_string_patch_binary']}


if __name__ == '__main__':
    import pprint
    import re
    import urllib
    _function_re = re.compile('<B\s+CLASS="function"\s*>(.*?)\(\)</B\s*>(?uism)')

    def get_php_functions():
        uf = urllib.urlopen('http://de.php.net/manual/en/index.functions.php')
        data = uf.read()
        uf.close()
        results = set()
        for match in _function_re.finditer(data):
            fn = match.group(1)
            if '-&#62;' not in fn and '::' not in fn:
                results.add(fn)
        # PY24: use sorted()
        results = list(results)
        results.sort()
        return results

    def get_function_module(func_name):
        fn = func_name.replace('_', '-')
        uf = urllib.urlopen('http://de.php.net/manual/en/function.%s.php' % fn)
        regex = re.compile('<li class="header up">'
                           '<a href="ref\..*?\.php">([a-zA-Z0-9\s]+)</a></li>')
        for line in uf:
            match = regex.search(line)
            if match:
                return match.group(1)

    print '>> Downloading Function Index'
    functions = get_php_functions()
    total = len(functions)
    print '%d functions found' % total
    modules = {}
    idx = 1
    for function_name in get_php_functions():
        print '>> %r (%d/%d)' % (function_name, idx, total)
        m = get_function_module(function_name)
        if m is None:
            print 'NOT_FOUND'
            m = 'unknown'
        else:
            print repr(m)
        modules.setdefault(m, []).append(function_name)
        idx += 1

    # extract useful sourcecode from this file
    f = open(__file__)
    try:
        content = f.read()
    finally:
        f.close()
    header = content[:content.find('MODULES = {')]
    footer = content[content.find("if __name__ == '__main__':"):]

    # write new file
    f = open(__file__, 'w')
    f.write(header)
    f.write('MODULES = %s\n\n' % pprint.pformat(modules))
    f.write(footer)
    f.close()
auto=[('BufAdd', 'BufAdd'), ('BufCreate', 'BufCreate'), ('BufDelete', 'BufDelete'), ('BufEnter', 'BufEnter'), ('BufFilePost', 'BufFilePost'), ('BufFilePre', 'BufFilePre'), ('BufHidden', 'BufHidden'), ('BufLeave', 'BufLeave'), ('BufNew', 'BufNew'), ('BufNewFile', 'BufNewFile'), ('BufRead', 'BufRead'), ('BufReadCmd', 'BufReadCmd'), ('BufReadPost', 'BufReadPost'), ('BufReadPre', 'BufReadPre'), ('BufUnload', 'BufUnload'), ('BufWinEnter', 'BufWinEnter'), ('BufWinLeave', 'BufWinLeave'), ('BufWipeout', 'BufWipeout'), ('BufWrite', 'BufWrite'), ('BufWriteCmd', 'BufWriteCmd'), ('BufWritePost', 'BufWritePost'), ('BufWritePre', 'BufWritePre'), ('Cmd', 'Cmd'), ('CmdwinEnter', 'CmdwinEnter'), ('CmdwinLeave', 'CmdwinLeave'), ('ColorScheme', 'ColorScheme'), ('CursorHold', 'CursorHold'), ('CursorHoldI', 'CursorHoldI'), ('CursorMoved', 'CursorMoved'), ('CursorMovedI', 'CursorMovedI'), ('EncodingChanged', 'EncodingChanged'), ('FileAppendCmd', 'FileAppendCmd'), ('FileAppendPost', 'FileAppendPost'), ('FileAppendPre', 'FileAppendPre'), ('FileChangedRO', 'FileChangedRO'), ('FileChangedShell', 'FileChangedShell'), ('FileChangedShellPost', 'FileChangedShellPost'), ('FileEncoding', 'FileEncoding'), ('FileReadCmd', 'FileReadCmd'), ('FileReadPost', 'FileReadPost'), ('FileReadPre', 'FileReadPre'), ('FileType', 'FileType'), ('FileWriteCmd', 'FileWriteCmd'), ('FileWritePost', 'FileWritePost'), ('FileWritePre', 'FileWritePre'), ('FilterReadPost', 'FilterReadPost'), ('FilterReadPre', 'FilterReadPre'), ('FilterWritePost', 'FilterWritePost'), ('FilterWritePre', 'FilterWritePre'), ('FocusGained', 'FocusGained'), ('FocusLost', 'FocusLost'), ('FuncUndefined', 'FuncUndefined'), ('GUIEnter', 'GUIEnter'), ('InsertChange', 'InsertChange'), ('InsertEnter', 'InsertEnter'), ('InsertLeave', 'InsertLeave'), ('MenuPopup', 'MenuPopup'), ('QuickFixCmdPost', 'QuickFixCmdPost'), ('QuickFixCmdPre', 'QuickFixCmdPre'), ('RemoteReply', 'RemoteReply'), ('SessionLoadPost', 'SessionLoadPost'), ('ShellCmdPost', 'ShellCmdPost'), ('ShellFilterPost', 'ShellFilterPost'), ('SourcePre', 'SourcePre'), ('SpellFileMissing', 'SpellFileMissing'), ('StdinReadPost', 'StdinReadPost'), ('StdinReadPre', 'StdinReadPre'), ('SwapExists', 'SwapExists'), ('Syntax', 'Syntax'), ('TabEnter', 'TabEnter'), ('TabLeave', 'TabLeave'), ('TermChanged', 'TermChanged'), ('TermResponse', 'TermResponse'), ('User', 'User'), ('UserGettingBored', 'UserGettingBored'), ('VimEnter', 'VimEnter'), ('VimLeave', 'VimLeave'), ('VimLeavePre', 'VimLeavePre'), ('VimResized', 'VimResized'), ('WinEnter', 'WinEnter'), ('WinLeave', 'WinLeave'), ('event', 'event')]
command=[('DeleteFirst', 'DeleteFirst'), ('Explore', 'Explore'), ('Hexplore', 'Hexplore'), ('I', 'I'), ('N', 'Next'), ('NetrwSettings', 'NetrwSettings'), ('Nread', 'Nread'), ('Nw', 'Nw'), ('P', 'Print'), ('Sexplore', 'Sexplore'), ('Vexplore', 'Vexplore'), ('X', 'X'), ('XMLent', 'XMLent'), ('XMLns', 'XMLns'), ('ab', 'abbreviate'), ('abc', 'abclear'), ('abo', 'aboveleft'), ('al', 'all'), ('ar', 'args'), ('arga', 'argadd'), ('argd', 'argdelete'), ('argdo', 'argdo'), ('arge', 'argedit'), ('argg', 'argglobal'), ('argl', 'arglocal'), ('argu', 'argument'), ('as', 'ascii'), ('b', 'buffer'), ('bN', 'bNext'), ('ba', 'ball'), ('bad', 'badd'), ('bd', 'bdelete'), ('be', 'be'), ('bel', 'belowright'), ('bf', 'bfirst'), ('bl', 'blast'), ('bm', 'bmodified'), ('bn', 'bnext'), ('bo', 'botright'), ('bp', 'bprevious'), ('br', 'brewind'), ('brea', 'break'), ('breaka', 'breakadd'), ('breakd', 'breakdel'), ('breakl', 'breaklist'), ('bro', 'browse'), ('bufdo', 'bufdo'), ('buffers', 'buffers'), ('bun', 'bunload'), ('bw', 'bwipeout'), ('c', 'change'), ('cN', 'cNext'), ('cNf', 'cNfile'), ('ca', 'cabbrev'), ('cabc', 'cabclear'), ('cad', 'caddexpr'), ('caddb', 'caddbuffer'), ('caddf', 'caddfile'), ('cal', 'call'), ('cat', 'catch'), ('cb', 'cbuffer'), ('cc', 'cc'), ('ccl', 'cclose'), ('cd', 'cd'), ('ce', 'center'), ('cex', 'cexpr'), ('cf', 'cfile'), ('cfir', 'cfirst'), ('cg', 'cgetfile'), ('cgetb', 'cgetbuffer'), ('cgete', 'cgetexpr'), ('changes', 'changes'), ('chd', 'chdir'), ('che', 'checkpath'), ('checkt', 'checktime'), ('cl', 'clist'), ('cla', 'clast'), ('clo', 'close'), ('cmapc', 'cmapclear'), ('cn', 'cnext'), ('cnew', 'cnewer'), ('cnf', 'cnfile'), ('cnorea', 'cnoreabbrev'), ('co', 'copy'), ('col', 'colder'), ('colo', 'colorscheme'), ('comc', 'comclear'), ('comp', 'compiler'), ('con', 'continue'), ('conf', 'confirm'), ('cope', 'copen'), ('cp', 'cprevious'), ('cpf', 'cpfile'), ('cq', 'cquit'), ('cr', 'crewind'), ('cu', 'cunmap'), ('cuna', 'cunabbrev'), ('cw', 'cwindow'), ('d', 'delete'), ('debugg', 'debuggreedy'), ('delc', 'delcommand'), ('delf', 'delfunction'), ('delm', 'delmarks'), ('di', 'display'), ('diffg', 'diffget'), ('diffoff', 'diffoff'), ('diffpatch', 'diffpatch'), ('diffpu', 'diffput'), ('diffsplit', 'diffsplit'), ('diffthis', 'diffthis'), ('diffu', 'diffupdate'), ('dig', 'digraphs'), ('dj', 'djump'), ('dl', 'dlist'), ('dr', 'drop'), ('ds', 'dsearch'), ('dsp', 'dsplit'), ('e', 'edit'), ('earlier', 'earlier'), ('echoe', 'echoerr'), ('echom', 'echomsg'), ('echon', 'echon'), ('el', 'else'), ('elsei', 'elseif'), ('em', 'emenu'), ('emenu', 'emenu'), ('en', 'endif'), ('endf', 'endfunction'), ('endfo', 'endfor'), ('endt', 'endtry'), ('endw', 'endwhile'), ('ene', 'enew'), ('ex', 'ex'), ('exi', 'exit'), ('exu', 'exusage'), ('f', 'file'), ('files', 'files'), ('filetype', 'filetype'), ('fin', 'find'), ('fina', 'finally'), ('fini', 'finish'), ('fir', 'first'), ('fix', 'fixdel'), ('fo', 'fold'), ('foldc', 'foldclose'), ('foldd', 'folddoopen'), ('folddoc', 'folddoclosed'), ('foldo', 'foldopen'), ('for', 'for'), ('fu', 'function'), ('go', 'goto'), ('gr', 'grep'), ('grepa', 'grepadd'), ('h', 'help'), ('ha', 'hardcopy'), ('helpf', 'helpfind'), ('helpg', 'helpgrep'), ('helpt', 'helptags'), ('hid', 'hide'), ('his', 'history'), ('ia', 'iabbrev'), ('iabc', 'iabclear'), ('if', 'if'), ('ij', 'ijump'), ('il', 'ilist'), ('imapc', 'imapclear'), ('in', 'in'), ('inorea', 'inoreabbrev'), ('is', 'isearch'), ('isp', 'isplit'), ('iu', 'iunmap'), ('iuna', 'iunabbrev'), ('j', 'join'), ('ju', 'jumps'), ('k', 'k'), ('kee', 'keepmarks'), ('keepalt', 'keepalt'), ('keepj', 'keepjumps'), ('l', 'list'), ('lN', 'lNext'), ('lNf', 'lNfile'), ('la', 'last'), ('lad', 'laddexpr'), ('laddb', 'laddbuffer'), ('laddf', 'laddfile'), ('lan', 'language'), ('later', 'later'), ('lb', 'lbuffer'), ('lc', 'lcd'), ('lch', 'lchdir'), ('lcl', 'lclose'), ('le', 'left'), ('lefta', 'leftabove'), ('lex', 'lexpr'), ('lf', 'lfile'), ('lfir', 'lfirst'), ('lg', 'lgetfile'), ('lgetb', 'lgetbuffer'), ('lgete', 'lgetexpr'), ('lgr', 'lgrep'), ('lgrepa', 'lgrepadd'), ('lh', 'lhelpgrep'), ('ll', 'll'), ('lla', 'llast'), ('lli', 'llist'), ('lm', 'lmap'), ('lmak', 'lmake'), ('lmapc', 'lmapclear'), ('ln', 'lnoremap'), ('lne', 'lnext'), ('lnew', 'lnewer'), ('lnf', 'lnfile'), ('lo', 'loadview'), ('loc', 'lockmarks'), ('lockv', 'lockvar'), ('lol', 'lolder'), ('lop', 'lopen'), ('lp', 'lprevious'), ('lpf', 'lpfile'), ('lr', 'lrewind'), ('ls', 'ls'), ('lt', 'ltag'), ('lu', 'lunmap'), ('lv', 'lvimgrep'), ('lvimgrepa', 'lvimgrepadd'), ('lw', 'lwindow'), ('m', 'move'), ('ma', 'mark'), ('mak', 'make'), ('marks', 'marks'), ('mat', 'match'), ('menut', 'menutranslate'), ('mk', 'mkexrc'), ('mks', 'mksession'), ('mksp', 'mkspell'), ('mkv', 'mkvimrc'), ('mkvie', 'mkview'), ('mod', 'mode'), ('mz', 'mzscheme'), ('mzf', 'mzfile'), ('n', 'next'), ('nbkey', 'nbkey'), ('new', 'new'), ('nmapc', 'nmapclear'), ('noh', 'nohlsearch'), ('norea', 'noreabbrev'), ('nu', 'number'), ('nun', 'nunmap'), ('o', 'open'), ('omapc', 'omapclear'), ('on', 'only'), ('opt', 'options'), ('ou', 'ounmap'), ('p', 'print'), ('pc', 'pclose'), ('pe', 'perl'), ('ped', 'pedit'), ('perld', 'perldo'), ('po', 'pop'), ('popu', 'popu'), ('popu', 'popup'), ('pp', 'ppop'), ('pre', 'preserve'), ('prev', 'previous'), ('prof', 'profile'), ('profd', 'profdel'), ('prompt', 'prompt'), ('promptf', 'promptfind'), ('promptr', 'promptrepl'), ('ps', 'psearch'), ('ptN', 'ptNext'), ('pta', 'ptag'), ('ptf', 'ptfirst'), ('ptj', 'ptjump'), ('ptl', 'ptlast'), ('ptn', 'ptnext'), ('ptp', 'ptprevious'), ('ptr', 'ptrewind'), ('pts', 'ptselect'), ('pu', 'put'), ('pw', 'pwd'), ('py', 'python'), ('pyf', 'pyfile'), ('q', 'quit'), ('qa', 'qall'), ('quita', 'quitall'), ('r', 'read'), ('rec', 'recover'), ('red', 'redo'), ('redi', 'redir'), ('redr', 'redraw'), ('redraws', 'redrawstatus'), ('reg', 'registers'), ('res', 'resize'), ('ret', 'retab'), ('retu', 'return'), ('rew', 'rewind'), ('ri', 'right'), ('rightb', 'rightbelow'), ('ru', 'runtime'), ('rub', 'ruby'), ('rubyd', 'rubydo'), ('rubyf', 'rubyfile'), ('rv', 'rviminfo'), ('sN', 'sNext'), ('sa', 'sargument'), ('sal', 'sall'), ('san', 'sandbox'), ('sav', 'saveas'), ('sb', 'sbuffer'), ('sbN', 'sbNext'), ('sba', 'sball'), ('sbf', 'sbfirst'), ('sbl', 'sblast'), ('sbm', 'sbmodified'), ('sbn', 'sbnext'), ('sbp', 'sbprevious'), ('sbr', 'sbrewind'), ('scrip', 'scriptnames'), ('scripte', 'scriptencoding'), ('se', 'set'), ('setf', 'setfiletype'), ('setg', 'setglobal'), ('setl', 'setlocal'), ('sf', 'sfind'), ('sfir', 'sfirst'), ('sh', 'shell'), ('sign', 'sign'), ('sil', 'silent'), ('sim', 'simalt'), ('sl', 'sleep'), ('sla', 'slast'), ('sm', 'smagic'), ('sm', 'smap'), ('smapc', 'smapclear'), ('sme', 'sme'), ('smenu', 'smenu'), ('sn', 'snext'), ('sni', 'sniff'), ('sno', 'snomagic'), ('snor', 'snoremap'), ('snoreme', 'snoreme'), ('snoremenu', 'snoremenu'), ('so', 'source'), ('sor', 'sort'), ('sp', 'split'), ('spe', 'spellgood'), ('spelld', 'spelldump'), ('spelli', 'spellinfo'), ('spellr', 'spellrepall'), ('spellu', 'spellundo'), ('spellw', 'spellwrong'), ('spr', 'sprevious'), ('sre', 'srewind'), ('st', 'stop'), ('sta', 'stag'), ('star', 'startinsert'), ('startg', 'startgreplace'), ('startr', 'startreplace'), ('stj', 'stjump'), ('stopi', 'stopinsert'), ('sts', 'stselect'), ('sun', 'sunhide'), ('sunm', 'sunmap'), ('sus', 'suspend'), ('sv', 'sview'), ('syncbind', 'syncbind'), ('t', 't'), ('tN', 'tNext'), ('ta', 'tag'), ('tab', 'tab'), ('tabN', 'tabNext'), ('tabc', 'tabclose'), ('tabd', 'tabdo'), ('tabe', 'tabedit'), ('tabf', 'tabfind'), ('tabfir', 'tabfirst'), ('tabl', 'tablast'), ('tabmove', 'tabmove'), ('tabn', 'tabnext'), ('tabnew', 'tabnew'), ('tabo', 'tabonly'), ('tabp', 'tabprevious'), ('tabr', 'tabrewind'), ('tabs', 'tabs'), ('tags', 'tags'), ('tc', 'tcl'), ('tcld', 'tcldo'), ('tclf', 'tclfile'), ('te', 'tearoff'), ('tf', 'tfirst'), ('th', 'throw'), ('the', 'the'), ('tj', 'tjump'), ('tl', 'tlast'), ('tm', 'tm'), ('tm', 'tmenu'), ('tn', 'tnext'), ('to', 'topleft'), ('tp', 'tprevious'), ('tr', 'trewind'), ('try', 'try'), ('ts', 'tselect'), ('tu', 'tu'), ('tu', 'tunmenu'), ('u', 'undo'), ('una', 'unabbreviate'), ('undoj', 'undojoin'), ('undol', 'undolist'), ('unh', 'unhide'), ('unlo', 'unlockvar'), ('unm', 'unmap'), ('up', 'update'), ('ve', 'version'), ('verb', 'verbose'), ('vert', 'vertical'), ('vi', 'visual'), ('vie', 'view'), ('vim', 'vimgrep'), ('vimgrepa', 'vimgrepadd'), ('viu', 'viusage'), ('vmapc', 'vmapclear'), ('vne', 'vnew'), ('vs', 'vsplit'), ('vu', 'vunmap'), ('w', 'write'), ('wN', 'wNext'), ('wa', 'wall'), ('wh', 'while'), ('win', 'winsize'), ('winc', 'wincmd'), ('windo', 'windo'), ('winp', 'winpos'), ('wn', 'wnext'), ('wp', 'wprevious'), ('wq', 'wq'), ('wqa', 'wqall'), ('ws', 'wsverb'), ('wv', 'wviminfo'), ('x', 'xit'), ('xa', 'xall'), ('xm', 'xmap'), ('xmapc', 'xmapclear'), ('xme', 'xme'), ('xmenu', 'xmenu'), ('xn', 'xnoremap'), ('xnoreme', 'xnoreme'), ('xnoremenu', 'xnoremenu'), ('xu', 'xunmap'), ('y', 'yank')]
option=[('acd', 'acd'), ('ai', 'ai'), ('akm', 'akm'), ('al', 'al'), ('aleph', 'aleph'), ('allowrevins', 'allowrevins'), ('altkeymap', 'altkeymap'), ('ambiwidth', 'ambiwidth'), ('ambw', 'ambw'), ('anti', 'anti'), ('antialias', 'antialias'), ('ar', 'ar'), ('arab', 'arab'), ('arabic', 'arabic'), ('arabicshape', 'arabicshape'), ('ari', 'ari'), ('arshape', 'arshape'), ('autochdir', 'autochdir'), ('autoindent', 'autoindent'), ('autoread', 'autoread'), ('autowrite', 'autowrite'), ('autowriteall', 'autowriteall'), ('aw', 'aw'), ('awa', 'awa'), ('background', 'background'), ('backspace', 'backspace'), ('backup', 'backup'), ('backupcopy', 'backupcopy'), ('backupdir', 'backupdir'), ('backupext', 'backupext'), ('backupskip', 'backupskip'), ('balloondelay', 'balloondelay'), ('ballooneval', 'ballooneval'), ('balloonexpr', 'balloonexpr'), ('bar', 'bar'), ('bdir', 'bdir'), ('bdlay', 'bdlay'), ('beval', 'beval'), ('bex', 'bex'), ('bexpr', 'bexpr'), ('bg', 'bg'), ('bh', 'bh'), ('bin', 'bin'), ('binary', 'binary'), ('biosk', 'biosk'), ('bioskey', 'bioskey'), ('bk', 'bk'), ('bkc', 'bkc'), ('bl', 'bl'), ('block', 'block'), ('bomb', 'bomb'), ('breakat', 'breakat'), ('brk', 'brk'), ('browsedir', 'browsedir'), ('bs', 'bs'), ('bsdir', 'bsdir'), ('bsk', 'bsk'), ('bt', 'bt'), ('bufhidden', 'bufhidden'), ('buflisted', 'buflisted'), ('buftype', 'buftype'), ('casemap', 'casemap'), ('cb', 'cb'), ('ccv', 'ccv'), ('cd', 'cd'), ('cdpath', 'cdpath'), ('cedit', 'cedit'), ('cf', 'cf'), ('cfu', 'cfu'), ('ch', 'ch'), ('charconvert', 'charconvert'), ('ci', 'ci'), ('cin', 'cin'), ('cindent', 'cindent'), ('cink', 'cink'), ('cinkeys', 'cinkeys'), ('cino', 'cino'), ('cinoptions', 'cinoptions'), ('cinw', 'cinw'), ('cinwords', 'cinwords'), ('clipboard', 'clipboard'), ('cmdheight', 'cmdheight'), ('cmdwinheight', 'cmdwinheight'), ('cmp', 'cmp'), ('cms', 'cms'), ('co', 'co'), ('columns', 'columns'), ('com', 'com'), ('comments', 'comments'), ('commentstring', 'commentstring'), ('compatible', 'compatible'), ('complete', 'complete'), ('completefunc', 'completefunc'), ('completeopt', 'completeopt'), ('confirm', 'confirm'), ('consk', 'consk'), ('conskey', 'conskey'), ('copyindent', 'copyindent'), ('cot', 'cot'), ('cp', 'cp'), ('cpo', 'cpo'), ('cpoptions', 'cpoptions'), ('cpt', 'cpt'), ('cscopepathcomp', 'cscopepathcomp'), ('cscopeprg', 'cscopeprg'), ('cscopequickfix', 'cscopequickfix'), ('cscopetag', 'cscopetag'), ('cscopetagorder', 'cscopetagorder'), ('cscopeverbose', 'cscopeverbose'), ('cspc', 'cspc'), ('csprg', 'csprg'), ('csqf', 'csqf'), ('cst', 'cst'), ('csto', 'csto'), ('csverb', 'csverb'), ('cuc', 'cuc'), ('cul', 'cul'), ('cursor', 'cursor'), ('cursor', 'cursor'), ('cursorcolumn', 'cursorcolumn'), ('cursorline', 'cursorline'), ('cwh', 'cwh'), ('debug', 'debug'), ('deco', 'deco'), ('def', 'def'), ('define', 'define'), ('delcombine', 'delcombine'), ('dex', 'dex'), ('dg', 'dg'), ('dict', 'dict'), ('dictionary', 'dictionary'), ('diff', 'diff'), ('diffexpr', 'diffexpr'), ('diffopt', 'diffopt'), ('digraph', 'digraph'), ('dip', 'dip'), ('dir', 'dir'), ('directory', 'directory'), ('display', 'display'), ('dy', 'dy'), ('ea', 'ea'), ('ead', 'ead'), ('eadirection', 'eadirection'), ('eb', 'eb'), ('ed', 'ed'), ('edcompatible', 'edcompatible'), ('ef', 'ef'), ('efm', 'efm'), ('ei', 'ei'), ('ek', 'ek'), ('enc', 'enc'), ('encoding', 'encoding'), ('end', 'end'), ('endofline', 'endofline'), ('eol', 'eol'), ('ep', 'ep'), ('equalalways', 'equalalways'), ('equalprg', 'equalprg'), ('errorbells', 'errorbells'), ('errorfile', 'errorfile'), ('errorformat', 'errorformat'), ('esckeys', 'esckeys'), ('et', 'et'), ('eventignore', 'eventignore'), ('ex', 'ex'), ('expandtab', 'expandtab'), ('exrc', 'exrc'), ('fcl', 'fcl'), ('fcs', 'fcs'), ('fdc', 'fdc'), ('fde', 'fde'), ('fdi', 'fdi'), ('fdl', 'fdl'), ('fdls', 'fdls'), ('fdm', 'fdm'), ('fdn', 'fdn'), ('fdo', 'fdo'), ('fdt', 'fdt'), ('fen', 'fen'), ('fenc', 'fenc'), ('fencs', 'fencs'), ('fex', 'fex'), ('ff', 'ff'), ('ffs', 'ffs'), ('fileencoding', 'fileencoding'), ('fileencodings', 'fileencodings'), ('fileformat', 'fileformat'), ('fileformats', 'fileformats'), ('filetype', 'filetype'), ('fillchars', 'fillchars'), ('fk', 'fk'), ('fkmap', 'fkmap'), ('flp', 'flp'), ('fml', 'fml'), ('fmr', 'fmr'), ('fo', 'fo'), ('foldclose', 'foldclose'), ('foldcolumn', 'foldcolumn'), ('foldenable', 'foldenable'), ('foldexpr', 'foldexpr'), ('foldignore', 'foldignore'), ('foldlevel', 'foldlevel'), ('foldlevelstart', 'foldlevelstart'), ('foldmarker', 'foldmarker'), ('foldmethod', 'foldmethod'), ('foldminlines', 'foldminlines'), ('foldnestmax', 'foldnestmax'), ('foldopen', 'foldopen'), ('foldtext', 'foldtext'), ('formatexpr', 'formatexpr'), ('formatlistpat', 'formatlistpat'), ('formatoptions', 'formatoptions'), ('formatprg', 'formatprg'), ('fp', 'fp'), ('fs', 'fs'), ('fsync', 'fsync'), ('ft', 'ft'), ('gcr', 'gcr'), ('gd', 'gd'), ('gdefault', 'gdefault'), ('gfm', 'gfm'), ('gfn', 'gfn'), ('gfs', 'gfs'), ('gfw', 'gfw'), ('ghr', 'ghr'), ('go', 'go'), ('gp', 'gp'), ('grepformat', 'grepformat'), ('grepprg', 'grepprg'), ('gtl', 'gtl'), ('gtt', 'gtt'), ('guicursor', 'guicursor'), ('guifont', 'guifont'), ('guifontset', 'guifontset'), ('guifontwide', 'guifontwide'), ('guiheadroom', 'guiheadroom'), ('guioptions', 'guioptions'), ('guipty', 'guipty'), ('guitablabel', 'guitablabel'), ('guitabtooltip', 'guitabtooltip'), ('helpfile', 'helpfile'), ('helpheight', 'helpheight'), ('helplang', 'helplang'), ('hf', 'hf'), ('hh', 'hh'), ('hi', 'hi'), ('hid', 'hid'), ('hidden', 'hidden'), ('highlight', 'highlight'), ('history', 'history'), ('hk', 'hk'), ('hkmap', 'hkmap'), ('hkmapp', 'hkmapp'), ('hkp', 'hkp'), ('hl', 'hl'), ('hlg', 'hlg'), ('hls', 'hls'), ('hlsearch', 'hlsearch'), ('ic', 'ic'), ('icon', 'icon'), ('iconstring', 'iconstring'), ('ignorecase', 'ignorecase'), ('im', 'im'), ('imactivatekey', 'imactivatekey'), ('imak', 'imak'), ('imc', 'imc'), ('imcmdline', 'imcmdline'), ('imd', 'imd'), ('imdisable', 'imdisable'), ('imi', 'imi'), ('iminsert', 'iminsert'), ('ims', 'ims'), ('imsearch', 'imsearch'), ('inc', 'inc'), ('include', 'include'), ('includeexpr', 'includeexpr'), ('incsearch', 'incsearch'), ('inde', 'inde'), ('indentexpr', 'indentexpr'), ('indentkeys', 'indentkeys'), ('indk', 'indk'), ('inex', 'inex'), ('inf', 'inf'), ('infercase', 'infercase'), ('insert', 'insert'), ('insert', 'insert'), ('insertmode', 'insertmode'), ('invacd', 'invacd'), ('invai', 'invai'), ('invakm', 'invakm'), ('invallowrevins', 'invallowrevins'), ('invaltkeymap', 'invaltkeymap'), ('invanti', 'invanti'), ('invantialias', 'invantialias'), ('invar', 'invar'), ('invarab', 'invarab'), ('invarabic', 'invarabic'), ('invarabicshape', 'invarabicshape'), ('invari', 'invari'), ('invarshape', 'invarshape'), ('invautochdir', 'invautochdir'), ('invautoindent', 'invautoindent'), ('invautoread', 'invautoread'), ('invautowrite', 'invautowrite'), ('invautowriteall', 'invautowriteall'), ('invaw', 'invaw'), ('invawa', 'invawa'), ('invbackup', 'invbackup'), ('invballooneval', 'invballooneval'), ('invbeval', 'invbeval'), ('invbin', 'invbin'), ('invbinary', 'invbinary'), ('invbiosk', 'invbiosk'), ('invbioskey', 'invbioskey'), ('invbk', 'invbk'), ('invbl', 'invbl'), ('invbomb', 'invbomb'), ('invbuflisted', 'invbuflisted'), ('invcf', 'invcf'), ('invci', 'invci'), ('invcin', 'invcin'), ('invcindent', 'invcindent'), ('invcompatible', 'invcompatible'), ('invconfirm', 'invconfirm'), ('invconsk', 'invconsk'), ('invconskey', 'invconskey'), ('invcopyindent', 'invcopyindent'), ('invcp', 'invcp'), ('invcscopetag', 'invcscopetag'), ('invcscopeverbose', 'invcscopeverbose'), ('invcst', 'invcst'), ('invcsverb', 'invcsverb'), ('invcuc', 'invcuc'), ('invcul', 'invcul'), ('invcursorcolumn', 'invcursorcolumn'), ('invcursorline', 'invcursorline'), ('invdeco', 'invdeco'), ('invdelcombine', 'invdelcombine'), ('invdg', 'invdg'), ('invdiff', 'invdiff'), ('invdigraph', 'invdigraph'), ('invdisable', 'invdisable'), ('invea', 'invea'), ('inveb', 'inveb'), ('inved', 'inved'), ('invedcompatible', 'invedcompatible'), ('invek', 'invek'), ('invendofline', 'invendofline'), ('inveol', 'inveol'), ('invequalalways', 'invequalalways'), ('inverrorbells', 'inverrorbells'), ('invesckeys', 'invesckeys'), ('invet', 'invet'), ('invex', 'invex'), ('invexpandtab', 'invexpandtab'), ('invexrc', 'invexrc'), ('invfen', 'invfen'), ('invfk', 'invfk'), ('invfkmap', 'invfkmap'), ('invfoldenable', 'invfoldenable'), ('invgd', 'invgd'), ('invgdefault', 'invgdefault'), ('invguipty', 'invguipty'), ('invhid', 'invhid'), ('invhidden', 'invhidden'), ('invhk', 'invhk'), ('invhkmap', 'invhkmap'), ('invhkmapp', 'invhkmapp'), ('invhkp', 'invhkp'), ('invhls', 'invhls'), ('invhlsearch', 'invhlsearch'), ('invic', 'invic'), ('invicon', 'invicon'), ('invignorecase', 'invignorecase'), ('invim', 'invim'), ('invimc', 'invimc'), ('invimcmdline', 'invimcmdline'), ('invimd', 'invimd'), ('invincsearch', 'invincsearch'), ('invinf', 'invinf'), ('invinfercase', 'invinfercase'), ('invinsertmode', 'invinsertmode'), ('invis', 'invis'), ('invjoinspaces', 'invjoinspaces'), ('invjs', 'invjs'), ('invlazyredraw', 'invlazyredraw'), ('invlbr', 'invlbr'), ('invlinebreak', 'invlinebreak'), ('invlisp', 'invlisp'), ('invlist', 'invlist'), ('invloadplugins', 'invloadplugins'), ('invlpl', 'invlpl'), ('invlz', 'invlz'), ('invma', 'invma'), ('invmacatsui', 'invmacatsui'), ('invmagic', 'invmagic'), ('invmh', 'invmh'), ('invml', 'invml'), ('invmod', 'invmod'), ('invmodeline', 'invmodeline'), ('invmodifiable', 'invmodifiable'), ('invmodified', 'invmodified'), ('invmore', 'invmore'), ('invmousef', 'invmousef'), ('invmousefocus', 'invmousefocus'), ('invmousehide', 'invmousehide'), ('invnu', 'invnu'), ('invnumber', 'invnumber'), ('invpaste', 'invpaste'), ('invpi', 'invpi'), ('invpreserveindent', 'invpreserveindent'), ('invpreviewwindow', 'invpreviewwindow'), ('invprompt', 'invprompt'), ('invpvw', 'invpvw'), ('invreadonly', 'invreadonly'), ('invremap', 'invremap'), ('invrestorescreen', 'invrestorescreen'), ('invrevins', 'invrevins'), ('invri', 'invri'), ('invrightleft', 'invrightleft'), ('invrightleftcmd', 'invrightleftcmd'), ('invrl', 'invrl'), ('invrlc', 'invrlc'), ('invro', 'invro'), ('invrs', 'invrs'), ('invru', 'invru'), ('invruler', 'invruler'), ('invsb', 'invsb'), ('invsc', 'invsc'), ('invscb', 'invscb'), ('invscrollbind', 'invscrollbind'), ('invscs', 'invscs'), ('invsecure', 'invsecure'), ('invsft', 'invsft'), ('invshellslash', 'invshellslash'), ('invshelltemp', 'invshelltemp'), ('invshiftround', 'invshiftround'), ('invshortname', 'invshortname'), ('invshowcmd', 'invshowcmd'), ('invshowfulltag', 'invshowfulltag'), ('invshowmatch', 'invshowmatch'), ('invshowmode', 'invshowmode'), ('invsi', 'invsi'), ('invsm', 'invsm'), ('invsmartcase', 'invsmartcase'), ('invsmartindent', 'invsmartindent'), ('invsmarttab', 'invsmarttab'), ('invsmd', 'invsmd'), ('invsn', 'invsn'), ('invsol', 'invsol'), ('invspell', 'invspell'), ('invsplitbelow', 'invsplitbelow'), ('invsplitright', 'invsplitright'), ('invspr', 'invspr'), ('invsr', 'invsr'), ('invssl', 'invssl'), ('invsta', 'invsta'), ('invstartofline', 'invstartofline'), ('invstmp', 'invstmp'), ('invswapfile', 'invswapfile'), ('invswf', 'invswf'), ('invta', 'invta'), ('invtagbsearch', 'invtagbsearch'), ('invtagrelative', 'invtagrelative'), ('invtagstack', 'invtagstack'), ('invtbi', 'invtbi'), ('invtbidi', 'invtbidi'), ('invtbs', 'invtbs'), ('invtermbidi', 'invtermbidi'), ('invterse', 'invterse'), ('invtextauto', 'invtextauto'), ('invtextmode', 'invtextmode'), ('invtf', 'invtf'), ('invtgst', 'invtgst'), ('invtildeop', 'invtildeop'), ('invtimeout', 'invtimeout'), ('invtitle', 'invtitle'), ('invto', 'invto'), ('invtop', 'invtop'), ('invtr', 'invtr'), ('invttimeout', 'invttimeout'), ('invttybuiltin', 'invttybuiltin'), ('invttyfast', 'invttyfast'), ('invtx', 'invtx'), ('invvb', 'invvb'), ('invvisualbell', 'invvisualbell'), ('invwa', 'invwa'), ('invwarn', 'invwarn'), ('invwb', 'invwb'), ('invweirdinvert', 'invweirdinvert'), ('invwfh', 'invwfh'), ('invwfw', 'invwfw'), ('invwildmenu', 'invwildmenu'), ('invwinfixheight', 'invwinfixheight'), ('invwinfixwidth', 'invwinfixwidth'), ('invwiv', 'invwiv'), ('invwmnu', 'invwmnu'), ('invwrap', 'invwrap'), ('invwrapscan', 'invwrapscan'), ('invwrite', 'invwrite'), ('invwriteany', 'invwriteany'), ('invwritebackup', 'invwritebackup'), ('invws', 'invws'), ('is', 'is'), ('isf', 'isf'), ('isfname', 'isfname'), ('isi', 'isi'), ('isident', 'isident'), ('isk', 'isk'), ('iskeyword', 'iskeyword'), ('isp', 'isp'), ('isprint', 'isprint'), ('joinspaces', 'joinspaces'), ('js', 'js'), ('key', 'key'), ('keymap', 'keymap'), ('keymodel', 'keymodel'), ('keywordprg', 'keywordprg'), ('km', 'km'), ('kmp', 'kmp'), ('kp', 'kp'), ('langmap', 'langmap'), ('langmenu', 'langmenu'), ('laststatus', 'laststatus'), ('lazyredraw', 'lazyredraw'), ('lbr', 'lbr'), ('lcs', 'lcs'), ('linebreak', 'linebreak'), ('lines', 'lines'), ('linespace', 'linespace'), ('lisp', 'lisp'), ('lispwords', 'lispwords'), ('list', 'list'), ('listchars', 'listchars'), ('lm', 'lm'), ('lmap', 'lmap'), ('loadplugins', 'loadplugins'), ('lpl', 'lpl'), ('ls', 'ls'), ('lsp', 'lsp'), ('lw', 'lw'), ('lz', 'lz'), ('ma', 'ma'), ('macatsui', 'macatsui'), ('magic', 'magic'), ('makeef', 'makeef'), ('makeprg', 'makeprg'), ('mat', 'mat'), ('matchpairs', 'matchpairs'), ('matchtime', 'matchtime'), ('maxcombine', 'maxcombine'), ('maxfuncdepth', 'maxfuncdepth'), ('maxmapdepth', 'maxmapdepth'), ('maxmem', 'maxmem'), ('maxmempattern', 'maxmempattern'), ('maxmemtot', 'maxmemtot'), ('mco', 'mco'), ('mef', 'mef'), ('menuitems', 'menuitems'), ('mfd', 'mfd'), ('mh', 'mh'), ('mis', 'mis'), ('mkspellmem', 'mkspellmem'), ('ml', 'ml'), ('mls', 'mls'), ('mm', 'mm'), ('mmd', 'mmd'), ('mmp', 'mmp'), ('mmt', 'mmt'), ('mod', 'mod'), ('mode', 'mode'), ('mode', 'mode'), ('modeline', 'modeline'), ('modelines', 'modelines'), ('modifiable', 'modifiable'), ('modified', 'modified'), ('more', 'more'), ('mouse', 'mouse'), ('mousef', 'mousef'), ('mousefocus', 'mousefocus'), ('mousehide', 'mousehide'), ('mousem', 'mousem'), ('mousemodel', 'mousemodel'), ('mouses', 'mouses'), ('mouseshape', 'mouseshape'), ('mouset', 'mouset'), ('mousetime', 'mousetime'), ('mp', 'mp'), ('mps', 'mps'), ('msm', 'msm'), ('mzq', 'mzq'), ('mzquantum', 'mzquantum'), ('nf', 'nf'), ('noacd', 'noacd'), ('noai', 'noai'), ('noakm', 'noakm'), ('noallowrevins', 'noallowrevins'), ('noaltkeymap', 'noaltkeymap'), ('noanti', 'noanti'), ('noantialias', 'noantialias'), ('noar', 'noar'), ('noarab', 'noarab'), ('noarabic', 'noarabic'), ('noarabicshape', 'noarabicshape'), ('noari', 'noari'), ('noarshape', 'noarshape'), ('noautochdir', 'noautochdir'), ('noautoindent', 'noautoindent'), ('noautoread', 'noautoread'), ('noautowrite', 'noautowrite'), ('noautowriteall', 'noautowriteall'), ('noaw', 'noaw'), ('noawa', 'noawa'), ('nobackup', 'nobackup'), ('noballooneval', 'noballooneval'), ('nobeval', 'nobeval'), ('nobin', 'nobin'), ('nobinary', 'nobinary'), ('nobiosk', 'nobiosk'), ('nobioskey', 'nobioskey'), ('nobk', 'nobk'), ('nobl', 'nobl'), ('nobomb', 'nobomb'), ('nobuflisted', 'nobuflisted'), ('nocf', 'nocf'), ('noci', 'noci'), ('nocin', 'nocin'), ('nocindent', 'nocindent'), ('nocompatible', 'nocompatible'), ('noconfirm', 'noconfirm'), ('noconsk', 'noconsk'), ('noconskey', 'noconskey'), ('nocopyindent', 'nocopyindent'), ('nocp', 'nocp'), ('nocscopetag', 'nocscopetag'), ('nocscopeverbose', 'nocscopeverbose'), ('nocst', 'nocst'), ('nocsverb', 'nocsverb'), ('nocuc', 'nocuc'), ('nocul', 'nocul'), ('nocursorcolumn', 'nocursorcolumn'), ('nocursorline', 'nocursorline'), ('nodeco', 'nodeco'), ('nodelcombine', 'nodelcombine'), ('nodg', 'nodg'), ('nodiff', 'nodiff'), ('nodigraph', 'nodigraph'), ('nodisable', 'nodisable'), ('noea', 'noea'), ('noeb', 'noeb'), ('noed', 'noed'), ('noedcompatible', 'noedcompatible'), ('noek', 'noek'), ('noendofline', 'noendofline'), ('noeol', 'noeol'), ('noequalalways', 'noequalalways'), ('noerrorbells', 'noerrorbells'), ('noesckeys', 'noesckeys'), ('noet', 'noet'), ('noex', 'noex'), ('noexpandtab', 'noexpandtab'), ('noexrc', 'noexrc'), ('nofen', 'nofen'), ('nofk', 'nofk'), ('nofkmap', 'nofkmap'), ('nofoldenable', 'nofoldenable'), ('nogd', 'nogd'), ('nogdefault', 'nogdefault'), ('noguipty', 'noguipty'), ('nohid', 'nohid'), ('nohidden', 'nohidden'), ('nohk', 'nohk'), ('nohkmap', 'nohkmap'), ('nohkmapp', 'nohkmapp'), ('nohkp', 'nohkp'), ('nohls', 'nohls'), ('nohlsearch', 'nohlsearch'), ('noic', 'noic'), ('noicon', 'noicon'), ('noignorecase', 'noignorecase'), ('noim', 'noim'), ('noimc', 'noimc'), ('noimcmdline', 'noimcmdline'), ('noimd', 'noimd'), ('noincsearch', 'noincsearch'), ('noinf', 'noinf'), ('noinfercase', 'noinfercase'), ('noinsertmode', 'noinsertmode'), ('nois', 'nois'), ('nojoinspaces', 'nojoinspaces'), ('nojs', 'nojs'), ('nolazyredraw', 'nolazyredraw'), ('nolbr', 'nolbr'), ('nolinebreak', 'nolinebreak'), ('nolisp', 'nolisp'), ('nolist', 'nolist'), ('noloadplugins', 'noloadplugins'), ('nolpl', 'nolpl'), ('nolz', 'nolz'), ('noma', 'noma'), ('nomacatsui', 'nomacatsui'), ('nomagic', 'nomagic'), ('nomh', 'nomh'), ('noml', 'noml'), ('nomod', 'nomod'), ('nomodeline', 'nomodeline'), ('nomodifiable', 'nomodifiable'), ('nomodified', 'nomodified'), ('nomore', 'nomore'), ('nomousef', 'nomousef'), ('nomousefocus', 'nomousefocus'), ('nomousehide', 'nomousehide'), ('nonu', 'nonu'), ('nonumber', 'nonumber'), ('nopaste', 'nopaste'), ('nopi', 'nopi'), ('nopreserveindent', 'nopreserveindent'), ('nopreviewwindow', 'nopreviewwindow'), ('noprompt', 'noprompt'), ('nopvw', 'nopvw'), ('noreadonly', 'noreadonly'), ('noremap', 'noremap'), ('norestorescreen', 'norestorescreen'), ('norevins', 'norevins'), ('nori', 'nori'), ('norightleft', 'norightleft'), ('norightleftcmd', 'norightleftcmd'), ('norl', 'norl'), ('norlc', 'norlc'), ('noro', 'noro'), ('nors', 'nors'), ('noru', 'noru'), ('noruler', 'noruler'), ('nosb', 'nosb'), ('nosc', 'nosc'), ('noscb', 'noscb'), ('noscrollbind', 'noscrollbind'), ('noscs', 'noscs'), ('nosecure', 'nosecure'), ('nosft', 'nosft'), ('noshellslash', 'noshellslash'), ('noshelltemp', 'noshelltemp'), ('noshiftround', 'noshiftround'), ('noshortname', 'noshortname'), ('noshowcmd', 'noshowcmd'), ('noshowfulltag', 'noshowfulltag'), ('noshowmatch', 'noshowmatch'), ('noshowmode', 'noshowmode'), ('nosi', 'nosi'), ('nosm', 'nosm'), ('nosmartcase', 'nosmartcase'), ('nosmartindent', 'nosmartindent'), ('nosmarttab', 'nosmarttab'), ('nosmd', 'nosmd'), ('nosn', 'nosn'), ('nosol', 'nosol'), ('nospell', 'nospell'), ('nosplitbelow', 'nosplitbelow'), ('nosplitright', 'nosplitright'), ('nospr', 'nospr'), ('nosr', 'nosr'), ('nossl', 'nossl'), ('nosta', 'nosta'), ('nostartofline', 'nostartofline'), ('nostmp', 'nostmp'), ('noswapfile', 'noswapfile'), ('noswf', 'noswf'), ('nota', 'nota'), ('notagbsearch', 'notagbsearch'), ('notagrelative', 'notagrelative'), ('notagstack', 'notagstack'), ('notbi', 'notbi'), ('notbidi', 'notbidi'), ('notbs', 'notbs'), ('notermbidi', 'notermbidi'), ('noterse', 'noterse'), ('notextauto', 'notextauto'), ('notextmode', 'notextmode'), ('notf', 'notf'), ('notgst', 'notgst'), ('notildeop', 'notildeop'), ('notimeout', 'notimeout'), ('notitle', 'notitle'), ('noto', 'noto'), ('notop', 'notop'), ('notr', 'notr'), ('nottimeout', 'nottimeout'), ('nottybuiltin', 'nottybuiltin'), ('nottyfast', 'nottyfast'), ('notx', 'notx'), ('novb', 'novb'), ('novisualbell', 'novisualbell'), ('nowa', 'nowa'), ('nowarn', 'nowarn'), ('nowb', 'nowb'), ('noweirdinvert', 'noweirdinvert'), ('nowfh', 'nowfh'), ('nowfw', 'nowfw'), ('nowildmenu', 'nowildmenu'), ('nowinfixheight', 'nowinfixheight'), ('nowinfixwidth', 'nowinfixwidth'), ('nowiv', 'nowiv'), ('nowmnu', 'nowmnu'), ('nowrap', 'nowrap'), ('nowrapscan', 'nowrapscan'), ('nowrite', 'nowrite'), ('nowriteany', 'nowriteany'), ('nowritebackup', 'nowritebackup'), ('nows', 'nows'), ('nrformats', 'nrformats'), ('nu', 'nu'), ('number', 'number'), ('numberwidth', 'numberwidth'), ('nuw', 'nuw'), ('oft', 'oft'), ('ofu', 'ofu'), ('omnifunc', 'omnifunc'), ('operatorfunc', 'operatorfunc'), ('opfunc', 'opfunc'), ('osfiletype', 'osfiletype'), ('pa', 'pa'), ('para', 'para'), ('paragraphs', 'paragraphs'), ('paste', 'paste'), ('pastetoggle', 'pastetoggle'), ('patchexpr', 'patchexpr'), ('patchmode', 'patchmode'), ('path', 'path'), ('pdev', 'pdev'), ('penc', 'penc'), ('pex', 'pex'), ('pexpr', 'pexpr'), ('pfn', 'pfn'), ('ph', 'ph'), ('pheader', 'pheader'), ('pi', 'pi'), ('pm', 'pm'), ('pmbcs', 'pmbcs'), ('pmbfn', 'pmbfn'), ('popt', 'popt'), ('preserveindent', 'preserveindent'), ('previewheight', 'previewheight'), ('previewwindow', 'previewwindow'), ('printdevice', 'printdevice'), ('printencoding', 'printencoding'), ('printexpr', 'printexpr'), ('printfont', 'printfont'), ('printheader', 'printheader'), ('printmbcharset', 'printmbcharset'), ('printmbfont', 'printmbfont'), ('printoptions', 'printoptions'), ('prompt', 'prompt'), ('pt', 'pt'), ('pumheight', 'pumheight'), ('pvh', 'pvh'), ('pvw', 'pvw'), ('qe', 'qe'), ('quoteescape', 'quoteescape'), ('readonly', 'readonly'), ('remap', 'remap'), ('report', 'report'), ('restorescreen', 'restorescreen'), ('revins', 'revins'), ('ri', 'ri'), ('rightleft', 'rightleft'), ('rightleftcmd', 'rightleftcmd'), ('rl', 'rl'), ('rlc', 'rlc'), ('ro', 'ro'), ('rs', 'rs'), ('rtp', 'rtp'), ('ru', 'ru'), ('ruf', 'ruf'), ('ruler', 'ruler'), ('rulerformat', 'rulerformat'), ('runtimepath', 'runtimepath'), ('sb', 'sb'), ('sbo', 'sbo'), ('sbr', 'sbr'), ('sc', 'sc'), ('scb', 'scb'), ('scr', 'scr'), ('scroll', 'scroll'), ('scrollbind', 'scrollbind'), ('scrolljump', 'scrolljump'), ('scrolloff', 'scrolloff'), ('scrollopt', 'scrollopt'), ('scs', 'scs'), ('sect', 'sect'), ('sections', 'sections'), ('secure', 'secure'), ('sel', 'sel'), ('selection', 'selection'), ('selectmode', 'selectmode'), ('sessionoptions', 'sessionoptions'), ('sft', 'sft'), ('sh', 'sh'), ('shape', 'shape'), ('shape', 'shape'), ('shcf', 'shcf'), ('shell', 'shell'), ('shellcmdflag', 'shellcmdflag'), ('shellpipe', 'shellpipe'), ('shellquote', 'shellquote'), ('shellredir', 'shellredir'), ('shellslash', 'shellslash'), ('shelltemp', 'shelltemp'), ('shelltype', 'shelltype'), ('shellxquote', 'shellxquote'), ('shiftround', 'shiftround'), ('shiftwidth', 'shiftwidth'), ('shm', 'shm'), ('shortmess', 'shortmess'), ('shortname', 'shortname'), ('showbreak', 'showbreak'), ('showcmd', 'showcmd'), ('showfulltag', 'showfulltag'), ('showmatch', 'showmatch'), ('showmode', 'showmode'), ('showtabline', 'showtabline'), ('shq', 'shq'), ('si', 'si'), ('sidescroll', 'sidescroll'), ('sidescrolloff', 'sidescrolloff'), ('siso', 'siso'), ('sj', 'sj'), ('slm', 'slm'), ('sm', 'sm'), ('smartcase', 'smartcase'), ('smartindent', 'smartindent'), ('smarttab', 'smarttab'), ('smc', 'smc'), ('smd', 'smd'), ('sn', 'sn'), ('so', 'so'), ('softtabstop', 'softtabstop'), ('sol', 'sol'), ('sp', 'sp'), ('spc', 'spc'), ('spell', 'spell'), ('spellcapcheck', 'spellcapcheck'), ('spellfile', 'spellfile'), ('spelllang', 'spelllang'), ('spellsuggest', 'spellsuggest'), ('spf', 'spf'), ('spl', 'spl'), ('splitbelow', 'splitbelow'), ('splitright', 'splitright'), ('spr', 'spr'), ('sps', 'sps'), ('sr', 'sr'), ('srr', 'srr'), ('ss', 'ss'), ('ssl', 'ssl'), ('ssop', 'ssop'), ('st', 'st'), ('sta', 'sta'), ('stal', 'stal'), ('start', 'start'), ('startofline', 'startofline'), ('statusline', 'statusline'), ('stl', 'stl'), ('stmp', 'stmp'), ('sts', 'sts'), ('su', 'su'), ('sua', 'sua'), ('suffixes', 'suffixes'), ('suffixesadd', 'suffixesadd'), ('sw', 'sw'), ('swapfile', 'swapfile'), ('swapsync', 'swapsync'), ('swb', 'swb'), ('swf', 'swf'), ('switchbuf', 'switchbuf'), ('sws', 'sws'), ('sxq', 'sxq'), ('syn', 'syn'), ('synmaxcol', 'synmaxcol'), ('syntax', 'syntax'), ('t_AB', 't_AB'), ('t_AF', 't_AF'), ('t_AL', 't_AL'), ('t_CS', 't_CS'), ('t_CV', 't_CV'), ('t_Ce', 't_Ce'), ('t_Co', 't_Co'), ('t_Cs', 't_Cs'), ('t_DL', 't_DL'), ('t_EI', 't_EI'), ('t_EI', 't_EI'), ('t_EI', 't_EI'), ('t_F1', 't_F1'), ('t_F2', 't_F2'), ('t_F3', 't_F3'), ('t_F4', 't_F4'), ('t_F5', 't_F5'), ('t_F6', 't_F6'), ('t_F7', 't_F7'), ('t_F8', 't_F8'), ('t_F9', 't_F9'), ('t_IE', 't_IE'), ('t_IS', 't_IS'), ('t_K1', 't_K1'), ('t_K3', 't_K3'), ('t_K4', 't_K4'), ('t_K5', 't_K5'), ('t_K6', 't_K6'), ('t_K7', 't_K7'), ('t_K8', 't_K8'), ('t_K9', 't_K9'), ('t_KA', 't_KA'), ('t_KB', 't_KB'), ('t_KC', 't_KC'), ('t_KD', 't_KD'), ('t_KE', 't_KE'), ('t_KF', 't_KF'), ('t_KG', 't_KG'), ('t_KH', 't_KH'), ('t_KI', 't_KI'), ('t_KJ', 't_KJ'), ('t_KK', 't_KK'), ('t_KL', 't_KL'), ('t_RI', 't_RI'), ('t_RV', 't_RV'), ('t_SI', 't_SI'), ('t_SI', 't_SI'), ('t_SI', 't_SI'), ('t_Sb', 't_Sb'), ('t_Sf', 't_Sf'), ('t_WP', 't_WP'), ('t_WS', 't_WS'), ('t_ZH', 't_ZH'), ('t_ZR', 't_ZR'), ('t_al', 't_al'), ('t_bc', 't_bc'), ('t_cd', 't_cd'), ('t_ce', 't_ce'), ('t_cl', 't_cl'), ('t_cm', 't_cm'), ('t_cs', 't_cs'), ('t_da', 't_da'), ('t_db', 't_db'), ('t_dl', 't_dl'), ('t_fs', 't_fs'), ('t_k1', 't_k1'), ('t_k2', 't_k2'), ('t_k3', 't_k3'), ('t_k4', 't_k4'), ('t_k5', 't_k5'), ('t_k6', 't_k6'), ('t_k7', 't_k7'), ('t_k8', 't_k8'), ('t_k9', 't_k9'), ('t_kB', 't_kB'), ('t_kD', 't_kD'), ('t_kI', 't_kI'), ('t_kN', 't_kN'), ('t_kP', 't_kP'), ('t_kb', 't_kb'), ('t_kd', 't_kd'), ('t_ke', 't_ke'), ('t_kh', 't_kh'), ('t_kl', 't_kl'), ('t_kr', 't_kr'), ('t_ks', 't_ks'), ('t_ku', 't_ku'), ('t_le', 't_le'), ('t_mb', 't_mb'), ('t_md', 't_md'), ('t_me', 't_me'), ('t_mr', 't_mr'), ('t_ms', 't_ms'), ('t_nd', 't_nd'), ('t_op', 't_op'), ('t_se', 't_se'), ('t_so', 't_so'), ('t_sr', 't_sr'), ('t_te', 't_te'), ('t_ti', 't_ti'), ('t_ts', 't_ts'), ('t_ue', 't_ue'), ('t_us', 't_us'), ('t_ut', 't_ut'), ('t_vb', 't_vb'), ('t_ve', 't_ve'), ('t_vi', 't_vi'), ('t_vs', 't_vs'), ('t_xs', 't_xs'), ('ta', 'ta'), ('tabline', 'tabline'), ('tabpagemax', 'tabpagemax'), ('tabstop', 'tabstop'), ('tag', 'tag'), ('tagbsearch', 'tagbsearch'), ('taglength', 'taglength'), ('tagrelative', 'tagrelative'), ('tags', 'tags'), ('tagstack', 'tagstack'), ('tal', 'tal'), ('tb', 'tb'), ('tbi', 'tbi'), ('tbidi', 'tbidi'), ('tbis', 'tbis'), ('tbs', 'tbs'), ('tenc', 'tenc'), ('term', 'term'), ('termbidi', 'termbidi'), ('termencoding', 'termencoding'), ('terse', 'terse'), ('textauto', 'textauto'), ('textmode', 'textmode'), ('textwidth', 'textwidth'), ('tf', 'tf'), ('tgst', 'tgst'), ('thesaurus', 'thesaurus'), ('tildeop', 'tildeop'), ('timeout', 'timeout'), ('timeoutlen', 'timeoutlen'), ('title', 'title'), ('titlelen', 'titlelen'), ('titleold', 'titleold'), ('titlestring', 'titlestring'), ('tl', 'tl'), ('tm', 'tm'), ('to', 'to'), ('toolbar', 'toolbar'), ('toolbariconsize', 'toolbariconsize'), ('top', 'top'), ('tpm', 'tpm'), ('tr', 'tr'), ('ts', 'ts'), ('tsl', 'tsl'), ('tsr', 'tsr'), ('ttimeout', 'ttimeout'), ('ttimeoutlen', 'ttimeoutlen'), ('ttm', 'ttm'), ('tty', 'tty'), ('ttybuiltin', 'ttybuiltin'), ('ttyfast', 'ttyfast'), ('ttym', 'ttym'), ('ttymouse', 'ttymouse'), ('ttyscroll', 'ttyscroll'), ('ttytype', 'ttytype'), ('tw', 'tw'), ('tx', 'tx'), ('uc', 'uc'), ('ul', 'ul'), ('undolevels', 'undolevels'), ('updatecount', 'updatecount'), ('updatetime', 'updatetime'), ('ut', 'ut'), ('vb', 'vb'), ('vbs', 'vbs'), ('vdir', 'vdir'), ('ve', 've'), ('verbose', 'verbose'), ('verbosefile', 'verbosefile'), ('vfile', 'vfile'), ('vi', 'vi'), ('viewdir', 'viewdir'), ('viewoptions', 'viewoptions'), ('viminfo', 'viminfo'), ('virtualedit', 'virtualedit'), ('visualbell', 'visualbell'), ('vop', 'vop'), ('wa', 'wa'), ('wak', 'wak'), ('warn', 'warn'), ('wb', 'wb'), ('wc', 'wc'), ('wcm', 'wcm'), ('wd', 'wd'), ('weirdinvert', 'weirdinvert'), ('wfh', 'wfh'), ('wfw', 'wfw'), ('wh', 'wh'), ('whichwrap', 'whichwrap'), ('wi', 'wi'), ('wig', 'wig'), ('wildchar', 'wildchar'), ('wildcharm', 'wildcharm'), ('wildignore', 'wildignore'), ('wildmenu', 'wildmenu'), ('wildmode', 'wildmode'), ('wildoptions', 'wildoptions'), ('wim', 'wim'), ('winaltkeys', 'winaltkeys'), ('window', 'window'), ('winfixheight', 'winfixheight'), ('winfixwidth', 'winfixwidth'), ('winheight', 'winheight'), ('winminheight', 'winminheight'), ('winminwidth', 'winminwidth'), ('winwidth', 'winwidth'), ('wiv', 'wiv'), ('wiw', 'wiw'), ('wm', 'wm'), ('wmh', 'wmh'), ('wmnu', 'wmnu'), ('wmw', 'wmw'), ('wop', 'wop'), ('wrap', 'wrap'), ('wrapmargin', 'wrapmargin'), ('wrapscan', 'wrapscan'), ('write', 'write'), ('writeany', 'writeany'), ('writebackup', 'writebackup'), ('writedelay', 'writedelay'), ('ws', 'ws'), ('ww', 'ww')]
# -*- coding: utf-8 -*-
"""
    pygments.lexers.agile
    ~~~~~~~~~~~~~~~~~~~~~

    Lexers for agile languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.lexer import Lexer, RegexLexer, ExtendedRegexLexer, \
     LexerContext, include, combined, do_insertions, bygroups, using
from pygments.token import Error, Text, \
     Comment, Operator, Keyword, Name, String, Number, Generic, Punctuation
from pygments.util import get_bool_opt, get_list_opt, shebang_matches
from pygments import unistring as uni


__all__ = ['PythonLexer', 'PythonConsoleLexer', 'PythonTracebackLexer',
           'RubyLexer', 'RubyConsoleLexer', 'PerlLexer', 'LuaLexer',
           'MiniDLexer', 'IoLexer', 'TclLexer', 'ClojureLexer',
           'Python3Lexer', 'Python3TracebackLexer']

# b/w compatibility
from pygments.lexers.functional import SchemeLexer

line_re  = re.compile('.*?\n')


class PythonLexer(RegexLexer):
    """
    For `Python <http://www.python.org>`_ source code.
    """

    name = 'Python'
    aliases = ['python', 'py']
    filenames = ['*.py', '*.pyw', '*.sc', 'SConstruct', 'SConscript']
    mimetypes = ['text/x-python', 'application/x-python']

    tokens = {
        'root': [
            (r'\n', Text),
            (r'^(\s*)("""(?:.|\n)*?""")', bygroups(Text, String.Doc)),
            (r"^(\s*)('''(?:.|\n)*?''')", bygroups(Text, String.Doc)),
            (r'[^\S\n]+', Text),
            (r'#.*$', Comment),
            (r'[]{}:(),;[]', Punctuation),
            (r'\\\n', Text),
            (r'\\', Text),
            (r'(in|is|and|or|not)\b', Operator.Word),
            (r'!=|==|<<|>>|[-~+/*%=<>&^|.]', Operator),
            include('keywords'),
            (r'(def)(\s+)', bygroups(Keyword, Text), 'funcname'),
            (r'(class)(\s+)', bygroups(Keyword, Text), 'classname'),
            (r'(from)(\s+)', bygroups(Keyword.Namespace, Text), 'fromimport'),
            (r'(import)(\s+)', bygroups(Keyword.Namespace, Text), 'import'),
            include('builtins'),
            include('backtick'),
            ('(?:[rR]|[uU][rR]|[rR][uU])"""', String, 'tdqs'),
            ("(?:[rR]|[uU][rR]|[rR][uU])'''", String, 'tsqs'),
            ('(?:[rR]|[uU][rR]|[rR][uU])"', String, 'dqs'),
            ("(?:[rR]|[uU][rR]|[rR][uU])'", String, 'sqs'),
            ('[uU]?"""', String, combined('stringescape', 'tdqs')),
            ("[uU]?'''", String, combined('stringescape', 'tsqs')),
            ('[uU]?"', String, combined('stringescape', 'dqs')),
            ("[uU]?'", String, combined('stringescape', 'sqs')),
            include('name'),
            include('numbers'),
        ],
        'keywords': [
            (r'(assert|break|continue|del|elif|else|except|exec|'
             r'finally|for|global|if|lambda|pass|print|raise|'
             r'return|try|while|yield|as|with)\b', Keyword),
        ],
        'builtins': [
            (r'(?<!\.)(__import__|abs|all|any|apply|basestring|bin|bool|buffer|'
             r'bytearray|bytes|callable|chr|classmethod|cmp|coerce|compile|'
             r'complex|delattr|dict|dir|divmod|enumerate|eval|execfile|exit|'
             r'file|filter|float|frozenset|getattr|globals|hasattr|hash|hex|id|'
             r'input|int|intern|isinstance|issubclass|iter|len|list|locals|'
             r'long|map|max|min|next|object|oct|open|ord|pow|property|range|'
             r'raw_input|reduce|reload|repr|reversed|round|set|setattr|slice|'
             r'sorted|staticmethod|str|sum|super|tuple|type|unichr|unicode|'
             r'vars|xrange|zip)\b', Name.Builtin),
            (r'(?<!\.)(self|None|Ellipsis|NotImplemented|False|True'
             r')\b', Name.Builtin.Pseudo),
            (r'(?<!\.)(ArithmeticError|AssertionError|AttributeError|'
             r'BaseException|DeprecationWarning|EOFError|EnvironmentError|'
             r'Exception|FloatingPointError|FutureWarning|GeneratorExit|IOError|'
             r'ImportError|ImportWarning|IndentationError|IndexError|KeyError|'
             r'KeyboardInterrupt|LookupError|MemoryError|NameError|'
             r'NotImplemented|NotImplementedError|OSError|OverflowError|'
             r'OverflowWarning|PendingDeprecationWarning|ReferenceError|'
             r'RuntimeError|RuntimeWarning|StandardError|StopIteration|'
             r'SyntaxError|SyntaxWarning|SystemError|SystemExit|TabError|'
             r'TypeError|UnboundLocalError|UnicodeDecodeError|'
             r'UnicodeEncodeError|UnicodeError|UnicodeTranslateError|'
             r'UnicodeWarning|UserWarning|ValueError|Warning|ZeroDivisionError'
             r')\b', Name.Exception),
        ],
        'numbers': [
            (r'(\d+\.\d*|\d*\.\d+)([eE][+-]?[0-9]+)?', Number.Float),
            (r'\d+[eE][+-]?[0-9]+', Number.Float),
            (r'0\d+', Number.Oct),
            (r'0[xX][a-fA-F0-9]+', Number.Hex),
            (r'\d+L', Number.Integer.Long),
            (r'\d+', Number.Integer)
        ],
        'backtick': [
            ('`.*?`', String.Backtick),
        ],
        'name': [
            (r'@[a-zA-Z0-9_.]+', Name.Decorator),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
        ],
        'funcname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Function, '#pop')
        ],
        'classname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Class, '#pop')
        ],
        'import': [
            (r'(\s+)(as)(\s+)', bygroups(Text, Keyword.Namespace, Text)),
            (r'[a-zA-Z_][a-zA-Z0-9_.]*', Name.Namespace),
            (r'(\s*)(,)(\s*)', bygroups(Text, Operator, Text)),
            (r'', Text, '#pop') # all else: go back
        ],
        'fromimport': [
            (r'(\s+)(import)\b', bygroups(Text, Keyword.Namespace), '#pop'),
            (r'[a-zA-Z_.][a-zA-Z0-9_.]*', Name.Namespace),
        ],
        'stringescape': [
            (r'\\([\\abfnrtv"\']|\n|N{.*?}|u[a-fA-F0-9]{4}|'
             r'U[a-fA-F0-9]{8}|x[a-fA-F0-9]{2}|[0-7]{1,3})', String.Escape)
        ],
        'strings': [
            (r'%(\([a-zA-Z0-9_]+\))?[-#0 +]*([0-9]+|[*])?(\.([0-9]+|[*]))?'
             '[hlL]?[diouxXeEfFgGcrs%]', String.Interpol),
            (r'[^\\\'"%\n]+', String),
            # quotes, percents and backslashes must be parsed one at a time
            (r'[\'"\\]', String),
            # unhandled string formatting sign
            (r'%', String)
            # newlines are an error (use "nl" state)
        ],
        'nl': [
            (r'\n', String)
        ],
        'dqs': [
            (r'"', String, '#pop'),
            (r'\\\\|\\"|\\\n', String.Escape), # included here again for raw strings
            include('strings')
        ],
        'sqs': [
            (r"'", String, '#pop'),
            (r"\\\\|\\'|\\\n", String.Escape), # included here again for raw strings
            include('strings')
        ],
        'tdqs': [
            (r'"""', String, '#pop'),
            include('strings'),
            include('nl')
        ],
        'tsqs': [
            (r"'''", String, '#pop'),
            include('strings'),
            include('nl')
        ],
    }

    def analyse_text(text):
        return shebang_matches(text, r'pythonw?(2\.\d)?')


class Python3Lexer(RegexLexer):
    """
    For `Python <http://www.python.org>`_ source code (version 3.0).

    *New in Pygments 0.10.*
    """

    name = 'Python 3'
    aliases = ['python3', 'py3']
    filenames = []  # Nothing until Python 3 gets widespread
    mimetypes = ['text/x-python3', 'application/x-python3']

    flags = re.MULTILINE | re.UNICODE

    uni_name = "[%s][%s]*" % (uni.xid_start, uni.xid_continue)

    tokens = PythonLexer.tokens.copy()
    tokens['keywords'] = [
        (r'(assert|break|continue|del|elif|else|except|'
         r'finally|for|global|if|lambda|pass|raise|'
         r'return|try|while|yield|as|with|True|False|None)\b', Keyword),
    ]
    tokens['builtins'] = [
        (r'(?<!\.)(__import__|abs|all|any|bin|bool|bytearray|bytes|'
         r'chr|classmethod|cmp|compile|complex|delattr|dict|dir|'
         r'divmod|enumerate|eval|filter|float|format|frozenset|getattr|'
         r'globals|hasattr|hash|hex|id|input|int|isinstance|issubclass|'
         r'iter|len|list|locals|map|max|memoryview|min|next|object|oct|'
         r'open|ord|pow|print|property|range|repr|reversed|round|'
         r'set|setattr|slice|sorted|staticmethod|str|sum|super|tuple|type|'
         r'vars|zip)\b', Name.Builtin),
        (r'(?<!\.)(self|Ellipsis|NotImplemented)\b', Name.Builtin.Pseudo),
        (r'(?<!\.)(ArithmeticError|AssertionError|AttributeError|'
         r'BaseException|BufferError|BytesWarning|DeprecationWarning|'
         r'EOFError|EnvironmentError|Exception|FloatingPointError|'
         r'FutureWarning|GeneratorExit|IOError|ImportError|'
         r'ImportWarning|IndentationError|IndexError|KeyError|'
         r'KeyboardInterrupt|LookupError|MemoryError|NameError|'
         r'NotImplementedError|OSError|OverflowError|'
         r'PendingDeprecationWarning|ReferenceError|'
         r'RuntimeError|RuntimeWarning|StopIteration|'
         r'SyntaxError|SyntaxWarning|SystemError|SystemExit|TabError|'
         r'TypeError|UnboundLocalError|UnicodeDecodeError|'
         r'UnicodeEncodeError|UnicodeError|UnicodeTranslateError|'
         r'UnicodeWarning|UserWarning|ValueError|Warning|ZeroDivisionError'
         r')\b', Name.Exception),
    ]
    tokens['numbers'] = [
        (r'(\d+\.\d*|\d*\.\d+)([eE][+-]?[0-9]+)?', Number.Float),
        (r'0[oO][0-7]+', Number.Oct),
        (r'0[bB][01]+', Number.Bin),
        (r'0[xX][a-fA-F0-9]+', Number.Hex),
        (r'\d+', Number.Integer)
    ]
    tokens['backtick'] = []
    tokens['name'] = [
        (r'@[a-zA-Z0-9_]+', Name.Decorator),
        (uni_name, Name),
    ]
    tokens['funcname'] = [
        (uni_name, Name.Function, '#pop')
    ]
    tokens['classname'] = [
        (uni_name, Name.Class, '#pop')
    ]
    tokens['import'] = [
        (r'(\s+)(as)(\s+)', bygroups(Text, Keyword, Text)),
        (r'\.', Name.Namespace),
        (uni_name, Name.Namespace),
        (r'(\s*)(,)(\s*)', bygroups(Text, Operator, Text)),
        (r'', Text, '#pop') # all else: go back
    ]
    tokens['fromimport'] = [
        (r'(\s+)(import)\b', bygroups(Text, Keyword), '#pop'),
        (r'\.', Name.Namespace),
        (uni_name, Name.Namespace),
    ]
    # don't highlight "%s" substitutions
    tokens['strings'] = [
        (r'[^\\\'"%\n]+', String),
        # quotes, percents and backslashes must be parsed one at a time
        (r'[\'"\\]', String),
        # unhandled string formatting sign
        (r'%', String)
        # newlines are an error (use "nl" state)
    ]

    def analyse_text(text):
        return shebang_matches(text, r'pythonw?(3\.\d)?')


class PythonConsoleLexer(Lexer):
    """
    For Python console output or doctests, such as:

    .. sourcecode:: pycon

        >>> a = 'foo'
        >>> print a
        foo
        >>> 1 / 0
        Traceback (most recent call last):
          File "<stdin>", line 1, in <module>
        ZeroDivisionError: integer division or modulo by zero

    Additional options:

    `python3`
        Use Python 3 lexer for code.  Default is ``False``.
        *New in Pygments 1.0.*
    """
    name = 'Python console session'
    aliases = ['pycon']
    mimetypes = ['text/x-python-doctest']

    def __init__(self, **options):
        self.python3 = get_bool_opt(options, 'python3', False)
        Lexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        if self.python3:
            pylexer = Python3Lexer(**self.options)
            tblexer = Python3TracebackLexer(**self.options)
        else:
            pylexer = PythonLexer(**self.options)
            tblexer = PythonTracebackLexer(**self.options)

        curcode = ''
        insertions = []
        curtb = ''
        tbindex = 0
        tb = 0
        for match in line_re.finditer(text):
            line = match.group()
            if line.startswith('>>> ') or line.startswith('... '):
                tb = 0
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, line[:4])]))
                curcode += line[4:]
            elif line.rstrip() == '...':
                tb = 0
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, '...')]))
                curcode += line[3:]
            else:
                if curcode:
                    for item in do_insertions(insertions,
                                    pylexer.get_tokens_unprocessed(curcode)):
                        yield item
                    curcode = ''
                    insertions = []
                if (line.startswith('Traceback (most recent call last):') or
                    re.match(r'  File "[^"]+", line \d+\n$', line)):
                    tb = 1
                    curtb = line
                    tbindex = match.start()
                elif line == 'KeyboardInterrupt\n':
                    yield match.start(), Name.Class, line
                elif tb:
                    curtb += line
                    if not (line.startswith(' ') or line.strip() == '...'):
                        tb = 0
                        for i, t, v in tblexer.get_tokens_unprocessed(curtb):
                            yield tbindex+i, t, v
                else:
                    yield match.start(), Generic.Output, line
        if curcode:
            for item in do_insertions(insertions,
                                      pylexer.get_tokens_unprocessed(curcode)):
                yield item


class PythonTracebackLexer(RegexLexer):
    """
    For Python tracebacks.

    *New in Pygments 0.7.*
    """

    name = 'Python Traceback'
    aliases = ['pytb']
    filenames = ['*.pytb']
    mimetypes = ['text/x-python-traceback']

    tokens = {
        'root': [
            (r'^Traceback \(most recent call last\):\n', Generic.Traceback, 'intb'),
            # SyntaxError starts with this.
            (r'^(?=  File "[^"]+", line \d+\n)', Generic.Traceback, 'intb'),
        ],
        'intb': [
            (r'^(  File )("[^"]+")(, line )(\d+)(, in )(.+)(\n)',
             bygroups(Text, Name.Builtin, Text, Number, Text, Name.Identifier, Text)),
            (r'^(  File )("[^"]+")(, line )(\d+)(\n)',
             bygroups(Text, Name.Builtin, Text, Number, Text)),
            (r'^(    )(.+)(\n)',
             bygroups(Text, using(PythonLexer), Text)),
            (r'^([ \t]*)(...)(\n)',
             bygroups(Text, Comment, Text)), # for doctests...
            (r'^(.+)(: )(.+)(\n)',
             bygroups(Name.Class, Text, Name.Identifier, Text), '#pop'),
            (r'^([a-zA-Z_][a-zA-Z0-9_]*)(:?\n)',
             bygroups(Name.Class, Text), '#pop')
        ],
    }


class Python3TracebackLexer(RegexLexer):
    """
    For Python 3.0 tracebacks, with support for chained exceptions.

    *New in Pygments 1.0.*
    """

    name = 'Python 3.0 Traceback'
    aliases = ['py3tb']
    filenames = ['*.py3tb']
    mimetypes = ['text/x-python3-traceback']

    tokens = {
        'root': [
            (r'\n', Text),
            (r'^Traceback \(most recent call last\):\n', Generic.Traceback, 'intb'),
            (r'^During handling of the above exception, another '
             r'exception occurred:\n\n', Generic.Traceback),
            (r'^The above exception was the direct cause of the '
             r'following exception:\n\n', Generic.Traceback),
        ],
        'intb': [
            (r'^(  File )("[^"]+")(, line )(\d+)(, in )(.+)(\n)',
             bygroups(Text, Name.Builtin, Text, Number, Text, Name.Identifier, Text)),
            (r'^(    )(.+)(\n)',
             bygroups(Text, using(Python3Lexer), Text)),
            (r'^([ \t]*)(...)(\n)',
             bygroups(Text, Comment, Text)), # for doctests...
            (r'^(.+)(: )(.+)(\n)',
             bygroups(Name.Class, Text, Name.Identifier, Text), '#pop'),
            (r'^([a-zA-Z_][a-zA-Z0-9_]*)(:?\n)',
             bygroups(Name.Class, Text), '#pop')
        ],
    }


class RubyLexer(ExtendedRegexLexer):
    """
    For `Ruby <http://www.ruby-lang.org>`_ source code.
    """

    name = 'Ruby'
    aliases = ['rb', 'ruby']
    filenames = ['*.rb', '*.rbw', 'Rakefile', '*.rake', '*.gemspec', '*.rbx']
    mimetypes = ['text/x-ruby', 'application/x-ruby']

    flags = re.DOTALL | re.MULTILINE

    def heredoc_callback(self, match, ctx):
        # okay, this is the hardest part of parsing Ruby...
        # match: 1 = <<-?, 2 = quote? 3 = name 4 = quote? 5 = rest of line

        start = match.start(1)
        yield start, Operator, match.group(1)        # <<-?
        yield match.start(2), String.Heredoc, match.group(2)  # quote ", ', `
        yield match.start(3), Name.Constant, match.group(3)   # heredoc name
        yield match.start(4), String.Heredoc, match.group(4)  # quote again

        heredocstack = ctx.__dict__.setdefault('heredocstack', [])
        outermost = not bool(heredocstack)
        heredocstack.append((match.group(1) == '<<-', match.group(3)))

        ctx.pos = match.start(5)
        ctx.end = match.end(5)
        # this may find other heredocs
        for i, t, v in self.get_tokens_unprocessed(context=ctx):
            yield i, t, v
        ctx.pos = match.end()

        if outermost:
            # this is the outer heredoc again, now we can process them all
            for tolerant, hdname in heredocstack:
                lines = []
                for match in line_re.finditer(ctx.text, ctx.pos):
                    if tolerant:
                        check = match.group().strip()
                    else:
                        check = match.group().rstrip()
                    if check == hdname:
                        for amatch in lines:
                            yield amatch.start(), String.Heredoc, amatch.group()
                        yield match.start(), Name.Constant, match.group()
                        ctx.pos = match.end()
                        break
                    else:
                        lines.append(match)
                else:
                    # end of heredoc not found -- error!
                    for amatch in lines:
                        yield amatch.start(), Error, amatch.group()
            ctx.end = len(ctx.text)
            del heredocstack[:]


    def gen_rubystrings_rules():
        def intp_regex_callback(self, match, ctx):
            yield match.start(1), String.Regex, match.group(1)    # begin
            nctx = LexerContext(match.group(3), 0, ['interpolated-regex'])
            for i, t, v in self.get_tokens_unprocessed(context=nctx):
                yield match.start(3)+i, t, v
            yield match.start(4), String.Regex, match.group(4)    # end[mixounse]*
            ctx.pos = match.end()

        def intp_string_callback(self, match, ctx):
            yield match.start(1), String.Other, match.group(1)
            nctx = LexerContext(match.group(3), 0, ['interpolated-string'])
            for i, t, v in self.get_tokens_unprocessed(context=nctx):
                yield match.start(3)+i, t, v
            yield match.start(4), String.Other, match.group(4)    # end
            ctx.pos = match.end()

        states = {}
        states['strings'] = [
            # easy ones
            (r'\:([a-zA-Z_][\w_]*[\!\?]?|\*\*?|[-+]@?|'
             r'[/%&|^`~]|\[\]=?|<<|>>|<=?>|>=?|===?)', String.Symbol),
            (r":'(\\\\|\\'|[^'])*'", String.Symbol),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
            (r':"', String.Symbol, 'simple-sym'),
            (r'"', String.Double, 'simple-string'),
            (r'(?<!\.)`', String.Backtick, 'simple-backtick'),
        ]

        # double-quoted string and symbol
        for name, ttype, end in ('string', String.Double, '"'), \
                                ('sym', String.Symbol, '"'), \
                                ('backtick', String.Backtick, '`'):
            states['simple-'+name] = [
                include('string-intp-escaped'),
                (r'[^\\%s#]+' % end, ttype),
                (r'[\\#]', ttype),
                (end, ttype, '#pop'),
            ]

        # braced quoted strings
        for lbrace, rbrace, name in ('\\{', '\\}', 'cb'), \
                                    ('\\[', '\\]', 'sb'), \
                                    ('\\(', '\\)', 'pa'), \
                                    ('<', '>', 'ab'):
            states[name+'-intp-string'] = [
                (r'\\[\\' + lbrace + rbrace + ']', String.Other),
                (r'(?<!\\)' + lbrace, String.Other, '#push'),
                (r'(?<!\\)' + rbrace, String.Other, '#pop'),
                include('string-intp-escaped'),
                (r'[\\#' + lbrace + rbrace + ']', String.Other),
                (r'[^\\#' + lbrace + rbrace + ']+', String.Other),
            ]
            states['strings'].append((r'%[QWx]?' + lbrace, String.Other,
                                      name+'-intp-string'))
            states[name+'-string'] = [
                (r'\\[\\' + lbrace + rbrace + ']', String.Other),
                (r'(?<!\\)' + lbrace, String.Other, '#push'),
                (r'(?<!\\)' + rbrace, String.Other, '#pop'),
                (r'[\\#' + lbrace + rbrace + ']', String.Other),
                (r'[^\\#' + lbrace + rbrace + ']+', String.Other),
            ]
            states['strings'].append((r'%[qsw]' + lbrace, String.Other,
                                      name+'-string'))
            states[name+'-regex'] = [
                (r'\\[\\' + lbrace + rbrace + ']', String.Regex),
                (r'(?<!\\)' + lbrace, String.Regex, '#push'),
                (r'(?<!\\)' + rbrace + '[mixounse]*', String.Regex, '#pop'),
                include('string-intp'),
                (r'[\\#' + lbrace + rbrace + ']', String.Regex),
                (r'[^\\#' + lbrace + rbrace + ']+', String.Regex),
            ]
            states['strings'].append((r'%r' + lbrace, String.Regex,
                                      name+'-regex'))

        # these must come after %<brace>!
        states['strings'] += [
            # %r regex
            (r'(%r([^a-zA-Z0-9]))([^\2\\]*(?:\\.[^\2\\]*)*)(\2[mixounse]*)',
             intp_regex_callback),
            # regular fancy strings with qsw
            (r'%[qsw]([^a-zA-Z0-9])([^\1\\]*(?:\\.[^\1\\]*)*)\1', String.Other),
            (r'(%[QWx]([^a-zA-Z0-9]))([^\2\\]*(?:\\.[^\2\\]*)*)(\2)',
             intp_string_callback),
            # special forms of fancy strings after operators or
            # in method calls with braces
            (r'(?<=[-+/*%=<>&!^|~,(])(\s*)(%([\t ])(?:[^\3\\]*(?:\\.[^\3\\]*)*)\3)',
             bygroups(Text, String.Other, None)),
            # and because of fixed with lookbehinds the whole thing a
            # second time for line startings...
            (r'^(\s*)(%([\t ])(?:[^\3\\]*(?:\\.[^\3\\]*)*)\3)',
             bygroups(Text, String.Other, None)),
            # all regular fancy strings without qsw
            (r'(%([^a-zA-Z0-9\s]))([^\2\\]*(?:\\.[^\2\\]*)*)(\2)',
             intp_string_callback),
        ]

        return states

    tokens = {
        'root': [
            (r'#.*?$', Comment.Single),
            (r'=begin\s.*?\n=end', Comment.Multiline),
            # keywords
            (r'(BEGIN|END|alias|begin|break|case|defined\?|'
             r'do|else|elsif|end|ensure|for|if|in|next|redo|'
             r'rescue|raise|retry|return|super|then|undef|unless|until|when|'
             r'while|yield)\b', Keyword),
            # start of function, class and module names
            (r'(module)(\s+)([a-zA-Z_][a-zA-Z0-9_]*(::[a-zA-Z_][a-zA-Z0-9_]*)*)',
             bygroups(Keyword, Text, Name.Namespace)),
            (r'(def)(\s+)', bygroups(Keyword, Text), 'funcname'),
            (r'def(?=[*%&^`~+-/\[<>=])', Keyword, 'funcname'),
            (r'(class)(\s+)', bygroups(Keyword, Text), 'classname'),
            # special methods
            (r'(initialize|new|loop|include|extend|raise|attr_reader|'
             r'attr_writer|attr_accessor|attr|catch|throw|private|'
             r'module_function|public|protected|true|false|nil)\b', Keyword.Pseudo),
            (r'(not|and|or)\b', Operator.Word),
            (r'(autoload|block_given|const_defined|eql|equal|frozen|include|'
             r'instance_of|is_a|iterator|kind_of|method_defined|nil|'
             r'private_method_defined|protected_method_defined|'
             r'public_method_defined|respond_to|tainted)\?', Name.Builtin),
            (r'(chomp|chop|exit|gsub|sub)!', Name.Builtin),
            (r'(?<!\.)(Array|Float|Integer|String|__id__|__send__|abort|ancestors|'
             r'at_exit|autoload|binding|callcc|caller|'
             r'catch|chomp|chop|class_eval|class_variables|'
             r'clone|const_defined\?|const_get|const_missing|const_set|constants|'
             r'display|dup|eval|exec|exit|extend|fail|fork|'
             r'format|freeze|getc|gets|global_variables|gsub|'
             r'hash|id|included_modules|inspect|instance_eval|'
             r'instance_method|instance_methods|'
             r'instance_variable_get|instance_variable_set|instance_variables|'
             r'lambda|load|local_variables|loop|'
             r'method|method_missing|methods|module_eval|name|'
             r'object_id|open|p|print|printf|private_class_method|'
             r'private_instance_methods|'
             r'private_methods|proc|protected_instance_methods|'
             r'protected_methods|public_class_method|'
             r'public_instance_methods|public_methods|'
             r'putc|puts|raise|rand|readline|readlines|require|'
             r'scan|select|self|send|set_trace_func|singleton_methods|sleep|'
             r'split|sprintf|srand|sub|syscall|system|taint|'
             r'test|throw|to_a|to_s|trace_var|trap|type|untaint|untrace_var|'
             r'warn)\b', Name.Builtin),
            (r'__(FILE|LINE)__\b', Name.Builtin.Pseudo),
            # normal heredocs
            (r'(?<!\w)(<<-?)(["`\']?)([a-zA-Z_]\w*)(\2)(.*?\n)', heredoc_callback),
            # empty string heredocs
            (r'(<<-?)("|\')()(\2)(.*?\n)', heredoc_callback),
            (r'__END__', Comment.Preproc, 'end-part'),
            # multiline regex (after keywords or assignemnts)
            (r'(?:^|(?<=[=<>~!])|'
                 r'(?<=(?:\s|;)when\s)|'
                 r'(?<=(?:\s|;)or\s)|'
                 r'(?<=(?:\s|;)and\s)|'
                 r'(?<=(?:\s|;|\.)index\s)|'
                 r'(?<=(?:\s|;|\.)scan\s)|'
                 r'(?<=(?:\s|;|\.)sub\s)|'
                 r'(?<=(?:\s|;|\.)sub!\s)|'
                 r'(?<=(?:\s|;|\.)gsub\s)|'
                 r'(?<=(?:\s|;|\.)gsub!\s)|'
                 r'(?<=(?:\s|;|\.)match\s)|'
                 r'(?<=(?:\s|;)if\s)|'
                 r'(?<=(?:\s|;)elsif\s)|'
                 r'(?<=^when\s)|'
                 r'(?<=^index\s)|'
                 r'(?<=^scan\s)|'
                 r'(?<=^sub\s)|'
                 r'(?<=^gsub\s)|'
                 r'(?<=^sub!\s)|'
                 r'(?<=^gsub!\s)|'
                 r'(?<=^match\s)|'
                 r'(?<=^if\s)|'
                 r'(?<=^elsif\s)'
             r')(\s*)(/)(?!=)', bygroups(Text, String.Regex), 'multiline-regex'),
            # multiline regex (in method calls)
            (r'(?<=\(|,)/', String.Regex, 'multiline-regex'),
            # multiline regex (this time the funny no whitespace rule)
            (r'(\s+)(/[^\s=])', String.Regex, 'multiline-regex'),
            # lex numbers and ignore following regular expressions which
            # are division operators in fact (grrrr. i hate that. any
            # better ideas?)
            # since pygments 0.7 we also eat a "?" operator after numbers
            # so that the char operator does not work. Chars are not allowed
            # there so that you can use the terner operator.
            # stupid example:
            #   x>=0?n[x]:""
            (r'(0_?[0-7]+(?:_[0-7]+)*)(\s*)([/?])?',
             bygroups(Number.Oct, Text, Operator)),
            (r'(0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*)(\s*)([/?])?',
             bygroups(Number.Hex, Text, Operator)),
            (r'(0b[01]+(?:_[01]+)*)(\s*)([/?])?',
             bygroups(Number.Bin, Text, Operator)),
            (r'([\d]+(?:_\d+)*)(\s*)([/?])?',
             bygroups(Number.Integer, Text, Operator)),
            # Names
            (r'@@[a-zA-Z_][a-zA-Z0-9_]*', Name.Variable.Class),
            (r'@[a-zA-Z_][a-zA-Z0-9_]*', Name.Variable.Instance),
            (r'\$[a-zA-Z0-9_]+', Name.Variable.Global),
            (r'\$[!@&`\'+~=/\\,;.<>_*$?:"]', Name.Variable.Global),
            (r'\$-[0adFiIlpvw]', Name.Variable.Global),
            (r'::', Operator),
            include('strings'),
            # chars
            (r'\?(\\[MC]-)*' # modifiers
             r'(\\([\\abefnrstv#"\']|x[a-fA-F0-9]{1,2}|[0-7]{1,3})|\S)'
             r'(?!\w)',
             String.Char),
            (r'[A-Z][a-zA-Z0-9_]+', Name.Constant),
            # this is needed because ruby attributes can look
            # like keywords (class) or like this: ` ?!?
            (r'(\.|::)([a-zA-Z_]\w*[\!\?]?|[*%&^`~+-/\[<>=])',
             bygroups(Operator, Name)),
            (r'[a-zA-Z_][\w_]*[\!\?]?', Name),
            (r'(\[|\]|\*\*|<<?|>>?|>=|<=|<=>|=~|={3}|'
             r'!~|&&?|\|\||\.{1,3})', Operator),
            (r'[-+/*%=<>&!^|~]=?', Operator),
            (r'[(){};,/?:\\]', Punctuation),
            (r'\s+', Text)
        ],
        'funcname': [
            (r'\(', Punctuation, 'defexpr'),
            (r'(?:([a-zA-Z_][a-zA-Z0-9_]*)(\.))?'
             r'([a-zA-Z_][\w_]*[\!\?]?|\*\*?|[-+]@?|'
             r'[/%&|^`~]|\[\]=?|<<|>>|<=?>|>=?|===?)',
             bygroups(Name.Class, Operator, Name.Function), '#pop'),
            (r'', Text, '#pop')
        ],
        'classname': [
            (r'\(', Punctuation, 'defexpr'),
            (r'<<', Operator, '#pop'),
            (r'[A-Z_][\w_]*', Name.Class, '#pop'),
            (r'', Text, '#pop')
        ],
        'defexpr': [
            (r'(\))(\.|::)?', bygroups(Punctuation, Operator), '#pop'),
            (r'\(', Operator, '#push'),
            include('root')
        ],
        'in-intp': [
            ('}', String.Interpol, '#pop'),
            include('root'),
        ],
        'string-intp': [
            (r'#{', String.Interpol, 'in-intp'),
            (r'#@@?[a-zA-Z_][a-zA-Z0-9_]*', String.Interpol),
            (r'#\$[a-zA-Z_][a-zA-Z0-9_]*', String.Interpol)
        ],
        'string-intp-escaped': [
            include('string-intp'),
            (r'\\([\\abefnrstv#"\']|x[a-fA-F0-9]{1,2}|[0-7]{1,3})', String.Escape)
        ],
        'interpolated-regex': [
            include('string-intp'),
            (r'[\\#]', String.Regex),
            (r'[^\\#]+', String.Regex),
        ],
        'interpolated-string': [
            include('string-intp'),
            (r'[\\#]', String.Other),
            (r'[^\\#]+', String.Other),
        ],
        'multiline-regex': [
            include('string-intp'),
            (r'\\/', String.Regex),
            (r'[\\#]', String.Regex),
            (r'[^\\/#]+', String.Regex),
            (r'/[mixounse]*', String.Regex, '#pop'),
        ],
        'end-part': [
            (r'.+', Comment.Preproc, '#pop')
        ]
    }
    tokens.update(gen_rubystrings_rules())

    def analyse_text(text):
        return shebang_matches(text, r'ruby(1\.\d)?')


class RubyConsoleLexer(Lexer):
    """
    For Ruby interactive console (**irb**) output like:

    .. sourcecode:: rbcon

        irb(main):001:0> a = 1
        => 1
        irb(main):002:0> puts a
        1
        => nil
    """
    name = 'Ruby irb session'
    aliases = ['rbcon', 'irb']
    mimetypes = ['text/x-ruby-shellsession']

    _prompt_re = re.compile('irb\([a-zA-Z_][a-zA-Z0-9_]*\):\d{3}:\d+[>*"\'] '
                            '|>> |\?> ')

    def get_tokens_unprocessed(self, text):
        rblexer = RubyLexer(**self.options)

        curcode = ''
        insertions = []
        for match in line_re.finditer(text):
            line = match.group()
            m = self._prompt_re.match(line)
            if m is not None:
                end = m.end()
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, line[:end])]))
                curcode += line[end:]
            else:
                if curcode:
                    for item in do_insertions(insertions,
                                    rblexer.get_tokens_unprocessed(curcode)):
                        yield item
                    curcode = ''
                    insertions = []
                yield match.start(), Generic.Output, line
        if curcode:
            for item in do_insertions(insertions,
                                      rblexer.get_tokens_unprocessed(curcode)):
                yield item


class PerlLexer(RegexLexer):
    """
    For `Perl <http://www.perl.org>`_ source code.
    """

    name = 'Perl'
    aliases = ['perl', 'pl']
    filenames = ['*.pl', '*.pm']
    mimetypes = ['text/x-perl', 'application/x-perl']

    flags = re.DOTALL | re.MULTILINE
    # TODO: give this a perl guy who knows how to parse perl...
    tokens = {
        'balanced-regex': [
            (r'/(\\\\|\\/|[^/])*/[egimosx]*', String.Regex, '#pop'),
            (r'!(\\\\|\\!|[^!])*![egimosx]*', String.Regex, '#pop'),
            (r'\\(\\\\|[^\\])*\\[egimosx]*', String.Regex, '#pop'),
            (r'{(\\\\|\\}|[^}])*}[egimosx]*', String.Regex, '#pop'),
            (r'<(\\\\|\\>|[^>])*>[egimosx]*', String.Regex, '#pop'),
            (r'\[(\\\\|\\\]|[^\]])*\][egimosx]*', String.Regex, '#pop'),
            (r'\((\\\\|\\\)|[^\)])*\)[egimosx]*', String.Regex, '#pop'),
            (r'@(\\\\|\\\@|[^\@])*@[egimosx]*', String.Regex, '#pop'),
            (r'%(\\\\|\\\%|[^\%])*%[egimosx]*', String.Regex, '#pop'),
            (r'\$(\\\\|\\\$|[^\$])*\$[egimosx]*', String.Regex, '#pop'),
            (r'!(\\\\|\\!|[^!])*![egimosx]*', String.Regex, '#pop'),
        ],
        'root': [
            (r'\#.*?$', Comment.Single),
            (r'^=[a-zA-Z0-9]+\s+.*?\n=cut', Comment.Multiline),
            (r'(case|continue|do|else|elsif|for|foreach|if|last|my|'
             r'next|our|redo|reset|then|unless|until|while|use|'
             r'print|new|BEGIN|END|return)\b', Keyword),
            (r'(format)(\s+)([a-zA-Z0-9_]+)(\s*)(=)(\s*\n)',
             bygroups(Keyword, Text, Name, Text, Punctuation, Text), 'format'),
            (r'(eq|lt|gt|le|ge|ne|not|and|or|cmp)\b', Operator.Word),
            # common delimiters
            (r's/(\\\\|\\/|[^/])*/(\\\\|\\/|[^/])*/[egimosx]*', String.Regex),
            (r's!(\\\\|\\!|[^!])*!(\\\\|\\!|[^!])*![egimosx]*', String.Regex),
            (r's\\(\\\\|[^\\])*\\(\\\\|[^\\])*\\[egimosx]*', String.Regex),
            (r's@(\\\\|\\@|[^@])*@(\\\\|\\@|[^@])*@[egimosx]*', String.Regex),
            (r's%(\\\\|\\%|[^%])*%(\\\\|\\%|[^%])*%[egimosx]*', String.Regex),
            # balanced delimiters
            (r's{(\\\\|\\}|[^}])*}\s*', String.Regex, 'balanced-regex'),
            (r's<(\\\\|\\>|[^>])*>\s*', String.Regex, 'balanced-regex'),
            (r's\[(\\\\|\\\]|[^\]])*\]\s*', String.Regex, 'balanced-regex'),
            (r's\((\\\\|\\\)|[^\)])*\)\s*', String.Regex, 'balanced-regex'),

            (r'm?/(\\\\|\\/|[^/\n])*/[gcimosx]*', String.Regex),
            (r'((?<==~)|(?<=\())\s*/(\\\\|\\/|[^/])*/[gcimosx]*', String.Regex),
            (r'\s+', Text),
            (r'(abs|accept|alarm|atan2|bind|binmode|bless|caller|chdir|'
             r'chmod|chomp|chop|chown|chr|chroot|close|closedir|connect|'
             r'continue|cos|crypt|dbmclose|dbmopen|defined|delete|die|'
             r'dump|each|endgrent|endhostent|endnetent|endprotoent|'
             r'endpwent|endservent|eof|eval|exec|exists|exit|exp|fcntl|'
             r'fileno|flock|fork|format|formline|getc|getgrent|getgrgid|'
             r'getgrnam|gethostbyaddr|gethostbyname|gethostent|getlogin|'
             r'getnetbyaddr|getnetbyname|getnetent|getpeername|getpgrp|'
             r'getppid|getpriority|getprotobyname|getprotobynumber|'
             r'getprotoent|getpwent|getpwnam|getpwuid|getservbyname|'
             r'getservbyport|getservent|getsockname|getsockopt|glob|gmtime|'
             r'goto|grep|hex|import|index|int|ioctl|join|keys|kill|last|'
             r'lc|lcfirst|length|link|listen|local|localtime|log|lstat|'
             r'map|mkdir|msgctl|msgget|msgrcv|msgsnd|my|next|no|oct|open|'
             r'opendir|ord|our|pack|package|pipe|pop|pos|printf|'
             r'prototype|push|quotemeta|rand|read|readdir|'
             r'readline|readlink|readpipe|recv|redo|ref|rename|require|'
             r'reverse|rewinddir|rindex|rmdir|scalar|seek|seekdir|'
             r'select|semctl|semget|semop|send|setgrent|sethostent|setnetent|'
             r'setpgrp|setpriority|setprotoent|setpwent|setservent|'
             r'setsockopt|shift|shmctl|shmget|shmread|shmwrite|shutdown|'
             r'sin|sleep|socket|socketpair|sort|splice|split|sprintf|sqrt|'
             r'srand|stat|study|substr|symlink|syscall|sysopen|sysread|'
             r'sysseek|system|syswrite|tell|telldir|tie|tied|time|times|tr|'
             r'truncate|uc|ucfirst|umask|undef|unlink|unpack|unshift|untie|'
             r'utime|values|vec|wait|waitpid|wantarray|warn|write'
             r')\b', Name.Builtin),
            (r'((__(DATA|DIE|WARN)__)|(STD(IN|OUT|ERR)))\b', Name.Builtin.Pseudo),
            (r'<<([a-zA-Z_][a-zA-Z0-9_]*);?\n.*?\n\1\n', String),
            (r'__END__', Comment.Preproc, 'end-part'),
            (r'\$\^[ADEFHILMOPSTWX]', Name.Variable.Global),
            (r"\$[\\\"\[\]'&`+*.,;=%~?@$!<>(^|/-](?!\w)", Name.Variable.Global),
            (r'[$@%#]+', Name.Variable, 'varname'),
            (r'0_?[0-7]+(_[0-7]+)*', Number.Oct),
            (r'0x[0-9A-Fa-f]+(_[0-9A-Fa-f]+)*', Number.Hex),
            (r'0b[01]+(_[01]+)*', Number.Bin),
            (r'\d+', Number.Integer),
            (r"'(\\\\|\\'|[^'])*'", String),
            (r'"(\\\\|\\"|[^"])*"', String),
            (r'`(\\\\|\\`|[^`])*`', String.Backtick),
            (r'<([^\s>]+)>', String.Regexp),
            (r'(q|qq|qw|qr|qx)\{', String.Other, 'cb-string'),
            (r'(q|qq|qw|qr|qx)\(', String.Other, 'rb-string'),
            (r'(q|qq|qw|qr|qx)\[', String.Other, 'sb-string'),
            (r'(q|qq|qw|qr|qx)\<', String.Other, 'lt-string'),
            (r'(q|qq|qw|qr|qx)(.)[.\n]*?\1', String.Other),
            (r'package\s+', Keyword, 'modulename'),
            (r'sub\s+', Keyword, 'funcname'),
            (r'(\[\]|\*\*|::|<<|>>|>=|<=|<=>|={3}|!=|=~|'
             r'!~|&&?|\|\||\.{1,3})', Operator),
            (r'[-+/*%=<>&^|!\\~]=?', Operator),
            (r'[\(\)\[\]:;,<>/\?\{\}]', Punctuation), # yes, there's no shortage
                                                      # of punctuation in Perl!
            (r'(?=\w)', Name, 'name'),
        ],
        'format': [
            (r'\.\n', String.Interpol, '#pop'),
            (r'[^\n]*\n', String.Interpol),
        ],
        'varname': [
            (r'\s+', Text),
            (r'\{', Punctuation, '#pop'), # hash syntax?
            (r'\)|,', Punctuation, '#pop'), # argument specifier
            (r'[a-zA-Z0-9_]+::', Name.Namespace),
            (r'[a-zA-Z0-9_:]+', Name.Variable, '#pop'),
        ],
        'name': [
            (r'[a-zA-Z0-9_]+::', Name.Namespace),
            (r'[a-zA-Z0-9_:]+', Name, '#pop'),
            (r'[A-Z_]+(?=[^a-zA-Z0-9_])', Name.Constant, '#pop'),
            (r'(?=[^a-zA-Z0-9_])', Text, '#pop'),
        ],
        'modulename': [
            (r'[a-zA-Z_][\w_]*', Name.Namespace, '#pop')
        ],
        'funcname': [
            (r'[a-zA-Z_][\w_]*[\!\?]?', Name.Function),
            (r'\s+', Text),
            # argument declaration
            (r'(\([$@%]*\))(\s*)', bygroups(Punctuation, Text)),
            (r'.*?{', Punctuation, '#pop'),
            (r';', Punctuation, '#pop'),
        ],
        'cb-string': [
            (r'\\[\{\}\\]', String.Other),
            (r'\\', String.Other),
            (r'\{', String.Other, 'cb-string'),
            (r'\}', String.Other, '#pop'),
            (r'[^\{\}\\]+', String.Other)
        ],
        'rb-string': [
            (r'\\[\(\)\\]', String.Other),
            (r'\\', String.Other),
            (r'\(', String.Other, 'rb-string'),
            (r'\)', String.Other, '#pop'),
            (r'[^\(\)]+', String.Other)
        ],
        'sb-string': [
            (r'\\[\[\]\\]', String.Other),
            (r'\\', String.Other),
            (r'\[', String.Other, 'sb-string'),
            (r'\]', String.Other, '#pop'),
            (r'[^\[\]]+', String.Other)
        ],
        'lt-string': [
            (r'\\[\<\>\\]', String.Other),
            (r'\\', String.Other),
            (r'\<', String.Other, 'lt-string'),
            (r'\>', String.Other, '#pop'),
            (r'[^\<\>]]+', String.Other)
        ],
        'end-part': [
            (r'.+', Comment.Preproc, '#pop')
        ]
    }

    def analyse_text(text):
        if shebang_matches(text, r'perl(\d\.\d\.\d)?'):
            return True
        if 'my $' in text:
            return 0.9
        return 0.1 # who knows, might still be perl!


class LuaLexer(RegexLexer):
    """
    For `Lua <http://www.lua.org>`_ source code.

    Additional options accepted:

    `func_name_highlighting`
        If given and ``True``, highlight builtin function names
        (default: ``True``).
    `disabled_modules`
        If given, must be a list of module names whose function names
        should not be highlighted. By default all modules are highlighted.

        To get a list of allowed modules have a look into the
        `_luabuiltins` module:

        .. sourcecode:: pycon

            >>> from pygments.lexers._luabuiltins import MODULES
            >>> MODULES.keys()
            ['string', 'coroutine', 'modules', 'io', 'basic', ...]
    """

    name = 'Lua'
    aliases = ['lua']
    filenames = ['*.lua']
    mimetypes = ['text/x-lua', 'application/x-lua']

    tokens = {
        'root': [
            (r'(?s)--\[(=*)\[.*?\]\1\]', Comment.Multiline),
            ('--.*$', Comment.Single),

            (r'(?i)(\d*\.\d+|\d+\.\d*)(e[+-]?\d+)?', Number.Float),
            (r'(?i)\d+e[+-]?\d+', Number.Float),
            ('(?i)0x[0-9a-f]*', Number.Hex),
            (r'\d+', Number.Integer),

            (r'\n', Text),
            (r'[^\S\n]', Text),
            (r'(?s)\[(=*)\[.*?\]\1\]', String.Multiline),
            (r'[\[\]\{\}\(\)\.,:;]', Punctuation),

            (r'(==|~=|<=|>=|\.\.|\.\.\.|[=+\-*/%^<>#])', Operator),
            (r'(and|or|not)\b', Operator.Word),

            ('(break|do|else|elseif|end|for|if|in|repeat|return|then|until|'
             r'while)\b', Keyword),
            (r'(local)\b', Keyword.Declaration),
            (r'(true|false|nil)\b', Keyword.Constant),

            (r'(function)(\s+)', bygroups(Keyword, Text), 'funcname'),
            (r'(class)(\s+)', bygroups(Keyword, Text), 'classname'),

            (r'[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)?', Name),

            # multiline strings
            (r'(?s)\[(=*)\[(.*?)\]\1\]', String),
            ("'", String.Single, combined('stringescape', 'sqs')),
            ('"', String.Double, combined('stringescape', 'dqs'))
        ],

        'funcname': [
            ('[A-Za-z_][A-Za-z0-9_]*', Name.Function, '#pop'),
            # inline function
            ('\(', Punctuation, '#pop'),
        ],

        'classname': [
            ('[A-Za-z_][A-Za-z0-9_]*', Name.Class, '#pop')
        ],

        # if I understand correctly, every character is valid in a lua string,
        # so this state is only for later corrections
        'string': [
            ('.', String)
        ],

        'stringescape': [
            (r'''\\([abfnrtv\\"']|\d{1,3})''', String.Escape)
        ],

        'sqs': [
            ("'", String, '#pop'),
            include('string')
        ],

        'dqs': [
            ('"', String, '#pop'),
            include('string')
        ]
    }

    def __init__(self, **options):
        self.func_name_highlighting = get_bool_opt(
            options, 'func_name_highlighting', True)
        self.disabled_modules = get_list_opt(options, 'disabled_modules', [])

        self._functions = set()
        if self.func_name_highlighting:
            from pygments.lexers._luabuiltins import MODULES
            for mod, func in MODULES.iteritems():
                if mod not in self.disabled_modules:
                    self._functions.update(func)
        RegexLexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        for index, token, value in \
            RegexLexer.get_tokens_unprocessed(self, text):
            if token is Name:
                if value in self._functions:
                    yield index, Name.Builtin, value
                    continue
                elif '.' in value:
                    a, b = value.split('.')
                    yield index, Name, a
                    yield index + len(a), Punctuation, u'.'
                    yield index + len(a) + 1, Name, b
                    continue
            yield index, token, value


class MiniDLexer(RegexLexer):
    """
    For `MiniD <http://www.dsource.org/projects/minid>`_ (a D-like scripting
    language) source.
    """
    name = 'MiniD'
    filenames = ['*.md']
    aliases = ['minid']
    mimetypes = ['text/x-minidsrc']

    tokens = {
        'root': [
            (r'\n', Text),
            (r'\s+', Text),
            # Comments
            (r'//(.*?)\n', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
            (r'/\+', Comment, 'nestedcomment'),
            # Keywords
            (r'(as|assert|break|case|catch|class|continue|coroutine|default'
             r'|do|else|finally|for|foreach|function|global|namespace'
             r'|if|import|in|is|local|module|return|super|switch'
             r'|this|throw|try|vararg|while|with|yield)\b', Keyword),
            (r'(false|true|null)\b', Keyword.Constant),
            # FloatLiteral
            (r'([0-9][0-9_]*)?\.[0-9_]+([eE][+\-]?[0-9_]+)?', Number.Float),
            # IntegerLiteral
            # -- Binary
            (r'0[Bb][01_]+', Number),
            # -- Octal
            (r'0[Cc][0-7_]+', Number.Oct),
            # -- Hexadecimal
            (r'0[xX][0-9a-fA-F_]+', Number.Hex),
            # -- Decimal
            (r'(0|[1-9][0-9_]*)', Number.Integer),
            # CharacterLiteral
            (r"""'(\\['"?\\abfnrtv]|\\x[0-9a-fA-F]{2}|\\[0-9]{1,3}"""
             r"""|\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8}|.)'""",
             String.Char
            ),
            # StringLiteral
            # -- WysiwygString
            (r'@"(""|.)*"', String),
            # -- AlternateWysiwygString
            (r'`(``|.)*`', String),
            # -- DoubleQuotedString
            (r'"(\\\\|\\"|[^"])*"', String),
            # Tokens
            (
             r'(~=|\^=|%=|\*=|==|!=|>>>=|>>>|>>=|>>|>=|<=>|\?=|-\>'
             r'|<<=|<<|<=|\+\+|\+=|--|-=|\|\||\|=|&&|&=|\.\.|/=)'
             r'|[-/.&$@|\+<>!()\[\]{}?,;:=*%^~#\\]', Punctuation
            ),
            # Identifier
            (r'[a-zA-Z_]\w*', Name),
        ],
        'nestedcomment': [
            (r'[^+/]+', Comment),
            (r'/\+', Comment, '#push'),
            (r'\+/', Comment, '#pop'),
            (r'[+/]', Comment),
        ],
    }


class IoLexer(RegexLexer):
    """
    For `Io <http://iolanguage.com/>`_ (a small, prototype-based
    programming language) source.

    *New in Pygments 0.10.*
    """
    name = 'Io'
    filenames = ['*.io']
    aliases = ['io']
    mimetypes = ['text/x-iosrc']
    tokens = {
        'root': [
            (r'\n', Text),
            (r'\s+', Text),
            # Comments
            (r'//(.*?)\n', Comment),
            (r'#(.*?)\n', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
            (r'/\+', Comment, 'nestedcomment'),
            # DoubleQuotedString
            (r'"(\\\\|\\"|[^"])*"', String),
            # Operators
            (r'::=|:=|=|\(|\)|;|,|\*|-|\+|>|<|@|!|/|\||\^|\.|%|&|\[|\]|\{|\}',
             Operator),
            # keywords
            (r'(clone|do|doFile|doString|method|for|if|else|elseif|then)\b',
             Keyword),
            # constants
            (r'(nil|false|true)\b', Name.Constant),
            # names
            ('(Object|list|List|Map|args|Sequence|Coroutine|File)\b',
             Name.Builtin),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
            # numbers
            (r'(\d+\.?\d*|\d*\.\d+)([eE][+-]?[0-9]+)?', Number.Float),
            (r'\d+', Number.Integer)
        ],
        'nestedcomment': [
            (r'[^+/]+', Comment),
            (r'/\+', Comment, '#push'),
            (r'\+/', Comment, '#pop'),
            (r'[+/]', Comment),
        ]
    }


class TclLexer(RegexLexer):
    """
    For Tcl source code.

    *New in Pygments 0.10.*
    """

    keyword_cmds_re = (
        r'\b(after|apply|array|break|catch|continue|elseif|else|error|'
        r'eval|expr|for|foreach|global|if|namespace|proc|rename|return|'
        r'set|switch|then|trace|unset|update|uplevel|upvar|variable|'
        r'vwait|while)\b'
        )

    builtin_cmds_re = (
        r'\b(append|bgerror|binary|cd|chan|clock|close|concat|dde|dict|'
        r'encoding|eof|exec|exit|fblocked|fconfigure|fcopy|file|'
        r'fileevent|flush|format|gets|glob|history|http|incr|info|interp|'
        r'join|lappend|lassign|lindex|linsert|list|llength|load|loadTk|'
        r'lrange|lrepeat|lreplace|lreverse|lsearch|lset|lsort|mathfunc|'
        r'mathop|memory|msgcat|open|package|pid|pkg::create|pkg_mkIndex|'
        r'platform|platform::shell|puts|pwd|re_syntax|read|refchan|'
        r'regexp|registry|regsub|scan|seek|socket|source|split|string|'
        r'subst|tell|time|tm|unknown|unload)\b'
        )

    name = 'Tcl'
    aliases = ['tcl']
    filenames = ['*.tcl']
    mimetypes = ['text/x-tcl', 'text/x-script.tcl', 'application/x-tcl']

    def _gen_command_rules(keyword_cmds_re, builtin_cmds_re, context=""):
        return [
            (keyword_cmds_re, Keyword, 'params' + context),
            (builtin_cmds_re, Name.Builtin, 'params' + context),
            (r'([\w\.\-]+)', Name.Variable, 'params' + context),
            (r'#', Comment, 'comment'),
        ]

    tokens = {
        'root': [
            include('command'),
            include('basic'),
            include('data'),
        ],
        'command': _gen_command_rules(keyword_cmds_re, builtin_cmds_re),
        'command-in-brace': _gen_command_rules(keyword_cmds_re,
                                               builtin_cmds_re,
                                               "-in-brace"),
        'command-in-bracket': _gen_command_rules(keyword_cmds_re,
                                                 builtin_cmds_re,
                                                 "-in-bracket"),
        'command-in-paren': _gen_command_rules(keyword_cmds_re,
                                               builtin_cmds_re,
                                               "-in-paren"),
        'basic': [
            (r'\(', Keyword, 'paren'),
            (r'\[', Keyword, 'bracket'),
            (r'\{', Keyword, 'brace'),
            (r'"', String.Double, 'string'),
            (r'(eq|ne|in|ni)\b', Operator.Word),
            (r'!=|==|<<|>>|<=|>=|&&|\|\||\*\*|[-+~!*/%<>&^|?:]', Operator),
        ],
        'data': [
            (r'\s+', Text),
            (r'0x[a-fA-F0-9]+', Number.Hex),
            (r'0[0-7]+', Number.Oct),
            (r'\d+\.\d+', Number.Float),
            (r'\d+', Number.Integer),
            (r'\$([\w\.\-\:]+)', Name.Variable),
            (r'([\w\.\-\:]+)', Text),
        ],
        'params': [
            (r';', Keyword, '#pop'),
            (r'\n', Text, '#pop'),
            (r'(else|elseif|then)', Keyword),
            include('basic'),
            include('data'),
        ],
        'params-in-brace': [
            (r'}', Keyword, ('#pop', '#pop')),
            include('params')
        ],
        'params-in-paren': [
            (r'\)', Keyword, ('#pop', '#pop')),
            include('params')
        ],
        'params-in-bracket': [
            (r'\]', Keyword, ('#pop', '#pop')),
            include('params')
        ],
        'string': [
            (r'\[', String.Double, 'string-square'),
            (r'(\\\\|\\[0-7]+|\\.|[^"])', String.Double),
            (r'"', String.Double, '#pop')
        ],
        'string-square': [
            (r'\[', String.Double, 'string-square'),
            (r'(\\\\|\\[0-7]+|\\.|[^\]])', String.Double),
            (r'\]', String.Double, '#pop')
        ],
        'brace': [
            (r'}', Keyword, '#pop'),
            include('command-in-brace'),
            include('basic'),
            include('data'),
        ],
        'paren': [
            (r'\)', Keyword, '#pop'),
            include('command-in-paren'),
            include('basic'),
            include('data'),
        ],
        'bracket': [
            (r'\]', Keyword, '#pop'),
            include('command-in-bracket'),
            include('basic'),
            include('data'),
        ],
        'comment': [
            (r'.*[^\\]\n', Comment, '#pop'),
            (r'.*\\\n', Comment),
        ],
    }

    def analyse_text(text):
        return shebang_matches(text, r'(tcl)')


class ClojureLexer(RegexLexer):
    """
    Lexer for `Clojure <http://clojure.org/>`_ source code.

    *New in Pygments 0.11.*
    """
    name = 'Clojure'
    aliases = ['clojure', 'clj']
    filenames = ['*.clj']
    mimetypes = ['text/x-clojure', 'application/x-clojure']

    keywords = [
        'fn', 'def', 'defn', 'defmacro', 'defmethod', 'defmulti', 'defn-',
        'defstruct',
        'if', 'cond',
        'let', 'for'
    ]
    builtins = [
        '.', '..',
        '*', '+', '-', '->', '..', '/', '<', '<=', '=', '==', '>', '>=',
        'accessor', 'agent', 'agent-errors', 'aget', 'alength', 'all-ns',
        'alter', 'and', 'append-child', 'apply', 'array-map', 'aset',
        'aset-boolean', 'aset-byte', 'aset-char', 'aset-double', 'aset-float',
        'aset-int', 'aset-long', 'aset-short', 'assert', 'assoc', 'await',
        'await-for', 'bean', 'binding', 'bit-and', 'bit-not', 'bit-or',
        'bit-shift-left', 'bit-shift-right', 'bit-xor', 'boolean', 'branch?',
        'butlast', 'byte', 'cast', 'char', 'children', 'class',
        'clear-agent-errors', 'comment', 'commute', 'comp', 'comparator',
        'complement', 'concat', 'conj', 'cons', 'constantly',
        'construct-proxy', 'contains?', 'count', 'create-ns', 'create-struct',
        'cycle', 'dec',  'deref', 'difference', 'disj', 'dissoc', 'distinct',
        'doall', 'doc', 'dorun', 'doseq', 'dosync', 'dotimes', 'doto',
        'double', 'down', 'drop', 'drop-while', 'edit', 'end?', 'ensure',
        'eval', 'every?', 'false?', 'ffirst', 'file-seq', 'filter', 'find',
        'find-doc', 'find-ns', 'find-var', 'first', 'float', 'flush',
        'fnseq', 'frest', 'gensym', 'get', 'get-proxy-class',
        'hash-map', 'hash-set', 'identical?', 'identity', 'if-let', 'import',
        'in-ns', 'inc', 'index', 'insert-child', 'insert-left', 'insert-right',
        'inspect-table', 'inspect-tree', 'instance?', 'int', 'interleave',
        'intersection', 'into', 'into-array', 'iterate', 'join', 'key', 'keys',
        'keyword', 'keyword?', 'last', 'lazy-cat', 'lazy-cons', 'left',
        'lefts', 'line-seq', 'list', 'list*', 'load', 'load-file',
        'locking', 'long', 'loop', 'macroexpand', 'macroexpand-1',
        'make-array', 'make-node', 'map', 'map-invert', 'map?', 'mapcat',
        'max', 'max-key', 'memfn', 'merge', 'merge-with', 'meta', 'min',
        'min-key', 'name', 'namespace', 'neg?', 'new', 'newline', 'next',
        'nil?', 'node', 'not', 'not-any?', 'not-every?', 'not=', 'ns-imports',
        'ns-interns', 'ns-map', 'ns-name', 'ns-publics', 'ns-refers',
        'ns-resolve', 'ns-unmap', 'nth', 'nthrest', 'or', 'parse', 'partial',
        'path', 'peek', 'pop', 'pos?', 'pr', 'pr-str', 'print', 'print-str',
        'println', 'println-str', 'prn', 'prn-str', 'project', 'proxy',
        'proxy-mappings', 'quot', 'rand', 'rand-int', 'range', 're-find',
        're-groups', 're-matcher', 're-matches', 're-pattern', 're-seq',
        'read', 'read-line', 'reduce', 'ref', 'ref-set', 'refer', 'rem',
        'remove', 'remove-method', 'remove-ns', 'rename', 'rename-keys',
        'repeat', 'replace', 'replicate', 'resolve', 'rest', 'resultset-seq',
        'reverse', 'rfirst', 'right', 'rights', 'root', 'rrest', 'rseq',
        'second', 'select', 'select-keys', 'send', 'send-off', 'seq',
        'seq-zip', 'seq?', 'set', 'short', 'slurp', 'some', 'sort',
        'sort-by', 'sorted-map', 'sorted-map-by', 'sorted-set',
        'special-symbol?', 'split-at', 'split-with', 'str', 'string?',
        'struct', 'struct-map', 'subs', 'subvec', 'symbol', 'symbol?',
        'sync', 'take', 'take-nth', 'take-while', 'test', 'time', 'to-array',
        'to-array-2d', 'tree-seq', 'true?', 'union', 'up', 'update-proxy',
        'val', 'vals', 'var-get', 'var-set', 'var?', 'vector', 'vector-zip',
        'vector?', 'when', 'when-first', 'when-let', 'when-not',
        'with-local-vars', 'with-meta', 'with-open', 'with-out-str',
        'xml-seq', 'xml-zip', 'zero?', 'zipmap', 'zipper']

    # valid names for identifiers
    # well, names can only not consist fully of numbers
    # but this should be good enough for now
    valid_name = r'[a-zA-Z0-9!$%&*+,/:<=>?@^_~-]+'

    tokens = {
        'root' : [
            # the comments - always starting with semicolon
            # and going to the end of the line
            (r';.*$', Comment.Single),

            # whitespaces - usually not relevant
            (r'\s+', Text),

            # numbers
            (r'-?\d+\.\d+', Number.Float),
            (r'-?\d+', Number.Integer),
            # support for uncommon kinds of numbers -
            # have to figure out what the characters mean
            #(r'(#e|#i|#b|#o|#d|#x)[\d.]+', Number),

            # strings, symbols and characters
            (r'"(\\\\|\\"|[^"])*"', String),
            (r"'" + valid_name, String.Symbol),
            (r"\\([()/'\".'_!Â§$%& ?;=+-]{1}|[a-zA-Z0-9]+)", String.Char),

            # constants
            (r'(#t|#f)', Name.Constant),

            # special operators
            (r"('|#|`|,@|,|\.)", Operator),

            # highlight the keywords
            ('(%s)' % '|'.join([
                re.escape(entry) + ' ' for entry in keywords]),
                Keyword
            ),

            # first variable in a quoted string like
            # '(this is syntactic sugar)
            (r"(?<='\()" + valid_name, Name.Variable),
            (r"(?<=#\()" + valid_name, Name.Variable),

            # highlight the builtins
            ("(?<=\()(%s)" % '|'.join([
                re.escape(entry) + ' ' for entry in builtins]),
                Name.Builtin
            ),

            # the remaining functions
            (r'(?<=\()' + valid_name, Name.Function),
            # find the remaining variables
            (valid_name, Name.Variable),

            # Clojure accepts vector notation
            (r'(\[|\])', Punctuation),

            # Clojure accepts map notation
            (r'(\{|\})', Punctuation),

            # the famous parentheses!
            (r'(\(|\))', Punctuation),
        ],
    }
# -*- coding: utf-8 -*-
"""
    pygments.lexers.asm
    ~~~~~~~~~~~~~~~~~~~

    Lexers for assembly languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.lexer import RegexLexer, include, bygroups, using, DelegatingLexer
from pygments.lexers.compiled import DLexer, CppLexer, CLexer
from pygments.token import *

__all__ = ['GasLexer', 'ObjdumpLexer','DObjdumpLexer', 'CppObjdumpLexer',
           'CObjdumpLexer', 'LlvmLexer', 'NasmLexer']


class GasLexer(RegexLexer):
    """
    For Gas (AT&T) assembly code.
    """
    name = 'GAS'
    aliases = ['gas']
    filenames = ['*.s', '*.S']
    mimetypes = ['text/x-gas']

    #: optional Comment or Whitespace
    string = r'"(\\"|[^"])*"'
    char = r'[a-zA-Z$._0-9@]'
    identifier = r'(?:[a-zA-Z$_]' + char + '*|\.' + char + '+)'
    number = r'(?:0[xX][a-zA-Z0-9]+|\d+)'

    tokens = {
        'root': [
            include('whitespace'),
            (identifier + ':', Name.Label),
            (r'\.' + identifier, Name.Attribute, 'directive-args'),
            (r'lock|rep(n?z)?|data\d+', Name.Attribute),
            (identifier, Name.Function, 'instruction-args'),
            (r'[\r\n]+', Text)
        ],
        'directive-args': [
            (identifier, Name.Constant),
            (string, String),
            ('@' + identifier, Name.Attribute),
            (number, Number.Integer),
            (r'[\r\n]+', Text, '#pop'),

            (r'#.*?$', Comment, '#pop'),

            include('punctuation'),
            include('whitespace')
        ],
        'instruction-args': [
            # For objdump-disassembled code, shouldn't occur in
            # actual assembler input
            ('([a-z0-9]+)( )(<)('+identifier+')(>)',
                bygroups(Number.Hex, Text, Punctuation, Name.Constant,
                         Punctuation)),
            ('([a-z0-9]+)( )(<)('+identifier+')([-+])('+number+')(>)',
                bygroups(Number.Hex, Text, Punctuation, Name.Constant,
                         Punctuation, Number.Integer, Punctuation)),

            # Address constants
            (identifier, Name.Constant),
            (number, Number.Integer),
            # Registers
            ('%' + identifier, Name.Variable),
            # Numeric constants
            ('$'+number, Number.Integer),
            (r'[\r\n]+', Text, '#pop'),
            (r'#.*?$', Comment, '#pop'),
            include('punctuation'),
            include('whitespace')
        ],
        'whitespace': [
            (r'\n', Text),
            (r'\s+', Text),
            (r'#.*?\n', Comment)
        ],
        'punctuation': [
            (r'[-*,.():]+', Punctuation)
        ]
    }

    def analyse_text(text):
        return re.match(r'^\.\w+', text, re.M)

class ObjdumpLexer(RegexLexer):
    """
    For the output of 'objdump -dr'
    """
    name = 'objdump'
    aliases = ['objdump']
    filenames = ['*.objdump']
    mimetypes = ['text/x-objdump']

    hex = r'[0-9A-Za-z]'

    tokens = {
        'root': [
            # File name & format:
            ('(.*?)(:)( +file format )(.*?)$',
                bygroups(Name.Label, Punctuation, Text, String)),
            # Section header
            ('(Disassembly of section )(.*?)(:)$',
                bygroups(Text, Name.Label, Punctuation)),
            # Function labels
            # (With offset)
            ('('+hex+'+)( )(<)(.*?)([-+])(0[xX][A-Za-z0-9]+)(>:)$',
                bygroups(Number.Hex, Text, Punctuation, Name.Function,
                         Punctuation, Number.Hex, Punctuation)),
            # (Without offset)
            ('('+hex+'+)( )(<)(.*?)(>:)$',
                bygroups(Number.Hex, Text, Punctuation, Name.Function,
                         Punctuation)),
            # Code line with disassembled instructions
            ('( *)('+hex+r'+:)(\t)((?:'+hex+hex+' )+)( *\t)([a-zA-Z].*?)$',
                bygroups(Text, Name.Label, Text, Number.Hex, Text,
                         using(GasLexer))),
            # Code line with ascii
            ('( *)('+hex+r'+:)(\t)((?:'+hex+hex+' )+)( *)(.*?)$',
                bygroups(Text, Name.Label, Text, Number.Hex, Text, String)),
            # Continued code line, only raw opcodes without disassembled
            # instruction
            ('( *)('+hex+r'+:)(\t)((?:'+hex+hex+' )+)$',
                bygroups(Text, Name.Label, Text, Number.Hex)),
            # Skipped a few bytes
            ('\t\.\.\.$', Text),
            # Relocation line
            # (With offset)
            ('(\t\t\t)('+hex+'+:)( )([^\t]+)(\t)(.*?)([-+])(0x' + hex + '+)$',
                bygroups(Text, Name.Label, Text, Name.Property, Text,
                         Name.Constant, Punctuation, Number.Hex)),
            # (Without offset)
            ('(\t\t\t)('+hex+'+:)( )([^\t]+)(\t)(.*?)$',
                bygroups(Text, Name.Label, Text, Name.Property, Text,
                         Name.Constant)),
            ('[^\n]+\n', Other)
        ]
    }


class DObjdumpLexer(DelegatingLexer):
    """
    For the output of 'objdump -Sr on compiled D files'
    """
    name = 'd-objdump'
    aliases = ['d-objdump']
    filenames = ['*.d-objdump']
    mimetypes = ['text/x-d-objdump']

    def __init__(self, **options):
        super(DObjdumpLexer, self).__init__(DLexer, ObjdumpLexer, **options)


class CppObjdumpLexer(DelegatingLexer):
    """
    For the output of 'objdump -Sr on compiled C++ files'
    """
    name = 'cpp-objdump'
    aliases = ['cpp-objdump', 'c++-objdumb', 'cxx-objdump']
    filenames = ['*.cpp-objdump', '*.c++-objdump', '*.cxx-objdump']
    mimetypes = ['text/x-cpp-objdump']

    def __init__(self, **options):
        super(CppObjdumpLexer, self).__init__(CppLexer, ObjdumpLexer, **options)


class CObjdumpLexer(DelegatingLexer):
    """
    For the output of 'objdump -Sr on compiled C files'
    """
    name = 'c-objdump'
    aliases = ['c-objdump']
    filenames = ['*.c-objdump']
    mimetypes = ['text/x-c-objdump']

    def __init__(self, **options):
        super(CObjdumpLexer, self).__init__(CLexer, ObjdumpLexer, **options)


class LlvmLexer(RegexLexer):
    """
    For LLVM assembly code.
    """
    name = 'LLVM'
    aliases = ['llvm']
    filenames = ['*.ll']
    mimetypes = ['text/x-llvm']

    #: optional Comment or Whitespace
    string = r'"[^"]*?"'
    identifier = r'([a-zA-Z$._][a-zA-Z$._0-9]*|' + string + ')'

    tokens = {
        'root': [
            include('whitespace'),

            # Before keywords, because keywords are valid label names :(...
            (r'^\s*' + identifier + '\s*:', Name.Label),

            include('keyword'),

            (r'%' + identifier, Name.Variable),#Name.Identifier.Local),
            (r'@' + identifier, Name.Constant),#Name.Identifier.Global),
            (r'%\d+', Name.Variable.Anonymous),#Name.Identifier.Anonymous),
            (r'c?' + string, String),

            (r'0[xX][a-fA-F0-9]+', Number),
            (r'-?\d+(?:[.]\d+)?(?:[eE][-+]?\d+(?:[.]\d+)?)?', Number),

            (r'[=<>{}\[\]()*.,]|x\b', Punctuation)
        ],
        'whitespace': [
            (r'(\n|\s)+', Text),
            (r';.*?\n', Comment)
        ],
        'keyword': [
            # Regular keywords
            (r'(void|label|float|double|opaque'
             r'|to'
             r'|alias|type'
             r'|zeroext|signext|inreg|sret|noalias|noreturn|nounwind|nest'
             r'|module|asm|target|datalayout|triple'
             r'|true|false|null|zeroinitializer|undef'
             r'|global|internal|external|linkonce|weak|appending|extern_weak'
             r'|dllimport|dllexport'
             r'|ccc|fastcc|coldcc|cc|tail'
             r'|default|hidden|protected'
             r'|thread_local|constant|align|section'
             r'|define|declare'

             # Statements & expressions
             r'|trunc|zext|sext|fptrunc|fpext|fptoui|fptosi|uitofp|sitofp'
             r'|ptrtoint|inttoptr|bitcast|getelementptr|select|icmp|fcmp'
             r'|extractelement|insertelement|shufflevector'
             r'|sideeffect|volatile'
             r'|ret|br|switch|invoke|unwind|unreachable'
             r'|add|sub|mul|udiv|sdiv|fdiv|urem|srem|frem'
             r'|shl|lshr|ashr|and|or|xor'
             r'|malloc|free|alloca|load|store'
             r'|phi|call|va_arg|va_list'

             # Comparison condition codes for icmp
             r'|eq|ne|ugt|uge|ult|ule|sgt|sge|slt|sle'
             # Ditto for fcmp: (minus keywords mentioned in other contexts)
             r'|oeq|ogt|oge|olt|ole|one|ord|ueq|ugt|uge|une|uno'

             r')\b', Keyword),
            # Integer types
            (r'i[1-9]\d*', Keyword)
        ]
    }


class NasmLexer(RegexLexer):
    """
    For Nasm (Intel) assembly code.
    """
    name = 'NASM'
    aliases = ['nasm']
    filenames = ['*.asm', '*.ASM']
    mimetypes = ['text/x-nasm']

    identifier = r'[a-zA-Z$._?][a-zA-Z0-9$._?#@~]*'
    hexn = r'(?:0[xX][0-9a-fA-F]+|$0[0-9a-fA-F]*|[0-9a-fA-F]+h)'
    octn = r'[0-7]+q'
    binn = r'[01]+b'
    decn = r'[0-9]+'
    floatn = decn + r'\.e?' + decn
    string = r'"(\\"|[^"])*"|' + r"'(\\'|[^'])*'"
    declkw = r'(?:res|d)[bwdqt]|times'
    register = (r'[a-d][lh]|e?[a-d]x|e?[sb]p|e?[sd]i|[c-gs]s|st[0-7]|'
                r'mm[0-7]|cr[0-4]|dr[0-367]|tr[3-7]')
    wordop = r'seg|wrt|strict'
    type = r'byte|[dq]?word'
    directives = (r'BITS|USE16|USE32|SECTION|SEGMENT|ABSOLUTE|EXTERN|GLOBAL|'
                  r'COMMON|CPU|GROUP|UPPERCASE|IMPORT|EXPORT|LIBRARY|MODULE')

    flags = re.IGNORECASE | re.MULTILINE
    tokens = {
        'root': [
            include('whitespace'),
            (r'^\s*%', Comment.Preproc, 'preproc'),
            (identifier + ':', Name.Label),
            (directives, Keyword, 'instruction-args'),
            (r'(%s)\s+(equ)' % identifier,
                bygroups(Name.Constant, Keyword.Declaration),
                'instruction-args'),
            (declkw, Keyword.Declaration, 'instruction-args'),
            (identifier, Name.Function, 'instruction-args'),
            (r'[\r\n]+', Text)
        ],
        'instruction-args': [
            (string, String),
            (hexn, Number.Hex),
            (octn, Number.Oct),
            (binn, Number),
            (floatn, Number.Float),
            (decn, Number.Integer),
            include('punctuation'),
            (register, Name.Builtin),
            (identifier, Name.Variable),
            (r'[\r\n]+', Text, '#pop'),
            include('whitespace')
        ],
        'preproc': [
            (r'[^;\n]+', Comment.Preproc),
            (r';.*?\n', Comment.Single, '#pop'),
            (r'\n', Comment.Preproc, '#pop'),
        ],
        'whitespace': [
            (r'\n', Text),
            (r'[ \t]+', Text),
            (r';.*', Comment.Single)
        ],
        'punctuation': [
            (r'[,():\[\]]+', Punctuation),
            (r'[&|^<>+*/%~-]+', Operator),
            (r'[$]+', Keyword.Constant),
            (wordop, Operator.Word),
            (type, Keyword.Type)
        ],
    }
# -*- coding: utf-8 -*-
"""
    pygments.lexers.compiled
    ~~~~~~~~~~~~~~~~~~~~~~~~

    Lexers for compiled languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.scanner import Scanner
from pygments.lexer import Lexer, RegexLexer, include, bygroups, using, \
                           this, combined
from pygments.util import get_bool_opt, get_list_opt
from pygments.token import \
     Text, Comment, Operator, Keyword, Name, String, Number, Punctuation, \
     Error

# backwards compatibility
from pygments.lexers.functional import OcamlLexer

__all__ = ['CLexer', 'CppLexer', 'DLexer', 'DelphiLexer', 'JavaLexer', 'ScalaLexer',
           'DylanLexer', 'OcamlLexer', 'ObjectiveCLexer', 'FortranLexer',
           'GLShaderLexer', 'PrologLexer', 'CythonLexer']


class CLexer(RegexLexer):
    """
    For C source code with preprocessor directives.
    """
    name = 'C'
    aliases = ['c']
    filenames = ['*.c', '*.h']
    mimetypes = ['text/x-chdr', 'text/x-csrc']

    #: optional Comment or Whitespace
    _ws = r'(?:\s|//.*?\n|/[*].*?[*]/)+'

    tokens = {
        'whitespace': [
            (r'^\s*#if\s+0', Comment.Preproc, 'if0'),
            (r'^\s*#', Comment.Preproc, 'macro'),
            (r'\n', Text),
            (r'\s+', Text),
            (r'\\\n', Text), # line continuation
            (r'//(\n|(.|\n)*?[^\\]\n)', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
        ],
        'statements': [
            (r'L?"', String, 'string'),
            (r"L?'(\\.|\\[0-7]{1,3}|\\x[a-fA-F0-9]{1,2}|[^\\\'\n])'", String.Char),
            (r'(\d+\.\d*|\.\d+|\d+)[eE][+-]?\d+[lL]?', Number.Float),
            (r'(\d+\.\d*|\.\d+|\d+[fF])[fF]?', Number.Float),
            (r'0x[0-9a-fA-F]+[Ll]?', Number.Hex),
            (r'0[0-7]+[Ll]?', Number.Oct),
            (r'\d+[Ll]?', Number.Integer),
            (r'[~!%^&*+=|?:<>/-]', Operator),
            (r'[()\[\],.]', Punctuation),
            (r'\b(case)(.+?)(:)', bygroups(Keyword, using(this), Text)),
            (r'(auto|break|case|const|continue|default|do|else|enum|extern|'
             r'for|goto|if|register|restricted|return|sizeof|static|struct|'
             r'switch|typedef|union|volatile|virtual|while)\b', Keyword),
            (r'(int|long|float|short|double|char|unsigned|signed|void)\b',
             Keyword.Type),
            (r'(_{0,2}inline|naked|restrict|thread|typename)\b', Keyword.Reserved),
            (r'__(asm|int8|based|except|int16|stdcall|cdecl|fastcall|int32|'
             r'declspec|finally|int64|try|leave)\b', Keyword.Reserved),
            (r'(true|false|NULL)\b', Name.Builtin),
            ('[a-zA-Z_][a-zA-Z0-9_]*:(?!:)', Name.Label),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
        ],
        'root': [
            include('whitespace'),
            # functions
            (r'((?:[a-zA-Z0-9_*\s])+?(?:\s|[*]))'    # return arguments
             r'([a-zA-Z_][a-zA-Z0-9_]*)'             # method name
             r'(\s*\([^;]*?\))'                      # signature
             r'(' + _ws + r')({)',
             bygroups(using(this), Name.Function, using(this), using(this),
                      Punctuation),
             'function'),
            # function declarations
            (r'((?:[a-zA-Z0-9_*\s])+?(?:\s|[*]))'    # return arguments
             r'([a-zA-Z_][a-zA-Z0-9_]*)'             # method name
             r'(\s*\([^;]*?\))'                      # signature
             r'(' + _ws + r')(;)',
             bygroups(using(this), Name.Function, using(this), using(this),
                      Punctuation)),
            ('', Text, 'statement'),
        ],
        'statement' : [
            include('whitespace'),
            include('statements'),
            ('[{}]', Punctuation),
            (';', Punctuation, '#pop'),
        ],
        'function': [
            include('whitespace'),
            include('statements'),
            (';', Punctuation),
            ('{', Punctuation, '#push'),
            ('}', Punctuation, '#pop'),
        ],
        'string': [
            (r'"', String, '#pop'),
            (r'\\([\\abfnrtv"\']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})', String.Escape),
            (r'[^\\"\n]+', String), # all other characters
            (r'\\\n', String), # line continuation
            (r'\\', String), # stray backslash
        ],
        'macro': [
            (r'[^/\n]+', Comment.Preproc),
            (r'/[*](.|\n)*?[*]/', Comment),
            (r'//.*?\n', Comment, '#pop'),
            (r'/', Comment.Preproc),
            (r'(?<=\\)\n', Comment.Preproc),
            (r'\n', Comment.Preproc, '#pop'),
        ],
        'if0': [
            (r'^\s*#if.*?(?<!\\)\n', Comment, '#push'),
            (r'^\s*#el(?:se|if).*\n', Comment.Preproc, '#pop'),
            (r'^\s*#endif.*?(?<!\\)\n', Comment, '#pop'),
            (r'.*?\n', Comment),
        ]
    }

    stdlib_types = ['size_t', 'ssize_t', 'off_t', 'wchar_t', 'ptrdiff_t',
            'sig_atomic_t', 'fpos_t', 'clock_t', 'time_t', 'va_list',
            'jmp_buf', 'FILE', 'DIR', 'div_t', 'ldiv_t', 'mbstate_t',
            'wctrans_t', 'wint_t', 'wctype_t']
    c99_types = ['_Bool', '_Complex', 'int8_t', 'int16_t', 'int32_t', 'int64_t',
            'uint8_t', 'uint16_t', 'uint32_t', 'uint64_t', 'int_least8_t',
            'int_least16_t', 'int_least32_t', 'int_least64_t',
            'uint_least8_t', 'uint_least16_t', 'uint_least32_t',
            'uint_least64_t', 'int_fast8_t', 'int_fast16_t', 'int_fast32_t',
            'int_fast64_t', 'uint_fast8_t', 'uint_fast16_t', 'uint_fast32_t',
            'uint_fast64_t', 'intptr_t', 'uintptr_t', 'intmax_t', 'uintmax_t']

    def __init__(self, **options):
        self.stdlibhighlighting = get_bool_opt(options,
                'stdlibhighlighting', True)
        self.c99highlighting = get_bool_opt(options,
                'c99highlighting', True)
        RegexLexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        for index, token, value in \
            RegexLexer.get_tokens_unprocessed(self, text):
            if token is Name:
                if self.stdlibhighlighting and value in self.stdlib_types:
                    token = Keyword.Type
                elif self.c99highlighting and value in self.c99_types:
                    token = Keyword.Type
            yield index, token, value

class CppLexer(RegexLexer):
    """
    For C++ source code with preprocessor directives.
    """
    name = 'C++'
    aliases = ['cpp', 'c++']
    filenames = ['*.cpp', '*.hpp', '*.c++', '*.h++', '*.cc', '*.hh', '*.cxx', '*.hxx']
    mimetypes = ['text/x-c++hdr', 'text/x-c++src']

    tokens = {
        'root': [
            (r'^\s*#if\s+0', Comment.Preproc, 'if0'),
            (r'^\s*#', Comment.Preproc, 'macro'),
            (r'\n', Text),
            (r'\s+', Text),
            (r'\\\n', Text), # line continuation
            (r'/(\\\n)?/(\n|(.|\n)*?[^\\]\n)', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
            (r'[{}]', Punctuation),
            (r'L?"', String, 'string'),
            (r"L?'(\\.|\\[0-7]{1,3}|\\x[a-fA-F0-9]{1,2}|[^\\\'\n])'", String.Char),
            (r'(\d+\.\d*|\.\d+|\d+)[eE][+-]?\d+[lL]?', Number.Float),
            (r'(\d+\.\d*|\.\d+|\d+[fF])[fF]?', Number.Float),
            (r'0x[0-9a-fA-F]+[Ll]?', Number.Hex),
            (r'0[0-7]+[Ll]?', Number.Oct),
            (r'\d+[Ll]?', Number.Integer),
            (r'[~!%^&*+=|?:<>/-]', Operator),
            (r'[()\[\],.;]', Punctuation),
            (r'(asm|auto|break|case|catch|const|const_cast|continue|'
             r'default|delete|do|dynamic_cast|else|enum|explicit|export|'
             r'extern|for|friend|goto|if|mutable|namespace|new|operator|'
             r'private|protected|public|register|reinterpret_cast|return|'
             r'restrict|sizeof|static|static_cast|struct|switch|template|'
             r'this|throw|throws|try|typedef|typeid|typename|union|using|'
             r'volatile|virtual|while)\b', Keyword),
            (r'(class)(\s+)', bygroups(Keyword, Text), 'classname'),
            (r'(bool|int|long|float|short|double|char|unsigned|signed|'
             r'void|wchar_t)\b', Keyword.Type),
            (r'(_{0,2}inline|naked|thread)\b', Keyword.Reserved),
            (r'__(asm|int8|based|except|int16|stdcall|cdecl|fastcall|int32|'
             r'declspec|finally|int64|try|leave|wchar_t|w64|virtual_inheritance|'
             r'uuidof|unaligned|super|single_inheritance|raise|noop|'
             r'multiple_inheritance|m128i|m128d|m128|m64|interface|'
             r'identifier|forceinline|event|assume)\b', Keyword.Reserved),
            (r'(true|false)\b', Keyword.Constant),
            (r'NULL\b', Name.Builtin),
            ('[a-zA-Z_][a-zA-Z0-9_]*:(?!:)', Name.Label),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
        ],
        'classname': [
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name.Class, '#pop'),
            # template specification
            (r'\s*(?=>)', Text, '#pop'),
        ],
        'string': [
            (r'"', String, '#pop'),
            (r'\\([\\abfnrtv"\']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})', String.Escape),
            (r'[^\\"\n]+', String), # all other characters
            (r'\\\n', String), # line continuation
            (r'\\', String), # stray backslash
        ],
        'macro': [
            (r'[^/\n]+', Comment.Preproc),
            (r'/[*](.|\n)*?[*]/', Comment),
            (r'//.*?\n', Comment, '#pop'),
            (r'/', Comment.Preproc),
            (r'(?<=\\)\n', Comment.Preproc),
            (r'\n', Comment.Preproc, '#pop'),
        ],
        'if0': [
            (r'^\s*#if.*?(?<!\\)\n', Comment, '#push'),
            (r'^\s*#endif.*?(?<!\\)\n', Comment, '#pop'),
            (r'.*?\n', Comment),
        ]
    }


class DLexer(RegexLexer):
    """
    For D source.
    """
    name = 'D'
    filenames = ['*.d', '*.di']
    aliases = ['d']
    mimetypes = ['text/x-dsrc']

    tokens = {
        'root': [
            (r'\n', Text),
            (r'\s+', Text),
            #(r'\\\n', Text), # line continuations
            # Comments
            (r'//(.*?)\n', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
            (r'/\+', Comment, 'nested_comment'),
            # Keywords
            (r'(abstract|alias|align|asm|assert|auto|body|break|case|cast'
             r'|catch|class|const|continue|debug|default|delegate|delete'
             r'|deprecated|do|else|enum|export|extern|finally|final'
             r'|foreach_reverse|foreach|for|function|goto|if|import|inout'
             r'|interface|invariant|in|is|lazy|mixin|module|new|nothrow|out'
             r'|override|package|pragma|private|protected|public|pure|ref|return'
             r'|scope|static|struct|super|switch|synchronized|template|this'
             r'|throw|try|typedef|typeid|typeof|union|unittest|version|volatile'
             r'|while|with|__traits)\b', Keyword
            ),
            (r'(bool|byte|cdouble|cent|cfloat|char|creal|dchar|double|float'
             r'|idouble|ifloat|int|ireal|long|real|short|ubyte|ucent|uint|ulong'
             r'|ushort|void|wchar)\b', Keyword.Type
            ),
            (r'(false|true|null)\b', Keyword.Constant),
            (r'macro\b', Keyword.Reserved),
            (r'(string|wstring|dstring)\b', Name.Builtin),
            # FloatLiteral
            # -- HexFloat
            (r'0[xX]([0-9a-fA-F_]*\.[0-9a-fA-F_]+|[0-9a-fA-F_]+)'
             r'[pP][+\-]?[0-9_]+[fFL]?[i]?', Number.Float),
            # -- DecimalFloat
            (r'[0-9_]+(\.[0-9_]+[eE][+\-]?[0-9_]+|'
             r'\.[0-9_]*|[eE][+\-]?[0-9_]+)[fFL]?[i]?', Number.Float),
            (r'\.(0|[1-9][0-9_]*)([eE][+\-]?[0-9_]+)?[fFL]?[i]?', Number.Float),
            # IntegerLiteral
            # -- Binary
            (r'0[Bb][01_]+', Number),
            # -- Octal
            (r'0[0-7_]+', Number.Oct),
            # -- Hexadecimal
            (r'0[xX][0-9a-fA-F_]+', Number.Hex),
            # -- Decimal
            (r'(0|[1-9][0-9_]*)([LUu]|Lu|LU|uL|UL)?', Number.Integer),
            # CharacterLiteral
            (r"""'(\\['"?\\abfnrtv]|\\x[0-9a-fA-F]{2}|\\[0-7]{1,3}"""
             r"""|\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8}|\\&\w+;|.)'""",
             String.Char
            ),
            # StringLiteral
            # -- WysiwygString
            (r'r"[^"]*"[cwd]?', String),
            # -- AlternateWysiwygString
            (r'`[^`]*`[cwd]?', String),
            # -- DoubleQuotedString
            (r'"(\\\\|\\"|[^"])*"[cwd]?', String),
            # -- EscapeSequence
            (r"""\\(['"?\\abfnrtv]|x[0-9a-fA-F]{2}|[0-7]{1,3}"""
             r"""|u[0-9a-fA-F]{4}|U[0-9a-fA-F]{8}|&\w+;)""",
             String
            ),
            # -- HexString
            (r'x"[0-9a-fA-F_\s]*"[cwd]?', String),
            # -- DelimitedString
            (r'q"\[', String, 'delimited_bracket'),
            (r'q"\(', String, 'delimited_parenthesis'),
            (r'q"<', String, 'delimited_angle'),
            (r'q"{', String, 'delimited_curly'),
            (r'q"([a-zA-Z_]\w*)\n.*?\n\1"', String),
            (r'q"(.).*?\1"', String),
            # -- TokenString
            (r'q{', String, 'token_string'),
            # Tokens
            (r'(~=|\^=|%=|\*=|==|!>=|!<=|!<>=|!<>|!<|!>|!=|>>>=|>>>|>>=|>>|>='
             r'|<>=|<>|<<=|<<|<=|\+\+|\+=|--|-=|\|\||\|=|&&|&=|\.\.\.|\.\.|/=)'
             r'|[/.&|\-+<>!()\[\]{}?,;:$=*%^~]', Punctuation
            ),
            # Identifier
            (r'[a-zA-Z_]\w*', Name),
        ],
        'nested_comment': [
            (r'[^+/]+', Comment),
            (r'/\+', Comment, '#push'),
            (r'\+/', Comment, '#pop'),
            (r'[+/]', Comment),
        ],
        'token_string': [
            (r'{', Punctuation, 'token_string_nest'),
            (r'}', String, '#pop'),
            include('root'),
        ],
        'token_string_nest': [
            (r'{', Punctuation, '#push'),
            (r'}', Punctuation, '#pop'),
            include('root'),
        ],
        'delimited_bracket': [
            (r'[^\[\]]+', String),
            (r'\[', String, 'delimited_inside_bracket'),
            (r'\]"', String, '#pop'),
        ],
        'delimited_inside_bracket': [
            (r'[^\[\]]+', String),
            (r'\[', String, '#push'),
            (r'\]', String, '#pop'),
        ],
        'delimited_parenthesis': [
            (r'[^\(\)]+', String),
            (r'\(', String, 'delimited_inside_parenthesis'),
            (r'\)"', String, '#pop'),
        ],
        'delimited_inside_parenthesis': [
            (r'[^\(\)]+', String),
            (r'\(', String, '#push'),
            (r'\)', String, '#pop'),
        ],
        'delimited_angle': [
            (r'[^<>]+', String),
            (r'<', String, 'delimited_inside_angle'),
            (r'>"', String, '#pop'),
        ],
        'delimited_inside_angle': [
            (r'[^<>]+', String),
            (r'<', String, '#push'),
            (r'>', String, '#pop'),
        ],
        'delimited_curly': [
            (r'[^{}]+', String),
            (r'{', String, 'delimited_inside_curly'),
            (r'}"', String, '#pop'),
        ],
        'delimited_inside_curly': [
            (r'[^{}]+', String),
            (r'{', String, '#push'),
            (r'}', String, '#pop'),
        ],
    }


class DelphiLexer(Lexer):
    """
    For `Delphi <http://www.borland.com/delphi/>`_ (Borland Object Pascal),
    Turbo Pascal and Free Pascal source code.

    Additional options accepted:

    `turbopascal`
        Highlight Turbo Pascal specific keywords (default: ``True``).
    `delphi`
        Highlight Borland Delphi specific keywords (default: ``True``).
    `freepascal`
        Highlight Free Pascal specific keywords (default: ``True``).
    `units`
        A list of units that should be considered builtin, supported are
        ``System``, ``SysUtils``, ``Classes`` and ``Math``.
        Default is to consider all of them builtin.
    """
    name = 'Delphi'
    aliases = ['delphi', 'pas', 'pascal', 'objectpascal']
    filenames = ['*.pas']
    mimetypes = ['text/x-pascal']

    TURBO_PASCAL_KEYWORDS = [
        'absolute', 'and', 'array', 'asm', 'begin', 'break', 'case',
        'const', 'constructor', 'continue', 'destructor', 'div', 'do',
        'downto', 'else', 'end', 'file', 'for', 'function', 'goto',
        'if', 'implementation', 'in', 'inherited', 'inline', 'interface',
        'label', 'mod', 'nil', 'not', 'object', 'of', 'on', 'operator',
        'or', 'packed', 'procedure', 'program', 'record', 'reintroduce',
        'repeat', 'self', 'set', 'shl', 'shr', 'string', 'then', 'to',
        'type', 'unit', 'until', 'uses', 'var', 'while', 'with', 'xor'
    ]

    DELPHI_KEYWORDS = [
        'as', 'class', 'except', 'exports', 'finalization', 'finally',
        'initialization', 'is', 'library', 'on', 'property', 'raise',
        'threadvar', 'try'
    ]

    FREE_PASCAL_KEYWORDS = [
        'dispose', 'exit', 'false', 'new', 'true'
    ]

    BLOCK_KEYWORDS = set([
        'begin', 'class', 'const', 'constructor', 'destructor', 'end',
        'finalization', 'function', 'implementation', 'initialization',
        'label', 'library', 'operator', 'procedure', 'program', 'property',
        'record', 'threadvar', 'type', 'unit', 'uses', 'var'
    ])

    FUNCTION_MODIFIERS = set([
        'alias', 'cdecl', 'export', 'inline', 'interrupt', 'nostackframe',
        'pascal', 'register', 'safecall', 'softfloat', 'stdcall',
        'varargs', 'name', 'dynamic', 'near', 'virtual', 'external',
        'override', 'assembler'
    ])

    # XXX: those aren't global. but currently we know no way for defining
    #      them just for the type context.
    DIRECTIVES = set([
        'absolute', 'abstract', 'assembler', 'cppdecl', 'default', 'far',
        'far16', 'forward', 'index', 'oldfpccall', 'private', 'protected',
        'published', 'public'
    ])

    BUILTIN_TYPES = set([
        'ansichar', 'ansistring', 'bool', 'boolean', 'byte', 'bytebool',
        'cardinal', 'char', 'comp', 'currency', 'double', 'dword',
        'extended', 'int64', 'integer', 'iunknown', 'longbool', 'longint',
        'longword', 'pansichar', 'pansistring', 'pbool', 'pboolean',
        'pbyte', 'pbytearray', 'pcardinal', 'pchar', 'pcomp', 'pcurrency',
        'pdate', 'pdatetime', 'pdouble', 'pdword', 'pextended', 'phandle',
        'pint64', 'pinteger', 'plongint', 'plongword', 'pointer',
        'ppointer', 'pshortint', 'pshortstring', 'psingle', 'psmallint',
        'pstring', 'pvariant', 'pwidechar', 'pwidestring', 'pword',
        'pwordarray', 'pwordbool', 'real', 'real48', 'shortint',
        'shortstring', 'single', 'smallint', 'string', 'tclass', 'tdate',
        'tdatetime', 'textfile', 'thandle', 'tobject', 'ttime', 'variant',
        'widechar', 'widestring', 'word', 'wordbool'
    ])

    BUILTIN_UNITS = {
        'System': [
            'abs', 'acquireexceptionobject', 'addr', 'ansitoutf8',
            'append', 'arctan', 'assert', 'assigned', 'assignfile',
            'beginthread', 'blockread', 'blockwrite', 'break', 'chdir',
            'chr', 'close', 'closefile', 'comptocurrency', 'comptodouble',
            'concat', 'continue', 'copy', 'cos', 'dec', 'delete',
            'dispose', 'doubletocomp', 'endthread', 'enummodules',
            'enumresourcemodules', 'eof', 'eoln', 'erase', 'exceptaddr',
            'exceptobject', 'exclude', 'exit', 'exp', 'filepos', 'filesize',
            'fillchar', 'finalize', 'findclasshinstance', 'findhinstance',
            'findresourcehinstance', 'flush', 'frac', 'freemem',
            'get8087cw', 'getdir', 'getlasterror', 'getmem',
            'getmemorymanager', 'getmodulefilename', 'getvariantmanager',
            'halt', 'hi', 'high', 'inc', 'include', 'initialize', 'insert',
            'int', 'ioresult', 'ismemorymanagerset', 'isvariantmanagerset',
            'length', 'ln', 'lo', 'low', 'mkdir', 'move', 'new', 'odd',
            'olestrtostring', 'olestrtostrvar', 'ord', 'paramcount',
            'paramstr', 'pi', 'pos', 'pred', 'ptr', 'pucs4chars', 'random',
            'randomize', 'read', 'readln', 'reallocmem',
            'releaseexceptionobject', 'rename', 'reset', 'rewrite', 'rmdir',
            'round', 'runerror', 'seek', 'seekeof', 'seekeoln',
            'set8087cw', 'setlength', 'setlinebreakstyle',
            'setmemorymanager', 'setstring', 'settextbuf',
            'setvariantmanager', 'sin', 'sizeof', 'slice', 'sqr', 'sqrt',
            'str', 'stringofchar', 'stringtoolestr', 'stringtowidechar',
            'succ', 'swap', 'trunc', 'truncate', 'typeinfo',
            'ucs4stringtowidestring', 'unicodetoutf8', 'uniquestring',
            'upcase', 'utf8decode', 'utf8encode', 'utf8toansi',
            'utf8tounicode', 'val', 'vararrayredim', 'varclear',
            'widecharlentostring', 'widecharlentostrvar',
            'widechartostring', 'widechartostrvar',
            'widestringtoucs4string', 'write', 'writeln'
        ],
        'SysUtils': [
            'abort', 'addexitproc', 'addterminateproc', 'adjustlinebreaks',
            'allocmem', 'ansicomparefilename', 'ansicomparestr',
            'ansicomparetext', 'ansidequotedstr', 'ansiextractquotedstr',
            'ansilastchar', 'ansilowercase', 'ansilowercasefilename',
            'ansipos', 'ansiquotedstr', 'ansisamestr', 'ansisametext',
            'ansistrcomp', 'ansistricomp', 'ansistrlastchar', 'ansistrlcomp',
            'ansistrlicomp', 'ansistrlower', 'ansistrpos', 'ansistrrscan',
            'ansistrscan', 'ansistrupper', 'ansiuppercase',
            'ansiuppercasefilename', 'appendstr', 'assignstr', 'beep',
            'booltostr', 'bytetocharindex', 'bytetocharlen', 'bytetype',
            'callterminateprocs', 'changefileext', 'charlength',
            'chartobyteindex', 'chartobytelen', 'comparemem', 'comparestr',
            'comparetext', 'createdir', 'createguid', 'currentyear',
            'currtostr', 'currtostrf', 'date', 'datetimetofiledate',
            'datetimetostr', 'datetimetostring', 'datetimetosystemtime',
            'datetimetotimestamp', 'datetostr', 'dayofweek', 'decodedate',
            'decodedatefully', 'decodetime', 'deletefile', 'directoryexists',
            'diskfree', 'disksize', 'disposestr', 'encodedate', 'encodetime',
            'exceptionerrormessage', 'excludetrailingbackslash',
            'excludetrailingpathdelimiter', 'expandfilename',
            'expandfilenamecase', 'expanduncfilename', 'extractfiledir',
            'extractfiledrive', 'extractfileext', 'extractfilename',
            'extractfilepath', 'extractrelativepath', 'extractshortpathname',
            'fileage', 'fileclose', 'filecreate', 'filedatetodatetime',
            'fileexists', 'filegetattr', 'filegetdate', 'fileisreadonly',
            'fileopen', 'fileread', 'filesearch', 'fileseek', 'filesetattr',
            'filesetdate', 'filesetreadonly', 'filewrite', 'finalizepackage',
            'findclose', 'findcmdlineswitch', 'findfirst', 'findnext',
            'floattocurr', 'floattodatetime', 'floattodecimal', 'floattostr',
            'floattostrf', 'floattotext', 'floattotextfmt', 'fmtloadstr',
            'fmtstr', 'forcedirectories', 'format', 'formatbuf', 'formatcurr',
            'formatdatetime', 'formatfloat', 'freeandnil', 'getcurrentdir',
            'getenvironmentvariable', 'getfileversion', 'getformatsettings',
            'getlocaleformatsettings', 'getmodulename', 'getpackagedescription',
            'getpackageinfo', 'gettime', 'guidtostring', 'incamonth',
            'includetrailingbackslash', 'includetrailingpathdelimiter',
            'incmonth', 'initializepackage', 'interlockeddecrement',
            'interlockedexchange', 'interlockedexchangeadd',
            'interlockedincrement', 'inttohex', 'inttostr', 'isdelimiter',
            'isequalguid', 'isleapyear', 'ispathdelimiter', 'isvalidident',
            'languages', 'lastdelimiter', 'loadpackage', 'loadstr',
            'lowercase', 'msecstotimestamp', 'newstr', 'nextcharindex', 'now',
            'outofmemoryerror', 'quotedstr', 'raiselastoserror',
            'raiselastwin32error', 'removedir', 'renamefile', 'replacedate',
            'replacetime', 'safeloadlibrary', 'samefilename', 'sametext',
            'setcurrentdir', 'showexception', 'sleep', 'stralloc', 'strbufsize',
            'strbytetype', 'strcat', 'strcharlength', 'strcomp', 'strcopy',
            'strdispose', 'strecopy', 'strend', 'strfmt', 'stricomp',
            'stringreplace', 'stringtoguid', 'strlcat', 'strlcomp', 'strlcopy',
            'strlen', 'strlfmt', 'strlicomp', 'strlower', 'strmove', 'strnew',
            'strnextchar', 'strpas', 'strpcopy', 'strplcopy', 'strpos',
            'strrscan', 'strscan', 'strtobool', 'strtobooldef', 'strtocurr',
            'strtocurrdef', 'strtodate', 'strtodatedef', 'strtodatetime',
            'strtodatetimedef', 'strtofloat', 'strtofloatdef', 'strtoint',
            'strtoint64', 'strtoint64def', 'strtointdef', 'strtotime',
            'strtotimedef', 'strupper', 'supports', 'syserrormessage',
            'systemtimetodatetime', 'texttofloat', 'time', 'timestamptodatetime',
            'timestamptomsecs', 'timetostr', 'trim', 'trimleft', 'trimright',
            'tryencodedate', 'tryencodetime', 'tryfloattocurr', 'tryfloattodatetime',
            'trystrtobool', 'trystrtocurr', 'trystrtodate', 'trystrtodatetime',
            'trystrtofloat', 'trystrtoint', 'trystrtoint64', 'trystrtotime',
            'unloadpackage', 'uppercase', 'widecomparestr', 'widecomparetext',
            'widefmtstr', 'wideformat', 'wideformatbuf', 'widelowercase',
            'widesamestr', 'widesametext', 'wideuppercase', 'win32check',
            'wraptext'
        ],
        'Classes': [
            'activateclassgroup', 'allocatehwnd', 'bintohex', 'checksynchronize',
            'collectionsequal', 'countgenerations', 'deallocatehwnd', 'equalrect',
            'extractstrings', 'findclass', 'findglobalcomponent', 'getclass',
            'groupdescendantswith', 'hextobin', 'identtoint',
            'initinheritedcomponent', 'inttoident', 'invalidpoint',
            'isuniqueglobalcomponentname', 'linestart', 'objectbinarytotext',
            'objectresourcetotext', 'objecttexttobinary', 'objecttexttoresource',
            'pointsequal', 'readcomponentres', 'readcomponentresex',
            'readcomponentresfile', 'rect', 'registerclass', 'registerclassalias',
            'registerclasses', 'registercomponents', 'registerintegerconsts',
            'registernoicon', 'registernonactivex', 'smallpoint', 'startclassgroup',
            'teststreamformat', 'unregisterclass', 'unregisterclasses',
            'unregisterintegerconsts', 'unregistermoduleclasses',
            'writecomponentresfile'
        ],
        'Math': [
            'arccos', 'arccosh', 'arccot', 'arccoth', 'arccsc', 'arccsch', 'arcsec',
            'arcsech', 'arcsin', 'arcsinh', 'arctan2', 'arctanh', 'ceil',
            'comparevalue', 'cosecant', 'cosh', 'cot', 'cotan', 'coth', 'csc',
            'csch', 'cycletodeg', 'cycletograd', 'cycletorad', 'degtocycle',
            'degtograd', 'degtorad', 'divmod', 'doubledecliningbalance',
            'ensurerange', 'floor', 'frexp', 'futurevalue', 'getexceptionmask',
            'getprecisionmode', 'getroundmode', 'gradtocycle', 'gradtodeg',
            'gradtorad', 'hypot', 'inrange', 'interestpayment', 'interestrate',
            'internalrateofreturn', 'intpower', 'isinfinite', 'isnan', 'iszero',
            'ldexp', 'lnxp1', 'log10', 'log2', 'logn', 'max', 'maxintvalue',
            'maxvalue', 'mean', 'meanandstddev', 'min', 'minintvalue', 'minvalue',
            'momentskewkurtosis', 'netpresentvalue', 'norm', 'numberofperiods',
            'payment', 'periodpayment', 'poly', 'popnstddev', 'popnvariance',
            'power', 'presentvalue', 'radtocycle', 'radtodeg', 'radtograd',
            'randg', 'randomrange', 'roundto', 'samevalue', 'sec', 'secant',
            'sech', 'setexceptionmask', 'setprecisionmode', 'setroundmode',
            'sign', 'simpleroundto', 'sincos', 'sinh', 'slndepreciation', 'stddev',
            'sum', 'sumint', 'sumofsquares', 'sumsandsquares', 'syddepreciation',
            'tan', 'tanh', 'totalvariance', 'variance'
        ]
    }

    ASM_REGISTERS = set([
        'ah', 'al', 'ax', 'bh', 'bl', 'bp', 'bx', 'ch', 'cl', 'cr0',
        'cr1', 'cr2', 'cr3', 'cr4', 'cs', 'cx', 'dh', 'di', 'dl', 'dr0',
        'dr1', 'dr2', 'dr3', 'dr4', 'dr5', 'dr6', 'dr7', 'ds', 'dx',
        'eax', 'ebp', 'ebx', 'ecx', 'edi', 'edx', 'es', 'esi', 'esp',
        'fs', 'gs', 'mm0', 'mm1', 'mm2', 'mm3', 'mm4', 'mm5', 'mm6',
        'mm7', 'si', 'sp', 'ss', 'st0', 'st1', 'st2', 'st3', 'st4', 'st5',
        'st6', 'st7', 'xmm0', 'xmm1', 'xmm2', 'xmm3', 'xmm4', 'xmm5',
        'xmm6', 'xmm7'
    ])

    ASM_INSTRUCTIONS = set([
        'aaa', 'aad', 'aam', 'aas', 'adc', 'add', 'and', 'arpl', 'bound',
        'bsf', 'bsr', 'bswap', 'bt', 'btc', 'btr', 'bts', 'call', 'cbw',
        'cdq', 'clc', 'cld', 'cli', 'clts', 'cmc', 'cmova', 'cmovae',
        'cmovb', 'cmovbe', 'cmovc', 'cmovcxz', 'cmove', 'cmovg',
        'cmovge', 'cmovl', 'cmovle', 'cmovna', 'cmovnae', 'cmovnb',
        'cmovnbe', 'cmovnc', 'cmovne', 'cmovng', 'cmovnge', 'cmovnl',
        'cmovnle', 'cmovno', 'cmovnp', 'cmovns', 'cmovnz', 'cmovo',
        'cmovp', 'cmovpe', 'cmovpo', 'cmovs', 'cmovz', 'cmp', 'cmpsb',
        'cmpsd', 'cmpsw', 'cmpxchg', 'cmpxchg486', 'cmpxchg8b', 'cpuid',
        'cwd', 'cwde', 'daa', 'das', 'dec', 'div', 'emms', 'enter', 'hlt',
        'ibts', 'icebp', 'idiv', 'imul', 'in', 'inc', 'insb', 'insd',
        'insw', 'int', 'int01', 'int03', 'int1', 'int3', 'into', 'invd',
        'invlpg', 'iret', 'iretd', 'iretw', 'ja', 'jae', 'jb', 'jbe',
        'jc', 'jcxz', 'jcxz', 'je', 'jecxz', 'jg', 'jge', 'jl', 'jle',
        'jmp', 'jna', 'jnae', 'jnb', 'jnbe', 'jnc', 'jne', 'jng', 'jnge',
        'jnl', 'jnle', 'jno', 'jnp', 'jns', 'jnz', 'jo', 'jp', 'jpe',
        'jpo', 'js', 'jz', 'lahf', 'lar', 'lcall', 'lds', 'lea', 'leave',
        'les', 'lfs', 'lgdt', 'lgs', 'lidt', 'ljmp', 'lldt', 'lmsw',
        'loadall', 'loadall286', 'lock', 'lodsb', 'lodsd', 'lodsw',
        'loop', 'loope', 'loopne', 'loopnz', 'loopz', 'lsl', 'lss', 'ltr',
        'mov', 'movd', 'movq', 'movsb', 'movsd', 'movsw', 'movsx',
        'movzx', 'mul', 'neg', 'nop', 'not', 'or', 'out', 'outsb', 'outsd',
        'outsw', 'pop', 'popa', 'popad', 'popaw', 'popf', 'popfd', 'popfw',
        'push', 'pusha', 'pushad', 'pushaw', 'pushf', 'pushfd', 'pushfw',
        'rcl', 'rcr', 'rdmsr', 'rdpmc', 'rdshr', 'rdtsc', 'rep', 'repe',
        'repne', 'repnz', 'repz', 'ret', 'retf', 'retn', 'rol', 'ror',
        'rsdc', 'rsldt', 'rsm', 'sahf', 'sal', 'salc', 'sar', 'sbb',
        'scasb', 'scasd', 'scasw', 'seta', 'setae', 'setb', 'setbe',
        'setc', 'setcxz', 'sete', 'setg', 'setge', 'setl', 'setle',
        'setna', 'setnae', 'setnb', 'setnbe', 'setnc', 'setne', 'setng',
        'setnge', 'setnl', 'setnle', 'setno', 'setnp', 'setns', 'setnz',
        'seto', 'setp', 'setpe', 'setpo', 'sets', 'setz', 'sgdt', 'shl',
        'shld', 'shr', 'shrd', 'sidt', 'sldt', 'smi', 'smint', 'smintold',
        'smsw', 'stc', 'std', 'sti', 'stosb', 'stosd', 'stosw', 'str',
        'sub', 'svdc', 'svldt', 'svts', 'syscall', 'sysenter', 'sysexit',
        'sysret', 'test', 'ud1', 'ud2', 'umov', 'verr', 'verw', 'wait',
        'wbinvd', 'wrmsr', 'wrshr', 'xadd', 'xbts', 'xchg', 'xlat',
        'xlatb', 'xor'
    ])

    def __init__(self, **options):
        Lexer.__init__(self, **options)
        self.keywords = set()
        if get_bool_opt(options, 'turbopascal', True):
            self.keywords.update(self.TURBO_PASCAL_KEYWORDS)
        if get_bool_opt(options, 'delphi', True):
            self.keywords.update(self.DELPHI_KEYWORDS)
        if get_bool_opt(options, 'freepascal', True):
            self.keywords.update(self.FREE_PASCAL_KEYWORDS)
        self.builtins = set()
        for unit in get_list_opt(options, 'units', self.BUILTIN_UNITS.keys()):
            self.builtins.update(self.BUILTIN_UNITS[unit])

    def get_tokens_unprocessed(self, text):
        scanner = Scanner(text, re.DOTALL | re.MULTILINE | re.IGNORECASE)
        stack = ['initial']
        in_function_block = False
        in_property_block = False
        was_dot = False
        next_token_is_function = False
        next_token_is_property = False
        collect_labels = False
        block_labels = set()
        brace_balance = [0, 0]

        while not scanner.eos:
            token = Error

            if stack[-1] == 'initial':
                if scanner.scan(r'\s+'):
                    token = Text
                elif scanner.scan(r'\{.*?\}|\(\*.*?\*\)'):
                    if scanner.match.startswith('$'):
                        token = Comment.Preproc
                    else:
                        token = Comment.Multiline
                elif scanner.scan(r'//.*?$'):
                    token = Comment.Single
                elif scanner.scan(r'[-+*\/=<>:;,.@\^]'):
                    token = Operator
                    # stop label highlighting on next ";"
                    if collect_labels and scanner.match == ';':
                        collect_labels = False
                elif scanner.scan(r'[\(\)\[\]]+'):
                    token = Punctuation
                    # abort function naming ``foo = Function(...)``
                    next_token_is_function = False
                    # if we are in a function block we count the open
                    # braces because ootherwise it's impossible to
                    # determine the end of the modifier context
                    if in_function_block or in_property_block:
                        if scanner.match == '(':
                            brace_balance[0] += 1
                        elif scanner.match == ')':
                            brace_balance[0] -= 1
                        elif scanner.match == '[':
                            brace_balance[1] += 1
                        elif scanner.match == ']':
                            brace_balance[1] -= 1
                elif scanner.scan(r'[A-Za-z_][A-Za-z_0-9]*'):
                    lowercase_name = scanner.match.lower()
                    if lowercase_name == 'result':
                        token = Name.Builtin.Pseudo
                    elif lowercase_name in self.keywords:
                        token = Keyword
                        # if we are in a special block and a
                        # block ending keyword occours (and the parenthesis
                        # is balanced) we end the current block context
                        if (in_function_block or in_property_block) and \
                           lowercase_name in self.BLOCK_KEYWORDS and \
                           brace_balance[0] <= 0 and \
                           brace_balance[1] <= 0:
                            in_function_block = False
                            in_property_block = False
                            brace_balance = [0, 0]
                            block_labels = set()
                        if lowercase_name in ('label', 'goto'):
                            collect_labels = True
                        elif lowercase_name == 'asm':
                            stack.append('asm')
                        elif lowercase_name == 'property':
                            in_property_block = True
                            next_token_is_property = True
                        elif lowercase_name in ('procedure', 'operator',
                                                'function', 'constructor',
                                                'destructor'):
                            in_function_block = True
                            next_token_is_function = True
                    # we are in a function block and the current name
                    # is in the set of registered modifiers. highlight
                    # it as pseudo keyword
                    elif in_function_block and \
                         lowercase_name in self.FUNCTION_MODIFIERS:
                        token = Keyword.Pseudo
                    # if we are in a property highlight some more
                    # modifiers
                    elif in_property_block and \
                         lowercase_name in ('read', 'write'):
                        token = Keyword.Pseudo
                        next_token_is_function = True
                    # if the last iteration set next_token_is_function
                    # to true we now want this name highlighted as
                    # function. so do that and reset the state
                    elif next_token_is_function:
                        # Look if the next token is a dot. If yes it's
                        # not a function, but a class name and the
                        # part after the dot a function name
                        if scanner.test(r'\s*\.\s*'):
                            token = Name.Class
                        # it's not a dot, our job is done
                        else:
                            token = Name.Function
                            next_token_is_function = False
                    # same for properties
                    elif next_token_is_property:
                        token = Name.Property
                        next_token_is_property = False
                    # Highlight this token as label and add it
                    # to the list of known labels
                    elif collect_labels:
                        token = Name.Label
                        block_labels.add(scanner.match.lower())
                    # name is in list of known labels
                    elif lowercase_name in block_labels:
                        token = Name.Label
                    elif lowercase_name in self.BUILTIN_TYPES:
                        token = Keyword.Type
                    elif lowercase_name in self.DIRECTIVES:
                        token = Keyword.Pseudo
                    # builtins are just builtins if the token
                    # before isn't a dot
                    elif not was_dot and lowercase_name in self.builtins:
                        token = Name.Builtin
                    else:
                        token = Name
                elif scanner.scan(r"'"):
                    token = String
                    stack.append('string')
                elif scanner.scan(r'\#(\d+|\$[0-9A-Fa-f]+)'):
                    token = String.Char
                elif scanner.scan(r'\$[0-9A-Fa-f]+'):
                    token = Number.Hex
                elif scanner.scan(r'\d+(?![eE]|\.[^.])'):
                    token = Number.Integer
                elif scanner.scan(r'\d+(\.\d+([eE][+-]?\d+)?|[eE][+-]?\d+)'):
                    token = Number.Float
                else:
                    # if the stack depth is deeper than once, pop
                    if len(stack) > 1:
                        stack.pop()
                    scanner.get_char()

            elif stack[-1] == 'string':
                if scanner.scan(r"''"):
                    token = String.Escape
                elif scanner.scan(r"'"):
                    token = String
                    stack.pop()
                elif scanner.scan(r"[^']*"):
                    token = String
                else:
                    scanner.get_char()
                    stack.pop()

            elif stack[-1] == 'asm':
                if scanner.scan(r'\s+'):
                    token = Text
                elif scanner.scan(r'end'):
                    token = Keyword
                    stack.pop()
                elif scanner.scan(r'\{.*?\}|\(\*.*?\*\)'):
                    if scanner.match.startswith('$'):
                        token = Comment.Preproc
                    else:
                        token = Comment.Multiline
                elif scanner.scan(r'//.*?$'):
                    token = Comment.Single
                elif scanner.scan(r"'"):
                    token = String
                    stack.append('string')
                elif scanner.scan(r'@@[A-Za-z_][A-Za-z_0-9]*'):
                    token = Name.Label
                elif scanner.scan(r'[A-Za-z_][A-Za-z_0-9]*'):
                    lowercase_name = scanner.match.lower()
                    if lowercase_name in self.ASM_INSTRUCTIONS:
                        token = Keyword
                    elif lowercase_name in self.ASM_REGISTERS:
                        token = Name.Builtin
                    else:
                        token = Name
                elif scanner.scan(r'[-+*\/=<>:;,.@\^]+'):
                    token = Operator
                elif scanner.scan(r'[\(\)\[\]]+'):
                    token = Punctuation
                elif scanner.scan(r'\$[0-9A-Fa-f]+'):
                    token = Number.Hex
                elif scanner.scan(r'\d+(?![eE]|\.[^.])'):
                    token = Number.Integer
                elif scanner.scan(r'\d+(\.\d+([eE][+-]?\d+)?|[eE][+-]?\d+)'):
                    token = Number.Float
                else:
                    scanner.get_char()
                    stack.pop()

            # save the dot!!!11
            if scanner.match.strip():
                was_dot = scanner.match == '.'
            yield scanner.start_pos, token, scanner.match or ''


class JavaLexer(RegexLexer):
    """
    For `Java <http://www.sun.com/java/>`_ source code.
    """

    name = 'Java'
    aliases = ['java']
    filenames = ['*.java']
    mimetypes = ['text/x-java']

    flags = re.MULTILINE | re.DOTALL

    #: optional Comment or Whitespace
    _ws = r'(?:\s|//.*?\n|/[*].*?[*]/)+'

    tokens = {
        'root': [
            # method names
            (r'^(\s*(?:[a-zA-Z_][a-zA-Z0-9_\.\[\]]*\s+)+?)' # return arguments
             r'([a-zA-Z_][a-zA-Z0-9_]*)'                    # method name
             r'(\s*)(\()',                                  # signature start
             bygroups(using(this), Name.Function, Text, Operator)),
            (r'[^\S\n]+', Text),
            (r'//.*?\n', Comment),
            (r'/\*.*?\*/', Comment),
            (r'@[a-zA-Z_][a-zA-Z0-9_\.]*', Name.Decorator),
            (r'(assert|break|case|catch|continue|default|do|else|finally|for|'
             r'if|goto|instanceof|new|return|switch|this|throw|try|while)\b',
             Keyword),
            (r'(abstract|const|enum|extends|final|implements|native|private|'
             r'protected|public|static|strictfp|super|synchronized|throws|'
             r'transient|volatile)\b', Keyword.Declaration),
            (r'(boolean|byte|char|double|float|int|long|short|void)\b',
             Keyword.Type),
            (r'(package)(\s+)', bygroups(Keyword.Namespace, Text)),
            (r'(true|false|null)\b', Keyword.Constant),
            (r'(class|interface)(\s+)', bygroups(Keyword.Declaration, Text), 'class'),
            (r'(import)(\s+)', bygroups(Keyword.Namespace, Text), 'import'),
            (r'"(\\\\|\\"|[^"])*"', String),
            (r"'\\.'|'[^\\]'|'\\u[0-9a-f]{4}'", String.Char),
            (r'(\.)([a-zA-Z_][a-zA-Z0-9_]*)', bygroups(Operator, Name.Attribute)),
            (r'[a-zA-Z_][a-zA-Z0-9_]*:', Name.Label),
            (r'[a-zA-Z_\$][a-zA-Z0-9_]*', Name),
            (r'[~\^\*!%&\[\]\(\)\{\}<>\|+=:;,./?-]', Operator),
            (r'[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?', Number.Float),
            (r'0x[0-9a-f]+', Number.Hex),
            (r'[0-9]+L?', Number.Integer),
            (r'\n', Text)
        ],
        'class': [
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name.Class, '#pop')
        ],
        'import': [
            (r'[a-zA-Z0-9_.]+\*?', Name.Namespace, '#pop')
        ],
    }

class ScalaLexer(RegexLexer):
    """
    For `Scala <http://www.scala-lang.org>`_ source code.
    """

    name = 'Scala'
    aliases = ['scala']
    filenames = ['*.scala']
    mimetypes = ['text/x-scala']

    flags = re.MULTILINE | re.DOTALL

    #: optional Comment or Whitespace
    _ws = r'(?:\s|//.*?\n|/[*].*?[*]/)+'

    # don't use raw unicode strings!
    op = u'[-~\\^\\*!%&\\\\<>\\|+=:/?@\u00a6-\u00a7\u00a9\u00ac\u00ae\u00b0-\u00b1\u00b6\u00d7\u00f7\u03f6\u0482\u0606-\u0608\u060e-\u060f\u06e9\u06fd-\u06fe\u07f6\u09fa\u0b70\u0bf3-\u0bf8\u0bfa\u0c7f\u0cf1-\u0cf2\u0d79\u0f01-\u0f03\u0f13-\u0f17\u0f1a-\u0f1f\u0f34\u0f36\u0f38\u0fbe-\u0fc5\u0fc7-\u0fcf\u109e-\u109f\u1360\u1390-\u1399\u1940\u19e0-\u19ff\u1b61-\u1b6a\u1b74-\u1b7c\u2044\u2052\u207a-\u207c\u208a-\u208c\u2100-\u2101\u2103-\u2106\u2108-\u2109\u2114\u2116-\u2118\u211e-\u2123\u2125\u2127\u2129\u212e\u213a-\u213b\u2140-\u2144\u214a-\u214d\u214f\u2190-\u2328\u232b-\u244a\u249c-\u24e9\u2500-\u2767\u2794-\u27c4\u27c7-\u27e5\u27f0-\u2982\u2999-\u29d7\u29dc-\u29fb\u29fe-\u2b54\u2ce5-\u2cea\u2e80-\u2ffb\u3004\u3012-\u3013\u3020\u3036-\u3037\u303e-\u303f\u3190-\u3191\u3196-\u319f\u31c0-\u31e3\u3200-\u321e\u322a-\u3250\u3260-\u327f\u328a-\u32b0\u32c0-\u33ff\u4dc0-\u4dff\ua490-\ua4c6\ua828-\ua82b\ufb29\ufdfd\ufe62\ufe64-\ufe66\uff0b\uff1c-\uff1e\uff5c\uff5e\uffe2\uffe4\uffe8-\uffee\ufffc-\ufffd]+'

    letter = u'[a-zA-Z\\$_\u00aa\u00b5\u00ba\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02af\u0370-\u0373\u0376-\u0377\u037b-\u037d\u0386\u0388-\u03f5\u03f7-\u0481\u048a-\u0556\u0561-\u0587\u05d0-\u05f2\u0621-\u063f\u0641-\u064a\u066e-\u066f\u0671-\u06d3\u06d5\u06ee-\u06ef\u06fa-\u06fc\u06ff\u0710\u0712-\u072f\u074d-\u07a5\u07b1\u07ca-\u07ea\u0904-\u0939\u093d\u0950\u0958-\u0961\u0972-\u097f\u0985-\u09b9\u09bd\u09ce\u09dc-\u09e1\u09f0-\u09f1\u0a05-\u0a39\u0a59-\u0a5e\u0a72-\u0a74\u0a85-\u0ab9\u0abd\u0ad0-\u0ae1\u0b05-\u0b39\u0b3d\u0b5c-\u0b61\u0b71\u0b83-\u0bb9\u0bd0\u0c05-\u0c3d\u0c58-\u0c61\u0c85-\u0cb9\u0cbd\u0cde-\u0ce1\u0d05-\u0d3d\u0d60-\u0d61\u0d7a-\u0d7f\u0d85-\u0dc6\u0e01-\u0e30\u0e32-\u0e33\u0e40-\u0e45\u0e81-\u0eb0\u0eb2-\u0eb3\u0ebd-\u0ec4\u0edc-\u0f00\u0f40-\u0f6c\u0f88-\u0f8b\u1000-\u102a\u103f\u1050-\u1055\u105a-\u105d\u1061\u1065-\u1066\u106e-\u1070\u1075-\u1081\u108e\u10a0-\u10fa\u1100-\u135a\u1380-\u138f\u13a0-\u166c\u166f-\u1676\u1681-\u169a\u16a0-\u16ea\u16ee-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u1770\u1780-\u17b3\u17dc\u1820-\u1842\u1844-\u18a8\u18aa-\u191c\u1950-\u19a9\u19c1-\u19c7\u1a00-\u1a16\u1b05-\u1b33\u1b45-\u1b4b\u1b83-\u1ba0\u1bae-\u1baf\u1c00-\u1c23\u1c4d-\u1c4f\u1c5a-\u1c77\u1d00-\u1d2b\u1d62-\u1d77\u1d79-\u1d9a\u1e00-\u1fbc\u1fbe\u1fc2-\u1fcc\u1fd0-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ffc\u2071\u207f\u2102\u2107\u210a-\u2113\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e\u2160-\u2188\u2c00-\u2c7c\u2c80-\u2ce4\u2d00-\u2d65\u2d80-\u2dde\u3006-\u3007\u3021-\u3029\u3038-\u303a\u303c\u3041-\u3096\u309f\u30a1-\u30fa\u30ff-\u318e\u31a0-\u31b7\u31f0-\u31ff\u3400-\u4db5\u4e00-\ua014\ua016-\ua48c\ua500-\ua60b\ua610-\ua61f\ua62a-\ua66e\ua680-\ua697\ua722-\ua76f\ua771-\ua787\ua78b-\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua822\ua840-\ua873\ua882-\ua8b3\ua90a-\ua925\ua930-\ua946\uaa00-\uaa28\uaa40-\uaa42\uaa44-\uaa4b\uac00-\ud7a3\uf900-\ufb1d\ufb1f-\ufb28\ufb2a-\ufd3d\ufd50-\ufdfb\ufe70-\ufefc\uff21-\uff3a\uff41-\uff5a\uff66-\uff6f\uff71-\uff9d\uffa0-\uffdc]'

    upper = u'[A-Z\\$_\u00c0-\u00d6\u00d8-\u00de\u0100\u0102\u0104\u0106\u0108\u010a\u010c\u010e\u0110\u0112\u0114\u0116\u0118\u011a\u011c\u011e\u0120\u0122\u0124\u0126\u0128\u012a\u012c\u012e\u0130\u0132\u0134\u0136\u0139\u013b\u013d\u013f\u0141\u0143\u0145\u0147\u014a\u014c\u014e\u0150\u0152\u0154\u0156\u0158\u015a\u015c\u015e\u0160\u0162\u0164\u0166\u0168\u016a\u016c\u016e\u0170\u0172\u0174\u0176\u0178-\u0179\u017b\u017d\u0181-\u0182\u0184\u0186-\u0187\u0189-\u018b\u018e-\u0191\u0193-\u0194\u0196-\u0198\u019c-\u019d\u019f-\u01a0\u01a2\u01a4\u01a6-\u01a7\u01a9\u01ac\u01ae-\u01af\u01b1-\u01b3\u01b5\u01b7-\u01b8\u01bc\u01c4\u01c7\u01ca\u01cd\u01cf\u01d1\u01d3\u01d5\u01d7\u01d9\u01db\u01de\u01e0\u01e2\u01e4\u01e6\u01e8\u01ea\u01ec\u01ee\u01f1\u01f4\u01f6-\u01f8\u01fa\u01fc\u01fe\u0200\u0202\u0204\u0206\u0208\u020a\u020c\u020e\u0210\u0212\u0214\u0216\u0218\u021a\u021c\u021e\u0220\u0222\u0224\u0226\u0228\u022a\u022c\u022e\u0230\u0232\u023a-\u023b\u023d-\u023e\u0241\u0243-\u0246\u0248\u024a\u024c\u024e\u0370\u0372\u0376\u0386\u0388-\u038f\u0391-\u03ab\u03cf\u03d2-\u03d4\u03d8\u03da\u03dc\u03de\u03e0\u03e2\u03e4\u03e6\u03e8\u03ea\u03ec\u03ee\u03f4\u03f7\u03f9-\u03fa\u03fd-\u042f\u0460\u0462\u0464\u0466\u0468\u046a\u046c\u046e\u0470\u0472\u0474\u0476\u0478\u047a\u047c\u047e\u0480\u048a\u048c\u048e\u0490\u0492\u0494\u0496\u0498\u049a\u049c\u049e\u04a0\u04a2\u04a4\u04a6\u04a8\u04aa\u04ac\u04ae\u04b0\u04b2\u04b4\u04b6\u04b8\u04ba\u04bc\u04be\u04c0-\u04c1\u04c3\u04c5\u04c7\u04c9\u04cb\u04cd\u04d0\u04d2\u04d4\u04d6\u04d8\u04da\u04dc\u04de\u04e0\u04e2\u04e4\u04e6\u04e8\u04ea\u04ec\u04ee\u04f0\u04f2\u04f4\u04f6\u04f8\u04fa\u04fc\u04fe\u0500\u0502\u0504\u0506\u0508\u050a\u050c\u050e\u0510\u0512\u0514\u0516\u0518\u051a\u051c\u051e\u0520\u0522\u0531-\u0556\u10a0-\u10c5\u1e00\u1e02\u1e04\u1e06\u1e08\u1e0a\u1e0c\u1e0e\u1e10\u1e12\u1e14\u1e16\u1e18\u1e1a\u1e1c\u1e1e\u1e20\u1e22\u1e24\u1e26\u1e28\u1e2a\u1e2c\u1e2e\u1e30\u1e32\u1e34\u1e36\u1e38\u1e3a\u1e3c\u1e3e\u1e40\u1e42\u1e44\u1e46\u1e48\u1e4a\u1e4c\u1e4e\u1e50\u1e52\u1e54\u1e56\u1e58\u1e5a\u1e5c\u1e5e\u1e60\u1e62\u1e64\u1e66\u1e68\u1e6a\u1e6c\u1e6e\u1e70\u1e72\u1e74\u1e76\u1e78\u1e7a\u1e7c\u1e7e\u1e80\u1e82\u1e84\u1e86\u1e88\u1e8a\u1e8c\u1e8e\u1e90\u1e92\u1e94\u1e9e\u1ea0\u1ea2\u1ea4\u1ea6\u1ea8\u1eaa\u1eac\u1eae\u1eb0\u1eb2\u1eb4\u1eb6\u1eb8\u1eba\u1ebc\u1ebe\u1ec0\u1ec2\u1ec4\u1ec6\u1ec8\u1eca\u1ecc\u1ece\u1ed0\u1ed2\u1ed4\u1ed6\u1ed8\u1eda\u1edc\u1ede\u1ee0\u1ee2\u1ee4\u1ee6\u1ee8\u1eea\u1eec\u1eee\u1ef0\u1ef2\u1ef4\u1ef6\u1ef8\u1efa\u1efc\u1efe\u1f08-\u1f0f\u1f18-\u1f1d\u1f28-\u1f2f\u1f38-\u1f3f\u1f48-\u1f4d\u1f59-\u1f5f\u1f68-\u1f6f\u1fb8-\u1fbb\u1fc8-\u1fcb\u1fd8-\u1fdb\u1fe8-\u1fec\u1ff8-\u1ffb\u2102\u2107\u210b-\u210d\u2110-\u2112\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u2130-\u2133\u213e-\u213f\u2145\u2183\u2c00-\u2c2e\u2c60\u2c62-\u2c64\u2c67\u2c69\u2c6b\u2c6d-\u2c6f\u2c72\u2c75\u2c80\u2c82\u2c84\u2c86\u2c88\u2c8a\u2c8c\u2c8e\u2c90\u2c92\u2c94\u2c96\u2c98\u2c9a\u2c9c\u2c9e\u2ca0\u2ca2\u2ca4\u2ca6\u2ca8\u2caa\u2cac\u2cae\u2cb0\u2cb2\u2cb4\u2cb6\u2cb8\u2cba\u2cbc\u2cbe\u2cc0\u2cc2\u2cc4\u2cc6\u2cc8\u2cca\u2ccc\u2cce\u2cd0\u2cd2\u2cd4\u2cd6\u2cd8\u2cda\u2cdc\u2cde\u2ce0\u2ce2\ua640\ua642\ua644\ua646\ua648\ua64a\ua64c\ua64e\ua650\ua652\ua654\ua656\ua658\ua65a\ua65c\ua65e\ua662\ua664\ua666\ua668\ua66a\ua66c\ua680\ua682\ua684\ua686\ua688\ua68a\ua68c\ua68e\ua690\ua692\ua694\ua696\ua722\ua724\ua726\ua728\ua72a\ua72c\ua72e\ua732\ua734\ua736\ua738\ua73a\ua73c\ua73e\ua740\ua742\ua744\ua746\ua748\ua74a\ua74c\ua74e\ua750\ua752\ua754\ua756\ua758\ua75a\ua75c\ua75e\ua760\ua762\ua764\ua766\ua768\ua76a\ua76c\ua76e\ua779\ua77b\ua77d-\ua77e\ua780\ua782\ua784\ua786\ua78b\uff21-\uff3a]'

    idrest = ur'%s(?:%s|[0-9])*(?:(?<=_)%s)?' % (letter, letter, op)

    tokens = {
        'root': [
            # method names
            (r'(class|trait|object)(\s+)', bygroups(Keyword, Text), 'class'),
            (ur"'%s" % idrest, Text.Symbol),
            (r'[^\S\n]+', Text),
            (r'//.*?\n', Comment),
            (r'/\*', Comment.Multiline, 'comment'),
            (ur'@%s' % idrest, Name.Decorator),
            (ur'(abstract|ca(?:se|tch)|d(?:ef|o)|e(?:lse|xtends)|'
             ur'f(?:inal(?:ly)?|or(?:Some)?)|i(?:f|mplicit)|'
             ur'lazy|match|new|override|pr(?:ivate|otected)'
             ur'|re(?:quires|turn)|s(?:ealed|uper)|'
             ur't(?:h(?:is|row)|ry)|va[lr]|w(?:hile|ith)|yield)\b|'
             u'(<[%:-]|=>|>:|[#=@_\u21D2\u2190])(\b|(?=\\s)|$)', Keyword),
            (ur':(?!%s)' % op, Keyword, 'type'),
            (ur'%s%s\b' % (upper, idrest), Name.Class),
            (r'(true|false|null)\b', Keyword.Constant),
            (r'(import|package)(\s+)', bygroups(Keyword, Text), 'import'),
            (r'(type)(\s+)', bygroups(Keyword, Text), 'type'),
            (r'"""(?:.|\n)*?"""', String),
            (r'"(\\\\|\\"|[^"])*"', String),
            (ur"'\\.'|'[^\\]'|'\\u[0-9a-f]{4}'", String.Char),
#            (ur'(\.)(%s|%s|`[^`]+`)' % (idrest, op), bygroups(Operator,
#             Name.Attribute)),
            (idrest, Name),
            (r'`[^`]+`', Name),
            (r'\[', Operator, 'typeparam'),
            (r'[\(\)\{\};,.]', Operator),
            (op, Operator),
            (ur'([0-9][0-9]*\.[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?[fFdD]?',
             Number.Float),
            (r'0x[0-9a-f]+', Number.Hex),
            (r'[0-9]+L?', Number.Integer),
            (r'\n', Text)
        ],
        'class': [
            (ur'(%s|%s|`[^`]+`)(\s*)(\[)' % (idrest, op),
             bygroups(Name.Class, Text, Operator), 'typeparam'),
            (r'[\s\n]+', Text),
            (r'{', Operator, '#pop'),
            (r'\(', Operator, '#pop'),
            (ur'%s|%s|`[^`]+`' % (idrest, op), Name.Class, '#pop'),
        ],
        'type': [
            (r'\s+', Text),
            (u'<[%:]|>:|[#_\u21D2]|forSome|type', Keyword),
            (r'([,\);}]|=>|=)([\s\n]*)', bygroups(Operator, Text), '#pop'),
            (r'[\(\{]', Operator, '#push'),
            (ur'((?:%s|%s|`[^`]+`)(?:\.(?:%s|%s|`[^`]+`))*)(\s*)(\[)' %
             (idrest, op, idrest, op),
             bygroups(Keyword.Type, Text, Operator), ('#pop', 'typeparam')),
            (ur'((?:%s|%s|`[^`]+`)(?:\.(?:%s|%s|`[^`]+`))*)(\s*)$' %
             (idrest, op, idrest, op),
             bygroups(Keyword.Type, Text), '#pop'),
            (ur'\.|%s|%s|`[^`]+`' % (idrest, op), Keyword.Type)
        ],
        'typeparam': [
            (r'[\s\n,]+', Text),
            (u'<[%:]|=>|>:|[#_\u21D2]|forSome|type', Keyword),
            (r'([\]\)\}])', Operator, '#pop'),
            (r'[\(\[\{]', Operator, '#push'),
            (ur'\.|%s|%s|`[^`]+`' % (idrest, op), Keyword.Type)
        ],
        'comment': [
            (r'[^/\*]+', Comment.Multiline),
            (r'/\*', Comment.Multiline, '#push'),
            (r'\*/', Comment.Multiline, '#pop'),
            (r'[*/]', Comment.Multiline)
        ],
        'import': [
            (ur'(%s|\.)+' % idrest, Name.Namespace, '#pop')
        ],
    }


class DylanLexer(RegexLexer):
    """
    For the `Dylan <http://www.opendylan.org/>`_ language.

    *New in Pygments 0.7.*
    """

    name = 'Dylan'
    aliases = ['dylan']
    filenames = ['*.dylan']
    mimetypes = ['text/x-dylan']

    flags = re.DOTALL

    tokens = {
        'root': [
            (r'\b(subclass|abstract|block|c(on(crete|stant)|lass)|domain'
             r'|ex(c(eption|lude)|port)|f(unction(|al))|generic|handler'
             r'|i(n(herited|line|stance|terface)|mport)|library|m(acro|ethod)'
             r'|open|primary|sealed|si(deways|ngleton)|slot'
             r'|v(ariable|irtual))\b', Name.Builtin),
            (r'<\w+>', Keyword.Type),
            (r'#?"(?:\\.|[^"])+?"', String.Double),
            (r'//.*?\n', Comment),
            (r'/\*[\w\W]*?\*/', Comment.Multiline),
            (r'\'.*?\'', String.Single),
            (r'=>|\b(a(bove|fterwards)|b(e(gin|low)|y)|c(ase|leanup|reate)'
             r'|define|else(|if)|end|f(inally|or|rom)|i[fn]|l(et|ocal)|otherwise'
             r'|rename|s(elect|ignal)|t(hen|o)|u(n(less|til)|se)|wh(en|ile))\b',
             Keyword),
            (r'([ \t])([!\$%&\*\/:<=>\?~_^a-zA-Z0-9.+\-]*:)',
             bygroups(Text, Name.Variable)),
            (r'([ \t]*)(\S+[^:])([ \t]*)(\()([ \t]*)',
             bygroups(Text, Name.Function, Text, Punctuation, Text)),
            (r'-?[0-9.]+', Number),
            (r'[(),;]', Punctuation),
            (r'\$[a-zA-Z0-9-]+', Name.Constant),
            (r'[!$%&*/:<>=?~^.+\[\]{}-]+', Operator),
            (r'\s+', Text),
            (r'#[a-zA-Z0-9-]+', Keyword),
            (r'[a-zA-Z0-9-]+', Name.Variable),
        ],
    }


class ObjectiveCLexer(RegexLexer):
    """
    For Objective-C source code with preprocessor directives.
    """

    name = 'Objective-C'
    aliases = ['objective-c', 'objectivec', 'obj-c', 'objc']
    #XXX: objc has .h files too :-/
    filenames = ['*.m']
    mimetypes = ['text/x-objective-c']

    #: optional Comment or Whitespace
    _ws = r'(?:\s|//.*?\n|/[*].*?[*]/)+'

    tokens = {
        'whitespace': [
            (r'^(\s*)(#if\s+0)', bygroups(Text, Comment.Preproc), 'if0'),
            (r'^(\s*)(#)', bygroups(Text, Comment.Preproc), 'macro'),
            (r'\n', Text),
            (r'\s+', Text),
            (r'\\\n', Text), # line continuation
            (r'//(\n|(.|\n)*?[^\\]\n)', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
        ],
        'statements': [
            (r'(L|@)?"', String, 'string'),
            (r"(L|@)?'(\\.|\\[0-7]{1,3}|\\x[a-fA-F0-9]{1,2}|[^\\\'\n])'",
             String.Char),
            (r'(\d+\.\d*|\.\d+|\d+)[eE][+-]?\d+[lL]?', Number.Float),
            (r'(\d+\.\d*|\.\d+|\d+[fF])[fF]?', Number.Float),
            (r'0x[0-9a-fA-F]+[Ll]?', Number.Hex),
            (r'0[0-7]+[Ll]?', Number.Oct),
            (r'\d+[Ll]?', Number.Integer),
            (r'[~!%^&*+=|?:<>/-]', Operator),
            (r'[()\[\],.]', Punctuation),
            (r'(auto|break|case|const|continue|default|do|else|enum|extern|'
             r'for|goto|if|register|restricted|return|sizeof|static|struct|'
             r'switch|typedef|union|volatile|virtual|while|in|@selector|'
             r'@private|@protected|@public|@encode|'
             r'@synchronized|@try|@throw|@catch|@finally|@end|@property|'
             r'@synthesize|@dynamic)\b', Keyword),
            (r'(int|long|float|short|double|char|unsigned|signed|void|'
             r'id|BOOL|IBOutlet|IBAction|SEL)\b', Keyword.Type),
            (r'(_{0,2}inline|naked|restrict|thread|typename)\b',
             Keyword.Reserved),
            (r'__(asm|int8|based|except|int16|stdcall|cdecl|fastcall|int32|'
             r'declspec|finally|int64|try|leave)\b', Keyword.Reserved),
            (r'(TRUE|FALSE|nil|NULL)\b', Name.Builtin),
            ('[a-zA-Z_][a-zA-Z0-9_]*:(?!:)', Name.Label),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
        ],
        'root': [
            include('whitespace'),
            # functions
            (r'((?:[a-zA-Z0-9_*\s])+?(?:\s|[*]))'    # return arguments
             r'([a-zA-Z_][a-zA-Z0-9_]*)'             # method name
             r'(\s*\([^;]*?\))'                      # signature
             r'(' + _ws + r')({)',
             bygroups(using(this), Name.Function,
                      using(this), Text, Punctuation),
             'function'),
            # function declarations
            (r'((?:[a-zA-Z0-9_*\s])+?(?:\s|[*]))'    # return arguments
             r'([a-zA-Z_][a-zA-Z0-9_]*)'             # method name
             r'(\s*\([^;]*?\))'                      # signature
             r'(' + _ws + r')(;)',
             bygroups(using(this), Name.Function,
                      using(this), Text, Punctuation)),
            (r'(@interface|@implementation)(\s+)', bygroups(Keyword, Text),
             'classname'),
            (r'(@class|@protocol)(\s+)', bygroups(Keyword, Text),
             'forward_classname'),
            (r'(\s*)(@end)(\s*)', bygroups(Text, Keyword, Text)),
            ('', Text, 'statement'),
        ],
        'classname' : [
            # interface definition that inherits
            ('([a-zA-Z_][a-zA-Z0-9_]*)(\s*:\s*)([a-zA-Z_][a-zA-Z0-9_]*)?',
             bygroups(Name.Class, Text, Name.Class), '#pop'),
            # interface definition for a category
            ('([a-zA-Z_][a-zA-Z0-9_]*)(\s*)(\([a-zA-Z_][a-zA-Z0-9_]*\))',
             bygroups(Name.Class, Text, Name.Label), '#pop'),
            # simple interface / implementation
            ('([a-zA-Z_][a-zA-Z0-9_]*)', Name.Class, '#pop')
        ],
        'forward_classname' : [
          ('([a-zA-Z_][a-zA-Z0-9_]*)(\s*,\s*)',
           bygroups(Name.Class, Text), 'forward_classname'),
          ('([a-zA-Z_][a-zA-Z0-9_]*)(\s*;?)',
           bygroups(Name.Class, Text), '#pop')
        ],
        'statement' : [
            include('whitespace'),
            include('statements'),
            ('[{}]', Punctuation),
            (';', Punctuation, '#pop'),
        ],
        'function': [
            include('whitespace'),
            include('statements'),
            (';', Punctuation),
            ('{', Punctuation, '#push'),
            ('}', Punctuation, '#pop'),
        ],
        'string': [
            (r'"', String, '#pop'),
            (r'\\([\\abfnrtv"\']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})', String.Escape),
            (r'[^\\"\n]+', String), # all other characters
            (r'\\\n', String), # line continuation
            (r'\\', String), # stray backslash
        ],
        'macro': [
            (r'[^/\n]+', Comment.Preproc),
            (r'/[*](.|\n)*?[*]/', Comment),
            (r'//.*?\n', Comment, '#pop'),
            (r'/', Comment.Preproc),
            (r'(?<=\\)\n', Comment.Preproc),
            (r'\n', Comment.Preproc, '#pop'),
        ],
        'if0': [
            (r'^\s*#if.*?(?<!\\)\n', Comment, '#push'),
            (r'^\s*#endif.*?(?<!\\)\n', Comment, '#pop'),
            (r'.*?\n', Comment),
        ]
    }

    def analyse_text(text):
        if '@"' in text: # strings
            return True
        if re.match(r'\[[a-zA-Z0-9.]:', text): # message
            return True
        return False

class FortranLexer(RegexLexer):
    '''
    Lexer for FORTRAN 90 code.

    *New in Pygments 0.10.*
    '''
    name = 'Fortran'
    aliases = ['fortran']
    filenames = ['*.f', '*.f90']
    mimetypes = ['text/x-fortran']
    flags = re.IGNORECASE

    # Data Types: INTEGER, REAL, COMPLEX, LOGICAL, CHARACTER and DOUBLE PRECISION
    # Operators: **, *, +, -, /, <, >, <=, >=, ==, /=
    # Logical (?): NOT, AND, OR, EQV, NEQV

    # Builtins:
    # http://gcc.gnu.org/onlinedocs/gcc-3.4.6/g77/Table-of-Intrinsic-Functions.html

    tokens = {
        'root': [
            (r'!.*\n', Comment),
            include('strings'),
            include('core'),
            (r'[a-z][a-z0-9_]*', Name.Variable),
            include('nums'),
            (r'[\s]+', Text),
        ],
        'core': [
            # Statements
            (r'\b(ACCEPT|ALLOCATABLE|ALLOCATE|ARRAY|ASSIGN|BACKSPACE|BLOCK DATA|'
             r'BYTE|CALL|CASE|CLOSE|COMMON|CONTAINS|CONTINUE|CYCLE|DATA|'
             r'DEALLOCATE|DECODE|DIMENSION|DO|ENCODE|END FILE|ENDIF|END|ENTRY|'
             r'EQUIVALENCE|EXIT|EXTERNAL|EXTRINSIC|FORALL|FORMAT|FUNCTION|GOTO|'
             r'IF|IMPLICIT|INCLUDE|INQUIRE|INTENT|INTERFACE|INTRINSIC|MODULE|'
             r'NAMELIST|NULLIFY|NONE|OPEN|OPTIONAL|OPTIONS|PARAMETER|PAUSE|'
             r'POINTER|PRINT|PRIVATE|PROGRAM|PUBLIC|PURE|READ|RECURSIVE|RETURN|'
             r'REWIND|SAVE|SELECT|SEQUENCE|STOP|SUBROUTINE|TARGET|TYPE|USE|'
             r'VOLATILE|WHERE|WRITE|WHILE|THEN|ELSE|ENDIF)\s*\b',
             Keyword),

            # Data Types
            (r'\b(CHARACTER|COMPLEX|DOUBLE PRECISION|DOUBLE COMPLEX|INTEGER|'
             r'LOGICAL|REAL)\s*\b',
             Keyword.Type),

            # Operators
            (r'(\*\*|\*|\+|-|\/|<|>|<=|>=|==|\/=|=)', Operator),

            (r'(::)', Keyword.Declaration),

            (r'[(),:&%]', Punctuation),

            # Intrinsics
            (r'\b(Abort|Abs|Access|AChar|ACos|AdjustL|AdjustR|AImag|AInt|Alarm|'
             r'All|Allocated|ALog|AMax|AMin|AMod|And|ANInt|Any|'
             r'ASin|Associated|ATan|BesJ|BesJN|BesY|BesYN|'
             r'Bit_Size|BTest|CAbs|CCos|Ceiling|CExp|Char|ChDir|ChMod|CLog|'
             r'Cmplx|Complex|Conjg|Cos|CosH|Count|CPU_Time|CShift|CSin|CSqRt|'
             r'CTime|DAbs|DACos|DASin|DATan|Date_and_Time|DbesJ|'
             r'DbesJ|DbesJN|DbesY|DbesY|DbesYN|Dble|DCos|DCosH|DDiM|DErF|DErFC|'
             r'DExp|Digits|DiM|DInt|DLog|DLog|DMax|DMin|DMod|DNInt|Dot_Product|'
             r'DProd|DSign|DSinH|DSin|DSqRt|DTanH|DTan|DTime|EOShift|Epsilon|'
             r'ErF|ErFC|ETime|Exit|Exp|Exponent|FDate|FGet|FGetC|Float|'
             r'Floor|Flush|FNum|FPutC|FPut|Fraction|FSeek|FStat|FTell|'
             r'GError|GetArg|GetCWD|GetEnv|GetGId|GetLog|GetPId|GetUId|'
             r'GMTime|HostNm|Huge|IAbs|IAChar|IAnd|IArgC|IBClr|IBits|'
             r'IBSet|IChar|IDate|IDiM|IDInt|IDNInt|IEOr|IErrNo|IFix|Imag|'
             r'ImagPart|Index|Int|IOr|IRand|IsaTty|IShft|IShftC|ISign|'
             r'ITime|Kill|Kind|LBound|Len|Len_Trim|LGe|LGt|Link|LLe|LLt|LnBlnk|'
             r'Loc|Log|Log|Logical|Long|LShift|LStat|LTime|MatMul|Max|'
             r'MaxExponent|MaxLoc|MaxVal|MClock|Merge|Min|MinExponent|MinLoc|'
             r'MinVal|Mod|Modulo|MvBits|Nearest|NInt|Not|Or|Pack|PError|'
             r'Precision|Present|Product|Radix|Rand|Random_Number|Random_Seed|'
             r'Range|Real|RealPart|Rename|Repeat|Reshape|RRSpacing|RShift|Scale|'
             r'Scan|Second|Selected_Int_Kind|Selected_Real_Kind|Set_Exponent|'
             r'Shape|Short|Sign|Signal|SinH|Sin|Sleep|Sngl|Spacing|Spread|SqRt|'
             r'SRand|Stat|Sum|SymLnk|System|System_Clock|Tan|TanH|Time|'
             r'Tiny|Transfer|Transpose|Trim|TtyNam|UBound|UMask|Unlink|Unpack|'
             r'Verify|XOr|ZAbs|ZCos|ZExp|ZLog|ZSin|ZSqRt)\s*\b',
             Name.Builtin),

            # Booleans
            (r'\.(true|false)\.', Name.Builtin),
            # Comparing Operators
            (r'\.(eq|ne|lt|le|gt|ge|not|and|or|eqv|neqv)\.', Operator.Word),
        ],

        'strings': [
            (r'"(\\\\|\\[0-7]+|\\.|[^"])*"', String.Double),
            (r"'(\\\\|\\[0-7]+|\\.|[^'])*'", String.Single),
        ],

        'nums': [
            (r'\d+(?![.Ee])', Number.Integer),
            (r'[+-]?\d*\.\d+([eE][-+]?\d+)?', Number.Float),
            (r'[+-]?\d+\.\d*([eE][-+]?\d+)?', Number.Float),
        ],
    }


class GLShaderLexer(RegexLexer):
    """
    GLSL (OpenGL Shader) lexer.

    *New in Pygments 1.1.*
    """
    name = 'GLSL'
    aliases = ['glsl']
    filenames = ['*.vert', '*.frag', '*.geo']
    mimetypes = ['text/x-glslsrc']

    tokens = {
        'root': [
            (r'^#.*', Comment.Preproc),
            (r'//.*', Comment.Single),
            (r'/\*[\w\W]*\*/', Comment.Multiline),
            (r'\+|-|~|!=?|\*|/|%|<<|>>|<=?|>=?|==?|&&?|\^|\|\|?',
             Operator),
            (r'[?:]', Operator), # quick hack for ternary
            (r'\bdefined\b', Operator),
            (r'[;{}(),\[\]]', Punctuation),
            #FIXME when e is present, no decimal point needed
            (r'[+-]?\d*\.\d+([eE][-+]?\d+)?', Number.Float),
            (r'[+-]?\d+\.\d*([eE][-+]?\d+)?', Number.Float),
            (r'0[xX][0-9a-fA-F]*', Number.Hex),
            (r'0[0-7]*', Number.Octal),
            (r'[1-9][0-9]*', Number.Integer),
            (r'\b(attribute|const|uniform|varying|centroid|break|continue|'
             r'do|for|while|if|else|in|out|inout|float|int|void|bool|true|'
             r'false|invariant|discard|return|mat[234]|mat[234]x[234]|'
             r'vec[234]|[ib]vec[234]|sampler[123]D|samplerCube|'
             r'sampler[12]DShadow|struct)\b', Keyword),
            (r'\b(asm|class|union|enum|typedef|template|this|packed|goto|'
             r'switch|default|inline|noinline|volatile|public|static|extern|'
             r'external|interface|long|short|double|half|fixed|unsigned|'
             r'lowp|mediump|highp|precision|input|output|hvec[234]|'
             r'[df]vec[234]|sampler[23]DRect|sampler2DRectShadow|sizeof|'
             r'cast|namespace|using)\b', Keyword), #future use
            (r'[a-zA-Z_][a-zA-Z_0-9]*', Name.Variable),
            (r'\.', Punctuation),
            (r'\s+', Text),
        ],
    }

class PrologLexer(RegexLexer):
    """
    Lexer for Prolog files.
    """
    name = 'Prolog'
    aliases = ['prolog']
    filenames = ['*.prolog', '*.pro', '*.pl']
    mimetypes = ['text/x-prolog']

    flags = re.UNICODE

    tokens = {
        'root': [
            (r'^#.*', Comment),
            (r'/\*', Comment, 'nested-comment'),
            (r'%.*', Comment),
            (r'[0-9]+', Number),
            (r'[\[\](){}|.,;!]', Punctuation),
            (r':-|-->', Punctuation),
            (r'"(?:\\x[0-9a-fA-F]+\\|\\u[0-9a-fA-F]{4}|\U[0-9a-fA-F]{8}|'
             r'\\[0-7]+\\|\\[\w\W]|[^"])*"', String.Double),
            (r"'(?:''|[^'])*'", String.Atom), # quoted atom
            # Needs to not be followed by an atom.
            #(r'=(?=\s|[a-zA-Z\[])', Operator),
            (r'(is|<|>|=<|>=|==|=:=|=|/|//|\*|\+|-)(?=\s|[a-zA-Z0-9\[])',
             Operator),
            (r'(mod|div|not)\b', Operator),
            (r'_', Keyword), # The don't-care variable
            (r'([a-z]+)(:)', bygroups(Name.Namespace, Punctuation)),
            (u'([a-z\u00c0-\u1fff\u3040-\ud7ff\ue000-\uffef]'
             u'[a-zA-Z0-9_$\u00c0-\u1fff\u3040-\ud7ff\ue000-\uffef]*)'
             u'(\\s*)(:-|-->)',
             bygroups(Name.Function, Text, Operator)), # function defn
            (u'([a-z\u00c0-\u1fff\u3040-\ud7ff\ue000-\uffef]'
             u'[a-zA-Z0-9_$\u00c0-\u1fff\u3040-\ud7ff\ue000-\uffef]*)'
             u'(\\s*)(\\()',
             bygroups(Name.Function, Text, Punctuation)),
            (u'[a-z\u00c0-\u1fff\u3040-\ud7ff\ue000-\uffef]'
             u'[a-zA-Z0-9_$\u00c0-\u1fff\u3040-\ud7ff\ue000-\uffef]*',
             String.Atom), # atom, characters
            # This one includes !
            (u'[#&*+\\-./:<=>?@\\\\^~\u00a1-\u00bf\u2010-\u303f]+',
             String.Atom), # atom, graphics
            (r'[A-Z_][A-Za-z0-9_]*', Name.Variable),
            (u'\\s+|[\u2000-\u200f\ufff0-\ufffe\uffef]', Text),
        ],
        'nested-comment': [
            (r'\*/', Comment, '#pop'),
            (r'/\*', Comment, '#push'),
            (r'[^*/]+', Comment),
            (r'[*/]', Comment),
        ],
    }

    def analyse_text(text):
        return ':-' in text


class CythonLexer(RegexLexer):
    """
    For Pyrex and `Cython <http://cython.org>`_ source code.

    *New in Pygments 1.1.*
    """

    name = 'Cython'
    aliases = ['cython', 'pyx']
    filenames = ['*.pyx', '*.pxd', '*.pxi']
    mimetypes = ['text/x-cython', 'application/x-cython']

    tokens = {
        'root': [
            (r'\n', Text),
            (r'^(\s*)("""(?:.|\n)*?""")', bygroups(Text, String.Doc)),
            (r"^(\s*)('''(?:.|\n)*?''')", bygroups(Text, String.Doc)),
            (r'[^\S\n]+', Text),
            (r'#.*$', Comment),
            (r'[]{}:(),;[]', Punctuation),
            (r'\\\n', Text),
            (r'\\', Text),
            (r'(in|is|and|or|not)\b', Operator.Word),
            (r'(<)([a-zA-Z0-9.?]+)(>)',
             bygroups(Punctuation, Keyword.Type, Punctuation)),
            (r'!=|==|<<|>>|[-~+/*%=<>&^|.?]', Operator),
            (r'(from)(\d+)(<=)(\s+)(<)(\d+)(:)',
             bygroups(Keyword, Number.Integer, Operator, Name, Operator,
                      Name, Punctuation)),
            include('keywords'),
            (r'(def|property)(\s+)', bygroups(Keyword, Text), 'funcname'),
            (r'(cp?def)(\s+)', bygroups(Keyword, Text), 'cdef'),
            (r'(class|struct)(\s+)', bygroups(Keyword, Text), 'classname'),
            (r'(from)(\s+)', bygroups(Keyword, Text), 'fromimport'),
            (r'(c?import)(\s+)', bygroups(Keyword, Text), 'import'),
            include('builtins'),
            include('backtick'),
            ('(?:[rR]|[uU][rR]|[rR][uU])"""', String, 'tdqs'),
            ("(?:[rR]|[uU][rR]|[rR][uU])'''", String, 'tsqs'),
            ('(?:[rR]|[uU][rR]|[rR][uU])"', String, 'dqs'),
            ("(?:[rR]|[uU][rR]|[rR][uU])'", String, 'sqs'),
            ('[uU]?"""', String, combined('stringescape', 'tdqs')),
            ("[uU]?'''", String, combined('stringescape', 'tsqs')),
            ('[uU]?"', String, combined('stringescape', 'dqs')),
            ("[uU]?'", String, combined('stringescape', 'sqs')),
            include('name'),
            include('numbers'),
        ],
        'keywords': [
            (r'(assert|break|by|continue|ctypedef|del|elif|else|except\??|exec|'
             r'finally|for|gil|global|if|include|lambda|nogil|pass|print|raise|'
             r'return|try|while|yield|as|with)\b', Keyword),
            (r'(DEF|IF|ELIF|ELSE)\b', Comment.Preproc),
        ],
        'builtins': [
            (r'(?<!\.)(__import__|abs|all|any|apply|basestring|bin|bool|buffer|'
             r'bytearray|bytes|callable|chr|classmethod|cmp|coerce|compile|'
             r'complex|delattr|dict|dir|divmod|enumerate|eval|execfile|exit|'
             r'file|filter|float|frozenset|getattr|globals|hasattr|hash|hex|id|'
             r'input|int|intern|isinstance|issubclass|iter|len|list|locals|'
             r'long|map|max|min|next|object|oct|open|ord|pow|property|range|'
             r'raw_input|reduce|reload|repr|reversed|round|set|setattr|slice|'
             r'sorted|staticmethod|str|sum|super|tuple|type|unichr|unicode|'
             r'vars|xrange|zip)\b', Name.Builtin),
            (r'(?<!\.)(self|None|Ellipsis|NotImplemented|False|True|NULL'
             r')\b', Name.Builtin.Pseudo),
            (r'(?<!\.)(ArithmeticError|AssertionError|AttributeError|'
             r'BaseException|DeprecationWarning|EOFError|EnvironmentError|'
             r'Exception|FloatingPointError|FutureWarning|GeneratorExit|IOError|'
             r'ImportError|ImportWarning|IndentationError|IndexError|KeyError|'
             r'KeyboardInterrupt|LookupError|MemoryError|NameError|'
             r'NotImplemented|NotImplementedError|OSError|OverflowError|'
             r'OverflowWarning|PendingDeprecationWarning|ReferenceError|'
             r'RuntimeError|RuntimeWarning|StandardError|StopIteration|'
             r'SyntaxError|SyntaxWarning|SystemError|SystemExit|TabError|'
             r'TypeError|UnboundLocalError|UnicodeDecodeError|'
             r'UnicodeEncodeError|UnicodeError|UnicodeTranslateError|'
             r'UnicodeWarning|UserWarning|ValueError|Warning|ZeroDivisionError'
             r')\b', Name.Exception),
        ],
        'numbers': [
            (r'(\d+\.?\d*|\d*\.\d+)([eE][+-]?[0-9]+)?', Number.Float),
            (r'0\d+', Number.Oct),
            (r'0[xX][a-fA-F0-9]+', Number.Hex),
            (r'\d+L', Number.Integer.Long),
            (r'\d+', Number.Integer)
        ],
        'backtick': [
            ('`.*?`', String.Backtick),
        ],
        'name': [
            (r'@[a-zA-Z0-9_]+', Name.Decorator),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
        ],
        'funcname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Function, '#pop')
        ],
        'cdef': [
            (r'(public|readonly|extern|api|inline)\b', Keyword.Reserved),
            (r'(struct|enum|union|class)\b', Keyword),
            (r'([a-zA-Z_][a-zA-Z0-9_]*)(\s*)(?=[(:#=]|$)',
             bygroups(Name.Function, Text), '#pop'),
            (r'([a-zA-Z_][a-zA-Z0-9_]*)(\s*)(,)',
             bygroups(Name.Function, Text, Punctuation)),
            (r'from\b', Keyword, '#pop'),
            (r'as\b', Keyword),
            (r':', Punctuation, '#pop'),
            (r'(?=["\'])', Text, '#pop'),
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Keyword.Type),
            (r'.', Text),
        ],
        'classname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Class, '#pop')
        ],
        'import': [
            (r'(\s+)(as)(\s+)', bygroups(Text, Keyword, Text)),
            (r'[a-zA-Z_][a-zA-Z0-9_.]*', Name.Namespace),
            (r'(\s*)(,)(\s*)', bygroups(Text, Operator, Text)),
            (r'', Text, '#pop') # all else: go back
        ],
        'fromimport': [
            (r'(\s+)(c?import)\b', bygroups(Text, Keyword), '#pop'),
            (r'[a-zA-Z_.][a-zA-Z0-9_.]*', Name.Namespace),
            # ``cdef foo from "header"``, or ``for foo from 0 < i < 10``
            (r'', Text, '#pop'),
        ],
        'stringescape': [
            (r'\\([\\abfnrtv"\']|\n|N{.*?}|u[a-fA-F0-9]{4}|'
             r'U[a-fA-F0-9]{8}|x[a-fA-F0-9]{2}|[0-7]{1,3})', String.Escape)
        ],
        'strings': [
            (r'%(\([a-zA-Z0-9]+\))?[-#0 +]*([0-9]+|[*])?(\.([0-9]+|[*]))?'
             '[hlL]?[diouxXeEfFgGcrs%]', String.Interpol),
            (r'[^\\\'"%\n]+', String),
            # quotes, percents and backslashes must be parsed one at a time
            (r'[\'"\\]', String),
            # unhandled string formatting sign
            (r'%', String)
            # newlines are an error (use "nl" state)
        ],
        'nl': [
            (r'\n', String)
        ],
        'dqs': [
            (r'"', String, '#pop'),
            (r'\\\\|\\"|\\\n', String.Escape), # included here again for raw strings
            include('strings')
        ],
        'sqs': [
            (r"'", String, '#pop'),
            (r"\\\\|\\'|\\\n", String.Escape), # included here again for raw strings
            include('strings')
        ],
        'tdqs': [
            (r'"""', String, '#pop'),
            include('strings'),
            include('nl')
        ],
        'tsqs': [
            (r"'''", String, '#pop'),
            include('strings'),
            include('nl')
        ],
    }
# -*- coding: utf-8 -*-
"""
    pygments.lexers.dotnet
    ~~~~~~~~~~~~~~~~~~~~~~

    Lexers for .net languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import re

from pygments.lexer import RegexLexer, DelegatingLexer, bygroups, using, this
from pygments.token import Punctuation, \
     Text, Comment, Operator, Keyword, Name, String, Number, Literal, Other
from pygments.util import get_choice_opt
from pygments import unistring as uni

from pygments.lexers.web import XmlLexer

__all__ = ['CSharpLexer', 'BooLexer', 'VbNetLexer', 'CSharpAspxLexer',
           'VbNetAspxLexer']


def _escape(st):
    return st.replace(u'\\', ur'\\').replace(u'-', ur'\-').\
           replace(u'[', ur'\[').replace(u']', ur'\]')

class CSharpLexer(RegexLexer):
    """
    For `C# <http://msdn2.microsoft.com/en-us/vcsharp/default.aspx>`_
    source code.

    Additional options accepted:

    `unicodelevel`
      Determines which Unicode characters this lexer allows for identifiers.
      The possible values are:

      * ``none`` -- only the ASCII letters and numbers are allowed. This
        is the fastest selection.
      * ``basic`` -- all Unicode characters from the specification except
        category ``Lo`` are allowed.
      * ``full`` -- all Unicode characters as specified in the C# specs
        are allowed.  Note that this means a considerable slowdown since the
        ``Lo`` category has more than 40,000 characters in it!

      The default value is ``basic``.

      *New in Pygments 0.8.*
    """

    name = 'C#'
    aliases = ['csharp', 'c#']
    filenames = ['*.cs']
    mimetypes = ['text/x-csharp'] # inferred

    flags = re.MULTILINE | re.DOTALL | re.UNICODE

    # for the range of allowed unicode characters in identifiers,
    # see http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-334.pdf

    levels = {
        'none': '@?[_a-zA-Z][a-zA-Z0-9_]*',
        'basic': ('@?[_' + uni.Lu + uni.Ll + uni.Lt + uni.Lm + uni.Nl + ']' +
                  '[' + uni.Lu + uni.Ll + uni.Lt + uni.Lm + uni.Nl +
                  uni.Nd + uni.Pc + uni.Cf + uni.Mn + uni.Mc + ']*'),
        'full': ('@?(?:_|[^' +
                 _escape(uni.allexcept('Lu', 'Ll', 'Lt', 'Lm', 'Lo', 'Nl')) + '])'
                 + '[^' + _escape(uni.allexcept('Lu', 'Ll', 'Lt', 'Lm', 'Lo',
                                                'Nl', 'Nd', 'Pc', 'Cf', 'Mn',
                                                'Mc')) + ']*'),
    }

    tokens = {}
    token_variants = True

    for levelname, cs_ident in levels.items():
        tokens[levelname] = {
            'root': [
                # method names
                (r'^([ \t]*(?:' + cs_ident + r'(?:\[\])?\s+)+?)' # return type
                 r'(' + cs_ident + ')'                           # method name
                 r'(\s*)(\()',                               # signature start
                 bygroups(using(this), Name.Function, Text, Punctuation)),
                (r'^\s*\[.*?\]', Name.Attribute),
                (r'[^\S\n]+', Text),
                (r'\\\n', Text), # line continuation
                (r'//.*?\n', Comment),
                (r'/[*](.|\n)*?[*]/', Comment),
                (r'\n', Text),
                (r'[~!%^&*()+=|\[\]:;,.<>/?-]', Punctuation),
                (r'[{}]', Punctuation),
                (r'@"(\\\\|\\"|[^"])*"', String),
                (r'"(\\\\|\\"|[^"\n])*["\n]', String),
                (r"'\\.'|'[^\\]'", String.Char),
                (r"[0-9](\.[0-9]*)?([eE][+-][0-9]+)?"
                 r"[flFLdD]?|0[xX][0-9a-fA-F]+[Ll]?", Number),
                (r'#[ \t]*(if|endif|else|elif|define|undef|'
                 r'line|error|warning|region|endregion|pragma)\b.*?\n',
                 Comment.Preproc),
                (r'\b(extern)(\s+)(alias)\b', bygroups(Keyword, Text,
                 Keyword)),
                (r'(abstract|as|base|break|case|catch|'
                 r'checked|const|continue|default|delegate|'
                 r'do|else|enum|event|explicit|extern|false|finally|'
                 r'fixed|for|foreach|goto|if|implicit|in|interface|'
                 r'internal|is|lock|new|null|operator|'
                 r'out|override|params|private|protected|public|readonly|'
                 r'ref|return|sealed|sizeof|stackalloc|static|'
                 r'switch|this|throw|true|try|typeof|'
                 r'unchecked|unsafe|virtual|void|while|'
                 r'get|set|new|partial|yield|add|remove|value)\b', Keyword),
                (r'(global)(::)', bygroups(Keyword, Punctuation)),
                (r'(bool|byte|char|decimal|double|float|int|long|object|sbyte|'
                 r'short|string|uint|ulong|ushort)\b\??', Keyword.Type),
                (r'(class|struct)(\s+)', bygroups(Keyword, Text), 'class'),
                (r'(namespace|using)(\s+)', bygroups(Keyword, Text), 'namespace'),
                (cs_ident, Name),
            ],
            'class': [
                (cs_ident, Name.Class, '#pop')
            ],
            'namespace': [
                (r'(?=\()', Text, '#pop'), # using (resource)
                ('(' + cs_ident + r'|\.)+', Name.Namespace, '#pop')
            ]
        }

    def __init__(self, **options):
        level = get_choice_opt(options, 'unicodelevel', self.tokens.keys(), 'basic')
        if level not in self._all_tokens:
            # compile the regexes now
            self._tokens = self.__class__.process_tokendef(level)
        else:
            self._tokens = self._all_tokens[level]

        RegexLexer.__init__(self, **options)


class BooLexer(RegexLexer):
    """
    For `Boo <http://boo.codehaus.org/>`_ source code.
    """

    name = 'Boo'
    aliases = ['boo']
    filenames = ['*.boo']
    mimetypes = ['text/x-boo']

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'(#|//).*$', Comment),
            (r'/[*]', Comment, 'comment'),
            (r'[]{}:(),.;[]', Punctuation),
            (r'\\\n', Text),
            (r'\\', Text),
            (r'(in|is|and|or|not)\b', Operator.Word),
            (r'/(\\\\|\\/|[^/\s])/', String.Regex),
            (r'@/(\\\\|\\/|[^/])*/', String.Regex),
            (r'=~|!=|==|<<|>>|[-+/*%=<>&^|]', Operator),
            (r'(as|abstract|callable|constructor|destructor|do|import|'
             r'enum|event|final|get|interface|internal|of|override|'
             r'partial|private|protected|public|return|set|static|'
             r'struct|transient|virtual|yield|super|and|break|cast|'
             r'continue|elif|else|ensure|except|for|given|goto|if|in|'
             r'is|isa|not|or|otherwise|pass|raise|ref|try|unless|when|'
             r'while|from|as)\b', Keyword),
            (r'def(?=\s+\(.*?\))', Keyword),
            (r'(def)(\s+)', bygroups(Keyword, Text), 'funcname'),
            (r'(class)(\s+)', bygroups(Keyword, Text), 'classname'),
            (r'(namespace)(\s+)', bygroups(Keyword, Text), 'namespace'),
            (r'(?<!\.)(true|false|null|self|__eval__|__switch__|array|'
             r'assert|checked|enumerate|filter|getter|len|lock|map|'
             r'matrix|max|min|normalArrayIndexing|print|property|range|'
             r'rawArrayIndexing|required|typeof|unchecked|using|'
             r'yieldAll|zip)\b', Name.Builtin),
            ('"""(\\\\|\\"|.*?)"""', String.Double),
            ('"(\\\\|\\"|[^"]*?)"', String.Double),
            ("'(\\\\|\\'|[^']*?)'", String.Single),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
            (r'(\d+\.\d*|\d*\.\d+)([fF][+-]?[0-9]+)?', Number.Float),
            (r'[0-9][0-9\.]*(m|ms|d|h|s)', Number),
            (r'0\d+', Number.Oct),
            (r'0x[a-fA-F0-9]+', Number.Hex),
            (r'\d+L', Number.Integer.Long),
            (r'\d+', Number.Integer),
        ],
        'comment': [
            ('/[*]', Comment.Multiline, '#push'),
            ('[*]/', Comment.Multiline, '#pop'),
            ('[^/*]', Comment.Multiline),
            ('[*/]', Comment.Multiline)
        ],
        'funcname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Function, '#pop')
        ],
        'classname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Class, '#pop')
        ],
        'namespace': [
            ('[a-zA-Z_][a-zA-Z0-9_.]*', Name.Namespace, '#pop')
        ]
    }


class VbNetLexer(RegexLexer):
    """
    For
    `Visual Basic.NET <http://msdn2.microsoft.com/en-us/vbasic/default.aspx>`_
    source code.
    """

    name = 'VB.net'
    aliases = ['vb.net', 'vbnet']
    filenames = ['*.vb', '*.bas']
    mimetypes = ['text/x-vbnet', 'text/x-vba'] # (?)

    flags = re.MULTILINE | re.IGNORECASE
    tokens = {
        'root': [
            (r'^\s*<.*?>', Name.Attribute),
            (r'\s+', Text),
            (r'\n', Text),
            (r'rem\b.*?\n', Comment),
            (r"'.*?\n", Comment),
            (r'#If\s.*?\sThen|#ElseIf\s.*?\sThen|#End\s+If|#Const|'
             r'#ExternalSource.*?\n|#End\s+ExternalSource|'
             r'#Region.*?\n|#End\s+Region|#ExternalChecksum',
             Comment.Preproc),
            (r'[\(\){}!#,.:]', Punctuation),
            (r'Option\s+(Strict|Explicit|Compare)\s+'
             r'(On|Off|Binary|Text)', Keyword.Declaration),
            (r'(?<!\.)(AddHandler|Alias|'
             r'ByRef|ByVal|Call|Case|Catch|CBool|CByte|CChar|CDate|'
             r'CDec|CDbl|CInt|CLng|CObj|Const|Continue|CSByte|CShort|'
             r'CSng|CStr|CType|CUInt|CULng|CUShort|Declare|'
             r'Default|Delegate|Dim|DirectCast|Do|Each|Else|ElseIf|'
             r'End|EndIf|Enum|Erase|Error|Event|Exit|False|Finally|For|'
             r'Friend|Function|Get|Global|GoSub|GoTo|Handles|If|'
             r'Implements|Imports|Inherits|Interface|'
             r'Let|Lib|Loop|Me|Module|MustInherit|'
             r'MustOverride|MyBase|MyClass|Namespace|Narrowing|New|Next|'
             r'Not|Nothing|NotInheritable|NotOverridable|Of|On|'
             r'Operator|Option|Optional|Overloads|Overridable|'
             r'Overrides|ParamArray|Partial|Private|Property|Protected|'
             r'Public|RaiseEvent|ReadOnly|ReDim|RemoveHandler|Resume|'
             r'Return|Select|Set|Shadows|Shared|Single|'
             r'Static|Step|Stop|Structure|Sub|SyncLock|Then|'
             r'Throw|To|True|Try|TryCast|Wend|'
             r'Using|When|While|Widening|With|WithEvents|'
             r'WriteOnly)\b', Keyword),
            (r'(?<!\.)(Function|Sub|Property)(\s+)',
             bygroups(Keyword, Text), 'funcname'),
            (r'(?<!\.)(Class|Structure|Enum)(\s+)',
             bygroups(Keyword, Text), 'classname'),
            (r'(?<!\.)(Namespace|Imports)(\s+)',
             bygroups(Keyword, Text), 'namespace'),
            (r'(?<!\.)(Boolean|Byte|Char|Date|Decimal|Double|Integer|Long|'
             r'Object|SByte|Short|Single|String|Variant|UInteger|ULong|'
             r'UShort)\b', Keyword.Type),
            (r'(?<!\.)(AddressOf|And|AndAlso|As|GetType|In|Is|IsNot|Like|Mod|'
             r'Or|OrElse|TypeOf|Xor)\b', Operator.Word),
            (r'&=|[*]=|/=|\\=|\^=|\+=|-=|<<=|>>=|<<|>>|:=|'
             r'<=|>=|<>|[-&*/\\^+=<>]',
             Operator),
            ('"', String, 'string'),
            ('[a-zA-Z_][a-zA-Z0-9_]*[%&@!#$]?', Name),
            ('#.*?#', Literal.Date),
            (r'(\d+\.\d*|\d*\.\d+)([fF][+-]?[0-9]+)?', Number.Float),
            (r'\d+([SILDFR]|US|UI|UL)?', Number.Integer),
            (r'&H[0-9a-f]+([SILDFR]|US|UI|UL)?', Number.Integer),
            (r'&O[0-7]+([SILDFR]|US|UI|UL)?', Number.Integer),
            (r'_\n', Text), # Line continuation
        ],
        'string': [
            (r'""', String),
            (r'"C?', String, '#pop'),
            (r'[^"]+', String),
        ],
        'funcname': [
            (r'[a-z_][a-z0-9_]*', Name.Function, '#pop')
        ],
        'classname': [
            (r'[a-z_][a-z0-9_]*', Name.Class, '#pop')
        ],
        'namespace': [
            (r'[a-z_][a-z0-9_.]*', Name.Namespace, '#pop')
        ],
    }

class GenericAspxLexer(RegexLexer):
    """
    Lexer for ASP.NET pages.
    """

    name = 'aspx-gen'
    filenames = []
    mimetypes = []

    flags = re.DOTALL

    tokens = {
        'root': [
            (r'(<%[@=#]?)(.*?)(%>)', bygroups(Name.Tag, Other, Name.Tag)),
            (r'(<script.*?>)(.*?)(</script>)', bygroups(using(XmlLexer),
                                                        Other,
                                                        using(XmlLexer))),
            (r'(.+?)(?=<)', using(XmlLexer)),
            (r'.+', using(XmlLexer)),
        ],
    }

#TODO support multiple languages within the same source file
class CSharpAspxLexer(DelegatingLexer):
    """
    Lexer for highligting C# within ASP.NET pages.
    """

    name = 'aspx-cs'
    aliases = ['aspx-cs']
    filenames = ['*.aspx', '*.asax', '*.ascx', '*.ashx', '*.asmx', '*.axd']
    mimetypes = []

    def __init__(self, **options):
        super(CSharpAspxLexer, self).__init__(CSharpLexer,GenericAspxLexer,
                                              **options)

    def analyse_text(text):
        if re.search(r'Page\s*Language="C#"', text, re.I) is not None:
            return 0.2
        elif re.search(r'script[^>]+language=["\']C#', text, re.I) is not None:
            return 0.15
        return 0.001 # TODO really only for when filename matched...

class VbNetAspxLexer(DelegatingLexer):
    """
    Lexer for highligting Visual Basic.net within ASP.NET pages.
    """

    name = 'aspx-vb'
    aliases = ['aspx-vb']
    filenames = ['*.aspx', '*.asax', '*.ascx', '*.ashx', '*.asmx', '*.axd']
    mimetypes = []

    def __init__(self, **options):
        super(VbNetAspxLexer, self).__init__(VbNetLexer,GenericAspxLexer,
                                              **options)

    def analyse_text(text):
        if re.search(r'Page\s*Language="Vb"', text, re.I) is not None:
            return 0.2
        elif re.search(r'script[^>]+language=["\']vb', text, re.I) is not None:
            return 0.15
# -*- coding: utf-8 -*-
"""
    pygments.lexers.functional
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

    Lexers for functional languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.lexer import Lexer, RegexLexer, bygroups, include, do_insertions
from pygments.token import Text, Comment, Operator, Keyword, Name, \
     String, Number, Punctuation, Literal, Generic


__all__ = ['SchemeLexer', 'CommonLispLexer', 'HaskellLexer', 'LiterateHaskellLexer',
           'OcamlLexer', 'ErlangLexer', 'ErlangShellLexer']


class SchemeLexer(RegexLexer):
    """
    A Scheme lexer, parsing a stream and outputting the tokens
    needed to highlight scheme code.
    This lexer could be most probably easily subclassed to parse
    other LISP-Dialects like Common Lisp, Emacs Lisp or AutoLisp.

    This parser is checked with pastes from the LISP pastebin
    at http://paste.lisp.org/ to cover as much syntax as possible.

    It supports the full Scheme syntax as defined in R5RS.

    *New in Pygments 0.6.*
    """
    name = 'Scheme'
    aliases = ['scheme', 'scm']
    filenames = ['*.scm']
    mimetypes = ['text/x-scheme', 'application/x-scheme']

    # list of known keywords and builtins taken form vim 6.4 scheme.vim
    # syntax file.
    keywords = [
        'lambda', 'define', 'if', 'else', 'cond', 'and', 'or', 'case', 'let',
        'let*', 'letrec', 'begin', 'do', 'delay', 'set!', '=>', 'quote',
        'quasiquote', 'unquote', 'unquote-splicing', 'define-syntax',
        'let-syntax', 'letrec-syntax', 'syntax-rules'
    ]
    builtins = [
        '*', '+', '-', '/', '<', '<=', '=', '>', '>=', 'abs', 'acos', 'angle',
        'append', 'apply', 'asin', 'assoc', 'assq', 'assv', 'atan',
        'boolean?', 'caaaar', 'caaadr', 'caaar', 'caadar', 'caaddr', 'caadr',
        'caar', 'cadaar', 'cadadr', 'cadar', 'caddar', 'cadddr', 'caddr',
        'cadr', 'call-with-current-continuation', 'call-with-input-file',
        'call-with-output-file', 'call-with-values', 'call/cc', 'car',
        'cdaaar', 'cdaadr', 'cdaar', 'cdadar', 'cdaddr', 'cdadr', 'cdar',
        'cddaar', 'cddadr', 'cddar', 'cdddar', 'cddddr', 'cdddr', 'cddr',
        'cdr', 'ceiling', 'char->integer', 'char-alphabetic?', 'char-ci<=?',
        'char-ci<?', 'char-ci=?', 'char-ci>=?', 'char-ci>?', 'char-downcase',
        'char-lower-case?', 'char-numeric?', 'char-ready?', 'char-upcase',
        'char-upper-case?', 'char-whitespace?', 'char<=?', 'char<?', 'char=?',
        'char>=?', 'char>?', 'char?', 'close-input-port', 'close-output-port',
        'complex?', 'cons', 'cos', 'current-input-port', 'current-output-port',
        'denominator', 'display', 'dynamic-wind', 'eof-object?', 'eq?',
        'equal?', 'eqv?', 'eval', 'even?', 'exact->inexact', 'exact?', 'exp',
        'expt', 'floor', 'for-each', 'force', 'gcd', 'imag-part',
        'inexact->exact', 'inexact?', 'input-port?', 'integer->char',
        'integer?', 'interaction-environment', 'lcm', 'length', 'list',
        'list->string', 'list->vector', 'list-ref', 'list-tail', 'list?',
        'load', 'log', 'magnitude', 'make-polar', 'make-rectangular',
        'make-string', 'make-vector', 'map', 'max', 'member', 'memq', 'memv',
        'min', 'modulo', 'negative?', 'newline', 'not', 'null-environment',
        'null?', 'number->string', 'number?', 'numerator', 'odd?',
        'open-input-file', 'open-output-file', 'output-port?', 'pair?',
        'peek-char', 'port?', 'positive?', 'procedure?', 'quotient',
        'rational?', 'rationalize', 'read', 'read-char', 'real-part', 'real?',
        'remainder', 'reverse', 'round', 'scheme-report-environment',
        'set-car!', 'set-cdr!', 'sin', 'sqrt', 'string', 'string->list',
        'string->number', 'string->symbol', 'string-append', 'string-ci<=?',
        'string-ci<?', 'string-ci=?', 'string-ci>=?', 'string-ci>?',
        'string-copy', 'string-fill!', 'string-length', 'string-ref',
        'string-set!', 'string<=?', 'string<?', 'string=?', 'string>=?',
        'string>?', 'string?', 'substring', 'symbol->string', 'symbol?',
        'tan', 'transcript-off', 'transcript-on', 'truncate', 'values',
        'vector', 'vector->list', 'vector-fill!', 'vector-length',
        'vector-ref', 'vector-set!', 'vector?', 'with-input-from-file',
        'with-output-to-file', 'write', 'write-char', 'zero?'
    ]

    # valid names for identifiers
    # well, names can only not consist fully of numbers
    # but this should be good enough for now
    valid_name = r'[a-zA-Z0-9!$%&*+,/:<=>?@^_~|-]+'

    tokens = {
        'root' : [
            # the comments - always starting with semicolon
            # and going to the end of the line
            (r';.*$', Comment.Single),

            # whitespaces - usually not relevant
            (r'\s+', Text),

            # numbers
            (r'-?\d+\.\d+', Number.Float),
            (r'-?\d+', Number.Integer),
            # support for uncommon kinds of numbers -
            # have to figure out what the characters mean
            #(r'(#e|#i|#b|#o|#d|#x)[\d.]+', Number),

            # strings, symbols and characters
            (r'"(\\\\|\\"|[^"])*"', String),
            (r"'" + valid_name, String.Symbol),
            (r"#\\([()/'\".'_!§$%& ?=+-]{1}|[a-zA-Z0-9]+)", String.Char),

            # constants
            (r'(#t|#f)', Name.Constant),

            # special operators
            (r"('|#|`|,@|,|\.)", Operator),

            # highlight the keywords
            ('(%s)' % '|'.join([
                re.escape(entry) + ' ' for entry in keywords]),
                Keyword
            ),

            # first variable in a quoted string like
            # '(this is syntactic sugar)
            (r"(?<='\()" + valid_name, Name.Variable),
            (r"(?<=#\()" + valid_name, Name.Variable),

            # highlight the builtins
            ("(?<=\()(%s)" % '|'.join([
                re.escape(entry) + ' ' for entry in builtins]),
                Name.Builtin
            ),

            # the remaining functions
            (r'(?<=\()' + valid_name, Name.Function),
            # find the remaining variables
            (valid_name, Name.Variable),

            # the famous parentheses!
            (r'(\(|\))', Punctuation),
        ],
    }


class CommonLispLexer(RegexLexer):
    """
    A Common Lisp lexer.

    *New in Pygments 0.9.*
    """
    name = 'Common Lisp'
    aliases = ['common-lisp', 'cl']
    filenames = ['*.cl', '*.lisp', '*.el']  # use for Elisp too
    mimetypes = ['text/x-common-lisp']

    flags = re.IGNORECASE | re.MULTILINE

    ### couple of useful regexes

    # characters that are not macro-characters and can be used to begin a symbol
    nonmacro = r'\\.|[a-zA-Z0-9!$%&*+-/<=>?@\[\]^_{}~]'
    constituent = nonmacro + '|[#.:]'
    terminated = r'(?=[ "()\'\n,;`])' # whitespace or terminating macro characters

    ### symbol token, reverse-engineered from hyperspec
    # Take a deep breath...
    symbol = r'(\|[^|]+\||(?:%s)(?:%s)*)' % (nonmacro, constituent)

    def __init__(self, **options):
        from pygments.lexers._clbuiltins import BUILTIN_FUNCTIONS, \
            SPECIAL_FORMS, MACROS, LAMBDA_LIST_KEYWORDS, DECLARATIONS, \
            BUILTIN_TYPES, BUILTIN_CLASSES
        self.builtin_function = BUILTIN_FUNCTIONS
        self.special_forms = SPECIAL_FORMS
        self.macros = MACROS
        self.lambda_list_keywords = LAMBDA_LIST_KEYWORDS
        self.declarations = DECLARATIONS
        self.builtin_types = BUILTIN_TYPES
        self.builtin_classes = BUILTIN_CLASSES
        RegexLexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        stack = ['root']
        for index, token, value in RegexLexer.get_tokens_unprocessed(self, text, stack):
            if token is Name.Variable:
                if value in self.builtin_function:
                    yield index, Name.Builtin, value
                    continue
                if value in self.special_forms:
                    yield index, Keyword, value
                    continue
                if value in self.macros:
                    yield index, Name.Builtin, value
                    continue
                if value in self.lambda_list_keywords:
                    yield index, Keyword, value
                    continue
                if value in self.declarations:
                    yield index, Keyword, value
                    continue
                if value in self.builtin_types:
                    yield index, Keyword.Type, value
                    continue
                if value in self.builtin_classes:
                    yield index, Name.Class, value
                    continue
            yield index, token, value

    tokens = {
        'root' : [
            ('', Text, 'body'),
        ],
        'multiline-comment' : [
            (r'#\|', Comment.Multiline, '#push'), # (cf. Hyperspec 2.4.8.19)
            (r'\|#', Comment.Multiline, '#pop'),
            (r'[^|#]+', Comment.Multiline),
            (r'[|#]', Comment.Multiline),
        ],
        'commented-form' : [
            (r'\(', Comment.Preproc, '#push'),
            (r'\)', Comment.Preproc, '#pop'),
            (r'[^()]+', Comment.Preproc),
        ],
        'body' : [
            # whitespace
            (r'\s+', Text),

            # single-line comment
            (r';.*$', Comment.Single),

            # multi-line comment
            (r'#\|', Comment.Multiline, 'multiline-comment'),

            # encoding comment (?)
            (r'#\d*Y.*$', Comment.Special),

            # strings and characters
            (r'"(\\.|[^"])*"', String),
            # quoting
            (r":" + symbol, String.Symbol),
            (r"'" + symbol, String.Symbol),
            (r"'", Operator),
            (r"`", Operator),

            # decimal numbers
            (r'[-+]?\d+\.?' + terminated, Number.Integer),
            (r'[-+]?\d+/\d+' + terminated, Number),
            (r'[-+]?(\d*\.\d+([defls][-+]?\d+)?|\d+(\.\d*)?[defls][-+]?\d+)' \
                + terminated, Number.Float),

            # sharpsign strings and characters
            (r"#\\." + terminated, String.Char),
            (r"#\\" + symbol, String.Char),

            # vector
            (r'#\(', Operator, 'body'),

            # bitstring
            (r'#\d*\*[01]*', Literal.Other),

            # uninterned symbol
            (r'#:' + symbol, String.Symbol),

            # read-time and load-time evaluation
            (r'#[.,]', Operator),

            # function shorthand
            (r'#\'', Name.Function),

            # binary rational
            (r'#[bB][+-]?[01]+(/[01]+)?', Number),

            # octal rational
            (r'#[oO][+-]?[0-7]+(/[0-7]+)?', Number.Oct),

            # hex rational
            (r'#[xX][+-]?[0-9a-fA-F]+(/[0-9a-fA-F]+)?', Number.Hex),

            # radix rational
            (r'#\d+[rR][+-]?[0-9a-zA-Z]+(/[0-9a-zA-Z]+)?', Number),

            # complex
            (r'(#[cC])(\()', bygroups(Number, Punctuation), 'body'),

            # array
            (r'(#\d+[aA])(\()', bygroups(Literal.Other, Punctuation), 'body'),

            # structure
            (r'(#[sS])(\()', bygroups(Literal.Other, Punctuation), 'body'),

            # path
            (r'#[pP]?"(\\.|[^"])*"', Literal.Other),

            # reference
            (r'#\d+=', Operator),
            (r'#\d+#', Operator),

            # read-time comment
            (r'#+nil' + terminated + '\s*\(', Comment.Preproc, 'commented-form'),

            # read-time conditional
            (r'#[+-]', Operator),

            # special operators that should have been parsed already
            (r'(,@|,|\.)', Operator),

            # special constants
            (r'(t|nil)' + terminated, Name.Constant),

            # functions and variables
            (r'\*' + symbol + '\*', Name.Variable.Global),
            (symbol, Name.Variable),

            # parentheses
            (r'\(', Punctuation, 'body'),
            (r'\)', Punctuation, '#pop'),
        ],
    }


class HaskellLexer(RegexLexer):
    """
    A Haskell lexer based on the lexemes defined in the Haskell 98 Report.

    *New in Pygments 0.8.*
    """
    name = 'Haskell'
    aliases = ['haskell', 'hs']
    filenames = ['*.hs']
    mimetypes = ['text/x-haskell']

    reserved = ['case','class','data','default','deriving','do','else',
                'if','in','infix[lr]?','instance',
                'let','newtype','of','then','type','where','_']
    ascii = ['NUL','SOH','[SE]TX','EOT','ENQ','ACK',
             'BEL','BS','HT','LF','VT','FF','CR','S[OI]','DLE',
             'DC[1-4]','NAK','SYN','ETB','CAN',
             'EM','SUB','ESC','[FGRU]S','SP','DEL']

    tokens = {
        'root': [
            # Whitespace:
            (r'\s+', Text),
            #(r'--\s*|.*$', Comment.Doc),
            (r'--.*$', Comment.Single),
            (r'{-', Comment.Multiline, 'comment'),
            # Lexemes:
            #  Identifiers
            (r'\bimport\b', Keyword.Reserved, 'import'),
            (r'\bmodule\b', Keyword.Reserved, 'module'),
            (r'\berror\b', Name.Exception),
            (r'\b(%s)(?!\')\b' % '|'.join(reserved), Keyword.Reserved),
            (r'^[_a-z][\w\']*', Name.Function),
            (r'[_a-z][\w\']*', Name),
            (r'[A-Z][\w\']*', Keyword.Type),
            #  Operators
            (r'\\(?![:!#$%&*+.\\/<=>?@^|~-]+)', Name.Function), # lambda operator
            (r'(<-|::|->|=>|=)(?![:!#$%&*+.\\/<=>?@^|~-]+)', Operator.Word), # specials
            (r':[:!#$%&*+.\\/<=>?@^|~-]*', Keyword.Type), # Constructor operators
            (r'[:!#$%&*+.\\/<=>?@^|~-]+', Operator), # Other operators
            #  Numbers
            (r'\d+[eE][+-]?\d+', Number.Float),
            (r'\d+\.\d+([eE][+-]?\d+)?', Number.Float),
            (r'0[oO][0-7]+', Number.Oct),
            (r'0[xX][\da-fA-F]+', Number.Hex),
            (r'\d+', Number.Integer),
            #  Character/String Literals
            (r"'", String.Char, 'character'),
            (r'"', String, 'string'),
            #  Special
            (r'\[\]', Keyword.Type),
            (r'\(\)', Name.Builtin),
            (r'[][(),;`{}]', Punctuation),
        ],
        'import': [
            # Import statements
            (r'\s+', Text),
            # after "funclist" state
            (r'\)', Punctuation, '#pop'),
            (r'qualified\b', Keyword),
            # import X as Y
            (r'([A-Z][a-zA-Z0-9_.]*)(\s+)(as)(\s+)([A-Z][a-zA-Z0-9_.]*)',
             bygroups(Name.Namespace, Text, Keyword, Text, Name), '#pop'),
            # import X hiding (functions)
            (r'([A-Z][a-zA-Z0-9_.]*)(\s+)(hiding)(\s+)(\()',
             bygroups(Name.Namespace, Text, Keyword, Text, Punctuation), 'funclist'),
            # import X (functions)
            (r'([A-Z][a-zA-Z0-9_.]*)(\s+)(\()',
             bygroups(Name.Namespace, Text, Punctuation), 'funclist'),
            # import X
            (r'[a-zA-Z0-9_.]+', Name.Namespace, '#pop'),
        ],
        'module': [
            (r'\s+', Text),
            (r'([A-Z][a-zA-Z0-9_.]*)(\s+)(\()',
             bygroups(Name.Namespace, Text, Punctuation), 'funclist'),
            (r'[A-Z][a-zA-Z0-9_.]*', Name.Namespace, '#pop'),
        ],
        'funclist': [
            (r'\s+', Text),
            (r'[A-Z][a-zA-Z0-9_]*', Keyword.Type),
            (r'[_a-z][\w\']+', Name.Function),
            (r'--.*$', Comment.Single),
            (r'{-', Comment.Multiline, 'comment'),
            (r',', Punctuation),
            (r'[:!#$%&*+.\\/<=>?@^|~-]+', Operator),
            # (HACK, but it makes sense to push two instances, believe me)
            (r'\(', Punctuation, ('funclist', 'funclist')),
            (r'\)', Punctuation, '#pop:2'),
        ],
        'comment': [
            # Multiline Comments
            (r'[^-{}]+', Comment.Multiline),
            (r'{-', Comment.Multiline, '#push'),
            (r'-}', Comment.Multiline, '#pop'),
            (r'[-{}]', Comment.Multiline),
        ],
        'character': [
            # Allows multi-chars, incorrectly.
            (r"[^\\']", String.Char),
            (r"\\", String.Escape, 'escape'),
            ("'", String.Char, '#pop'),
        ],
        'string': [
            (r'[^\\"]+', String),
            (r"\\", String.Escape, 'escape'),
            ('"', String, '#pop'),
        ],
        'escape': [
            (r'[abfnrtv"\'&\\]', String.Escape, '#pop'),
            (r'\^[][A-Z@\^_]', String.Escape, '#pop'),
            ('|'.join(ascii), String.Escape, '#pop'),
            (r'o[0-7]+', String.Escape, '#pop'),
            (r'x[\da-fA-F]+', String.Escape, '#pop'),
            (r'\d+', String.Escape, '#pop'),
            (r'\n\s+\\', String.Escape, '#pop'),
        ],
    }


line_re = re.compile('.*?\n')
bird_re = re.compile(r'(>[ \t]*)(.*\n)')

class LiterateHaskellLexer(Lexer):
    """
    For Literate Haskell (Bird-style or LaTeX) source.

    Additional options accepted:

    `litstyle`
        If given, must be ``"bird"`` or ``"latex"``.  If not given, the style
        is autodetected: if the first non-whitespace character in the source
        is a backslash or percent character, LaTeX is assumed, else Bird.

    *New in Pygments 0.9.*
    """
    name = 'Literate Haskell'
    aliases = ['lhs', 'literate-haskell']
    filenames = ['*.lhs']
    mimetypes = ['text/x-literate-haskell']

    def get_tokens_unprocessed(self, text):
        hslexer = HaskellLexer(**self.options)

        style = self.options.get('litstyle')
        if style is None:
            style = (text.lstrip()[0] in '%\\') and 'latex' or 'bird'

        code = ''
        insertions = []
        if style == 'bird':
            # bird-style
            for match in line_re.finditer(text):
                line = match.group()
                m = bird_re.match(line)
                if m:
                    insertions.append((len(code), [(0, Comment.Special, m.group(1))]))
                    code += m.group(2)
                else:
                    insertions.append((len(code), [(0, Text, line)]))
        else:
            # latex-style
            from pygments.lexers.text import TexLexer
            lxlexer = TexLexer(**self.options)

            codelines = 0
            latex = ''
            for match in line_re.finditer(text):
                line = match.group()
                if codelines:
                    if line.lstrip().startswith('\\end{code}'):
                        codelines = 0
                        latex += line
                    else:
                        code += line
                elif line.lstrip().startswith('\\begin{code}'):
                    codelines = 1
                    latex += line
                    insertions.append((len(code),
                                       list(lxlexer.get_tokens_unprocessed(latex))))
                    latex = ''
                else:
                    latex += line
            insertions.append((len(code),
                               list(lxlexer.get_tokens_unprocessed(latex))))
        for item in do_insertions(insertions, hslexer.get_tokens_unprocessed(code)):
            yield item


class OcamlLexer(RegexLexer):
    """
    For the OCaml language.

    *New in Pygments 0.7.*
    """

    name = 'OCaml'
    aliases = ['ocaml']
    filenames = ['*.ml', '*.mli', '*.mll', '*.mly']
    mimetypes = ['text/x-ocaml']

    keywords = [
      'as', 'assert', 'begin', 'class', 'constraint', 'do', 'done',
      'downto', 'else', 'end', 'exception', 'external', 'false',
      'for', 'fun', 'function', 'functor', 'if', 'in', 'include',
      'inherit', 'initializer', 'lazy', 'let', 'match', 'method',
      'module', 'mutable', 'new', 'object', 'of', 'open', 'private',
      'raise', 'rec', 'sig', 'struct', 'then', 'to', 'true', 'try',
      'type', 'val', 'virtual', 'when', 'while', 'with'
    ]
    keyopts = [
      '!=','#','&','&&','\(','\)','\*','\+',',','-',
      '-\.','->','\.','\.\.',':','::',':=',':>',';',';;','<',
      '<-','=','>','>]','>}','\?','\?\?','\[','\[<','\[>','\[\|',
      ']','_','`','{','{<','\|','\|]','}','~'
    ]

    operators = r'[!$%&*+\./:<=>?@^|~-]'
    word_operators = ['and', 'asr', 'land', 'lor', 'lsl', 'lxor', 'mod', 'or']
    prefix_syms = r'[!?~]'
    infix_syms = r'[=<>@^|&+\*/$%-]'
    primitives = ['unit', 'int', 'float', 'bool', 'string', 'char', 'list', 'array']

    tokens = {
        'escape-sequence': [
            (r'\\[\"\'ntbr]', String.Escape),
            (r'\\[0-9]{3}', String.Escape),
            (r'\\x[0-9a-fA-F]{2}', String.Escape),
        ],
        'root': [
            (r'\s+', Text),
            (r'false|true|\(\)|\[\]', Name.Builtin.Pseudo),
            (r'\b([A-Z][A-Za-z0-9_\']*)(?=\s*\.)',
             Name.Namespace, 'dotted'),
            (r'\b([A-Z][A-Za-z0-9_\']*)', Name.Class),
            (r'\(\*', Comment, 'comment'),
            (r'\b(%s)\b' % '|'.join(keywords), Keyword),
            (r'(%s)' % '|'.join(keyopts), Operator),
            (r'(%s|%s)?%s' % (infix_syms, prefix_syms, operators), Operator),
            (r'\b(%s)\b' % '|'.join(word_operators), Operator.Word),
            (r'\b(%s)\b' % '|'.join(primitives), Keyword.Type),

            (r"[^\W\d][\w']*", Name),

            (r'\d[\d_]*', Number.Integer),
            (r'0[xX][\da-fA-F][\da-fA-F_]*', Number.Hex),
            (r'0[oO][0-7][0-7_]*', Number.Oct),
            (r'0[bB][01][01_]*', Number.Binary),
            (r'-?\d[\d_]*(.[\d_]*)?([eE][+\-]?\d[\d_]*)', Number.Float),

            (r"'(?:(\\[\\\"'ntbr ])|(\\[0-9]{3})|(\\x[0-9a-fA-F]{2}))'",
             String.Char),
            (r"'.'", String.Char),
            (r"'", Keyword), # a stray quote is another syntax element

            (r'"', String.Double, 'string'),

            (r'[~?][a-z][\w\']*:', Name.Variable),
        ],
        'comment': [
            (r'[^(*)]+', Comment),
            (r'\(\*', Comment, '#push'),
            (r'\*\)', Comment, '#pop'),
            (r'[(*)]', Comment),
        ],
        'string': [
            (r'[^\\"]+', String.Double),
            include('escape-sequence'),
            (r'\\\n', String.Double),
            (r'"', String.Double, '#pop'),
        ],
        'dotted': [
            (r'\s+', Text),
            (r'\.', Punctuation),
            (r'[A-Z][A-Za-z0-9_\']*(?=\s*\.)', Name.Namespace),
            (r'[A-Z][A-Za-z0-9_\']*', Name.Class, '#pop'),
            (r'[a-z][a-z0-9_\']*', Name, '#pop'),
        ],
    }


class ErlangLexer(RegexLexer):
    """
    For the Erlang functional programming language.

    Blame Jeremy Thurgood (http://jerith.za.net/).

    *New in Pygments 0.9.*
    """

    name = 'Erlang'
    aliases = ['erlang']
    filenames = ['*.erl', '*.hrl']
    mimetypes = ['text/x-erlang']

    keywords = [
        'after', 'begin', 'case', 'catch', 'cond', 'end', 'fun', 'if',
        'let', 'of', 'query', 'receive', 'try', 'when',
        ]

    builtins = [ # See erlang(3) man page
        'abs', 'append_element', 'apply', 'atom_to_list', 'binary_to_list',
        'bitstring_to_list', 'binary_to_term', 'bit_size', 'bump_reductions',
        'byte_size', 'cancel_timer', 'check_process_code', 'delete_module',
        'demonitor', 'disconnect_node', 'display', 'element', 'erase', 'exit',
        'float', 'float_to_list', 'fun_info', 'fun_to_list',
        'function_exported', 'garbage_collect', 'get', 'get_keys',
        'group_leader', 'hash', 'hd', 'integer_to_list', 'iolist_to_binary',
        'iolist_size', 'is_atom', 'is_binary', 'is_bitstring', 'is_boolean',
        'is_builtin', 'is_float', 'is_function', 'is_integer', 'is_list',
        'is_number', 'is_pid', 'is_port', 'is_process_alive', 'is_record',
        'is_reference', 'is_tuple', 'length', 'link', 'list_to_atom',
        'list_to_binary', 'list_to_bitstring', 'list_to_existing_atom',
        'list_to_float', 'list_to_integer', 'list_to_pid', 'list_to_tuple',
        'load_module', 'localtime_to_universaltime', 'make_tuple', 'md5',
        'md5_final', 'md5_update', 'memory', 'module_loaded', 'monitor',
        'monitor_node', 'node', 'nodes', 'open_port', 'phash', 'phash2',
        'pid_to_list', 'port_close', 'port_command', 'port_connect',
        'port_control', 'port_call', 'port_info', 'port_to_list',
        'process_display', 'process_flag', 'process_info', 'purge_module',
        'put', 'read_timer', 'ref_to_list', 'register', 'resume_process',
        'round', 'send', 'send_after', 'send_nosuspend', 'set_cookie',
        'setelement', 'size', 'spawn', 'spawn_link', 'spawn_monitor',
        'spawn_opt', 'split_binary', 'start_timer', 'statistics',
        'suspend_process', 'system_flag', 'system_info', 'system_monitor',
        'system_profile', 'term_to_binary', 'tl', 'trace', 'trace_delivered',
        'trace_info', 'trace_pattern', 'trunc', 'tuple_size', 'tuple_to_list',
        'universaltime_to_localtime', 'unlink', 'unregister', 'whereis'
        ]

    operators = r'(\+|-|\*|/|<|>|=|==|/=|=:=|=/=|=<|>=|\+\+|--|<-|!)'
    word_operators = [
        'and', 'andalso', 'band', 'bnot', 'bor', 'bsl', 'bsr', 'bxor',
        'div', 'not', 'or', 'orelse', 'rem', 'xor'
        ]

    atom_re = r"(?:[a-z][a-zA-Z0-9_]*|'[^\n']*[^\\]')"

    variable_re = r'(?:[A-Z_][a-zA-Z0-9_]*)'

    escape_re = r'(?:\\(?:[bdefnrstv\'"\\/]|[0-7][0-7]?[0-7]?|\^[a-zA-Z]))'

    macro_re = r'(?:'+variable_re+r'|'+atom_re+r')'

    base_re = r'(?:[2-9]|[12][0-9]|3[0-6])'

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'%.*\n', Comment),
            ('(' + '|'.join(keywords) + r')\b', Keyword),
            ('(' + '|'.join(builtins) + r')\b', Name.Builtin),
            ('(' + '|'.join(word_operators) + r')\b', Operator.Word),
            (r'^-', Punctuation, 'directive'),
            (operators, Operator),
            (r'"', String, 'string'),
            (r'<<', Name.Label),
            (r'>>', Name.Label),
            (r'('+atom_re+')(:)', bygroups(Name.Namespace, Punctuation)),
            (r'^('+atom_re+r')(\s*)(\()', bygroups(Name.Function, Text, Punctuation)),
            (r'[+-]?'+base_re+r'#[0-9a-zA-Z]+', Number.Integer),
            (r'[+-]?\d+', Number.Integer),
            (r'[+-]?\d+.\d+', Number.Float),
            (r'[][:_@\".{}()|;,]', Punctuation),
            (variable_re, Name.Variable),
            (atom_re, Name),
            (r'\?'+macro_re, Name.Constant),
            (r'\$(?:'+escape_re+r'|\\[ %]|[^\\])', String.Char),
            (r'#'+atom_re+r'(:?\.'+atom_re+r')?', Name.Label),
            ],
        'string': [
            (escape_re, String.Escape),
            (r'"', String, '#pop'),
            (r'~[0-9.*]*[~#+bBcdefginpPswWxX]', String.Interpol),
            (r'[^"\\~]+', String),
            (r'~', String),
            ],
        'directive': [
            (r'(define)(\s*)(\()('+macro_re+r')',
             bygroups(Name.Entity, Text, Punctuation, Name.Constant), '#pop'),
            (r'(record)(\s*)(\()('+macro_re+r')',
             bygroups(Name.Entity, Text, Punctuation, Name.Label), '#pop'),
            (atom_re, Name.Entity, '#pop'),
            ],
        }


class ErlangShellLexer(Lexer):
    """
    Shell sessions in erl (for Erlang code).

    *New in Pygments 1.1.*
    """
    name = 'Erlang erl session'
    aliases = ['erl']
    filenames = ['*.erl-sh']
    mimetypes = ['text/x-erl-shellsession']

    _prompt_re = re.compile(r'\d+>(?=\s|\Z)')

    def get_tokens_unprocessed(self, text):
        erlexer = ErlangLexer(**self.options)

        curcode = ''
        insertions = []
        for match in line_re.finditer(text):
            line = match.group()
            m = self._prompt_re.match(line)
            if m is not None:
                end = m.end()
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, line[:end])]))
                curcode += line[end:]
            else:
                if curcode:
                    for item in do_insertions(insertions,
                                    erlexer.get_tokens_unprocessed(curcode)):
                        yield item
                    curcode = ''
                    insertions = []
                if line.startswith('*'):
                    yield match.start(), Generic.Traceback, line
                else:
                    yield match.start(), Generic.Output, line
        if curcode:
            for item in do_insertions(insertions,
                                      erlexer.get_tokens_unprocessed(curcode)):
                yield item

# -*- coding: utf-8 -*-
"""
    pygments.lexers.math
    ~~~~~~~~~~~~~~~~~~~~

    Lexers for math languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.lexer import Lexer, RegexLexer, bygroups, include, do_insertions
from pygments.token import Comment, String, Punctuation, Keyword, Name, \
    Operator, Number, Text, Generic

from pygments.lexers.agile import PythonLexer

__all__ = ['MuPADLexer', 'MatlabLexer', 'MatlabSessionLexer', 'NumPyLexer',
           'SLexer']


class MuPADLexer(RegexLexer):
    """
    A `MuPAD <http://www.mupad.com>`_ lexer.
    Contributed by Christopher Creutzig <christopher@creutzig.de>.

    *New in Pygments 0.8.*
    """
    name = 'MuPAD'
    aliases = ['mupad']
    filenames = ['*.mu']

    tokens = {
      'root' : [
        (r'//.*?$', Comment.Single),
        (r'/\*', Comment.Multiline, 'comment'),
        (r'"(?:[^"\\]|\\.)*"', String),
        (r'\(|\)|\[|\]|\{|\}', Punctuation),
        (r'''(?x)\b(?:
            next|break|end|
            axiom|end_axiom|category|end_category|domain|end_domain|inherits|
            if|%if|then|elif|else|end_if|
            case|of|do|otherwise|end_case|
            while|end_while|
            repeat|until|end_repeat|
            for|from|to|downto|step|end_for|
            proc|local|option|save|begin|end_proc|
            delete|frame
          )\b''', Keyword),
        (r'''(?x)\b(?:
            DOM_ARRAY|DOM_BOOL|DOM_COMPLEX|DOM_DOMAIN|DOM_EXEC|DOM_EXPR|
            DOM_FAIL|DOM_FLOAT|DOM_FRAME|DOM_FUNC_ENV|DOM_HFARRAY|DOM_IDENT|
            DOM_INT|DOM_INTERVAL|DOM_LIST|DOM_NIL|DOM_NULL|DOM_POLY|DOM_PROC|
            DOM_PROC_ENV|DOM_RAT|DOM_SET|DOM_STRING|DOM_TABLE|DOM_VAR
          )\b''', Name.Class),
        (r'''(?x)\b(?:
            PI|EULER|E|CATALAN|
            NIL|FAIL|undefined|infinity|
            TRUE|FALSE|UNKNOWN
          )\b''',
          Name.Constant),
        (r'\b(?:dom|procname)\b', Name.Builtin.Pseudo),
        (r'\.|,|:|;|=|\+|-|\*|/|\^|@|>|<|\$|\||!|\'|%|~=', Operator),
        (r'''(?x)\b(?:
            and|or|not|xor|
            assuming|
            div|mod|
            union|minus|intersect|in|subset
          )\b''',
          Operator.Word),
        (r'\b(?:I|RDN_INF|RD_NINF|RD_NAN)\b', Number),
        #(r'\b(?:adt|linalg|newDomain|hold)\b', Name.Builtin),
        (r'''(?x)
          ((?:[a-zA-Z_#][a-zA-Z_#0-9]*|`[^`]*`)
          (?:::[a-zA-Z_#][a-zA-Z_#0-9]*|`[^`]*`)*)\s*([(])''',
          bygroups(Name.Function, Punctuation)),
        (r'''(?x)
          (?:[a-zA-Z_#][a-zA-Z_#0-9]*|`[^`]*`)
          (?:::[a-zA-Z_#][a-zA-Z_#0-9]*|`[^`]*`)*''', Name.Variable),
        (r'[0-9]+(?:\.[0-9]*)?(?:e[0-9]+)?', Number),
        (r'\.[0-9]+(?:e[0-9]+)?', Number),
        (r'.', Text)
      ],
      'comment' : [
        (r'[^*/]', Comment.Multiline),
        (r'/\*', Comment.Multiline, '#push'),
        (r'\*/', Comment.Multiline, '#pop'),
        (r'[*/]', Comment.Multiline)
      ]
    }


class MatlabLexer(RegexLexer):
    """
    For Matlab (or GNU Octave) source code.
    Contributed by Ken Schutte <kschutte@csail.mit.edu>.

    *New in Pygments 0.10.*
    """
    name = 'Matlab'
    aliases = ['matlab', 'octave']
    filenames = ['*.m']
    mimetypes = ['text/matlab']

    #
    # These lists are generated automatically.
    # Run the following in bash shell:
    #
    # for f in elfun specfun elmat; do
    #   echo -n "$f = "
    #   matlab -nojvm -r "help $f;exit;" | perl -ne \
    #   'push(@c,$1) if /^    (\w+)\s+-/; END {print q{["}.join(q{","},@c).qq{"]\n};}'
    # done
    #
    # elfun: Elementary math functions
    # specfun: Special Math functions
    # elmat: Elementary matrices and matrix manipulation
    #
    # taken from Matlab version 7.4.0.336 (R2007a)
    #
    elfun = ["sin","sind","sinh","asin","asind","asinh","cos","cosd","cosh",
             "acos","acosd","acosh","tan","tand","tanh","atan","atand","atan2",
             "atanh","sec","secd","sech","asec","asecd","asech","csc","cscd",
             "csch","acsc","acscd","acsch","cot","cotd","coth","acot","acotd",
             "acoth","hypot","exp","expm1","log","log1p","log10","log2","pow2",
             "realpow","reallog","realsqrt","sqrt","nthroot","nextpow2","abs",
             "angle","complex","conj","imag","real","unwrap","isreal","cplxpair",
             "fix","floor","ceil","round","mod","rem","sign"]
    specfun = ["airy","besselj","bessely","besselh","besseli","besselk","beta",
               "betainc","betaln","ellipj","ellipke","erf","erfc","erfcx",
               "erfinv","expint","gamma","gammainc","gammaln","psi","legendre",
               "cross","dot","factor","isprime","primes","gcd","lcm","rat",
               "rats","perms","nchoosek","factorial","cart2sph","cart2pol",
               "pol2cart","sph2cart","hsv2rgb","rgb2hsv"]
    elmat = ["zeros","ones","eye","repmat","rand","randn","linspace","logspace",
             "freqspace","meshgrid","accumarray","size","length","ndims","numel",
             "disp","isempty","isequal","isequalwithequalnans","cat","reshape",
             "diag","blkdiag","tril","triu","fliplr","flipud","flipdim","rot90",
             "find","end","sub2ind","ind2sub","bsxfun","ndgrid","permute",
             "ipermute","shiftdim","circshift","squeeze","isscalar","isvector",
             "ans","eps","realmax","realmin","pi","i","inf","nan","isnan",
             "isinf","isfinite","j","why","compan","gallery","hadamard","hankel",
             "hilb","invhilb","magic","pascal","rosser","toeplitz","vander",
             "wilkinson"]

    tokens = {
        'root': [
            # line starting with '!' is sent as a system command.  not sure what
            # label to use...
            (r'^!.*', String.Other),
            (r'%.*$', Comment),
            (r'^\s*function', Keyword, 'deffunc'),

            # from 'iskeyword' on version 7.4.0.336 (R2007a):
            (r'(break|case|catch|classdef|continue|else|elseif|end|for|function|'
             r'global|if|otherwise|parfor|persistent|return|switch|try|while)\b',
             Keyword),

            ("(" + "|".join(elfun+specfun+elmat) + r')\b',  Name.Builtin),

            # operators:
            (r'-|==|~=|<|>|<=|>=|&&|&|~', Operator),
            # operators requiring escape for re:
            (r'\.\*|\*|\+|\.\^|\.\\|\.\/|\/|\\', Operator),

            # punctuation:
            (r'\[|\]|\(|\)|\{|\}|:|@|\.|,', Punctuation),
            (r'=|:|;', Punctuation),

            # quote can be transpose, instead of string:
            # (not great, but handles common cases...)
            (r'([\w\)\]]+)(\')', bygroups(Text, Operator)),

            (r'\'', String, 'string'),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name),
            (r'.', Text),
        ],
        'string': [
            (r'[^\']*\'', String, '#pop')
        ],
        'deffunc': [
            (r'(\s*)(.+)(\s*)(=)(\s*)(.+)(\()(.*)(\))(\s*)',
             bygroups(Text.Whitespace, Text, Text.Whitespace, Punctuation,
                      Text.Whitespace, Name.Function, Punctuation, Text,
                      Punctuation, Text.Whitespace), '#pop'),
        ],
    }

    def analyse_text(text):
        if re.match('^\s*%', text, re.M): # comment
            return 0.9
        elif re.match('^!\w+', text, re.M): # system cmd
            return 0.9
        return 0.1

line_re  = re.compile('.*?\n')

class MatlabSessionLexer(Lexer):
    """
    For Matlab (or GNU Octave) sessions.  Modeled after PythonConsoleLexer.
    Contributed by Ken Schutte <kschutte@csail.mit.edu>.

    *New in Pygments 0.10.*
    """
    name = 'Matlab session'
    aliases = ['matlabsession']

    def get_tokens_unprocessed(self, text):
        mlexer = MatlabLexer(**self.options)

        curcode = ''
        insertions = []

        for match in line_re.finditer(text):
            line = match.group()

            if line.startswith('>>'):
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, line[:3])]))
                curcode += line[3:]

            elif line.startswith('???'):

                idx = len(curcode)

                # without is showing error on same line as before...?
                line = "\n" + line
                token = (0, Generic.Traceback, line)
                insertions.append(  (idx, [token,]) )

            else:
                if curcode:
                    for item in do_insertions(
                        insertions, mlexer.get_tokens_unprocessed(curcode)):
                        yield item
                    curcode = ''
                    insertions = []

                yield match.start(), Generic.Output, line

        if curcode: # or item:
            for item in do_insertions(
                insertions, mlexer.get_tokens_unprocessed(curcode)):
                yield item


class NumPyLexer(PythonLexer):
    '''
    A Python lexer recognizing Numerical Python builtins.

    *New in Pygments 0.10.*
    '''

    name = 'NumPy'
    aliases = ['numpy']

    # override the mimetypes to not inherit them from python
    mimetypes = []
    filenames = []

    EXTRA_KEYWORDS = set([
        'abs', 'absolute', 'accumulate', 'add', 'alen', 'all', 'allclose',
        'alltrue', 'alterdot', 'amax', 'amin', 'angle', 'any', 'append',
        'apply_along_axis', 'apply_over_axes', 'arange', 'arccos', 'arccosh',
        'arcsin', 'arcsinh', 'arctan', 'arctan2', 'arctanh', 'argmax', 'argmin',
        'argsort', 'argwhere', 'around', 'array', 'array2string', 'array_equal',
        'array_equiv', 'array_repr', 'array_split', 'array_str', 'arrayrange',
        'asanyarray', 'asarray', 'asarray_chkfinite', 'ascontiguousarray',
        'asfarray', 'asfortranarray', 'asmatrix', 'asscalar', 'astype',
        'atleast_1d', 'atleast_2d', 'atleast_3d', 'average', 'bartlett',
        'base_repr', 'beta', 'binary_repr', 'bincount', 'binomial',
        'bitwise_and', 'bitwise_not', 'bitwise_or', 'bitwise_xor', 'blackman',
        'bmat', 'broadcast', 'byte_bounds', 'bytes', 'byteswap', 'c_',
        'can_cast', 'ceil', 'choose', 'clip', 'column_stack', 'common_type',
        'compare_chararrays', 'compress', 'concatenate', 'conj', 'conjugate',
        'convolve', 'copy', 'corrcoef', 'correlate', 'cos', 'cosh', 'cov',
        'cross', 'cumprod', 'cumproduct', 'cumsum', 'delete', 'deprecate',
        'diag', 'diagflat', 'diagonal', 'diff', 'digitize', 'disp', 'divide',
        'dot', 'dsplit', 'dstack', 'dtype', 'dump', 'dumps', 'ediff1d', 'empty',
        'empty_like', 'equal', 'exp', 'expand_dims', 'expm1', 'extract', 'eye',
        'fabs', 'fastCopyAndTranspose', 'fft', 'fftfreq', 'fftshift', 'fill',
        'finfo', 'fix', 'flat', 'flatnonzero', 'flatten', 'fliplr', 'flipud',
        'floor', 'floor_divide', 'fmod', 'frexp', 'fromarrays', 'frombuffer',
        'fromfile', 'fromfunction', 'fromiter', 'frompyfunc', 'fromstring',
        'generic', 'get_array_wrap', 'get_include', 'get_numarray_include',
        'get_numpy_include', 'get_printoptions', 'getbuffer', 'getbufsize',
        'geterr', 'geterrcall', 'geterrobj', 'getfield', 'gradient', 'greater',
        'greater_equal', 'gumbel', 'hamming', 'hanning', 'histogram',
        'histogram2d', 'histogramdd', 'hsplit', 'hstack', 'hypot', 'i0',
        'identity', 'ifft', 'imag', 'index_exp', 'indices', 'inf', 'info',
        'inner', 'insert', 'int_asbuffer', 'interp', 'intersect1d',
        'intersect1d_nu', 'inv', 'invert', 'iscomplex', 'iscomplexobj',
        'isfinite', 'isfortran', 'isinf', 'isnan', 'isneginf', 'isposinf',
        'isreal', 'isrealobj', 'isscalar', 'issctype', 'issubclass_',
        'issubdtype', 'issubsctype', 'item', 'itemset', 'iterable', 'ix_',
        'kaiser', 'kron', 'ldexp', 'left_shift', 'less', 'less_equal', 'lexsort',
        'linspace', 'load', 'loads', 'loadtxt', 'log', 'log10', 'log1p', 'log2',
        'logical_and', 'logical_not', 'logical_or', 'logical_xor', 'logspace',
        'lstsq', 'mat', 'matrix', 'max', 'maximum', 'maximum_sctype',
        'may_share_memory', 'mean', 'median', 'meshgrid', 'mgrid', 'min',
        'minimum', 'mintypecode', 'mod', 'modf', 'msort', 'multiply', 'nan',
        'nan_to_num', 'nanargmax', 'nanargmin', 'nanmax', 'nanmin', 'nansum',
        'ndenumerate', 'ndim', 'ndindex', 'negative', 'newaxis', 'newbuffer',
        'newbyteorder', 'nonzero', 'not_equal', 'obj2sctype', 'ogrid', 'ones',
        'ones_like', 'outer', 'permutation', 'piecewise', 'pinv', 'pkgload',
        'place', 'poisson', 'poly', 'poly1d', 'polyadd', 'polyder', 'polydiv',
        'polyfit', 'polyint', 'polymul', 'polysub', 'polyval', 'power', 'prod',
        'product', 'ptp', 'put', 'putmask', 'r_', 'randint', 'random_integers',
        'random_sample', 'ranf', 'rank', 'ravel', 'real', 'real_if_close',
        'recarray', 'reciprocal', 'reduce', 'remainder', 'repeat', 'require',
        'reshape', 'resize', 'restoredot', 'right_shift', 'rint', 'roll',
        'rollaxis', 'roots', 'rot90', 'round', 'round_', 'row_stack', 's_',
        'sample', 'savetxt', 'sctype2char', 'searchsorted', 'seed', 'select',
        'set_numeric_ops', 'set_printoptions', 'set_string_function',
        'setbufsize', 'setdiff1d', 'seterr', 'seterrcall', 'seterrobj',
        'setfield', 'setflags', 'setmember1d', 'setxor1d', 'shape',
        'show_config', 'shuffle', 'sign', 'signbit', 'sin', 'sinc', 'sinh',
        'size', 'slice', 'solve', 'sometrue', 'sort', 'sort_complex', 'source',
        'split', 'sqrt', 'square', 'squeeze', 'standard_normal', 'std',
        'subtract', 'sum', 'svd', 'swapaxes', 'take', 'tan', 'tanh', 'tensordot',
        'test', 'tile', 'tofile', 'tolist', 'tostring', 'trace', 'transpose',
        'trapz', 'tri', 'tril', 'trim_zeros', 'triu', 'true_divide', 'typeDict',
        'typename', 'uniform', 'union1d', 'unique', 'unique1d', 'unravel_index',
        'unwrap', 'vander', 'var', 'vdot', 'vectorize', 'view', 'vonmises',
        'vsplit', 'vstack', 'weibull', 'where', 'who', 'zeros', 'zeros_like'
    ])

    def get_tokens_unprocessed(self, text):
        for index, token, value in \
                PythonLexer.get_tokens_unprocessed(self, text):
            if token is Name and value in self.EXTRA_KEYWORDS:
                yield index, Keyword.Pseudo, value
            else:
                yield index, token, value


class SLexer(RegexLexer):
    """
    For S, S-plus, and R source code.

    *New in Pygments 0.10.*
    """

    name = 'S'
    aliases = ['splus', 's', 'r']
    filenames = ['*.S', '*.R']
    mimetypes = ['text/S-plus', 'text/S', 'text/R']

    tokens = {
        'comments': [
            (r'#.*$', Comment.Single),
        ],
        'valid_name': [
            (r'[a-zA-Z][0-9a-zA-Z\._]+', Text),
            (r'`.+`', String.Backtick),
        ],
        'punctuation': [
            (r'\[|\]|\[\[|\]\]|\$|\(|\)|@|:::?|;|,', Punctuation),
        ],
        'keywords': [
            (r'for(?=\s*\()|while(?=\s*\()|if(?=\s*\()|(?<=\s)else|'
             r'(?<=\s)break(?=;|$)|return(?=\s*\()|function(?=\s*\()',
             Keyword.Reserved)
        ],
        'operators': [
            (r'<-|-|==|<=|>=|<|>|&&|&|!=', Operator),
            (r'\*|\+|\^|/|%%|%/%|=', Operator),
            (r'%in%|%*%', Operator)
        ],
        'builtin_symbols': [
            (r'NULL|NA|TRUE|FALSE', Keyword.Constant),
        ],
        'numbers': [
            (r'(?<![0-9a-zA-Z\)\}\]`\"])(?=\s*)[-\+]?[0-9]+'
             r'(\.[0-9]*)?(E[0-9][-\+]?(\.[0-9]*)?)?', Number),
        ],
        'statements': [
            include('comments'),
            # whitespaces
            (r'\s+', Text),
            (r'\"', String, 'string_dquote'),
            include('builtin_symbols'),
            include('numbers'),
            include('keywords'),
            include('punctuation'),
            include('operators'),
            include('valid_name'),
        ],
        'root': [
            include('statements'),
            # blocks:
            (r'\{|\}', Punctuation),
            #(r'\{', Punctuation, 'block'),
            (r'.', Text),
        ],
        #'block': [
        #    include('statements'),
        #    ('\{', Punctuation, '#push'),
        #    ('\}', Punctuation, '#pop')
        #],
        'string_dquote': [
            (r'[^\"]*\"', String, '#pop'),
        ],
    }

    def analyse_text(text):
        return '<-' in text
# -*- coding: utf-8 -*-
"""
    pygments.lexers.other
    ~~~~~~~~~~~~~~~~~~~~~

    Lexers for other languages.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re

from pygments.lexer import Lexer, RegexLexer, include, bygroups, using, \
     this, do_insertions
from pygments.token import Error, Punctuation, \
     Text, Comment, Operator, Keyword, Name, String, Number, Generic
from pygments.util import shebang_matches
from pygments.lexers.web import HtmlLexer


__all__ = ['SqlLexer', 'MySqlLexer', 'SqliteConsoleLexer', 'BrainfuckLexer',
           'BashLexer', 'BatchLexer', 'BefungeLexer', 'RedcodeLexer',
           'MOOCodeLexer', 'SmalltalkLexer', 'TcshLexer', 'LogtalkLexer',
           'GnuplotLexer', 'PovrayLexer', 'AppleScriptLexer',
           'BashSessionLexer', 'ModelicaLexer', 'RebolLexer', 'ABAPLexer']

line_re  = re.compile('.*?\n')


class SqlLexer(RegexLexer):
    """
    Lexer for Structured Query Language. Currently, this lexer does
    not recognize any special syntax except ANSI SQL.
    """

    name = 'SQL'
    aliases = ['sql']
    filenames = ['*.sql']
    mimetypes = ['text/x-sql']

    flags = re.IGNORECASE
    tokens = {
        'root': [
            (r'\s+', Text),
            (r'--.*?\n', Comment.Single),
            (r'/\*', Comment.Multiline, 'multiline-comments'),
            (r'(ABORT|ABS|ABSOLUTE|ACCESS|ADA|ADD|ADMIN|AFTER|AGGREGATE|'
             r'ALIAS|ALL|ALLOCATE|ALTER|ANALYSE|ANALYZE|AND|ANY|ARE|AS|'
             r'ASC|ASENSITIVE|ASSERTION|ASSIGNMENT|ASYMMETRIC|AT|ATOMIC|'
             r'AUTHORIZATION|AVG|BACKWARD|BEFORE|BEGIN|BETWEEN|BITVAR|'
             r'BIT_LENGTH|BOTH|BREADTH|BY|C|CACHE|CALL|CALLED|CARDINALITY|'
             r'CASCADE|CASCADED|CASE|CAST|CATALOG|CATALOG_NAME|CHAIN|'
             r'CHARACTERISTICS|CHARACTER_LENGTH|CHARACTER_SET_CATALOG|'
             r'CHARACTER_SET_NAME|CHARACTER_SET_SCHEMA|CHAR_LENGTH|CHECK|'
             r'CHECKED|CHECKPOINT|CLASS|CLASS_ORIGIN|CLOB|CLOSE|CLUSTER|'
             r'COALSECE|COBOL|COLLATE|COLLATION|COLLATION_CATALOG|'
             r'COLLATION_NAME|COLLATION_SCHEMA|COLUMN|COLUMN_NAME|'
             r'COMMAND_FUNCTION|COMMAND_FUNCTION_CODE|COMMENT|COMMIT|'
             r'COMMITTED|COMPLETION|CONDITION_NUMBER|CONNECT|CONNECTION|'
             r'CONNECTION_NAME|CONSTRAINT|CONSTRAINTS|CONSTRAINT_CATALOG|'
             r'CONSTRAINT_NAME|CONSTRAINT_SCHEMA|CONSTRUCTOR|CONTAINS|'
             r'CONTINUE|CONVERSION|CONVERT|COPY|CORRESPONTING|COUNT|'
             r'CREATE|CREATEDB|CREATEUSER|CROSS|CUBE|CURRENT|CURRENT_DATE|'
             r'CURRENT_PATH|CURRENT_ROLE|CURRENT_TIME|CURRENT_TIMESTAMP|'
             r'CURRENT_USER|CURSOR|CURSOR_NAME|CYCLE|DATA|DATABASE|'
             r'DATETIME_INTERVAL_CODE|DATETIME_INTERVAL_PRECISION|DAY|'
             r'DEALLOCATE|DECLARE|DEFAULT|DEFAULTS|DEFERRABLE|DEFERRED|'
             r'DEFINED|DEFINER|DELETE|DELIMITER|DELIMITERS|DEREF|DESC|'
             r'DESCRIBE|DESCRIPTOR|DESTROY|DESTRUCTOR|DETERMINISTIC|'
             r'DIAGNOSTICS|DICTIONARY|DISCONNECT|DISPATCH|DISTINCT|DO|'
             r'DOMAIN|DROP|DYNAMIC|DYNAMIC_FUNCTION|DYNAMIC_FUNCTION_CODE|'
             r'EACH|ELSE|ENCODING|ENCRYPTED|END|END-EXEC|EQUALS|ESCAPE|EVERY|'
             r'EXCEPT|ESCEPTION|EXCLUDING|EXCLUSIVE|EXEC|EXECUTE|EXISTING|'
             r'EXISTS|EXPLAIN|EXTERNAL|EXTRACT|FALSE|FETCH|FINAL|FIRST|FOR|'
             r'FORCE|FOREIGN|FORTRAN|FORWARD|FOUND|FREE|FREEZE|FROM|FULL|'
             r'FUNCTION|G|GENERAL|GENERATED|GET|GLOBAL|GO|GOTO|GRANT|GRANTED|'
             r'GROUP|GROUPING|HANDLER|HAVING|HIERARCHY|HOLD|HOST|IDENTITY|'
             r'IGNORE|ILIKE|IMMEDIATE|IMMUTABLE|IMPLEMENTATION|IMPLICIT|IN|'
             r'INCLUDING|INCREMENT|INDEX|INDITCATOR|INFIX|INHERITS|INITIALIZE|'
             r'INITIALLY|INNER|INOUT|INPUT|INSENSITIVE|INSERT|INSTANTIABLE|'
             r'INSTEAD|INTERSECT|INTO|INVOKER|IS|ISNULL|ISOLATION|ITERATE|JOIN|'
             r'K|KEY|KEY_MEMBER|KEY_TYPE|LANCOMPILER|LANGUAGE|LARGE|LAST|'
             r'LATERAL|LEADING|LEFT|LENGTH|LESS|LEVEL|LIKE|LILMIT|LISTEN|LOAD|'
             r'LOCAL|LOCALTIME|LOCALTIMESTAMP|LOCATION|LOCATOR|LOCK|LOWER|M|'
             r'MAP|MATCH|MAX|MAXVALUE|MESSAGE_LENGTH|MESSAGE_OCTET_LENGTH|'
             r'MESSAGE_TEXT|METHOD|MIN|MINUTE|MINVALUE|MOD|MODE|MODIFIES|'
             r'MODIFY|MONTH|MORE|MOVE|MUMPS|NAMES|NATIONAL|NATURAL|NCHAR|'
             r'NCLOB|NEW|NEXT|NO|NOCREATEDB|NOCREATEUSER|NONE|NOT|NOTHING|'
             r'NOTIFY|NOTNULL|NULL|NULLABLE|NULLIF|OBJECT|OCTET_LENGTH|OF|OFF|'
             r'OFFSET|OIDS|OLD|ON|ONLY|OPEN|OPERATION|OPERATOR|OPTION|OPTIONS|'
             r'OR|ORDER|ORDINALITY|OUT|OUTER|OUTPUT|OVERLAPS|OVERLAY|OVERRIDING|'
             r'OWNER|PAD|PARAMETER|PARAMETERS|PARAMETER_MODE|PARAMATER_NAME|'
             r'PARAMATER_ORDINAL_POSITION|PARAMETER_SPECIFIC_CATALOG|'
             r'PARAMETER_SPECIFIC_NAME|PARAMATER_SPECIFIC_SCHEMA|PARTIAL|'
             r'PASCAL|PENDANT|PLACING|PLI|POSITION|POSTFIX|PRECISION|PREFIX|'
             r'PREORDER|PREPARE|PRESERVE|PRIMARY|PRIOR|PRIVILEGES|PROCEDURAL|'
             r'PROCEDURE|PUBLIC|READ|READS|RECHECK|RECURSIVE|REF|REFERENCES|'
             r'REFERENCING|REINDEX|RELATIVE|RENAME|REPEATABLE|REPLACE|RESET|'
             r'RESTART|RESTRICT|RESULT|RETURN|RETURNED_LENGTH|'
             r'RETURNED_OCTET_LENGTH|RETURNED_SQLSTATE|RETURNS|REVOKE|RIGHT|'
             r'ROLE|ROLLBACK|ROLLUP|ROUTINE|ROUTINE_CATALOG|ROUTINE_NAME|'
             r'ROUTINE_SCHEMA|ROW|ROWS|ROW_COUNT|RULE|SAVE_POINT|SCALE|SCHEMA|'
             r'SCHEMA_NAME|SCOPE|SCROLL|SEARCH|SECOND|SECURITY|SELECT|SELF|'
             r'SENSITIVE|SERIALIZABLE|SERVER_NAME|SESSION|SESSION_USER|SET|'
             r'SETOF|SETS|SHARE|SHOW|SIMILAR|SIMPLE|SIZE|SOME|SOURCE|SPACE|'
             r'SPECIFIC|SPECIFICTYPE|SPECIFIC_NAME|SQL|SQLCODE|SQLERROR|'
             r'SQLEXCEPTION|SQLSTATE|SQLWARNINIG|STABLE|START|STATE|STATEMENT|'
             r'STATIC|STATISTICS|STDIN|STDOUT|STORAGE|STRICT|STRUCTURE|STYPE|'
             r'SUBCLASS_ORIGIN|SUBLIST|SUBSTRING|SUM|SYMMETRIC|SYSID|SYSTEM|'
             r'SYSTEM_USER|TABLE|TABLE_NAME| TEMP|TEMPLATE|TEMPORARY|TERMINATE|'
             r'THAN|THEN|TIMESTAMP|TIMEZONE_HOUR|TIMEZONE_MINUTE|TO|TOAST|'
             r'TRAILING|TRANSATION|TRANSACTIONS_COMMITTED|'
             r'TRANSACTIONS_ROLLED_BACK|TRANSATION_ACTIVE|TRANSFORM|'
             r'TRANSFORMS|TRANSLATE|TRANSLATION|TREAT|TRIGGER|TRIGGER_CATALOG|'
             r'TRIGGER_NAME|TRIGGER_SCHEMA|TRIM|TRUE|TRUNCATE|TRUSTED|TYPE|'
             r'UNCOMMITTED|UNDER|UNENCRYPTED|UNION|UNIQUE|UNKNOWN|UNLISTEN|'
             r'UNNAMED|UNNEST|UNTIL|UPDATE|UPPER|USAGE|USER|'
             r'USER_DEFINED_TYPE_CATALOG|USER_DEFINED_TYPE_NAME|'
             r'USER_DEFINED_TYPE_SCHEMA|USING|VACUUM|VALID|VALIDATOR|VALUES|'
             r'VARIABLE|VERBOSE|VERSION|VIEW|VOLATILE|WHEN|WHENEVER|WHERE|'
             r'WITH|WITHOUT|WORK|WRITE|YEAR|ZONE)\b', Keyword),
            (r'(ARRAY|BIGINT|BINARY|BIT|BLOB|BOOLEAN|CHAR|CHARACTER|DATE|'
             r'DEC|DECIMAL|FLOAT|INT|INTEGER|INTERVAL|NUMBER|NUMERIC|REAL|'
             r'SERIAL|SMALLINT|VARCHAR|VARYING|INT8|SERIAL8|TEXT)\b',
             Name.Builtin),
            (r'[+*/<>=~!@#%^&|`?^-]', Operator),
            (r'[0-9]+', Number.Integer),
            # TODO: Backslash escapes?
            (r"'(''|[^'])*'", String.Single),
            (r'"(""|[^"])*"', String.Symbol), # not a real string literal in ANSI SQL
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name),
            (r'[;:()\[\],\.]', Punctuation)
        ],
        'multiline-comments': [
            (r'/\*', Comment.Multiline, 'multiline-comments'),
            (r'\*/', Comment.Multiline, '#pop'),
            (r'[^/\*]+', Comment.Multiline),
            (r'[/*]', Comment.Multiline)
        ]
    }


class MySqlLexer(RegexLexer):
    """
    Special lexer for MySQL.
    """

    name = 'MySQL'
    aliases = ['mysql']
    mimetypes = ['text/x-mysql']

    flags = re.IGNORECASE
    tokens = {
        'root': [
            (r'\s+', Text),
            (r'(#|--\s+).*?\n', Comment.Single),
            (r'/\*', Comment.Multiline, 'multiline-comments'),
            (r'[0-9]+', Number.Integer),
            (r'[0-9]*\.[0-9]+(e[+-][0-9]+)', Number.Float),
            # TODO: add backslash escapes
            (r"'(''|[^'])*'", String.Single),
            (r'"(""|[^"])*"', String.Double),
            (r"`(``|[^`])*`", String.Symbol),
            (r'[+*/<>=~!@#%^&|`?^-]', Operator),
            (r'\b(tinyint|smallint|mediumint|int|integer|bigint|date|'
             r'datetime|time|bit|bool|tinytext|mediumtext|longtext|text|'
             r'tinyblob|mediumblob|longblob|blob|float|double|double\s+'
             r'precision|real|numeric|dec|decimal|timestamp|year|char|'
             r'varchar|varbinary|varcharacter|enum|set)(\b\s*)(\()?',
             bygroups(Keyword.Type, Text, Punctuation)),
            (r'\b(add|all|alter|analyze|and|as|asc|asensitive|before|between|'
             r'bigint|binary|blob|both|by|call|cascade|case|change|char|'
             r'character|check|collate|column|condition|constraint|continue|'
             r'convert|create|cross|current_date|current_time|'
             r'current_timestamp|current_user|cursor|database|databases|'
             r'day_hour|day_microsecond|day_minute|day_second|dec|decimal|'
             r'declare|default|delayed|delete|desc|describe|deterministic|'
             r'distinct|distinctrow|div|double|drop|dual|each|else|elseif|'
             r'enclosed|escaped|exists|exit|explain|fetch|float|float4|float8'
             r'|for|force|foreign|from|fulltext|grant|group|having|'
             r'high_priority|hour_microsecond|hour_minute|hour_second|if|'
             r'ignore|in|index|infile|inner|inout|insensitive|insert|int|'
             r'int1|int2|int3|int4|int8|integer|interval|into|is|iterate|'
             r'join|key|keys|kill|leading|leave|left|like|limit|lines|load|'
             r'localtime|localtimestamp|lock|long|loop|low_priority|match|'
             r'minute_microsecond|minute_second|mod|modifies|natural|'
             r'no_write_to_binlog|not|numeric|on|optimize|option|optionally|'
             r'or|order|out|outer|outfile|precision|primary|procedure|purge|'
             r'raid0|read|reads|real|references|regexp|release|rename|repeat|'
             r'replace|require|restrict|return|revoke|right|rlike|schema|'
             r'schemas|second_microsecond|select|sensitive|separator|set|'
             r'show|smallint|soname|spatial|specific|sql|sql_big_result|'
             r'sql_calc_found_rows|sql_small_result|sqlexception|sqlstate|'
             r'sqlwarning|ssl|starting|straight_join|table|terminated|then|'
             r'to|trailing|trigger|undo|union|unique|unlock|unsigned|update|'
             r'usage|use|using|utc_date|utc_time|utc_timestamp|values|'
             r'varying|when|where|while|with|write|x509|xor|year_month|'
             r'zerofill)\b', Keyword),
            # TODO: this list is not complete
            (r'\b(auto_increment|engine|charset|tables)\b', Keyword.Pseudo),
            (r'(true|false|null)', Name.Constant),
            (r'([a-zA-Z_][a-zA-Z0-9_]*)(\s*)(\()',
             bygroups(Name.Function, Text, Punctuation)),
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name),
            (r'@[A-Za-z0-9]*[._]*[A-Za-z0-9]*', Name.Variable),
            (r'[;:()\[\],\.]', Punctuation)
        ],
        'multiline-comments': [
            (r'/\*', Comment.Multiline, 'multiline-comments'),
            (r'\*/', Comment.Multiline, '#pop'),
            (r'[^/\*]+', Comment.Multiline),
            (r'[/*]', Comment.Multiline)
        ]
    }


class SqliteConsoleLexer(Lexer):
    """
    Lexer for example sessions using sqlite3.

    *New in Pygments 0.11.*
    """

    name = 'sqlite3con'
    aliases = ['sqlite3']
    filenames = ['*.sqlite3-console']
    mimetypes = ['text/x-sqlite3-console']

    def get_tokens_unprocessed(self, data):
        sql = SqlLexer(**self.options)

        curcode = ''
        insertions = []
        for match in line_re.finditer(data):
            line = match.group()
            if line.startswith('sqlite> ') or line.startswith('   ...> '):
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, line[:8])]))
                curcode += line[8:]
            else:
                if curcode:
                    for item in do_insertions(insertions,
                                              sql.get_tokens_unprocessed(curcode)):
                        yield item
                    curcode = ''
                    insertions = []
                if line.startswith('SQL error: '):
                    yield (match.start(), Generic.Traceback, line)
                else:
                    yield (match.start(), Generic.Output, line)
        if curcode:
            for item in do_insertions(insertions,
                                      sql.get_tokens_unprocessed(curcode)):
                yield item


class BrainfuckLexer(RegexLexer):
    """
    Lexer for the esoteric `BrainFuck <http://www.muppetlabs.com/~breadbox/bf/>`_
    language.
    """

    name = 'Brainfuck'
    aliases = ['brainfuck', 'bf']
    filenames = ['*.bf', '*.b']
    mimetypes = ['application/x-brainfuck']

    tokens = {
        'common': [
            # use different colors for different instruction types
            (r'[.,]+', Name.Tag),
            (r'[+-]+', Name.Builtin),
            (r'[<>]+', Name.Variable),
            (r'[^.,+\-<>\[\]]+', Comment),
        ],
        'root': [
            (r'\[', Keyword, 'loop'),
            (r'\]', Error),
            include('common'),
        ],
        'loop': [
            (r'\[', Keyword, '#push'),
            (r'\]', Keyword, '#pop'),
            include('common'),
        ]
    }


class BefungeLexer(RegexLexer):
    """
    Lexer for the esoteric `Befunge <http://en.wikipedia.org/wiki/Befunge>`_
    language.

    *New in Pygments 0.7.*
    """
    name = 'Befunge'
    aliases = ['befunge']
    filenames = ['*.befunge']
    mimetypes = ['application/x-befunge']

    tokens = {
        'root': [
            (r'[0-9a-f]', Number),
            (r'[\+\*/%!`-]', Operator), # Traditional math
            (r'[<>^v?\[\]rxjk]', Name.Variable), # Move, imperatives
            (r'[:\\$.,n]', Name.Builtin), # Stack ops, imperatives
            (r'[|_mw]', Keyword),
            (r'[{}]', Name.Tag), # Befunge-98 stack ops
            (r'".*?"', String.Double), # Strings don't appear to allow escapes
            (r'\'.', String.Single), # Single character
            (r'[#;]', Comment), # Trampoline... depends on direction hit
            (r'[pg&~=@iotsy]', Keyword), # Misc
            (r'[()A-Z]', Comment), # Fingerprints
            (r'\s+', Text), # Whitespace doesn't matter
        ],
    }



class BashLexer(RegexLexer):
    """
    Lexer for (ba)sh shell scripts.

    *New in Pygments 0.6.*
    """

    name = 'Bash'
    aliases = ['bash', 'sh']
    filenames = ['*.sh']
    mimetypes = ['application/x-sh', 'application/x-shellscript']

    tokens = {
        'root': [
            include('basic'),
            (r'\$\(\(', Keyword, 'math'),
            (r'\$\(', Keyword, 'paren'),
            (r'\${#?', Keyword, 'curly'),
            (r'`', String.Backtick, 'backticks'),
            include('data'),
        ],
        'basic': [
            (r'\b(if|fi|else|while|do|done|for|then|return|function|case|'
             r'select|continue|until|esac|elif)\s*\b',
             Keyword),
            (r'\b(alias|bg|bind|break|builtin|caller|cd|command|compgen|'
             r'complete|declare|dirs|disown|echo|enable|eval|exec|exit|'
             r'export|false|fc|fg|getopts|hash|help|history|jobs|kill|let|'
             r'local|logout|popd|printf|pushd|pwd|read|readonly|set|shift|'
             r'shopt|source|suspend|test|time|times|trap|true|type|typeset|'
             r'ulimit|umask|unalias|unset|wait)\s*\b(?!\.)',
             Name.Builtin),
            (r'#.*\n', Comment),
            (r'\\[\w\W]', String.Escape),
            (r'(\b\w+)(\s*)(=)', bygroups(Name.Variable, Text, Operator)),
            (r'[\[\]{}()=]', Operator),
            (r'<<\s*(\'?)\\?(\w+)[\w\W]+?\2', String),
            (r'&&|\|\|', Operator),
        ],
        'data': [
            (r'\$?"(\\\\|\\[0-7]+|\\.|[^"])*"', String.Double),
            (r"\$?'(\\\\|\\[0-7]+|\\.|[^'])*'", String.Single),
            (r';', Text),
            (r'\s+', Text),
            (r'[^=\s\n\[\]{}()$"\'`\\<]+', Text),
            (r'\d+(?= |\Z)', Number),
            (r'\$#?(\w+|.)', Name.Variable),
            (r'<', Text),
        ],
        'curly': [
            (r'}', Keyword, '#pop'),
            (r':-', Keyword),
            (r'[a-zA-Z0-9_]+', Name.Variable),
            (r'[^}:"\'`$]+', Punctuation),
            (r':', Punctuation),
            include('root'),
        ],
        'paren': [
            (r'\)', Keyword, '#pop'),
            include('root'),
        ],
        'math': [
            (r'\)\)', Keyword, '#pop'),
            (r'[-+*/%^|&]|\*\*|\|\|', Operator),
            (r'\d+', Number),
            include('root'),
        ],
        'backticks': [
            (r'`', String.Backtick, '#pop'),
            include('root'),
        ],
    }

    def analyse_text(text):
        return shebang_matches(text, r'(ba|z|)sh')


class BashSessionLexer(Lexer):
    """
    Lexer for simplistic shell sessions.

    *New in Pygments 1.1.*
    """

    name = 'Bash Session'
    aliases = ['console']
    filenames = ['*.sh-session']
    mimetypes = ['application/x-shell-session']

    def get_tokens_unprocessed(self, text):
        bashlexer = BashLexer(**self.options)

        pos = 0
        curcode = ''
        insertions = []

        for match in line_re.finditer(text):
            line = match.group()
            m = re.match(r'^((?:|sh\S*?|\w+\S+[@:]\S+(?:\s+\S+)?|\[\S+[@:]'
                         r'[^\n]+\].+)[$#%])(.*\n?)', line)
            if m:
                # To support output lexers (say diff output), the output
                # needs to be broken by prompts whenever the output lexer
                # changes.
                if not insertions:
                    pos = match.start()

                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, m.group(1))]))
                curcode += m.group(2)
            elif line.startswith('>'):
                insertions.append((len(curcode),
                                   [(0, Generic.Prompt, line[:1])]))
                curcode += line[1:]
            else:
                if insertions:
                    toks = bashlexer.get_tokens_unprocessed(curcode)
                    for i, t, v in do_insertions(insertions, toks):
                        yield pos+i, t, v
                yield match.start(), Generic.Output, line
                insertions = []
                curcode = ''
        if insertions:
            for i, t, v in do_insertions(insertions,
                                         bashlexer.get_tokens_unprocessed(curcode)):
                yield pos+i, t, v


class BatchLexer(RegexLexer):
    """
    Lexer for the DOS/Windows Batch file format.

    *New in Pygments 0.7.*
    """
    name = 'Batchfile'
    aliases = ['bat']
    filenames = ['*.bat', '*.cmd']
    mimetypes = ['application/x-dos-batch']

    flags = re.MULTILINE | re.IGNORECASE

    tokens = {
        'root': [
            # Lines can start with @ to prevent echo
            (r'^\s*@', Punctuation),
            (r'^(\s*)(rem\s.*)$', bygroups(Text, Comment)),
            (r'".*?"', String.Double),
            (r"'.*?'", String.Single),
            # If made more specific, make sure you still allow expansions
            # like %~$VAR:zlt
            (r'%%?[~$:\w]+%?', Name.Variable),
            (r'::.*', Comment), # Technically :: only works at BOL
            (r'(set)(\s+)(\w+)', bygroups(Keyword, Text, Name.Variable)),
            (r'(call)(\s+)(:\w+)', bygroups(Keyword, Text, Name.Label)),
            (r'(goto)(\s+)(\w+)', bygroups(Keyword, Text, Name.Label)),
            (r'\b(set|call|echo|on|off|endlocal|for|do|goto|if|pause|'
             r'setlocal|shift|errorlevel|exist|defined|cmdextversion|'
             r'errorlevel|else|cd|md|del|deltree|cls|choice)\b', Keyword),
            (r'\b(equ|neq|lss|leq|gtr|geq)\b', Operator),
            include('basic'),
            (r'.', Text),
        ],
        'echo': [
            # Escapes only valid within echo args?
            (r'\^\^|\^<|\^>|\^\|', String.Escape),
            (r'\n', Text, '#pop'),
            include('basic'),
            (r'[^\'"^]+', Text),
        ],
        'basic': [
            (r'".*?"', String.Double),
            (r"'.*?'", String.Single),
            (r'`.*?`', String.Backtick),
            (r'-?\d+', Number),
            (r',', Punctuation),
            (r'=', Operator),
            (r'/\S+', Name),
            (r':\w+', Name.Label),
            (r'\w:\w+', Text),
            (r'([<>|])(\s*)(\w+)', bygroups(Punctuation, Text, Name)),
        ],
    }


class RedcodeLexer(RegexLexer):
    """
    A simple Redcode lexer based on ICWS'94.
    Contributed by Adam Blinkinsop <blinks@acm.org>.

    *New in Pygments 0.8.*
    """
    name = 'Redcode'
    aliases = ['redcode']
    filenames = ['*.cw']

    opcodes = ['DAT','MOV','ADD','SUB','MUL','DIV','MOD',
               'JMP','JMZ','JMN','DJN','CMP','SLT','SPL',
               'ORG','EQU','END']
    modifiers = ['A','B','AB','BA','F','X','I']

    tokens = {
        'root': [
            # Whitespace:
            (r'\s+', Text),
            (r';.*$', Comment.Single),
            # Lexemes:
            #  Identifiers
            (r'\b(%s)\b' % '|'.join(opcodes), Name.Function),
            (r'\b(%s)\b' % '|'.join(modifiers), Name.Decorator),
            (r'[A-Za-z_][A-Za-z_0-9]+', Name),
            #  Operators
            (r'[-+*/%]', Operator),
            (r'[#$@<>]', Operator), # mode
            (r'[.,]', Punctuation), # mode
            #  Numbers
            (r'[-+]?\d+', Number.Integer),
        ],
    }


class MOOCodeLexer(RegexLexer):
    """
    For `MOOCode <http://www.moo.mud.org/>`_ (the MOO scripting
    language).

    *New in Pygments 0.9.*
    """
    name = 'MOOCode'
    filenames = ['*.moo']
    aliases = ['moocode']
    mimetypes = ['text/x-moocode']

    tokens = {
        'root' : [
            # Numbers
            (r'(0|[1-9][0-9_]*)', Number.Integer),
            # Strings
            (r'"(\\\\|\\"|[^"])*"', String),
            # exceptions
            (r'(E_PERM|E_DIV)', Name.Exception),
            # db-refs
            (r'((#[-0-9]+)|(\$[a-z_A-Z0-9]+))', Name.Entity),
            # Keywords
            (r'\b(if|else|elseif|endif|for|endfor|fork|endfork|while'
             r'|endwhile|break|continue|return|try'
             r'|except|endtry|finally|in)\b', Keyword),
            # builtins
            (r'(random|length)', Name.Builtin),
            # special variables
            (r'(player|caller|this|args)', Name.Variable.Instance),
            # skip whitespace
            (r'\s+', Text),
            (r'\n', Text),
            # other operators
            (r'([!;=,{}&\|:\.\[\]@\(\)\<\>\?]+)', Operator),
            # function call
            (r'([a-z_A-Z0-9]+)(\()', bygroups(Name.Function, Operator)),
            # variables
            (r'([a-zA-Z_0-9]+)', Text),
        ]
    }


class SmalltalkLexer(RegexLexer):
    """
    For `Smalltalk <http://www.smalltalk.org/>`_ syntax.
    Contributed by Stefan Matthias Aust.
    Rewritten by Nils Winter.

    *New in Pygments 0.10.*
    """
    name = 'Smalltalk'
    filenames = ['*.st']
    aliases = ['smalltalk', 'squeak']
    mimetypes = ['text/x-smalltalk']

    tokens = {
        'root' : [
            (r'(<)(\w+:)(.*?)(>)', bygroups(Text, Keyword, Text, Text)),
            include('squeak fileout'),
            include('whitespaces'),
            include('method definition'),
            (r'(\|)([\w\s]*)(\|)', bygroups(Operator, Name.Variable, Operator)),
            include('objects'),
            (r'\^|\:=|\_', Operator),
            # temporaries
            (r'[\]({}.;!]', Text),

        ],
        'method definition' : [
            # Not perfect can't allow whitespaces at the beginning and the
            # without breaking everything
            (r'([a-zA-Z]+\w*:)(\s*)(\w+)',
             bygroups(Name.Function, Text, Name.Variable)),
            (r'^(\b[a-zA-Z]+\w*\b)(\s*)$', bygroups(Name.Function, Text)),
            (r'^([-+*/\\~<>=|&!?,@%]+)(\s*)(\w+)(\s*)$',
             bygroups(Name.Function, Text, Name.Variable, Text)),
        ],
        'blockvariables' : [
            include('whitespaces'),
            (r'(:)(\s*)([A-Za-z\w]+)',
             bygroups(Operator, Text, Name.Variable)),
            (r'\|', Operator, '#pop'),
            (r'', Text, '#pop'), # else pop
        ],
        'literals' : [
            (r'\'[^\']*\'', String, 'afterobject'),
            (r'\$.', String.Char, 'afterobject'),
            (r'#\(', String.Symbol, 'parenth'),
            (r'\)', Text, 'afterobject'),
            (r'(\d+r)?-?\d+(\.\d+)?(e-?\d+)?', Number, 'afterobject'),
        ],
        '_parenth_helper' : [
            include('whitespaces'),
            (r'[-+*/\\~<>=|&#!?,@%\w+:]+', String.Symbol),
            # literals
            (r'\'[^\']*\'', String),
            (r'\$.', String.Char),
            (r'(\d+r)?-?\d+(\.\d+)?(e-?\d+)?', Number),
            (r'#*\(', String.Symbol, 'inner_parenth'),
        ],
        'parenth' : [
            # This state is a bit tricky since
            # we can't just pop this state
            (r'\)', String.Symbol, ('root','afterobject')),
            include('_parenth_helper'),
        ],
        'inner_parenth': [
            (r'\)', String.Symbol, '#pop'),
            include('_parenth_helper'),
        ],
        'whitespaces' : [
            # skip whitespace and comments
            (r'\s+', Text),
            (r'"[^"]*"', Comment),
        ],
        'objects' : [
            (r'\[', Text, 'blockvariables'),
            (r'\]', Text, 'afterobject'),
            (r'\b(self|super|true|false|nil|thisContext)\b',
             Name.Builtin.Pseudo, 'afterobject'),
            (r'\b[A-Z]\w*(?!:)\b', Name.Class, 'afterobject'),
            (r'\b[a-z]\w*(?!:)\b', Name.Variable, 'afterobject'),
            (r'#("[^"]*"|[-+*/\\~<>=|&!?,@%]+|[\w:]+)',
             String.Symbol, 'afterobject'),
            include('literals'),
        ],
        'afterobject' : [
            (r'! !$', Keyword , '#pop'), # squeak chunk delimeter
            include('whitespaces'),
            (r'\b(ifTrue:|ifFalse:|whileTrue:|whileFalse:|timesRepeat:)',
             Name.Builtin, '#pop'),
            (r'\b(new\b(?!:))', Name.Builtin),
            (r'\:=|\_', Operator, '#pop'),
            (r'\b[a-zA-Z]+\w*:', Name.Function, '#pop'),
            (r'\b[a-zA-Z]+\w*', Name.Function),
            (r'\w+:?|[-+*/\\~<>=|&!?,@%]+', Name.Function, '#pop'),
            (r'\.', Punctuation, '#pop'),
            (r';', Punctuation),
            (r'[\])}]', Text),
            (r'[\[({]', Text, '#pop'),
        ],
        'squeak fileout' : [
            # Squeak fileout format (optional)
            (r'^"[^"]*"!', Keyword),
            (r"^'[^']*'!", Keyword),
            (r'^(!)(\w+)( commentStamp: )(.*?)( prior: .*?!\n)(.*?)(!)',
                bygroups(Keyword, Name.Class, Keyword, String, Keyword, Text, Keyword)),
            (r'^(!)(\w+(?: class)?)( methodsFor: )(\'[^\']*\')(.*?!)',
                bygroups(Keyword, Name.Class, Keyword, String, Keyword)),
            (r'^(\w+)( subclass: )(#\w+)'
             r'(\s+instanceVariableNames: )(.*?)'
             r'(\s+classVariableNames: )(.*?)'
             r'(\s+poolDictionaries: )(.*?)'
             r'(\s+category: )(.*?)(!)',
                bygroups(Name.Class, Keyword, String.Symbol, Keyword, String, Keyword,
                         String, Keyword, String, Keyword, String, Keyword)),
            (r'^(\w+(?: class)?)(\s+instanceVariableNames: )(.*?)(!)',
                bygroups(Name.Class, Keyword, String, Keyword)),
            (r'(!\n)(\].*)(! !)$', bygroups(Keyword, Text, Keyword)),
            (r'! !$', Keyword),
        ],
    }


class TcshLexer(RegexLexer):
    """
    Lexer for tcsh scripts.

    *New in Pygments 0.10.*
    """

    name = 'Tcsh'
    aliases = ['tcsh', 'csh']
    filenames = ['*.tcsh', '*.csh']
    mimetypes = ['application/x-csh']

    tokens = {
        'root': [
            include('basic'),
            (r'\$\(', Keyword, 'paren'),
            (r'\${#?', Keyword, 'curly'),
            (r'`', String.Backtick, 'backticks'),
            include('data'),
        ],
        'basic': [
            (r'\b(if|endif|else|while|then|foreach|case|default|'
             r'continue|goto|breaksw|end|switch|endsw)\s*\b',
             Keyword),
            (r'\b(alias|alloc|bg|bindkey|break|builtins|bye|caller|cd|chdir|'
             r'complete|dirs|echo|echotc|eval|exec|exit|'
             r'fg|filetest|getxvers|glob|getspath|hashstat|history|hup|inlib|jobs|kill|'
             r'limit|log|login|logout|ls-F|migrate|newgrp|nice|nohup|notify|'
             r'onintr|popd|printenv|pushd|rehash|repeat|rootnode|popd|pushd|set|shift|'
             r'sched|setenv|setpath|settc|setty|setxvers|shift|source|stop|suspend|'
             r'source|suspend|telltc|time|'
             r'umask|unalias|uncomplete|unhash|universe|unlimit|unset|unsetenv|'
             r'ver|wait|warp|watchlog|where|which)\s*\b',
             Name.Builtin),
            (r'#.*\n', Comment),
            (r'\\[\w\W]', String.Escape),
            (r'(\b\w+)(\s*)(=)', bygroups(Name.Variable, Text, Operator)),
            (r'[\[\]{}()=]+', Operator),
            (r'<<\s*(\'?)\\?(\w+)[\w\W]+?\2', String),
        ],
        'data': [
            (r'"(\\\\|\\[0-7]+|\\.|[^"])*"', String.Double),
            (r"'(\\\\|\\[0-7]+|\\.|[^'])*'", String.Single),
            (r'\s+', Text),
            (r'[^=\s\n\[\]{}()$"\'`\\]+', Text),
            (r'\d+(?= |\Z)', Number),
            (r'\$#?(\w+|.)', Name.Variable),
        ],
        'curly': [
            (r'}', Keyword, '#pop'),
            (r':-', Keyword),
            (r'[a-zA-Z0-9_]+', Name.Variable),
            (r'[^}:"\'`$]+', Punctuation),
            (r':', Punctuation),
            include('root'),
        ],
        'paren': [
            (r'\)', Keyword, '#pop'),
            include('root'),
        ],
        'backticks': [
            (r'`', String.Backtick, '#pop'),
            include('root'),
        ],
    }


class LogtalkLexer(RegexLexer):
    """
    For `Logtalk <http://logtalk.org/>`_ source code.

    *New in Pygments 0.10.*
    """

    name = 'Logtalk'
    aliases = ['logtalk']
    filenames = ['*.lgt']
    mimetypes = ['text/x-logtalk']

    tokens = {
        'root': [
            # Directives
            (r'^\s*:-\s',Punctuation,'directive'),
            # Comments
            (r'%.*?\n', Comment),
            (r'/\*(.|\n)*?\*/',Comment),
            # Whitespace
            (r'\n', Text),
            (r'\s+', Text),
            # Numbers
            (r"0'.", Number),
            (r'0b[01]+', Number),
            (r'0o[0-7]+', Number),
            (r'0x[0-9a-fA-F]+', Number),
            (r'\d+\.?\d*((e|E)(\+|-)?\d+)?', Number),
            # Variables
            (r'([A-Z_][a-zA-Z0-9_]*)', Name.Variable),
            # Event handlers
            (r'(after|before)(?=[(])', Keyword),
            # Execution-context methods
            (r'(parameter|this|se(lf|nder))(?=[(])', Keyword),
            # Reflection
            (r'(current_predicate|predicate_property)(?=[(])', Keyword),
            # DCGs and term expansion
            (r'(expand_term|(goal|term)_expansion|phrase)(?=[(])', Keyword),
            # Entity
            (r'(abolish|c(reate|urrent))_(object|protocol|category)(?=[(])',
             Keyword),
            (r'(object|protocol|category)_property(?=[(])', Keyword),
            # Entity relations
            (r'complements_object(?=[(])', Keyword),
            (r'extends_(object|protocol|category)(?=[(])', Keyword),
            (r'imp(lements_protocol|orts_category)(?=[(])', Keyword),
            (r'(instantiat|specializ)es_class(?=[(])', Keyword),
            # Events
            (r'(current_event|(abolish|define)_events)(?=[(])', Keyword),
            # Flags
            (r'(current|set)_logtalk_flag(?=[(])', Keyword),
            # Compiling, loading, and library paths
            (r'logtalk_(compile|l(ibrary_path|oad))(?=[(])', Keyword),
            # Database
            (r'(clause|retract(all)?)(?=[(])', Keyword),
            (r'a(bolish|ssert(a|z))(?=[(])', Keyword),
            # Control
            (r'(ca(ll|tch)|throw)(?=[(])', Keyword),
            (r'(fail|true)\b', Keyword),
            # All solutions
            (r'((bag|set)of|f(ind|or)all)(?=[(])', Keyword),
            # Multi-threading meta-predicates
            (r'threaded(_(call|once|ignore|exit|peek|wait|notify))?(?=[(])',
             Keyword),
            # Term unification
            (r'unify_with_occurs_check(?=[(])', Keyword),
            # Term creation and decomposition
            (r'(functor|arg|copy_term)(?=[(])', Keyword),
            # Evaluable functors
            (r'(rem|mod|abs|sign)(?=[(])', Keyword),
            (r'float(_(integer|fractional)_part)?(?=[(])', Keyword),
            (r'(floor|truncate|round|ceiling)(?=[(])', Keyword),
            # Other arithmetic functors
            (r'(cos|atan|exp|log|s(in|qrt))(?=[(])', Keyword),
            # Term testing
            (r'(var|atom(ic)?|integer|float|compound|n(onvar|umber))(?=[(])',
             Keyword),
            # Stream selection and control
            (r'(curren|se)t_(in|out)put(?=[(])', Keyword),
            (r'(open|close)(?=[(])', Keyword),
            (r'flush_output(?=[(])', Keyword),
            (r'(at_end_of_stream|flush_output)\b', Keyword),
            (r'(stream_property|at_end_of_stream|set_stream_position)(?=[(])',
             Keyword),
            # Character and byte input/output
            (r'(nl|(get|peek|put)_(byte|c(har|ode)))(?=[(])', Keyword),
            (r'\bnl\b', Keyword),
            # Term input/output
            (r'read(_term)?(?=[(])', Keyword),
            (r'write(q|_(canonical|term))?(?=[(])', Keyword),
            (r'(current_)?op(?=[(])', Keyword),
            (r'(current_)?char_conversion(?=[(])', Keyword),
            # Atomic term processing
            (r'atom_(length|c(hars|o(ncat|des)))(?=[(])', Keyword),
            (r'(char_code|sub_atom)(?=[(])', Keyword),
            (r'number_c(har|ode)s(?=[(])', Keyword),
            # Implementation defined hooks functions
            (r'(se|curren)t_prolog_flag(?=[(])', Keyword),
            (r'\bhalt\b', Keyword),
            (r'halt(?=[(])', Keyword),
            # Message sending operators
            (r'(::|:|\^\^)', Operator),
            # External call
            (r'[{}]', Keyword),
            # Logic and control
            (r'\bonce(?=[(])', Keyword),
            (r'\brepeat\b', Keyword),
            # Bitwise functors
            (r'(>>|<<|/\\|\\\\|\\)', Operator),
            # Arithemtic evaluation
            (r'\bis\b', Keyword),
            # Arithemtic comparison
            (r'(=:=|=\\=|<|=<|>=|>)', Operator),
            # Term creation and decomposition
            (r'=\.\.', Operator),
            # Term unification
            (r'(=|\\=)', Operator),
            # Term comparison
            (r'(==|\\==|@=<|@<|@>=|@>)', Operator),
            # Evaluable functors
            (r'(//|[-+*/])', Operator),
            (r'\b(mod|rem)\b', Operator),
            # Other arithemtic functors
            (r'\b\*\*\b', Operator),
            # DCG rules
            (r'-->', Operator),
            # Control constructs
            (r'([!;]|->)', Operator),
            # Logic and control
            (r'\\+', Operator),
            # Mode operators
            (r'[?@]', Operator),
            # Strings
            (r'"(\\\\|\\"|[^"])*"', String),
            # Ponctuation
            (r'[()\[\],.|]', Text),
            # Atoms
            (r"[a-z][a-zA-Z0-9_]*", Text),
            (r"[']", String, 'quoted_atom'),
        ],

        'quoted_atom': [
            (r"['][']", String),
            (r"[']", String, '#pop'),
            (r'\\([\\abfnrtv"\']|(x[a-fA-F0-9]+|[0-7]+)\\)', String.Escape),
            (r"[^\\'\n]+", String),
            (r'\\', String),
        ],

        'directive': [
            # Entity directives
            (r'(category|object|protocol)(?=[(])', Keyword, 'entityrelations'),
            (r'(end_(category|object|protocol))[.]',Keyword, 'root'),
            # Predicate scope directives
            (r'(public|protected|private)(?=[(])', Keyword, 'root'),
            # Other directives
            (r'e(ncoding|xport)(?=[(])', Keyword, 'root'),
            (r'in(fo|itialization)(?=[(])', Keyword, 'root'),
            (r'(dynamic|synchronized|threaded)[.]', Keyword, 'root'),
            (r'(alias|d(ynamic|iscontiguous)|m(eta_predicate|ode|ultifile)'
             r'|synchronized)(?=[(])', Keyword, 'root'),
            (r'op(?=[(])', Keyword, 'root'),
            (r'(calls|use(s|_module))(?=[(])', Keyword, 'root'),
            (r'[a-z][a-zA-Z0-9_]*(?=[(])', Text, 'root'),
            (r'[a-z][a-zA-Z0-9_]*[.]', Text, 'root'),
        ],

        'entityrelations': [
            (r'(extends|i(nstantiates|mp(lements|orts))|specializes)(?=[(])',
             Keyword),
            # Numbers
            (r"0'.", Number),
            (r'0b[01]+', Number),
            (r'0o[0-7]+', Number),
            (r'0x[0-9a-fA-F]+', Number),
            (r'\d+\.?\d*((e|E)(\+|-)?\d+)?', Number),
            # Variables
            (r'([A-Z_][a-zA-Z0-9_]*)', Name.Variable),
            # Atoms
            (r"[a-z][a-zA-Z0-9_]*", Text),
            (r"[']", String, 'quoted_atom'),
            # Strings
            (r'"(\\\\|\\"|[^"])*"', String),
            # End of entity-opening directive
            (r'([)]\.)', Text, 'root'),
            # Scope operator
            (r'(::)', Operator),
            # Ponctuation
            (r'[()\[\],.|]', Text),
            # Comments
            (r'%.*?\n', Comment),
            (r'/\*(.|\n)*?\*/',Comment),
            # Whitespace
            (r'\n', Text),
            (r'\s+', Text),
        ]
    }


def _shortened(word):
    dpos = word.find('$')
    return '|'.join([word[:dpos] + word[dpos+1:i] + r'\b'
                     for i in range(len(word), dpos, -1)])
def _shortened_many(*words):
    return '|'.join(map(_shortened, words))

class GnuplotLexer(RegexLexer):
    """
    For `Gnuplot <http://gnuplot.info/>`_ plotting scripts.

    *New in Pygments 0.11.*
    """

    name = 'Gnuplot'
    aliases = ['gnuplot']
    filenames = ['*.plot', '*.plt']
    mimetypes = ['text/x-gnuplot']

    tokens = {
        'root': [
            include('whitespace'),
            (_shortened('bi$nd'), Keyword, 'bind'),
            (_shortened_many('ex$it', 'q$uit'), Keyword, 'quit'),
            (_shortened('f$it'), Keyword, 'fit'),
            (r'(if)(\s*)(\()', bygroups(Keyword, Text, Punctuation), 'if'),
            (r'else\b', Keyword),
            (_shortened('pa$use'), Keyword, 'pause'),
            (_shortened_many('p$lot', 'rep$lot', 'sp$lot'), Keyword, 'plot'),
            (_shortened('sa$ve'), Keyword, 'save'),
            (_shortened('se$t'), Keyword, ('genericargs', 'optionarg')),
            (_shortened_many('sh$ow', 'uns$et'),
             Keyword, ('noargs', 'optionarg')),
            (_shortened_many('low$er', 'ra$ise', 'ca$ll', 'cd$', 'cl$ear',
                             'h$elp', '\\?$', 'hi$story', 'l$oad', 'pr$int',
                             'pwd$', 're$read', 'res$et', 'scr$eendump',
                             'she$ll', 'sy$stem', 'up$date'),
             Keyword, 'genericargs'),
            (_shortened_many('pwd$', 're$read', 'res$et', 'scr$eendump',
                             'she$ll', 'test$'),
             Keyword, 'noargs'),
            ('([a-zA-Z_][a-zA-Z0-9_]*)(\s*)(=)',
             bygroups(Name.Variable, Text, Operator), 'genericargs'),
            ('([a-zA-Z_][a-zA-Z0-9_]*)(\s*\(.*?\)\s*)(=)',
             bygroups(Name.Function, Text, Operator), 'genericargs'),
            (r'@[a-zA-Z_][a-zA-Z0-9_]*', Name.Constant), # macros
            (r';', Keyword),
        ],
        'comment': [
            (r'[^\\\n]', Comment),
            (r'\\\n', Comment),
            (r'\\', Comment),
            # don't add the newline to the Comment token
            ('', Comment, '#pop'),
        ],
        'whitespace': [
            ('#', Comment, 'comment'),
            (r'[ \t\v\f]+', Text),
        ],
        'noargs': [
            include('whitespace'),
            # semicolon and newline end the argument list
            (r';', Punctuation, '#pop'),
            (r'\n', Text, '#pop'),
        ],
        'dqstring': [
            (r'"', String, '#pop'),
            (r'\\([\\abfnrtv"\']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})', String.Escape),
            (r'[^\\"\n]+', String), # all other characters
            (r'\\\n', String), # line continuation
            (r'\\', String), # stray backslash
            (r'\n', String, '#pop'), # newline ends the string too
        ],
        'sqstring': [
            (r"''", String), # escaped single quote
            (r"'", String, '#pop'),
            (r"[^\\'\n]+", String), # all other characters
            (r'\\\n', String), # line continuation
            (r'\\', String), # normal backslash
            (r'\n', String, '#pop'), # newline ends the string too
        ],
        'genericargs': [
            include('noargs'),
            (r'"', String, 'dqstring'),
            (r"'", String, 'sqstring'),
            (r'(\d+\.\d*|\.\d+|\d+)[eE][+-]?\d+', Number.Float),
            (r'(\d+\.\d*|\.\d+)', Number.Float),
            (r'-?\d+', Number.Integer),
            ('[,.~!%^&*+=|?:<>/-]', Operator),
            ('[{}()\[\]]', Punctuation),
            (r'(eq|ne)\b', Operator.Word),
            (r'([a-zA-Z_][a-zA-Z0-9_]*)(\s*)(\()',
             bygroups(Name.Function, Text, Punctuation)),
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name),
            (r'@[a-zA-Z_][a-zA-Z0-9_]*', Name.Constant), # macros
            (r'\\\n', Text),
        ],
        'optionarg': [
            include('whitespace'),
            (_shortened_many(
                "a$ll","an$gles","ar$row","au$toscale","b$ars","bor$der",
                "box$width","cl$abel","c$lip","cn$trparam","co$ntour","da$ta",
                "data$file","dg$rid3d","du$mmy","enc$oding","dec$imalsign",
                "fit$","font$path","fo$rmat","fu$nction","fu$nctions","g$rid",
                "hid$den3d","his$torysize","is$osamples","k$ey","keyt$itle",
                "la$bel","li$nestyle","ls$","loa$dpath","loc$ale","log$scale",
                "mac$ros","map$ping","map$ping3d","mar$gin","lmar$gin",
                "rmar$gin","tmar$gin","bmar$gin","mo$use","multi$plot",
                "mxt$ics","nomxt$ics","mx2t$ics","nomx2t$ics","myt$ics",
                "nomyt$ics","my2t$ics","nomy2t$ics","mzt$ics","nomzt$ics",
                "mcbt$ics","nomcbt$ics","of$fsets","or$igin","o$utput",
                "pa$rametric","pm$3d","pal$ette","colorb$ox","p$lot",
                "poi$ntsize","pol$ar","pr$int","obj$ect","sa$mples","si$ze",
                "st$yle","su$rface","table$","t$erminal","termo$ptions","ti$cs",
                "ticsc$ale","ticsl$evel","timef$mt","tim$estamp","tit$le",
                "v$ariables","ve$rsion","vi$ew","xyp$lane","xda$ta","x2da$ta",
                "yda$ta","y2da$ta","zda$ta","cbda$ta","xl$abel","x2l$abel",
                "yl$abel","y2l$abel","zl$abel","cbl$abel","xti$cs","noxti$cs",
                "x2ti$cs","nox2ti$cs","yti$cs","noyti$cs","y2ti$cs","noy2ti$cs",
                "zti$cs","nozti$cs","cbti$cs","nocbti$cs","xdti$cs","noxdti$cs",
                "x2dti$cs","nox2dti$cs","ydti$cs","noydti$cs","y2dti$cs",
                "noy2dti$cs","zdti$cs","nozdti$cs","cbdti$cs","nocbdti$cs",
                "xmti$cs","noxmti$cs","x2mti$cs","nox2mti$cs","ymti$cs",
                "noymti$cs","y2mti$cs","noy2mti$cs","zmti$cs","nozmti$cs",
                "cbmti$cs","nocbmti$cs","xr$ange","x2r$ange","yr$ange",
                "y2r$ange","zr$ange","cbr$ange","rr$ange","tr$ange","ur$ange",
                "vr$ange","xzeroa$xis","x2zeroa$xis","yzeroa$xis","y2zeroa$xis",
                "zzeroa$xis","zeroa$xis","z$ero"), Name.Builtin, '#pop'),
        ],
        'bind': [
            ('!', Keyword, '#pop'),
            (_shortened('all$windows'), Name.Builtin),
            include('genericargs'),
        ],
        'quit': [
            (r'gnuplot\b', Keyword),
            include('noargs'),
        ],
        'fit': [
            (r'via\b', Name.Builtin),
            include('plot'),
        ],
        'if': [
            (r'\)', Punctuation, '#pop'),
            include('genericargs'),
        ],
        'pause': [
            (r'(mouse|any|button1|button2|button3)\b', Name.Builtin),
            (_shortened('key$press'), Name.Builtin),
            include('genericargs'),
        ],
        'plot': [
            (_shortened_many('ax$es', 'axi$s', 'bin$ary', 'ev$ery', 'i$ndex',
                             'mat$rix', 's$mooth', 'thru$', 't$itle',
                             'not$itle', 'u$sing', 'w$ith'),
             Name.Builtin),
            include('genericargs'),
        ],
        'save': [
            (_shortened_many('f$unctions', 's$et', 't$erminal', 'v$ariables'),
             Name.Builtin),
            include('genericargs'),
        ],
    }


class PovrayLexer(RegexLexer):
    """
    For `Persistence of Vision Raytracer <http://www.povray.org/>`_ files.

    *New in Pygments 0.11.*
    """
    name = 'POVRay'
    aliases = ['pov']
    filenames = ['*.pov', '*.inc']
    mimetypes = ['text/x-povray']

    tokens = {
        'root': [
            (r'/\*[\w\W]*?\*/', Comment.Multiline),
            (r'//.*\n', Comment.Single),
            (r'"(?:\\.|[^"])+"', String.Double),
            (r'#(debug|default|else|end|error|fclose|fopen|if|ifdef|ifndef|'
             r'include|range|read|render|statistics|switch|undef|version|'
             r'warning|while|write|define|macro|local|declare)',
             Comment.Preproc),
            (r'\b(aa_level|aa_threshold|abs|acos|acosh|adaptive|adc_bailout|'
             r'agate|agate_turb|all|alpha|ambient|ambient_light|angle|'
             r'aperture|arc_angle|area_light|asc|asin|asinh|assumed_gamma|'
             r'atan|atan2|atanh|atmosphere|atmospheric_attenuation|'
             r'attenuating|average|background|black_hole|blue|blur_samples|'
             r'bounded_by|box_mapping|bozo|break|brick|brick_size|'
             r'brightness|brilliance|bumps|bumpy1|bumpy2|bumpy3|bump_map|'
             r'bump_size|case|caustics|ceil|checker|chr|clipped_by|clock|'
             r'color|color_map|colour|colour_map|component|composite|concat|'
             r'confidence|conic_sweep|constant|control0|control1|cos|cosh|'
             r'count|crackle|crand|cube|cubic_spline|cylindrical_mapping|'
             r'debug|declare|default|degrees|dents|diffuse|direction|'
             r'distance|distance_maximum|div|dust|dust_type|eccentricity|'
             r'else|emitting|end|error|error_bound|exp|exponent|'
             r'fade_distance|fade_power|falloff|falloff_angle|false|'
             r'file_exists|filter|finish|fisheye|flatness|flip|floor|'
             r'focal_point|fog|fog_alt|fog_offset|fog_type|frequency|gif|'
             r'global_settings|glowing|gradient|granite|gray_threshold|'
             r'green|halo|hexagon|hf_gray_16|hierarchy|hollow|hypercomplex|'
             r'if|ifdef|iff|image_map|incidence|include|int|interpolate|'
             r'inverse|ior|irid|irid_wavelength|jitter|lambda|leopard|'
             r'linear|linear_spline|linear_sweep|location|log|looks_like|'
             r'look_at|low_error_factor|mandel|map_type|marble|material_map|'
             r'matrix|max|max_intersections|max_iteration|max_trace_level|'
             r'max_value|metallic|min|minimum_reuse|mod|mortar|'
             r'nearest_count|no|normal|normal_map|no_shadow|number_of_waves|'
             r'octaves|off|offset|omega|omnimax|on|once|onion|open|'
             r'orthographic|panoramic|pattern1|pattern2|pattern3|'
             r'perspective|pgm|phase|phong|phong_size|pi|pigment|'
             r'pigment_map|planar_mapping|png|point_at|pot|pow|ppm|'
             r'precision|pwr|quadratic_spline|quaternion|quick_color|'
             r'quick_colour|quilted|radial|radians|radiosity|radius|rainbow|'
             r'ramp_wave|rand|range|reciprocal|recursion_limit|red|'
             r'reflection|refraction|render|repeat|rgb|rgbf|rgbft|rgbt|'
             r'right|ripples|rotate|roughness|samples|scale|scallop_wave|'
             r'scattering|seed|shadowless|sin|sine_wave|sinh|sky|sky_sphere|'
             r'slice|slope_map|smooth|specular|spherical_mapping|spiral|'
             r'spiral1|spiral2|spotlight|spotted|sqr|sqrt|statistics|str|'
             r'strcmp|strength|strlen|strlwr|strupr|sturm|substr|switch|sys|'
             r't|tan|tanh|test_camera_1|test_camera_2|test_camera_3|'
             r'test_camera_4|texture|texture_map|tga|thickness|threshold|'
             r'tightness|tile2|tiles|track|transform|translate|transmit|'
             r'triangle_wave|true|ttf|turbulence|turb_depth|type|'
             r'ultra_wide_angle|up|use_color|use_colour|use_index|u_steps|'
             r'val|variance|vaxis_rotate|vcross|vdot|version|vlength|'
             r'vnormalize|volume_object|volume_rendered|vol_with_light|'
             r'vrotate|v_steps|warning|warp|water_level|waves|while|width|'
             r'wood|wrinkles|yes)\b', Keyword),
            (r'bicubic_patch|blob|box|camera|cone|cubic|cylinder|difference|'
             r'disc|height_field|intersection|julia_fractal|lathe|'
             r'light_source|merge|mesh|object|plane|poly|polygon|prism|'
             r'quadric|quartic|smooth_triangle|sor|sphere|superellipsoid|'
             r'text|torus|triangle|union', Name.Builtin),
            # TODO: <=, etc
            (r'[\[\](){}<>;,]', Punctuation),
            (r'[-+*/=]', Operator),
            (r'\b(x|y|z|u|v)\b', Name.Builtin.Pseudo),
            (r'[a-zA-Z_][a-zA-Z_0-9]*', Name),
            (r'[0-9]+\.[0-9]*', Number.Float),
            (r'\.[0-9]+', Number.Float),
            (r'[0-9]+', Number.Integer),
            (r'\s+', Text),
        ]
    }


class AppleScriptLexer(RegexLexer):
    """
    For `AppleScript source code
    <http://developer.apple.com/documentation/AppleScript/
    Conceptual/AppleScriptLangGuide>`_,
    including `AppleScript Studio
    <http://developer.apple.com/documentation/AppleScript/
    Reference/StudioReference>`_.
    Contributed by Andreas Amann <aamann@mac.com>.
    """

    name = 'AppleScript'
    aliases = ['applescript']
    filenames = ['*.applescript']

    flags = re.MULTILINE | re.DOTALL

    Identifiers = r'[a-zA-Z]\w*'
    Literals = ['AppleScript', 'current application', 'false', 'linefeed',
                'missing value', 'pi','quote', 'result', 'return', 'space',
                'tab', 'text item delimiters', 'true', 'version']
    Classes = ['alias ', 'application ', 'boolean ', 'class ', 'constant ',
               'date ', 'file ', 'integer ', 'list ', 'number ', 'POSIX file ',
               'real ', 'record ', 'reference ', 'RGB color ', 'script ',
               'text ', 'unit types', '(Unicode )?text', 'string']
    BuiltIn = ['attachment', 'attribute run', 'character', 'day', 'month',
               'paragraph', 'word', 'year']
    HandlerParams = ['about', 'above', 'against', 'apart from', 'around',
                     'aside from', 'at', 'below', 'beneath', 'beside',
                     'between', 'for', 'given', 'instead of', 'on', 'onto',
                     'out of', 'over', 'since']
    Commands = ['ASCII (character|number)', 'activate', 'beep', 'choose URL',
                'choose application', 'choose color', 'choose file( name)?',
                'choose folder', 'choose from list',
                'choose remote application', 'clipboard info',
                'close( access)?', 'copy', 'count', 'current date', 'delay',
                'delete', 'display (alert|dialog)', 'do shell script',
                'duplicate', 'exists', 'get eof', 'get volume settings',
                'info for', 'launch', 'list (disks|folder)', 'load script',
                'log', 'make', 'mount volume', 'new', 'offset',
                'open( (for access|location))?', 'path to', 'print', 'quit',
                'random number', 'read', 'round', 'run( script)?',
                'say', 'scripting components',
                'set (eof|the clipboard to|volume)', 'store script',
                'summarize', 'system attribute', 'system info',
                'the clipboard', 'time to GMT', 'write', 'quoted form']
    References = ['(in )?back of', '(in )?front of', '[0-9]+(st|nd|rd|th)',
                  'first', 'second', 'third', 'fourth', 'fifth', 'sixth',
                  'seventh', 'eighth', 'ninth', 'tenth', 'after', 'back',
                  'before', 'behind', 'every', 'front', 'index', 'last',
                  'middle', 'some', 'that', 'through', 'thru', 'where', 'whose']
    Operators = ["and", "or", "is equal", "equals", "(is )?equal to", "is not",
                 "isn't", "isn't equal( to)?", "is not equal( to)?",
                 "doesn't equal", "does not equal", "(is )?greater than",
                 "comes after", "is not less than or equal( to)?",
                 "isn't less than or equal( to)?", "(is )?less than",
                 "comes before", "is not greater than or equal( to)?",
                 "isn't greater than or equal( to)?",
                 "(is  )?greater than or equal( to)?", "is not less than",
                 "isn't less than", "does not come before",
                 "doesn't come before", "(is )?less than or equal( to)?",
                 "is not greater than", "isn't greater than",
                 "does not come after", "doesn't come after", "starts? with",
                 "begins? with", "ends? with", "contains?", "does not contain",
                 "doesn't contain", "is in", "is contained by", "is not in",
                 "is not contained by", "isn't contained by", "div", "mod",
                 "not", "(a  )?(ref( to)?|reference to)", "is", "does"]
    Control = ['considering', 'else', 'error', 'exit', 'from', 'if',
               'ignoring', 'in', 'repeat', 'tell', 'then', 'times', 'to',
               'try', 'until', 'using terms from', 'while', 'whith',
               'with timeout( of)?', 'with transaction', 'by', 'continue',
               'end', 'its?', 'me', 'my', 'return', 'of' , 'as']
    Declarations = ['global', 'local', 'prop(erty)?', 'set', 'get']
    Reserved = ['but', 'put', 'returning', 'the']
    StudioClasses = ['action cell', 'alert reply', 'application', 'box',
                     'browser( cell)?', 'bundle', 'button( cell)?', 'cell',
                     'clip view', 'color well', 'color-panel',
                     'combo box( item)?', 'control',
                     'data( (cell|column|item|row|source))?', 'default entry',
                     'dialog reply', 'document', 'drag info', 'drawer',
                     'event', 'font(-panel)?', 'formatter',
                     'image( (cell|view))?', 'matrix', 'menu( item)?', 'item',
                     'movie( view)?', 'open-panel', 'outline view', 'panel',
                     'pasteboard', 'plugin', 'popup button',
                     'progress indicator', 'responder', 'save-panel',
                     'scroll view', 'secure text field( cell)?', 'slider',
                     'sound', 'split view', 'stepper', 'tab view( item)?',
                     'table( (column|header cell|header view|view))',
                     'text( (field( cell)?|view))?', 'toolbar( item)?',
                     'user-defaults', 'view', 'window']
    StudioEvents = ['accept outline drop', 'accept table drop', 'action',
                    'activated', 'alert ended', 'awake from nib', 'became key',
                    'became main', 'begin editing', 'bounds changed',
                    'cell value', 'cell value changed', 'change cell value',
                    'change item value', 'changed', 'child of item',
                    'choose menu item', 'clicked', 'clicked toolbar item',
                    'closed', 'column clicked', 'column moved',
                    'column resized', 'conclude drop', 'data representation',
                    'deminiaturized', 'dialog ended', 'document nib name',
                    'double clicked', 'drag( (entered|exited|updated))?',
                    'drop', 'end editing', 'exposed', 'idle', 'item expandable',
                    'item value', 'item value changed', 'items changed',
                    'keyboard down', 'keyboard up', 'launched',
                    'load data representation', 'miniaturized', 'mouse down',
                    'mouse dragged', 'mouse entered', 'mouse exited',
                    'mouse moved', 'mouse up', 'moved',
                    'number of browser rows', 'number of items',
                    'number of rows', 'open untitled', 'opened', 'panel ended',
                    'parameters updated', 'plugin loaded', 'prepare drop',
                    'prepare outline drag', 'prepare outline drop',
                    'prepare table drag', 'prepare table drop',
                    'read from file', 'resigned active', 'resigned key',
                    'resigned main', 'resized( sub views)?',
                    'right mouse down', 'right mouse dragged',
                    'right mouse up', 'rows changed', 'scroll wheel',
                    'selected tab view item', 'selection changed',
                    'selection changing', 'should begin editing',
                    'should close', 'should collapse item',
                    'should end editing', 'should expand item',
                    'should open( untitled)?',
                    'should quit( after last window closed)?',
                    'should select column', 'should select item',
                    'should select row', 'should select tab view item',
                    'should selection change', 'should zoom', 'shown',
                    'update menu item', 'update parameters',
                    'update toolbar item', 'was hidden', 'was miniaturized',
                    'will become active', 'will close', 'will dismiss',
                    'will display browser cell', 'will display cell',
                    'will display item cell', 'will display outline cell',
                    'will finish launching', 'will hide', 'will miniaturize',
                    'will move', 'will open', 'will pop up', 'will quit',
                    'will resign active', 'will resize( sub views)?',
                    'will select tab view item', 'will show', 'will zoom',
                    'write to file', 'zoomed']
    StudioCommands = ['animate', 'append', 'call method', 'center',
                      'close drawer', 'close panel', 'display',
                      'display alert', 'display dialog', 'display panel', 'go',
                      'hide', 'highlight', 'increment', 'item for',
                      'load image', 'load movie', 'load nib', 'load panel',
                      'load sound', 'localized string', 'lock focus', 'log',
                      'open drawer', 'path for', 'pause', 'perform action',
                      'play', 'register', 'resume', 'scroll', 'select( all)?',
                      'show', 'size to fit', 'start', 'step back',
                      'step forward', 'stop', 'synchronize', 'unlock focus',
                      'update']
    StudioProperties = ['accepts arrow key', 'action method', 'active',
                        'alignment', 'allowed identifiers',
                        'allows branch selection', 'allows column reordering',
                        'allows column resizing', 'allows column selection',
                        'allows customization',
                        'allows editing text attributes',
                        'allows empty selection', 'allows mixed state',
                        'allows multiple selection', 'allows reordering',
                        'allows undo', 'alpha( value)?', 'alternate image',
                        'alternate increment value', 'alternate title',
                        'animation delay', 'associated file name',
                        'associated object', 'auto completes', 'auto display',
                        'auto enables items', 'auto repeat',
                        'auto resizes( outline column)?',
                        'auto save expanded items', 'auto save name',
                        'auto save table columns', 'auto saves configuration',
                        'auto scroll', 'auto sizes all columns to fit',
                        'auto sizes cells', 'background color', 'bezel state',
                        'bezel style', 'bezeled', 'border rect', 'border type',
                        'bordered', 'bounds( rotation)?', 'box type',
                        'button returned', 'button type',
                        'can choose directories', 'can choose files',
                        'can draw', 'can hide',
                        'cell( (background color|size|type))?', 'characters',
                        'class', 'click count', 'clicked( data)? column',
                        'clicked data item', 'clicked( data)? row',
                        'closeable', 'collating', 'color( (mode|panel))',
                        'command key down', 'configuration',
                        'content(s| (size|view( margins)?))?', 'context',
                        'continuous', 'control key down', 'control size',
                        'control tint', 'control view',
                        'controller visible', 'coordinate system',
                        'copies( on scroll)?', 'corner view', 'current cell',
                        'current column', 'current( field)?  editor',
                        'current( menu)? item', 'current row',
                        'current tab view item', 'data source',
                        'default identifiers', 'delta (x|y|z)',
                        'destination window', 'directory', 'display mode',
                        'displayed cell', 'document( (edited|rect|view))?',
                        'double value', 'dragged column', 'dragged distance',
                        'dragged items', 'draws( cell)? background',
                        'draws grid', 'dynamically scrolls', 'echos bullets',
                        'edge', 'editable', 'edited( data)? column',
                        'edited data item', 'edited( data)? row', 'enabled',
                        'enclosing scroll view', 'ending page',
                        'error handling', 'event number', 'event type',
                        'excluded from windows menu', 'executable path',
                        'expanded', 'fax number', 'field editor', 'file kind',
                        'file name', 'file type', 'first responder',
                        'first visible column', 'flipped', 'floating',
                        'font( panel)?', 'formatter', 'frameworks path',
                        'frontmost', 'gave up', 'grid color', 'has data items',
                        'has horizontal ruler', 'has horizontal scroller',
                        'has parent data item', 'has resize indicator',
                        'has shadow', 'has sub menu', 'has vertical ruler',
                        'has vertical scroller', 'header cell', 'header view',
                        'hidden', 'hides when deactivated', 'highlights by',
                        'horizontal line scroll', 'horizontal page scroll',
                        'horizontal ruler view', 'horizontally resizable',
                        'icon image', 'id', 'identifier',
                        'ignores multiple clicks',
                        'image( (alignment|dims when disabled|frame style|'
                            'scaling))?',
                        'imports graphics', 'increment value',
                        'indentation per level', 'indeterminate', 'index',
                        'integer value', 'intercell spacing', 'item height',
                        'key( (code|equivalent( modifier)?|window))?',
                        'knob thickness', 'label', 'last( visible)? column',
                        'leading offset', 'leaf', 'level', 'line scroll',
                        'loaded', 'localized sort', 'location', 'loop mode',
                        'main( (bunde|menu|window))?', 'marker follows cell',
                        'matrix mode', 'maximum( content)? size',
                        'maximum visible columns',
                        'menu( form representation)?', 'miniaturizable',
                        'miniaturized', 'minimized image', 'minimized title',
                        'minimum column width', 'minimum( content)? size',
                        'modal', 'modified', 'mouse down state',
                        'movie( (controller|file|rect))?', 'muted', 'name',
                        'needs display', 'next state', 'next text',
                        'number of tick marks', 'only tick mark values',
                        'opaque', 'open panel', 'option key down',
                        'outline table column', 'page scroll', 'pages across',
                        'pages down', 'palette label', 'pane splitter',
                        'parent data item', 'parent window', 'pasteboard',
                        'path( (names|separator))?', 'playing',
                        'plays every frame', 'plays selection only', 'position',
                        'preferred edge', 'preferred type', 'pressure',
                        'previous text', 'prompt', 'properties',
                        'prototype cell', 'pulls down', 'rate',
                        'released when closed', 'repeated',
                        'requested print time', 'required file type',
                        'resizable', 'resized column', 'resource path',
                        'returns records', 'reuses columns', 'rich text',
                        'roll over', 'row height', 'rulers visible',
                        'save panel', 'scripts path', 'scrollable',
                        'selectable( identifiers)?', 'selected cell',
                        'selected( data)? columns?', 'selected data items?',
                        'selected( data)? rows?', 'selected item identifier',
                        'selection by rect', 'send action on arrow key',
                        'sends action when done editing', 'separates columns',
                        'separator item', 'sequence number', 'services menu',
                        'shared frameworks path', 'shared support path',
                        'sheet', 'shift key down', 'shows alpha',
                        'shows state by', 'size( mode)?',
                        'smart insert delete enabled', 'sort case sensitivity',
                        'sort column', 'sort order', 'sort type',
                        'sorted( data rows)?', 'sound', 'source( mask)?',
                        'spell checking enabled', 'starting page', 'state',
                        'string value', 'sub menu', 'super menu', 'super view',
                        'tab key traverses cells', 'tab state', 'tab type',
                        'tab view', 'table view', 'tag', 'target( printer)?',
                        'text color', 'text container insert',
                        'text container origin', 'text returned',
                        'tick mark position', 'time stamp',
                        'title(d| (cell|font|height|position|rect))?',
                        'tool tip', 'toolbar', 'trailing offset', 'transparent',
                        'treat packages as directories', 'truncated labels',
                        'types', 'unmodified characters', 'update views',
                        'use sort indicator', 'user defaults',
                        'uses data source', 'uses ruler',
                        'uses threaded animation',
                        'uses title from previous column', 'value wraps',
                        'version',
                        'vertical( (line scroll|page scroll|ruler view))?',
                        'vertically resizable', 'view',
                        'visible( document rect)?', 'volume', 'width', 'window',
                        'windows menu', 'wraps', 'zoomable', 'zoomed']

    tokens = {
        'root': [
            (r'\s+', Text),
            (ur'¬\n', String.Escape),
            (r"'s\s+", Text), # This is a possessive, consider moving
            (r'(--|#).*?$', Comment),
            (r'\(\*', Comment.Multiline, 'comment'),
            (r'[\(\){}!,.:]', Punctuation),
            (ur'(«)([^»]+)(»)',
             bygroups(Text, Name.Builtin, Text)),
            (r'\b((?:considering|ignoring)\s*)'
             r'(application responses|case|diacriticals|hyphens|'
             r'numeric strings|punctuation|white space)',
             bygroups(Keyword, Name.Builtin)),
            (ur'(-|\*|\+|&|≠|>=?|<=?|=|≥|≤|/|÷|\^)', Operator),
            (r"\b(%s)\b" % '|'.join(Operators), Operator.Word),
            (r'^(\s*(?:on|end)\s+)'
             r'(%s)' % '|'.join(StudioEvents),
             bygroups(Keyword, Name.Function)),
            (r'^(\s*)(in|on|script|to)(\s+)', bygroups(Text, Keyword, Text)),
            (r'\b(as )(%s)\b' % '|'.join(Classes),
             bygroups(Keyword, Name.Class)),
            (r'\b(%s)\b' % '|'.join(Literals), Name.Constant),
            (r'\b(%s)\b' % '|'.join(Commands), Name.Builtin),
            (r'\b(%s)\b' % '|'.join(Control), Keyword),
            (r'\b(%s)\b' % '|'.join(Declarations), Keyword),
            (r'\b(%s)\b' % '|'.join(Reserved), Name.Builtin),
            (r'\b(%s)s?\b' % '|'.join(BuiltIn), Name.Builtin),
            (r'\b(%s)\b' % '|'.join(HandlerParams), Name.Builtin),
            (r'\b(%s)\b' % '|'.join(StudioProperties), Name.Attribute),
            (r'\b(%s)s?\b' % '|'.join(StudioClasses), Name.Builtin),
            (r'\b(%s)\b' % '|'.join(StudioCommands), Name.Builtin),
            (r'\b(%s)\b' % '|'.join(References), Name.Builtin),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r'\b(%s)\b' % Identifiers, Name.Variable),
            (r'[-+]?(\d+\.\d*|\d*\.\d+)(E[-+][0-9]+)?', Number.Float),
            (r'[-+]?\d+', Number.Integer),
        ],
        'comment': [
            ('\(\*', Comment.Multiline, '#push'),
            ('\*\)', Comment.Multiline, '#pop'),
            ('[^*(]+', Comment.Multiline),
            ('[*(]', Comment.Multiline),
        ],
    }


class ModelicaLexer(RegexLexer):
    """
    For `Modelica <http://www.modelica.org/>`_ source code.

    *New in Pygments 1.1.*
    """
    name = 'Modelica'
    aliases = ['modelica']
    filenames = ['*.mo']
    mimetypes = ['text/x-modelica']

    flags = re.IGNORECASE | re.DOTALL

    tokens = {
        'whitespace': [
            (r'\n', Text),
            (r'\s+', Text),
            (r'\\\n', Text), # line continuation
            (r'//(\n|(.|\n)*?[^\\]\n)', Comment),
            (r'/(\\\n)?[*](.|\n)*?[*](\\\n)?/', Comment),
        ],
        'statements': [
            (r'"', String, 'string'),
            (r'(\d+\.\d*|\.\d+|\d+|\d.)[eE][+-]?\d+[lL]?', Number.Float),
            (r'(\d+\.\d*|\.\d+)', Number.Float),
            (r'\d+[Ll]?', Number.Integer),
            (r'[~!%^&*+=|?:<>/-]', Operator),
            (r'[()\[\]{},.;]', Punctuation),
            (r'(true|false|NULL|Real|Integer|Boolean)\b', Name.Builtin),
            (r"([a-zA-Z_][\w]*|'[a-zA-Z_\+\-\*\/\^][\w]*')"
             r"(\.([a-zA-Z_][\w]*|'[a-zA-Z_\+\-\*\/\^][\w]*'))+", Name.Class),
            (r"('[\w\+\-\*\/\^]+'|\w+)", Name)        ],
        'root': [
            include('whitespace'),
            include('keywords'),
            include('functions'),
            include('operators'),
            include('classes'),
            (r'("<html>|<html>)', Name.Tag, 'html-content'),
            include('statements')
        ],
        'keywords': [
            (r'(algorithm|annotation|break|connect|constant|constrainedby|'
            r'discrete|each|else|elseif|elsewhen|encapsulated|enumeration|'
            r'end|equation|exit|expandable|extends|'
            r'external|false|final|flow|for|if|import|in|inner|input|'
            r'loop|nondiscrete|outer|output|parameter|partial|'
            r'protected|public|redeclare|replaceable|time|then|true|'
            r'when|while|within)\b', Keyword)
        ],
        'functions': [
            (r'(abs|acos|acosh|asin|asinh|atan|atan2|atan3|ceil|cos|cosh|'
             r'cross|div|exp|floor|log|log10|mod|rem|sign|sin|sinh|size|'
             r'sqrt|tan|tanh|zeros)\b', Name.Function)
        ],
        'operators': [
            (r'(and|assert|cardinality|change|delay|der|edge|initial|'
             r'noEvent|not|or|pre|reinit|return|sample|smooth|'
             r'terminal|terminate)\b', Name.Builtin)
        ],
        'classes': [
            (r'(block|class|connector|function|model|package|'
             r'record|type)\b', Name.Class)
        ],
        'string': [
            (r'"', String, '#pop'),
            (r'\\([\\abfnrtv"\']|x[a-fA-F0-9]{2,4}|[0-7]{1,3})',
             String.Escape),
            (r'[^\\"\n]+', String), # all other characters
            (r'\\\n', String), # line continuation
            (r'\\', String) # stray backslash
        ],
        'html-content': [
            (r'<\s*/\s*html\s*>', Name.Tag, '#pop'),
            (r'.+?(?=<\s*/\s*html\s*>)', using(HtmlLexer)),
        ]
    }


class RebolLexer(RegexLexer):
    """
    A `REBOL <http://www.rebol.com/>`_ lexer.

    *New in Pygments 1.1.*
    """
    name = 'REBOL'
    aliases = ['rebol']
    filenames = ['*.r', '*.r3']
    mimetypes = ['text/x-rebol']

    flags = re.IGNORECASE | re.MULTILINE

    re.IGNORECASE

    escape_re = r'(?:\^\([0-9a-fA-F]{1,4}\)*)'

    def word_callback(lexer, match):
        word = match.group()

        if re.match(".*:$", word):
            yield match.start(), Generic.Subheading, word
        elif re.match(
            r'(native|alias|all|any|as-string|as-binary|bind|bound\?|case|'
            r'catch|checksum|comment|debase|dehex|exclude|difference|disarm|'
            r'either|else|enbase|foreach|remove-each|form|free|get|get-env|if|'
            r'in|intersect|loop|minimum-of|maximum-of|mold|new-line|'
            r'new-line\?|not|now|prin|print|reduce|compose|construct|repeat|'
            r'reverse|save|script\?|set|shift|switch|throw|to-hex|trace|try|'
            r'type\?|union|unique|unless|unprotect|unset|until|use|value\?|'
            r'while|compress|decompress|secure|open|close|read|read-io|'
            r'write-io|write|update|query|wait|input\?|exp|log-10|log-2|'
            r'log-e|square-root|cosine|sine|tangent|arccosine|arcsine|'
            r'arctangent|protect|lowercase|uppercase|entab|detab|connected\?|'
            r'browse|launch|stats|get-modes|set-modes|to-local-file|'
            r'to-rebol-file|encloak|decloak|create-link|do-browser|bind\?|'
            r'hide|draw|show|size-text|textinfo|offset-to-caret|'
            r'caret-to-offset|local-request-file|rgb-to-hsv|hsv-to-rgb|'
            r'crypt-strength\?|dh-make-key|dh-generate-key|dh-compute-key|'
            r'dsa-make-key|dsa-generate-key|dsa-make-signature|'
            r'dsa-verify-signature|rsa-make-key|rsa-generate-key|'
            r'rsa-encrypt)$', word):
            yield match.start(), Name.Builtin, word
        elif re.match(
            r'(add|subtract|multiply|divide|remainder|power|and~|or~|xor~|'
            r'minimum|maximum|negate|complement|absolute|random|head|tail|'
            r'next|back|skip|at|pick|first|second|third|fourth|fifth|sixth|'
            r'seventh|eighth|ninth|tenth|last|path|find|select|make|to|copy\*|'
            r'insert|remove|change|poke|clear|trim|sort|min|max|abs|cp|'
            r'copy)$', word):
            yield match.start(), Name.Function, word
        elif re.match(
            r'(error|source|input|license|help|install|echo|Usage|with|func|'
            r'throw-on-error|function|does|has|context|probe|\?\?|as-pair|'
            r'mod|modulo|round|repend|about|set-net|append|join|rejoin|reform|'
            r'remold|charset|array|replace|move|extract|forskip|forall|alter|'
            r'first+|also|take|for|forever|dispatch|attempt|what-dir|'
            r'change-dir|clean-path|list-dir|dirize|rename|split-path|delete|'
            r'make-dir|delete-dir|in-dir|confirm|dump-obj|upgrade|what|'
            r'build-tag|process-source|build-markup|decode-cgi|read-cgi|'
            r'write-user|save-user|set-user-name|protect-system|parse-xml|'
            r'cvs-date|cvs-version|do-boot|get-net-info|desktop|layout|'
            r'scroll-para|get-face|alert|set-face|uninstall|unfocus|'
            r'request-dir|center-face|do-events|net-error|decode-url|'
            r'parse-header|parse-header-date|parse-email-addrs|import-email|'
            r'send|build-attach-body|resend|show-popup|hide-popup|open-events|'
            r'find-key-face|do-face|viewtop|confine|find-window|'
            r'insert-event-func|remove-event-func|inform|dump-pane|dump-face|'
            r'flag-face|deflag-face|clear-fields|read-net|vbug|path-thru|'
            r'read-thru|load-thru|do-thru|launch-thru|load-image|'
            r'request-download|do-face-alt|set-font|set-para|get-style|'
            r'set-style|make-face|stylize|choose|hilight-text|hilight-all|'
            r'unlight-text|focus|scroll-drag|clear-face|reset-face|scroll-face|'
            r'resize-face|load-stock|load-stock-block|notify|request|flash|'
            r'request-color|request-pass|request-text|request-list|'
            r'request-date|request-file|dbug|editor|link-relative-path|'
            r'emailer|parse-error)$', word):
            yield match.start(), Keyword.Namespace, word
        elif re.match(
            r'(halt|quit|do|load|q|recycle|call|run|ask|parse|view|unview|'
            r'return|exit|break)$', word):
            yield match.start(), Name.Exception, word
        elif re.match('REBOL$', word):
            yield match.start(), Generic.Heading, word
        elif re.match("to-.*", word):
            yield match.start(), Keyword, word
        elif re.match('(\+|-|\*|/|//|\*\*|and|or|xor|=\?|=|==|<>|<|>|<=|>=)$',
                      word):
            yield match.start(), Operator, word
        elif re.match(".*\?$", word):
            yield match.start(), Keyword, word
        elif re.match(".*\!$", word):
            yield match.start(), Keyword.Type, word
        elif re.match("'.*", word):
            yield match.start(), Name.Variable.Instance, word # lit-word
        elif re.match("#.*", word):
            yield match.start(), Name.Label, word # issue
        elif re.match("%.*", word):
            yield match.start(), Name.Decorator, word # file
        else:
            yield match.start(), Name.Variable, word

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'#"', String.Char, 'char'),
            (r'#{[0-9a-fA-F]*}', Number.Hex),
            (r'2#{', Number.Hex, 'bin2'),
            (r'64#{[0-9a-zA-Z+/=\s]*}', Number.Hex),
            (r'"', String, 'string'),
            (r'{', String, 'string2'),
            (r';#+.*\n', Comment.Special),
            (r';\*+.*\n', Comment.Preproc),
            (r';.*\n', Comment),
            (r'%"', Name.Decorator, 'stringFile'),
            (r'%[^(\^{^")\s\[\]]+', Name.Decorator),
            (r'<[a-zA-Z0-9:._-]*>', Name.Tag),
            (r'<[^(<>\s")]+', Name.Tag, 'tag'),
            (r'[+-]?([a-zA-Z]{1,3})?\$\d+(\.\d+)?', Number.Float), # money
            (r'[+-]?\d+\:\d+(\:\d+)?(\.\d+)?', String.Other), # time
            (r'\d+\-[0-9a-zA-Z]+\-\d+(\/\d+\:\d+(\:\d+)?'
             r'([\.\d+]?([+-]?\d+:\d+)?)?)?', String.Other), # date
            (r'\d+(\.\d+)+\.\d+', Keyword.Constant), # tuple
            (r'\d+[xX]\d+', Keyword.Constant), # pair
            (r'[+-]?\d+(\'\d+)?([\.,]\d*)?[eE][+-]?\d+', Number.Float),
            (r'[+-]?\d+(\'\d+)?[\.,]\d*', Number.Float),
            (r'[+-]?\d+(\'\d+)?', Number),
            (r'[\[\]\(\)]', Generic.Strong),
            (r'[a-zA-Z]+[^(\^{"\s:)]*://[^(\^{"\s)]*', Name.Decorator), # url
            (r'mailto:[^(\^{"@\s)]+@[^(\^{"@\s)]+', Name.Decorator), # url
            (r'[^(\^{"@\s)]+@[^(\^{"@\s)]+', Name.Decorator), # email
            (r'comment\s', Comment, 'comment'),
            (r'/[^(\^{^")\s/[\]]*', Name.Attribute),
            (r'([^(\^{^")\s/[\]]+)(?=[:({"\s/\[\]])', word_callback),
            (r'([^(\^{^")\s]+)', Text),
        ],
        'string': [
            (r'[^(\^")]+', String),
            (escape_re, String.Escape),
            (r'[\(|\)]+', String),
            (r'\^.', String.Escape),
            (r'"', String, '#pop'),
        ],
        'string2': [
            (r'[^(\^{^})]+', String),
            (escape_re, String.Escape),
            (r'[\(|\)]+', String),
            (r'\^.', String.Escape),
            (r'{', String, '#push'),
            (r'}', String, '#pop'),
        ],
        'stringFile': [
            (r'[^(\^")]+', Name.Decorator),
            (escape_re, Name.Decorator),
            (r'\^.', Name.Decorator),
            (r'"', Name.Decorator, '#pop'),
        ],
        'char': [
            (escape_re + '"', String.Char, '#pop'),
            (r'\^."', String.Char, '#pop'),
            (r'."', String.Char, '#pop'),
        ],
        'tag': [
            (escape_re, Name.Tag),
            (r'"', Name.Tag, 'tagString'),
            (r'[^(<>\r\n")]+', Name.Tag),
            (r'>', Name.Tag, '#pop'),
        ],
        'tagString': [
            (r'[^(\^")]+', Name.Tag),
            (escape_re, Name.Tag),
            (r'[\(|\)]+', Name.Tag),
            (r'\^.', Name.Tag),
            (r'"', Name.Tag, '#pop'),
        ],
        'tuple': [
            (r'(\d+\.)+', Keyword.Constant),
            (r'\d+', Keyword.Constant, '#pop'),
        ],
        'bin2': [
            (r'\s+', Number.Hex),
            (r'([0-1]\s*){8}', Number.Hex),
            (r'}', Number.Hex, '#pop'),
        ],
        'comment': [
            (r'"', Comment, 'commentString1'),
            (r'{', Comment, 'commentString2'),
            (r'\[', Comment, 'commentBlock'),
            (r'[^(\s{\"\[]+', Comment, '#pop'),
        ],
        'commentString1': [
            (r'[^(\^")]+', Comment),
            (escape_re, Comment),
            (r'[\(|\)]+', Comment),
            (r'\^.', Comment),
            (r'"', Comment, '#pop'),
        ],
        'commentString2': [
            (r'[^(\^{^})]+', Comment),
            (escape_re, Comment),
            (r'[\(|\)]+', Comment),
            (r'\^.', Comment),
            (r'{', Comment, '#push'),
            (r'}', Comment, '#pop'),
        ],
        'commentBlock': [
            (r'\[',Comment, '#push'),
            (r'\]',Comment, '#pop'),
            (r'[^(\[\])]*', Comment),
        ],
    }


class ABAPLexer(RegexLexer):
    """
    Lexer for ABAP, SAP's integrated language.

    *New in Pygments 1.1.*
    """
    name = 'ABAP'
    aliases = ['abap']
    filenames = ['*.abap']
    mimetypes = ['text/x-abap']

    flags = re.IGNORECASE | re.MULTILINE

    tokens = {
        'common': [
            (r'\s+', Text),
            (r'^\*.*$', Comment.Single),
            (r'\".*?\n', Comment.Single),
            ],
        'variable-names': [
            (r'<[\S_]+>', Name.Variable),
            (r'[\w][\w_~]*(?:(\[\])|->\*)?', Name.Variable),
            ],
        'root': [
            include('common'),
            #function calls
            (r'(CALL\s+(?:BADI|CUSTOMER-FUNCTION|FUNCTION))(\s+)(\'?\S+\'?)',
                bygroups(Keyword, Text, Name.Function)),
            (r'(CALL\s+(?:DIALOG|SCREEN|SUBSCREEN|SELECTION-SCREEN|'
             r'TRANSACTION|TRANSFORMATION))\b',
                Keyword),
            (r'(FORM|PERFORM)(\s+)([\w_]+)',
                bygroups(Keyword, Text, Name.Function)),
            (r'(PERFORM)(\s+)(\()([\w_]+)(\))',
                bygroups(Keyword, Text, Punctuation, Name.Variable, Punctuation )),
            (r'(MODULE)(\s+)(\S+)(\s+)(INPUT|OUTPUT)',
                bygroups(Keyword, Text, Name.Function, Text, Keyword)),

            # method implementation
            (r'(METHOD)(\s+)([\w_~]+)',
                bygroups(Keyword, Text, Name.Function)),
            # method calls
            (r'(\s+)([\w_\-]+)([=\-]>)([\w_\-~]+)',
                bygroups(Text, Name.Variable, Operator, Name.Function)),
            # call methodnames returning style
            (r'(?<=(=|-)>)([\w_\-~]+)(?=\()', Name.Function),

            # keywords with dashes in them.
            # these need to be first, because for instance the -ID part
            # of MESSAGE-ID wouldn't get highlighted if MESSAGE was
            # first in the list of keywords.
            (r'(ADD-CORRESPONDING|AUTHORITY-CHECK|'
             r'CLASS-DATA|CLASS-EVENTS|CLASS-METHODS|CLASS-POOL|'
             r'DELETE-ADJACENT|DIVIDE-CORRESPONDING|'
             r'EDITOR-CALL|ENHANCEMENT-POINT|ENHANCEMENT-SECTION|EXIT-COMMAND|'
             r'FIELD-GROUPS|FIELD-SYMBOLS|FUNCTION-POOL|'
             r'INTERFACE-POOL|INVERTED-DATE|'
             r'LOAD-OF-PROGRAM|LOG-POINT|'
             r'MESSAGE-ID|MOVE-CORRESPONDING|MULTIPLY-CORRESPONDING|'
             r'NEW-LINE|NEW-PAGE|NEW-SECTION|NO-EXTENSION|'
             r'OUTPUT-LENGTH|PRINT-CONTROL|'
             r'SELECT-OPTIONS|START-OF-SELECTION|SUBTRACT-CORRESPONDING|'
             r'SYNTAX-CHECK|SYSTEM-EXCEPTIONS|'
             r'TYPE-POOL|TYPE-POOLS'
             r')\b', Keyword),

             # keyword kombinations
            (r'CREATE\s+(PUBLIC|PRIVATE|DATA|OBJECT)|'
             r'((PUBLIC|PRIVATE|PROTECTED)\s+SECTION|'
             r'(TYPE|LIKE)(\s+(LINE\s+OF|REF\s+TO|'
             r'(SORTED|STANDARD|HASHED)\s+TABLE\s+OF))?|'
             r'FROM\s+(DATABASE|MEMORY)|CALL\s+METHOD|'
             r'(GROUP|ORDER) BY|HAVING|SEPARATED BY|'
             r'GET\s+(BADI|BIT|CURSOR|DATASET|LOCALE|PARAMETER|'
                      r'PF-STATUS|(PROPERTY|REFERENCE)\s+OF|'
                      r'RUN\s+TIME|TIME\s+(STAMP)?)?|'
             r'SET\s+(BIT|BLANK\s+LINES|COUNTRY|CURSOR|DATASET|EXTENDED\s+CHECK|'
                      r'HANDLER|HOLD\s+DATA|LANGUAGE|LEFT\s+SCROLL-BOUNDARY|'
                      r'LOCALE|MARGIN|PARAMETER|PF-STATUS|PROPERTY\s+OF|'
                      r'RUN\s+TIME\s+(ANALYZER|CLOCK\s+RESOLUTION)|SCREEN|'
                      r'TITLEBAR|UPADTE\s+TASK\s+LOCAL|USER-COMMAND)|'
             r'CONVERT\s+((INVERTED-)?DATE|TIME|TIME\s+STAMP|TEXT)|'
             r'(CLOSE|OPEN)\s+(DATASET|CURSOR)|'
             r'(TO|FROM)\s+(DATA BUFFER|INTERNAL TABLE|MEMORY ID|'
                            r'DATABASE|SHARED\s+(MEMORY|BUFFER))|'
             r'DESCRIBE\s+(DISTANCE\s+BETWEEN|FIELD|LIST|TABLE)|'
             r'FREE\s(MEMORY|OBJECT)?|'
             r'PROCESS\s+(BEFORE\s+OUTPUT|AFTER\s+INPUT|'
                          r'ON\s+(VALUE-REQUEST|HELP-REQUEST))|'
             r'AT\s+(LINE-SELECTION|USER-COMMAND|END\s+OF|NEW)|'
             r'AT\s+SELECTION-SCREEN(\s+(ON(\s+(BLOCK|(HELP|VALUE)-REQUEST\s+FOR|'
                                     r'END\s+OF|RADIOBUTTON\s+GROUP))?|OUTPUT))?|'
             r'SELECTION-SCREEN:?\s+((BEGIN|END)\s+OF\s+((TABBED\s+)?BLOCK|LINE|'
                                     r'SCREEN)|COMMENT|FUNCTION\s+KEY|'
                                     r'INCLUDE\s+BLOCKS|POSITION|PUSHBUTTON|'
                                     r'SKIP|ULINE)|'
             r'LEAVE\s+(LIST-PROCESSING|PROGRAM|SCREEN|'
                        r'TO LIST-PROCESSING|TO TRANSACTION)'
             r'(ENDING|STARTING)\s+AT|'
             r'FORMAT\s+(COLOR|INTENSIFIED|INVERSE|HOTSPOT|INPUT|FRAMES|RESET)|'
             r'AS\s+(CHECKBOX|SUBSCREEN|WINDOW)|'
             r'WITH\s+(((NON-)?UNIQUE)?\s+KEY|FRAME)|'
             r'(BEGIN|END)\s+OF|'
             r'DELETE(\s+ADJACENT\s+DUPLICATES\sFROM)?|'
             r'COMPARING(\s+ALL\s+FIELDS)?|'
             r'INSERT(\s+INITIAL\s+LINE\s+INTO|\s+LINES\s+OF)?|'
             r'IN\s+((BYTE|CHARACTER)\s+MODE|PROGRAM)|'
             r'END-OF-(DEFINITION|PAGE|SELECTION)|'
             r'WITH\s+FRAME(\s+TITLE)|'

             # simple kombinations
             r'AND\s+(MARK|RETURN)|CLIENT\s+SPECIFIED|CORRESPONDING\s+FIELDS\s+OF|'
             r'IF\s+FOUND|FOR\s+EVENT|INHERITING\s+FROM|LEAVE\s+TO\s+SCREEN|'
             r'LOOP\s+AT\s+(SCREEN)?|LOWER\s+CASE|MATCHCODE\s+OBJECT|MODIF\s+ID|'
             r'MODIFY\s+SCREEN|NESTING\s+LEVEL|NO\s+INTERVALS|OF\s+STRUCTURE|'
             r'RADIOBUTTON\s+GROUP|RANGE\s+OF|REF\s+TO|SUPPRESS DIALOG|'
             r'TABLE\s+OF|UPPER\s+CASE|TRANSPORTING\s+NO\s+FIELDS|'
             r'VALUE\s+CHECK|VISIBLE\s+LENGTH|HEADER\s+LINE)\b', Keyword),

            # single word keywords.
            (r'(^|(?<=(\s|\.)))(ABBREVIATED|ADD|ALIASES|APPEND|ASSERT|'
             r'ASSIGN(ING)?|AT(\s+FIRST)?|'
             r'BACK|BLOCK|BREAK-POINT|'
             r'CASE|CATCH|CHANGING|CHECK|CLASS|CLEAR|COLLECT|COLOR|COMMIT|'
             r'CREATE|COMMUNICATION|COMPONENTS?|COMPUTE|CONCATENATE|CONDENSE|'
             r'CONSTANTS|CONTEXTS|CONTINUE|CONTROLS|'
             r'DATA|DECIMALS|DEFAULT|DEFINE|DEFINITION|DEFERRED|DEMAND|'
             r'DETAIL|DIRECTORY|DIVIDE|DO|'
             r'ELSE(IF)?|ENDAT|ENDCASE|ENDCLASS|ENDDO|ENDFORM|ENDFUNCTION|'
             r'ENDIF|ENDLOOP|ENDMETHOD|ENDMODULE|ENDSELECT|ENDTRY|'
             r'ENHANCEMENT|EVENTS|EXCEPTIONS|EXIT|EXPORT|EXPORTING|EXTRACT|'
             r'FETCH|FIELDS?|FIND|FOR|FORM|FORMAT|FREE|FROM|'
             r'HIDE|'
             r'ID|IF|IMPORT|IMPLEMENTATION|IMPORTING|IN|INCLUDE|INCLUDING|'
             r'INDEX|INFOTYPES|INITIALIZATION|INTERFACE|INTERFACES|INTO|'
             r'LENGTH|LINES|LOAD|LOCAL|'
             r'JOIN|'
             r'KEY|'
             r'MAXIMUM|MESSAGE|METHOD[S]?|MINIMUM|MODULE|MODIFY|MOVE|MULTIPLY|'
             r'NODES|'
             r'OBLIGATORY|OF|OFF|ON|OVERLAY|'
             r'PACK|PARAMETERS|PERCENTAGE|POSITION|PROGRAM|PROVIDE|PUBLIC|PUT|'
             r'RAISE|RAISING|RANGES|READ|RECEIVE|REFRESH|REJECT|REPORT|RESERVE|'
             r'RESUME|RETRY|RETURN|RETURNING|RIGHT|ROLLBACK|'
             r'SCROLL|SEARCH|SELECT|SHIFT|SINGLE|SKIP|SORT|SPLIT|STATICS|STOP|'
             r'SUBMIT|SUBTRACT|SUM|SUMMARY|SUMMING|SUPPLY|'
             r'TABLE|TABLES|TIMES|TITLE|TO|TOP-OF-PAGE|TRANSFER|TRANSLATE|TRY|TYPES|'
             r'ULINE|UNDER|UNPACK|UPDATE|USING|'
             r'VALUE|VALUES|VIA|'
             r'WAIT|WHEN|WHERE|WHILE|WITH|WINDOW|WRITE)\b', Keyword),

             # builtins
            (r'(abs|acos|asin|atan|'
             r'boolc|boolx|bit_set|'
             r'char_off|charlen|ceil|cmax|cmin|condense|contains|'
             r'contains_any_of|contains_any_not_of|concat_lines_of|cos|cosh|'
             r'count|count_any_of|count_any_not_of|'
             r'dbmaxlen|distance|'
             r'escape|exp|'
             r'find|find_end|find_any_of|find_any_not_of|floor|frac|from_mixed|'
             r'insert|'
             r'lines|log|log10|'
             r'match|matches|'
             r'nmax|nmin|numofchar|'
             r'repeat|replace|rescale|reverse|round|'
             r'segment|shift_left|shift_right|sign|sin|sinh|sqrt|strlen|'
             r'substring|substring_after|substring_from|substring_before|substring_to|'
             r'tan|tanh|to_upper|to_lower|to_mixed|translate|trunc|'
             r'xstrlen)(\()\b', bygroups(Name.Builtin, Punctuation)),

            (r'&[0-9]', Name),
            (r'[0-9]+', Number.Integer),

            # operators which look like variable names before
            # parsing variable names.
            (r'(?<=(\s|.))(AND|EQ|NE|GT|LT|GE|LE|CO|CN|CA|NA|CS|NOT|NS|CP|NP|'
             r'BYTE-CO|BYTE-CN|BYTE-CA|BYTE-NA|BYTE-CS|BYTE-NS|'
             r'IS\s+(NOT\s+)?(INITIAL|ASSIGNED|REQUESTED|BOUND))\b', Operator),

            include('variable-names'),

            # standard oparators after variable names,
            # because < and > are part of field symbols.
            (r'[?*<>=\-+]', Operator),
            (r"'(''|[^'])*'", String.Single),
            (r'[/;:()\[\],\.]', Punctuation)
        ],
    }
# -*- coding: utf-8 -*-
"""
    pygments.lexers.parsers
    ~~~~~~~~~~~~~~~~~~~~~~~

    Lexers for parser generators.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re

from pygments.lexer import RegexLexer, DelegatingLexer, \
    include, bygroups, using, this
from pygments.token import Error, Punctuation, Generic, Other, \
    Text, Comment, Operator, Keyword, Name, String, Number, Whitespace
from pygments.lexers.compiled import JavaLexer, CLexer, CppLexer, \
    ObjectiveCLexer, DLexer
from pygments.lexers.dotnet import CSharpLexer
from pygments.lexers.agile import RubyLexer, PythonLexer, PerlLexer
from pygments.lexers.web import ActionScriptLexer
# Use TextLexer during development to just focus on one part of a delegating
# lexer.
from pygments.lexers.special import TextLexer

__all__ = ['RagelLexer', 'RagelEmbeddedLexer', 'RagelCLexer', 'RagelDLexer',
           'RagelCppLexer', 'RagelObjectiveCLexer', 'RagelRubyLexer',
           'RagelJavaLexer', 'AntlrLexer', 'AntlrPythonLexer',
           'AntlrPerlLexer', 'AntlrRubyLexer', 'AntlrCppLexer',
           #'AntlrCLexer',
           'AntlrCSharpLexer', 'AntlrObjectiveCLexer',
           'AntlrJavaLexer', "AntlrActionScriptLexer"]

class RagelLexer(RegexLexer):
    """
    A pure `Ragel <http://www.complang.org/ragel/>`_ lexer.  Use this for
    fragments of Ragel.  For ``.rl`` files, use RagelEmbeddedLexer instead
    (or one of the language-specific subclasses).

    *New in Pygments 1.1*
    """

    name = 'Ragel'
    aliases = ['ragel']
    filenames = []

    tokens = {
        'whitespace': [
            (r'\s+', Whitespace)
        ],
        'comments': [
            (r'\#.*$', Comment),
        ],
        'keywords': [
            (r'(access|action|alphtype)\b', Keyword),
            (r'(getkey|write|machine|include)\b', Keyword),
            (r'(any|ascii|extend|alpha|digit|alnum|lower|upper)\b', Keyword),
            (r'(xdigit|cntrl|graph|print|punct|space|zlen|empty)\b', Keyword)
        ],
        'numbers': [
            (r'0x[0-9A-Fa-f]+', Number.Hex),
            (r'[+-]?[0-9]+', Number.Integer),
        ],
        'literals': [
            (r'"(\\\\|\\"|[^"])*"', String), # double quote string
            (r"'(\\\\|\\'|[^'])*'", String), # single quote string
            (r'\[(\\\\|\\\]|[^\]])*\]', String), # square bracket literals
            (r'/(?!\*)(\\\\|\\/|[^/])*/', String.Regex), # regular expressions
        ],
        'identifiers': [
            (r'[a-zA-Z_][a-zA-Z_0-9]*', Name.Variable),
        ],
        'operators': [
            (r',', Operator), # Join
            (r'\||&|-|--', Operator), # Union, Intersection and Subtraction
            (r'\.|<:|:>|:>>', Operator), # Concatention
            (r':', Operator), # Label
            (r'->', Operator), # Epsilon Transition
            (r'(>|\$|%|<|@|<>)(/|eof\b)', Operator), # EOF Actions
            (r'(>|\$|%|<|@|<>)(!|err\b)', Operator), # Global Error Actions
            (r'(>|\$|%|<|@|<>)(\^|lerr\b)', Operator), # Local Error Actions
            (r'(>|\$|%|<|@|<>)(~|to\b)', Operator), # To-State Actions
            (r'(>|\$|%|<|@|<>)(\*|from\b)', Operator), # From-State Actions
            (r'>|@|\$|%', Operator), # Transition Actions and Priorities
            (r'\*|\?|\+|{[0-9]*,[0-9]*}', Operator), # Repetition
            (r'!|\^', Operator), # Negation
            (r'\(|\)', Operator), # Grouping
        ],
        'root': [
            include('literals'),
            include('whitespace'),
            include('comments'),
            include('keywords'),
            include('numbers'),
            include('identifiers'),
            include('operators'),
            (r'{', Punctuation, 'host'),
            (r'=', Operator),
            (r';', Punctuation),
        ],
        'host': [
            (r'(' + r'|'.join(( # keep host code in largest possible chunks
                r'[^{}\'"/#]+', # exclude unsafe characters
                r'[^\\][\\][{}]', # allow escaped { or }

                # strings and comments may safely contain unsafe characters
                r'"(\\\\|\\"|[^"])*"', # double quote string
                r"'(\\\\|\\'|[^'])*'", # single quote string
                r'//.*$\n?', # single line comment
                r'/\*(.|\n)*?\*/', # multi-line javadoc-style comment
                r'\#.*$\n?', # ruby comment

                # regular expression: There's no reason for it to start
                # with a * and this stops confusion with comments.
                r'/(?!\*)(\\\\|\\/|[^/])*/',

                # / is safe now that we've handled regex and javadoc comments
                r'/',
            )) + r')+', Other),

            (r'{', Punctuation, '#push'),
            (r'}', Punctuation, '#pop'),
        ],
    }

class RagelEmbeddedLexer(RegexLexer):
    """
    A lexer for `Ragel`_ embedded in a host language file.

    This will only highlight Ragel statements. If you want host language
    highlighting then call the language-specific Ragel lexer.

    *New in Pygments 1.1*
    """

    name = 'Embedded Ragel'
    aliases = ['ragel-em']
    filenames = ['*.rl']

    tokens = {
        'root': [
            (r'(' + r'|'.join(( # keep host code in largest possible chunks
                r'[^%\'"/#]+', # exclude unsafe characters
                r'%(?=[^%]|$)', # a single % sign is okay, just not 2 of them

                # strings and comments may safely contain unsafe characters
                r'"(\\\\|\\"|[^"])*"', # double quote string
                r"'(\\\\|\\'|[^'])*'", # single quote string
                r'/\*(.|\n)*?\*/', # multi-line javadoc-style comment
                r'//.*$\n?', # single line comment
                r'\#.*$\n?', # ruby/ragel comment
                r'/(?!\*)(\\\\|\\/|[^/])*/', # regular expression

                # / is safe now that we've handled regex and javadoc comments
                r'/',
            )) + r')+', Other),

            # Single Line FSM.
            # Please don't put a quoted newline in a single line FSM.
            # That's just mean. It will break this.
            (r'(%%)(?![{%])(.*)($|;)(\n?)', bygroups(Punctuation,
                                                     using(RagelLexer),
                                                     Punctuation, Text)),

            # Multi Line FSM.
            (r'(%%%%|%%){', Punctuation, 'multi-line-fsm'),
        ],
        'multi-line-fsm': [
            (r'(' + r'|'.join(( # keep ragel code in largest possible chunks.
                r'(' + r'|'.join((
                    r'[^}\'"\[/#]', # exclude unsafe characters
                    r'}(?=[^%]|$)', # } is okay as long as it's not followed by %
                    r'}%(?=[^%]|$)', # ...well, one %'s okay, just not two...
                    r'[^\\][\\][{}]', # ...and } is okay if it's escaped

                    # allow / if it's preceded with one of these symbols
                    # (ragel EOF actions)
                    r'(>|\$|%|<|@|<>)/',

                    # specifically allow regex followed immediately by *
                    # so it doesn't get mistaken for a comment
                    r'/(?!\*)(\\\\|\\/|[^/])*/\*',

                    # allow / as long as it's not followed by another / or by a *
                    r'/(?=[^/\*]|$)',

                    # We want to match as many of these as we can in one block.
                    # Not sure if we need the + sign here,
                    # does it help performance?
                    )) + r')+',

                # strings and comments may safely contain unsafe characters
                r'"(\\\\|\\"|[^"])*"', # double quote string
                r"'(\\\\|\\'|[^'])*'", # single quote string
                r"\[(\\\\|\\\]|[^\]])*\]", # square bracket literal
                r'/\*(.|\n)*?\*/', # multi-line javadoc-style comment
                r'//.*$\n?', # single line comment
                r'\#.*$\n?', # ruby/ragel comment
            )) + r')+', using(RagelLexer)),

            (r'}%%', Punctuation, '#pop'),
        ]
    }

    def analyse_text(text):
        return '@LANG: indep' in text or 0.1

class RagelRubyLexer(DelegatingLexer):
    """
    A lexer for `Ragel`_ in a Ruby host file.

    *New in Pygments 1.1*
    """

    name = 'Ragel in Ruby Host'
    aliases = ['ragel-ruby', 'ragel-rb']
    filenames = ['*.rl']

    def __init__(self, **options):
        super(RagelRubyLexer, self).__init__(RubyLexer, RagelEmbeddedLexer,
                                              **options)

    def analyse_text(text):
        return '@LANG: ruby' in text

class RagelCLexer(DelegatingLexer):
    """
    A lexer for `Ragel`_ in a C host file.

    *New in Pygments 1.1*
    """

    name = 'Ragel in C Host'
    aliases = ['ragel-c']
    filenames = ['*.rl']

    def __init__(self, **options):
        super(RagelCLexer, self).__init__(CLexer, RagelEmbeddedLexer,
                                          **options)

    def analyse_text(text):
        return '@LANG: c' in text

class RagelDLexer(DelegatingLexer):
    """
    A lexer for `Ragel`_ in a D host file.

    *New in Pygments 1.1*
    """

    name = 'Ragel in D Host'
    aliases = ['ragel-d']
    filenames = ['*.rl']

    def __init__(self, **options):
        super(RagelDLexer, self).__init__(DLexer, RagelEmbeddedLexer, **options)

    def analyse_text(text):
        return '@LANG: d' in text

class RagelCppLexer(DelegatingLexer):
    """
    A lexer for `Ragel`_ in a CPP host file.

    *New in Pygments 1.1*
    """

    name = 'Ragel in CPP Host'
    aliases = ['ragel-cpp']
    filenames = ['*.rl']

    def __init__(self, **options):
        super(RagelCppLexer, self).__init__(CppLexer, RagelEmbeddedLexer, **options)

    def analyse_text(text):
        return '@LANG: c++' in text

class RagelObjectiveCLexer(DelegatingLexer):
    """
    A lexer for `Ragel`_ in an Objective C host file.

    *New in Pygments 1.1*
    """

    name = 'Ragel in Objective C Host'
    aliases = ['ragel-objc']
    filenames = ['*.rl']

    def __init__(self, **options):
        super(RagelObjectiveCLexer, self).__init__(ObjectiveCLexer,
                                                   RagelEmbeddedLexer,
                                                   **options)

    def analyse_text(text):
        return '@LANG: objc' in text

class RagelJavaLexer(DelegatingLexer):
    """
    A lexer for `Ragel`_ in a Java host file.

    *New in Pygments 1.1*
    """

    name = 'Ragel in Java Host'
    aliases = ['ragel-java']
    filenames = ['*.rl']

    def __init__(self, **options):
        super(RagelJavaLexer, self).__init__(JavaLexer, RagelEmbeddedLexer,
                                             **options)

    def analyse_text(text):
        return '@LANG: java' in text

class AntlrLexer(RegexLexer):
    """
    Generic `ANTLR`_ Lexer.
    Should not be called directly, instead
    use DelegatingLexer for your target language.

    *New in Pygments 1.1*

    .. _ANTLR: http://www.antlr.org/
    """

    name = 'ANTLR'
    aliases = ['antlr']
    filenames = []

    _id =          r'[A-Za-z][A-Za-z_0-9]*'
    _TOKEN_REF =   r'[A-Z][A-Za-z_0-9]*'
    _RULE_REF =    r'[a-z][A-Za-z_0-9]*'
    _STRING_LITERAL = r'\'(?:\\\\|\\\'|[^\']*)\''
    _INT = r'[0-9]+'

    tokens = {
        'whitespace': [
            (r'\s+', Whitespace),
        ],
        'comments': [
            (r'//.*$', Comment),
            (r'/\*(.|\n)*?\*/', Comment),
        ],
        'root': [
            include('whitespace'),
            include('comments'),

            (r'(lexer|parser|tree)?(\s*)(grammar\b)(\s*)(' + _id + ')(;)',
             bygroups(Keyword, Whitespace, Keyword, Whitespace, Name.Class,
                      Punctuation)),
            # optionsSpec
            (r'options\b', Keyword, 'options'),
            # tokensSpec
            (r'tokens\b', Keyword, 'tokens'),
            # attrScope
            (r'(scope)(\s*)(' + _id + ')(\s*)({)',
             bygroups(Keyword, Whitespace, Name.Variable, Whitespace,
                      Punctuation), 'action'),
            # exception
            (r'(catch|finally)\b', Keyword, 'exception'),
            # action
            (r'(@' + _id + ')(\s*)(::)?(\s*)(' + _id + ')(\s*)({)',
             bygroups(Name.Label, Whitespace, Punctuation, Whitespace,
                      Name.Label, Whitespace, Punctuation), 'action'),
            # rule
            (r'((?:protected|private|public|fragment)\b)?(\s*)(' + _id + ')(!)?', \
             bygroups(Keyword, Whitespace, Name.Label, Punctuation),
             ('rule-alts', 'rule-prelims')),
        ],
        'exception': [
            (r'\n', Whitespace, '#pop'),
            (r'\s', Whitespace),
            include('comments'),

            (r'\[', Punctuation, 'nested-arg-action'),
            (r'\{', Punctuation, 'action'),
        ],
        'rule-prelims': [
            include('whitespace'),
            include('comments'),

            (r'returns\b', Keyword),
            (r'\[', Punctuation, 'nested-arg-action'),
            (r'\{', Punctuation, 'action'),
            # throwsSpec
            (r'(throws)(\s+)(' + _id + ')',
             bygroups(Keyword, Whitespace, Name.Label)),
            (r'(?:(,)(\s*)(' + _id + '))+',
             bygroups(Punctuation, Whitespace, Name.Label)), # Additional throws
            # optionsSpec
            (r'options\b', Keyword, 'options'),
            # ruleScopeSpec - scope followed by target language code or name of action
            # TODO finish implementing other possibilities for scope
            # L173 ANTLRv3.g from ANTLR book
            (r'(scope)(\s+)({)', bygroups(Keyword, Whitespace, Punctuation),
            'action'),
            (r'(scope)(\s+)(' + _id + ')(\s*)(;)',
             bygroups(Keyword, Whitespace, Name.Label, Whitespace, Punctuation)),
            # ruleAction
            (r'(@' + _id + ')(\s*)({)',
             bygroups(Name.Label, Whitespace, Punctuation), 'action'),
            # finished prelims, go to rule alts!
            (r':', Punctuation, '#pop')
        ],
        'rule-alts': [
            include('whitespace'),
            include('comments'),

            # These might need to go in a separate 'block' state triggered by (
            (r'options\b', Keyword, 'options'),
            (r':', Punctuation),

            # literals
            (r"'(\\\\|\\'|[^'])*'", String),
            (r'"(\\\\|\\"|[^"])*"', String),
            (r'<<([^>]|>[^>])>>', String),
            # identifiers
            # Tokens start with capital letter.
            (r'\$?[A-Z_][A-Za-z_0-9]*', Name.Constant),
            # Rules start with small letter.
            (r'\$?[a-z_][A-Za-z_0-9]*', Name.Variable),
            # operators
            (r'(\+|\||->|=>|=|\(|\)|\.\.|\.|\?|\*|\^|!|\#|~)', Operator),
            (r',', Punctuation),
            (r'\[', Punctuation, 'nested-arg-action'),
            (r'\{', Punctuation, 'action'),
            (r';', Punctuation, '#pop')
        ],
        'tokens': [
            include('whitespace'),
            include('comments'),
            (r'{', Punctuation),
            (r'(' + _TOKEN_REF + r')(\s*)(=)?(\s*)(' + _STRING_LITERAL + ')?(\s*)(;)',
             bygroups(Name.Label, Whitespace, Punctuation, Whitespace,
                      String, Whitespace, Punctuation)),
            (r'}', Punctuation, '#pop'),
        ],
        'options': [
            include('whitespace'),
            include('comments'),
            (r'{', Punctuation),
            (r'(' + _id + r')(\s*)(=)(\s*)(' +
             '|'.join((_id, _STRING_LITERAL, _INT, '\*'))+ ')(\s*)(;)',
             bygroups(Name.Variable, Whitespace, Punctuation, Whitespace,
                      Text, Whitespace, Punctuation)),
            (r'}', Punctuation, '#pop'),
        ],
        'action': [
            (r'(' + r'|'.join(( # keep host code in largest possible chunks
                r'[^\${}\'"/\\]+', # exclude unsafe characters

                # strings and comments may safely contain unsafe characters
                r'"(\\\\|\\"|[^"])*"', # double quote string
                r"'(\\\\|\\'|[^'])*'", # single quote string
                r'//.*$\n?', # single line comment
                r'/\*(.|\n)*?\*/', # multi-line javadoc-style comment

                # regular expression: There's no reason for it to start
                # with a * and this stops confusion with comments.
                r'/(?!\*)(\\\\|\\/|[^/])*/',

                # backslashes are okay, as long as we are not backslashing a %
                r'\\(?!%)',

                # Now that we've handled regex and javadoc comments
                # it's safe to let / through.
                r'/',
            )) + r')+', Other),
            (r'(\\)(%)', bygroups(Punctuation, Other)),
            (r'(\$[a-zA-Z]+)(\.?)(text|value)?',
             bygroups(Name.Variable, Punctuation, Name.Property)),
            (r'{', Punctuation, '#push'),
            (r'}', Punctuation, '#pop'),
        ],
        'nested-arg-action': [
            (r'(' + r'|'.join(( # keep host code in largest possible chunks.
                r'[^\$\[\]\'"/]+', # exclude unsafe characters

                # strings and comments may safely contain unsafe characters
                r'"(\\\\|\\"|[^"])*"', # double quote string
                r"'(\\\\|\\'|[^'])*'", # single quote string
                r'//.*$\n?', # single line comment
                r'/\*(.|\n)*?\*/', # multi-line javadoc-style comment

                # regular expression: There's no reason for it to start
                # with a * and this stops confusion with comments.
                r'/(?!\*)(\\\\|\\/|[^/])*/',

                # Now that we've handled regex and javadoc comments
                # it's safe to let / through.
                r'/',
            )) + r')+', Other),


            (r'\[', Punctuation, '#push'),
            (r'\]', Punctuation, '#pop'),
            (r'(\$[a-zA-Z]+)(\.?)(text|value)?',
             bygroups(Name.Variable, Punctuation, Name.Property)),
            (r'(\\\\|\\\]|\\\[|[^\[\]])+', Other),
        ]
    }

# http://www.antlr.org/wiki/display/ANTLR3/Code+Generation+Targets

# TH: I'm not aware of any language features of C++ that will cause
# incorrect lexing of C files.  Antlr doesn't appear to make a distinction,
# so just assume they're C++.  No idea how to make Objective C work in the
# future.

#class AntlrCLexer(DelegatingLexer):
#    """
#    ANTLR with C Target
#
#    *New in Pygments 1.1*
#    """
#
#    name = 'ANTLR With C Target'
#    aliases = ['antlr-c']
#    filenames = ['*.G', '*.g']
#
#    def __init__(self, **options):
#        super(AntlrCLexer, self).__init__(CLexer, AntlrLexer, **options)
#
#    def analyse_text(text):
#        return re.match(r'^\s*language\s*=\s*C\s*;', text)

class AntlrCppLexer(DelegatingLexer):
    """
    `ANTLR`_ with CPP Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With CPP Target'
    aliases = ['antlr-cpp']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrCppLexer, self).__init__(CppLexer, AntlrLexer, **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*C\s*;', text, re.M)

class AntlrObjectiveCLexer(DelegatingLexer):
    """
    `ANTLR`_ with Objective-C Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With ObjectiveC Target'
    aliases = ['antlr-objc']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrObjectiveCLexer, self).__init__(ObjectiveCLexer,
                                                   AntlrLexer, **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*ObjC\s*;', text)

class AntlrCSharpLexer(DelegatingLexer):
    """
    `ANTLR`_ with C# Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With C# Target'
    aliases = ['antlr-csharp', 'antlr-c#']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrCSharpLexer, self).__init__(CSharpLexer, AntlrLexer,
                                               **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*CSharp2\s*;', text, re.M)

class AntlrPythonLexer(DelegatingLexer):
    """
    `ANTLR`_ with Python Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With Python Target'
    aliases = ['antlr-python']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrPythonLexer, self).__init__(PythonLexer, AntlrLexer,
                                               **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*Python\s*;', text, re.M)


class AntlrJavaLexer(DelegatingLexer):
    """
    `ANTLR`_ with Java Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With Java Target'
    aliases = ['antlr-java']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrJavaLexer, self).__init__(JavaLexer, AntlrLexer,
                                             **options)

    def analyse_text(text):
        return 0.5 # Antlr is Java if not specified


class AntlrRubyLexer(DelegatingLexer):
    """
    `ANTLR`_ with Ruby Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With Ruby Target'
    aliases = ['antlr-ruby', 'antlr-rb']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrRubyLexer, self).__init__(RubyLexer, AntlrLexer,
                                             **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*Ruby\s*;', text, re.M)

class AntlrPerlLexer(DelegatingLexer):
    """
    `ANTLR`_ with Perl Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With Perl Target'
    aliases = ['antlr-perl']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrPerlLexer, self).__init__(PerlLexer, AntlrLexer,
                                             **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*Perl5\s*;', text, re.M)

class AntlrActionScriptLexer(DelegatingLexer):
    """
    `ANTLR`_ with ActionScript Target

    *New in Pygments 1.1*
    """

    name = 'ANTLR With ActionScript Target'
    aliases = ['antlr-as', 'antlr-actionscript']
    filenames = ['*.G', '*.g']

    def __init__(self, **options):
        super(AntlrActionScriptLexer, self).__init__(ActionScriptLexer,
                                                     AntlrLexer, **options)

    def analyse_text(text):
        return re.match(r'^\s*language\s*=\s*ActionScript\s*;', text, re.M)
# -*- coding: utf-8 -*-
"""
    pygments.lexers.special
    ~~~~~~~~~~~~~~~~~~~~~~~

    Special lexers.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
import cStringIO

from pygments.lexer import Lexer
from pygments.token import Token, Error, Text
from pygments.util import get_choice_opt, b


__all__ = ['TextLexer', 'RawTokenLexer']


class TextLexer(Lexer):
    """
    "Null" lexer, doesn't highlight anything.
    """
    name = 'Text only'
    aliases = ['text']
    filenames = ['*.txt']
    mimetypes = ['text/plain']

    def get_tokens_unprocessed(self, text):
        yield 0, Text, text


_ttype_cache = {}

line_re = re.compile(b('.*?\n'))

class RawTokenLexer(Lexer):
    """
    Recreate a token stream formatted with the `RawTokenFormatter`.  This
    lexer raises exceptions during parsing if the token stream in the
    file is malformed.

    Additional options accepted:

    `compress`
        If set to ``"gz"`` or ``"bz2"``, decompress the token stream with
        the given compression algorithm before lexing (default: ``""``).
    """
    name = 'Raw token data'
    aliases = ['raw']
    filenames = []
    mimetypes = ['application/x-pygments-tokens']

    def __init__(self, **options):
        self.compress = get_choice_opt(options, 'compress',
                                       ['', 'none', 'gz', 'bz2'], '')
        Lexer.__init__(self, **options)

    def get_tokens(self, text):
        if isinstance(text, unicode):
            # raw token stream never has any non-ASCII characters
            text = text.encode('ascii')
        if self.compress == 'gz':
            import gzip
            gzipfile = gzip.GzipFile('', 'rb', 9, cStringIO.StringIO(text))
            text = gzipfile.read()
        elif self.compress == 'bz2':
            import bz2
            text = bz2.decompress(text)

        # do not call Lexer.get_tokens() because we do not want Unicode
        # decoding to occur, and stripping is not optional.
        text = text.strip(b('\n')) + b('\n')
        for i, t, v in self.get_tokens_unprocessed(text):
            yield t, v

    def get_tokens_unprocessed(self, text):
        length = 0
        for match in line_re.finditer(text):
            try:
                ttypestr, val = match.group().split(b('\t'), 1)
            except ValueError:
                val = match.group().decode(self.encoding)
                ttype = Error
            else:
                ttype = _ttype_cache.get(ttypestr)
                if not ttype:
                    ttype = Token
                    ttypes = ttypestr.split('.')[1:]
                    for ttype_ in ttypes:
                        if not ttype_ or not ttype_[0].isupper():
                            raise ValueError('malformed token name')
                        ttype = getattr(ttype, ttype_)
                    _ttype_cache[ttypestr] = ttype
                val = val[2:-2].decode('unicode-escape')
            yield length, ttype, val
            length += len(val)
# -*- coding: utf-8 -*-
"""
    pygments.lexers.templates
    ~~~~~~~~~~~~~~~~~~~~~~~~~

    Lexers for various template engines' markup.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.lexers.web import \
     PhpLexer, HtmlLexer, XmlLexer, JavascriptLexer, CssLexer
from pygments.lexers.agile import PythonLexer
from pygments.lexers.compiled import JavaLexer
from pygments.lexer import Lexer, DelegatingLexer, RegexLexer, bygroups, \
     include, using, this
from pygments.token import Error, Punctuation, \
     Text, Comment, Operator, Keyword, Name, String, Number, Other, Token
from pygments.util import html_doctype_matches, looks_like_xml

__all__ = ['HtmlPhpLexer', 'XmlPhpLexer', 'CssPhpLexer',
           'JavascriptPhpLexer', 'ErbLexer', 'RhtmlLexer',
           'XmlErbLexer', 'CssErbLexer', 'JavascriptErbLexer',
           'SmartyLexer', 'HtmlSmartyLexer', 'XmlSmartyLexer',
           'CssSmartyLexer', 'JavascriptSmartyLexer', 'DjangoLexer',
           'HtmlDjangoLexer', 'CssDjangoLexer', 'XmlDjangoLexer',
           'JavascriptDjangoLexer', 'GenshiLexer', 'HtmlGenshiLexer',
           'GenshiTextLexer', 'CssGenshiLexer', 'JavascriptGenshiLexer',
           'MyghtyLexer', 'MyghtyHtmlLexer', 'MyghtyXmlLexer',
           'MyghtyCssLexer', 'MyghtyJavascriptLexer', 'MakoLexer',
           'MakoHtmlLexer', 'MakoXmlLexer', 'MakoJavascriptLexer',
           'MakoCssLexer', 'JspLexer', 'CheetahLexer', 'CheetahHtmlLexer',
           'CheetahXmlLexer', 'CheetahJavascriptLexer',
           'EvoqueLexer', 'EvoqueHtmlLexer', 'EvoqueXmlLexer']


class ErbLexer(Lexer):
    """
    Generic `ERB <http://ruby-doc.org/core/classes/ERB.html>`_ (Ruby Templating)
    lexer.

    Just highlights ruby code between the preprocessor directives, other data
    is left untouched by the lexer.

    All options are also forwarded to the `RubyLexer`.
    """

    name = 'ERB'
    aliases = ['erb']
    mimetypes = ['application/x-ruby-templating']

    _block_re = re.compile(r'(<%%|%%>|<%=|<%#|<%-|<%|-%>|%>|^%[^%].*?$)', re.M)

    def __init__(self, **options):
        from pygments.lexers.agile import RubyLexer
        self.ruby_lexer = RubyLexer(**options)
        Lexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        """
        Since ERB doesn't allow "<%" and other tags inside of ruby
        blocks we have to use a split approach here that fails for
        that too.
        """
        tokens = self._block_re.split(text)
        tokens.reverse()
        state = idx = 0
        try:
            while True:
                # text
                if state == 0:
                    val = tokens.pop()
                    yield idx, Other, val
                    idx += len(val)
                    state = 1
                # block starts
                elif state == 1:
                    tag = tokens.pop()
                    # literals
                    if tag in ('<%%', '%%>'):
                        yield idx, Other, tag
                        idx += 3
                        state = 0
                    # comment
                    elif tag == '<%#':
                        yield idx, Comment.Preproc, tag
                        val = tokens.pop()
                        yield idx + 3, Comment, val
                        idx += 3 + len(val)
                        state = 2
                    # blocks or output
                    elif tag in ('<%', '<%=', '<%-'):
                        yield idx, Comment.Preproc, tag
                        idx += len(tag)
                        data = tokens.pop()
                        r_idx = 0
                        for r_idx, r_token, r_value in \
                            self.ruby_lexer.get_tokens_unprocessed(data):
                            yield r_idx + idx, r_token, r_value
                        idx += len(data)
                        state = 2
                    elif tag in ('%>', '-%>'):
                        yield idx, Error, tag
                        idx += len(tag)
                        state = 0
                    # % raw ruby statements
                    else:
                        yield idx, Comment.Preproc, tag[0]
                        r_idx = 0
                        for r_idx, r_token, r_value in \
                            self.ruby_lexer.get_tokens_unprocessed(tag[1:]):
                            yield idx + 1 + r_idx, r_token, r_value
                        idx += len(tag)
                        state = 0
                # block ends
                elif state == 2:
                    tag = tokens.pop()
                    if tag not in ('%>', '-%>'):
                        yield idx, Other, tag
                    else:
                        yield idx, Comment.Preproc, tag
                    idx += len(tag)
                    state = 0
        except IndexError:
            return

    def analyse_text(text):
        if '<%' in text and '%>' in text:
            return 0.4


class SmartyLexer(RegexLexer):
    """
    Generic `Smarty <http://smarty.php.net/>`_ template lexer.

    Just highlights smarty code between the preprocessor directives, other
    data is left untouched by the lexer.
    """

    name = 'Smarty'
    aliases = ['smarty']
    filenames = ['*.tpl']
    mimetypes = ['application/x-smarty']

    flags = re.MULTILINE | re.DOTALL

    tokens = {
        'root': [
            (r'[^{]+', Other),
            (r'(\{)(\*.*?\*)(\})',
             bygroups(Comment.Preproc, Comment, Comment.Preproc)),
            (r'(\{php\})(.*?)(\{/php\})',
             bygroups(Comment.Preproc, using(PhpLexer, startinline=True),
                      Comment.Preproc)),
            (r'(\{)(/?[a-zA-Z_][a-zA-Z0-9_]*)(\s*)',
             bygroups(Comment.Preproc, Name.Function, Text), 'smarty'),
            (r'\{', Comment.Preproc, 'smarty')
        ],
        'smarty': [
            (r'\s+', Text),
            (r'\}', Comment.Preproc, '#pop'),
            (r'#[a-zA-Z_][a-zA-Z0-9_]*#', Name.Variable),
            (r'\$[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z0-9_]+)*', Name.Variable),
            (r'[~!%^&*()+=|\[\]:;,.<>/?{}@-]', Operator),
            ('(true|false|null)\b', Keyword.Constant),
            (r"[0-9](\.[0-9]*)?(eE[+-][0-9])?[flFLdD]?|"
             r"0[xX][0-9a-fA-F]+[Ll]?", Number),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name.Attribute)
        ]
    }

    def analyse_text(text):
        rv = 0.0
        if re.search('\{if\s+.*?\}.*?\{/if\}', text):
            rv += 0.15
        if re.search('\{include\s+file=.*?\}', text):
            rv += 0.15
        if re.search('\{foreach\s+.*?\}.*?\{/foreach\}', text):
            rv += 0.15
        if re.search('\{\$.*?\}', text):
            rv += 0.01
        return rv


class DjangoLexer(RegexLexer):
    """
    Generic `django <http://www.djangoproject.com/documentation/templates/>`_
    and `jinja <http://wsgiarea.pocoo.org/jinja/>`_ template lexer.

    It just highlights django/jinja code between the preprocessor directives,
    other data is left untouched by the lexer.
    """

    name = 'Django/Jinja'
    aliases = ['django', 'jinja']
    mimetypes = ['application/x-django-templating', 'application/x-jinja']

    flags = re.M | re.S

    tokens = {
        'root': [
            (r'[^{]+', Other),
            (r'\{\{', Comment.Preproc, 'var'),
            # jinja/django comments
            (r'\{[*#].*?[*#]\}', Comment),
            # django comments
            (r'(\{%)(-?\s*)(comment)(\s*-?)(%\})(.*?)'
             r'(\{%)(-?\s*)(endcomment)(\s*-?)(%\})',
             bygroups(Comment.Preproc, Text, Keyword, Text, Comment.Preproc,
                      Comment, Comment.Preproc, Text, Keyword, Text,
                      Comment.Preproc)),
            # raw jinja blocks
            (r'(\{%)(-?\s*)(raw)(\s*-?)(%\})(.*?)'
             r'(\{%)(-?\s*)(endraw)(\s*-?)(%\})',
             bygroups(Comment.Preproc, Text, Keyword, Text, Comment.Preproc,
                      Text, Comment.Preproc, Text, Keyword, Text,
                      Comment.Preproc)),
            # filter blocks
            (r'(\{%)(-?\s*)(filter)(\s+)([a-zA-Z_][a-zA-Z0-9_]*)',
             bygroups(Comment.Preproc, Text, Keyword, Text, Name.Function),
             'block'),
            (r'(\{%)(-?\s*)([a-zA-Z_][a-zA-Z0-9_]*)',
             bygroups(Comment.Preproc, Text, Keyword), 'block'),
            (r'\{', Other)
        ],
        'varnames': [
            (r'(\|)(\s*)([a-zA-Z_][a-zA-Z0-9_]*)',
             bygroups(Operator, Text, Name.Function)),
            (r'(is)(\s+)(not)?(\s+)?([a-zA-Z_][a-zA-Z0-9_]*)',
             bygroups(Keyword, Text, Keyword, Text, Name.Function)),
            (r'(_|true|false|none|True|False|None)\b', Keyword.Pseudo),
            (r'(in|as|reversed|recursive|not|and|or|is|if|else|import|'
             r'with(?:(?:out)?\s*context)?)\b', Keyword),
            (r'(loop|block|super|forloop)\b', Name.Builtin),
            (r'[a-zA-Z][a-zA-Z0-9_]*', Name.Variable),
            (r'\.[a-zA-Z0-9_]+', Name.Variable),
            (r':?"(\\\\|\\"|[^"])*"', String.Double),
            (r":?'(\\\\|\\'|[^'])*'", String.Single),
            (r'([{}()\[\]+\-*/,:]|[><=]=?)', Operator),
            (r"[0-9](\.[0-9]*)?(eE[+-][0-9])?[flFLdD]?|"
             r"0[xX][0-9a-fA-F]+[Ll]?", Number),
        ],
        'var': [
            (r'\s+', Text),
            (r'(-?)(\}\})', bygroups(Text, Comment.Preproc), '#pop'),
            include('varnames')
        ],
        'block': [
            (r'\s+', Text),
            (r'(-?)(%\})', bygroups(Text, Comment.Preproc), '#pop'),
            include('varnames'),
            (r'.', Punctuation)
        ]
    }

    def analyse_text(text):
        rv = 0.0
        if re.search(r'\{%\s*(block|extends)', text) is not None:
            rv += 0.4
        if re.search(r'\{%\s*if\s*.*?%\}', text) is not None:
            rv += 0.1
        if re.search(r'\{\{.*?\}\}', text) is not None:
            rv += 0.1
        return rv


class MyghtyLexer(RegexLexer):
    """
    Generic `myghty templates`_ lexer. Code that isn't Myghty
    markup is yielded as `Token.Other`.

    *New in Pygments 0.6.*

    .. _myghty templates: http://www.myghty.org/
    """

    name = 'Myghty'
    aliases = ['myghty']
    filenames = ['*.myt', 'autodelegate']
    mimetypes = ['application/x-myghty']

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'(<%(def|method))(\s*)(.*?)(>)(.*?)(</%\2\s*>)(?s)',
             bygroups(Name.Tag, None, Text, Name.Function, Name.Tag,
                      using(this), Name.Tag)),
            (r'(<%(\w+))(.*?)(>)(.*?)(</%\2\s*>)(?s)',
             bygroups(Name.Tag, None, Name.Function, Name.Tag,
                      using(PythonLexer), Name.Tag)),
            (r'(<&[^|])(.*?)(,.*?)?(&>)',
             bygroups(Name.Tag, Name.Function, using(PythonLexer), Name.Tag)),
            (r'(<&\|)(.*?)(,.*?)?(&>)(?s)',
             bygroups(Name.Tag, Name.Function, using(PythonLexer), Name.Tag)),
            (r'</&>', Name.Tag),
            (r'(<%!?)(.*?)(%>)(?s)',
             bygroups(Name.Tag, using(PythonLexer), Name.Tag)),
            (r'(?<=^)#[^\n]*(\n|\Z)', Comment),
            (r'(?<=^)(%)([^\n]*)(\n|\Z)',
             bygroups(Name.Tag, using(PythonLexer), Other)),
            (r"""(?sx)
                 (.+?)               # anything, followed by:
                 (?:
                  (?<=\n)(?=[%#]) |  # an eval or comment line
                  (?=</?[%&]) |      # a substitution or block or
                                     # call start or end
                                     # - don't consume
                  (\\\n) |           # an escaped newline
                  \Z                 # end of string
                 )""", bygroups(Other, Operator)),
        ]
    }


class MyghtyHtmlLexer(DelegatingLexer):
    """
    Subclass of the `MyghtyLexer` that highlights unlexer data
    with the `HtmlLexer`.

    *New in Pygments 0.6.*
    """

    name = 'HTML+Myghty'
    aliases = ['html+myghty']
    mimetypes = ['text/html+myghty']

    def __init__(self, **options):
        super(MyghtyHtmlLexer, self).__init__(HtmlLexer, MyghtyLexer,
                                              **options)


class MyghtyXmlLexer(DelegatingLexer):
    """
    Subclass of the `MyghtyLexer` that highlights unlexer data
    with the `XmlLexer`.

    *New in Pygments 0.6.*
    """

    name = 'XML+Myghty'
    aliases = ['xml+myghty']
    mimetypes = ['application/xml+myghty']

    def __init__(self, **options):
        super(MyghtyXmlLexer, self).__init__(XmlLexer, MyghtyLexer,
                                             **options)


class MyghtyJavascriptLexer(DelegatingLexer):
    """
    Subclass of the `MyghtyLexer` that highlights unlexer data
    with the `JavascriptLexer`.

    *New in Pygments 0.6.*
    """

    name = 'JavaScript+Myghty'
    aliases = ['js+myghty', 'javascript+myghty']
    mimetypes = ['application/x-javascript+myghty',
                 'text/x-javascript+myghty',
                 'text/javascript+mygthy']

    def __init__(self, **options):
        super(MyghtyJavascriptLexer, self).__init__(JavascriptLexer,
                                                    MyghtyLexer, **options)


class MyghtyCssLexer(DelegatingLexer):
    """
    Subclass of the `MyghtyLexer` that highlights unlexer data
    with the `CssLexer`.

    *New in Pygments 0.6.*
    """

    name = 'CSS+Myghty'
    aliases = ['css+myghty']
    mimetypes = ['text/css+myghty']

    def __init__(self, **options):
        super(MyghtyCssLexer, self).__init__(CssLexer, MyghtyLexer,
                                             **options)


class MakoLexer(RegexLexer):
    """
    Generic `mako templates`_ lexer. Code that isn't Mako
    markup is yielded as `Token.Other`.

    *New in Pygments 0.7.*

    .. _mako templates: http://www.makotemplates.org/
    """

    name = 'Mako'
    aliases = ['mako']
    filenames = ['*.mao']
    mimetypes = ['application/x-mako']

    tokens = {
        'root': [
            (r'(\s*)(%)(\s*end(?:\w+))(\n|\Z)',
             bygroups(Text, Comment.Preproc, Keyword, Other)),
            (r'(\s*)(%)([^\n]*)(\n|\Z)',
             bygroups(Text, Comment.Preproc, using(PythonLexer), Other)),
            (r'(\s*)(##[^\n]*)(\n|\Z)',
             bygroups(Text, Comment.Preproc, Other)),
            (r'(?s)<%doc>.*?</%doc>', Comment.Preproc),
            (r'(<%)([\w\.\:]+)',
             bygroups(Comment.Preproc, Name.Builtin), 'tag'),
            (r'(</%)([\w\.\:]+)(>)',
             bygroups(Comment.Preproc, Name.Builtin, Comment.Preproc)),
            (r'<%(?=([\w\.\:]+))', Comment.Preproc, 'ondeftags'),
            (r'(<%(?:!?))(.*?)(%>)(?s)',
             bygroups(Comment.Preproc, using(PythonLexer), Comment.Preproc)),
            (r'(\$\{)(.*?)(\})',
             bygroups(Comment.Preproc, using(PythonLexer), Comment.Preproc)),
            (r'''(?sx)
                (.+?)                # anything, followed by:
                (?:
<<<<<<< local
                 (?<=\n)(?=%|\#\#) |# an eval or comment line
                 (?=\#\*) |         # multiline comment
                 (?=</?%) |         # a python block
                                    # call start or end
                 (?=\$\{) |         # a substitution
=======
                 (?<=\n)(?=%|\#\#) | # an eval or comment line
                 (?=\#\*) |          # multiline comment
                 (?=</?%) |          # a python block
                                     # call start or end
                 (?=\$\{) |          # a substitution
>>>>>>> other
                 (?<=\n)(?=\s*%) |
                                     # - don't consume
                 (\\\n) |            # an escaped newline
                 \Z                  # end of string
                )
            ''', bygroups(Other, Operator)),
            (r'\s+', Text),
        ],
        'ondeftags': [
            (r'<%', Comment.Preproc),
            (r'(?<=<%)(include|inherit|namespace|page)', Name.Builtin),
            include('tag'),
        ],
        'tag': [
            (r'((?:\w+)\s*=)\s*(".*?")',
             bygroups(Name.Attribute, String)),
            (r'/?\s*>', Comment.Preproc, '#pop'),
            (r'\s+', Text),
        ],
        'attr': [
            ('".*?"', String, '#pop'),
            ("'.*?'", String, '#pop'),
            (r'[^\s>]+', String, '#pop'),
        ],
    }


class MakoHtmlLexer(DelegatingLexer):
    """
    Subclass of the `MakoLexer` that highlights unlexed data
    with the `HtmlLexer`.

    *New in Pygments 0.7.*
    """

    name = 'HTML+Mako'
    aliases = ['html+mako']
    mimetypes = ['text/html+mako']

    def __init__(self, **options):
        super(MakoHtmlLexer, self).__init__(HtmlLexer, MakoLexer,
                                              **options)

class MakoXmlLexer(DelegatingLexer):
    """
    Subclass of the `MakoLexer` that highlights unlexer data
    with the `XmlLexer`.

    *New in Pygments 0.7.*
    """

    name = 'XML+Mako'
    aliases = ['xml+mako']
    mimetypes = ['application/xml+mako']

    def __init__(self, **options):
        super(MakoXmlLexer, self).__init__(XmlLexer, MakoLexer,
                                             **options)

class MakoJavascriptLexer(DelegatingLexer):
    """
    Subclass of the `MakoLexer` that highlights unlexer data
    with the `JavascriptLexer`.

    *New in Pygments 0.7.*
    """

    name = 'JavaScript+Mako'
    aliases = ['js+mako', 'javascript+mako']
    mimetypes = ['application/x-javascript+mako',
                 'text/x-javascript+mako',
                 'text/javascript+mako']

    def __init__(self, **options):
        super(MakoJavascriptLexer, self).__init__(JavascriptLexer,
                                                    MakoLexer, **options)

class MakoCssLexer(DelegatingLexer):
    """
    Subclass of the `MakoLexer` that highlights unlexer data
    with the `CssLexer`.

    *New in Pygments 0.7.*
    """

    name = 'CSS+Mako'
    aliases = ['css+mako']
    mimetypes = ['text/css+mako']

    def __init__(self, **options):
        super(MakoCssLexer, self).__init__(CssLexer, MakoLexer,
                                             **options)


# Genshi and Cheetah lexers courtesy of Matt Good.

class CheetahPythonLexer(Lexer):
    """
    Lexer for handling Cheetah's special $ tokens in Python syntax.
    """

    def get_tokens_unprocessed(self, text):
        pylexer = PythonLexer(**self.options)
        for pos, type_, value in pylexer.get_tokens_unprocessed(text):
            if type_ == Token.Error and value == '$':
                type_ = Comment.Preproc
            yield pos, type_, value


class CheetahLexer(RegexLexer):
    """
    Generic `cheetah templates`_ lexer. Code that isn't Cheetah
    markup is yielded as `Token.Other`.  This also works for
    `spitfire templates`_ which use the same syntax.

    .. _cheetah templates: http://www.cheetahtemplate.org/
    .. _spitfire templates: http://code.google.com/p/spitfire/
    """

    name = 'Cheetah'
    aliases = ['cheetah', 'spitfire']
    filenames = ['*.tmpl', '*.spt']
    mimetypes = ['application/x-cheetah', 'application/x-spitfire']

    tokens = {
        'root': [
            (r'(##[^\n]*)$',
             (bygroups(Comment))),
            (r'#[*](.|\n)*?[*]#', Comment),
            (r'#end[^#\n]*(?:#|$)', Comment.Preproc),
            (r'#slurp$', Comment.Preproc),
            (r'(#[a-zA-Z]+)([^#\n]*)(#|$)',
             (bygroups(Comment.Preproc, using(CheetahPythonLexer),
                       Comment.Preproc))),
            # TODO support other Python syntax like $foo['bar']
            (r'(\$)([a-zA-Z_][a-zA-Z0-9_\.]*[a-zA-Z0-9_])',
             bygroups(Comment.Preproc, using(CheetahPythonLexer))),
            (r'(\$\{!?)(.*?)(\})(?s)',
             bygroups(Comment.Preproc, using(CheetahPythonLexer),
                      Comment.Preproc)),
            (r'''(?sx)
                (.+?)               # anything, followed by:
                (?:
                 (?=[#][#a-zA-Z]*) |   # an eval comment
                 (?=\$[a-zA-Z_{]) | # a substitution
                 \Z                 # end of string
                )
            ''', Other),
            (r'\s+', Text),
        ],
    }


class CheetahHtmlLexer(DelegatingLexer):
    """
    Subclass of the `CheetahLexer` that highlights unlexer data
    with the `HtmlLexer`.
    """

    name = 'HTML+Cheetah'
    aliases = ['html+cheetah', 'html+spitfire']
    mimetypes = ['text/html+cheetah', 'text/html+spitfire']

    def __init__(self, **options):
        super(CheetahHtmlLexer, self).__init__(HtmlLexer, CheetahLexer,
                                               **options)


class CheetahXmlLexer(DelegatingLexer):
    """
    Subclass of the `CheetahLexer` that highlights unlexer data
    with the `XmlLexer`.
    """

    name = 'XML+Cheetah'
    aliases = ['xml+cheetah', 'xml+spitfire']
    mimetypes = ['application/xml+cheetah', 'application/xml+spitfire']

    def __init__(self, **options):
        super(CheetahXmlLexer, self).__init__(XmlLexer, CheetahLexer,
                                              **options)


class CheetahJavascriptLexer(DelegatingLexer):
    """
    Subclass of the `CheetahLexer` that highlights unlexer data
    with the `JavascriptLexer`.
    """

    name = 'JavaScript+Cheetah'
    aliases = ['js+cheetah', 'javascript+cheetah',
               'js+spitfire', 'javascript+spitfire']
    mimetypes = ['application/x-javascript+cheetah',
                 'text/x-javascript+cheetah',
                 'text/javascript+cheetah',
                 'application/x-javascript+spitfire',
                 'text/x-javascript+spitfire',
                 'text/javascript+spitfire']

    def __init__(self, **options):
        super(CheetahJavascriptLexer, self).__init__(JavascriptLexer,
                                                     CheetahLexer, **options)


class GenshiTextLexer(RegexLexer):
    """
    A lexer that highlights `genshi <http://genshi.edgewall.org/>`_ text
    templates.
    """

    name = 'Genshi Text'
    aliases = ['genshitext']
    mimetypes = ['application/x-genshi-text', 'text/x-genshi']

    tokens = {
        'root': [
            (r'[^#\$\s]+', Other),
            (r'^(\s*)(##.*)$', bygroups(Text, Comment)),
            (r'^(\s*)(#)', bygroups(Text, Comment.Preproc), 'directive'),
            include('variable'),
            (r'[#\$\s]', Other),
        ],
        'directive': [
            (r'\n', Text, '#pop'),
            (r'(?:def|for|if)\s+.*', using(PythonLexer), '#pop'),
            (r'(choose|when|with)([^\S\n]+)(.*)',
             bygroups(Keyword, Text, using(PythonLexer)), '#pop'),
            (r'(choose|otherwise)\b', Keyword, '#pop'),
            (r'(end\w*)([^\S\n]*)(.*)', bygroups(Keyword, Text, Comment), '#pop'),
        ],
        'variable': [
            (r'(?<!\$)(\$\{)(.+?)(\})',
             bygroups(Comment.Preproc, using(PythonLexer), Comment.Preproc)),
            (r'(?<!\$)(\$)([a-zA-Z_][a-zA-Z0-9_\.]*)',
             Name.Variable),
        ]
    }


class GenshiMarkupLexer(RegexLexer):
    """
    Base lexer for Genshi markup, used by `HtmlGenshiLexer` and
    `GenshiLexer`.
    """

    flags = re.DOTALL

    tokens = {
        'root': [
            (r'[^<\$]+', Other),
            (r'(<\?python)(.*?)(\?>)',
             bygroups(Comment.Preproc, using(PythonLexer), Comment.Preproc)),
            # yield style and script blocks as Other
            (r'<\s*(script|style)\s*.*?>.*?<\s*/\1\s*>', Other),
            (r'<\s*py:[a-zA-Z0-9]+', Name.Tag, 'pytag'),
            (r'<\s*[a-zA-Z0-9:]+', Name.Tag, 'tag'),
            include('variable'),
            (r'[<\$]', Other),
        ],
        'pytag': [
            (r'\s+', Text),
            (r'[a-zA-Z0-9_:-]+\s*=', Name.Attribute, 'pyattr'),
            (r'/?\s*>', Name.Tag, '#pop'),
        ],
        'pyattr': [
            ('(")(.*?)(")', bygroups(String, using(PythonLexer), String), '#pop'),
            ("(')(.*?)(')", bygroups(String, using(PythonLexer), String), '#pop'),
            (r'[^\s>]+', String, '#pop'),
        ],
        'tag': [
            (r'\s+', Text),
            (r'py:[a-zA-Z0-9_-]+\s*=', Name.Attribute, 'pyattr'),
            (r'[a-zA-Z0-9_:-]+\s*=', Name.Attribute, 'attr'),
            (r'/?\s*>', Name.Tag, '#pop'),
        ],
        'attr': [
            ('"', String, 'attr-dstring'),
            ("'", String, 'attr-sstring'),
            (r'[^\s>]*', String, '#pop')
        ],
        'attr-dstring': [
            ('"', String, '#pop'),
            include('strings'),
            ("'", String)
        ],
        'attr-sstring': [
            ("'", String, '#pop'),
            include('strings'),
            ("'", String)
        ],
        'strings': [
            ('[^"\'$]+', String),
            include('variable')
        ],
        'variable': [
            (r'(?<!\$)(\$\{)(.+?)(\})',
             bygroups(Comment.Preproc, using(PythonLexer), Comment.Preproc)),
            (r'(?<!\$)(\$)([a-zA-Z_][a-zA-Z0-9_\.]*)',
             Name.Variable),
        ]
    }


class HtmlGenshiLexer(DelegatingLexer):
    """
    A lexer that highlights `genshi <http://genshi.edgewall.org/>`_ and
    `kid <http://kid-templating.org/>`_ kid HTML templates.
    """

    name = 'HTML+Genshi'
    aliases = ['html+genshi', 'html+kid']
    alias_filenames = ['*.html', '*.htm', '*.xhtml']
    mimetypes = ['text/html+genshi']

    def __init__(self, **options):
        super(HtmlGenshiLexer, self).__init__(HtmlLexer, GenshiMarkupLexer,
                                              **options)

    def analyse_text(text):
        rv = 0.0
        if re.search('\$\{.*?\}', text) is not None:
            rv += 0.2
        if re.search('py:(.*?)=["\']', text) is not None:
            rv += 0.2
        return rv + HtmlLexer.analyse_text(text) - 0.01


class GenshiLexer(DelegatingLexer):
    """
    A lexer that highlights `genshi <http://genshi.edgewall.org/>`_ and
    `kid <http://kid-templating.org/>`_ kid XML templates.
    """

    name = 'Genshi'
    aliases = ['genshi', 'kid', 'xml+genshi', 'xml+kid']
    filenames = ['*.kid']
    alias_filenames = ['*.xml']
    mimetypes = ['application/x-genshi', 'application/x-kid']

    def __init__(self, **options):
        super(GenshiLexer, self).__init__(XmlLexer, GenshiMarkupLexer,
                                          **options)

    def analyse_text(text):
        rv = 0.0
        if re.search('\$\{.*?\}', text) is not None:
            rv += 0.2
        if re.search('py:(.*?)=["\']', text) is not None:
            rv += 0.2
        return rv + XmlLexer.analyse_text(text) - 0.01


class JavascriptGenshiLexer(DelegatingLexer):
    """
    A lexer that highlights javascript code in genshi text templates.
    """

    name = 'JavaScript+Genshi Text'
    aliases = ['js+genshitext', 'js+genshi', 'javascript+genshitext',
               'javascript+genshi']
    alias_filenames = ['*.js']
    mimetypes = ['application/x-javascript+genshi',
                 'text/x-javascript+genshi',
                 'text/javascript+genshi']

    def __init__(self, **options):
        super(JavascriptGenshiLexer, self).__init__(JavascriptLexer,
                                                    GenshiTextLexer,
                                                    **options)

    def analyse_text(text):
        return GenshiLexer.analyse_text(text) - 0.05


class CssGenshiLexer(DelegatingLexer):
    """
    A lexer that highlights CSS definitions in genshi text templates.
    """

    name = 'CSS+Genshi Text'
    aliases = ['css+genshitext', 'css+genshi']
    alias_filenames = ['*.css']
    mimetypes = ['text/css+genshi']

    def __init__(self, **options):
        super(CssGenshiLexer, self).__init__(CssLexer, GenshiTextLexer,
                                             **options)

    def analyse_text(text):
        return GenshiLexer.analyse_text(text) - 0.05


class RhtmlLexer(DelegatingLexer):
    """
    Subclass of the ERB lexer that highlights the unlexed data with the
    html lexer.

    Nested Javascript and CSS is highlighted too.
    """

    name = 'RHTML'
    aliases = ['rhtml', 'html+erb', 'html+ruby']
    filenames = ['*.rhtml']
    alias_filenames = ['*.html', '*.htm', '*.xhtml']
    mimetypes = ['text/html+ruby']

    def __init__(self, **options):
        super(RhtmlLexer, self).__init__(HtmlLexer, ErbLexer, **options)

    def analyse_text(text):
        rv = ErbLexer.analyse_text(text) - 0.01
        if html_doctype_matches(text):
            # one more than the XmlErbLexer returns
            rv += 0.5
        return rv


class XmlErbLexer(DelegatingLexer):
    """
    Subclass of `ErbLexer` which highlights data outside preprocessor
    directives with the `XmlLexer`.
    """

    name = 'XML+Ruby'
    aliases = ['xml+erb', 'xml+ruby']
    alias_filenames = ['*.xml']
    mimetypes = ['application/xml+ruby']

    def __init__(self, **options):
        super(XmlErbLexer, self).__init__(XmlLexer, ErbLexer, **options)

    def analyse_text(text):
        rv = ErbLexer.analyse_text(text) - 0.01
        if looks_like_xml(text):
            rv += 0.4
        return rv


class CssErbLexer(DelegatingLexer):
    """
    Subclass of `ErbLexer` which highlights unlexed data with the `CssLexer`.
    """

    name = 'CSS+Ruby'
    aliases = ['css+erb', 'css+ruby']
    alias_filenames = ['*.css']
    mimetypes = ['text/css+ruby']

    def __init__(self, **options):
        super(CssErbLexer, self).__init__(CssLexer, ErbLexer, **options)

    def analyse_text(text):
        return ErbLexer.analyse_text(text) - 0.05


class JavascriptErbLexer(DelegatingLexer):
    """
    Subclass of `ErbLexer` which highlights unlexed data with the
    `JavascriptLexer`.
    """

    name = 'JavaScript+Ruby'
    aliases = ['js+erb', 'javascript+erb', 'js+ruby', 'javascript+ruby']
    alias_filenames = ['*.js']
    mimetypes = ['application/x-javascript+ruby',
                 'text/x-javascript+ruby',
                 'text/javascript+ruby']

    def __init__(self, **options):
        super(JavascriptErbLexer, self).__init__(JavascriptLexer, ErbLexer,
                                                 **options)

    def analyse_text(text):
        return ErbLexer.analyse_text(text) - 0.05


class HtmlPhpLexer(DelegatingLexer):
    """
    Subclass of `PhpLexer` that highlights unhandled data with the `HtmlLexer`.

    Nested Javascript and CSS is highlighted too.
    """

    name = 'HTML+PHP'
    aliases = ['html+php']
    filenames = ['*.phtml']
    alias_filenames = ['*.php', '*.html', '*.htm', '*.xhtml',
                       '*.php[345]']
    mimetypes = ['application/x-php',
                 'application/x-httpd-php', 'application/x-httpd-php3',
                 'application/x-httpd-php4', 'application/x-httpd-php5']

    def __init__(self, **options):
        super(HtmlPhpLexer, self).__init__(HtmlLexer, PhpLexer, **options)

    def analyse_text(text):
        rv = PhpLexer.analyse_text(text) - 0.01
        if html_doctype_matches(text):
            rv += 0.5
        return rv


class XmlPhpLexer(DelegatingLexer):
    """
    Subclass of `PhpLexer` that higlights unhandled data with the `XmlLexer`.
    """

    name = 'XML+PHP'
    aliases = ['xml+php']
    alias_filenames = ['*.xml', '*.php', '*.php[345]']
    mimetypes = ['application/xml+php']

    def __init__(self, **options):
        super(XmlPhpLexer, self).__init__(XmlLexer, PhpLexer, **options)

    def analyse_text(text):
        rv = PhpLexer.analyse_text(text) - 0.01
        if looks_like_xml(text):
            rv += 0.4
        return rv


class CssPhpLexer(DelegatingLexer):
    """
    Subclass of `PhpLexer` which highlights unmatched data with the `CssLexer`.
    """

    name = 'CSS+PHP'
    aliases = ['css+php']
    alias_filenames = ['*.css']
    mimetypes = ['text/css+php']

    def __init__(self, **options):
        super(CssPhpLexer, self).__init__(CssLexer, PhpLexer, **options)

    def analyse_text(text):
        return PhpLexer.analyse_text(text) - 0.05


class JavascriptPhpLexer(DelegatingLexer):
    """
    Subclass of `PhpLexer` which highlights unmatched data with the
    `JavascriptLexer`.
    """

    name = 'JavaScript+PHP'
    aliases = ['js+php', 'javascript+php']
    alias_filenames = ['*.js']
    mimetypes = ['application/x-javascript+php',
                 'text/x-javascript+php',
                 'text/javascript+php']

    def __init__(self, **options):
        super(JavascriptPhpLexer, self).__init__(JavascriptLexer, PhpLexer,
                                                 **options)

    def analyse_text(text):
        return PhpLexer.analyse_text(text)


class HtmlSmartyLexer(DelegatingLexer):
    """
    Subclass of the `SmartyLexer` that highighlights unlexed data with the
    `HtmlLexer`.

    Nested Javascript and CSS is highlighted too.
    """

    name = 'HTML+Smarty'
    aliases = ['html+smarty']
    alias_filenames = ['*.html', '*.htm', '*.xhtml', '*.tpl']
    mimetypes = ['text/html+smarty']

    def __init__(self, **options):
        super(HtmlSmartyLexer, self).__init__(HtmlLexer, SmartyLexer, **options)

    def analyse_text(text):
        rv = SmartyLexer.analyse_text(text) - 0.01
        if html_doctype_matches(text):
            rv += 0.5
        return rv


class XmlSmartyLexer(DelegatingLexer):
    """
    Subclass of the `SmartyLexer` that highlights unlexed data with the
    `XmlLexer`.
    """

    name = 'XML+Smarty'
    aliases = ['xml+smarty']
    alias_filenames = ['*.xml', '*.tpl']
    mimetypes = ['application/xml+smarty']

    def __init__(self, **options):
        super(XmlSmartyLexer, self).__init__(XmlLexer, SmartyLexer, **options)

    def analyse_text(text):
        rv = SmartyLexer.analyse_text(text) - 0.01
        if looks_like_xml(text):
            rv += 0.4
        return rv


class CssSmartyLexer(DelegatingLexer):
    """
    Subclass of the `SmartyLexer` that highlights unlexed data with the
    `CssLexer`.
    """

    name = 'CSS+Smarty'
    aliases = ['css+smarty']
    alias_filenames = ['*.css', '*.tpl']
    mimetypes = ['text/css+smarty']

    def __init__(self, **options):
        super(CssSmartyLexer, self).__init__(CssLexer, SmartyLexer, **options)

    def analyse_text(text):
        return SmartyLexer.analyse_text(text) - 0.05


class JavascriptSmartyLexer(DelegatingLexer):
    """
    Subclass of the `SmartyLexer` that highlights unlexed data with the
    `JavascriptLexer`.
    """

    name = 'JavaScript+Smarty'
    aliases = ['js+smarty', 'javascript+smarty']
    alias_filenames = ['*.js', '*.tpl']
    mimetypes = ['application/x-javascript+smarty',
                 'text/x-javascript+smarty',
                 'text/javascript+smarty']

    def __init__(self, **options):
        super(JavascriptSmartyLexer, self).__init__(JavascriptLexer, SmartyLexer,
                                                    **options)

    def analyse_text(text):
        return SmartyLexer.analyse_text(text) - 0.05


class HtmlDjangoLexer(DelegatingLexer):
    """
    Subclass of the `DjangoLexer` that highighlights unlexed data with the
    `HtmlLexer`.

    Nested Javascript and CSS is highlighted too.
    """

    name = 'HTML+Django/Jinja'
    aliases = ['html+django', 'html+jinja']
    alias_filenames = ['*.html', '*.htm', '*.xhtml']
    mimetypes = ['text/html+django', 'text/html+jinja']

    def __init__(self, **options):
        super(HtmlDjangoLexer, self).__init__(HtmlLexer, DjangoLexer, **options)

    def analyse_text(text):
        rv = DjangoLexer.analyse_text(text) - 0.01
        if html_doctype_matches(text):
            rv += 0.5
        return rv


class XmlDjangoLexer(DelegatingLexer):
    """
    Subclass of the `DjangoLexer` that highlights unlexed data with the
    `XmlLexer`.
    """

    name = 'XML+Django/Jinja'
    aliases = ['xml+django', 'xml+jinja']
    alias_filenames = ['*.xml']
    mimetypes = ['application/xml+django', 'application/xml+jinja']

    def __init__(self, **options):
        super(XmlDjangoLexer, self).__init__(XmlLexer, DjangoLexer, **options)

    def analyse_text(text):
        rv = DjangoLexer.analyse_text(text) - 0.01
        if looks_like_xml(text):
            rv += 0.4
        return rv


class CssDjangoLexer(DelegatingLexer):
    """
    Subclass of the `DjangoLexer` that highlights unlexed data with the
    `CssLexer`.
    """

    name = 'CSS+Django/Jinja'
    aliases = ['css+django', 'css+jinja']
    alias_filenames = ['*.css']
    mimetypes = ['text/css+django', 'text/css+jinja']

    def __init__(self, **options):
        super(CssDjangoLexer, self).__init__(CssLexer, DjangoLexer, **options)

    def analyse_text(text):
        return DjangoLexer.analyse_text(text) - 0.05


class JavascriptDjangoLexer(DelegatingLexer):
    """
    Subclass of the `DjangoLexer` that highlights unlexed data with the
    `JavascriptLexer`.
    """

    name = 'JavaScript+Django/Jinja'
    aliases = ['js+django', 'javascript+django',
               'js+jinja', 'javascript+jinja']
    alias_filenames = ['*.js']
    mimetypes = ['application/x-javascript+django',
                 'application/x-javascript+jinja',
                 'text/x-javascript+django',
                 'text/x-javascript+jinja',
                 'text/javascript+django',
                 'text/javascript+jinja']

    def __init__(self, **options):
        super(JavascriptDjangoLexer, self).__init__(JavascriptLexer, DjangoLexer,
                                                    **options)

    def analyse_text(text):
        return DjangoLexer.analyse_text(text) - 0.05


class JspRootLexer(RegexLexer):
    """
    Base for the `JspLexer`. Yields `Token.Other` for area outside of
    JSP tags.

    *New in Pygments 0.7.*
    """

    tokens = {
        'root': [
            (r'<%\S?', Keyword, 'sec'),
            # FIXME: I want to make these keywords but still parse attributes.
            (r'</?jsp:(forward|getProperty|include|plugin|setProperty|useBean).*?>',
             Keyword),
            (r'[^<]+', Other),
            (r'<', Other),
        ],
        'sec': [
            (r'%>', Keyword, '#pop'),
            # note: '\w\W' != '.' without DOTALL.
            (r'[\w\W]+?(?=%>|\Z)', using(JavaLexer)),
        ],
    }


class JspLexer(DelegatingLexer):
    """
    Lexer for Java Server Pages.

    *New in Pygments 0.7.*
    """
    name = 'Java Server Page'
    aliases = ['jsp']
    filenames = ['*.jsp']
    mimetypes = ['application/x-jsp']

    def __init__(self, **options):
        super(JspLexer, self).__init__(XmlLexer, JspRootLexer, **options)

    def analyse_text(text):
        rv = JavaLexer.analyse_text(text) - 0.01
        if looks_like_xml(text):
            rv += 0.4
        if '<%' in text and '%>' in text:
            rv += 0.1
        return rv


class EvoqueLexer(RegexLexer):
    """
    For files using the Evoque templating system.

    *New in Pygments 1.1.*
    """
    name = 'Evoque'
    aliases = ['evoque']
    filenames = ['*.evoque']
    mimetypes = ['application/x-evoque']

    flags = re.DOTALL

    tokens = {
        'root': [
            (r'[^#$]+', Other),
            (r'#\[', Comment.Multiline, 'comment'),
            (r'\$\$', Other),
            # svn keywords
            (r'\$\w+:[^$\n]*\$', Comment.Multiline),
            # directives: begin, end
            (r'(\$)(begin|end)(\{(%)?)(.*?)((?(4)%)\})',
             bygroups(Punctuation, Name.Builtin, Punctuation, None,
                      String, Punctuation, None)),
            # directives: evoque, overlay
            # see doc for handling first name arg: /directives/evoque/
            #+ minor inconsistency: the "name" in e.g. $overlay{name=site_base}
            # should be using(PythonLexer), not passed out as String
            (r'(\$)(evoque|overlay)(\{(%)?)(\s*[#\w\-"\'.]+[^=,%}]+?)?'
             r'(.*?)((?(4)%)\})',
             bygroups(Punctuation, Name.Builtin, Punctuation, None,
                      String, using(PythonLexer), Punctuation, None)),
            # directives: if, for, prefer, test
            (r'(\$)(\w+)(\{(%)?)(.*?)((?(4)%)\})',
             bygroups(Punctuation, Name.Builtin, Punctuation, None,
                      using(PythonLexer), Punctuation, None)),
            # directive clauses (no {} expression)
            (r'(\$)(else|rof|fi)', bygroups(Punctuation, Name.Builtin)),
            # expressions
            (r'(\$\{(%)?)(.*?)((!)(.*?))?((?(2)%)\})',
             bygroups(Punctuation, None, using(PythonLexer),
                      Name.Builtin, None, None, Punctuation, None)),
            (r'#', Other),
        ],
        'comment': [
            (r'[^\]#]', Comment.Multiline),
            (r'#\[', Comment.Multiline, '#push'),
            (r'\]#', Comment.Multiline, '#pop'),
            (r'[\]#]', Comment.Multiline)
        ],
    }

class EvoqueHtmlLexer(DelegatingLexer):
    """
    Subclass of the `EvoqueLexer` that highlights unlexed data with the
    `HtmlLexer`.

    *New in Pygments 1.1.*
    """
    name = 'HTML+Evoque'
    aliases = ['html+evoque']
    filenames = ['*.html']
    mimetypes = ['text/html+evoque']

    def __init__(self, **options):
        super(EvoqueHtmlLexer, self).__init__(HtmlLexer, EvoqueLexer,
                                              **options)

class EvoqueXmlLexer(DelegatingLexer):
    """
    Subclass of the `EvoqueLexer` that highlights unlexed data with the
    `XmlLexer`.

    *New in Pygments 1.1.*
    """
    name = 'XML+Evoque'
    aliases = ['xml+evoque']
    filenames = ['*.xml']
    mimetypes = ['application/xml+evoque']

    def __init__(self, **options):
        super(EvoqueXmlLexer, self).__init__(XmlLexer, EvoqueLexer,
                                             **options)
# -*- coding: utf-8 -*-
"""
    pygments.lexers.text
    ~~~~~~~~~~~~~~~~~~~~

    Lexers for non-source code file types.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set
from bisect import bisect

from pygments.lexer import Lexer, LexerContext, RegexLexer, ExtendedRegexLexer, \
     bygroups, include, using, this, do_insertions
from pygments.token import Punctuation, Text, Comment, Keyword, Name, String, \
     Generic, Operator, Number, Whitespace, Literal
from pygments.util import get_bool_opt
from pygments.lexers.other import BashLexer

__all__ = ['IniLexer', 'SourcesListLexer', 'BaseMakefileLexer',
           'MakefileLexer', 'DiffLexer', 'IrcLogsLexer', 'TexLexer',
           'GroffLexer', 'ApacheConfLexer', 'BBCodeLexer', 'MoinWikiLexer',
           'RstLexer', 'VimLexer', 'GettextLexer', 'SquidConfLexer',
           'DebianControlLexer', 'DarcsPatchLexer', 'YamlLexer',
           'LighttpdConfLexer', 'NginxConfLexer']


class IniLexer(RegexLexer):
    """
    Lexer for configuration files in INI style.
    """

    name = 'INI'
    aliases = ['ini', 'cfg']
    filenames = ['*.ini', '*.cfg', '*.properties']
    mimetypes = ['text/x-ini']

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'[;#].*?$', Comment),
            (r'\[.*?\]$', Keyword),
            (r'(.*?)([ \t]*)(=)([ \t]*)(.*?)$',
             bygroups(Name.Attribute, Text, Operator, Text, String))
        ]
    }

    def analyse_text(text):
        npos = text.find('\n')
        if npos < 3:
            return False
        return text[0] == '[' and text[npos-1] == ']'


class SourcesListLexer(RegexLexer):
    """
    Lexer that highlights debian sources.list files.

    *New in Pygments 0.7.*
    """

    name = 'Debian Sourcelist'
    aliases = ['sourceslist', 'sources.list']
    filenames = ['sources.list']
    mimetype = ['application/x-debian-sourceslist']

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'#.*?$', Comment),
            (r'^(deb(?:-src)?)(\s+)',
             bygroups(Keyword, Text), 'distribution')
        ],
        'distribution': [
            (r'#.*?$', Comment, '#pop'),
            (r'\$\(ARCH\)', Name.Variable),
            (r'[^\s$[]+', String),
            (r'\[', String.Other, 'escaped-distribution'),
            (r'\$', String),
            (r'\s+', Text, 'components')
        ],
        'escaped-distribution': [
            (r'\]', String.Other, '#pop'),
            (r'\$\(ARCH\)', Name.Variable),
            (r'[^\]$]+', String.Other),
            (r'\$', String.Other)
        ],
        'components': [
            (r'#.*?$', Comment, '#pop:2'),
            (r'$', Text, '#pop:2'),
            (r'\s+', Text),
            (r'\S+', Keyword.Pseudo),
        ]
    }

    def analyse_text(text):
        for line in text.split('\n'):
            line = line.strip()
            if not (line.startswith('#') or line.startswith('deb ') or
                    line.startswith('deb-src ') or not line):
                return False
        return True


class MakefileLexer(Lexer):
    """
    Lexer for BSD and GNU make extensions (lenient enough to handle both in
    the same file even).

    *Rewritten in Pygments 0.10.*
    """

    name = 'Makefile'
    aliases = ['make', 'makefile', 'mf', 'bsdmake']
    filenames = ['*.mak', 'Makefile', 'makefile', 'Makefile.*', 'GNUmakefile']
    mimetypes = ['text/x-makefile']

    r_special = re.compile(r'^(?:'
        # BSD Make
        r'\.\s*(include|undef|error|warning|if|else|elif|endif|for|endfor)|'
        # GNU Make
        r'\s*(ifeq|ifneq|ifdef|ifndef|else|endif|-?include|define|endef|:))(?=\s)')
    r_comment = re.compile(r'^\s*@?#')

    def get_tokens_unprocessed(self, text):
        ins = []
        lines = text.splitlines(True)
        done = ''
        lex = BaseMakefileLexer(**self.options)
        backslashflag = False
        for line in lines:
            if self.r_special.match(line) or backslashflag:
                ins.append((len(done), [(0, Comment.Preproc, line)]))
                backslashflag = line.strip().endswith('\\')
            elif self.r_comment.match(line):
                ins.append((len(done), [(0, Comment, line)]))
            else:
                done += line
        for item in do_insertions(ins, lex.get_tokens_unprocessed(done)):
            yield item


class BaseMakefileLexer(RegexLexer):
    """
    Lexer for simple Makefiles (no preprocessing).

    *New in Pygments 0.10.*
    """

    name = 'Makefile'
    aliases = ['basemake']
    filenames = []
    mimetypes = []

    tokens = {
        'root': [
            (r'^(?:[\t ]+.*\n|\n)+', using(BashLexer)),
            (r'\$\((?:.*\\\n|.*\n)+', using(BashLexer)),
            (r'\s+', Text),
            (r'#.*?\n', Comment),
            (r'(export)(\s+)(?=[a-zA-Z0-9_${}\t -]+\n)',
             bygroups(Keyword, Text), 'export'),
            (r'export\s+', Keyword),
            # assignment
            (r'([a-zA-Z0-9_${}.-]+)(\s*)([!?:+]?=)([ \t]*)((?:.*\\\n|.*\n)+)',
             bygroups(Name.Variable, Text, Operator, Text, using(BashLexer))),
            # strings
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
            # targets
            (r'([^\n:]+)(:+)([ \t]*)', bygroups(Name.Function, Operator, Text),
             'block-header'),
            # TODO: add paren handling (grr)
        ],
        'export': [
            (r'[a-zA-Z0-9_${}-]+', Name.Variable),
            (r'\n', Text, '#pop'),
            (r'\s+', Text),
        ],
        'block-header': [
            (r'[^,\\\n#]+', Number),
            (r',', Punctuation),
            (r'#.*?\n', Comment),
            (r'\\\n', Text), # line continuation
            (r'\\.', Text),
            (r'(?:[\t ]+.*\n|\n)+', using(BashLexer), '#pop'),
        ],
    }


class DiffLexer(RegexLexer):
    """
    Lexer for unified or context-style diffs or patches.
    """

    name = 'Diff'
    aliases = ['diff', 'udiff']
    filenames = ['*.diff', '*.patch']
    mimetypes = ['text/x-diff', 'text/x-patch']

    tokens = {
        'root': [
            (r' .*\n', Text),
            (r'\+.*\n', Generic.Inserted),
            (r'-.*\n', Generic.Deleted),
            (r'!.*\n', Generic.Strong),
            (r'@.*\n', Generic.Subheading),
            (r'([Ii]ndex|diff).*\n', Generic.Heading),
            (r'=.*\n', Generic.Heading),
            (r'.*\n', Text),
        ]
    }

    def analyse_text(text):
        if text[:7] == 'Index: ':
            return True
        if text[:5] == 'diff ':
            return True
        if text[:4] == '--- ':
            return 0.9


DPATCH_KEYWORDS = ['hunk', 'addfile', 'adddir', 'rmfile', 'rmdir', 'move',
    'replace']

class DarcsPatchLexer(RegexLexer):
    """
    DarcsPatchLexer is a lexer for the various versions of the darcs patch
    format.  Examples of this format are derived by commands such as
    ``darcs annotate --patch`` and ``darcs send``.

    *New in Pygments 0.10.*
    """
    name = 'Darcs Patch'
    aliases = ['dpatch']
    filenames = ['*.dpatch', '*.darcspatch']

    tokens = {
        'root': [
            (r'<', Operator),
            (r'>', Operator),
            (r'{', Operator),
            (r'}', Operator),
            (r'(\[)((?:TAG )?)(.*)(\n)(.*)(\*\*)(\d+)(\s?)(\])',
             bygroups(Operator, Keyword, Name, Text, Name, Operator,
                      Literal.Date, Text, Operator)),
            (r'(\[)((?:TAG )?)(.*)(\n)(.*)(\*\*)(\d+)(\s?)',
             bygroups(Operator, Keyword, Name, Text, Name, Operator,
                      Literal.Date, Text), 'comment'),
            (r'New patches:', Generic.Heading),
            (r'Context:', Generic.Heading),
            (r'Patch bundle hash:', Generic.Heading),
            (r'(\s*)(%s)(.*\n)' % '|'.join(DPATCH_KEYWORDS),
                bygroups(Text, Keyword, Text)),
            (r'\+', Generic.Inserted, "insert"),
            (r'-', Generic.Deleted, "delete"),
            (r'.*\n', Text),
        ],
        'comment': [
            (r'[^\]].*\n', Comment),
            (r'\]', Operator, "#pop"),
        ],
        'specialText': [ # darcs add [_CODE_] special operators for clarity
            (r'\n', Text, "#pop"), # line-based
            (r'\[_[^_]*_]', Operator),
        ],
        'insert': [
            include('specialText'),
            (r'\[', Generic.Inserted),
            (r'[^\n\[]*', Generic.Inserted),
        ],
        'delete': [
            include('specialText'),
            (r'\[', Generic.Deleted),
            (r'[^\n\[]*', Generic.Deleted),
        ],
    }


class IrcLogsLexer(RegexLexer):
    """
    Lexer for IRC logs in *irssi*, *xchat* or *weechat* style.
    """

    name = 'IRC logs'
    aliases = ['irc']
    filenames = ['*.weechatlog']
    mimetypes = ['text/x-irclog']

    flags = re.VERBOSE | re.MULTILINE
    timestamp = r"""
        (
          # irssi / xchat and others
          (?: \[|\()?                  # Opening bracket or paren for the timestamp
            (?:                        # Timestamp
                (?: (?:\d{1,4} [-/]?)+ # Date as - or /-separated groups of digits
                 [T ])?                # Date/time separator: T or space
                (?: \d?\d [:.]?)+      # Time as :/.-separated groups of 1 or 2 digits
            )
          (?: \]|\))?\s+               # Closing bracket or paren for the timestamp
        |
          # weechat
          \d{4}\s\w{3}\s\d{2}\s        # Date
          \d{2}:\d{2}:\d{2}\s+         # Time + Whitespace
        |
          # xchat
          \w{3}\s\d{2}\s               # Date
          \d{2}:\d{2}:\d{2}\s+         # Time + Whitespace
        )?
    """
    tokens = {
        'root': [
                # log start/end
            (r'^\*\*\*\*(.*)\*\*\*\*$', Comment),
            # hack
            ("^" + timestamp + r'(\s*<[^>]*>\s*)$', bygroups(Comment.Preproc, Name.Tag)),
            # normal msgs
            ("^" + timestamp + r"""
                (\s*<.*?>\s*)          # Nick """,
             bygroups(Comment.Preproc, Name.Tag), 'msg'),
            # /me msgs
            ("^" + timestamp + r"""
                (\s*[*]\s+)            # Star
                ([^\s]+\s+.*?\n)       # Nick + rest of message """,
             bygroups(Comment.Preproc, Keyword, Generic.Inserted)),
            # join/part msgs
            ("^" + timestamp + r"""
                (\s*(?:\*{3}|<?-[!@=P]?->?)\s*)  # Star(s) or symbols
                ([^\s]+\s+)                     # Nick + Space
                (.*?\n)                         # Rest of message """,
             bygroups(Comment.Preproc, Keyword, String, Comment)),
            (r"^.*?\n", Text),
        ],
        'msg': [
            (r"[^\s]+:(?!//)", Name.Attribute),  # Prefix
            (r".*\n", Text, '#pop'),
        ],
    }


class BBCodeLexer(RegexLexer):
    """
    A lexer that highlights BBCode(-like) syntax.

    *New in Pygments 0.6.*
    """

    name = 'BBCode'
    aliases = ['bbcode']
    mimetypes = ['text/x-bbcode']

    tokens = {
        'root' : [
            (r'[\s\w]+', Text),
            (r'(\[)(/?[^\]\n\r=]+)(\])',
             bygroups(Keyword, Keyword.Pseudo, Keyword)),
            (r'(\[)([^\]\n\r=]+)(=)([^\]\n\r]+)(\])',
             bygroups(Keyword, Keyword.Pseudo, Operator, String, Keyword)),
        ],
    }


class TexLexer(RegexLexer):
    """
    Lexer for the TeX and LaTeX typesetting languages.
    """

    name = 'TeX'
    aliases = ['tex', 'latex']
    filenames = ['*.tex', '*.aux', '*.toc']
    mimetypes = ['text/x-tex', 'text/x-latex']

    tokens = {
        'general': [
            (r'%.*?\n', Comment),
            (r'[{}]', Name.Builtin),
            (r'[&_^]', Name.Builtin),
        ],
        'root': [
            (r'\\\[', String.Backtick, 'displaymath'),
            (r'\\\(', String, 'inlinemath'),
            (r'\$\$', String.Backtick, 'displaymath'),
            (r'\$', String, 'inlinemath'),
            (r'\\([a-zA-Z]+|.)', Keyword, 'command'),
            include('general'),
            (r'[^\\$%&_^{}]+', Text),
        ],
        'math': [
            (r'\\([a-zA-Z]+|.)', Name.Variable),
            include('general'),
            (r'[0-9]+', Number),
            (r'[-=!+*/()\[\]]', Operator),
            (r'[^=!+*/()\[\]\\$%&_^{}0-9-]+', Name.Builtin),
        ],
        'inlinemath': [
            (r'\\\)', String, '#pop'),
            (r'\$', String, '#pop'),
            include('math'),
        ],
        'displaymath': [
            (r'\\\]', String, '#pop'),
            (r'\$\$', String, '#pop'),
            (r'\$', Name.Builtin),
            include('math'),
        ],
        'command': [
            (r'\[.*?\]', Name.Attribute),
            (r'\*', Keyword),
            (r'', Text, '#pop'),
        ],
    }

    def analyse_text(text):
        for start in ("\\documentclass", "\\input", "\\documentstyle",
                      "\\relax"):
            if text[:len(start)] == start:
                return True


class GroffLexer(RegexLexer):
    """
    Lexer for the (g)roff typesetting language, supporting groff
    extensions. Mainly useful for highlighting manpage sources.

    *New in Pygments 0.6.*
    """

    name = 'Groff'
    aliases = ['groff', 'nroff', 'man']
    filenames = ['*.[1234567]', '*.man']
    mimetypes = ['application/x-troff', 'text/troff']

    tokens = {
        'root': [
            (r'(?i)(\.)(\w+)', bygroups(Text, Keyword), 'request'),
            (r'\.', Punctuation, 'request'),
            # Regular characters, slurp till we find a backslash or newline
            (r'[^\\\n]*', Text, 'textline'),
        ],
        'textline': [
            include('escapes'),
            (r'[^\\\n]+', Text),
            (r'\n', Text, '#pop'),
        ],
        'escapes': [
            # groff has many ways to write escapes.
            (r'\\"[^\n]*', Comment),
            (r'\\[fn]\w', String.Escape),
            (r'\\\(..', String.Escape),
            (r'\\.\[.*\]', String.Escape),
            (r'\\.', String.Escape),
            (r'\\\n', Text, 'request'),
        ],
        'request': [
            (r'\n', Text, '#pop'),
            include('escapes'),
            (r'"[^\n"]+"', String.Double),
            (r'\d+', Number),
            (r'\S+', String),
            (r'\s+', Text),
        ],
    }

    def analyse_text(text):
        if text[:1] != '.':
            return False
        if text[:3] == '.\\"':
            return True
        if text[:4] == '.TH ':
            return True
        if text[1:3].isalnum() and text[3].isspace():
            return 0.9


class ApacheConfLexer(RegexLexer):
    """
    Lexer for configuration files following the Apache config file
    format.

    *New in Pygments 0.6.*
    """

    name = 'ApacheConf'
    aliases = ['apacheconf', 'aconf', 'apache']
    filenames = ['.htaccess', 'apache.conf', 'apache2.conf']
    mimetypes = ['text/x-apacheconf']
    flags = re.MULTILINE | re.IGNORECASE

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'(#.*?)$', Comment),
            (r'(<[^\s>]+)(?:(\s+)(.*?))?(>)',
             bygroups(Name.Tag, Text, String, Name.Tag)),
            (r'([a-zA-Z][a-zA-Z0-9]*)(\s+)',
             bygroups(Name.Builtin, Text), 'value'),
            (r'\.+', Text),
        ],
        'value': [
            (r'$', Text, '#pop'),
            (r'[^\S\n]+', Text),
            (r'\d+\.\d+\.\d+\.\d+(?:/\d+)?', Number),
            (r'\d+', Number),
            (r'/([a-zA-Z0-9][a-zA-Z0-9_./-]+)', String.Other),
            (r'(on|off|none|any|all|double|email|dns|min|minimal|'
             r'os|productonly|full|emerg|alert|crit|error|warn|'
             r'notice|info|debug|registry|script|inetd|standalone|'
             r'user|group)\b', Keyword),
            (r'"([^"\\]*(?:\\.[^"\\]*)*)"', String.Double),
            (r'[^\s"]+', Text)
        ]
    }


class MoinWikiLexer(RegexLexer):
    """
    For MoinMoin (and Trac) Wiki markup.

    *New in Pygments 0.7.*
    """

    name = 'MoinMoin/Trac Wiki markup'
    aliases = ['trac-wiki', 'moin']
    filenames = []
    mimetypes = ['text/x-trac-wiki']
    flags = re.MULTILINE | re.IGNORECASE

    tokens = {
        'root': [
            (r'^#.*$', Comment),
            (r'(!)(\S+)', bygroups(Keyword, Text)), # Ignore-next
            # Titles
            (r'^(=+)([^=]+)(=+)(\s*#.+)?$',
             bygroups(Generic.Heading, using(this), Generic.Heading, String)),
            # Literal code blocks, with optional shebang
            (r'({{{)(\n#!.+)?', bygroups(Name.Builtin, Name.Namespace), 'codeblock'),
            (r'(\'\'\'?|\|\||`|__|~~|\^|,,|::)', Comment), # Formatting
            # Lists
            (r'^( +)([.*-])( )', bygroups(Text, Name.Builtin, Text)),
            (r'^( +)([a-zivx]{1,5}\.)( )', bygroups(Text, Name.Builtin, Text)),
            # Other Formatting
            (r'\[\[\w+.*?\]\]', Keyword), # Macro
            (r'(\[[^\s\]]+)(\s+[^\]]+?)?(\])',
             bygroups(Keyword, String, Keyword)), # Link
            (r'^----+$', Keyword), # Horizontal rules
            (r'[^\n\'\[{!_~^,|]+', Text),
            (r'\n', Text),
            (r'.', Text),
        ],
        'codeblock': [
            (r'}}}', Name.Builtin, '#pop'),
            # these blocks are allowed to be nested in Trac, but not MoinMoin
            (r'{{{', Text, '#push'),
            (r'[^{}]+', Comment.Preproc), # slurp boring text
            (r'.', Comment.Preproc), # allow loose { or }
        ],
    }


class RstLexer(RegexLexer):
    """
    For `reStructuredText <http://docutils.sf.net/rst.html>`_ markup.

    *New in Pygments 0.7.*

    Additional options accepted:

    `handlecodeblocks`
        Highlight the contents of ``.. sourcecode:: langauge`` and
        ``.. code:: language`` directives with a lexer for the given
        language (default: ``True``). *New in Pygments 0.8.*
    """
    name = 'reStructuredText'
    aliases = ['rst', 'rest', 'restructuredtext']
    filenames = ['*.rst', '*.rest']
    mimetypes = ["text/x-rst", "text/prs.fallenstein.rst"]
    flags = re.MULTILINE

    def _handle_sourcecode(self, match):
        from pygments.lexers import get_lexer_by_name
        from pygments.util import ClassNotFound

        # section header
        yield match.start(1), Punctuation, match.group(1)
        yield match.start(2), Text, match.group(2)
        yield match.start(3), Operator.Word, match.group(3)
        yield match.start(4), Punctuation, match.group(4)
        yield match.start(5), Text, match.group(5)
        yield match.start(6), Keyword, match.group(6)
        yield match.start(7), Text, match.group(7)

        # lookup lexer if wanted and existing
        lexer = None
        if self.handlecodeblocks:
            try:
                lexer = get_lexer_by_name(match.group(6).strip())
            except ClassNotFound:
                pass
        indention = match.group(8)
        indention_size = len(indention)
        code = (indention + match.group(9) + match.group(10) + match.group(11))

        # no lexer for this language. handle it like it was a code block
        if lexer is None:
            yield match.start(8), String, code
            return

        # highlight the lines with the lexer.
        ins = []
        codelines = code.splitlines(True)
        code = ''
        for line in codelines:
            if len(line) > indention_size:
                ins.append((len(code), [(0, Text, line[:indention_size])]))
                code += line[indention_size:]
            else:
                code += line
        for item in do_insertions(ins, lexer.get_tokens_unprocessed(code)):
            yield item

    tokens = {
        'root': [
            # Heading with overline
            (r'^(=+|-+|`+|:+|\.+|\'+|"+|~+|\^+|_+|\*+|\++|#+)([ \t]*\n)(.+)(\n)(\1)(\n)',
             bygroups(Generic.Heading, Text, Generic.Heading,
                      Text, Generic.Heading, Text)),
            # Plain heading
            (r'^(\S.*)(\n)(={3,}|-{3,}|`{3,}|:{3,}|\.{3,}|\'{3,}|"{3,}|'
             r'~{3,}|\^{3,}|_{3,}|\*{3,}|\+{3,}|#{3,})(\n)',
             bygroups(Generic.Heading, Text, Generic.Heading, Text)),
            # Bulleted lists
            (r'^(\s*)([-*+])( .+\n(?:\1  .+\n)*)',
             bygroups(Text, Number, using(this, state='inline'))),
            # Numbered lists
            (r'^(\s*)([0-9#ivxlcmIVXLCM]+\.)( .+\n(?:\1  .+\n)*)',
             bygroups(Text, Number, using(this, state='inline'))),
            (r'^(\s*)(\(?[0-9#ivxlcmIVXLCM]+\))( .+\n(?:\1  .+\n)*)',
             bygroups(Text, Number, using(this, state='inline'))),
            # Numbered, but keep words at BOL from becoming lists
            (r'^(\s*)([A-Z]+\.)( .+\n(?:\1  .+\n)+)',
             bygroups(Text, Number, using(this, state='inline'))),
            (r'^(\s*)(\(?[A-Za-z]+\))( .+\n(?:\1  .+\n)+)',
             bygroups(Text, Number, using(this, state='inline'))),
            # Sourcecode directives
            (r'^( *\.\.)(\s*)((?:source)?code)(::)([ \t]*)([^\n]+)'
             r'(\n[ \t]*\n)([ \t]+)(.*)(\n)((?:(?:\8.*|)\n)+)',
             _handle_sourcecode),
            # A directive
            (r'^( *\.\.)(\s*)([\w-]+)(::)(?:([ \t]*)(.+))?',
             bygroups(Punctuation, Text, Operator.Word, Punctuation, Text, Keyword)),
            # A reference target
            (r'^( *\.\.)(\s*)([\w\t ]+:)(.*?)$',
             bygroups(Punctuation, Text, Name.Tag, using(this, state='inline'))),
            # A footnote target
            (r'^( *\.\.)(\s*)(\[.+\])(.*?)$',
             bygroups(Punctuation, Text, Name.Tag, using(this, state='inline'))),
            # Comments
            (r'^ *\.\..*(\n( +.*\n|\n)+)?', Comment.Preproc),
            # Field list
            (r'^( *)(:.*?:)([ \t]+)(.*?)$', bygroups(Text, Name.Class, Text,
                                                     Name.Function)),
            # Definition list
            (r'^([^ ].*(?<!::)\n)((?:(?: +.*)\n)+)',
             bygroups(using(this, state='inline'), using(this, state='inline'))),
            # Code blocks
            (r'(::)(\n[ \t]*\n)([ \t]+)(.*)(\n)((?:(?:\3.*|)\n)+)',
             bygroups(String.Escape, Text, String, String, Text, String)),
            include('inline'),
        ],
        'inline': [
            (r'\\.', Text), # escape
            (r'``', String, 'literal'), # code
            (r'(`)(.+?)(`__?)',
             bygroups(Punctuation, using(this), Punctuation)), # reference
            (r'(`.+?`)(:[a-zA-Z0-9-]+?:)?',
             bygroups(Name.Variable, Name.Attribute)), # role
            (r'(:[a-zA-Z0-9-]+?:)(`.+?`)',
             bygroups(Name.Attribute, Name.Variable)), # user-defined role
            (r'\*\*.+?\*\*', Generic.Strong), # Strong emphasis
            (r'\*.+?\*', Generic.Emph), # Emphasis
            (r'\[.*?\]_', String), # Footnote or citation
            (r'<.+?>', Name.Tag), # Hyperlink
            (r'[^\\\n\[*`:]+', Text),
            (r'.', Text),
        ],
        'literal': [
            (r'[^`\\]+', String),
            (r'\\.', String),
            (r'``', String, '#pop'),
            (r'[`\\]', String),
        ]
    }

    def __init__(self, **options):
        self.handlecodeblocks = get_bool_opt(options, 'handlecodeblocks', True)
        RegexLexer.__init__(self, **options)

    def analyse_text(text):
        if text[:2] == '..' and text[2:3] != '.':
            return 0.3
        p1 = text.find("\n")
        p2 = text.find("\n", p1 + 1)
        if (p2 > -1 and              # has two lines
            p1 * 2 + 1 == p2 and     # they are the same length
            text[p1+1] in '-=' and   # the next line both starts and ends with
            text[p1+1] == text[p2-1]): # ...a sufficiently high header
            return 0.5


class VimLexer(RegexLexer):
    """
    Lexer for VimL script files.

    *New in Pygments 0.8.*
    """
    name = 'VimL'
    aliases = ['vim']
    filenames = ['*.vim', '.vimrc']
    mimetypes = ['text/x-vim']
    flags = re.MULTILINE

    tokens = {
        'root': [
            # Who decided that doublequote was a good comment character??
            (r'^\s*".*', Comment),
            (r'(?<=\s)"[^\-:.%#=*].*', Comment),

            (r'[ \t]+', Text),
            # TODO: regexes can have other delims
            (r'/(\\\\|\\/|[^\n/])*/', String.Regex),
            (r'"(\\\\|\\"|[^\n"])*"', String.Double),
            (r"'(\\\\|\\'|[^\n'])*'", String.Single),
            (r'-?\d+', Number),
            (r'#[0-9a-f]{6}', Number.Hex),
            (r'^:', Punctuation),
            (r'[()<>+=!|,~-]', Punctuation), # Inexact list.  Looks decent.
            (r'\b(let|if|else|endif|elseif|fun|function|endfunction)\b',
             Keyword),
            (r'\b(NONE|bold|italic|underline|dark|light)\b', Name.Builtin),
            (r'\b\w+\b', Name.Other), # These are postprocessed below
            (r'.', Text),
        ],
    }
    def __init__(self, **options):
        from pygments.lexers._vimbuiltins import command, option, auto
        self._cmd = command
        self._opt = option
        self._aut = auto

        RegexLexer.__init__(self, **options)

    def is_in(self, w, mapping):
        r"""
        It's kind of difficult to decide if something might be a keyword
        in VimL because it allows you to abbreviate them.  In fact,
        'ab[breviate]' is a good example.  :ab, :abbre, or :abbreviate are
        valid ways to call it so rather than making really awful regexps
        like::

            \bab(?:b(?:r(?:e(?:v(?:i(?:a(?:t(?:e)?)?)?)?)?)?)?)?\b

        we match `\b\w+\b` and then call is_in() on those tokens.  See
        `scripts/get_vimkw.py` for how the lists are extracted.
        """
        p = bisect(mapping, (w,))
        if p > 0:
            if mapping[p-1][0] == w[:len(mapping[p-1][0])] and \
               mapping[p-1][1][:len(w)] == w: return True
        if p < len(mapping):
            return mapping[p][0] == w[:len(mapping[p][0])] and \
                   mapping[p][1][:len(w)] == w
        return False

    def get_tokens_unprocessed(self, text):
        # TODO: builtins are only subsequent tokens on lines
        #       and 'keywords' only happen at the beginning except
        #       for :au ones
        for index, token, value in \
            RegexLexer.get_tokens_unprocessed(self, text):
            if token is Name.Other:
                if self.is_in(value, self._cmd):
                    yield index, Keyword, value
                elif self.is_in(value, self._opt) or \
                     self.is_in(value, self._aut):
                    yield index, Name.Builtin, value
                else:
                    yield index, Text, value
            else:
                yield index, token, value


class GettextLexer(RegexLexer):
    """
    Lexer for Gettext catalog files.

    *New in Pygments 0.9.*
    """
    name = 'Gettext Catalog'
    aliases = ['pot', 'po']
    filenames = ['*.pot', '*.po']
    mimetypes = ['application/x-gettext', 'text/x-gettext', 'text/gettext']

    tokens = {
        'root': [
            (r'^#,\s.*?$', Keyword.Type),
            (r'^#:\s.*?$', Keyword.Declaration),
            #(r'^#$', Comment),
            (r'^(#|#\.\s|#\|\s|#~\s|#\s).*$', Comment.Single),
            (r'^(")([\w-]*:)(.*")$',
             bygroups(String, Name.Property, String)),
            (r'^".*"$', String),
            (r'^(msgid|msgid_plural|msgstr)(\s+)(".*")$',
             bygroups(Name.Variable, Text, String)),
            (r'^(msgstr\[)(\d)(\])(\s+)(".*")$',
             bygroups(Name.Variable, Number.Integer, Name.Variable, Text, String)),
        ]
    }


class SquidConfLexer(RegexLexer):
    """
    Lexer for `squid <http://www.squid-cache.org/>`_ configuration files.

    *New in Pygments 0.9.*
    """

    name = 'SquidConf'
    aliases = ['squidconf', 'squid.conf', 'squid']
    filenames = ['squid.conf']
    mimetypes = ['text/x-squidconf']
    flags = re.IGNORECASE

    keywords = [ "acl", "always_direct", "announce_host",
                 "announce_period", "announce_port", "announce_to",
                 "anonymize_headers", "append_domain", "as_whois_server",
                 "auth_param_basic", "authenticate_children",
                 "authenticate_program", "authenticate_ttl", "broken_posts",
                 "buffered_logs", "cache_access_log", "cache_announce",
                 "cache_dir", "cache_dns_program", "cache_effective_group",
                 "cache_effective_user", "cache_host", "cache_host_acl",
                 "cache_host_domain", "cache_log", "cache_mem",
                 "cache_mem_high", "cache_mem_low", "cache_mgr",
                 "cachemgr_passwd", "cache_peer", "cache_peer_access",
                 "cahce_replacement_policy", "cache_stoplist",
                 "cache_stoplist_pattern", "cache_store_log", "cache_swap",
                 "cache_swap_high", "cache_swap_log", "cache_swap_low",
                 "client_db", "client_lifetime", "client_netmask",
                 "connect_timeout", "coredump_dir", "dead_peer_timeout",
                 "debug_options", "delay_access", "delay_class",
                 "delay_initial_bucket_level", "delay_parameters",
                 "delay_pools", "deny_info", "dns_children", "dns_defnames",
                 "dns_nameservers", "dns_testnames", "emulate_httpd_log",
                 "err_html_text", "fake_user_agent", "firewall_ip",
                 "forwarded_for", "forward_snmpd_port", "fqdncache_size",
                 "ftpget_options", "ftpget_program", "ftp_list_width",
                 "ftp_passive", "ftp_user", "half_closed_clients",
                 "header_access", "header_replace", "hierarchy_stoplist",
                 "high_response_time_warning", "high_page_fault_warning",
                 "htcp_port", "http_access", "http_anonymizer", "httpd_accel",
                 "httpd_accel_host", "httpd_accel_port",
                 "httpd_accel_uses_host_header", "httpd_accel_with_proxy",
                 "http_port", "http_reply_access", "icp_access",
                 "icp_hit_stale", "icp_port", "icp_query_timeout",
                 "ident_lookup", "ident_lookup_access", "ident_timeout",
                 "incoming_http_average", "incoming_icp_average",
                 "inside_firewall", "ipcache_high", "ipcache_low",
                 "ipcache_size", "local_domain", "local_ip", "logfile_rotate",
                 "log_fqdn", "log_icp_queries", "log_mime_hdrs",
                 "maximum_object_size", "maximum_single_addr_tries",
                 "mcast_groups", "mcast_icp_query_timeout", "mcast_miss_addr",
                 "mcast_miss_encode_key", "mcast_miss_port", "memory_pools",
                 "memory_pools_limit", "memory_replacement_policy",
                 "mime_table", "min_http_poll_cnt", "min_icp_poll_cnt",
                 "minimum_direct_hops", "minimum_object_size",
                 "minimum_retry_timeout", "miss_access", "negative_dns_ttl",
                 "negative_ttl", "neighbor_timeout", "neighbor_type_domain",
                 "netdb_high", "netdb_low", "netdb_ping_period",
                 "netdb_ping_rate", "never_direct", "no_cache",
                 "passthrough_proxy", "pconn_timeout", "pid_filename",
                 "pinger_program", "positive_dns_ttl", "prefer_direct",
                 "proxy_auth", "proxy_auth_realm", "query_icmp", "quick_abort",
                 "quick_abort", "quick_abort_max", "quick_abort_min",
                 "quick_abort_pct", "range_offset_limit", "read_timeout",
                 "redirect_children", "redirect_program",
                 "redirect_rewrites_host_header", "reference_age",
                 "reference_age", "refresh_pattern", "reload_into_ims",
                 "request_body_max_size", "request_size", "request_timeout",
                 "shutdown_lifetime", "single_parent_bypass",
                 "siteselect_timeout", "snmp_access", "snmp_incoming_address",
                 "snmp_port", "source_ping", "ssl_proxy",
                 "store_avg_object_size", "store_objects_per_bucket",
                 "strip_query_terms", "swap_level1_dirs", "swap_level2_dirs",
                 "tcp_incoming_address", "tcp_outgoing_address",
                 "tcp_recv_bufsize", "test_reachability", "udp_hit_obj",
                 "udp_hit_obj_size", "udp_incoming_address",
                 "udp_outgoing_address", "unique_hostname", "unlinkd_program",
                 "uri_whitespace", "useragent_log", "visible_hostname",
                 "wais_relay", "wais_relay_host", "wais_relay_port",
                 ]

    opts = [ "proxy-only", "weight", "ttl", "no-query", "default",
             "round-robin", "multicast-responder", "on", "off", "all",
             "deny", "allow", "via", "parent", "no-digest", "heap", "lru",
             "realm", "children", "credentialsttl", "none", "disable",
             "offline_toggle", "diskd", "q1", "q2",
             ]

    actions = [ "shutdown", "info", "parameter", "server_list",
                "client_list", r'squid\.conf',
                ]

    actions_stats = [ "objects", "vm_objects", "utilization",
                      "ipcache", "fqdncache", "dns", "redirector", "io",
                      "reply_headers", "filedescriptors", "netdb",
                      ]

    actions_log = [ "status", "enable", "disable", "clear"]

    acls = [ "url_regex", "urlpath_regex", "referer_regex", "port",
             "proto", "req_mime_type", "rep_mime_type", "method",
             "browser", "user", "src", "dst", "time", "dstdomain", "ident",
             "snmp_community",
             ]

    ip_re = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'

    def makelistre(list):
        return r'\b(?:'+'|'.join(list)+r')\b'

    tokens = {
        'root': [
            (r'\s+', Text),
            (r'#', Comment, 'comment'),
            (makelistre(keywords), Keyword),
            (makelistre(opts), Name.Constant),
            # Actions
            (makelistre(actions), String),
            (r'stats/'+makelistre(actions), String),
            (r'log/'+makelistre(actions)+r'=', String),
            (makelistre(acls), Keyword),
            (ip_re+r'(?:/(?:'+ip_re+r')|\d+)?', Number),
            (r'\b\d+\b', Number),
            (r'\S+', Text),
        ],
        'comment': [
            (r'\s*TAG:.*', String.Escape, '#pop'),
            (r'.*', Comment, '#pop'),
        ],
    }


class DebianControlLexer(RegexLexer):
    """
    Lexer for Debian ``control`` files and ``apt-cache show <pkg>`` outputs.

    *New in Pygments 0.9.*
    """
    name = 'Debian Control file'
    aliases = ['control']
    filenames = ['control']

    tokens = {
        'root': [
            (r'^(Description)', Keyword, 'description'),
            (r'^(Maintainer)(:\s*)', bygroups(Keyword, Text), 'maintainer'),
            (r'^((Build-)?Depends)', Keyword, 'depends'),
            (r'^((?:Python-)?Version)(:\s*)([^\s]+)$',
             bygroups(Keyword, Text, Number)),
            (r'^((?:Installed-)?Size)(:\s*)([^\s]+)$',
             bygroups(Keyword, Text, Number)),
            (r'^(MD5Sum|SHA1|SHA256)(:\s*)([^\s]+)$',
             bygroups(Keyword, Text, Number)),
            (r'^([a-zA-Z\-0-9\.]*?)(:\s*)(.*?)$',
             bygroups(Keyword, Whitespace, String)),
        ],
        'maintainer': [
            (r'<[^>]+>', Generic.Strong),
            (r'<[^>]+>$', Generic.Strong, '#pop'),
            (r',\n?', Text),
            (r'.', Text),
        ],
        'description': [
            (r'(.*)(Homepage)(: )([^\s]+)', bygroups(Text, String, Name, Name.Class)),
            (r':.*\n', Generic.Strong),
            (r' .*\n', Text),
            ('', Text, '#pop'),
        ],
        'depends': [
            (r':\s*', Text),
            (r'(\$)(\{)(\w+\s*:\s*\w+)', bygroups(Operator, Text, Name.Entity)),
            (r'\(', Text, 'depend_vers'),
            (r',', Text),
            (r'\|', Operator),
            (r'[\s]+', Text),
            (r'[}\)]\s*$', Text, '#pop'),
            (r'[}]', Text),
            (r'[^,]$', Name.Function, '#pop'),
            (r'([\+\.a-zA-Z0-9-][\s\n]*)', Name.Function),
        ],
        'depend_vers': [
            (r'\),', Text, '#pop'),
            (r'\)[^,]', Text, '#pop:2'),
            (r'([><=]+)(\s*)([^\)]+)', bygroups(Operator, Text, Number))
        ]
    }


class YamlLexerContext(LexerContext):
    """Indentation context for the YAML lexer."""

    def __init__(self, *args, **kwds):
        super(YamlLexerContext, self).__init__(*args, **kwds)
        self.indent_stack = []
        self.indent = -1
        self.next_indent = 0
        self.block_scalar_indent = None


class YamlLexer(ExtendedRegexLexer):
    """
    Lexer for `YAML <http://yaml.org/>`_, a human-friendly data serialization
    language.

    *New in Pygments 0.11.*
    """

    name = 'YAML'
    aliases = ['yaml']
    filenames = ['*.yaml', '*.yml']
    mimetypes = ['text/x-yaml']


    def something(token_class):
        """Do not produce empty tokens."""
        def callback(lexer, match, context):
            text = match.group()
            if not text:
                return
            yield match.start(), token_class, text
            context.pos = match.end()
        return callback

    def reset_indent(token_class):
        """Reset the indentation levels."""
        def callback(lexer, match, context):
            text = match.group()
            context.indent_stack = []
            context.indent = -1
            context.next_indent = 0
            context.block_scalar_indent = None
            yield match.start(), token_class, text
            context.pos = match.end()
        return callback

    def save_indent(token_class, start=False):
        """Save a possible indentation level."""
        def callback(lexer, match, context):
            text = match.group()
            extra = ''
            if start:
                context.next_indent = len(text)
                if context.next_indent < context.indent:
                    while context.next_indent < context.indent:
                        context.indent = context.indent_stack.pop()
                    if context.next_indent > context.indent:
                        extra = text[context.indent:]
                        text = text[:context.indent]
            else:
                context.next_indent += len(text)
            if text:
                yield match.start(), token_class, text
            if extra:
                yield match.start()+len(text), token_class.Error, extra
            context.pos = match.end()
        return callback

    def set_indent(token_class, implicit=False):
        """Set the previously saved indentation level."""
        def callback(lexer, match, context):
            text = match.group()
            if context.indent < context.next_indent:
                context.indent_stack.append(context.indent)
                context.indent = context.next_indent
            if not implicit:
                context.next_indent += len(text)
            yield match.start(), token_class, text
            context.pos = match.end()
        return callback

    def set_block_scalar_indent(token_class):
        """Set an explicit indentation level for a block scalar."""
        def callback(lexer, match, context):
            text = match.group()
            context.block_scalar_indent = None
            if not text:
                return
            increment = match.group(1)
            if increment:
                current_indent = max(context.indent, 0)
                increment = int(increment)
                context.block_scalar_indent = current_indent + increment
            if text:
                yield match.start(), token_class, text
                context.pos = match.end()
        return callback

    def parse_block_scalar_empty_line(indent_token_class, content_token_class):
        """Process an empty line in a block scalar."""
        def callback(lexer, match, context):
            text = match.group()
            if (context.block_scalar_indent is None or
                    len(text) <= context.block_scalar_indent):
                if text:
                    yield match.start(), indent_token_class, text
            else:
                indentation = text[:context.block_scalar_indent]
                content = text[context.block_scalar_indent:]
                yield match.start(), indent_token_class, indentation
                yield (match.start()+context.block_scalar_indent,
                        content_token_class, content)
            context.pos = match.end()
        return callback

    def parse_block_scalar_indent(token_class):
        """Process indentation spaces in a block scalar."""
        def callback(lexer, match, context):
            text = match.group()
            if context.block_scalar_indent is None:
                if len(text) <= max(context.indent, 0):
                    context.stack.pop()
                    context.stack.pop()
                    return
                context.block_scalar_indent = len(text)
            else:
                if len(text) < context.block_scalar_indent:
                    context.stack.pop()
                    context.stack.pop()
                    return
            if text:
                yield match.start(), token_class, text
                context.pos = match.end()
        return callback

    def parse_plain_scalar_indent(token_class):
        """Process indentation spaces in a plain scalar."""
        def callback(lexer, match, context):
            text = match.group()
            if len(text) <= context.indent:
                context.stack.pop()
                context.stack.pop()
                return
            if text:
                yield match.start(), token_class, text
                context.pos = match.end()
        return callback



    tokens = {
        # the root rules
        'root': [
            # ignored whitespaces
            (r'[ ]+(?=#|$)', Text),
            # line breaks
            (r'\n+', Text),
            # a comment
            (r'#[^\n]*', Comment.Single),
            # the '%YAML' directive
            (r'^%YAML(?=[ ]|$)', reset_indent(Name.Tag), 'yaml-directive'),
            # the %TAG directive
            (r'^%TAG(?=[ ]|$)', reset_indent(Name.Tag), 'tag-directive'),
            # document start and document end indicators
            (r'^(?:---|\.\.\.)(?=[ ]|$)', reset_indent(Name.Namespace),
             'block-line'),
            # indentation spaces
            (r'[ ]*(?![ \t\n\r\f\v]|$)', save_indent(Text, start=True),
             ('block-line', 'indentation')),
        ],

        # trailing whitespaces after directives or a block scalar indicator
        'ignored-line': [
            # ignored whitespaces
            (r'[ ]+(?=#|$)', Text),
            # a comment
            (r'#[^\n]*', Comment.Single),
            # line break
            (r'\n', Text, '#pop:2'),
        ],

        # the %YAML directive
        'yaml-directive': [
            # the version number
            (r'([ ]+)([0-9]+\.[0-9]+)',
             bygroups(Text, Number), 'ignored-line'),
        ],

        # the %YAG directive
        'tag-directive': [
            # a tag handle and the corresponding prefix
            (r'([ ]+)(!|![0-9A-Za-z_-]*!)'
             r'([ ]+)(!|!?[0-9A-Za-z;/?:@&=+$,_.!~*\'()\[\]%-]+)',
             bygroups(Text, Keyword.Type, Text, Keyword.Type),
             'ignored-line'),
        ],

        # block scalar indicators and indentation spaces
        'indentation': [
            # trailing whitespaces are ignored
            (r'[ ]*$', something(Text), '#pop:2'),
            # whitespaces preceeding block collection indicators
            (r'[ ]+(?=[?:-](?:[ ]|$))', save_indent(Text)),
            # block collection indicators
            (r'[?:-](?=[ ]|$)', set_indent(Punctuation.Indicator)),
            # the beginning a block line
            (r'[ ]*', save_indent(Text), '#pop'),
        ],

        # an indented line in the block context
        'block-line': [
            # the line end
            (r'[ ]*(?=#|$)', something(Text), '#pop'),
            # whitespaces separating tokens
            (r'[ ]+', Text),
            # tags, anchors and aliases,
            include('descriptors'),
            # block collections and scalars
            include('block-nodes'),
            # flow collections and quoted scalars
            include('flow-nodes'),
            # a plain scalar
            (r'(?=[^ \t\n\r\f\v?:,\[\]{}#&*!|>\'"%@`-]|[?:-][^ \t\n\r\f\v])',
             something(Name.Variable),
             'plain-scalar-in-block-context'),
        ],

        # tags, anchors, aliases
        'descriptors' : [
            # a full-form tag
            (r'!<[0-9A-Za-z;/?:@&=+$,_.!~*\'()\[\]%-]+>', Keyword.Type),
            # a tag in the form '!', '!suffix' or '!handle!suffix'
            (r'!(?:[0-9A-Za-z_-]+)?'
             r'(?:![0-9A-Za-z;/?:@&=+$,_.!~*\'()\[\]%-]+)?', Keyword.Type),
            # an anchor
            (r'&[0-9A-Za-z_-]+', Name.Label),
            # an alias
            (r'\*[0-9A-Za-z_-]+', Name.Variable),
        ],

        # block collections and scalars
        'block-nodes': [
            # implicit key
            (r':(?=[ ]|$)', set_indent(Punctuation.Indicator, implicit=True)),
            # literal and folded scalars
            (r'[|>]', Punctuation.Indicator,
             ('block-scalar-content', 'block-scalar-header')),
        ],

        # flow collections and quoted scalars
        'flow-nodes': [
            # a flow sequence
            (r'\[', Punctuation.Indicator, 'flow-sequence'),
            # a flow mapping
            (r'\{', Punctuation.Indicator, 'flow-mapping'),
            # a single-quoted scalar
            (r'\'', String, 'single-quoted-scalar'),
            # a double-quoted scalar
            (r'\"', String, 'double-quoted-scalar'),
        ],

        # the content of a flow collection
        'flow-collection': [
            # whitespaces
            (r'[ ]+', Text),
            # line breaks
            (r'\n+', Text),
            # a comment
            (r'#[^\n]*', Comment.Single),
            # simple indicators
            (r'[?:,]', Punctuation.Indicator),
            # tags, anchors and aliases
            include('descriptors'),
            # nested collections and quoted scalars
            include('flow-nodes'),
            # a plain scalar
            (r'(?=[^ \t\n\r\f\v?:,\[\]{}#&*!|>\'"%@`])',
             something(Name.Variable),
             'plain-scalar-in-flow-context'),
        ],

        # a flow sequence indicated by '[' and ']'
        'flow-sequence': [
            # include flow collection rules
            include('flow-collection'),
            # the closing indicator
            (r'\]', Punctuation.Indicator, '#pop'),
        ],

        # a flow mapping indicated by '{' and '}'
        'flow-mapping': [
            # include flow collection rules
            include('flow-collection'),
            # the closing indicator
            (r'\}', Punctuation.Indicator, '#pop'),
        ],

        # block scalar lines
        'block-scalar-content': [
            # line break
            (r'\n', Text),
            # empty line
            (r'^[ ]+$',
             parse_block_scalar_empty_line(Text, Name.Constant)),
            # indentation spaces (we may leave the state here)
            (r'^[ ]*', parse_block_scalar_indent(Text)),
            # line content
            (r'[^\n\r\f\v]+', Name.Constant),
        ],

        # the content of a literal or folded scalar
        'block-scalar-header': [
            # indentation indicator followed by chomping flag
            (r'([1-9])?[+-]?(?=[ ]|$)',
             set_block_scalar_indent(Punctuation.Indicator),
             'ignored-line'),
            # chomping flag followed by indentation indicator
            (r'[+-]?([1-9])?(?=[ ]|$)',
             set_block_scalar_indent(Punctuation.Indicator),
             'ignored-line'),
        ],

        # ignored and regular whitespaces in quoted scalars
        'quoted-scalar-whitespaces': [
            # leading and trailing whitespaces are ignored
            (r'^[ ]+|[ ]+$', Text),
            # line breaks are ignored
            (r'\n+', Text),
            # other whitespaces are a part of the value
            (r'[ ]+', Name.Variable),
        ],

        # single-quoted scalars
        'single-quoted-scalar': [
            # include whitespace and line break rules
            include('quoted-scalar-whitespaces'),
            # escaping of the quote character
            (r'\'\'', String.Escape),
            # regular non-whitespace characters
            (r'[^ \t\n\r\f\v\']+', String),
            # the closing quote
            (r'\'', String, '#pop'),
        ],

        # double-quoted scalars
        'double-quoted-scalar': [
            # include whitespace and line break rules
            include('quoted-scalar-whitespaces'),
            # escaping of special characters
            (r'\\[0abt\tn\nvfre "\\N_LP]', String),
            # escape codes
            (r'\\(?:x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})',
             String.Escape),
            # regular non-whitespace characters
            (r'[^ \t\n\r\f\v\"\\]+', String),
            # the closing quote
            (r'"', String, '#pop'),
        ],

        # the beginning of a new line while scanning a plain scalar
        'plain-scalar-in-block-context-new-line': [
            # empty lines
            (r'^[ ]+$', Text),
            # line breaks
            (r'\n+', Text),
            # document start and document end indicators
            (r'^(?=---|\.\.\.)', something(Name.Namespace), '#pop:3'),
            # indentation spaces (we may leave the block line state here)
            (r'^[ ]*', parse_plain_scalar_indent(Text), '#pop'),
        ],

        # a plain scalar in the block context
        'plain-scalar-in-block-context': [
            # the scalar ends with the ':' indicator
            (r'[ ]*(?=:[ ]|:$)', something(Text), '#pop'),
            # the scalar ends with whitespaces followed by a comment
            (r'[ ]+(?=#)', Text, '#pop'),
            # trailing whitespaces are ignored
            (r'[ ]+$', Text),
            # line breaks are ignored
            (r'\n+', Text, 'plain-scalar-in-block-context-new-line'),
            # other whitespaces are a part of the value
            (r'[ ]+', Literal.Scalar.Plain),
            # regular non-whitespace characters
            (r'(?::(?![ \t\n\r\f\v])|[^ \t\n\r\f\v:])+', Literal.Scalar.Plain),
        ],

        # a plain scalar is the flow context
        'plain-scalar-in-flow-context': [
            # the scalar ends with an indicator character
            (r'[ ]*(?=[,:?\[\]{}])', something(Text), '#pop'),
            # the scalar ends with a comment
            (r'[ ]+(?=#)', Text, '#pop'),
            # leading and trailing whitespaces are ignored
            (r'^[ ]+|[ ]+$', Text),
            # line breaks are ignored
            (r'\n+', Text),
            # other whitespaces are a part of the value
            (r'[ ]+', Name.Variable),
            # regular non-whitespace characters
            (r'[^ \t\n\r\f\v,:?\[\]{}]+', Name.Variable),
        ],

    }

    def get_tokens_unprocessed(self, text=None, context=None):
        if context is None:
            context = YamlLexerContext(text, 0)
        return super(YamlLexer, self).get_tokens_unprocessed(text, context)


class LighttpdConfLexer(RegexLexer):
    """
    Lexer for `Lighttpd <http://lighttpd.net/>`_ configuration files.

    *New in Pygments 0.11.*
    """
    name = 'Lighttpd configuration file'
    aliases = ['lighty', 'lighttpd']
    filenames = []
    mimetypes = ['text/x-lighttpd-conf']

    tokens = {
        'root': [
            (r'#.*\n', Comment.Single),
            (r'/\S*', Name), # pathname
            (r'[a-zA-Z._-]+', Keyword),
            (r'\d+\.\d+\.\d+\.\d+(?:/\d+)?', Number),
            (r'[0-9]+', Number),
            (r'=>|=~|\+=|==|=|\+', Operator),
            (r'\$[A-Z]+', Name.Builtin),
            (r'[(){}\[\],]', Punctuation),
            (r'"([^"\\]*(?:\\.[^"\\]*)*)"', String.Double),
            (r'\s+', Text),
        ],

    }


class NginxConfLexer(RegexLexer):
    """
    Lexer for `Nginx <http://nginx.net/>`_ configuration files.

    *New in Pygments 0.11.*
    """
    name = 'Nginx configuration file'
    aliases = ['nginx']
    filenames = []
    mimetypes = ['text/x-nginx-conf']

    tokens = {
        'root': [
            (r'(include)(\s+)([^\s;]+)', bygroups(Keyword, Text, Name)),
            (r'[^\s;#]+', Keyword, 'stmt'),
            include('base'),
        ],
        'block': [
            (r'}', Punctuation, '#pop:2'),
            (r'[^\s;#]+', Keyword.Namespace, 'stmt'),
            include('base'),
        ],
        'stmt': [
            (r'{', Punctuation, 'block'),
            (r';', Punctuation, '#pop'),
            include('base'),
        ],
        'base': [
            (r'#.*\n', Comment.Single),
            (r'on|off', Name.Constant),
            (r'\$[^\s;#()]+', Name.Variable),
            (r'([a-z0-9.-]+)(:)([0-9]+)',
             bygroups(Name, Punctuation, Number.Integer)),
            (r'[a-z-]+/[a-z-+]+', String), # mimetype
            #(r'[a-zA-Z._-]+', Keyword),
            (r'[0-9]+[km]?\b', Number.Integer),
            (r'(~)(\s*)([^\s{]+)', bygroups(Punctuation, Text, String.Regex)),
            (r'[:=~]', Punctuation),
            (r'[^\s;#{}$]+', String), # catch all
            (r'/[^\s;#]*', Name), # pathname
            (r'\s+', Text),
        ],
    }
# -*- coding: utf-8 -*-
"""
    pygments.lexers.web
    ~~~~~~~~~~~~~~~~~~~

    Lexers for web-related languages and markup.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re
try:
    set
except NameError:
    from sets import Set as set

from pygments.lexer import RegexLexer, bygroups, using, include, this
from pygments.token import \
     Text, Comment, Operator, Keyword, Name, String, Number, Other, Punctuation
from pygments.util import get_bool_opt, get_list_opt, looks_like_xml, \
                          html_doctype_matches


__all__ = ['HtmlLexer', 'XmlLexer', 'JavascriptLexer', 'CssLexer',
           'PhpLexer', 'ActionScriptLexer', 'XsltLexer', 'ActionScript3Lexer',
           'MxmlLexer']


class JavascriptLexer(RegexLexer):
    """
    For JavaScript source code.
    """

    name = 'JavaScript'
    aliases = ['js', 'javascript']
    filenames = ['*.js']
    mimetypes = ['application/x-javascript', 'text/x-javascript', 'text/javascript']

    flags = re.DOTALL
    tokens = {
        'root': [
            (r'\s+', Text),
            (r'<!--', Comment),
            (r'//.*?\n', Comment),
            (r'/\*.*?\*/', Comment),
            (r'/(\\\\|\\/|[^/\n])*/[gim]+\b', String.Regex),
            (r'/(\\\\|\\/|[^/\n])*/(?=\s*[,);\n])', String.Regex),
            (r'/(\\\\|\\/|[^/\n])*/(?=\s*\.[a-z])', String.Regex),
            (r'[~\^\*!%&<>\|+=:;,/?\\-]+', Operator),
            (r'[{}\[\]();.]+', Punctuation),
            (r'(for|in|while|do|break|return|continue|if|else|throw|try|'
             r'catch|new|typeof|instanceof|this)\b', Keyword),
            (r'(var|with|const|label|function)\b', Keyword.Declaration),
            (r'(true|false|null|NaN|Infinity|undefined)\b', Keyword.Constant),
            (r'(Array|Boolean|Date|Error|Function|Math|netscape|'
             r'Number|Object|Packages|RegExp|String|sun|decodeURI|'
             r'decodeURIComponent|encodeURI|encodeURIComponent|'
             r'Error|eval|isFinite|isNaN|parseFloat|parseInt|document|this|'
             r'window)\b', Name.Builtin),
            (r'[$a-zA-Z_][a-zA-Z0-9_]*', Name.Other),
            (r'[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?', Number.Float),
            (r'0x[0-9a-fA-F]+', Number.Hex),
            (r'[0-9]+', Number.Integer),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
        ]
    }


class ActionScriptLexer(RegexLexer):
    """
    For ActionScript source code.

    *New in Pygments 0.9.*
    """

    name = 'ActionScript'
    aliases = ['as', 'actionscript']
    filenames = ['*.as']
    mimetypes = ['application/x-actionscript', 'text/x-actionscript',
                 'text/actionscript']

    flags = re.DOTALL
    tokens = {
        'root': [
            (r'\s+', Text),
            (r'//.*?\n', Comment),
            (r'/\*.*?\*/', Comment),
            (r'/(\\\\|\\/|[^/\n])*/[gim]*', String.Regex),
            (r'[~\^\*!%&<>\|+=:;,/?\\-]+', Operator),
            (r'[{}\[\]();.]+', Punctuation),
            (r'(case|default|for|each|in|while|do|break|return|continue|if|else|'
             r'throw|try|catch|var|with|new|typeof|arguments|instanceof|this|'
             r'switch)\b', Keyword),
            (r'(class|public|final|internal|native|override|private|protected|'
             r'static|import|extends|implements|interface|intrinsic|return|super|'
             r'dynamic|function|const|get|namespace|package|set)\b',
             Keyword.Declaration),
            (r'(true|false|null|NaN|Infinity|-Infinity|undefined|Void)\b',
             Keyword.Constant),
            (r'(Accessibility|AccessibilityProperties|ActionScriptVersion|'
             r'ActivityEvent|AntiAliasType|ApplicationDomain|AsBroadcaster|Array|'
             r'AsyncErrorEvent|AVM1Movie|BevelFilter|Bitmap|BitmapData|'
             r'BitmapDataChannel|BitmapFilter|BitmapFilterQuality|BitmapFilterType|'
             r'BlendMode|BlurFilter|Boolean|ByteArray|Camera|Capabilities|CapsStyle|'
             r'Class|Color|ColorMatrixFilter|ColorTransform|ContextMenu|'
             r'ContextMenuBuiltInItems|ContextMenuEvent|ContextMenuItem|'
             r'ConvultionFilter|CSMSettings|DataEvent|Date|DefinitionError|'
             r'DeleteObjectSample|Dictionary|DisplacmentMapFilter|DisplayObject|'
             r'DisplacmentMapFilterMode|DisplayObjectContainer|DropShadowFilter|'
             r'Endian|EOFError|Error|ErrorEvent|EvalError|Event|EventDispatcher|'
             r'EventPhase|ExternalInterface|FileFilter|FileReference|'
             r'FileReferenceList|FocusDirection|FocusEvent|Font|FontStyle|FontType|'
             r'FrameLabel|FullScreenEvent|Function|GlowFilter|GradientBevelFilter|'
             r'GradientGlowFilter|GradientType|Graphics|GridFitType|HTTPStatusEvent|'
             r'IBitmapDrawable|ID3Info|IDataInput|IDataOutput|IDynamicPropertyOutput'
             r'IDynamicPropertyWriter|IEventDispatcher|IExternalizable|'
             r'IllegalOperationError|IME|IMEConversionMode|IMEEvent|int|'
             r'InteractiveObject|InterpolationMethod|InvalidSWFError|InvokeEvent|'
             r'IOError|IOErrorEvent|JointStyle|Key|Keyboard|KeyboardEvent|KeyLocation|'
             r'LineScaleMode|Loader|LoaderContext|LoaderInfo|LoadVars|LocalConnection|'
             r'Locale|Math|Matrix|MemoryError|Microphone|MorphShape|Mouse|MouseEvent|'
             r'MovieClip|MovieClipLoader|Namespace|NetConnection|NetStatusEvent|'
             r'NetStream|NewObjectSample|Number|Object|ObjectEncoding|PixelSnapping|'
             r'Point|PrintJob|PrintJobOptions|PrintJobOrientation|ProgressEvent|Proxy|'
             r'QName|RangeError|Rectangle|ReferenceError|RegExp|Responder|Sample|Scene|'
             r'ScriptTimeoutError|Security|SecurityDomain|SecurityError|'
             r'SecurityErrorEvent|SecurityPanel|Selection|Shape|SharedObject|'
             r'SharedObjectFlushStatus|SimpleButton|Socket|Sound|SoundChannel|'
             r'SoundLoaderContext|SoundMixer|SoundTransform|SpreadMethod|Sprite|'
             r'StackFrame|StackOverflowError|Stage|StageAlign|StageDisplayState|'
             r'StageQuality|StageScaleMode|StaticText|StatusEvent|String|StyleSheet|'
             r'SWFVersion|SyncEvent|SyntaxError|System|TextColorType|TextField|'
             r'TextFieldAutoSize|TextFieldType|TextFormat|TextFormatAlign|'
             r'TextLineMetrics|TextRenderer|TextSnapshot|Timer|TimerEvent|Transform|'
             r'TypeError|uint|URIError|URLLoader|URLLoaderDataFormat|URLRequest|'
             r'URLRequestHeader|URLRequestMethod|URLStream|URLVariabeles|VerifyError|'
             r'Video|XML|XMLDocument|XMLList|XMLNode|XMLNodeType|XMLSocket|XMLUI)\b',
             Name.Builtin),
            (r'(decodeURI|decodeURIComponent|encodeURI|escape|eval|isFinite|isNaN|'
             r'isXMLName|clearInterval|fscommand|getTimer|getURL|getVersion|'
             r'isFinite|parseFloat|parseInt|setInterval|trace|updateAfterEvent|'
             r'unescape)\b',Name.Function),
            (r'[$a-zA-Z_][a-zA-Z0-9_]*', Name.Other),
            (r'[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?', Number.Float),
            (r'0x[0-9a-f]+', Number.Hex),
            (r'[0-9]+', Number.Integer),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
        ]
    }

    def analyse_text(text):
        return 0.05


class ActionScript3Lexer(RegexLexer):
    """
    For ActionScript 3 source code.

    *New in Pygments 0.11.*
    """

    name = 'ActionScript 3'
    aliases = ['as3', 'actionscript3']
    filenames = ['*.as']
    mimetypes = ['application/x-actionscript', 'text/x-actionscript',
                 'text/actionscript']

    identifier = r'[$a-zA-Z_][a-zA-Z0-9_]*'

    flags = re.DOTALL | re.MULTILINE
    tokens = {
        'root': [
            (r'\s+', Text),
            (r'(function\s+)(' + identifier + r')(\s*)(\()',
             bygroups(Keyword.Declaration, Name.Function, Text, Operator),
             'funcparams'),
            (r'(var|const)(\s+)(' + identifier + r')(\s*)(:)(\s*)(' + identifier + r')',
             bygroups(Keyword.Declaration, Text, Name, Text, Punctuation, Text,
                      Keyword.Type)),
            (r'(import|package)(\s+)((?:' + identifier + r'|\.)+)(\s*)',
             bygroups(Keyword, Text, Name.Namespace, Text)),
            (r'(new)(\s+)(' + identifier + r')(\s*)(\()',
             bygroups(Keyword, Text, Keyword.Type, Text, Operator)),
            (r'//.*?\n', Comment.Single),
            (r'/\*.*?\*/', Comment.Multiline),
            (r'/(\\\\|\\/|[^\n])*/[gisx]*', String.Regex),
            (r'(\.)(' + identifier + r')', bygroups(Operator, Name.Attribute)),
            (r'(case|default|for|each|in|while|do|break|return|continue|if|else|'
             r'throw|try|catch|with|new|typeof|arguments|instanceof|this|'
             r'switch|import|include|as|is)\b',
             Keyword),
            (r'(class|public|final|internal|native|override|private|protected|'
             r'static|import|extends|implements|interface|intrinsic|return|super|'
             r'dynamic|function|const|get|namespace|package|set)\b',
             Keyword.Declaration),
            (r'(true|false|null|NaN|Infinity|-Infinity|undefined|void)\b',
             Keyword.Constant),
            (r'(decodeURI|decodeURIComponent|encodeURI|escape|eval|isFinite|isNaN|'
             r'isXMLName|clearInterval|fscommand|getTimer|getURL|getVersion|'
             r'isFinite|parseFloat|parseInt|setInterval|trace|updateAfterEvent|'
             r'unescape)\b', Name.Function),
            (identifier, Name),
            (r'[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?', Number.Float),
            (r'0x[0-9a-f]+', Number.Hex),
            (r'[0-9]+', Number.Integer),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
            (r'[~\^\*!%&<>\|+=:;,/?\\{}\[\]();.-]+', Operator),
        ],
        'funcparams': [
            (r'(\s*)(\.\.\.)?(' + identifier + r')(\s*)(:)(\s*)(' +
             identifier + r'|\*)(\s*)',
             bygroups(Text, Punctuation, Name, Text, Operator, Text,
                      Keyword.Type, Text), 'defval'),
            (r'\)', Operator, 'type')
        ],
        'type': [
            (r'(\s*)(:)(\s*)(' + identifier + r'|\*)',
             bygroups(Text, Operator, Text, Keyword.Type), '#pop:2'),
            (r'\s*', Text, '#pop:2')
        ],
        'defval': [
            (r'(=)(\s*)([^(),]+)(\s*)(,?)',
             bygroups(Operator, Text, using(this), Text, Operator), '#pop'),
            (r',?', Operator, '#pop')
        ]
    }

    def analyse_text(text):
        if re.match(r'\w+\s*:\s*\w', text): return 0.3
        return 0.1


class CssLexer(RegexLexer):
    """
    For CSS (Cascading Style Sheets).
    """

    name = 'CSS'
    aliases = ['css']
    filenames = ['*.css']
    mimetypes = ['text/css']

    tokens = {
        'root': [
            include('basics'),
        ],
        'basics': [
            (r'\s+', Text),
            (r'/\*(?:.|\n)*?\*/', Comment),
            (r'{', Punctuation, 'content'),
            (r'\:[a-zA-Z0-9_-]+', Name.Decorator),
            (r'\.[a-zA-Z0-9_-]+', Name.Class),
            (r'\#[a-zA-Z0-9_-]+', Name.Function),
            (r'@[a-zA-Z0-9_-]+', Keyword, 'atrule'),
            (r'[a-zA-Z0-9_-]+', Name.Tag),
            (r'[~\^\*!%&\[\]\(\)<>\|+=@:;,./?-]', Operator),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single)
        ],
        'atrule': [
            (r'{', Punctuation, 'atcontent'),
            (r';', Punctuation, '#pop'),
            include('basics'),
        ],
        'atcontent': [
            include('basics'),
            (r'}', Punctuation, '#pop:2'),
        ],
        'content': [
            (r'\s+', Text),
            (r'}', Punctuation, '#pop'),
            (r'url\(.*?\)', String.Other),
            (r'^@.*?$', Comment.Preproc),
            (r'(azimuth|background-attachment|background-color|'
             r'background-image|background-position|background-repeat|'
             r'background|border-bottom-color|border-bottom-style|'
             r'border-bottom-width|border-left-color|border-left-style|'
             r'border-left-width|border-right|border-right-color|'
             r'border-right-style|border-right-width|border-top-color|'
             r'border-top-style|border-top-width|border-bottom|'
             r'border-collapse|border-left|border-width|border-color|'
             r'border-spacing|border-style|border-top|border|caption-side|'
             r'clear|clip|color|content|counter-increment|counter-reset|'
             r'cue-after|cue-before|cue|cursor|direction|display|'
             r'elevation|empty-cells|float|font-family|font-size|'
             r'font-size-adjust|font-stretch|font-style|font-variant|'
             r'font-weight|font|height|letter-spacing|line-height|'
             r'list-style-type|list-style-image|list-style-position|'
             r'list-style|margin-bottom|margin-left|margin-right|'
             r'margin-top|margin|marker-offset|marks|max-height|max-width|'
             r'min-height|min-width|opacity|orphans|outline|outline-color|'
             r'outline-style|outline-width|overflow|padding-bottom|'
             r'padding-left|padding-right|padding-top|padding|page|'
             r'page-break-after|page-break-before|page-break-inside|'
             r'pause-after|pause-before|pause|pitch|pitch-range|'
             r'play-during|position|quotes|richness|right|size|'
             r'speak-header|speak-numeral|speak-punctuation|speak|'
             r'speech-rate|stress|table-layout|text-align|text-decoration|'
             r'text-indent|text-shadow|text-transform|top|unicode-bidi|'
             r'vertical-align|visibility|voice-family|volume|white-space|'
             r'widows|width|word-spacing|z-index|bottom|left|'
             r'above|absolute|always|armenian|aural|auto|avoid|baseline|'
             r'behind|below|bidi-override|blink|block|bold|bolder|both|'
             r'capitalize|center-left|center-right|center|circle|'
             r'cjk-ideographic|close-quote|collapse|condensed|continuous|'
             r'crop|crosshair|cross|cursive|dashed|decimal-leading-zero|'
             r'decimal|default|digits|disc|dotted|double|e-resize|embed|'
             r'extra-condensed|extra-expanded|expanded|fantasy|far-left|'
             r'far-right|faster|fast|fixed|georgian|groove|hebrew|help|'
             r'hidden|hide|higher|high|hiragana-iroha|hiragana|icon|'
             r'inherit|inline-table|inline|inset|inside|invert|italic|'
             r'justify|katakana-iroha|katakana|landscape|larger|large|'
             r'left-side|leftwards|level|lighter|line-through|list-item|'
             r'loud|lower-alpha|lower-greek|lower-roman|lowercase|ltr|'
             r'lower|low|medium|message-box|middle|mix|monospace|'
             r'n-resize|narrower|ne-resize|no-close-quote|no-open-quote|'
             r'no-repeat|none|normal|nowrap|nw-resize|oblique|once|'
             r'open-quote|outset|outside|overline|pointer|portrait|px|'
             r'relative|repeat-x|repeat-y|repeat|rgb|ridge|right-side|'
             r'rightwards|s-resize|sans-serif|scroll|se-resize|'
             r'semi-condensed|semi-expanded|separate|serif|show|silent|'
             r'slow|slower|small-caps|small-caption|smaller|soft|solid|'
             r'spell-out|square|static|status-bar|super|sw-resize|'
             r'table-caption|table-cell|table-column|table-column-group|'
             r'table-footer-group|table-header-group|table-row|'
             r'table-row-group|text|text-bottom|text-top|thick|thin|'
             r'transparent|ultra-condensed|ultra-expanded|underline|'
             r'upper-alpha|upper-latin|upper-roman|uppercase|url|'
             r'visible|w-resize|wait|wider|x-fast|x-high|x-large|x-loud|'
             r'x-low|x-small|x-soft|xx-large|xx-small|yes)\b', Keyword),
            (r'(indigo|gold|firebrick|indianred|yellow|darkolivegreen|'
             r'darkseagreen|mediumvioletred|mediumorchid|chartreuse|'
             r'mediumslateblue|black|springgreen|crimson|lightsalmon|brown|'
             r'turquoise|olivedrab|cyan|silver|skyblue|gray|darkturquoise|'
             r'goldenrod|darkgreen|darkviolet|darkgray|lightpink|teal|'
             r'darkmagenta|lightgoldenrodyellow|lavender|yellowgreen|thistle|'
             r'violet|navy|orchid|blue|ghostwhite|honeydew|cornflowerblue|'
             r'darkblue|darkkhaki|mediumpurple|cornsilk|red|bisque|slategray|'
             r'darkcyan|khaki|wheat|deepskyblue|darkred|steelblue|aliceblue|'
             r'gainsboro|mediumturquoise|floralwhite|coral|purple|lightgrey|'
             r'lightcyan|darksalmon|beige|azure|lightsteelblue|oldlace|'
             r'greenyellow|royalblue|lightseagreen|mistyrose|sienna|'
             r'lightcoral|orangered|navajowhite|lime|palegreen|burlywood|'
             r'seashell|mediumspringgreen|fuchsia|papayawhip|blanchedalmond|'
             r'peru|aquamarine|white|darkslategray|ivory|dodgerblue|'
             r'lemonchiffon|chocolate|orange|forestgreen|slateblue|olive|'
             r'mintcream|antiquewhite|darkorange|cadetblue|moccasin|'
             r'limegreen|saddlebrown|darkslateblue|lightskyblue|deeppink|'
             r'plum|aqua|darkgoldenrod|maroon|sandybrown|magenta|tan|'
             r'rosybrown|pink|lightblue|palevioletred|mediumseagreen|'
             r'dimgray|powderblue|seagreen|snow|mediumblue|midnightblue|'
             r'paleturquoise|palegoldenrod|whitesmoke|darkorchid|salmon|'
             r'lightslategray|lawngreen|lightgreen|tomato|hotpink|'
             r'lightyellow|lavenderblush|linen|mediumaquamarine|green|'
             r'blueviolet|peachpuff)\b', Name.Builtin),
            (r'\!important', Comment.Preproc),
            (r'/\*(?:.|\n)*?\*/', Comment),
            (r'\#[a-zA-Z0-9]{1,6}', Number),
            (r'[\.-]?[0-9]*[\.]?[0-9]+(em|px|\%|pt|pc|in|mm|cm|ex)', Number),
            (r'-?[0-9]+', Number),
            (r'[~\^\*!%&<>\|+=@:,./?-]+', Operator),
            (r'[\[\]();]+', Punctuation),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r"'(\\\\|\\'|[^'])*'", String.Single),
            (r'[a-zA-Z][a-zA-Z0-9]+', Name)
        ]
    }


class HtmlLexer(RegexLexer):
    """
    For HTML 4 and XHTML 1 markup. Nested JavaScript and CSS is highlighted
    by the appropriate lexer.
    """

    name = 'HTML'
    aliases = ['html']
    filenames = ['*.html', '*.htm', '*.xhtml', '*.xslt']
    mimetypes = ['text/html', 'application/xhtml+xml']

    flags = re.IGNORECASE | re.DOTALL
    tokens = {
        'root': [
            ('[^<&]+', Text),
            (r'&\S*?;', Name.Entity),
            (r'\<\!\[CDATA\[.*?\]\]\>', Comment.Preproc),
            ('<!--', Comment, 'comment'),
            (r'<\?.*?\?>', Comment.Preproc),
            ('<![^>]*>', Comment.Preproc),
            (r'<\s*script\s*', Name.Tag, ('script-content', 'tag')),
            (r'<\s*style\s*', Name.Tag, ('style-content', 'tag')),
            (r'<\s*[a-zA-Z0-9:]+', Name.Tag, 'tag'),
            (r'<\s*/\s*[a-zA-Z0-9:]+\s*>', Name.Tag),
        ],
        'comment': [
            ('[^-]+', Comment),
            ('-->', Comment, '#pop'),
            ('-', Comment),
        ],
        'tag': [
            (r'\s+', Text),
            (r'[a-zA-Z0-9_:-]+\s*=', Name.Attribute, 'attr'),
            (r'[a-zA-Z0-9_:-]+', Name.Attribute),
            (r'/?\s*>', Name.Tag, '#pop'),
        ],
        'script-content': [
            (r'<\s*/\s*script\s*>', Name.Tag, '#pop'),
            (r'.+?(?=<\s*/\s*script\s*>)', using(JavascriptLexer)),
        ],
        'style-content': [
            (r'<\s*/\s*style\s*>', Name.Tag, '#pop'),
            (r'.+?(?=<\s*/\s*style\s*>)', using(CssLexer)),
        ],
        'attr': [
            ('".*?"', String, '#pop'),
            ("'.*?'", String, '#pop'),
            (r'[^\s>]+', String, '#pop'),
        ],
    }

    def analyse_text(text):
        if html_doctype_matches(text):
            return 0.5


class PhpLexer(RegexLexer):
    """
    For `PHP <http://www.php.net/>`_ source code.
    For PHP embedded in HTML, use the `HtmlPhpLexer`.

    Additional options accepted:

    `startinline`
        If given and ``True`` the lexer starts highlighting with
        php code (i.e.: no starting ``<?php`` required).  The default
        is ``False``.
    `funcnamehighlighting`
        If given and ``True``, highlight builtin function names
        (default: ``True``).
    `disabledmodules`
        If given, must be a list of module names whose function names
        should not be highlighted. By default all modules are highlighted
        except the special ``'unknown'`` module that includes functions
        that are known to php but are undocumented.

        To get a list of allowed modules have a look into the
        `_phpbuiltins` module:

        .. sourcecode:: pycon

            >>> from pygments.lexers._phpbuiltins import MODULES
            >>> MODULES.keys()
            ['PHP Options/Info', 'Zip', 'dba', ...]

        In fact the names of those modules match the module names from
        the php documentation.
    """

    name = 'PHP'
    aliases = ['php', 'php3', 'php4', 'php5']
    filenames = ['*.php', '*.php[345]']
    mimetypes = ['text/x-php']

    flags = re.IGNORECASE | re.DOTALL | re.MULTILINE
    tokens = {
        'root': [
            (r'<\?(php)?', Comment.Preproc, 'php'),
            (r'[^<]+', Other),
            (r'<', Other)
        ],
        'php': [
            (r'\?>', Comment.Preproc, '#pop'),
            (r'<<<([a-zA-Z_][a-zA-Z0-9_]*)\n.*?\n\1\;?\n', String),
            (r'\s+', Text),
            (r'#.*?\n', Comment),
            (r'//.*?\n', Comment),
            (r'/\*\*/', Comment), # put the empty comment here, it is otherwise
                                  # seen as the start of a docstring
            (r'/\*\*.*?\*/', String.Doc),
            (r'/\*.*?\*/', Comment),
            (r'(->|::)(\s*)([a-zA-Z_][a-zA-Z0-9_]*)',
             bygroups(Operator, Text, Name.Attribute)),
            (r'[~!%^&*+=|:.<>/?@-]+', Operator),
            (r'[\[\]{}();,]+', Punctuation),
            (r'(class)(\s+)', bygroups(Keyword, Text), 'classname'),
            (r'(function)(\s+)(&?)(\s*)',
              bygroups(Keyword, Text, Operator, Text), 'functionname'),
            (r'(const)(\s+)([a-zA-Z_][a-zA-Z0-9_]*)',
              bygroups(Keyword, Text, Name.Constant)),
            (r'(and|E_PARSE|old_function|E_ERROR|or|as|E_WARNING|parent|'
             r'eval|PHP_OS|break|exit|case|extends|PHP_VERSION|cfunction|'
             r'FALSE|print|for|require|continue|foreach|require_once|'
             r'declare|return|default|static|do|switch|die|stdClass|'
             r'echo|else|TRUE|elseif|var|empty|if|xor|enddeclare|include|'
             r'virtual|endfor|include_once|while|endforeach|global|__FILE__|'
             r'endif|list|__LINE__|endswitch|new|__sleep|endwhile|not|'
             r'array|__wakeup|E_ALL|NULL|final|php_user_filter|interface|'
             r'implements|public|private|protected|abstract|clone|try|'
             r'catch|throw|this)\b', Keyword),
            ('(true|false|null)\b', Keyword.Constant),
            (r'\$\{\$+[a-zA-Z_][a-zA-Z0-9_]*\}', Name.Variable),
            (r'\$+[a-zA-Z_][a-zA-Z0-9_]*', Name.Variable),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Other),
            (r"[0-9](\.[0-9]*)?(eE[+-][0-9])?[flFLdD]?|"
             r"0[xX][0-9a-fA-F]+[Ll]?", Number),
            (r"'([^'\\]*(?:\\.[^'\\]*)*)'", String.Single),
            (r'`([^`\\]*(?:\\.[^`\\]*)*)`', String.Backtick),
            (r'"', String.Double, 'string'),
        ],
        'classname': [
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name.Class, '#pop')
        ],
        'functionname': [
            (r'[a-zA-Z_][a-zA-Z0-9_]*', Name.Function, '#pop')
        ],
        'string': [
            (r'"', String.Double, '#pop'),
            (r'[^{$"\\]+', String.Double),
            (r'\\([nrt\"$]|[0-7]{1,3}|x[0-9A-Fa-f]{1,2})', String.Escape),
            (r'\$[a-zA-Z_][a-zA-Z0-9_]*(\[\S+\]|->[a-zA-Z_][a-zA-Z0-9_]*)?',
             String.Interpol),
            (r'(\{\$\{)(.*?)(\}\})',
             bygroups(String.Interpol, using(this, _startinline=True),
                      String.Interpol)),
            (r'(\{)(\$.*?)(\})',
             bygroups(String.Interpol, using(this, _startinline=True),
                      String.Interpol)),
            (r'(\$\{)(\S+)(\})',
             bygroups(String.Interpol, Name.Variable, String.Interpol)),
            (r'[${\\]+', String.Double)
        ],
    }

    def __init__(self, **options):
        self.funcnamehighlighting = get_bool_opt(
            options, 'funcnamehighlighting', True)
        self.disabledmodules = get_list_opt(
            options, 'disabledmodules', ['unknown'])
        self.startinline = get_bool_opt(options, 'startinline', False)

        # private option argument for the lexer itself
        if '_startinline' in options:
            self.startinline = options.pop('_startinline')

        # collect activated functions in a set
        self._functions = set()
        if self.funcnamehighlighting:
            from pygments.lexers._phpbuiltins import MODULES
            for key, value in MODULES.iteritems():
                if key not in self.disabledmodules:
                    self._functions.update(value)
        RegexLexer.__init__(self, **options)

    def get_tokens_unprocessed(self, text):
        stack = ['root']
        if self.startinline:
            stack.append('php')
        for index, token, value in \
            RegexLexer.get_tokens_unprocessed(self, text, stack):
            if token is Name.Other:
                if value in self._functions:
                    yield index, Name.Builtin, value
                    continue
            yield index, token, value

    def analyse_text(text):
        rv = 0.0
        if re.search(r'<\?(?!xml)', text):
            rv += 0.3
        if '?>' in text:
            rv += 0.1
        return rv


class XmlLexer(RegexLexer):
    """
    Generic lexer for XML (eXtensible Markup Language).
    """

    flags = re.MULTILINE | re.DOTALL

    name = 'XML'
    aliases = ['xml']
    filenames = ['*.xml', '*.xsl', '*.rss', '*.xslt', '*.xsd', '*.wsdl']
    mimetypes = ['text/xml', 'application/xml', 'image/svg+xml',
                 'application/rss+xml', 'application/atom+xml',
                 'application/xsl+xml', 'application/xslt+xml']

    tokens = {
        'root': [
            ('[^<&]+', Text),
            (r'&\S*?;', Name.Entity),
            (r'\<\!\[CDATA\[.*?\]\]\>', Comment.Preproc),
            ('<!--', Comment, 'comment'),
            (r'<\?.*?\?>', Comment.Preproc),
            ('<![^>]*>', Comment.Preproc),
            (r'<\s*[a-zA-Z0-9:._-]+', Name.Tag, 'tag'),
            (r'<\s*/\s*[a-zA-Z0-9:._-]+\s*>', Name.Tag),
        ],
        'comment': [
            ('[^-]+', Comment),
            ('-->', Comment, '#pop'),
            ('-', Comment),
        ],
        'tag': [
            (r'\s+', Text),
            (r'[a-zA-Z0-9_.:-]+\s*=', Name.Attribute, 'attr'),
            (r'/?\s*>', Name.Tag, '#pop'),
        ],
        'attr': [
            ('\s+', Text),
            ('".*?"', String, '#pop'),
            ("'.*?'", String, '#pop'),
            (r'[^\s>]+', String, '#pop'),
        ],
    }

    def analyse_text(text):
        if looks_like_xml(text):
            return 0.5


class XsltLexer(XmlLexer):
    '''
    A lexer for XSLT.

    *New in Pygments 0.10.*
    '''

    name = 'XSLT'
    aliases = ['xslt']
    filenames = ['*.xsl', '*.xslt']

    EXTRA_KEYWORDS = set([
        'apply-imports', 'apply-templates', 'attribute',
        'attribute-set', 'call-template', 'choose', 'comment',
        'copy', 'copy-of', 'decimal-format', 'element', 'fallback',
        'for-each', 'if', 'import', 'include', 'key', 'message',
        'namespace-alias', 'number', 'otherwise', 'output', 'param',
        'preserve-space', 'processing-instruction', 'sort',
        'strip-space', 'stylesheet', 'template', 'text', 'transform',
        'value-of', 'variable', 'when', 'with-param'
    ])

    def get_tokens_unprocessed(self, text):
        for index, token, value in XmlLexer.get_tokens_unprocessed(self, text):
            m = re.match('</?xsl:([^>]*)/?>?', value)

            if token is Name.Tag and m and m.group(1) in self.EXTRA_KEYWORDS:
                yield index, Keyword, value
            else:
                yield index, token, value

    def analyse_text(text):
        if looks_like_xml(text) and '<xsl' in text:
            return 0.8



class MxmlLexer(RegexLexer):
    """
    For MXML markup.
    Nested AS3 in <script> tags is highlighted by the appropriate lexer.
    """
    flags = re.MULTILINE | re.DOTALL
    name = 'MXML'
    aliases = ['mxml']
    filenames = ['*.mxml']
    mimetimes = ['text/xml', 'application/xml']

    tokens = {
            'root': [
                ('[^<&]+', Text),
                (r'&\S*?;', Name.Entity),
                (r'(\<\!\[CDATA\[)(.*?)(\]\]\>)',
                 bygroups(String, using(ActionScript3Lexer), String)),
                ('<!--', Comment, 'comment'),
                (r'<\?.*?\?>', Comment.Preproc),
                ('<![^>]*>', Comment.Preproc),
                (r'<\s*[a-zA-Z0-9:._-]+', Name.Tag, 'tag'),
                (r'<\s*/\s*[a-zA-Z0-9:._-]+\s*>', Name.Tag),
            ],
            'comment': [
                ('[^-]+', Comment),
                ('-->', Comment, '#pop'),
                ('-', Comment),
            ],
            'tag': [
                (r'\s+', Text),
                (r'[a-zA-Z0-9_.:-]+\s*=', Name.Attribute, 'attr'),
                (r'/?\s*>', Name.Tag, '#pop'),
            ],
            'attr': [
                ('\s+', Text),
                ('".*?"', String, '#pop'),
                ("'.*?'", String, '#pop'),
                (r'[^\s>]+', String, '#pop'),
            ],
        }
# -*- coding: utf-8 -*-
"""
    pygments.plugin
    ~~~~~~~~~~~~~~~

    Pygments setuptools plugin interface. The methods defined
    here also work if setuptools isn't installed but they just
    return nothing.

    lexer plugins::

        [pygments.lexers]
        yourlexer = yourmodule:YourLexer

    formatter plugins::

        [pygments.formatters]
        yourformatter = yourformatter:YourFormatter
        /.ext = yourformatter:YourFormatter

    As you can see, you can define extensions for the formatter
    with a leading slash.

    syntax plugins::

        [pygments.styles]
        yourstyle = yourstyle:YourStyle

    filter plugin::

        [pygments.filter]
        yourfilter = yourfilter:YourFilter


    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
try:
    import pkg_resources
except ImportError:
    pkg_resources = None

LEXER_ENTRY_POINT = 'pygments.lexers'
FORMATTER_ENTRY_POINT = 'pygments.formatters'
STYLE_ENTRY_POINT = 'pygments.styles'
FILTER_ENTRY_POINT = 'pygments.filters'


def find_plugin_lexers():
    if pkg_resources is None:
        return
    for entrypoint in pkg_resources.iter_entry_points(LEXER_ENTRY_POINT):
        yield entrypoint.load()


def find_plugin_formatters():
    if pkg_resources is None:
        return
    for entrypoint in pkg_resources.iter_entry_points(FORMATTER_ENTRY_POINT):
        yield entrypoint.name, entrypoint.load()


def find_plugin_styles():
    if pkg_resources is None:
        return
    for entrypoint in pkg_resources.iter_entry_points(STYLE_ENTRY_POINT):
        yield entrypoint.name, entrypoint.load()


def find_plugin_filters():
    if pkg_resources is None:
        return
    for entrypoint in pkg_resources.iter_entry_points(FILTER_ENTRY_POINT):
        yield entrypoint.name, entrypoint.load()
# -*- coding: utf-8 -*-
"""
    pygments.scanner
    ~~~~~~~~~~~~~~~~

    This library implements a regex based scanner. Some languages
    like Pascal are easy to parse but have some keywords that
    depend on the context. Because of this it's impossible to lex
    that just by using a regular expression lexer like the
    `RegexLexer`.

    Have a look at the `DelphiLexer` to get an idea of how to use
    this scanner.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import re


class EndOfText(RuntimeError):
    """
    Raise if end of text is reached and the user
    tried to call a match function.
    """


class Scanner(object):
    """
    Simple scanner

    All method patterns are regular expression strings (not
    compiled expressions!)
    """

    def __init__(self, text, flags=0):
        """
        :param text:    The text which should be scanned
        :param flags:   default regular expression flags
        """
        self.data = text
        self.data_length = len(text)
        self.start_pos = 0
        self.pos = 0
        self.flags = flags
        self.last = None
        self.match = None
        self._re_cache = {}

    def eos(self):
        """`True` if the scanner reached the end of text."""
        return self.pos >= self.data_length
    eos = property(eos, eos.__doc__)

    def check(self, pattern):
        """
        Apply `pattern` on the current position and return
        the match object. (Doesn't touch pos). Use this for
        lookahead.
        """
        if self.eos:
            raise EndOfText()
        if pattern not in self._re_cache:
            self._re_cache[pattern] = re.compile(pattern, self.flags)
        return self._re_cache[pattern].match(self.data, self.pos)

    def test(self, pattern):
        """Apply a pattern on the current position and check
        if it patches. Doesn't touch pos."""
        return self.check(pattern) is not None

    def scan(self, pattern):
        """
        Scan the text for the given pattern and update pos/match
        and related fields. The return value is a boolen that
        indicates if the pattern matched. The matched value is
        stored on the instance as ``match``, the last value is
        stored as ``last``. ``start_pos`` is the position of the
        pointer before the pattern was matched, ``pos`` is the
        end position.
        """
        if self.eos:
            raise EndOfText()
        if pattern not in self._re_cache:
            self._re_cache[pattern] = re.compile(pattern, self.flags)
        self.last = self.match
        m = self._re_cache[pattern].match(self.data, self.pos)
        if m is None:
            return False
        self.start_pos = m.start()
        self.pos = m.end()
        self.match = m.group()
        return True

    def get_char(self):
        """Scan exactly one char."""
        self.scan('.')

    def __repr__(self):
        return '<%s %d/%d>' % (
            self.__class__.__name__,
            self.pos,
            self.data_length
        )
# -*- coding: utf-8 -*-
"""
    pygments.style
    ~~~~~~~~~~~~~~

    Basic style object.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.token import Token, STANDARD_TYPES


class StyleMeta(type):

    def __new__(mcs, name, bases, dct):
        obj = type.__new__(mcs, name, bases, dct)
        for token in STANDARD_TYPES:
            if token not in obj.styles:
                obj.styles[token] = ''

        def colorformat(text):
            if text[0:1] == '#':
                col = text[1:]
                if len(col) == 6:
                    return col
                elif len(col) == 3:
                    return col[0]+'0'+col[1]+'0'+col[2]+'0'
            elif text == '':
                return ''
            assert False, "wrong color format %r" % text

        _styles = obj._styles = {}

        for ttype in obj.styles:
            for token in ttype.split():
                if token in _styles:
                    continue
                ndef = _styles.get(token.parent, None)
                styledefs = obj.styles.get(token, '').split()
                if  not ndef or token is None:
                    ndef = ['', 0, 0, 0, '', '', 0, 0, 0]
                elif 'noinherit' in styledefs and token is not Token:
                    ndef = _styles[Token][:]
                else:
                    ndef = ndef[:]
                _styles[token] = ndef
                for styledef in obj.styles.get(token, '').split():
                    if styledef == 'noinherit':
                        pass
                    elif styledef == 'bold':
                        ndef[1] = 1
                    elif styledef == 'nobold':
                        ndef[1] = 0
                    elif styledef == 'italic':
                        ndef[2] = 1
                    elif styledef == 'noitalic':
                        ndef[2] = 0
                    elif styledef == 'underline':
                        ndef[3] = 1
                    elif styledef == 'nounderline':
                        ndef[3] = 0
                    elif styledef[:3] == 'bg:':
                        ndef[4] = colorformat(styledef[3:])
                    elif styledef[:7] == 'border:':
                        ndef[5] = colorformat(styledef[7:])
                    elif styledef == 'roman':
                        ndef[6] = 1
                    elif styledef == 'sans':
                        ndef[7] = 1
                    elif styledef == 'mono':
                        ndef[8] = 1
                    else:
                        ndef[0] = colorformat(styledef)

        return obj

    def style_for_token(cls, token):
        t = cls._styles[token]
        return {
            'color':        t[0] or None,
            'bold':         bool(t[1]),
            'italic':       bool(t[2]),
            'underline':    bool(t[3]),
            'bgcolor':      t[4] or None,
            'border':       t[5] or None,
            'roman':        bool(t[6]) or None,
            'sans':         bool(t[7]) or None,
            'mono':         bool(t[8]) or None,
        }

    def list_styles(cls):
        return list(cls)

    def styles_token(cls, ttype):
        return ttype in cls._styles

    def __iter__(cls):
        for token in cls._styles:
            yield token, cls.style_for_token(token)

    def __len__(cls):
        return len(cls._styles)


class Style(object):
    __metaclass__ = StyleMeta

    #: overall background color (``None`` means transparent)
    background_color = '#ffffff'

    #: highlight background color
    highlight_color = '#ffffcc'

    #: Style definitions for individual token types.
    styles = {}
# -*- coding: utf-8 -*-
"""
    pygments.styles
    ~~~~~~~~~~~~~~~

    Contains built-in styles.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.plugin import find_plugin_styles
from pygments.util import ClassNotFound


#: Maps style names to 'submodule::classname'.
STYLE_MAP = {
    'default':  'default::DefaultStyle',
    'emacs':    'emacs::EmacsStyle',
    'friendly': 'friendly::FriendlyStyle',
    'colorful': 'colorful::ColorfulStyle',
    'autumn':   'autumn::AutumnStyle',
    'murphy':   'murphy::MurphyStyle',
    'manni':    'manni::ManniStyle',
    'perldoc':  'perldoc::PerldocStyle',
    'pastie':   'pastie::PastieStyle',
    'borland':  'borland::BorlandStyle',
    'trac':     'trac::TracStyle',
    'native':   'native::NativeStyle',
    'fruity':   'fruity::FruityStyle',
    'bw':       'bw::BlackWhiteStyle',
    'vs':       'vs::VisualStudioStyle',
    'tango':    'tango::TangoStyle',
}


def get_style_by_name(name):
    if name in STYLE_MAP:
        mod, cls = STYLE_MAP[name].split('::')
        builtin = "yes"
    else:
        for found_name, style in find_plugin_styles():
            if name == found_name:
                return style
        # perhaps it got dropped into our styles package
        builtin = ""
        mod = name
        cls = name.title() + "Style"

    try:
        mod = __import__('pygments.styles.' + mod, None, None, [cls])
    except ImportError:
        raise ClassNotFound("Could not find style module %r" % mod +
                         (builtin and ", though it should be builtin") + ".")
    try:
        return getattr(mod, cls)
    except AttributeError:
        raise ClassNotFound("Could not find style class %r in style module." % cls)


def get_all_styles():
    """Return an generator for all styles by name,
    both builtin and plugin."""
    for name in STYLE_MAP:
        yield name
    for name, _ in find_plugin_styles():
        yield name
# -*- coding: utf-8 -*-
"""
    pygments.styles.autumn
    ~~~~~~~~~~~~~~~~~~~~~~

    A colorful style, inspired by the terminal highlighting style.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class AutumnStyle(Style):
    """
    A colorful style, inspired by the terminal highlighting style.
    """

    default_style = ""

    styles = {
        Whitespace:                 '#bbbbbb',

        Comment:                    'italic #aaaaaa',
        Comment.Preproc:            'noitalic #4c8317',
        Comment.Special:            'italic #0000aa',

        Keyword:                    '#0000aa',
        Keyword.Type:               '#00aaaa',

        Operator.Word:              '#0000aa',

        Name.Builtin:               '#00aaaa',
        Name.Function:              '#00aa00',
        Name.Class:                 'underline #00aa00',
        Name.Namespace:             'underline #00aaaa',
        Name.Variable:              '#aa0000',
        Name.Constant:              '#aa0000',
        Name.Entity:                'bold #800',
        Name.Attribute:             '#1e90ff',
        Name.Tag:                   'bold #1e90ff',
        Name.Decorator:             '#888888',

        String:                     '#aa5500',
        String.Symbol:              '#0000aa',
        String.Regex:               '#009999',

        Number:                     '#009999',

        Generic.Heading:            'bold #000080',
        Generic.Subheading:         'bold #800080',
        Generic.Deleted:            '#aa0000',
        Generic.Inserted:           '#00aa00',
        Generic.Error:              '#aa0000',
        Generic.Emph:               'italic',
        Generic.Strong:             'bold',
        Generic.Prompt:             '#555555',
        Generic.Output:             '#888888',
        Generic.Traceback:          '#aa0000',

        Error:                      '#F00 bg:#FAA'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.borland
    ~~~~~~~~~~~~~~~~~~~~~~~

    Style similar to the style used in the Borland IDEs.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class BorlandStyle(Style):
    """
    Style similar to the style used in the borland IDEs.
    """

    default_style = ''

    styles = {
        Whitespace:             '#bbbbbb',

        Comment:                'italic #008800',
        Comment.Preproc:        'noitalic #008080',
        Comment.Special:        'noitalic bold',

        String:                 '#0000FF',
        String.Char:            '#800080',
        Number:                 '#0000FF',
        Keyword:                'bold #000080',
        Operator.Word:          'bold',
        Name.Tag:               'bold #000080',
        Name.Attribute:         '#FF0000',

        Generic.Heading:        '#999999',
        Generic.Subheading:     '#aaaaaa',
        Generic.Deleted:        'bg:#ffdddd #000000',
        Generic.Inserted:       'bg:#ddffdd #000000',
        Generic.Error:          '#aa0000',
        Generic.Emph:           'italic',
        Generic.Strong:         'bold',
        Generic.Prompt:         '#555555',
        Generic.Output:         '#888888',
        Generic.Traceback:      '#aa0000',

        Error:                  'bg:#e3d2d2 #a61717'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.bw
    ~~~~~~~~~~~~~~~~~~

    Simple black/white only style.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Operator, Generic


class BlackWhiteStyle(Style):

    background_color = "#ffffff"
    default_style = ""

    styles = {
        Comment:                   "italic",
        Comment.Preproc:           "noitalic",

        Keyword:                   "bold",
        Keyword.Pseudo:            "nobold",
        Keyword.Type:              "nobold",

        Operator.Word:             "bold",

        Name.Class:                "bold",
        Name.Namespace:            "bold",
        Name.Exception:            "bold",
        Name.Entity:               "bold",
        Name.Tag:                  "bold",

        String:                    "italic",
        String.Interpol:           "bold",
        String.Escape:             "bold",

        Generic.Heading:           "bold",
        Generic.Subheading:        "bold",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold",

        Error:                     "border:#FF0000"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.colorful
    ~~~~~~~~~~~~~~~~~~~~~~~~

    A colorful style, inspired by CodeRay.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class ColorfulStyle(Style):
    """
    A colorful style, inspired by CodeRay.
    """

    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",

        Comment:                   "#888",
        Comment.Preproc:           "#579",
        Comment.Special:           "bold #cc0000",

        Keyword:                   "bold #080",
        Keyword.Pseudo:            "#038",
        Keyword.Type:              "#339",

        Operator:                  "#333",
        Operator.Word:             "bold #000",

        Name.Builtin:              "#007020",
        Name.Function:             "bold #06B",
        Name.Class:                "bold #B06",
        Name.Namespace:            "bold #0e84b5",
        Name.Exception:            "bold #F00",
        Name.Variable:             "#963",
        Name.Variable.Instance:    "#33B",
        Name.Variable.Class:       "#369",
        Name.Variable.Global:      "bold #d70",
        Name.Constant:             "bold #036",
        Name.Label:                "bold #970",
        Name.Entity:               "bold #800",
        Name.Attribute:            "#00C",
        Name.Tag:                  "#070",
        Name.Decorator:            "bold #555",

        String:                    "bg:#fff0f0",
        String.Char:               "#04D bg:",
        String.Doc:                "#D42 bg:",
        String.Interpol:           "bg:#eee",
        String.Escape:             "bold #666",
        String.Regex:              "bg:#fff0ff #000",
        String.Symbol:             "#A60 bg:",
        String.Other:              "#D20",

        Number:                    "bold #60E",
        Number.Integer:            "bold #00D",
        Number.Float:              "bold #60E",
        Number.Hex:                "bold #058",
        Number.Oct:                "bold #40E",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#A00000",
        Generic.Inserted:          "#00A000",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #c65d09",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "#F00 bg:#FAA"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.default
    ~~~~~~~~~~~~~~~~~~~~~~~

    The default highlighting style.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class DefaultStyle(Style):
    """
    The default style (inspired by Emacs 22).
    """

    background_color = "#f8f8f8"
    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",
        Comment:                   "italic #408080",
        Comment.Preproc:           "noitalic #BC7A00",

        #Keyword:                   "bold #AA22FF",
        Keyword:                   "bold #008000",
        Keyword.Pseudo:            "nobold",
        Keyword.Type:              "nobold #B00040",

        Operator:                  "#666666",
        Operator.Word:             "bold #AA22FF",

        Name.Builtin:              "#008000",
        Name.Function:             "#0000FF",
        Name.Class:                "bold #0000FF",
        Name.Namespace:            "bold #0000FF",
        Name.Exception:            "bold #D2413A",
        Name.Variable:             "#19177C",
        Name.Constant:             "#880000",
        Name.Label:                "#A0A000",
        Name.Entity:               "bold #999999",
        Name.Attribute:            "#7D9029",
        Name.Tag:                  "bold #008000",
        Name.Decorator:            "#AA22FF",

        String:                    "#BA2121",
        String.Doc:                "italic",
        String.Interpol:           "bold #BB6688",
        String.Escape:             "bold #BB6622",
        String.Regex:              "#BB6688",
        #String.Symbol:             "#B8860B",
        String.Symbol:             "#19177C",
        String.Other:              "#008000",
        Number:                    "#666666",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#A00000",
        Generic.Inserted:          "#00A000",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #000080",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "border:#FF0000"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.emacs
    ~~~~~~~~~~~~~~~~~~~~~

    A highlighting style for Pygments, inspired by Emacs.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class EmacsStyle(Style):
    """
    The default style (inspired by Emacs 22).
    """

    background_color = "#f8f8f8"
    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",
        Comment:                   "italic #008800",
        Comment.Preproc:           "noitalic",
        Comment.Special:           "noitalic bold",

        Keyword:                   "bold #AA22FF",
        Keyword.Pseudo:            "nobold",
        Keyword.Type:              "bold #00BB00",

        Operator:                  "#666666",
        Operator.Word:             "bold #AA22FF",

        Name.Builtin:              "#AA22FF",
        Name.Function:             "#00A000",
        Name.Class:                "#0000FF",
        Name.Namespace:            "bold #0000FF",
        Name.Exception:            "bold #D2413A",
        Name.Variable:             "#B8860B",
        Name.Constant:             "#880000",
        Name.Label:                "#A0A000",
        Name.Entity:               "bold #999999",
        Name.Attribute:            "#BB4444",
        Name.Tag:                  "bold #008000",
        Name.Decorator:            "#AA22FF",

        String:                    "#BB4444",
        String.Doc:                "italic",
        String.Interpol:           "bold #BB6688",
        String.Escape:             "bold #BB6622",
        String.Regex:              "#BB6688",
        String.Symbol:             "#B8860B",
        String.Other:              "#008000",
        Number:                    "#666666",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#A00000",
        Generic.Inserted:          "#00A000",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #000080",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "border:#FF0000"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.friendly
    ~~~~~~~~~~~~~~~~~~~~~~~~

    A modern style based on the VIM pyte theme.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class FriendlyStyle(Style):
    """
    A modern style based on the VIM pyte theme.
    """

    background_color = "#f0f0f0"
    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",
        Comment:                   "italic #60a0b0",
        Comment.Preproc:           "noitalic #007020",
        Comment.Special:           "noitalic bg:#fff0f0",

        Keyword:                   "bold #007020",
        Keyword.Pseudo:            "nobold",
        Keyword.Type:              "nobold #902000",

        Operator:                  "#666666",
        Operator.Word:             "bold #007020",

        Name.Builtin:              "#007020",
        Name.Function:             "#06287e",
        Name.Class:                "bold #0e84b5",
        Name.Namespace:            "bold #0e84b5",
        Name.Exception:            "#007020",
        Name.Variable:             "#bb60d5",
        Name.Constant:             "#60add5",
        Name.Label:                "bold #002070",
        Name.Entity:               "bold #d55537",
        Name.Attribute:            "#4070a0",
        Name.Tag:                  "bold #062873",
        Name.Decorator:            "bold #555555",

        String:                    "#4070a0",
        String.Doc:                "italic",
        String.Interpol:           "italic #70a0d0",
        String.Escape:             "bold #4070a0",
        String.Regex:              "#235388",
        String.Symbol:             "#517918",
        String.Other:              "#c65d09",
        Number:                    "#40a070",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#A00000",
        Generic.Inserted:          "#00A000",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #c65d09",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "border:#FF0000"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.fruity
    ~~~~~~~~~~~~~~~~~~~~~~

    pygments version of my "fruity" vim theme.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Token, Comment, Name, Keyword, \
    Generic, Number, String, Whitespace

class FruityStyle(Style):
    """
    Pygments version of the "native" vim theme.
    """

    background_color = '#111111'
    highlight_color = '#333333'

    styles = {
        Whitespace:         '#888888',
        Token:              '#ffffff',
        Generic.Output:     '#444444 bg:#222222',
        Keyword:            '#fb660a bold',
        Keyword.Pseudo:     'nobold',
        Number:             '#0086f7 bold',
        Name.Tag:           '#fb660a bold',
        Name.Variable:      '#fb660a',
        Name.Constant:      '#fb660a',
        Comment:            '#008800 bg:#0f140f italic',
        Name.Attribute:     '#ff0086 bold',
        String:             '#0086d2',
        Name.Function:      '#ff0086 bold',
        Generic.Heading:    '#ffffff bold',
        Keyword.Type:       '#cdcaa9 bold',
        Generic.Subheading: '#ffffff bold',
        Name.Constant:      '#0086d2',
        Comment.Preproc:    '#ff0007 bold'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.manni
    ~~~~~~~~~~~~~~~~~~~~~

    A colorful style, inspired by the terminal highlighting style.

    This is a port of the style used in the `php port`_ of pygments
    by Manni. The style is called 'default' there.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class ManniStyle(Style):
    """
    A colorful style, inspired by the terminal highlighting style.
    """

    background_color = '#f0f3f3'

    styles = {
        Whitespace:         '#bbbbbb',
        Comment:            'italic #0099FF',
        Comment.Preproc:    'noitalic #009999',
        Comment.Special:    'bold',

        Keyword:            'bold #006699',
        Keyword.Pseudo:     'nobold',
        Keyword.Type:       '#007788',

        Operator:           '#555555',
        Operator.Word:      'bold #000000',

        Name.Builtin:       '#336666',
        Name.Function:      '#CC00FF',
        Name.Class:         'bold #00AA88',
        Name.Namespace:     'bold #00CCFF',
        Name.Exception:     'bold #CC0000',
        Name.Variable:      '#003333',
        Name.Constant:      '#336600',
        Name.Label:         '#9999FF',
        Name.Entity:        'bold #999999',
        Name.Attribute:     '#330099',
        Name.Tag:           'bold #330099',
        Name.Decorator:     '#9999FF',

        String:             '#CC3300',
        String.Doc:         'italic',
        String.Interpol:    '#AA0000',
        String.Escape:      'bold #CC3300',
        String.Regex:       '#33AAAA',
        String.Symbol:      '#FFCC33',
        String.Other:       '#CC3300',

        Number:             '#FF6600',

        Generic.Heading:    'bold #003300',
        Generic.Subheading: 'bold #003300',
        Generic.Deleted:    'border:#CC0000 bg:#FFCCCC',
        Generic.Inserted:   'border:#00CC00 bg:#CCFFCC',
        Generic.Error:      '#FF0000',
        Generic.Emph:       'italic',
        Generic.Strong:     'bold',
        Generic.Prompt:     'bold #000099',
        Generic.Output:     '#AAAAAA',
        Generic.Traceback:  '#99CC66',

        Error:              'bg:#FFAAAA #AA0000'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.murphy
    ~~~~~~~~~~~~~~~~~~~~~~

    Murphy's style from CodeRay.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class MurphyStyle(Style):
    """
    Murphy's style from CodeRay.
    """

    default_style = ""

    styles = {
        Whitespace:                "#bbbbbb",
        Comment:                   "#666 italic",
        Comment.Preproc:           "#579 noitalic",
        Comment.Special:           "#c00 bold",

        Keyword:                   "bold #289",
        Keyword.Pseudo:            "#08f",
        Keyword.Type:              "#66f",

        Operator:                  "#333",
        Operator.Word:             "bold #000",

        Name.Builtin:              "#072",
        Name.Function:             "bold #5ed",
        Name.Class:                "bold #e9e",
        Name.Namespace:            "bold #0e84b5",
        Name.Exception:            "bold #F00",
        Name.Variable:             "#036",
        Name.Variable.Instance:    "#aaf",
        Name.Variable.Class:       "#ccf",
        Name.Variable.Global:      "#f84",
        Name.Constant:             "bold #5ed",
        Name.Label:                "bold #970",
        Name.Entity:               "#800",
        Name.Attribute:            "#007",
        Name.Tag:                  "#070",
        Name.Decorator:            "bold #555",

        String:                    "bg:#e0e0ff",
        String.Char:               "#88F bg:",
        String.Doc:                "#D42 bg:",
        String.Interpol:           "bg:#eee",
        String.Escape:             "bold #666",
        String.Regex:              "bg:#e0e0ff #000",
        String.Symbol:             "#fc8 bg:",
        String.Other:              "#f88",

        Number:                    "bold #60E",
        Number.Integer:            "bold #66f",
        Number.Float:              "bold #60E",
        Number.Hex:                "bold #058",
        Number.Oct:                "bold #40E",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#A00000",
        Generic.Inserted:          "#00A000",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #c65d09",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "#F00 bg:#FAA"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.native
    ~~~~~~~~~~~~~~~~~~~~~~

    pygments version of my "native" vim theme.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Token, Whitespace


class NativeStyle(Style):
    """
    Pygments version of the "native" vim theme.
    """

    background_color = '#202020'
    highlight_color = '#404040'

    styles = {
        Token:              '#d0d0d0',
        Whitespace:         '#666666',

        Comment:            'italic #999999',
        Comment.Preproc:    'noitalic bold #cd2828',
        Comment.Special:    'noitalic bold #e50808 bg:#520000',

        Keyword:            'bold #6ab825',
        Keyword.Pseudo:     'nobold',
        Operator.Word:      'bold #6ab825',

        String:             '#ed9d13',
        String.Other:       '#ffa500',

        Number:             '#3677a9',

        Name.Builtin:       '#24909d',
        Name.Variable:      '#40ffff',
        Name.Constant:      '#40ffff',
        Name.Class:         'underline #447fcf',
        Name.Function:      '#447fcf',
        Name.Namespace:     'underline #447fcf',
        Name.Exception:     '#bbbbbb',
        Name.Tag:           'bold #6ab825',
        Name.Attribute:     '#bbbbbb',
        Name.Decorator:     '#ffa500',

        Generic.Heading:    'bold #ffffff',
        Generic.Subheading: 'underline #ffffff',
        Generic.Deleted:    '#d22323',
        Generic.Inserted:   '#589819',
        Generic.Error:      '#d22323',
        Generic.Emph:       'italic',
        Generic.Strong:     'bold',
        Generic.Prompt:     '#aaaaaa',
        Generic.Output:     '#cccccc',
        Generic.Traceback:  '#d22323',

        Error:              'bg:#e3d2d2 #a61717'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.pastie
    ~~~~~~~~~~~~~~~~~~~~~~

    Style similar to the `pastie`_ default style.

    .. _pastie: http://pastie.caboo.se/

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class PastieStyle(Style):
    """
    Style similar to the pastie default style.
    """

    default_style = ''

    styles = {
        Whitespace:             '#bbbbbb',
        Comment:                '#888888',
        Comment.Preproc:        'bold #cc0000',
        Comment.Special:        'bg:#fff0f0 bold #cc0000',

        String:                 'bg:#fff0f0 #dd2200',
        String.Regex:           'bg:#fff0ff #008800',
        String.Other:           'bg:#f0fff0 #22bb22',
        String.Symbol:          '#aa6600',
        String.Interpol:        '#3333bb',
        String.Escape:          '#0044dd',

        Operator.Word:          '#008800',

        Keyword:                'bold #008800',
        Keyword.Pseudo:         'nobold',
        Keyword.Type:           '#888888',

        Name.Class:             'bold #bb0066',
        Name.Exception:         'bold #bb0066',
        Name.Function:          'bold #0066bb',
        Name.Property:          'bold #336699',
        Name.Namespace:         'bold #bb0066',
        Name.Builtin:           '#003388',
        Name.Variable:          '#336699',
        Name.Variable.Class:    '#336699',
        Name.Variable.Instance: '#3333bb',
        Name.Variable.Global:   '#dd7700',
        Name.Constant:          'bold #003366',
        Name.Tag:               'bold #bb0066',
        Name.Attribute:         '#336699',
        Name.Decorator:         '#555555',
        Name.Label:             'italic #336699',

        Number:                 'bold #0000DD',

        Generic.Heading:        '#333',
        Generic.Subheading:     '#666',
        Generic.Deleted:        'bg:#ffdddd #000000',
        Generic.Inserted:       'bg:#ddffdd #000000',
        Generic.Error:          '#aa0000',
        Generic.Emph:           'italic',
        Generic.Strong:         'bold',
        Generic.Prompt:         '#555555',
        Generic.Output:         '#888888',
        Generic.Traceback:      '#aa0000',

        Error:                  'bg:#e3d2d2 #a61717'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.perldoc
    ~~~~~~~~~~~~~~~~~~~~~~~

    Style similar to the style used in the `perldoc`_ code blocks.

    .. _perldoc: http://perldoc.perl.org/

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class PerldocStyle(Style):
    """
    Style similar to the style used in the perldoc code blocks.
    """

    background_color = '#eeeedd'
    default_style = ''

    styles = {
        Whitespace:             '#bbbbbb',
        Comment:                '#228B22',
        Comment.Preproc:        '#1e889b',
        Comment.Special:        '#8B008B bold',

        String:                 '#CD5555',
        String.Heredoc:         '#1c7e71 italic',
        String.Regex:           '#B452CD',
        String.Other:           '#cb6c20',
        String.Regex:           '#1c7e71',

        Number:                 '#B452CD',

        Operator.Word:          '#8B008B',

        Keyword:                '#8B008B bold',
        Keyword.Type:           '#a7a7a7',

        Name.Class:             '#008b45 bold',
        Name.Exception:         '#008b45 bold',
        Name.Function:          '#008b45',
        Name.Namespace:         '#008b45 underline',
        Name.Variable:          '#00688B',
        Name.Constant:          '#00688B',
        Name.Decorator:         '#707a7c',
        Name.Tag:               '#8B008B bold',
        Name.Attribute:         '#658b00',
        Name.Builtin:           '#658b00',

        Generic.Heading:        'bold #000080',
        Generic.Subheading:     'bold #800080',
        Generic.Deleted:        '#aa0000',
        Generic.Inserted:       '#00aa00',
        Generic.Error:          '#aa0000',
        Generic.Emph:           'italic',
        Generic.Strong:         'bold',
        Generic.Prompt:         '#555555',
        Generic.Output:         '#888888',
        Generic.Traceback:      '#aa0000',

        Error:                  'bg:#e3d2d2 #a61717'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.tango
    ~~~~~~~~~~~~~~~~~~~~~

    The Crunchy default Style inspired from the color palette from
    the Tango Icon Theme Guidelines.

    http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines

    Butter:     #fce94f     #edd400     #c4a000
    Orange:     #fcaf3e     #f57900     #ce5c00
    Chocolate:  #e9b96e     #c17d11     #8f5902
    Chameleon:  #8ae234     #73d216     #4e9a06
    Sky Blue:   #729fcf     #3465a4     #204a87
    Plum:       #ad7fa8     #75507b     #5c35cc
    Scarlet Red:#ef2929     #cc0000     #a40000
    Aluminium:  #eeeeec     #d3d7cf     #babdb6
                #888a85     #555753     #2e3436

    Not all of the above colors are used; other colors added:
        very light grey: #f8f8f8  (for background)

    This style can be used as a template as it includes all the known
    Token types, unlike most (if not all) of the styles included in the
    Pygments distribution.

    However, since Crunchy is intended to be used by beginners, we have strived
    to create a style that gloss over subtle distinctions between different
    categories.

    Taking Python for example, comments (Comment.*) and docstrings (String.Doc)
    have been chosen to have the same style.  Similarly, keywords (Keyword.*),
    and Operator.Word (and, or, in) have been assigned the same style.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace, Punctuation, Other, Literal


class TangoStyle(Style):
    """
    The Crunchy default Style inspired from the color palette from
    the Tango Icon Theme Guidelines.
    """

    # work in progress...

    background_color = "#f8f8f8"
    default_style = ""

    styles = {
        # No corresponding class for the following:
        #Text:              "", # class:  '',
        Whitespace:                "underline #f8f8f8", # class: 'w',
        Error:                     "#a40000 border:#ef2929", # class: 'err',
        Other:                     "#000000",        # class 'x',

        Comment:                   "italic #8f5902", # class: 'c',
        Comment.Multiline:         "italic #8f5902", # class: 'cm',
        Comment.Preproc:           "italic #8f5902", # class: 'cp',
        Comment.Single:            "italic #8f5902", # class: 'c1',
        Comment.Special:           "italic #8f5902", # class: 'cs',

        Keyword:                   "bold #204a87", # class: 'k',
        Keyword.Constant:          "bold #204a87", # class: 'kc',
        Keyword.Declaration:       "bold #204a87", # class: 'kd',
        Keyword.Namespace:         "bold #204a87", # class: 'kn',
        Keyword.Pseudo:            "bold #204a87", # class: 'kp',
        Keyword.Reserved:          "bold #204a87", # class: 'kr',
        Keyword.Type:              "bold #204a87", # class: 'kt',

        Operator:                  "bold #ce5c00", # class: 'o'
        Operator.Word:             "bold #204a87", # class: 'ow' - like keywords

        Punctuation:               "bold #000000", # class: 'p'

        # because special names such as Name.Class, Name.Function, etc.
        # are not recognized as such later in the parsing, we choose them
        # to look the same as ordinary variables.
        Name:                          "#000000",      # class: 'n'
        Name.Attribute:                "#c4a000",      # class: 'na', - to be revised
        Name.Builtin:                  "#204a87",      # class: 'nb'
        Name.Builtin.Pseudo:           "#3465a4",      # class: 'bp'
        Name.Class:                    "#000000",      # class: 'nc' - to be revised
        Name.Constant:                 "#000000",      # class: 'no', - to be revised
        Name.Decorator:                "bold #5c35cc", # class: 'nd', - to be revised
        Name.Entity:                   "#ce5c00",      # class: 'ni',
        Name.Exception:                "bold #cc0000", # class: 'ne',
        Name.Function:                 "#000000",      # class: 'nf'
        Name.Property:                 "#000000",      # class: 'py',
        Name.Label:                    "#f57900",      # class: 'nl',
        Name.Namespace:                "#000000",      # class: 'nn' - to be revised
        Name.Other:                    "#000000",      # class: 'nx',
        Name.Tag:                      "bold #204a87", # class'nt' -- like a keyword
        Name.Variable:                 "#000000",      # class: 'nv', - to be revised
        Name.Variable.Class:           "#000000",      # class: 'vc', - to be revised
        Name.Variable.Global:          "#000000",      # class: 'vg', - to be revised
        Name.Variable.Instance:        "#000000",      # class: 'vi', - to be revised

        # since the tango light blue does not show up well in text, we choose
        # a pure blue instead.
        Number:                        "bold #0000cf", # class: 'm'
        Number.Float:                  "bold #0000cf", # class: ''mf',
        Number.Hex:                    "bold #0000cf", # class: ''mh',
        Number.Integer:                "bold #0000cf", # class: ''mi',
        Number.Integer.Long:           "bold #0000cf", # class: ''il',
        Number.Oct:                    "bold #0000cf", # class: ''mo',

        Literal:                   "#000000",      # class: 'l',
        Literal.Date:              "#000000",      # class: 'ld',

        String:                    "#4e9a06",      # class: 's',
        String.Backtick:           "#4e9a06",      # class: 'sb',
        String.Char:               "#4e9a06",      # class: 'sc',
        String.Doc:                "italic #8f5902",  # class: 'sd' - like a comment
        String.Double:             "#4e9a06",      # class: 's2',
        String.Escape:             "#4e9a06",      # class: 'se',
        String.Heredoc:            "#4e9a06",      # class: 'sh',
        String.Interpol:           "#4e9a06",      # class: 'si',
        String.Other:              "#4e9a06",      # class: 'sx',
        String.Regex:              "#4e9a06",      # class: 'sr',
        String.Single:             "#4e9a06",      # class: 's1',
        String.Symbol:             "#4e9a06",      # class: 'ss',

        Generic:                   "#000000",      # class: 'g',
        Generic.Deleted:           "#a40000",      # class: 'gd',
        Generic.Emph:              "italic #000000",      # class: 'ge',
        Generic.Error:             "#ef2929",      # class: 'gr',
        Generic.Heading:           "bold #000080",      # class: 'gh',
        Generic.Inserted:          "#00A000",      # class: 'gi',
        Generic.Output:            "italic #000000",      # class: 'go',
        Generic.Prompt:            "#8f5902",      # class: 'gp',
        Generic.Strong:            "bold #000000",      # class: 'gs',
        Generic.Subheading:        "bold #800080",      # class: 'gu',
        Generic.Traceback:         "bold #a40000",      # class: 'gt',
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.trac
    ~~~~~~~~~~~~~~~~~~~~

    Port of the default trac highlighter design.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace


class TracStyle(Style):
    """
    Port of the default trac highlighter design.
    """

    default_style = ''

    styles = {
        Whitespace:             '#bbbbbb',
        Comment:                'italic #999988',
        Comment.Preproc:        'bold noitalic #999999',
        Comment.Special:        'bold #999999',

        Operator:               'bold',

        String:                 '#bb8844',
        String.Regex:           '#808000',

        Number:                 '#009999',

        Keyword:                'bold',
        Keyword.Type:           '#445588',

        Name.Builtin:           '#999999',
        Name.Function:          'bold #990000',
        Name.Class:             'bold #445588',
        Name.Exception:         'bold #990000',
        Name.Namespace:         '#555555',
        Name.Variable:          '#008080',
        Name.Constant:          '#008080',
        Name.Tag:               '#000080',
        Name.Attribute:         '#008080',
        Name.Entity:            '#800080',

        Generic.Heading:        '#999999',
        Generic.Subheading:     '#aaaaaa',
        Generic.Deleted:        'bg:#ffdddd #000000',
        Generic.Inserted:       'bg:#ddffdd #000000',
        Generic.Error:          '#aa0000',
        Generic.Emph:           'italic',
        Generic.Strong:         'bold',
        Generic.Prompt:         '#555555',
        Generic.Output:         '#888888',
        Generic.Traceback:      '#aa0000',

        Error:                  'bg:#e3d2d2 #a61717'
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.vim
    ~~~~~~~~~~~~~~~~~~~

    A highlighting style for Pygments, inspired by vim.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace, Token


class VimStyle(Style):
    """
    Styles somewhat like vim 7.0
    """

    background_color = "#000000"
    highlight_color = "#222222"
    default_style = "#cccccc"

    styles = {
        Token:                     "#cccccc",
        Whitespace:                "",
        Comment:                   "#000080",
        Comment.Preproc:           "",
        Comment.Special:           "bold #cd0000",

        Keyword:                   "#cdcd00",
        Keyword.Declaration:       "#00cd00",
        Keyword.Namespace:         "#cd00cd",
        Keyword.Pseudo:            "",
        Keyword.Type:              "#00cd00",

        Operator:                  "#3399cc",
        Operator.Word:             "#cdcd00",

        Name:                      "",
        Name.Class:                "#00cdcd",
        Name.Builtin:              "#cd00cd",
        Name.Exception:            "bold #666699",
        Name.Variable:             "#00cdcd",

        String:                    "#cd0000",
        Number:                    "#cd00cd",

        Generic.Heading:           "bold #000080",
        Generic.Subheading:        "bold #800080",
        Generic.Deleted:           "#cd0000",
        Generic.Inserted:          "#00cd00",
        Generic.Error:             "#FF0000",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold #000080",
        Generic.Output:            "#888",
        Generic.Traceback:         "#04D",

        Error:                     "border:#FF0000"
    }
# -*- coding: utf-8 -*-
"""
    pygments.styles.vs
    ~~~~~~~~~~~~~~~~~~

    Simple style with MS Visual Studio colors.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Operator, Generic


class VisualStudioStyle(Style):

    background_color = "#ffffff"
    default_style = ""

    styles = {
        Comment:                   "#008000",
        Comment.Preproc:           "#0000ff",
        Keyword:                   "#0000ff",
        Operator.Word:             "#0000ff",
        Keyword.Type:              "#2b91af",
        Name.Class:                "#2b91af",
        String:                    "#a31515",

        Generic.Heading:           "bold",
        Generic.Subheading:        "bold",
        Generic.Emph:              "italic",
        Generic.Strong:            "bold",
        Generic.Prompt:            "bold",

        Error:                     "border:#FF0000"
    }
# -*- coding: utf-8 -*-
"""
    pygments.token
    ~~~~~~~~~~~~~~

    Basic token types and the standard tokens.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
try:
    set
except NameError:
    from sets import Set as set


class _TokenType(tuple):
    parent = None

    def split(self):
        buf = []
        node = self
        while node is not None:
            buf.append(node)
            node = node.parent
        buf.reverse()
        return buf

    def __init__(self, *args):
        # no need to call super.__init__
        self.subtypes = set()

    def __contains__(self, val):
        return self is val or (
            type(val) is self.__class__ and
            val[:len(self)] == self
        )

    def __getattr__(self, val):
        if not val or not val[0].isupper():
            return tuple.__getattribute__(self, val)
        new = _TokenType(self + (val,))
        setattr(self, val, new)
        self.subtypes.add(new)
        new.parent = self
        return new

    def __hash__(self):
        return hash(tuple(self))

    def __repr__(self):
        return 'Token' + (self and '.' or '') + '.'.join(self)


Token       = _TokenType()

# Special token types
Text        = Token.Text
Whitespace  = Text.Whitespace
Error       = Token.Error
# Text that doesn't belong to this lexer (e.g. HTML in PHP)
Other       = Token.Other

# Common token types for source code
Keyword     = Token.Keyword
Name        = Token.Name
Literal     = Token.Literal
String      = Literal.String
Number      = Literal.Number
Punctuation = Token.Punctuation
Operator    = Token.Operator
Comment     = Token.Comment

# Generic types for non-source code
Generic     = Token.Generic

# String and some others are not direct childs of Token.
# alias them:
Token.Token = Token
Token.String = String
Token.Number = Number


def is_token_subtype(ttype, other):
    """
    Return True if ``ttype`` is a subtype of ``other``.

    exists for backwards compatibility. use ``ttype in other`` now.
    """
    return ttype in other


def string_to_tokentype(s):
    """
    Convert a string into a token type::

        >>> string_to_token('String.Double')
        Token.Literal.String.Double
        >>> string_to_token('Token.Literal.Number')
        Token.Literal.Number
        >>> string_to_token('')
        Token

    Tokens that are already tokens are returned unchanged:

        >>> string_to_token(String)
        Token.Literal.String
    """
    if isinstance(s, _TokenType):
        return s
    if not s:
        return Token
    node = Token
    for item in s.split('.'):
        node = getattr(node, item)
    return node


# Map standard token types to short names, used in CSS class naming.
# If you add a new item, please be sure to run this file to perform
# a consistency check for duplicate values.
STANDARD_TYPES = {
    Token:                         '',

    Text:                          '',
    Whitespace:                    'w',
    Error:                         'err',
    Other:                         'x',

    Keyword:                       'k',
    Keyword.Constant:              'kc',
    Keyword.Declaration:           'kd',
    Keyword.Namespace:             'kn',
    Keyword.Pseudo:                'kp',
    Keyword.Reserved:              'kr',
    Keyword.Type:                  'kt',

    Name:                          'n',
    Name.Attribute:                'na',
    Name.Builtin:                  'nb',
    Name.Builtin.Pseudo:           'bp',
    Name.Class:                    'nc',
    Name.Constant:                 'no',
    Name.Decorator:                'nd',
    Name.Entity:                   'ni',
    Name.Exception:                'ne',
    Name.Function:                 'nf',
    Name.Property:                 'py',
    Name.Label:                    'nl',
    Name.Namespace:                'nn',
    Name.Other:                    'nx',
    Name.Tag:                      'nt',
    Name.Variable:                 'nv',
    Name.Variable.Class:           'vc',
    Name.Variable.Global:          'vg',
    Name.Variable.Instance:        'vi',

    Literal:                       'l',
    Literal.Date:                  'ld',

    String:                        's',
    String.Backtick:               'sb',
    String.Char:                   'sc',
    String.Doc:                    'sd',
    String.Double:                 's2',
    String.Escape:                 'se',
    String.Heredoc:                'sh',
    String.Interpol:               'si',
    String.Other:                  'sx',
    String.Regex:                  'sr',
    String.Single:                 's1',
    String.Symbol:                 'ss',

    Number:                        'm',
    Number.Float:                  'mf',
    Number.Hex:                    'mh',
    Number.Integer:                'mi',
    Number.Integer.Long:           'il',
    Number.Oct:                    'mo',

    Operator:                      'o',
    Operator.Word:                 'ow',

    Punctuation:                   'p',

    Comment:                       'c',
    Comment.Multiline:             'cm',
    Comment.Preproc:               'cp',
    Comment.Single:                'c1',
    Comment.Special:               'cs',

    Generic:                       'g',
    Generic.Deleted:               'gd',
    Generic.Emph:                  'ge',
    Generic.Error:                 'gr',
    Generic.Heading:               'gh',
    Generic.Inserted:              'gi',
    Generic.Output:                'go',
    Generic.Prompt:                'gp',
    Generic.Strong:                'gs',
    Generic.Subheading:            'gu',
    Generic.Traceback:             'gt',
}
# -*- coding: utf-8 -*-
"""
    pygments.util
    ~~~~~~~~~~~~~

    Utility functions.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""
import re
import sys


split_path_re = re.compile(r'[/\\ ]')
doctype_lookup_re = re.compile(r'''(?smx)
    (<\?.*?\?>)?\s*
    <!DOCTYPE\s+(
     [a-zA-Z_][a-zA-Z0-9]*\s+
     [a-zA-Z_][a-zA-Z0-9]*\s+
     "[^"]*")
     [^>]*>
''')
tag_re = re.compile(r'<(.+?)(\s.*?)?>.*?</.+?>(?uism)')


class ClassNotFound(ValueError):
    """
    If one of the get_*_by_* functions didn't find a matching class.
    """


class OptionError(Exception):
    pass


def get_choice_opt(options, optname, allowed, default=None, normcase=False):
    string = options.get(optname, default)
    if normcase:
        string = string.lower()
    if string not in allowed:
        raise OptionError('Value for option %s must be one of %s' %
                          (optname, ', '.join(map(str, allowed))))
    return string


def get_bool_opt(options, optname, default=None):
    string = options.get(optname, default)
    if isinstance(string, bool):
        return string
    elif isinstance(string, int):
        return bool(string)
    elif not isinstance(string, basestring):
        raise OptionError('Invalid type %r for option %s; use '
                          '1/0, yes/no, true/false, on/off' % (
                          string, optname))
    elif string.lower() in ('1', 'yes', 'true', 'on'):
        return True
    elif string.lower() in ('0', 'no', 'false', 'off'):
        return False
    else:
        raise OptionError('Invalid value %r for option %s; use '
                          '1/0, yes/no, true/false, on/off' % (
                          string, optname))


def get_int_opt(options, optname, default=None):
    string = options.get(optname, default)
    try:
        return int(string)
    except TypeError:
        raise OptionError('Invalid type %r for option %s; you '
                          'must give an integer value' % (
                          string, optname))
    except ValueError:
        raise OptionError('Invalid value %r for option %s; you '
                          'must give an integer value' % (
                          string, optname))


def get_list_opt(options, optname, default=None):
    val = options.get(optname, default)
    if isinstance(val, basestring):
        return val.split()
    elif isinstance(val, (list, tuple)):
        return list(val)
    else:
        raise OptionError('Invalid type %r for option %s; you '
                          'must give a list value' % (
                          val, optname))


def docstring_headline(obj):
    if not obj.__doc__:
        return ''
    res = []
    for line in obj.__doc__.strip().splitlines():
        if line.strip():
            res.append(" " + line.strip())
        else:
            break
    return ''.join(res).lstrip()


def make_analysator(f):
    """
    Return a static text analysation function that
    returns float values.
    """
    def text_analyse(text):
        rv = f(text)
        if not rv:
            return 0.0
        return min(1.0, max(0.0, float(rv)))
    text_analyse.__doc__ = f.__doc__
    return staticmethod(text_analyse)


def shebang_matches(text, regex):
    """
    Check if the given regular expression matches the last part of the
    shebang if one exists.

        >>> from pygments.util import shebang_matches
        >>> shebang_matches('#!/usr/bin/env python', r'python(2\.\d)?')
        True
        >>> shebang_matches('#!/usr/bin/python2.4', r'python(2\.\d)?')
        True
        >>> shebang_matches('#!/usr/bin/python-ruby', r'python(2\.\d)?')
        False
        >>> shebang_matches('#!/usr/bin/python/ruby', r'python(2\.\d)?')
        False
        >>> shebang_matches('#!/usr/bin/startsomethingwith python',
        ...                 r'python(2\.\d)?')
        True

    It also checks for common windows executable file extensions::

        >>> shebang_matches('#!C:\\Python2.4\\Python.exe', r'python(2\.\d)?')
        True

    Parameters (``'-f'`` or ``'--foo'`` are ignored so ``'perl'`` does
    the same as ``'perl -e'``)

    Note that this method automatically searches the whole string (eg:
    the regular expression is wrapped in ``'^$'``)
    """
    index = text.find('\n')
    if index >= 0:
        first_line = text[:index].lower()
    else:
        first_line = text.lower()
    if first_line.startswith('#!'):
        try:
            found = [x for x in split_path_re.split(first_line[2:].strip())
                     if x and not x.startswith('-')][-1]
        except IndexError:
            return False
        regex = re.compile('^%s(\.(exe|cmd|bat|bin))?$' % regex, re.IGNORECASE)
        if regex.search(found) is not None:
            return True
    return False


def doctype_matches(text, regex):
    """
    Check if the doctype matches a regular expression (if present).
    Note that this method only checks the first part of a DOCTYPE.
    eg: 'html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"'
    """
    m = doctype_lookup_re.match(text)
    if m is None:
        return False
    doctype = m.group(2)
    return re.compile(regex).match(doctype.strip()) is not None


def html_doctype_matches(text):
    """
    Check if the file looks like it has a html doctype.
    """
    return doctype_matches(text, r'html\s+PUBLIC\s+"-//W3C//DTD X?HTML.*')


_looks_like_xml_cache = {}
def looks_like_xml(text):
    """
    Check if a doctype exists or if we have some tags.
    """
    key = hash(text)
    try:
        return _looks_like_xml_cache[key]
    except KeyError:
        m = doctype_lookup_re.match(text)
        if m is not None:
            return True
        rv = tag_re.search(text[:1000]) is not None
        _looks_like_xml_cache[key] = rv
        return rv

# Python 2/3 compatibility

if sys.version_info < (3,0):
    b = bytes = str
    u_prefix = 'u'
    import StringIO, cStringIO
    BytesIO = cStringIO.StringIO
    StringIO = StringIO.StringIO
else:
    import builtins
    bytes = builtins.bytes
    u_prefix = ''
    def b(s):
        if isinstance(s, str):
            return bytes(map(ord, s))
        elif isinstance(s, bytes):
            return s
        else:
            raise TypeError("Invalid argument %r for b()" % (s,))
    import io
    BytesIO = io.BytesIO
    StringIO = io.StringIO
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Checker for file headers
    ~~~~~~~~~~~~~~~~~~~~~~~~

    Make sure each Python file has a correct file header
    including copyright and license information.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import sys, os, re
import getopt
import cStringIO
from os.path import join, splitext, abspath


checkers = {}

def checker(*suffixes, **kwds):
    only_pkg = kwds.pop('only_pkg', False)
    def deco(func):
        for suffix in suffixes:
            checkers.setdefault(suffix, []).append(func)
        func.only_pkg = only_pkg
        return func
    return deco


name_mail_re = r'[\w ]+(<.*?>)?'
copyright_re = re.compile(r'^    :copyright: Copyright 2006-2009 by the Pygments team, '
                          r'see AUTHORS\.$', re.UNICODE)
copyright_2_re = re.compile(r'^                %s(, %s)*[,.]$' %
                            (name_mail_re, name_mail_re), re.UNICODE)
coding_re    = re.compile(r'coding[:=]\s*([-\w.]+)')
not_ix_re    = re.compile(r'\bnot\s+\S+?\s+i[sn]\s\S+')
is_const_re  = re.compile(r'if.*?==\s+(None|False|True)\b')

misspellings = ["developement", "adress", "verificate",  # ALLOW-MISSPELLING
                "informations"]                          # ALLOW-MISSPELLING


@checker('.py')
def check_syntax(fn, lines):
    try:
        compile(''.join(lines), fn, "exec")
    except SyntaxError, err:
        yield 0, "not compilable: %s" % err


@checker('.py')
def check_style_and_encoding(fn, lines):
    encoding = 'ascii'
    for lno, line in enumerate(lines):
        if len(line) > 90:
            yield lno+1, "line too long"
        m = not_ix_re.search(line)
        if m:
            yield lno+1, '"' + m.group() + '"'
        if is_const_re.search(line):
            yield lno+1, 'using == None/True/False'
        if lno < 2:
            co = coding_re.search(line)
            if co:
                encoding = co.group(1)
        try:
            line.decode(encoding)
        except UnicodeDecodeError, err:
            yield lno+1, "not decodable: %s\n   Line: %r" % (err, line)
        except LookupError, err:
            yield 0, "unknown encoding: %s" % encoding
            encoding = 'latin1'


@checker('.py', only_pkg=True)
def check_fileheader(fn, lines):
    # line number correction
    c = 1
    if lines[0:1] == ['#!/usr/bin/env python\n']:
        lines = lines[1:]
        c = 2

    llist = []
    docopen = False
    for lno, l in enumerate(lines):
        llist.append(l)
        if lno == 0:
            if l == '# -*- coding: rot13 -*-\n':
                # special-case pony package
                return
            elif l != '# -*- coding: utf-8 -*-\n':
                yield 1, "missing coding declaration"
        elif lno == 1:
            if l != '"""\n' and l != 'r"""\n':
                yield 2, 'missing docstring begin (""")'
            else:
                docopen = True
        elif docopen:
            if l == '"""\n':
                # end of docstring
                if lno <= 4:
                    yield lno+c, "missing module name in docstring"
                break

            if l != "\n" and l[:4] != '    ' and docopen:
                yield lno+c, "missing correct docstring indentation"

            if lno == 2:
                # if not in package, don't check the module name
                modname = fn[:-3].replace('/', '.').replace('.__init__', '')
                while modname:
                    if l.lower()[4:-1] == modname:
                        break
                    modname = '.'.join(modname.split('.')[1:])
                else:
                    yield 3, "wrong module name in docstring heading"
                modnamelen = len(l.strip())
            elif lno == 3:
                if l.strip() != modnamelen * "~":
                    yield 4, "wrong module name underline, should be ~~~...~"

    else:
        yield 0, "missing end and/or start of docstring..."

    # check for copyright and license fields
    license = llist[-2:-1]
    if license != ["    :license: BSD, see LICENSE for details.\n"]:
        yield 0, "no correct license info"

    ci = -3
    copyright = [s.decode('utf-8') for s in llist[ci:ci+1]]
    while copyright and copyright_2_re.match(copyright[0]):
        ci -= 1
        copyright = llist[ci:ci+1]
    if not copyright or not copyright_re.match(copyright[0]):
        yield 0, "no correct copyright info"


@checker('.py', '.html', '.js')
def check_whitespace_and_spelling(fn, lines):
    for lno, line in enumerate(lines):
        if "\t" in line:
            yield lno+1, "OMG TABS!!!1 "
        if line[:-1].rstrip(' \t') != line[:-1]:
            yield lno+1, "trailing whitespace"
        for word in misspellings:
            if word in line and 'ALLOW-MISSPELLING' not in line:
                yield lno+1, '"%s" used' % word


bad_tags = ('<b>', '<i>', '<u>', '<s>', '<strike>'
            '<center>', '<big>', '<small>', '<font')

@checker('.html')
def check_xhtml(fn, lines):
    for lno, line in enumerate(lines):
        for bad_tag in bad_tags:
            if bad_tag in line:
                yield lno+1, "used " + bad_tag


def main(argv):
    try:
        gopts, args = getopt.getopt(argv[1:], "vi:")
    except getopt.GetoptError:
        print "Usage: %s [-v] [-i ignorepath]* [path]" % argv[0]
        return 2
    opts = {}
    for opt, val in gopts:
        if opt == '-i':
            val = abspath(val)
        opts.setdefault(opt, []).append(val)

    if len(args) == 0:
        path = '.'
    elif len(args) == 1:
        path = args[0]
    else:
        print "Usage: %s [-v] [-i ignorepath]* [path]" % argv[0]
        return 2

    verbose = '-v' in opts

    num = 0
    out = cStringIO.StringIO()

    # TODO: replace os.walk run with iteration over output of
    #       `svn list -R`.

    for root, dirs, files in os.walk(path):
        if '.svn' in dirs:
            dirs.remove('.svn')
        if '-i' in opts and abspath(root) in opts['-i']:
            del dirs[:]
            continue
        # XXX: awkward: for the Makefile call: don't check non-package
        #      files for file headers
        in_pocoo_pkg = root.startswith('./pygments')
        for fn in files:

            fn = join(root, fn)
            if fn[:2] == './': fn = fn[2:]

            if '-i' in opts and abspath(fn) in opts['-i']:
                continue

            ext = splitext(fn)[1]
            checkerlist = checkers.get(ext, None)
            if not checkerlist:
                continue

            if verbose:
                print "Checking %s..." % fn

            try:
                f = open(fn, 'r')
                lines = list(f)
            except (IOError, OSError), err:
                print "%s: cannot open: %s" % (fn, err)
                num += 1
                continue

            for checker in checkerlist:
                if not in_pocoo_pkg and checker.only_pkg:
                    continue
                for lno, msg in checker(fn, lines):
                    print >>out, "%s:%d: %s" % (fn, lno, msg)
                    num += 1
    if verbose:
        print
    if num == 0:
        print "No errors found."
    else:
        print out.getvalue().rstrip('\n')
        print "%d error%s found." % (num, num > 1 and "s" or "")
    return int(num > 0)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
import sys

from pygments.lexers import get_all_lexers, find_lexer_class
from pygments.lexer import Lexer

def main():
    uses = {}

    for name, aliases, filenames, mimetypes in get_all_lexers():
        cls = find_lexer_class(name)
        for f in filenames:
            if f not in uses:
                uses[f] = []
            uses[f].append(cls)

    ret = 0
    for k, v in uses.iteritems():
        if len(v) > 1:
            #print "Multiple for", k, v
            for i in v:
                if i.analyse_text is None:
                    print i, "has a None analyse_text"
                    ret |= 1
                elif Lexer.analyse_text.__doc__ == i.analyse_text.__doc__:
                    print i, "needs analyse_text, multiple lexers for", k
                    ret |= 2
    return ret

if __name__ == '__main__':
    sys.exit(main())
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Codetags finder
    ~~~~~~~~~~~~~~~

    Find code tags in specified files and/or directories
    and create a report in HTML format.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import sys, os, re
import getopt
from os.path import join, abspath, isdir, isfile


TAGS = set(('XXX', 'TODO', 'FIXME', 'HACK'))

tag_re = re.compile(
    r'(?P<tag>\b' + r'\b|\b'.join(TAGS) + r'\b)\s*'
    r'(?: \( (?P<who> .*? ) \) )?'
    r'\s*:?\s* (?P<what> .*? ) \s* $',
    re.X)

binary_re = re.compile('[\x00-\x06\x0E-\x1F]')


def escape_html(text):
    return text.replace('&', '&amp;'). \
                replace('<', '&lt;').  \
                replace('>', '&gt;').  \
                replace('"', '&quot;')

def process_file(store, filename):
    try:
        f = open(filename, 'r')
    except (IOError, OSError):
        return False
    llmatch = 0
    try:
        for lno, line in enumerate(f):
            # just some random heuristics to filter out binary files
            if lno < 100 and binary_re.search(line):
                return False
            m = tag_re.search(line)
            if m:
                store.setdefault(filename, []).append({
                    'lno':  lno+1,
                    'tag':  m.group('tag'),
                    'who':  m.group('who') or '',
                    'what': escape_html(m.group('what')),
                })
                # 'what' cannot start at column 0
                llmatch = m.start('what')
            elif llmatch:
                # continuation lines
                # XXX: this is Python centric, doesn't work for
                #      JavaScript, for example.
                if line[:llmatch].replace('#', '').isspace():
                    cont = line[llmatch:].strip()
                    if cont:
                        store[filename][-1]['what'] += ' ' + escape_html(cont)
                        continue
                llmatch = 0
        return True
    finally:
        f.close()


def main():
    try:
        gopts, args = getopt.getopt(sys.argv[1:], "vo:i:")
    except getopt.GetoptError:
        print ("Usage: %s [-v] [-i ignoredir]* [-o reportfile.html] "
               "path ..." % sys.argv[0])
        return 2
    opts = {}
    for opt, val in gopts:
        if opt == '-i':
            val = abspath(val)
        opts.setdefault(opt, []).append(val)

    if not args:
        args = ['.']

    if '-o' in opts:
        output = abspath(opts['-o'][-1])
    else:
        output = abspath('tags.html')

    verbose = '-v' in opts

    store = {}
    gnum = 0
    num = 0

    for path in args:
        print "Searching for code tags in %s, please wait." % path

        if isfile(path):
            gnum += 1
            if process_file(store, path):
                if verbose:
                    print path + ": found %d tags" % \
                        (path in store and len(store[path]) or 0)
                num += 1
            else:
                if verbose:
                    print path + ": binary or not readable"
            continue
        elif not isdir(path):
            continue

        for root, dirs, files in os.walk(path):
            if '-i' in opts and abspath(root) in opts['-i']:
                del dirs[:]
                continue
            if '.svn' in dirs:
                dirs.remove('.svn')
            for fn in files:
                gnum += 1
                if gnum % 50 == 0 and not verbose:
                    sys.stdout.write('.')
                    sys.stdout.flush()

                fn = join(root, fn)

                if fn.endswith('.pyc') or fn.endswith('.pyo'):
                    continue
                elif '-i' in opts and abspath(fn) in opts['-i']:
                    continue
                elif abspath(fn) == output:
                    continue

                if fn[:2] == './': fn = fn[2:]
                if process_file(store, fn):
                    if verbose:
                        print fn + ": found %d tags" % \
                            (fn in store and len(store[fn]) or 0)
                    num += 1
                else:
                    if verbose:
                        print fn + ": binary or not readable"
        print

    print "Processed %d of %d files. Found %d tags in %d files." % (
        num, gnum, sum(len(fitem) for fitem in store.itervalues()), len(store))

    if not store:
        return 0

    HTML = '''\
<html>
<head>
<title>Code tags report</title>
<style type="text/css">
body { font-family: Trebuchet MS,Verdana,sans-serif;
       width: 80%%; margin-left: auto; margin-right: auto; }
table { width: 100%%; border-spacing: 0;
        border: 1px solid #CCC; }
th { font-weight: bold; background-color: #DDD }
td { padding: 2px 5px 2px 5px;
     vertical-align: top; }
.tr0 { background-color: #EEEEEE; }
.tr1 { background-color: #F6F6F6; }
.tag { text-align: center; font-weight: bold; }
.tr0 .tag { background-color: #FFEEEE; }
.tr1 .tag { background-color: #FFDDDD; }
.head { padding-top: 10px; font-size: 100%%; font-weight: bold }
.XXX { color: #500; }
.FIXME { color: red; }
.TODO { color: #880; }
</style>
</head>
<body>
<h1>Code tags report for %s</h1>
<table>
<tr><th>Line</th><th>Tag</th><th>Who</th><th>Description</th></tr>
%s
</table>
</body>
</html>
'''

    TABLE = '\n<tr><td class="head" colspan="4">File: %s</td>\n'

    TR = ('<tr class="tr%d"><td class="lno">%%(lno)d</td>'
          '<td class="tag %%(tag)s">%%(tag)s</td>'
          '<td class="who">%%(who)s</td><td class="what">%%(what)s</td></tr>')

    f = file(output, 'w')
    table = '\n'.join(TABLE % fname +
                      '\n'.join(TR % (no % 2,) % entry
                                for no, entry in enumerate(store[fname]))
                      for fname in sorted(store))
    f.write(HTML % (', '.join(map(abspath, args)), table))
    f.close()

    print "Report written to %s." % output
    return 0

if __name__ == '__main__':
    sys.exit(main())
#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    Lexing error finder
    ~~~~~~~~~~~~~~~~~~~

    For the source files given on the command line, display
    the text where Error tokens are being generated, along
    with some context.

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import sys, os

try:
    import pygments
except ImportError:
    # try parent path
    sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from pygments import highlight
from pygments.lexers import get_lexer_for_filename, get_lexer_by_name
from pygments.token import Error

def main(fn):
    try:
        lx = get_lexer_for_filename(fn)
    except ValueError:
        try:
            name, rest = fn.split("_", 1)
            lx = get_lexer_by_name(name)
        except ValueError:
            raise AssertionError('no lexer found for file %r' % fn)
    text = file(fn, 'U').read()
    text = text.strip('\n') + '\n'
    text = text.decode('latin1')
    ntext = []
    for type, val in lx.get_tokens(text):
        if type == Error:
            print "Error parsing", fn
            print "\n".join(['   ' + repr(x) for x in ntext[-num:]])
            print `val` + "<<<"
            return 1
        ntext.append((type,val))
    return 0


num = 10

if __name__ == "__main__":
    if sys.argv[1][:2] == '-n':
        num = int(sys.argv[1][2:])
        del sys.argv[1]
    ret = 0
    for f in sys.argv[1:]:
        ret += main(f)
    sys.exit(bool(ret))
import re
from pprint import pprint

r_line = re.compile(r"^(syn keyword vimCommand contained|syn keyword vimOption "
                    r"contained|syn keyword vimAutoEvent contained)\s+(.*)")
r_item = re.compile(r"(\w+)(?:\[(\w+)\])?")

def getkw(input, output):
    out = file(output, 'w')

    output_info = {'command': [], 'option': [], 'auto': []}
    for line in file(input):
        m = r_line.match(line)
        if m:
            # Decide which output gets mapped to d
            if 'vimCommand' in m.group(1):
                d = output_info['command']
            elif 'AutoEvent' in m.group(1):
                d = output_info['auto']
            else:
                d = output_info['option']

            # Extract all the shortened versions
            for i in r_item.finditer(m.group(2)):
                d.append((i.group(1), "%s%s" % (i.group(1), i.group(2) or '')))
            d.sort()

    for a, b in output_info.items():
        print >>out, '%s=%r' % (a, b)

def is_keyword(w, keywords):
    for i in range(len(w), 0, -1):
        if w[:i] in keywords:
            return signals[w[:i]][:len(w)] == w
    return False

if __name__ == "__main__":
    getkw("/usr/share/vim/vim70/syntax/vim.vim", "temp.py")
#! /usr/bin/env python

# Released to the public domain, by Tim Peters, 03 October 2000.
# -B option added by Georg Brandl, 2006.

"""reindent [-d][-r][-v] [ path ... ]

-d (--dryrun)  Dry run.  Analyze, but don't make any changes to files.
-r (--recurse) Recurse.  Search for all .py files in subdirectories too.
-B (--no-backup)         Don't write .bak backup files.
-v (--verbose) Verbose.  Print informative msgs; else only names of changed files.
-h (--help)    Help.     Print this usage information and exit.

Change Python (.py) files to use 4-space indents and no hard tab characters.
Also trim excess spaces and tabs from ends of lines, and remove empty lines
at the end of files.  Also ensure the last line ends with a newline.

If no paths are given on the command line, reindent operates as a filter,
reading a single source file from standard input and writing the transformed
source to standard output.  In this case, the -d, -r and -v flags are
ignored.

You can pass one or more file and/or directory paths.  When a directory
path, all .py files within the directory will be examined, and, if the -r
option is given, likewise recursively for subdirectories.

If output is not to standard output, reindent overwrites files in place,
renaming the originals with a .bak extension.  If it finds nothing to
change, the file is left alone.  If reindent does change a file, the changed
file is a fixed-point for future runs (i.e., running reindent on the
resulting .py file won't change it again).

The hard part of reindenting is figuring out what to do with comment
lines.  So long as the input files get a clean bill of health from
tabnanny.py, reindent should do a good job.
"""

__version__ = "1"

import tokenize
import os
import sys

verbose = 0
recurse = 0
dryrun  = 0
no_backup = 0

def usage(msg=None):
    if msg is not None:
        print >> sys.stderr, msg
    print >> sys.stderr, __doc__

def errprint(*args):
    sep = ""
    for arg in args:
        sys.stderr.write(sep + str(arg))
        sep = " "
    sys.stderr.write("\n")

def main():
    import getopt
    global verbose, recurse, dryrun, no_backup

    try:
        opts, args = getopt.getopt(sys.argv[1:], "drvhB",
                                   ["dryrun", "recurse", "verbose", "help",
                                    "no-backup"])
    except getopt.error, msg:
        usage(msg)
        return
    for o, a in opts:
        if o in ('-d', '--dryrun'):
            dryrun += 1
        elif o in ('-r', '--recurse'):
            recurse += 1
        elif o in ('-v', '--verbose'):
            verbose += 1
        elif o in ('-B', '--no-backup'):
            no_backup += 1
        elif o in ('-h', '--help'):
            usage()
            return
    if not args:
        r = Reindenter(sys.stdin)
        r.run()
        r.write(sys.stdout)
        return
    for arg in args:
        check(arg)

def check(file):
    if os.path.isdir(file) and not os.path.islink(file):
        if verbose:
            print "listing directory", file
        names = os.listdir(file)
        for name in names:
            fullname = os.path.join(file, name)
            if ((recurse and os.path.isdir(fullname) and
                 not os.path.islink(fullname))
                or name.lower().endswith(".py")):
                check(fullname)
        return

    if verbose:
        print "checking", file, "...",
    try:
        f = open(file)
    except IOError, msg:
        errprint("%s: I/O Error: %s" % (file, str(msg)))
        return

    r = Reindenter(f)
    f.close()
    if r.run():
        if verbose:
            print "changed."
            if dryrun:
                print "But this is a dry run, so leaving it alone."
        else:
            print "reindented", file, (dryrun and "(dry run => not really)" or "")
        if not dryrun:
            if not no_backup:
                bak = file + ".bak"
                if os.path.exists(bak):
                    os.remove(bak)
                os.rename(file, bak)
                if verbose:
                    print "renamed", file, "to", bak
            f = open(file, "w")
            r.write(f)
            f.close()
            if verbose:
                print "wrote new", file
    else:
        if verbose:
            print "unchanged."


class Reindenter:

    def __init__(self, f):
        self.find_stmt = 1  # next token begins a fresh stmt?
        self.level = 0      # current indent level

        # Raw file lines.
        self.raw = f.readlines()

        # File lines, rstripped & tab-expanded.  Dummy at start is so
        # that we can use tokenize's 1-based line numbering easily.
        # Note that a line is all-blank iff it's "\n".
        self.lines = [line.rstrip('\n \t').expandtabs() + "\n"
                      for line in self.raw]
        self.lines.insert(0, None)
        self.index = 1  # index into self.lines of next line

        # List of (lineno, indentlevel) pairs, one for each stmt and
        # comment line.  indentlevel is -1 for comment lines, as a
        # signal that tokenize doesn't know what to do about them;
        # indeed, they're our headache!
        self.stats = []

    def run(self):
        tokenize.tokenize(self.getline, self.tokeneater)
        # Remove trailing empty lines.
        lines = self.lines
        while lines and lines[-1] == "\n":
            lines.pop()
        # Sentinel.
        stats = self.stats
        stats.append((len(lines), 0))
        # Map count of leading spaces to # we want.
        have2want = {}
        # Program after transformation.
        after = self.after = []
        # Copy over initial empty lines -- there's nothing to do until
        # we see a line with *something* on it.
        i = stats[0][0]
        after.extend(lines[1:i])
        for i in range(len(stats)-1):
            thisstmt, thislevel = stats[i]
            nextstmt = stats[i+1][0]
            have = getlspace(lines[thisstmt])
            want = thislevel * 4
            if want < 0:
                # A comment line.
                if have:
                    # An indented comment line.  If we saw the same
                    # indentation before, reuse what it most recently
                    # mapped to.
                    want = have2want.get(have, -1)
                    if want < 0:
                        # Then it probably belongs to the next real stmt.
                        for j in xrange(i+1, len(stats)-1):
                            jline, jlevel = stats[j]
                            if jlevel >= 0:
                                if have == getlspace(lines[jline]):
                                    want = jlevel * 4
                                break
                    if want < 0:           # Maybe it's a hanging
                                           # comment like this one,
                        # in which case we should shift it like its base
                        # line got shifted.
                        for j in xrange(i-1, -1, -1):
                            jline, jlevel = stats[j]
                            if jlevel >= 0:
                                want = have + getlspace(after[jline-1]) - \
                                       getlspace(lines[jline])
                                break
                    if want < 0:
                        # Still no luck -- leave it alone.
                        want = have
                else:
                    want = 0
            assert want >= 0
            have2want[have] = want
            diff = want - have
            if diff == 0 or have == 0:
                after.extend(lines[thisstmt:nextstmt])
            else:
                for line in lines[thisstmt:nextstmt]:
                    if diff > 0:
                        if line == "\n":
                            after.append(line)
                        else:
                            after.append(" " * diff + line)
                    else:
                        remove = min(getlspace(line), -diff)
                        after.append(line[remove:])
        return self.raw != self.after

    def write(self, f):
        f.writelines(self.after)

    # Line-getter for tokenize.
    def getline(self):
        if self.index >= len(self.lines):
            line = ""
        else:
            line = self.lines[self.index]
            self.index += 1
        return line

    # Line-eater for tokenize.
    def tokeneater(self, type, token, (sline, scol), end, line,
                   INDENT=tokenize.INDENT,
                   DEDENT=tokenize.DEDENT,
                   NEWLINE=tokenize.NEWLINE,
                   COMMENT=tokenize.COMMENT,
                   NL=tokenize.NL):

        if type == NEWLINE:
            # A program statement, or ENDMARKER, will eventually follow,
            # after some (possibly empty) run of tokens of the form
            #     (NL | COMMENT)* (INDENT | DEDENT+)?
            self.find_stmt = 1

        elif type == INDENT:
            self.find_stmt = 1
            self.level += 1

        elif type == DEDENT:
            self.find_stmt = 1
            self.level -= 1

        elif type == COMMENT:
            if self.find_stmt:
                self.stats.append((sline, -1))
                # but we're still looking for a new stmt, so leave
                # find_stmt alone

        elif type == NL:
            pass

        elif self.find_stmt:
            # This is the first "real token" following a NEWLINE, so it
            # must be the first token of the next program statement, or an
            # ENDMARKER.
            self.find_stmt = 0
            if line:   # not endmarker
                self.stats.append((sline, self.level))

# Count number of leading blanks.
def getlspace(line):
    i, n = 0, len(line)
    while i < n and line[i] == " ":
        i += 1
    return i

if __name__ == '__main__':
    main()
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Vim Colorscheme Converter
    ~~~~~~~~~~~~~~~~~~~~~~~~~

    This script converts vim colorscheme files to valid pygments
    style classes meant for putting into modules.

    :copyright 2006 by Armin Ronacher.
    :license: BSD, see LICENSE for details.
"""

import sys
import re
from os import path
from cStringIO import StringIO

split_re = re.compile(r'(?<!\\)\s+')

SCRIPT_NAME = 'Vim Colorscheme Converter'
SCRIPT_VERSION = '0.1'


COLORS = {
    # Numeric Colors
    '0': '#000000',
    '1': '#c00000',
    '2': '#008000',
    '3': '#808000',
    '4': '#0000c0',
    '5': '#c000c0',
    '6': '#008080',
    '7': '#c0c0c0',
    '8': '#808080',
    '9': '#ff6060',
    '10': '#00ff00',
    '11': '#ffff00',
    '12': '#8080ff',
    '13': '#ff40ff',
    '14': '#00ffff',
    '15': '#ffffff',
    # Named Colors
    'alice': '#f0f8ff',
    'aliceblue': '#f0f8ff',
    'antique': '#faebd7',
    'antiquewhite': '#faebd7',
    'antiquewhite1': '#ffefdb',
    'antiquewhite2': '#eedfcc',
    'antiquewhite3': '#cdc0b0',
    'antiquewhite4': '#8b8378',
    'aquamarine': '#7fffd4',
    'aquamarine1': '#7fffd4',
    'aquamarine2': '#76eec6',
    'aquamarine3': '#66cdaa',
    'aquamarine4': '#458b74',
    'azure': '#f0ffff',
    'azure1': '#f0ffff',
    'azure2': '#e0eeee',
    'azure3': '#c1cdcd',
    'azure4': '#838b8b',
    'beige': '#f5f5dc',
    'bisque': '#ffe4c4',
    'bisque1': '#ffe4c4',
    'bisque2': '#eed5b7',
    'bisque3': '#cdb79e',
    'bisque4': '#8b7d6b',
    'black': '#000000',
    'blanched': '#ffebcd',
    'blanchedalmond': '#ffebcd',
    'blue': '#8a2be2',
    'blue1': '#0000ff',
    'blue2': '#0000ee',
    'blue3': '#0000cd',
    'blue4': '#00008b',
    'blueviolet': '#8a2be2',
    'brown': '#a52a2a',
    'brown1': '#ff4040',
    'brown2': '#ee3b3b',
    'brown3': '#cd3333',
    'brown4': '#8b2323',
    'burlywood': '#deb887',
    'burlywood1': '#ffd39b',
    'burlywood2': '#eec591',
    'burlywood3': '#cdaa7d',
    'burlywood4': '#8b7355',
    'cadet': '#5f9ea0',
    'cadetblue': '#5f9ea0',
    'cadetblue1': '#98f5ff',
    'cadetblue2': '#8ee5ee',
    'cadetblue3': '#7ac5cd',
    'cadetblue4': '#53868b',
    'chartreuse': '#7fff00',
    'chartreuse1': '#7fff00',
    'chartreuse2': '#76ee00',
    'chartreuse3': '#66cd00',
    'chartreuse4': '#458b00',
    'chocolate': '#d2691e',
    'chocolate1': '#ff7f24',
    'chocolate2': '#ee7621',
    'chocolate3': '#cd661d',
    'chocolate4': '#8b4513',
    'coral': '#ff7f50',
    'coral1': '#ff7256',
    'coral2': '#ee6a50',
    'coral3': '#cd5b45',
    'coral4': '#8b3e2f',
    'cornflower': '#6495ed',
    'cornflowerblue': '#6495ed',
    'cornsilk': '#fff8dc',
    'cornsilk1': '#fff8dc',
    'cornsilk2': '#eee8cd',
    'cornsilk3': '#cdc8b1',
    'cornsilk4': '#8b8878',
    'cyan': '#00ffff',
    'cyan1': '#00ffff',
    'cyan2': '#00eeee',
    'cyan3': '#00cdcd',
    'cyan4': '#008b8b',
    'dark': '#8b0000',
    'darkblue': '#00008b',
    'darkcyan': '#008b8b',
    'darkgoldenrod': '#b8860b',
    'darkgoldenrod1': '#ffb90f',
    'darkgoldenrod2': '#eead0e',
    'darkgoldenrod3': '#cd950c',
    'darkgoldenrod4': '#8b6508',
    'darkgray': '#a9a9a9',
    'darkgreen': '#006400',
    'darkgrey': '#a9a9a9',
    'darkkhaki': '#bdb76b',
    'darkmagenta': '#8b008b',
    'darkolivegreen': '#556b2f',
    'darkolivegreen1': '#caff70',
    'darkolivegreen2': '#bcee68',
    'darkolivegreen3': '#a2cd5a',
    'darkolivegreen4': '#6e8b3d',
    'darkorange': '#ff8c00',
    'darkorange1': '#ff7f00',
    'darkorange2': '#ee7600',
    'darkorange3': '#cd6600',
    'darkorange4': '#8b4500',
    'darkorchid': '#9932cc',
    'darkorchid1': '#bf3eff',
    'darkorchid2': '#b23aee',
    'darkorchid3': '#9a32cd',
    'darkorchid4': '#68228b',
    'darkred': '#8b0000',
    'darksalmon': '#e9967a',
    'darkseagreen': '#8fbc8f',
    'darkseagreen1': '#c1ffc1',
    'darkseagreen2': '#b4eeb4',
    'darkseagreen3': '#9bcd9b',
    'darkseagreen4': '#698b69',
    'darkslateblue': '#483d8b',
    'darkslategray': '#2f4f4f',
    'darkslategray1': '#97ffff',
    'darkslategray2': '#8deeee',
    'darkslategray3': '#79cdcd',
    'darkslategray4': '#528b8b',
    'darkslategrey': '#2f4f4f',
    'darkturquoise': '#00ced1',
    'darkviolet': '#9400d3',
    'deep': '#ff1493',
    'deeppink': '#ff1493',
    'deeppink1': '#ff1493',
    'deeppink2': '#ee1289',
    'deeppink3': '#cd1076',
    'deeppink4': '#8b0a50',
    'deepskyblue': '#00bfff',
    'deepskyblue1': '#00bfff',
    'deepskyblue2': '#00b2ee',
    'deepskyblue3': '#009acd',
    'deepskyblue4': '#00688b',
    'dim': '#696969',
    'dimgray': '#696969',
    'dimgrey': '#696969',
    'dodger': '#1e90ff',
    'dodgerblue': '#1e90ff',
    'dodgerblue1': '#1e90ff',
    'dodgerblue2': '#1c86ee',
    'dodgerblue3': '#1874cd',
    'dodgerblue4': '#104e8b',
    'firebrick': '#b22222',
    'firebrick1': '#ff3030',
    'firebrick2': '#ee2c2c',
    'firebrick3': '#cd2626',
    'firebrick4': '#8b1a1a',
    'floral': '#fffaf0',
    'floralwhite': '#fffaf0',
    'forest': '#228b22',
    'forestgreen': '#228b22',
    'gainsboro': '#dcdcdc',
    'ghost': '#f8f8ff',
    'ghostwhite': '#f8f8ff',
    'gold': '#ffd700',
    'gold1': '#ffd700',
    'gold2': '#eec900',
    'gold3': '#cdad00',
    'gold4': '#8b7500',
    'goldenrod': '#daa520',
    'goldenrod1': '#ffc125',
    'goldenrod2': '#eeb422',
    'goldenrod3': '#cd9b1d',
    'goldenrod4': '#8b6914',
    'gray': '#bebebe',
    'gray0': '#000000',
    'gray1': '#030303',
    'gray10': '#1a1a1a',
    'gray100': '#ffffff',
    'gray11': '#1c1c1c',
    'gray12': '#1f1f1f',
    'gray13': '#212121',
    'gray14': '#242424',
    'gray15': '#262626',
    'gray16': '#292929',
    'gray17': '#2b2b2b',
    'gray18': '#2e2e2e',
    'gray19': '#303030',
    'gray2': '#050505',
    'gray20': '#333333',
    'gray21': '#363636',
    'gray22': '#383838',
    'gray23': '#3b3b3b',
    'gray24': '#3d3d3d',
    'gray25': '#404040',
    'gray26': '#424242',
    'gray27': '#454545',
    'gray28': '#474747',
    'gray29': '#4a4a4a',
    'gray3': '#080808',
    'gray30': '#4d4d4d',
    'gray31': '#4f4f4f',
    'gray32': '#525252',
    'gray33': '#545454',
    'gray34': '#575757',
    'gray35': '#595959',
    'gray36': '#5c5c5c',
    'gray37': '#5e5e5e',
    'gray38': '#616161',
    'gray39': '#636363',
    'gray4': '#0a0a0a',
    'gray40': '#666666',
    'gray41': '#696969',
    'gray42': '#6b6b6b',
    'gray43': '#6e6e6e',
    'gray44': '#707070',
    'gray45': '#737373',
    'gray46': '#757575',
    'gray47': '#787878',
    'gray48': '#7a7a7a',
    'gray49': '#7d7d7d',
    'gray5': '#0d0d0d',
    'gray50': '#7f7f7f',
    'gray51': '#828282',
    'gray52': '#858585',
    'gray53': '#878787',
    'gray54': '#8a8a8a',
    'gray55': '#8c8c8c',
    'gray56': '#8f8f8f',
    'gray57': '#919191',
    'gray58': '#949494',
    'gray59': '#969696',
    'gray6': '#0f0f0f',
    'gray60': '#999999',
    'gray61': '#9c9c9c',
    'gray62': '#9e9e9e',
    'gray63': '#a1a1a1',
    'gray64': '#a3a3a3',
    'gray65': '#a6a6a6',
    'gray66': '#a8a8a8',
    'gray67': '#ababab',
    'gray68': '#adadad',
    'gray69': '#b0b0b0',
    'gray7': '#121212',
    'gray70': '#b3b3b3',
    'gray71': '#b5b5b5',
    'gray72': '#b8b8b8',
    'gray73': '#bababa',
    'gray74': '#bdbdbd',
    'gray75': '#bfbfbf',
    'gray76': '#c2c2c2',
    'gray77': '#c4c4c4',
    'gray78': '#c7c7c7',
    'gray79': '#c9c9c9',
    'gray8': '#141414',
    'gray80': '#cccccc',
    'gray81': '#cfcfcf',
    'gray82': '#d1d1d1',
    'gray83': '#d4d4d4',
    'gray84': '#d6d6d6',
    'gray85': '#d9d9d9',
    'gray86': '#dbdbdb',
    'gray87': '#dedede',
    'gray88': '#e0e0e0',
    'gray89': '#e3e3e3',
    'gray9': '#171717',
    'gray90': '#e5e5e5',
    'gray91': '#e8e8e8',
    'gray92': '#ebebeb',
    'gray93': '#ededed',
    'gray94': '#f0f0f0',
    'gray95': '#f2f2f2',
    'gray96': '#f5f5f5',
    'gray97': '#f7f7f7',
    'gray98': '#fafafa',
    'gray99': '#fcfcfc',
    'green': '#adff2f',
    'green1': '#00ff00',
    'green2': '#00ee00',
    'green3': '#00cd00',
    'green4': '#008b00',
    'greenyellow': '#adff2f',
    'grey': '#bebebe',
    'grey0': '#000000',
    'grey1': '#030303',
    'grey10': '#1a1a1a',
    'grey100': '#ffffff',
    'grey11': '#1c1c1c',
    'grey12': '#1f1f1f',
    'grey13': '#212121',
    'grey14': '#242424',
    'grey15': '#262626',
    'grey16': '#292929',
    'grey17': '#2b2b2b',
    'grey18': '#2e2e2e',
    'grey19': '#303030',
    'grey2': '#050505',
    'grey20': '#333333',
    'grey21': '#363636',
    'grey22': '#383838',
    'grey23': '#3b3b3b',
    'grey24': '#3d3d3d',
    'grey25': '#404040',
    'grey26': '#424242',
    'grey27': '#454545',
    'grey28': '#474747',
    'grey29': '#4a4a4a',
    'grey3': '#080808',
    'grey30': '#4d4d4d',
    'grey31': '#4f4f4f',
    'grey32': '#525252',
    'grey33': '#545454',
    'grey34': '#575757',
    'grey35': '#595959',
    'grey36': '#5c5c5c',
    'grey37': '#5e5e5e',
    'grey38': '#616161',
    'grey39': '#636363',
    'grey4': '#0a0a0a',
    'grey40': '#666666',
    'grey41': '#696969',
    'grey42': '#6b6b6b',
    'grey43': '#6e6e6e',
    'grey44': '#707070',
    'grey45': '#737373',
    'grey46': '#757575',
    'grey47': '#787878',
    'grey48': '#7a7a7a',
    'grey49': '#7d7d7d',
    'grey5': '#0d0d0d',
    'grey50': '#7f7f7f',
    'grey51': '#828282',
    'grey52': '#858585',
    'grey53': '#878787',
    'grey54': '#8a8a8a',
    'grey55': '#8c8c8c',
    'grey56': '#8f8f8f',
    'grey57': '#919191',
    'grey58': '#949494',
    'grey59': '#969696',
    'grey6': '#0f0f0f',
    'grey60': '#999999',
    'grey61': '#9c9c9c',
    'grey62': '#9e9e9e',
    'grey63': '#a1a1a1',
    'grey64': '#a3a3a3',
    'grey65': '#a6a6a6',
    'grey66': '#a8a8a8',
    'grey67': '#ababab',
    'grey68': '#adadad',
    'grey69': '#b0b0b0',
    'grey7': '#121212',
    'grey70': '#b3b3b3',
    'grey71': '#b5b5b5',
    'grey72': '#b8b8b8',
    'grey73': '#bababa',
    'grey74': '#bdbdbd',
    'grey75': '#bfbfbf',
    'grey76': '#c2c2c2',
    'grey77': '#c4c4c4',
    'grey78': '#c7c7c7',
    'grey79': '#c9c9c9',
    'grey8': '#141414',
    'grey80': '#cccccc',
    'grey81': '#cfcfcf',
    'grey82': '#d1d1d1',
    'grey83': '#d4d4d4',
    'grey84': '#d6d6d6',
    'grey85': '#d9d9d9',
    'grey86': '#dbdbdb',
    'grey87': '#dedede',
    'grey88': '#e0e0e0',
    'grey89': '#e3e3e3',
    'grey9': '#171717',
    'grey90': '#e5e5e5',
    'grey91': '#e8e8e8',
    'grey92': '#ebebeb',
    'grey93': '#ededed',
    'grey94': '#f0f0f0',
    'grey95': '#f2f2f2',
    'grey96': '#f5f5f5',
    'grey97': '#f7f7f7',
    'grey98': '#fafafa',
    'grey99': '#fcfcfc',
    'honeydew': '#f0fff0',
    'honeydew1': '#f0fff0',
    'honeydew2': '#e0eee0',
    'honeydew3': '#c1cdc1',
    'honeydew4': '#838b83',
    'hot': '#ff69b4',
    'hotpink': '#ff69b4',
    'hotpink1': '#ff6eb4',
    'hotpink2': '#ee6aa7',
    'hotpink3': '#cd6090',
    'hotpink4': '#8b3a62',
    'indian': '#cd5c5c',
    'indianred': '#cd5c5c',
    'indianred1': '#ff6a6a',
    'indianred2': '#ee6363',
    'indianred3': '#cd5555',
    'indianred4': '#8b3a3a',
    'ivory': '#fffff0',
    'ivory1': '#fffff0',
    'ivory2': '#eeeee0',
    'ivory3': '#cdcdc1',
    'ivory4': '#8b8b83',
    'khaki': '#f0e68c',
    'khaki1': '#fff68f',
    'khaki2': '#eee685',
    'khaki3': '#cdc673',
    'khaki4': '#8b864e',
    'lavender': '#fff0f5',
    'lavenderblush': '#fff0f5',
    'lavenderblush1': '#fff0f5',
    'lavenderblush2': '#eee0e5',
    'lavenderblush3': '#cdc1c5',
    'lavenderblush4': '#8b8386',
    'lawn': '#7cfc00',
    'lawngreen': '#7cfc00',
    'lemon': '#fffacd',
    'lemonchiffon': '#fffacd',
    'lemonchiffon1': '#fffacd',
    'lemonchiffon2': '#eee9bf',
    'lemonchiffon3': '#cdc9a5',
    'lemonchiffon4': '#8b8970',
    'light': '#90ee90',
    'lightblue': '#add8e6',
    'lightblue1': '#bfefff',
    'lightblue2': '#b2dfee',
    'lightblue3': '#9ac0cd',
    'lightblue4': '#68838b',
    'lightcoral': '#f08080',
    'lightcyan': '#e0ffff',
    'lightcyan1': '#e0ffff',
    'lightcyan2': '#d1eeee',
    'lightcyan3': '#b4cdcd',
    'lightcyan4': '#7a8b8b',
    'lightgoldenrod': '#eedd82',
    'lightgoldenrod1': '#ffec8b',
    'lightgoldenrod2': '#eedc82',
    'lightgoldenrod3': '#cdbe70',
    'lightgoldenrod4': '#8b814c',
    'lightgoldenrodyellow': '#fafad2',
    'lightgray': '#d3d3d3',
    'lightgreen': '#90ee90',
    'lightgrey': '#d3d3d3',
    'lightpink': '#ffb6c1',
    'lightpink1': '#ffaeb9',
    'lightpink2': '#eea2ad',
    'lightpink3': '#cd8c95',
    'lightpink4': '#8b5f65',
    'lightsalmon': '#ffa07a',
    'lightsalmon1': '#ffa07a',
    'lightsalmon2': '#ee9572',
    'lightsalmon3': '#cd8162',
    'lightsalmon4': '#8b5742',
    'lightseagreen': '#20b2aa',
    'lightskyblue': '#87cefa',
    'lightskyblue1': '#b0e2ff',
    'lightskyblue2': '#a4d3ee',
    'lightskyblue3': '#8db6cd',
    'lightskyblue4': '#607b8b',
    'lightslateblue': '#8470ff',
    'lightslategray': '#778899',
    'lightslategrey': '#778899',
    'lightsteelblue': '#b0c4de',
    'lightsteelblue1': '#cae1ff',
    'lightsteelblue2': '#bcd2ee',
    'lightsteelblue3': '#a2b5cd',
    'lightsteelblue4': '#6e7b8b',
    'lightyellow': '#ffffe0',
    'lightyellow1': '#ffffe0',
    'lightyellow2': '#eeeed1',
    'lightyellow3': '#cdcdb4',
    'lightyellow4': '#8b8b7a',
    'lime': '#32cd32',
    'limegreen': '#32cd32',
    'linen': '#faf0e6',
    'magenta': '#ff00ff',
    'magenta1': '#ff00ff',
    'magenta2': '#ee00ee',
    'magenta3': '#cd00cd',
    'magenta4': '#8b008b',
    'maroon': '#b03060',
    'maroon1': '#ff34b3',
    'maroon2': '#ee30a7',
    'maroon3': '#cd2990',
    'maroon4': '#8b1c62',
    'medium': '#9370db',
    'mediumaquamarine': '#66cdaa',
    'mediumblue': '#0000cd',
    'mediumorchid': '#ba55d3',
    'mediumorchid1': '#e066ff',
    'mediumorchid2': '#d15fee',
    'mediumorchid3': '#b452cd',
    'mediumorchid4': '#7a378b',
    'mediumpurple': '#9370db',
    'mediumpurple1': '#ab82ff',
    'mediumpurple2': '#9f79ee',
    'mediumpurple3': '#8968cd',
    'mediumpurple4': '#5d478b',
    'mediumseagreen': '#3cb371',
    'mediumslateblue': '#7b68ee',
    'mediumspringgreen': '#00fa9a',
    'mediumturquoise': '#48d1cc',
    'mediumvioletred': '#c71585',
    'midnight': '#191970',
    'midnightblue': '#191970',
    'mint': '#f5fffa',
    'mintcream': '#f5fffa',
    'misty': '#ffe4e1',
    'mistyrose': '#ffe4e1',
    'mistyrose1': '#ffe4e1',
    'mistyrose2': '#eed5d2',
    'mistyrose3': '#cdb7b5',
    'mistyrose4': '#8b7d7b',
    'moccasin': '#ffe4b5',
    'navajo': '#ffdead',
    'navajowhite': '#ffdead',
    'navajowhite1': '#ffdead',
    'navajowhite2': '#eecfa1',
    'navajowhite3': '#cdb38b',
    'navajowhite4': '#8b795e',
    'navy': '#000080',
    'navyblue': '#000080',
    'old': '#fdf5e6',
    'oldlace': '#fdf5e6',
    'olive': '#6b8e23',
    'olivedrab': '#6b8e23',
    'olivedrab1': '#c0ff3e',
    'olivedrab2': '#b3ee3a',
    'olivedrab3': '#9acd32',
    'olivedrab4': '#698b22',
    'orange': '#ff4500',
    'orange1': '#ffa500',
    'orange2': '#ee9a00',
    'orange3': '#cd8500',
    'orange4': '#8b5a00',
    'orangered': '#ff4500',
    'orangered1': '#ff4500',
    'orangered2': '#ee4000',
    'orangered3': '#cd3700',
    'orangered4': '#8b2500',
    'orchid': '#da70d6',
    'orchid1': '#ff83fa',
    'orchid2': '#ee7ae9',
    'orchid3': '#cd69c9',
    'orchid4': '#8b4789',
    'pale': '#db7093',
    'palegoldenrod': '#eee8aa',
    'palegreen': '#98fb98',
    'palegreen1': '#9aff9a',
    'palegreen2': '#90ee90',
    'palegreen3': '#7ccd7c',
    'palegreen4': '#548b54',
    'paleturquoise': '#afeeee',
    'paleturquoise1': '#bbffff',
    'paleturquoise2': '#aeeeee',
    'paleturquoise3': '#96cdcd',
    'paleturquoise4': '#668b8b',
    'palevioletred': '#db7093',
    'palevioletred1': '#ff82ab',
    'palevioletred2': '#ee799f',
    'palevioletred3': '#cd6889',
    'palevioletred4': '#8b475d',
    'papaya': '#ffefd5',
    'papayawhip': '#ffefd5',
    'peach': '#ffdab9',
    'peachpuff': '#ffdab9',
    'peachpuff1': '#ffdab9',
    'peachpuff2': '#eecbad',
    'peachpuff3': '#cdaf95',
    'peachpuff4': '#8b7765',
    'peru': '#cd853f',
    'pink': '#ffc0cb',
    'pink1': '#ffb5c5',
    'pink2': '#eea9b8',
    'pink3': '#cd919e',
    'pink4': '#8b636c',
    'plum': '#dda0dd',
    'plum1': '#ffbbff',
    'plum2': '#eeaeee',
    'plum3': '#cd96cd',
    'plum4': '#8b668b',
    'powder': '#b0e0e6',
    'powderblue': '#b0e0e6',
    'purple': '#a020f0',
    'purple1': '#9b30ff',
    'purple2': '#912cee',
    'purple3': '#7d26cd',
    'purple4': '#551a8b',
    'red': '#ff0000',
    'red1': '#ff0000',
    'red2': '#ee0000',
    'red3': '#cd0000',
    'red4': '#8b0000',
    'rosy': '#bc8f8f',
    'rosybrown': '#bc8f8f',
    'rosybrown1': '#ffc1c1',
    'rosybrown2': '#eeb4b4',
    'rosybrown3': '#cd9b9b',
    'rosybrown4': '#8b6969',
    'royal': '#4169e1',
    'royalblue': '#4169e1',
    'royalblue1': '#4876ff',
    'royalblue2': '#436eee',
    'royalblue3': '#3a5fcd',
    'royalblue4': '#27408b',
    'saddle': '#8b4513',
    'saddlebrown': '#8b4513',
    'salmon': '#fa8072',
    'salmon1': '#ff8c69',
    'salmon2': '#ee8262',
    'salmon3': '#cd7054',
    'salmon4': '#8b4c39',
    'sandy': '#f4a460',
    'sandybrown': '#f4a460',
    'sea': '#2e8b57',
    'seagreen': '#2e8b57',
    'seagreen1': '#54ff9f',
    'seagreen2': '#4eee94',
    'seagreen3': '#43cd80',
    'seagreen4': '#2e8b57',
    'seashell': '#fff5ee',
    'seashell1': '#fff5ee',
    'seashell2': '#eee5de',
    'seashell3': '#cdc5bf',
    'seashell4': '#8b8682',
    'sienna': '#a0522d',
    'sienna1': '#ff8247',
    'sienna2': '#ee7942',
    'sienna3': '#cd6839',
    'sienna4': '#8b4726',
    'sky': '#87ceeb',
    'skyblue': '#87ceeb',
    'skyblue1': '#87ceff',
    'skyblue2': '#7ec0ee',
    'skyblue3': '#6ca6cd',
    'skyblue4': '#4a708b',
    'slate': '#6a5acd',
    'slateblue': '#6a5acd',
    'slateblue1': '#836fff',
    'slateblue2': '#7a67ee',
    'slateblue3': '#6959cd',
    'slateblue4': '#473c8b',
    'slategray': '#708090',
    'slategray1': '#c6e2ff',
    'slategray2': '#b9d3ee',
    'slategray3': '#9fb6cd',
    'slategray4': '#6c7b8b',
    'slategrey': '#708090',
    'snow': '#fffafa',
    'snow1': '#fffafa',
    'snow2': '#eee9e9',
    'snow3': '#cdc9c9',
    'snow4': '#8b8989',
    'spring': '#00ff7f',
    'springgreen': '#00ff7f',
    'springgreen1': '#00ff7f',
    'springgreen2': '#00ee76',
    'springgreen3': '#00cd66',
    'springgreen4': '#008b45',
    'steel': '#4682b4',
    'steelblue': '#4682b4',
    'steelblue1': '#63b8ff',
    'steelblue2': '#5cacee',
    'steelblue3': '#4f94cd',
    'steelblue4': '#36648b',
    'tan': '#d2b48c',
    'tan1': '#ffa54f',
    'tan2': '#ee9a49',
    'tan3': '#cd853f',
    'tan4': '#8b5a2b',
    'thistle': '#d8bfd8',
    'thistle1': '#ffe1ff',
    'thistle2': '#eed2ee',
    'thistle3': '#cdb5cd',
    'thistle4': '#8b7b8b',
    'tomato': '#ff6347',
    'tomato1': '#ff6347',
    'tomato2': '#ee5c42',
    'tomato3': '#cd4f39',
    'tomato4': '#8b3626',
    'turquoise': '#40e0d0',
    'turquoise1': '#00f5ff',
    'turquoise2': '#00e5ee',
    'turquoise3': '#00c5cd',
    'turquoise4': '#00868b',
    'violet': '#ee82ee',
    'violetred': '#d02090',
    'violetred1': '#ff3e96',
    'violetred2': '#ee3a8c',
    'violetred3': '#cd3278',
    'violetred4': '#8b2252',
    'wheat': '#f5deb3',
    'wheat1': '#ffe7ba',
    'wheat2': '#eed8ae',
    'wheat3': '#cdba96',
    'wheat4': '#8b7e66',
    'white': '#ffffff',
    'whitesmoke': '#f5f5f5',
    'yellow': '#ffff00',
    'yellow1': '#ffff00',
    'yellow2': '#eeee00',
    'yellow3': '#cdcd00',
    'yellow4': '#8b8b00',
    'yellowgreen': '#9acd32'
}

TOKENS = {
    'normal':           '',
    'string':           'String',
    'number':           'Number',
    'float':            'Number.Float',
    'constant':         'Name.Constant',
    'number':           'Number',
    'statement':        ('Keyword', 'Name.Tag'),
    'identifier':       'Name.Variable',
    'operator':         'Operator.Word',
    'label':            'Name.Label',
    'exception':        'Name.Exception',
    'function':         ('Name.Function', 'Name.Attribute'),
    'preproc':          'Comment.Preproc',
    'comment':          'Comment',
    'type':             'Keyword.Type',
    'diffadd':          'Generic.Inserted',
    'diffdelete':       'Generic.Deleted',
    'error':            'Generic.Error',
    'errormsg':         'Generic.Traceback',
    'title':            ('Generic.Heading', 'Generic.Subheading'),
    'underlined':       'Generic.Emph',
    'special':          'Name.Entity',
    'nontext':          'Generic.Output'
}

TOKEN_TYPES = set()
for token in TOKENS.itervalues():
    if not isinstance(token, tuple):
        token = (token,)
    for token in token:
        if token:
            TOKEN_TYPES.add(token.split('.')[0])


def get_vim_color(color):
    if color.startswith('#'):
        if len(color) == 7:
            return color
        else:
            return '#%s0' % '0'.join(color)[1:]
    return COLORS.get(color.lower())


def find_colors(code):
    colors = {'Normal': {}}
    bg_color = None
    def set(attrib, value):
        if token not in colors:
            colors[token] = {}
        if key.startswith('gui') or attrib not in colors[token]:
            colors[token][attrib] = value

    for line in code.splitlines():
        if line.startswith('"'):
            continue
        parts = split_re.split(line.strip())
        if len(parts) == 2 and parts[0] == 'set':
            p = parts[1].split()
            if p[0] == 'background' and p[1] == 'dark':
                token = 'Normal'
                bg_color = '#000000'
        elif len(parts) > 2 and \
           len(parts[0]) >= 2 and \
           'highlight'.startswith(parts[0]):
            token = parts[1].lower()
            if token not in TOKENS:
                continue
            for item in parts[2:]:
                p = item.split('=', 1)
                if not len(p) == 2:
                    continue
                key, value = p
                if key in ('ctermfg', 'guifg'):
                    color = get_vim_color(value)
                    if color:
                        set('color', color)
                elif key in ('ctermbg', 'guibg'):
                    color = get_vim_color(value)
                    if color:
                        set('bgcolor', color)
                elif key in ('term', 'cterm', 'gui'):
                    items = value.split(',')
                    for item in items:
                        item = item.lower()
                        if item == 'none':
                            set('noinherit', True)
                        elif item == 'bold':
                            set('bold', True)
                        elif item == 'underline':
                            set('underline', True)
                        elif item == 'italic':
                            set('italic', True)

    if bg_color is not None and not colors['Normal'].get('bgcolor'):
        colors['Normal']['bgcolor'] = bg_color

    color_map = {}
    for token, styles in colors.iteritems():
        if token in TOKENS:
            tmp = []
            if styles.get('noinherit'):
                tmp.append('noinherit')
            if 'color' in styles:
                tmp.append(styles['color'])
            if 'bgcolor' in styles:
                tmp.append('bg:' + styles['bgcolor'])
            if styles.get('bold'):
                tmp.append('bold')
            if styles.get('italic'):
                tmp.append('italic')
            if styles.get('underline'):
                tmp.append('underline')
            tokens = TOKENS[token]
            if not isinstance(tokens, tuple):
                tokens = (tokens,)
            for token in tokens:
                color_map[token] = ' '.join(tmp)

    default_token = color_map.pop('')
    return default_token, color_map


class StyleWriter(object):

    def __init__(self, code, name):
        self.code = code
        self.name = name.lower()

    def write_header(self, out):
        out.write('# -*- coding: utf-8 -*-\n"""\n')
        out.write('    %s Colorscheme\n' % self.name.title())
        out.write('    %s\n\n' % ('~' * (len(self.name) + 12)))
        out.write('    Converted by %s\n' % SCRIPT_NAME)
        out.write('"""\nfrom pygments.style import Style\n')
        out.write('from pygments.token import Token, %s\n\n' % ', '.join(TOKEN_TYPES))
        out.write('class %sStyle(Style):\n\n' % self.name.title())

    def write(self, out):
        self.write_header(out)
        default_token, tokens = find_colors(self.code)
        tokens = tokens.items()
        tokens.sort(lambda a, b: cmp(len(a[0]), len(a[1])))
        bg_color = [x[3:] for x in default_token.split() if x.startswith('bg:')]
        if bg_color:
            out.write('    background_color = %r\n' % bg_color[0])
        out.write('    styles = {\n')
        out.write('        %-20s%r\n' % ('Token:', default_token))
        for token, definition in tokens:
            if definition:
                out.write('        %-20s%r\n' % (token + ':', definition))
        out.write('    }')

    def __repr__(self):
        out = StringIO()
        self.write_style(out)
        return out.getvalue()


def convert(filename, stream=None):
    name = path.basename(filename)
    if name.endswith('.vim'):
        name = name[:-4]
    f = file(filename)
    code = f.read()
    f.close()
    writer = StyleWriter(code, name)
    if stream is not None:
        out = stream
    else:
        out = StringIO()
    writer.write(out)
    if stream is None:
        return out.getvalue()


def main():
    if len(sys.argv) != 2 or sys.argv[1] in ('-h', '--help'):
        print 'Usage: %s <filename.vim>' % sys.argv[0]
        return 2
    if sys.argv[1] in ('-v', '--version'):
        print '%s %s' % (SCRIPT_NAME, SCRIPT_VERSION)
        return
    filename = sys.argv[1]
    if not (path.exists(filename) and path.isfile(filename)):
        print 'Error: %s not found' % filename
        return 1
    convert(filename, sys.stdout)
    sys.stdout.write('\n')


if __name__ == '__main__':
    sys.exit(main() or 0)
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    Pygments
    ~~~~~~~~

    Pygments is a syntax highlighting package written in Python.

    It is a generic syntax highlighter for general use in all kinds of software
    such as forum systems, wikis or other applications that need to prettify
    source code. Highlights are:

    * a wide range of common languages and markup formats is supported
    * special attention is paid to details, increasing quality by a fair amount
    * support for new languages and formats are added easily
    * a number of output formats, presently HTML, LaTeX, RTF, SVG and ANSI sequences
    * it is usable as a command-line tool and as a library
    * ... and it highlights even Brainfuck!

    The `Pygments tip`_ is installable with ``easy_install Pygments==dev``.

    .. _Pygments tip: http://dev.pocoo.org/hg/pygments-main/archive/tip.tar.gz#egg=Pygments-dev

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

try:
    from setuptools import setup, find_packages
except ImportError:
    from distutils.core import setup
    def find_packages():
        return [
            'pygments',
            'pygments.lexers',
            'pygments.formatters',
            'pygments.styles',
            'pygments.filters',
        ]

try:
    from distutils.command.build_py import build_py_2to3 as build_py
except ImportError:
    from distutils.command.build_py import build_py

setup(
    name = 'Pygments',
    version = '1.1',
    url = 'http://pygments.org/',
    license = 'BSD License',
    author = 'Georg Brandl',
    author_email = 'georg@python.org',
    description = 'Pygments is a syntax highlighting package written in Python.',
    long_description = __doc__,
    keywords = 'syntax highlighting',
    packages = find_packages(),
    scripts = ['pygmentize'],
    platforms = 'any',
    zip_safe = False,
    include_package_data = True,
    classifiers = [
        'License :: OSI Approved :: BSD License',
        'Intended Audience :: Developers',
        'Intended Audience :: End Users/Desktop',
        'Intended Audience :: System Administrators',
        'Development Status :: 5 - Production/Stable',
        'Programming Language :: Python',
        'Operating System :: OS Independent',
    ],
    cmdclass = {'build_py': build_py},
)
# -*- coding: utf-8 -*-
"""
    Pygments unit tests
    ~~~~~~~~~~~~~~~~~~

    Usage::

        python run.py [testfile ...]


    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import sys, os
import unittest

from os.path import dirname, basename, join, abspath

import pygments

try:
    import coverage
except ImportError:
    coverage = None

testdir = abspath(dirname(__file__))

failed = []
total_test_count = 0
error_test_count = 0


def err(file, what, exc):
    print >>sys.stderr, file, 'failed %s:' % what,
    print >>sys.stderr, exc
    failed.append(file[:-3])


class QuietTestRunner(object):
    """Customized test runner for relatively quiet output"""

    def __init__(self, testname, stream=sys.stderr):
        self.testname = testname
        self.stream = unittest._WritelnDecorator(stream)

    def run(self, test):
        global total_test_count
        global error_test_count
        result = unittest._TextTestResult(self.stream, True, 1)
        test(result)
        if not result.wasSuccessful():
            self.stream.write(' FAIL:')
            result.printErrors()
            failed.append(self.testname)
        else:
            self.stream.write(' ok\n')
        total_test_count += result.testsRun
        error_test_count += len(result.errors) + len(result.failures)
        return result


def run_tests(with_coverage=False):
    # needed to avoid confusion involving atexit handlers
    import logging

    if sys.argv[1:]:
        # test only files given on cmdline
        files = [entry + '.py' for entry in sys.argv[1:] if entry.startswith('test_')]
    else:
        files = [entry for entry in os.listdir(testdir)
                 if (entry.startswith('test_') and entry.endswith('.py'))]
        files.sort()

    WIDTH = 85

    print >>sys.stderr, \
        ('Pygments %s Test Suite running%s, stand by...' %
         (pygments.__version__,
          with_coverage and " with coverage analysis" or "")).center(WIDTH)
    print >>sys.stderr, ('(using Python %s)' % sys.version.split()[0]).center(WIDTH)
    print >>sys.stderr, '='*WIDTH

    if with_coverage:
        coverage.erase()
        coverage.start()

    for testfile in files:
        globs = {'__file__': join(testdir, testfile)}
        try:
            execfile(join(testdir, testfile), globs)
        except Exception, exc:
            raise
            err(testfile, 'execfile', exc)
            continue
        sys.stderr.write(testfile[:-3] + ': ')
        try:
            runner = QuietTestRunner(testfile[:-3])
            # make a test suite of all TestCases in the file
            tests = []
            for name, thing in globs.iteritems():
                if name.endswith('Test'):
                    tests.append((name, unittest.makeSuite(thing)))
            tests.sort()
            suite = unittest.TestSuite()
            suite.addTests([x[1] for x in tests])
            runner.run(suite)
        except Exception, exc:
            err(testfile, 'running test', exc)

    print >>sys.stderr, '='*WIDTH
    if failed:
        print >>sys.stderr, '%d of %d tests failed.' % \
              (error_test_count, total_test_count)
        print >>sys.stderr, 'Tests failed in:', ', '.join(failed)
        ret = 1
    else:
        if total_test_count == 1:
            print >>sys.stderr, '1 test happy.'
        else:
            print >>sys.stderr, 'All %d tests happy.' % total_test_count
        ret = 0

    if with_coverage:
        coverage.stop()
        modules = [mod for name, mod in sys.modules.iteritems()
                   if name.startswith('pygments.') and mod]
        coverage.report(modules)

    return ret


if __name__ == '__main__':
    with_coverage = False
    if sys.argv[1:2] == ['-C']:
        with_coverage = bool(coverage)
        del sys.argv[1]
    sys.exit(run_tests(with_coverage))
# -*- coding: utf-8 -*-
"""
    Pygments unit tests
    ~~~~~~~~~~~~~~~~~~

    Usage::

        python run.py [testfile ...]


    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import sys, os

if sys.version_info >= (3,):
    # copy test suite over to "build/lib" and convert it
    print ('Copying and converting sources to build/lib/test...')
    from distutils.util import copydir_run_2to3
    testroot = os.path.dirname(__file__)
    newroot = os.path.join(testroot, '..', 'build/lib/test')
    copydir_run_2to3(testroot, newroot)
    os.chdir(os.path.join(newroot, '..'))

try:
    import nose
except ImportError:
    print ("nose is required to run the test suites")
    sys.exit(1)

nose.main()
# coding: utf-8
"""
Support for Pygments tests
"""

import os


def location(mod_name):
    """
    Return the file and directory that the code for *mod_name* is in.
    """
    source = mod_name.endswith("pyc") and mod_name[:-1] or mod_name
    source = os.path.abspath(source)
    return source, os.path.dirname(source)
# -*- coding: utf-8 -*-
"""
    Pygments basic API tests
    ~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import unittest
import random

from pygments import lexers, formatters, filters, format
from pygments.token import _TokenType, Text
from pygments.lexer import RegexLexer
from pygments.formatters.img import FontNotFound
from pygments.util import BytesIO, StringIO, bytes, b

import support

TESTFILE, TESTDIR = support.location(__file__)

test_content = [chr(i) for i in xrange(33, 128)] * 5
random.shuffle(test_content)
test_content = ''.join(test_content) + '\n'

class LexersTest(unittest.TestCase):

    def test_import_all(self):
        # instantiate every lexer, to see if the token type defs are correct
        for x in lexers.LEXERS.keys():
            c = getattr(lexers, x)()

    def test_lexer_classes(self):
        a = self.assert_
        ae = self.assertEquals
        # test that every lexer class has the correct public API
        for lexer in lexers._iter_lexerclasses():
            a(type(lexer.name) is str)
            for attr in 'aliases', 'filenames', 'alias_filenames', 'mimetypes':
                a(hasattr(lexer, attr))
                a(type(getattr(lexer, attr)) is list, "%s: %s attribute wrong" %
                                                      (lexer, attr))
            result = lexer.analyse_text("abc")
            a(isinstance(result, float) and 0.0 <= result <= 1.0)

            inst = lexer(opt1="val1", opt2="val2")
            if issubclass(lexer, RegexLexer):
                if not hasattr(lexer, '_tokens'):
                    # if there's no "_tokens", the lexer has to be one with
                    # multiple tokendef variants
                    a(lexer.token_variants)
                    for variant in lexer.tokens:
                        a('root' in lexer.tokens[variant])
                else:
                    a('root' in lexer._tokens, '%s has no root state' % lexer)

            tokens = list(inst.get_tokens(test_content))
            txt = ""
            for token in tokens:
                a(isinstance(token, tuple))
                a(isinstance(token[0], _TokenType))
                if isinstance(token[1], str):
                    print repr(token[1])
                a(isinstance(token[1], unicode))
                txt += token[1]
            ae(txt, test_content, "%s lexer roundtrip failed: %r != %r" %
                    (lexer.name, test_content, txt))

    def test_get_lexers(self):
        a = self.assert_
        ae = self.assertEquals
        # test that the lexers functions work

        for func, args in [(lexers.get_lexer_by_name, ("python",)),
                           (lexers.get_lexer_for_filename, ("test.py",)),
                           (lexers.get_lexer_for_mimetype, ("text/x-python",)),
                           (lexers.guess_lexer, ("#!/usr/bin/python -O\nprint",)),
                           (lexers.guess_lexer_for_filename, ("a.py", "<%= @foo %>"))
                           ]:
            x = func(opt="val", *args)
            a(isinstance(x, lexers.PythonLexer))
            ae(x.options["opt"], "val")


class FiltersTest(unittest.TestCase):

    def test_basic(self):
        filter_args = {
            'whitespace': {'spaces': True, 'tabs': True, 'newlines': True},
            'highlight': {'names': ['isinstance', 'lexers', 'x']},
        }
        for x in filters.FILTERS.keys():
            lx = lexers.PythonLexer()
            lx.add_filter(x, **filter_args.get(x, {}))
            text = open(TESTFILE, 'rb').read().decode('utf-8')
            tokens = list(lx.get_tokens(text))
            roundtext = ''.join([t[1] for t in tokens])
            if x not in ('whitespace', 'keywordcase'):
                # these filters change the text
                self.assertEquals(roundtext, text,
                                  "lexer roundtrip with %s filter failed" % x)

    def test_raiseonerror(self):
        lx = lexers.PythonLexer()
        lx.add_filter('raiseonerror', excclass=RuntimeError)
        self.assertRaises(RuntimeError, list, lx.get_tokens('$'))

    def test_whitespace(self):
        lx = lexers.PythonLexer()
        lx.add_filter('whitespace', spaces='%')
        text = open(TESTFILE, 'rb').read().decode('utf-8')
        lxtext = ''.join([t[1] for t in list(lx.get_tokens(text))])
        self.failIf(' ' in lxtext)

    def test_keywordcase(self):
        lx = lexers.PythonLexer()
        lx.add_filter('keywordcase', case='capitalize')
        text = open(TESTFILE, 'rb').read().decode('utf-8')
        lxtext = ''.join([t[1] for t in list(lx.get_tokens(text))])
        self.assert_('Def' in lxtext and 'Class' in lxtext)

    def test_codetag(self):
        lx = lexers.PythonLexer()
        lx.add_filter('codetagify')
        text = u'# BUG: text'
        tokens = list(lx.get_tokens(text))
        self.assertEquals('# ', tokens[0][1])
        self.assertEquals('BUG', tokens[1][1])

    def test_codetag_boundary(self):
        # http://dev.pocoo.org/projects/pygments/ticket/368
        lx = lexers.PythonLexer()
        lx.add_filter('codetagify')
        text = u'# DEBUG: text'
        tokens = list(lx.get_tokens(text))
        self.assertEquals('# DEBUG: text', tokens[0][1])


class FormattersTest(unittest.TestCase):

    def test_public_api(self):
        a = self.assert_
        ae = self.assertEquals
        ts = list(lexers.PythonLexer().get_tokens("def f(): pass"))
        out = StringIO()
        # test that every formatter class has the correct public API
        for formatter, info in formatters.FORMATTERS.iteritems():
            a(len(info) == 4)
            a(info[0], "missing formatter name") # name
            a(info[1], "missing formatter aliases") # aliases
            a(info[3], "missing formatter docstring") # doc

            if formatter.name == 'Raw tokens':
                # will not work with Unicode output file
                continue

            try:
                inst = formatter(opt1="val1")
            except (ImportError, FontNotFound):
                continue
            try:
                inst.get_style_defs()
            except NotImplementedError:
                # may be raised by formatters for which it doesn't make sense
                pass
            inst.format(ts, out)

    def test_encodings(self):
        from pygments.formatters import HtmlFormatter

        # unicode output
        fmt = HtmlFormatter()
        tokens = [(Text, u"ä")]
        out = format(tokens, fmt)
        self.assert_(type(out) is unicode)
        self.assert_(u"ä" in out)

        # encoding option
        fmt = HtmlFormatter(encoding="latin1")
        tokens = [(Text, u"ä")]
        self.assert_(u"ä".encode("latin1") in format(tokens, fmt))

        # encoding and outencoding option
        fmt = HtmlFormatter(encoding="latin1", outencoding="utf8")
        tokens = [(Text, u"ä")]
        self.assert_(u"ä".encode("utf8") in format(tokens, fmt))

    def test_styles(self):
        from pygments.formatters import HtmlFormatter
        fmt = HtmlFormatter(style="pastie")

    def test_unicode_handling(self):
        # test that the formatter supports encoding and Unicode
        tokens = list(lexers.PythonLexer(encoding='utf-8').
                      get_tokens("def f(): 'ä'"))
        for formatter, info in formatters.FORMATTERS.iteritems():
            try:
                inst = formatter(encoding=None)
            except (ImportError, FontNotFound):
                # some dependency or font not installed
                continue

            if formatter.name != 'Raw tokens':
                out = format(tokens, inst)
                if formatter.unicodeoutput:
                    self.assert_(type(out) is unicode)

                inst = formatter(encoding='utf-8')
                out = format(tokens, inst)
                self.assert_(type(out) is bytes, '%s: %r' % (formatter, out))
                # Cannot test for encoding, since formatters may have to escape
                # non-ASCII characters.
            else:
                inst = formatter()
                out = format(tokens, inst)
                self.assert_(type(out) is bytes, '%s: %r' % (formatter, out))

    def test_get_formatters(self):
        a = self.assert_
        ae = self.assertEquals
        # test that the formatters functions work
        x = formatters.get_formatter_by_name("html", opt="val")
        a(isinstance(x, formatters.HtmlFormatter))
        ae(x.options["opt"], "val")

        x = formatters.get_formatter_for_filename("a.html", opt="val")
        a(isinstance(x, formatters.HtmlFormatter))
        ae(x.options["opt"], "val")
# -*- coding: utf-8 -*-
"""
    Basic CLexer Test
    ~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import unittest
import os

from pygments.token import Text, Number
from pygments.lexers import CLexer


class CLexerTest(unittest.TestCase):

    def setUp(self):
        self.lexer = CLexer()

    def testNumbers(self):
        code = '42 23.42 23. .42 023 0xdeadbeef 23e+42 42e-23'
        wanted = []
        for item in zip([Number.Integer, Number.Float, Number.Float,
                         Number.Float, Number.Oct, Number.Hex,
                         Number.Float, Number.Float], code.split()):
            wanted.append(item)
            wanted.append((Text, ' '))
        wanted = [(Text, '')] + wanted[:-1] + [(Text, '\n')]
        self.assertEqual(list(self.lexer.get_tokens(code)), wanted)


if __name__ == '__main__':
    unittest.main()
# -*- coding: utf-8 -*-
"""
    Command line test
    ~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

# Test the command line interface

import sys, os
import unittest
import StringIO

from pygments import highlight
from pygments.cmdline import main as cmdline_main

import support

TESTFILE, TESTDIR = support.location(__file__)


def run_cmdline(*args):
    saved_stdout = sys.stdout
    saved_stderr = sys.stderr
    new_stdout = sys.stdout = StringIO.StringIO()
    new_stderr = sys.stderr = StringIO.StringIO()
    try:
        ret = cmdline_main(["pygmentize"] + list(args))
    finally:
        sys.stdout = saved_stdout
        sys.stderr = saved_stderr
    return (ret, new_stdout.getvalue(), new_stderr.getvalue())


class CmdLineTest(unittest.TestCase):

    def test_L_opt(self):
        c, o, e = run_cmdline("-L")
        self.assertEquals(c, 0)
        self.assert_("Lexers" in o and "Formatters" in o and
                     "Filters" in o and "Styles" in o)
        c, o, e = run_cmdline("-L", "lexer")
        self.assertEquals(c, 0)
        self.assert_("Lexers" in o and "Formatters" not in o)
        c, o, e = run_cmdline("-L", "lexers")
        self.assertEquals(c, 0)

    def test_O_opt(self):
        filename = TESTFILE
        c, o, e = run_cmdline("-Ofull=1,linenos=true,foo=bar",
                              "-fhtml", filename)
        self.assertEquals(c, 0)
        self.assert_("<html" in o)
        self.assert_('class="linenos"' in o)

    def test_P_opt(self):
        filename = TESTFILE
        c, o, e = run_cmdline("-Pfull", "-Ptitle=foo, bar=baz=,",
                              "-fhtml", filename)
        self.assertEquals(c, 0)
        self.assert_("<title>foo, bar=baz=,</title>" in o)

    def test_F_opt(self):
        filename = TESTFILE
        c, o, e = run_cmdline("-Fhighlight:tokentype=Name.Blubb,"
                              "names=TESTFILE filename",
                              "-fhtml", filename)
        self.assertEquals(c, 0)
        self.assert_('<span class="n-Blubb' in o)

    def test_H_opt(self):
        c, o, e = run_cmdline("-H", "formatter", "html")
        self.assertEquals(c, 0)
        self.assert_('HTML' in o)

    def test_S_opt(self):
        c, o, e = run_cmdline("-S", "default", "-f", "html", "-O", "linenos=1")
        self.assertEquals(c, 0)

    def test_invalid_opts(self):
        for opts in [("-L", "-lpy"), ("-L", "-fhtml"), ("-L", "-Ox"),
                     ("-a",), ("-Sst", "-lpy"), ("-H",),
                     ("-H", "formatter"),]:
            self.assert_(run_cmdline(*opts)[0] == 2)

    def test_normal(self):
        # test that cmdline gives the same output as library api
        from pygments.lexers import PythonLexer
        from pygments.formatters import HtmlFormatter
        filename = TESTFILE
        code = open(filename, 'rb').read()

        output = highlight(code, PythonLexer(), HtmlFormatter())

        c, o, e = run_cmdline("-lpython", "-fhtml", filename)

        self.assertEquals(o, output)
        self.assertEquals(e, "")
        self.assertEquals(c, 0)


if __name__ == '__main__':
    unittest.main()
# -*- coding: utf-8 -*-
"""
    Pygments tests with example files
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import unittest

from pygments import highlight
from pygments.lexers import get_lexer_for_filename, get_lexer_by_name
from pygments.token import Error
from pygments.util import ClassNotFound, b


# generate methods
def test_example_files():
    testdir = os.path.dirname(__file__)
    for fn in os.listdir(os.path.join(testdir, 'examplefiles')):
        absfn = os.path.join(testdir, 'examplefiles', fn)
        if not os.path.isfile(absfn):
            continue

        try:
            lx = get_lexer_for_filename(absfn)
        except ClassNotFound:
            if "_" not in fn:
                raise AssertionError('file %r has no registered extension, '
                                     'nor is of the form <lexer>_filename '
                                     'for overriding, thus no lexer found.'
                                    % fn)
            try:
                name, rest = fn.split("_", 1)
                lx = get_lexer_by_name(name)
            except ClassNotFound:
                raise AssertionError('no lexer found for file %r' % fn)
        yield check_lexer, lx, absfn

def check_lexer(lx, absfn):
    text = open(absfn, 'rb').read()
    text = text.strip(b('\n')) + b('\n')
    try:
        text = text.decode('utf-8')
    except UnicodeError:
        text = text.decode('latin1')
    ntext = []
    for type, val in lx.get_tokens(text):
        ntext.append(val)
        assert type != Error, 'lexer %s generated error token for %s' % \
                (lx, absfn)
    if u''.join(ntext) != text:
        raise AssertionError('round trip failed for ' + absfn)
# -*- coding: utf-8 -*-
"""
    Pygments HTML formatter tests
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import re
import unittest
import StringIO
import tempfile
from os.path import join, dirname, isfile, abspath

from pygments.lexers import PythonLexer
from pygments.formatters import HtmlFormatter, NullFormatter
from pygments.formatters.html import escape_html

import support

TESTFILE, TESTDIR = support.location(__file__)

tokensource = list(PythonLexer(encoding='utf-8').get_tokens(open(TESTFILE).read()))

class HtmlFormatterTest(unittest.TestCase):
    def test_correct_output(self):
        hfmt = HtmlFormatter(nowrap=True)
        houtfile = StringIO.StringIO()
        hfmt.format(tokensource, houtfile)

        nfmt = NullFormatter()
        noutfile = StringIO.StringIO()
        nfmt.format(tokensource, noutfile)

        stripped_html = re.sub('<.*?>', '', houtfile.getvalue())
        escaped_text = escape_html(noutfile.getvalue())
        self.assertEquals(stripped_html, escaped_text)

    def test_external_css(self):
        # test correct behavior
        # CSS should be in /tmp directory
        fmt1 = HtmlFormatter(full=True, cssfile='fmt1.css', outencoding='utf-8')
        # CSS should be in TESTDIR (TESTDIR is absolute)
        fmt2 = HtmlFormatter(full=True, cssfile=join(TESTDIR, 'fmt2.css'),
                             outencoding='utf-8')
        tfile = tempfile.NamedTemporaryFile(suffix='.html')
        fmt1.format(tokensource, tfile)
        try:
            fmt2.format(tokensource, tfile)
            self.assert_(isfile(join(TESTDIR, 'fmt2.css')))
        except IOError:
            # test directory not writable
            pass
        tfile.close()

        self.assert_(isfile(join(dirname(tfile.name), 'fmt1.css')))
        os.unlink(join(dirname(tfile.name), 'fmt1.css'))
        try:
            os.unlink(join(TESTDIR, 'fmt2.css'))
        except OSError:
            pass

    def test_all_options(self):
        for optdict in [dict(nowrap=True),
                        dict(linenos=True),
                        dict(linenos=True, full=True),
                        dict(linenos=True, full=True, noclasses=True)]:

            outfile = StringIO.StringIO()
            fmt = HtmlFormatter(**optdict)
            fmt.format(tokensource, outfile)

    def test_valid_output(self):
        # test all available wrappers
        fmt = HtmlFormatter(full=True, linenos=True, noclasses=True,
                            outencoding='utf-8')

        handle, pathname = tempfile.mkstemp('.html')
        tfile = os.fdopen(handle, 'w+b')
        fmt.format(tokensource, tfile)
        tfile.close()
        catname = os.path.join(TESTDIR, 'dtds', 'HTML4.soc')
        try:
            try:
                import subprocess
                ret = subprocess.Popen(['nsgmls', '-s', '-c', catname, pathname],
                                       stdout=subprocess.PIPE).wait()
            except ImportError:
                # Python 2.3 - no subprocess module
                ret = os.popen('nsgmls -s -c "%s" "%s"' % (catname, pathname)).close()
                if ret == 32512: raise OSError  # not found
        except OSError:
            # nsgmls not available
            pass
        else:
            self.failIf(ret, 'nsgmls run reported errors')

        os.unlink(pathname)

    def test_get_style_defs(self):
        fmt = HtmlFormatter()
        sd = fmt.get_style_defs()
        self.assert_(sd.startswith('.'))

        fmt = HtmlFormatter(cssclass='foo')
        sd = fmt.get_style_defs()
        self.assert_(sd.startswith('.foo'))
        sd = fmt.get_style_defs('.bar')
        self.assert_(sd.startswith('.bar'))
        sd = fmt.get_style_defs(['.bar', '.baz'])
        fl = sd.splitlines()[0]
        self.assert_('.bar' in fl and '.baz' in fl)

    def test_unicode_options(self):
        fmt = HtmlFormatter(title=u'Föö',
                            cssclass=u'bär',
                            cssstyles=u'div:before { content: \'bäz\' }',
                            encoding='utf-8')
        handle, pathname = tempfile.mkstemp('.html')
        tfile = os.fdopen(handle, 'w+b')
        fmt.format(tokensource, tfile)
        tfile.close()
# -*- coding: utf-8 -*-
"""
    Pygments LaTeX formatter tests
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import os
import unittest
import tempfile

from pygments.formatters import LatexFormatter
from pygments.lexers import PythonLexer

import support

TESTFILE, TESTDIR = support.location(__file__)


class LatexFormatterTest(unittest.TestCase):

    def test_valid_output(self):
        tokensource = list(PythonLexer().get_tokens(open(TESTFILE).read()))
        fmt = LatexFormatter(full=True, encoding='latin1')

        handle, pathname = tempfile.mkstemp('.tex')
        # place all output files in /tmp too
        old_wd = os.getcwd()
        os.chdir(os.path.dirname(pathname))
        tfile = os.fdopen(handle, 'wb')
        fmt.format(tokensource, tfile)
        tfile.close()
        try:
            try:
                import subprocess
                ret = subprocess.Popen(['latex', '-interaction=nonstopmode',
                                        pathname],
                                       stdout=subprocess.PIPE).wait()
            except ImportError:
                # Python 2.3 - no subprocess module
                ret = os.popen('latex -interaction=nonstopmode "%s"'
                               % pathname).close()
                if ret == 32512: raise OSError  # not found
        except OSError:
            # latex not available
            pass
        else:
            self.failIf(ret, 'latex run reported errors')

        os.unlink(pathname)
        os.chdir(old_wd)
# -*- coding: utf-8 -*-
"""
    Pygments regex lexer tests
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import unittest

from pygments.token import Text
from pygments.lexer import RegexLexer

class TestLexer(RegexLexer):
    """Test tuple state transitions including #pop."""
    tokens = {
        'root': [
            ('a', Text.Root, 'rag'),
            ('e', Text.Root),
        ],
        'beer': [
            ('d', Text.Beer, ('#pop', '#pop')),
        ],
        'rag': [
            ('b', Text.Rag, '#push'),
            ('c', Text.Rag, ('#pop', 'beer')),
        ],
    }

class TupleTransTest(unittest.TestCase):
    def test(self):
        lx = TestLexer()
        toks = list(lx.get_tokens_unprocessed('abcde'))
        self.assertEquals(toks,
           [(0, Text.Root, 'a'), (1, Text.Rag, 'b'), (2, Text.Rag, 'c'),
            (3, Text.Beer, 'd'), (4, Text.Root, 'e')])
# -*- coding: utf-8 -*-
"""
    Test suite for the token module
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import unittest
import StringIO
import sys

from pygments import token


class TokenTest(unittest.TestCase):

    def test_tokentype(self):
        e = self.assertEquals
        r = self.assertRaises

        t = token.String

        e(t.split(), [token.Token, token.Literal, token.String])

        e(t.__class__, token._TokenType)

    def test_functions(self):
        self.assert_(token.is_token_subtype(token.String, token.String))
        self.assert_(token.is_token_subtype(token.String, token.Literal))
        self.failIf(token.is_token_subtype(token.Literal, token.String))

        self.assert_(token.string_to_tokentype(token.String) is token.String)
        self.assert_(token.string_to_tokentype('') is token.Token)
        self.assert_(token.string_to_tokentype('String') is token.String)

    def test_sanity_check(self):
        stp = token.STANDARD_TYPES.copy()
        stp[token.Token] = '---' # Token and Text do conflict, that is okay
        t = {}
        for k, v in stp.iteritems():
            t.setdefault(v, []).append(k)
        if len(t) == len(stp):
            return # Okay

        for k, v in t.iteritems():
            if len(v) > 1:
                self.fail("%r has more than one key: %r" % (k, v))


if __name__ == '__main__':
    unittest.main()
import unittest
from pygments.lexer import using, bygroups, this, RegexLexer
from pygments.token import String, Text, Keyword

class TestLexer(RegexLexer):
    tokens = {
        'root': [
            (r'#.*', using(this, state='invalid')),
            (r'(")(.+?)(")', bygroups(String, using(this, state='string'), String)),
            (r'[^"]+', Text),
        ],
        'string': [
            (r'.+', Keyword),
        ],
    }

class UsingStateTest(unittest.TestCase):
    def test_basic(self):
        expected = [(Text, 'a'), (String, '"'), (Keyword, 'bcd'),
                    (String, '"'), (Text, 'e\n')]
        t = list(TestLexer().get_tokens('a"bcd"e'))
        self.assertEquals(t, expected)
    def test_error(self):
        def gen():
            x = list(TestLexer().get_tokens('#a'))
        #XXX: should probably raise a more specific exception if the state
        #     doesn't exist.
        self.assertRaises(Exception, gen)

if __name__ == "__main__":
    unittest.main()
# -*- coding: utf-8 -*-
"""
    Test suite for the util module
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    :copyright: Copyright 2006-2009 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import unittest
import os

from pygments import util


class UtilTest(unittest.TestCase):

    def test_getoptions(self):
        raises = self.assertRaises
        equals = self.assertEquals

        equals(util.get_bool_opt({}, 'a', True), True)
        equals(util.get_bool_opt({}, 'a', 1), True)
        equals(util.get_bool_opt({}, 'a', 'true'), True)
        equals(util.get_bool_opt({}, 'a', 'no'), False)
        raises(util.OptionError, util.get_bool_opt, {}, 'a', [])
        raises(util.OptionError, util.get_bool_opt, {}, 'a', 'foo')

        equals(util.get_int_opt({}, 'a', 1), 1)
        raises(util.OptionError, util.get_int_opt, {}, 'a', [])
        raises(util.OptionError, util.get_int_opt, {}, 'a', 'bar')

        equals(util.get_list_opt({}, 'a', [1]), [1])
        equals(util.get_list_opt({}, 'a', '1 2'), ['1', '2'])
        raises(util.OptionError, util.get_list_opt, {}, 'a', 1)


    def test_docstring_headline(self):
        def f1():
            """
            docstring headline

            other text
            """
        def f2():
            """
            docstring
            headline

            other text
            """

        self.assertEquals(util.docstring_headline(f1), "docstring headline")
        self.assertEquals(util.docstring_headline(f2), "docstring headline")

    def test_analysator(self):
        class X(object):
            def analyse(text):
                return 0.5
            analyse = util.make_analysator(analyse)
        self.assertEquals(X.analyse(''), 0.5)

    def test_shebang_matches(self):
        self.assert_(util.shebang_matches('#!/usr/bin/env python', r'python(2\.\d)?'))
        self.assert_(util.shebang_matches('#!/usr/bin/python2.4', r'python(2\.\d)?'))
        self.assert_(util.shebang_matches('#!/usr/bin/startsomethingwith python',
                                          r'python(2\.\d)?'))
        self.assert_(util.shebang_matches('#!C:\\Python2.4\\Python.exe',
                                          r'python(2\.\d)?'))

        self.failIf(util.shebang_matches('#!/usr/bin/python-ruby', r'python(2\.\d)?'))
        self.failIf(util.shebang_matches('#!/usr/bin/python/ruby', r'python(2\.\d)?'))
        self.failIf(util.shebang_matches('#!', r'python'))

    def test_doctype_matches(self):
        self.assert_(util.doctype_matches('<!DOCTYPE html PUBLIC "a"> <html>',
                                          'html.*'))
        self.failIf(util.doctype_matches('<?xml ?> <DOCTYPE html PUBLIC "a"> <html>',
                                         'html.*'))
        self.assert_(util.html_doctype_matches(
            '<?xml ?><!DOCTYPE html PUBLIC  "-//W3C//DTD XHTML 1.0 Strict//EN">'))

    def test_xml(self):
        self.assert_(util.looks_like_xml(
            '<?xml ?><!DOCTYPE html PUBLIC  "-//W3C//DTD XHTML 1.0 Strict//EN">'))
        self.assert_(util.looks_like_xml('<html xmlns>abc</html>'))
        self.failIf(util.looks_like_xml('<html>'))

if __name__ == '__main__':
    unittest.main()
