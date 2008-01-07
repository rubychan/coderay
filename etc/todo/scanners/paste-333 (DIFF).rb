## diff.rb

module CodeRay module Scanners
	
	class Diff < Scanner

		register_for :diff
		
		def scan_tokens tokens, options

			until eos?

				kind = :space
				match = nil

          # remove newlines
          if scan(/\n/)
            kind = :space
					elsif scan(/^[+-]{3} .*$/)
						kind = :diffhead
          elsif scan(/^[+].*$/)
	          kind = :add
          elsif scan(/^[-].*$/)
	          kind = :delete
          elsif scan(/^[^ ].*$/)
            kind = :diffhead
          elsif scan(/^ .*$/)
            kind = :space
				  else 
				    getch 
				  end
		
				match ||= matched
				raise [match, kind], tokens if kind == :error

				tokens << [match, kind]
		
			end
			
			tokens
		end

	end

end end

## styles (cycnus) [plain]

.add { color:green; background:#dfd; }
.delete { color:red; background:#fdd; }
.diffhead { color:#999; background: #e7e7ff; }

## tokens (encoder/html/classes.rb)

		ClassOfKind = {
		  :add => "add",
		  :delete => "delete",
		  :diffhead => "diffhead",

## example diff [diff]
Index: /Users/jgoebel/rails/pastie/app/controllers/pastes_controller.rb
===================================================================
--- /Users/jgoebel/rails/pastie/app/controllers/pastes_controller.rb  (revision 1431)
+++ /Users/jgoebel/rails/pastie/app/controllers/pastes_controller.rb  (revision 1437)
@@ -1,6 +1,10 @@
+require 'login_system'
 require 'coderay'
 
 class PastesController < ApplicationController
+  include LoginSystem
+
+  before_filter :attempt_cookie_login
 
 #  caches_action :recent
 
@@ -10,11 +14,7 @@
 
   def show
     @paste = Paste.find(params[:id])
-    if params[:key] and params[:key]==User.new(@paste.nick).magic_mojo
-        session[:login]=@paste.nick
-        return redirect_to(:action => 'show', :id => @paste.id)
-    end
-    
+    attempt_key_login if not logged_in?
     unless @paste.asset or not @paste.body.blank?
       render :action => "edit"
     end