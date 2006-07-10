# This goes to /lib/ruby/1.8/rdoc/generators/template/html/
module RDoc::Page

FONTS = "Tahoma, Verdana, sans-serif"

require 'rake_helpers/ca.rb'

Hy.ca <<CA
<<
	BACKGROUND = '#322'

	GOLD = '#e92'
	DARK_GOLD = '#630'
	FIRE = '#fc3'
	MORE_FIRE = '#fe0'
	LIGHT_BLUE = '#CCF'
	DARK_BLUE = '#004'
	FLARE = LIGHT_BLUE
	DARK_GRAY = '#444'
	PURPLE = '#d8f'
	DARK_PURPLE = '#303'

	LINK = LIGHT_BLUE
	VISITED = '#ccc'
	HOVER = '#f44'

	BORDER = '3px double gray'
>>
CA

require 'coderay'

STYLE = Hy.ca <<CSS + CodeRay::Encoders[:html]::CSS.new.stylesheet
a { text-decoration: none; }
a:link { color: $LINK }
a:visited { color: $VISITED }
a:hover, a:active, a:focus { color: $HOVER }

body {
  background-color: $BACKGROUND;
  color: $GOLD;
  margin: 0px;
  font-family: %fonts%;
}

img { border: $BORDER; }

hr {
	background-color: none; color: none;
	height: 3px;
	border: 1px solid gray;
	margin: 0.5em 0em;
	padding: 0px;
}

tt { color: $LIGHT_BLUE; font-size: 1em; }

.sectiontitle {
	font-size: 1.2em;
	font-weight: bold;
	font-color: white;
	border: $BORDER;
	padding: 0.2em;
	margin: 1em auto; margin-top: 3em;
	text-align: center;
	width: 75%;
	background-color: $DARK_BLUE;
}

.attr-rw {
  padding-left: 1em;
  padding-right: 1em;
  text-align: center;
  color: silver;
}

.attr-name {
  font-weight: bold;
}

.attr-desc {
}

.attr-value {
  font-family: monospace;
	color: $LIGHT_BLUE;
	font-size: 1em;
}

.banner {
	border-collapse: collapse;
  font-size: small;
  background: $DARK_PURPLE;
  color: silver;
  border: 0px;
  border-bottom: $BORDER;
  padding: 0.5em;
  margin-bottom: 1em;
}
.xbanner table { border-collapse: collapse; }

.banner td {
  color: silver;
	background-color: transparent;
	padding: 0.2em 0.5em;
}
.banner td.ruby-chan {
	vertical-align: bottom;
	padding: 0px;
	width: 1px;
}

.file-title-prefix { }

td.file-title {
  font-size: 140%;
  font-weight: bold;
  color: $PURPLE;
}

.dyn-source {
  display: none;
  margin: 0.5em;
}

.method {
  margin-left: 1em;
  margin-right: 1em;
  margin-bottom: 1em;
  border: 1px solid white;
	color: $MORE_FIRE;
	background: $DARK_PURPLE;
}

.description pre {
	border: 1px solid gray;
	background: $DARK_BLUE;
	color: white;
	padding: 0.5em;
}

.method .title {
  font-family: monospace;
  font-size: larger;
  color: $PURPLE;
  background: $DARK_GRAY;
  border-bottom: $BORDER;
  margin: 0px; padding: 0.1em 0.5em;
}

.method .description, .method .sourcecode {
  margin: 0.2em 1em;
}
.method p {
	color: $GOLD;
}

.description p, .sourcecode p {
  margin-bottom: 0.5em;
}

.method .sourcecode p.source-link {
  margin-top: 0.5em;
  font-style: normal;
}
.arrow { font-size: larger; }

.method .aka {
  margin-top: 0.3em;
  margin-left: 1em;
  color: $FIRE;
}

#content {
  margin: 2em; margin-top: 0px;
}

#description p {
  margin-bottom: 0.5em;
}

h1 {
	font-size: 1.5em;
	font-weight: bold;
	color: $FLARE;
	border: $BORDER;
	padding: 0.25em;
	margin: 1em auto;
	text-align: center;
	width: 33%;
	background-color: $DARK_BLUE;
}
h1 a:link, h1 a:visited { color: $FLARE }

h2 {
	margin-bottom: 0.5em;
	margin-top: 2em;
  font-size: 1.2em;
  font-weight: bold;
  color: $FIRE;
}

h3, h4, h5, h6 {
	margin-bottom: 0.4em;
	margin-top: 1.5em;
	padding: 0px;
  border: 0px;
  color: $FIRE;
  font-size: 1em;
}

.sourcecode > pre {
	border: 1px solid silver;
	background: #112;
	color: white;
	padding: 0.5em;
}
CSS

XHTML_FRAMESET_PREAMBLE = #<?xml version="1.0" encoding="%charset%"?>
%{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
}

XHTML_PREAMBLE =
%{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
}

HEADER = XHTML_PREAMBLE + <<ENDHEADER
<html>
  <head>
    <title>%title%</title>
    <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
    <link rel="stylesheet" href="%style_url%" type="text/css" media="screen" />

    <script language="JavaScript" type="text/javascript">
    // <![CDATA[

        function toggleSource( id )
        {
          var elem
          var link

          if( document.getElementById )
          {
            elem = document.getElementById( id )
            link = document.getElementById( "l_" + id )
          }
          else if ( document.all )
          {
            elem = eval( "document.all." + id )
            link = eval( "document.all.l_" + id )
          }
          else
            return false;

          if( elem.style.display == "block" )
          {
            elem.style.display = "none"
            link.innerHTML = "show source"
          }
          else
          {
            elem.style.display = "block"
            link.innerHTML = "hide source"
          }
        }

        function openCode( url )
        {
          window.open( url, "SOURCE_CODE", "width=400,height=400,scrollbars=yes" )
        }
      // ]]>
    </script>
  </head>

  <body>
ENDHEADER

FILE_PAGE = <<HTML
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="banner">
  <tr><td>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td class="file-title" colspan="2"><span class="file-title-prefix">File</span> %short_name%</td>
		</tr>
    <tr>
    	<td>
        <table border="0" cellspacing="0" cellpadding="2">
          <tr>
            <td>Path:</td>
            <td>%full_path%
IF:cvsurl
				&nbsp;(<a href="%cvsurl%">CVS</a>)
ENDIF:cvsurl
            </td>
          </tr>
          <tr>
            <td>Modified:</td>
            <td>%dtm_modified%</td>
          </tr>
        </table>
      </td></tr>
    </table>
  </td>
  <td class="ruby-chan">
	  <a href="http://ruby.cYcnus.de"><img src="http://ruby.cYcnus.de/pics/ruby-doc-chan.gif" alt="Ruby-Chan" style="border: 0px" /></a>
  </td>
 </tr>
</table><br />
HTML

###################################################################

CLASS_PAGE = <<HTML
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="banner">
	<tr>
  	<td class="file-title"><span class="file-title-prefix">%classmod%</span> %full_name%</td>
		<td rowspan="2" class="ruby-chan">
			<a href="http://ruby.cYcnus.de"><img src="http://ruby.cYcnus.de/pics/ruby-doc-chan.gif" alt="Ruby-Chan" style="border: 0px" /></a>
		</td>
	</tr>
	<tr>
 	 <td>
    <table cellspacing="0" cellpadding="2">
      <tr valign="top">
        <td>In:</td>
        <td>
START:infiles
HREF:full_path_url:full_path:
IF:cvsurl
&nbsp;(<a href="%cvsurl%">CVS</a>)
ENDIF:cvsurl
END:infiles
        </td>
      </tr>
IF:parent
    <tr>
      <td>Parent:</td>
      <td>
IF:par_url
        <a href="%par_url%">
ENDIF:par_url
%parent%
IF:par_url
         </a>
ENDIF:par_url
     </td>
   </tr>
ENDIF:parent
         </table>
        </td>
        </tr>
      </table>
HTML

###################################################################

METHOD_LIST = <<HTML
  <div id="content">
IF:diagram
  <table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td align="center">
    %diagram%
  </td></tr></table>
ENDIF:diagram

IF:description
  <div class="description">%description%</div>
ENDIF:description

IF:requires
  <div class="sectiontitle">Required Files</div>
  <ul>
START:requires
  <li>HREF:aref:name:</li>
END:requires
  </ul>
ENDIF:requires

IF:toc
  <div class="sectiontitle">Contents</div>
  <ul>
START:toc
  <li><a href="#%href%">%secname%</a></li>
END:toc
  </ul>
ENDIF:toc

IF:methods
  <div class="sectiontitle">Methods</div>
  <ul>
START:methods
  <li>HREF:aref:name:</li>
END:methods
  </ul>
ENDIF:methods

IF:includes
<div class="sectiontitle">Included Modules</div>
<ul>
START:includes
  <li>HREF:aref:name:</li>
END:includes
</ul>
ENDIF:includes

START:sections
IF:sectitle
<div class="sectiontitle"><a nem="%secsequence%">%sectitle%</a></div>
IF:seccomment
<div class="description">
%seccomment%
</div>
ENDIF:seccomment
ENDIF:sectitle

IF:classlist
  <div class="sectiontitle">Classes and Modules</div>
  %classlist%
ENDIF:classlist

IF:constants
  <div class="sectiontitle">Constants</div>
  <table border="0" cellpadding="5">
START:constants
  <tr valign="top">
    <td class="attr-name">%name%</td>
    <td>=</td>
    <td class="attr-value">%value%</td>
  </tr>
IF:desc
  <tr valign="top">
    <td>&nbsp;</td>
    <td colspan="2" class="attr-desc">%desc%</td>
  </tr>
ENDIF:desc
END:constants
  </table>
ENDIF:constants

IF:attributes
  <div class="sectiontitle">Attributes</div>
  <table border="0" cellpadding="5">
START:attributes
  <tr valign="top">
    <td class="attr-rw">
IF:rw
[%rw%]
ENDIF:rw
    </td>
    <td class="attr-name">%name%</td>
    <td class="attr-desc">%a_desc%</td>
  </tr>
END:attributes
  </table>
ENDIF:attributes

IF:method_list
START:method_list
IF:methods
<div class="sectiontitle">%type% %category% methods</div>
START:methods
<div class="method">
  <div class="title">
IF:callseq
    <a name="%aref%"></a><b>%callseq%</b>
ENDIF:callseq
IFNOT:callseq
    <a name="%aref%"></a><b>%name%</b>%params%
ENDIF:callseq
IF:codeurl
[ <a href="javascript:openCode("%codeurl%")">source</a> ]
ENDIF:codeurl
  </div>
IF:m_desc
  <div class="description">
  %m_desc%
  </div>
ENDIF:m_desc
IF:aka
<div class="aka">
  --- This method is also aliased as
START:aka
  <a href="%aref%">%name%</a>
END:aka
  ---
</div>
ENDIF:aka
IF:sourcecode
<div class="sourcecode">
  <p class="source-link"><span class="arrow">&rarr;</span> <a href="javascript:toggleSource('%aref%_source')" id="l_%aref%_source">show source</a></p>
  <div id="%aref%_source" class="dyn-source">
%sourcecode%
  </div>
</div>
ENDIF:sourcecode
</div>
END:methods
ENDIF:methods
END:method_list
ENDIF:method_list
END:sections
</div>
HTML

FOOTER = <<ENDFOOTER
  </body>
</html>
ENDFOOTER

BODY = HEADER + <<ENDBODY
  !INCLUDE! <!-- banner header -->

  <div id="bodyContent">
    #{METHOD_LIST}
  </div>

  #{FOOTER}
ENDBODY

########################## Source code ##########################

SRC_PAGE = XHTML_PREAMBLE + <<HTML
<html>
<head><title>%title%</title>
<meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
<style type="text/css">
.ruby-comment    { color: green; font-style: italic }
.ruby-constant   { color: #4433aa; font-weight: bold; }
.ruby-identifier { color: #222222;  }
.ruby-ivar       { color: #2233dd; }
.ruby-keyword    { color: #3333FF; font-weight: bold }
.ruby-node       { color: #777777; }
.ruby-operator   { color: #111111;  }
.ruby-regexp     { color: #662222; }
.ruby-value      { color: #662222; font-style: italic }
  .kw { color: #3333FF; font-weight: bold }
  .cmt { color: green; font-style: italic }
  .str { color: #662222; font-style: italic }
  .re  { color: #662222; }
</style>
</head>
<body bgcolor="white">
<pre>%code%</pre>
</body>
</html>
HTML

########################## Index ################################

FR_INDEX_BODY = <<HTML
!INCLUDE!
HTML

FILE_INDEX = XHTML_PREAMBLE + <<HTML
<html>
<head><title>List</title>
<meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
<style type="text/css">
<!--
#{ Hy.ca <<CA
  body {
    background-color: $DARK_PURPLE;
    font-family: #{FONTS};
    color: white;
    margin: 0px;
  }
  .banner {
    background: $DARK_BLUE;
    color: $GOLD;
    padding: 0em 0.2em;
    border-bottom: $BORDER;
    font-size: smaller;
    font-weight: bold;
    text-align: center;
  }
  .entries {
    margin: 0.25em 0em 0em 0.5em;
    font-size: 75%;
  }
  a { text-decoration: none; white-space: nowrap; }
  a:link { color: $LINK; }
  a:visited { color: $VISITED; }
  a:hover, a:active, a:focus { color: $HOVER; }
CA
}
-->
</style>
<base target="docwin" />
</head>
<body>
<div class="banner">%list_title%</div>
<div class="entries">
START:entries
<a href="%href%">%name%</a><br />
END:entries
</div>
</body></html>
HTML

CLASS_INDEX = FILE_INDEX
METHOD_INDEX = FILE_INDEX

INDEX = XHTML_FRAMESET_PREAMBLE + <<HTML
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title>%title%</title>
  <meta http-equiv="Content-Type" content="text/html; charset=%charset%" />
</head>

<frameset cols="20%,*">
    <frameset rows="15%,35%,50%">
        <frame src="fr_file_index.html"   title="Files" name="Files" />
        <frame src="fr_class_index.html"  name="Classes" />
        <frame src="fr_method_index.html" name="Methods" />
    </frameset>
IF:inline_source
      <frame  src="%initial_page%" name="docwin" />
ENDIF:inline_source
IFNOT:inline_source
    <frameset rows="80%,20%">
      <frame  src="%initial_page%" name="docwin" />
      <frame  src="blank.html" name="source" />
    </frameset>
ENDIF:inline_source
    <noframes>
          <body bgcolor="white">
            Click <a href="html/index.html">here</a> for a non-frames
            version of this page.
          </body>
    </noframes>
</frameset>

</html>
HTML

end
