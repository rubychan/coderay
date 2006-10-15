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

