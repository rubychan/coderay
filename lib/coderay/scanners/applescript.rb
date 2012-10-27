#  Scanner for AppleScript Created by Sebastian Yepes F.
#    Web:     http://sebastian.yepes.in
#    e-Mail:  sebastian@yepes.in

module CodeRay
module Scanners
  
  class AppleScript < Scanner

    register_for :applescript
    
    RESERVED_WORDS = [
      '#include', 'for', 'foreach', 'if', 'elseif', 'else', 'while', 'do', 'dowhile', 'end',
      'switch', 'case', 'return', 'break', 'continue', 'in', 'to', 'of', 'repeat', 'tell', 'then','as'
    ]

    KEYWORD_OPERATOR = [
      'is greater than', 'comes after', 'is less than', 'comes before',
      'is greater than or equal to', 'is less than or equal to', 'is equal to',
      'is', 'is not equal to', 'is not', 'contains', 'does not contain', 'is in',
      'is not in', 'starts with', 'ends with'
      ]


    DIRECTIVES = [
			'activate', '#endinitclip', '#initclip', '__proto__', '_accProps', '_alpha', '_currentframe',
			'_droptarget', '_focusrect', '_framesloaded', '_height', '_highquality', '_lockroot',
			'_name', '_parent', '_quality', '_root', '_rotation', '_soundbuftime', '_target', '_totalframes',
			'_url', '_visible', '_width', '_x', '_xmouse', '_xscale', '_y', '_ymouse', '_yscale', 'abs',
			'Accessibility', 'acos', 'activityLevel', 'add', 'addListener', 'addPage', 'addProperty',
			'addRequestHeader', 'align', 'allowDomain', 'allowInsecureDomain', 'and', 'appendChild',
			'apply', 'Arguments', 'Array', 'asfunction', 'asin', 'atan', 'atan2', 'attachAudio', 'attachMovie',
			'attachSound', 'attachVideo', 'attributes', 'autosize', 'avHardwareDisable', 'background',
			'backgroundColor', 'BACKSPACE', 'bandwidth', 'beginFill', 'beginGradientFill', 'blockIndent',
			'bold', 'Boolean', 'border', 'borderColor', 'bottomScroll', 'bufferLength', 'bufferTime',
			'builtInItems', 'bullet', 'Button', 'bytesLoaded', 'bytesTotal', 'call', 'callee', 'caller',
			'Camera', 'capabilities', 'CAPSLOCK', 'caption', 'catch', 'ceil', 'charAt', 'charCodeAt',
			'childNodes', 'chr', 'clear', 'clearInterval', 'cloneNode', 'close', 'Color', 'concat',
			'connect', 'condenseWhite', 'constructor', 'contentType', 'ContextMenu', 'ContextMenuItem',
			'CONTROL', 'copy', 'cos', 'createElement', 'createEmptyMovieClip', 'createTextField',
			'createTextNode', 'currentFps', 'curveTo', 'CustomActions', 'customItems', 'data', 'Date',
			'deblocking', 'delete', 'DELETEKEY', 'docTypeDecl', 'domain', 'DOWN',
			'duplicateMovieClip', 'duration', 'dynamic', 'E', 'embedFonts', 'enabled',
			'endFill', 'ENTER', 'eq', 'Error', 'ESCAPE(Konstante)', 'escape(Funktion)', 'eval',
			'exactSettings', 'exp', 'extends', 'finally', 'findText', 'firstChild', 'floor',
			'flush', 'focusEnabled', 'font', 'fps', 'fromCharCode', 'fscommand',
			'gain', 'ge', 'get', 'getAscii', 'getBeginIndex', 'getBounds', 'getBytesLoaded', 'getBytesTotal',
			'getCaretIndex', 'getCode', 'getCount', 'getDate', 'getDay', 'getDepth', 'getEndIndex', 'getFocus',
			'getFontList', 'getFullYear', 'getHours', 'getInstanceAtDepth', 'getLocal', 'getMilliseconds',
			'getMinutes', 'getMonth', 'getNewTextFormat', 'getNextHighestDepth', 'getPan', 'getProgress',
			'getProperty', 'getRGB', 'getSeconds', 'getSelected', 'getSelectedText', 'getSize', 'getStyle',
			'getStyleNames', 'getSWFVersion', 'getText', 'getTextExtent', 'getTextFormat', 'getTextSnapshot',
			'getTime', 'getTimer', 'getTimezoneOffset', 'getTransform', 'getURL', 'getUTCDate', 'getUTCDay',
			'getUTCFullYear', 'getUTCHours', 'getUTCMilliseconds', 'getUTCMinutes', 'getUTCMonth', 'getUTCSeconds',
			'getVersion', 'getVolume', 'getYear', 'globalToLocal', 'goto', 'gotoAndPlay', 'gotoAndStop',
			'hasAccessibility', 'hasAudio', 'hasAudioEncoder', 'hasChildNodes', 'hasEmbeddedVideo', 'hasMP3',
			'hasPrinting', 'hasScreenBroadcast', 'hasScreenPlayback', 'hasStreamingAudio', 'hasStreamingVideo',
			'hasVideoEncoder', 'height', 'hide', 'hideBuiltInItems', 'hitArea', 'hitTest', 'hitTestTextNearPos',
			'HOME', 'hscroll', 'html', 'htmlText', 'ID3', 'ifFrameLoaded', 'ignoreWhite', 'implements',
			'import', 'indent', 'index', 'indexOf', 'Infinity', '-Infinity', 'INSERT', 'insertBefore', 'install',
			'instanceof', 'int', 'interface', 'isActive', 'isDebugger', 'isDown', 'isFinite', 'isNaN', 'isToggled',
			'italic', 'join', 'Key', 'language', 'lastChild', 'lastIndexOf', 'le', 'leading', 'LEFT', 'leftMargin',
			'length', 'level', 'lineStyle', 'lineTo', 'list', 'LN10', 'LN2', 'load', 'loadClip', 'loaded', 'loadMovie',
			'loadMovieNum', 'loadSound', 'loadVariables', 'loadVariablesNum', 'LoadVars', 'LocalConnection',
			'localFileReadDisable', 'localToGlobal', 'log', 'LOG10E', 'LOG2E', 'manufacturer', 'Math', 'max',
			'MAX_VALUE', 'maxChars', 'maxhscroll', 'maxscroll', 'mbchr', 'mblength', 'mbord', 'mbsubstring', 'menu',
			'message', 'Microphone', 'min', 'MIN_VALUE', 'MMExecute', 'motionLevel', 'motionTimeOut', 'Mouse',
			'mouseWheelEnabled', 'moveTo', 'Movieclip', 'MovieClipLoader', 'multiline', 'muted', 'name', 'names', 'NaN',
			'ne', 'NEGATIVE_INFINITY', 'NetConnection', 'NetStream', 'newline', 'nextFrame',
			'nextScene', 'nextSibling', 'nodeName', 'nodeType', 'nodeValue', 'not', 'Number', 'Object',
			'on', 'onActivity', 'onChanged', 'onClipEvent', 'onClose', 'onConnect', 'onData', 'onDragOut',
			'onDragOver', 'onEnterFrame', 'onID3', 'onKeyDown', 'onKeyUp', 'onKillFocus', 'onLoad', 'onLoadComplete',
			'onLoadError', 'onLoadInit', 'onLoadProgress', 'onLoadStart', 'onMouseDown', 'onMouseMove', 'onMouseUp',
			'onMouseWheel', 'onPress', 'onRelease', 'onReleaseOutside', 'onResize', 'onRollOut', 'onRollOver',
			'onScroller', 'onSelect', 'onSetFocus', 'onSoundComplete', 'onStatus', 'onUnload', 'onUpdate', 'onXML',
			'or(logischesOR)', 'ord', 'os', 'parentNode', 'parseCSS', 'parseFloat', 'parseInt', 'parseXML', 'password',
			'pause', 'PGDN', 'PGUP', 'PI', 'pixelAspectRatio', 'play', 'playerType', 'pop', 'position',
			'POSITIVE_INFINITY', 'pow', 'prevFrame', 'previousSibling', 'prevScene', 'print', 'printAsBitmap',
			'printAsBitmapNum', 'PrintJob', 'printNum', 'private', 'prototype', 'public', 'push', 'quality',
			'random', 'rate', 'registerClass', 'removeListener', 'removeMovieClip', 'removeNode', 'removeTextField',
			'replaceSel', 'replaceText', 'resolutionX', 'resolutionY', 'restrict', 'reverse', 'RIGHT',
			'rightMargin', 'round', 'scaleMode', 'screenColor', 'screenDPI', 'screenResolutionX', 'screenResolutionY',
			'scroll', 'seek', 'selectable', 'Selection', 'send', 'sendAndLoad', 'separatorBefore', 'serverString',
			'set', 'setvariable', 'setBufferTime', 'setClipboard', 'setDate', 'setFocus', 'setFullYear', 'setGain',
			'setHours', 'setInterval', 'setMask', 'setMilliseconds', 'setMinutes', 'setMode', 'setMonth',
			'setMotionLevel', 'setNewTextFormat', 'setPan', 'setProperty', 'setQuality', 'setRate', 'setRGB',
			'setSeconds', 'setSelectColor', 'setSelected', 'setSelection', 'setSilenceLevel', 'setStyle',
			'setTextFormat', 'setTime', 'setTransform', 'setUseEchoSuppression', 'setUTCDate', 'setUTCFullYear',
			'setUTCHours', 'setUTCMilliseconds', 'setUTCMinutes', 'setUTCMonth', 'setUTCSeconds', 'setVolume',
			'setYear', 'SharedObject', 'SHIFT(Konstante)', 'shift(Methode)', 'show', 'showMenu', 'showSettings',
			'silenceLevel', 'silenceTimeout', 'sin', 'size', 'slice', 'smoothing', 'sort', 'sortOn', 'Sound', 'SPACE',
			'splice', 'split', 'sqrt', 'SQRT1_2', 'SQRT2', 'Stage', 'start', 'startDrag', 'static', 'status', 'stop',
			'stopAllSounds', 'stopDrag', 'StyleSheet(Klasse)', 'styleSheet(Eigenschaft)', 'substr',
			'substring', 'super', 'swapDepths', 'System', 'TAB', 'tabChildren', 'tabEnabled', 'tabIndex',
			'tabStops', 'tan', 'target', 'targetPath', 'tellTarget', 'text', 'textColor', 'TextField', 'TextFormat',
			'textHeight', 'TextSnapshot', 'textWidth', 'this', 'throw', 'time', 'toggleHighQuality', 'toLowerCase',
			'toString', 'toUpperCase', 'trace', 'trackAsMenu', 'try', 'type', 'typeof', 'undefined',
			'underline', 'unescape', 'uninstall', 'unloadClip', 'unloadMovie', 'unLoadMovieNum', 'unshift', 'unwatch',
			'UP', 'updateAfterEvent', 'updateProperties', 'url', 'useCodePage', 'useEchoSuppression', 'useHandCursor',
			'UTC', 'valueOf', 'variable', 'version', 'Video', 'visible', 'void', 'watch', 'width',
			'with', 'wordwrap', 'XML', 'xmlDecl', 'XMLNode', 'XMLSocket'
    ]
    
    PREDEFINED_TYPES = [
      'boolean', 'small integer', 'integer', 'double integer', 
      'small real', 'real', 'date','list', 'record', 'string', 'class'
    ]

    PREDEFINED_CONSTANTS = [
      'pi', 'true', 'false',
      'application responses', 'case', 'diacriticals', 'expansion', 'hyphens', 'punctuation', 'white space',
      'seconds', 'minutes', 'hours', 'days', 'weeks',
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      'anything', 'current application', 'it', 'me', 'missing value', 'my', 'result',
      'yes', 'no', 'ask',
      'return', 'space', 'tab',
      'all caps', 'all lowercase', 'bold', 'condensed', 'expanded', 'hidden', 'italic', 'outline', 'plain', 'shadow', 'small caps', 'strikethrough', 'subscript', 'superscript', 'underline',
      'version'
    ]
    
    PLAIN_STRING_CONTENT = {
      "'" => /[^'\n]+/,
      '"' => /[^"\n]+/,
    }
    
    
    IDENT_KIND = CaseIgnoringWordList.new(:ident).
      add(RESERVED_WORDS, :reserved).
      add(KEYWORD_OPERATOR, :operator).
      add(DIRECTIVES, :directive).
      add(PREDEFINED_TYPES, :pre_type).
      add(PREDEFINED_CONSTANTS, :pre_constant)
      
      

    def scan_tokens tokens, options

      state = :initial
      plain_string_content = @plain_string_content

      until eos?

        kind = nil
        match = nil

        if state == :initial
          
          if scan(/\s+/x)
            kind = :space
            
          elsif scan(%r! \{ \$ [^}]* \}? | \(\* \$ (?: .*? \*\) | .* ) !mx)
            kind = :preprocessor
            
          elsif scan(/^[\s\t]*--.*/x)
            kind = :comment
          elsif scan(/\(\* (?: .*? \*\)$ | .* )/mx)
            kind = :comment
            
          elsif scan(/ [-+*\/=<>:;,.@\^|\(\)\[\]]+ /x)
            kind = :operator
            
          elsif match = scan(/ [A-Za-z_][A-Za-z_0-9]* /x)
            kind = IDENT_KIND[match]
            
          elsif match = scan(/ ' ( [^\n']|'' ) (?:'|$) /x)
            tokens << [:open, :char]
            tokens << ["'", :delimiter]
            tokens << [self[1], :content]
            tokens << ["'", :delimiter]
            tokens << [:close, :char]
            next
            
          elsif match = scan(/["']/)
            tokens << [:open, :string]
            state = :string
            plain_string_content = PLAIN_STRING_CONTENT[match]
            kind = :delimiter
            
          else
            kind = :plain
            getch

          end
          
        elsif state == :string
            if scan(plain_string_content)
              kind = :content
            elsif scan(/['"]/)
              tokens << [matched, :delimiter]
              tokens << [:close, :string]
              state = :initial
              next
            elsif scan(/ \\ | $ /x)
              tokens << [:close, :string]
              kind = :error
              state = :initial
            end

          else
            raise_inspect "else case \" reached; %p not handled." % peek(1), tokens
          end
        
        match ||= matched
        if $DEBUG and not kind
          raise_inspect 'Error token %p in line %d' %
            [[match, kind], line], tokens
        end
        raise_inspect 'Empty token', tokens unless match
        tokens << [match, kind]
        
      end
      tokens
    end

  end

end
end