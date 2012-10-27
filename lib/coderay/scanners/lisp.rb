# By Nathan Weizenbaum (http://nex3.leeweiz.net)
# MIT License (http://www.opensource.org/licenses/mit-license.php)
#
# CodeRay scanner for Lisp.
# The keywords are mostly geared towards Emacs Lisp,
# but it should work fine for Common Lisp
# and reasonably well for Scheme.

require 'rubygems'
require 'coderay'

module CodeRay::Scanners
  class Lisp < Scanner
    register_for :lisp

    NON_SYMBOL_CHARS = '();\s\[\]'
    SYMBOL_RE = /[^#{NON_SYMBOL_CHARS}]+/
    EXPONENT_RE = /(e[\-+]?[0-9]+)?/

    GEN_DEFINES = %w{
      defun defun* defsubst defmacro defadvice define-skeleton define-minor-mode
      define-global-minor-mode define-globalized-minor-mode define-derived-mode
      define-generic-mode define-compiler-macro define-modify-macro defsetf
      define-setf-expander define-method-combination defgeneric defmethod
    }
    TYPE_DEFINES = %w{
      defgroup deftheme deftype defstruct defclass define-condition
      define-widget defface defpackage
    }
    VAR_DEFINES = %w{
      defvar defconst defconstant defcustom defparameter define-symbol-macro
    }
    KEYWORDS = (GEN_DEFINES + TYPE_DEFINES + VAR_DEFINES + %w{
      lambda autoload progn prog1 prog2 save-excursion save-window-excursion
      save-selected-window save-restriction save-match-data save-current-buffer
      with-current-buffer combine-after-change-calls with-output-to-string
      with-temp-file with-temp-buffer with-temp-message with-syntax-table let
      let* while if read-if catch condition-case unwind-protect
      with-output-to-temp-buffer eval-after-load dolist dotimes when unless
    }).inject({}) { |memo, str| memo[str] = nil; memo }

    DEFINES = WordList.new.
      add(GEN_DEFINES, :function).
      add(TYPE_DEFINES, :class).
      add(VAR_DEFINES, :variable)

    def scan_tokens(tokens, options)
      defined = false
      until eos?
        kind = nil
        match = nil

        if scan(/\s+/m)
          kind = :space
        else
          if scan(/[\(\)\[\]]/)
            kind = :delimiter
          elsif scan(/'+#{SYMBOL_RE}/)
            kind = :symbol
          elsif scan(/\&#{SYMBOL_RE}/)
            kind = :reserved
          elsif scan(/:#{SYMBOL_RE}/)
            kind = :constant
          elsif scan(/\?#{SYMBOL_RE}/)
            kind = :char
          elsif match = scan(/"(\\"|[^"])+"/m)
            tokens << [:open, :string] << ['"', :delimiter] <<
              [match[1...-1], :content] << ['"', :delimiter] << [:close, :string]
            next
          elsif scan(/[\-+]?[0-9]*\.[0-9]+#{EXPONENT_RE}/)
            kind = :float
          elsif scan(/[\-+]?[0-9]+#{EXPONENT_RE}/)
            kind = :integer
          elsif scan(/;.*$/)
            kind = :comment
          elsif scan(SYMBOL_RE)
            kind = :plain

            if defined
              kind = defined
            else
              sym = matched
              if KEYWORDS.include? sym
                kind = :reserved                
                defined = DEFINES[sym]
              end
            end
          end
        end

        match ||= matched
        raise_inspect 'Empty token', tokens unless match

        defined = [:reserved, :comment, :space].include?(kind) && defined

        tokens << [match, kind]
      end

      tokens
    end
  end
end