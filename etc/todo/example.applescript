(**
  *	filename: MailNotification.applescript
 *	created : Tue Feb 11 14:24:40 2003
 *	LastEditDate Was "Mon Jun 30 11:25:23 2003"
 *
 *)

(* recipientAddress is a list of Addresses to send to
 * messageSubject is the subject of the spam message
 * messageBody is the body of the spam message
 *)
on sendemail(emailer, vcardPath, recipientAddress, messageSubject, messageBody)

	(* Part that does all of the work, this works for Mail *)
	if (emailer is equal to "com.apple.mail") then
		tell application "Mail"
			-- Properties can be specified in a record when creating the message or
			-- afterwards by setting individual property values.
			set newMessage to make new outgoing message with properties {subject:messageSubject, content:messageBody}
			tell newMessage
				-- Default is false. Determines whether the compose window will
				-- show on the screen or whether it will happen in the background.
				set visible to false

				repeat with emailAddress in recipientAddress
					make new bcc recipient at end of bcc recipients with properties {address:emailAddress}
				end repeat
				tell content
					-- Position must be specified for attachments
					make new attachment with properties {file name:vcardPath} at after the last paragraph
				end tell
			end tell
			-- send the message
			send newMessage
		end tell
	else
		if (emailer is equal to "com.microsoft.entourage") then
			(* lots of stuff for entourage here *)
		end if
	end if
end sendemail

-- sendemail("com.apple.mail", "/tmp/foo.vcf", "dude@apple.com", "messageSubject", "messageBody")
(**
  *	filename: SharingInvite.applescript
 *
 *)

(* recipientAddress is a list of Addresses to send to
 * messageSubject is the subject of the invite message
 * messageBody is the body of the invite message
 *)
on sendemail(emailer, recipientAddress, messageSubject, messageBody)
	
	(* Part that does all of the work, this works for Mail *)
	if (emailer is equal to "com.apple.mail") then
		tell application "Mail"
			-- Properties can be specified in a record when creating the message or
			-- afterwards by setting individual property values.
			set newMessage to make new outgoing message with properties {subject:messageSubject, content:messageBody}
			tell newMessage
				-- Default is false. Determines whether the compose window will
				-- show on the screen or whether it will happen in the background.
				set visible to true
				
				repeat with emailAddress in recipientAddress
					make new bcc recipient at end of bcc recipients with properties {address:emailAddress}
				end repeat
			end tell
			-- send the message
			--			send newMessage
		end tell
	else
		if (emailer is equal to "com.microsoft.entourage") then
			(* lots of stuff for entourage here *)
		end if
	end if
end sendemail

-- sendemail("com.apple.mail", "dude@apple.com", "messageSubject", "messageBody")
beep
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Wil je Big Bang " & game_name & " voor Mac OS X spelen? (Laat het me weten als je het spel niet hebt en ik stuur het je met een klik op de muis.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wanneer je klaar bent om te spelen, open je mijn spelsleutel die je meteen van mij zult ontvangen."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Laten we Big Bang " & game_name & " voor Mac OS X spelen. Ik denk niet dat je het spel hebt, dus daarom stuur ik het je hierbij!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Laat het me weten wanneer je klaar bent om te spelen, dan nodig ik je uit voor een spel."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Eudora"		set newMessage to make new message at end of mailbox "Out"	tell newMessage		set subject to theSubject		set body to theBody & return & return				set field "to" to theRecipients				attach to newMessage documents {oldPath as alias}	end tell		activate		return trueend tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Une partie de Big Bang " & game_name & " pour Mac OS X ? (Si tu n'as pas ce jeu, dis-le moi et je te l'envoie d'un simple clic !)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Pour jouer, il suffit d'ouvrir le fichier que je vais t'envoyer."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Faisons une partie de Big Bang " & game_name & " pour Mac OS X. Comme tu n'as pas ce jeu, je te l'envoie !" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Dis-moi quand tu veux jouer et je t'inviterai pour une partie."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Willst Du Big Bang " & game_name & " auf einem Mac OS X spielen? (Wenn Du das Spiel nicht besitzt, gib mir Bescheid. Ich kann es mit einem Klick senden.)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Wenn Du spielbereit bist, verwende einfach meinen Spieleschluessel, den ich Dir gleich sende."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Lass uns Big Bang " & game_name & " for Mac OS X spielen. Ich glaube, dass Du es nicht hast. Hier ist es." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Wenn Du spielbereit bist, gebe mir Bescheid, und ich lade Dich zu einem Spiel ein."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Vuoi giocare a Big Bang " & game_name & " per Mac OS X? (Se non ce l'hai, fammelo sapere e te lo mando in un clic!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Quando sei pronto per giocare, apri la chiave della partita che ti mando."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Giochiamo a Big Bang " & game_name & " per Mac OS X. Non mi sembra che tu ce l'abbia, quindi te lo mando!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Quando sei pronto per giocare, fammelo sapere."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Want to play Big Bang " & game_name & " for Mac OS X? (If you don't have it, let me know and I can send it with one click!)" as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "When you're ready to play, simply open my game key which I'm sending to you next."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Let's play Big Bang " & game_name & " for Mac OS X. I don't think you have it, so, here it is!" as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "When you're ready to play, let me know and I'll invite you to a game."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell
(*	The calling application will define the following variables for you: *	 *	oldPath - A Mac OS 9 styled full path name to the attachment file *	unixPath - A Unix-styled full path name *	theRecipients - A comma-separated list of email addresses to send to *	theSubject - String which contained the subject *	theBody - String which contains the body of the email *)tell application "Mail"	activate	set this_message to make new compose message at beginning of every compose message with properties {subject:theSubject,content:theBody}	tell this_message		set content to return & return & content		make new recipient at end of recipients with properties {display name:theRecipients}		tell content			make new text attachment with properties {file name:unixPath} at before the first word of the first paragraph		end tell	end tell		set content of this_message to the content of this_message	make new message editor at beginning of message editors	set compose message of message editor 1 to this_message		return trueend tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

set theBody to the clipboard as Unicode text

tell application "Mail"
	
	set newMessage to make new outgoing message with properties {subject:theSubject, content:return}
	tell newMessage
		set visible to true
		make new to recipient at end of to recipients with properties {name:theRecipients}
		tell content
			make new attachment with properties {file name:unixPath} at after the last paragraph
			make new text at after the last paragraph with data (return & return & theBody)
		end tell
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Microsoft Entourage"
	
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
(*	The calling application will define the following variables for you:
 *	
 *	oldPath - A Mac OS 9 styled full path name to the attachment file
 *	unixPath - A Unix-styled full path name
 *	theRecipients - A comma-separated list of email addresses to send to
 *	theSubject - String which contained the subject
 *	theBody - String which contains the body of the email
 *)

tell application "Outlook Express"
	set newMessage to make new draft window with properties {recipient:theRecipients, subject:theSubject, content:theBody & return & return}
	tell newMessage
		make new file with properties {name:oldPath}
	end tell
	
	activate
	
	return true
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Quieres jugar a Big Bang " & game_name & " para Mac OS X? Si no lo tienes, te lo hago llegar con un simple clic." as string)
	
	set chat_message to chat_message & chat_string
	
	set chat_message to chat_message & "Para empezar a jugar, abre el archivo de llave de partida que te paso."
	
	repeat with j from 1 to the number of services
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
	end repeat
	
	return false
end tell
tell application "iChat"
	
	activate
	
	set chat_message to {}
	
	set chat_string to ("Juguemos a Big Bang " & game_name & " para Mac OS X. Creo que no lo tienes. Te lo paso." as string)
	
	
	set chat_message to chat_message & chat_string
	set chat_message to chat_message & "Cuando quieras jugar me lo dices y te invito a una partida."
	
	repeat with j from 1 to the number of services
		
		repeat with i from 1 to the number of accounts of item j of services
			
			if (id of item i of accounts of item j of services as string) is equal to target_id then
				
				set user_status to status of item i of accounts of item j of services
				set user_idle to idle time of item i of accounts of item j of services
				
				if user_status is available and user_idle is 0 then
					
					repeat with k from 1 to the number of items of chat_message
						send item k of chat_message to item i of accounts of item j of services
					end repeat
					
					--send ("Big Bang " & game_name & "" as string) to item i of accounts of item j of services
					
					set frontmost to true
					
					return true
					
				end if
			end if
			
		end repeat
		
	end repeat
	
	return false
end tell

-- First we  initialize a few variables
-- TODO remove the unused ones
set myEvList to {}
set myTaskList to {}
set theTextList to ""
set theError to 0
set theImfile to ""
set theDocRef to 0
set theImFileName to ""
set gEntourageWasRunning to true
set gMinimunPBar to 0.005
set gProgression to 0
set gNTasks to 0
set gNEvents to 0

-- Creating a new calendar in iCal 

tell application "iCal"
	activate
	make new calendar with properties {title:"Entourage"}
	delay (0.5)
end tell

-- Getting the events from Entourage (not there is no way to choose which Entourage in this one)
try
	if (theError of me is equal to 0) then
		tell application "Microsoft Entourage"
			--log "Entourage import, start getting events " & (current date)
			activate
			
			set myEEvents to get every event
			set my gNEvents to count (myEEvents)
			set myTasks to tasks where its completed is equal to false
			set my gNTasks to count (myTasks)
			
			if my gNTasks is not equal to 0 then
				set entIncrement to (round ((count myEEvents) / 40) rounding up)
			else
				set entIncrement to (round ((count myEEvents) / 80) rounding up)
			end if
			set progEntIdx to 0
			
			repeat with aEEvent in myEEvents
				set tmpVal to {}
				-- append raw properties to the list as list of records have their own syntax
				set tmpVal to tmpVal & (get subject of aEEvent as Unicode text)
				
				set begDate to (get start time of aEEvent)
				set endDate to (get end time of aEEvent)
				set addFlag to (get all day event of aEEvent)
				if addFlag is equal to false then
					if (endDate - begDate) > 24 * hours then
						set addFlag to true
						set time of begDate to 0
						set time of endDate to 0
						set dday to day of endDate
						set day of endDate to dday + 1
					end if
				end if
				set tmpVal to tmpVal & addFlag
				set tmpVal to tmpVal & begDate
				set tmpVal to tmpVal & endDate
				
				set tmpVal to tmpVal & (get recurring of aEEvent)
				set tmpVal to tmpVal & (get recurrence of aEEvent)
				set tmpVal to tmpVal & (get location of aEEvent as Unicode text)
				set tmpVal to tmpVal & (get content of aEEvent as Unicode text)
				set (myEvList of me) to (myEvList of me) & tmpVal
				set progEntIdx to progEntIdx + 1
				if progEntIdx is equal to entIncrement then
					set progEntIdx to 0
				end if
			end repeat
			
			--log "Entourage import, start getting tasks " & (current date)
			if (my gNTasks) is not equal to 0 then
				--if count task is not equal to 0 then
				set my gProgression to 0.3
				set entIncrement to (round ((my gNTasks) / 40) rounding up)
				
				set progEntIdx to 0
				
				repeat with aTask in myTasks
					set tmpVal to {}
					set tmpVal to tmpVal & (get the name of aTask as Unicode text)
					set tmpVal to tmpVal & (get the due date of aTask)
					set tmpPri to the priority of aTask
					if tmpPri is equal to highest then
						set tmpVal to tmpVal & 1
					else if tmpPri is equal to high then
						set tmpVal to tmpVal & 4
					else if tmpPri is equal to low then
						set tmpVal to tmpVal & 7
					else if tmpPri is equal to lowest then
						set tmpVal to tmpVal & 7
					else
						set tmpVal to tmpVal & 0
					end if
					set tmpVal to tmpVal & (get content of aTask as Unicode text)
					
					set (myTaskList of me) to (myTaskList of me) & tmpVal
					set progEntIdx to progEntIdx + 1
					
					if progEntIdx is equal to entIncrement then
						set progEntIdx to 0
					end if
				end repeat
			end if
		end tell
	end if
	
	--correct the recurrences
	set parsidx to 0
	repeat my gNEvents times
		set entRule to (item (parsidx + 6) of (myEvList of me))
		if (entRule) is not equal to "" then
			set offUntil to offset of "UNTIL=" in entRule
			if offUntil is not equal to 0 then
				set icalRule to text 1 through (offUntil + 5) of entRule
				set remainText to (text (offUntil + 6) through (length of (entRule)) of entRule)
				set endPos to offset of ";" in remainText
				set untilDateStr to (text 1 through (endPos - 1) of remainText) as string
				set untilYear to (items 1 through 4 of untilDateStr) as string
				set untilMonth to (items 5 through 6 of untilDateStr) as string
				set untilDay to (items 7 through 8 of untilDateStr) as string
				
				set untilDate to current date
				set day of untilDate to untilDay
				set year of untilDate to untilYear
				
				if untilMonth is equal to "01" then
					set month of untilDate to January
				else if untilMonth is equal to "02" then
					set month of untilDate to February
				else if untilMonth is equal to "03" then
					set month of untilDate to March
				else if untilMonth is equal to "04" then
					set month of untilDate to April
				else if untilMonth is equal to "05" then
					set month of untilDate to May
				else if untilMonth is equal to "06" then
					set month of untilDate to June
				else if untilMonth is equal to "07" then
					set month of untilDate to July
				else if untilMonth is equal to "08" then
					set month of untilDate to August
				else if untilMonth is equal to "09" then
					set month of untilDate to September
				else if untilMonth is equal to "10" then
					set month of untilDate to October
				else if untilMonth is equal to "11" then
					set month of untilDate to November
				else if untilMonth is equal to "12" then
					set month of untilDate to December
				end if
				
				set newUntilDate to untilDate + 1 * days
				set newUntiDateStr to ((year of newUntilDate) as string)
				if (month of newUntilDate) as string is equal to "January" then
					set newUntiDateStr to newUntiDateStr & "01"
				else if (month of newUntilDate) as string is equal to "February" then
					set newUntiDateStr to newUntiDateStr & "02"
				else if (month of newUntilDate) as string is equal to "March" then
					set newUntiDateStr to newUntiDateStr & "03"
				else if (month of newUntilDate) as string is equal to "April" then
					set newUntiDateStr to newUntiDateStr & "04"
				else if (month of newUntilDate) as string is equal to "May" then
					set newUntiDateStr to newUntiDateStr & "05"
				else if (month of newUntilDate) as string is equal to "June" then
					set newUntiDateStr to newUntiDateStr & "06"
				else if (month of newUntilDate) as string is equal to "July" then
					set newUntiDateStr to newUntiDateStr & "07"
				else if (month of newUntilDate) as string is equal to "August" then
					set newUntiDateStr to newUntiDateStr & "08"
				else if (month of newUntilDate) as string is equal to "September" then
					set newUntiDateStr to newUntiDateStr & "09"
				else if (month of newUntilDate) as string is equal to "October" then
					set newUntiDateStr to newUntiDateStr & "10"
				else if (month of newUntilDate) as string is equal to "November" then
					set newUntiDateStr to newUntiDateStr & "11"
				else if (month of newUntilDate) as string is equal to "December" then
					set newUntiDateStr to newUntiDateStr & "12"
				end if
				
				if day of newUntilDate < 10 then
					set newUntiDateStr to newUntiDateStr & "0" & day of newUntilDate
				else
					set newUntiDateStr to newUntiDateStr & day of newUntilDate
				end if
				set icalRule to icalRule & newUntiDateStr & (items 9 through (length of untilDateStr) of untilDateStr) as string
				set icalRule to icalRule & (text endPos through (length of (remainText)) of remainText)
				set (item (parsidx + 6) of (myEvList of me)) to icalRule
			end if
		end if
		set parsidx to parsidx + 8
	end repeat
	-- put the events in iCal
	
	tell application "iCal"
		set my gProgression to 0.5
		set progression to my gProgression
		activate
		log "Entourage import, storing events in iCal " & (current date)
		set parsidx to 0
		set numEvents to (count (myEvList of me)) / 8
		
		if my gNTasks is not equal to 0 then
			set entIncrement to (round ((my gNEvents) / 50) rounding up)
		else
			set entIncrement to (round ((my gNEvents) / 100) rounding up)
		end if
		
		set progEntIdx to 0
		
		repeat numEvents times
			set evtSummary to (item (parsidx + 1) of (myEvList of me)) as Unicode text
			set evtStartDate to item (parsidx + 3) of (myEvList of me)
			set evtLocation to (item (parsidx + 7) of (myEvList of me))
			set evtNotes to (item (parsidx + 8) of (myEvList of me))
			set isAD to (item (parsidx + 2) of (myEvList of me)) as boolean
			
			if isAD is equal to true then
				set evtADD to true
				set evtEndDate to item (parsidx + 4) of (myEvList of me)
				if ((item (parsidx + 5) of (myEvList of me)) is equal to true) then
					set evtRecRule to (item (parsidx + 6) of (myEvList of me))
					--my translateReccurenceRule
					set myNewADEvent to make new event at the end of events of last calendar
					tell myNewADEvent
						set summary to evtSummary
						set start date to evtStartDate
						set end date to evtEndDate - 1
						set allday event to true
						set recurrence to evtRecRule
						set description to evtNotes
						set location to evtLocation
					end tell
				else
					set myNewADEvent to make new event at the end of events of last calendar
					tell myNewADEvent
						set summary to evtSummary
						set start date to evtStartDate
						set end date to evtEndDate - 1
						set allday event to true
						set description to evtNotes
						set location to evtLocation
					end tell
				end if
			else
				set evtEndDate to item (parsidx + 4) of (myEvList of me)
				if ((item (parsidx + 5) of (myEvList of me)) is equal to true) then
					set evtRecRule to (item (parsidx + 6) of (myEvList of me))
					-- my translateReccurenceRule
					make new event with properties {summary:evtSummary, start date:evtStartDate, end date:evtEndDate, recurrence:evtRecRule, location:evtLocation, description:evtNotes} at the end of events of last calendar
				else
					make new event with properties {summary:evtSummary, start date:evtStartDate, end date:evtEndDate, location:evtLocation, description:evtNotes} at the end of events of last calendar
				end if
			end if
			
			
			set parsidx to parsidx + 8
			set progEntIdx to progEntIdx + 1
			
			if progEntIdx is equal to entIncrement then
				set progEntIdx to 0
				set my gProgression to ((my gProgression) + gMinimunPBar)
				set progression to my gProgression
			end if
		end repeat
		--	log "Entourage import : end of events" & (current date)
		if my gNTasks is not equal to 0 then
			set my gProgression to 0.75
			set progression to my gProgression
			set parsjdx to 0
			set entIncrement to (round ((my gNTasks) / 50) rounding up)
			set progEntIdx to 0
			repeat my gNTasks times
				set tdSummary to (item (parsjdx + 1) of (myTaskList of me)) as Unicode text
				--				set tdPriority to no priority -- (item (parsjdx + 3) of (myTaskList of me)) as integer
				set msPriority to (item (parsjdx + 3) of (myTaskList of me)) as integer
				set tdContent to (item (parsjdx + 4) of (myTaskList of me)) as Unicode text
				if msPriority is equal to 1 then
					set tdPriority to high priority
				else if msPriority is equal to 4 then
					set tdPriority to medium priority
				else if msPriority is equal to 7 then
					set tdPriority to low priority
				else if msPriority is equal to 0 then
					set tdPriority to no priority
				end if
				set tdDueDate to item (parsjdx + 2) of (myTaskList of me)
				set yearPosDueDate to year of tdDueDate
				--Entourage marks ToDo with no due date to 1904
				if yearPosDueDate is not equal to 1904 then
					make new todo with properties {summary:tdSummary, priority:tdPriority, due date:tdDueDate, description:tdContent} at the end of todos of last calendar
				else
					make new todo with properties {summary:tdSummary, priority:tdPriority, description:tdContent} at the end of todos of last calendar
				end if
				set parsjdx to parsjdx + 4
				set progEntIdx to progEntIdx + 1
				
				if progEntIdx is equal to entIncrement then
					set progEntIdx to 0
					set my gProgression to ((my gProgression) + gMinimunPBar)
					set progression to my gProgression
				end if
			end repeat
		end if
		set progression to 1
		delay 0.9
	end tell
on error errorMessageVariable
	log errorMessageVariable
	if errorMessageVariable is equal to "Cancel Operation" then
		tell application "iCal"
			log "Operation cancelled"
		end tell
	end if
end try

--tell application "iCal"
--	dismiss progress
--end tell

-- reput Entourage to its initial state
--if (gEntourageWasRunning of me) is equal to false then
tell application "Microsoft Entourage" to quit
--end if

on translateReccurenceRule(entRule)
	set icalRule to entRule
	
	set offUntil to offset of "UNTIL=" in entRule
	if offUntil is not equal to 0 then
		set icalRule to text 1 through (offUntil + 5) of entRule
		set remainText to (text (offUntil + 6) through (length of (entRule)) of entRule)
		set endPos to offset of ";" in remainText
		set untilDateStr to (text 1 through (endPos - 1) of remainText) as string
		log untilDateStr
		set untilYear to (items 1 through 4 of untilDateStr) as string
		set untilMonth to (items 5 through 6 of untilDateStr) as string
		set untilDay to (items 7 through 8 of untilDateStr) as string
		set untilDate to date (untilMonth & "/" & untilDay & "/ " & untilYear)
		set newUntilDate to untilDate + 1 * days
		set newUntiDateStr to ((year of newUntilDate) as string)
		if (month of newUntilDate) as string is equal to "January" then
			set newUntiDateStr to newUntiDateStr & "01"
		else if (month of newUntilDate) as string is equal to "February" then
			set newUntiDateStr to newUntiDateStr & "02"
		else if (month of newUntilDate) as string is equal to "March" then
			set newUntiDateStr to newUntiDateStr & "03"
		else if (month of newUntilDate) as string is equal to "April" then
			set newUntiDateStr to newUntiDateStr & "04"
		else if (month of newUntilDate) as string is equal to "May" then
			set newUntiDateStr to newUntiDateStr & "05"
		else if (month of newUntilDate) as string is equal to "June" then
			set newUntiDateStr to newUntiDateStr & "06"
		else if (month of newUntilDate) as string is equal to "July" then
			set newUntiDateStr to newUntiDateStr & "07"
		else if (month of newUntilDate) as string is equal to "August" then
			set newUntiDateStr to newUntiDateStr & "08"
		else if (month of newUntilDate) as string is equal to "September" then
			set newUntiDateStr to newUntiDateStr & "09"
		else if (month of newUntilDate) as string is equal to "October" then
			set newUntiDateStr to newUntiDateStr & "10"
		else if (month of newUntilDate) as string is equal to "November" then
			set newUntiDateStr to newUntiDateStr & "11"
		else if (month of newUntilDate) as string is equal to "December" then
			set newUntiDateStr to newUntiDateStr & "12"
		end if
		
		if day of newUntilDate < 10 then
			set newUntiDateStr to newUntiDateStr & "0" & day of newUntilDate
		else
			set newUntiDateStr to newUntiDateStr & day of newUntilDate
		end if
		set icalRule to icalRule & newUntiDateStr & (items 9 through (length of untilDateStr) of untilDateStr) as string
		set icalRule to icalRule & (text endPos through (length of (remainText)) of remainText)
	end if
	
	return icalRule
end translateReccurenceRule

on getValueForCalRecRule(aRecRule, aRuleName)
	set ruleOffset to offset of aRuleName in aRecRule
	if ruleOffset is not equal to 0 then
		if (character (ruleOffset + (count of aRuleName)) of aRecRule) is equal to "=" then
			set remainStr to text (ruleOffset + (count of aRuleName) + 1) through (count of aRecRule) of aRecRule
			set endPos to offset of ";" in remainStr
			set result to text 1 through (endPos - 1) of remainStr
			return result
		else
			return ""
		end if
	else
		return ""
	end if
end getValueForCalRecRule

-- Mail.applescript
-- iCal

on show_mail_sbrs(subjectLine, messageText, myrecipients)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		repeat with i from (count of myrecipients) to 1 by -1
			tell mymail to make new to recipient at beginning of to recipients with properties {address:(item i of myrecipients)}
		end repeat
		set visible of mymail to true
		activate
	end tell
end show_mail_sbrs

on show_mail_sbr(subjectLine, messageText, myrecipient)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail to make new to recipient at beginning of to recipients with properties {address:myrecipient}
		set visible of mymail to true
		activate
	end tell
end show_mail_sbr

on send_mail_sb(subjectLine, messageText)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		set visible of mymail to true
		activate
	end tell
end send_mail_sb

on send_mail_sbr(subjectLine, messageText, myrecipient)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail to make new to recipient at beginning of to recipients with properties {address:myrecipient}
		send mymail
	end tell
end send_mail_sbr

on send_mail_sbrp(subjectLine, messageText, myrecipient, invitationPath)
	set pfile to POSIX file invitationPath
	set myfile to pfile as alias
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail to make new to recipient at beginning of to recipients with properties {address:myrecipient}
		tell mymail
			tell content
				make new attachment with properties {file name:myfile} at after the last word of the the last paragraph
			end tell
		end tell
		send mymail
	end tell
end send_mail_sbrp

on send_mail_sbp(subjectLine, messageText, invitationPath)
	set pfile to POSIX file invitationPath
	set myfile to pfile as alias
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail
			tell content
				make new attachment with properties {file name:myfile} at after the last word of the the last paragraph
			end tell
		end tell
		set visible of mymail to true
		activate
	end tell
end send_mail_sbp

tell application "Mail"	activate	set mysubject to $1	set mybody to $2	set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:mysubject, content:mybody})	set visible of mymail to trueend tell
tell application "Mail"	set mysubject to $1	set mybody to $2	set myrecipient to $3		set mymail to (make new outgoing message at the beginning of outgoing messages with properties { subject:mysubject, content:mybody})	tell mymail to make new to recipient at beginning of to recipients with properties {name:myrecipient}		send mymailend tell
tell application "Mail"	set mysubject to $1	set mybody to $2	set myrecipient to $3	set pfile to $4	set myfile to pfile as alias		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:mysubject, content:mybody})	tell mymail to make new to recipient at beginning of to recipients with properties {name:myrecipient}		tell mymail		tell content			make new attachment with properties {file name:myfile} at after the last word of the the last paragraph		end tell	end tell	send mymailend tell
-- Mail.applescript
-- iCal

on show_mail_sbrs(subjectLine, messageText, myrecipients)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		repeat with i from (count of myrecipients) to 1 by -1
			tell mymail to make new to recipient at beginning of to recipients with properties {address:(item i of myrecipients)}
		end repeat
		set visible of mymail to true
		activate
	end tell
end show_mail_sbrs

on show_mail_sbr(subjectLine, messageText, myrecipient)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail to make new to recipient at beginning of to recipients with properties {address:myrecipient}
		set visible of mymail to true
		activate
	end tell
end show_mail_sbr

on send_mail_sb(subjectLine, messageText)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		set visible of mymail to true
		activate
	end tell
end send_mail_sb

on send_mail_sbr(subjectLine, messageText, myrecipient)
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail to make new to recipient at beginning of to recipients with properties {address:myrecipient}
		send mymail
	end tell
end send_mail_sbr

on send_mail_sbrp(subjectLine, messageText, myrecipient, invitationPath)
	set pfile to POSIX file invitationPath
	set myfile to pfile as alias
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail to make new to recipient at beginning of to recipients with properties {address:myrecipient}
		tell mymail
			tell content
				make new attachment with properties {file name:myfile} at after the last word of the the last paragraph
			end tell
		end tell
		send mymail
	end tell
end send_mail_sbrp

on send_mail_sbp(subjectLine, messageText, invitationPath)
	set pfile to POSIX file invitationPath
	set myfile to pfile as alias
	tell application "Mail"
		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:subjectLine, content:messageText})
		tell mymail
			tell content
				make new attachment with properties {file name:myfile} at after the last word of the the last paragraph
			end tell
		end tell
		set visible of mymail to true
		activate
	end tell
end send_mail_sbp

tell application "Mail"	activate	set mysubject to $1	set mybody to $2	set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:mysubject, content:mybody})	set visible of mymail to trueend tell
tell application "Mail"	set mysubject to $1	set mybody to $2	set myrecipient to $3		set mymail to (make new outgoing message at the beginning of outgoing messages with properties { subject:mysubject, content:mybody})	tell mymail to make new to recipient at beginning of to recipients with properties {name:myrecipient}		send mymailend tell
tell application "Mail"	set mysubject to $1	set mybody to $2	set myrecipient to $3	set pfile to $4	set myfile to pfile as alias		set mymail to (make new outgoing message at the beginning of outgoing messages with properties {subject:mysubject, content:mybody})	tell mymail to make new to recipient at beginning of to recipients with properties {name:myrecipient}		tell mymail		tell content			make new attachment with properties {file name:myfile} at after the last word of the the last paragraph		end tell	end tell	send mymailend tell
on activate_iterm(shellCommand)
	tell application "iTerm"
		make new terminal
		tell the first terminal
			activate current session
			launch session "Default Session"
			tell the last session
				write text shellCommand
			end tell
		end tell
		activate
	end tell
end activate_iterm
on activate_terminal(shellCommand)
	tell application "Finder"
		if exists process "Terminal" then
			tell application "Terminal"
				activate
				do script shellCommand
			end tell
		else
			tell application "Terminal"
				activate
				do script shellCommand in window 0
			end tell
		end if
	end tell
end activate_terminal
tell application "Mail"
	set composeWindow to make new outgoing message with properties {subject:"SelfTest message", content:"This is a test message for SelfTest.", visible:true}
	close composeWindow without saving
end tell
-- dynamicCall publish("[[QTExpNameOut]]")

on publish(attachedFilePath)
	tell application "Mail"
		set new_message to make new outgoing message
		tell new_message
			set visible to true
			make new to recipient at end of to recipients
			tell content
				make new attachment with properties {file name:attachedFilePath} at after the last paragraph
			end tell
		end tell
		activate
	end tell
end publish
--  ${TM_NEW_FILE_BASENAME}.applescript
--
--  Created by ${TM_USERNAME} on ${TM_DATE}.
--  Copyright (c) ${TM_YEAR} ${TM_ORGANIZATION_NAME}. All rights reserved.
--

on open dropped_items

	-- do something useful

end open
--  ${TM_NEW_FILE_BASENAME}.applescript
--
--  Created by ${TM_USERNAME} on ${TM_DATE}.
--  Copyright (c) ${TM_YEAR} ${TM_ORGANIZATION_NAME}. All rights reserved.
--

on adding folder items to this_folder after receiving added_items

	-- do something useful

end adding folder items to



on removing folder items from this_folder after losing removed_items

	-- do something useful

end removing folder items from



on opening folder this_folder

	-- do something useful

end opening folder



on moving folder window for this_folder from original_bounds

	-- do something useful

end moving folder window for



on closing folder window for this_folder

	-- do something useful

end closing folder window for
-- ${TM_NEW_FILE_BASENAME}.applescript
-- 
-- Created by ${TM_USERNAME} on ${TM_DATE}.
-- Copyright (c) ${TM_YEAR} ${TM_ORGANIZATION_NAME}. All rights reserved.
-- 
-- Place in ~/Library/Application Support/Quicksilver/Actions/
-- 

using terms from application "Quicksilver"
    on process text the_text
		
		-- do something useful
		
    end process text
end using terms from
--  ${TM_NEW_FILE_BASENAME}.applescript
--
--  Created by ${TM_USERNAME} on ${TM_DATE}.
--  Copyright (c) ${TM_YEAR} ${TM_ORGANIZATION_NAME}. All rights reserved.
--

on run

	-- do something useful

end run
--  ${TM_NEW_FILE_BASENAME}.applescript
--
--  Created by ${TM_USERNAME} on ${TM_DATE}.
--  Copyright (c) ${TM_YEAR} ${TM_ORGANIZATION_NAME}. All rights reserved.
--

on run argv

	-- do something useful

end run
-----------------------------------------------------------------------------
-- Name:        docs/mac/M5build.applescript
-- Purpose:     Automatic build of projects with CodeWarrior 5
-- Author:      Gilles Depeyrot
-- Modified by:
-- Created:     06.10.2001
-- RCS-ID:      $Id: M5build.applescript,v 1.3 2001/12/02 20:02:17 GD Exp $
-- Copyright:   (c) 2001 Gilles Depeyrot
-- Licence:     wxWindows licence
-----------------------------------------------------------------------------
--
-- This AppleScript automatically recurses through the selected folder looking for
-- and building CodeWarrior projects.
-- To use this script, simply open it with the 'Script Editor' and run it.
--

--
-- Suffix used to recognize CodeWarrior project files
--
property gProjectSuffix : "M5.mcp"

--
-- Values used to create the log file
--
property gEol : "
"
property gSeparator : "-------------------------------------------------------------------------------" & gEol

--
-- Project and build success count
--
set theProjectCount to 0
set theProjectSuccessCount to 0

--
-- Default log file name
--
set theDate to (day of (current date)) & "/" & GetMonthIndex(current date) & "/" & (year of (current date))
set theLogFileName to "build-" & theDate & ".log"

--
-- Ask the user to select the wxWindows samples folder
--
set theFolder to choose folder with prompt "Select the folder in which to build the projects"

--
-- Ask the user to choose the build log file
--
set theLogFile to choose file name with prompt "Save the build log file" default name theLogFileName

--
-- Open the log file to record the build log
--
set theLogFileRef to open for access theLogFile with write permission

--
-- Write log file header
--
write gSeparator starting at 0 to theLogFileRef
write "Build log" & gEol to theLogFileRef
write gSeparator to theLogFileRef
write "start on " & ((current date) as string) & gEol to theLogFileRef
write gSeparator to theLogFileRef
write "building projects in '" & (theFolder as string) & "'" & gEol to theLogFileRef
write gSeparator to theLogFileRef

--
-- Build or Rebuild targets?
--
set theText to "Build or rebuild projects?"
set theBuild to button returned of (display dialog theText buttons {"Cancel", "Build", "Rebuild"} default button "Rebuild" with icon note)
if theBuild is not equal to "Cancel" then
	--
	-- Build which targets?
	--
	set theText to theBuild & " Classic or Carbon targets?"
	set theType to button returned of (display dialog theText buttons {"Cancel", "Classic", "Carbon"} default button "Carbon" with icon note)
	if theType is not equal to "Cancel" then
		--
		-- Build Debug or Release targets?
		--
		set theText to theBuild & " " & theType & " Debug or " & theType & " Release targets?"
		set theOption to button returned of (display dialog theText buttons {"Cancel", "Release", "Debug"} default button "Debug" with icon note)
		if theOption is not equal to "Cancel" then
			set theTarget to theType & " " & theOption
			
			write "building project targets '" & theTarget & "'" & gEol to theLogFileRef
			write gSeparator to theLogFileRef
			
			BuildProjects(theLogFileRef, theFolder, theTarget, theBuild is equal to "Rebuild")
			
		end if
	end if
end if

--
-- Write log file footer
--
write "successful build of " & theProjectSuccessCount & " projects out of " & theProjectCount & gEol to theLogFileRef
write gSeparator to theLogFileRef
write "end on " & ((current date) as string) & gEol to theLogFileRef
write gSeparator to theLogFileRef
--
-- Close the log file
--
close access theLogFileRef

--
-- BuildProjects
--
on BuildProjects(inLogFileRef, inFolder, inTarget, inRebuild)
	global theProjectCount, theProjectSuccessCount
	
	tell application "Finder" to update inFolder
	
	try
		tell application "Finder" to set theProject to ((the first file of inFolder whose name ends with gProjectSuffix) as string)
	on error
		set theProject to ""
	end try
	
	if theProject is not "" then
		set theProjectCount to theProjectCount + 1
		
		write "building project '" & theProject & "'" & gEol to inLogFileRef
		
		tell application "CodeWarrior IDE 4.0.4"
			--
			-- Open the project in CodeWarrior
			--
			open theProject
			--
			-- Change to the requested target
			--
			Set Current Target inTarget
			--
			-- Remove object code if rebuild requested
			--
			if inRebuild then
				Remove Binaries
			end if
			--
			-- Build/Rebuild the selected target
			--
			set theBuildInfo to Make Project with ExternalEditor
			--
			-- Close the project
			--
			Close Project
		end tell
		--
		-- Report errors to build log file
		--
		write gEol to inLogFileRef
		ReportBuildInfo(inLogFileRef, theBuildInfo)
		write gSeparator to inLogFileRef
	end if
	
	tell application "Finder" to set theSubFolders to every folder of inFolder whose name does not end with " Data"
	repeat with theFolder in theSubFolders
		BuildProjects(inLogFileRef, theFolder, inTarget, inRebuild)
	end repeat
	
end BuildProjects

--
-- ReportBuildInfo
--
on ReportBuildInfo(inLogFileRef, inBuildInfo)
	global theProjectCount, theProjectSuccessCount
	
	set theErrorCount to 0
	set theWarningCount to 0
	
	repeat with theInfo in inBuildInfo
		tell application "CodeWarrior IDE 4.0.4"
			set theKind to ((messageKind of theInfo) as string)
			
			tell me to write "*** " & theKind & " *** " & message of theInfo & gEol to inLogFileRef
			try
				set theFile to ((file of theInfo) as string)
			on error
				set theFile to ""
			end try
			if theFile is not "" then
				tell me to write theFile & " line " & lineNumber of theInfo & gEol to inLogFileRef
			end if
			tell me to write gEol to inLogFileRef
		end tell
		
		if MessageKindIsError(theKind) then
			set theErrorCount to theErrorCount + 1
		else
			set theWarningCount to theWarningCount + 1
		end if
	end repeat
	
	if theErrorCount is 0 then
		set theProjectSuccessCount to theProjectSuccessCount + 1
		write "build succeeded with " & theWarningCount & " warning(s)" & gEol to inLogFileRef
	else
		write "build failed with " & theErrorCount & " error(s) and " & theWarningCount & " warning(s)" & gEol to inLogFileRef
	end if
end ReportBuildInfo

--
-- MessageKindIsError
--
on MessageKindIsError(inKind)
	if inKind is "compiler error" or inKind is "linker error" or inKind is "generic error" then
		return true
	else
		return false
	end if
end MessageKindIsError

--
-- GetMonthIndex
--
on GetMonthIndex(inDate)
	set theMonth to the month of inDate
	set theMonthList to {January, February, March, April, May, June, July, August, September, October, November, December}
	repeat with i from 1 to the number of items in theMonthList
		if theMonth is item i of theMonthList then
			return i
		end if
	end repeat
end GetMonthIndex
-----------------------------------------------------------------------------
-- Name:        docs/mac/M5mcp2xml.applescript
-- Purpose:     Automatic export of CodeWarrior 5 projects to XML files
-- Author:      Gilles Depeyrot
-- Modified by:
-- Created:     28.11.2001
-- RCS-ID:      $Id: M5mcp2xml.applescript,v 1.2 2001/12/02 20:02:17 GD Exp $
-- Copyright:   (c) 2001 Gilles Depeyrot
-- Licence:     wxWindows licence
-----------------------------------------------------------------------------
--
-- This AppleScript automatically recurses through the selected folder looking for
-- and exporting CodeWarrior projects to xml files.
-- To use this script, simply open it with the 'Script Editor' and run it.
--

--
-- Suffix used to recognize CodeWarrior project files
--
property gProjectSuffix : "M5.mcp"

--
-- Project and build success count
--
set theProjectCount to 0
set theProjectSuccessCount to 0

--
-- Ask the user to select the wxWindows samples folder
--
set theFolder to choose folder with prompt "Select the wxWindows folder"

ExportProjects(theFolder)

tell me to display dialog "Exported " & theProjectSuccessCount & " projects out of " & theProjectCount

--
-- ExportProjects
--
on ExportProjects(inFolder)
	global theProjectCount, theProjectSuccessCount
	
	tell application "Finder" to update inFolder
	
	try
		tell application "Finder" to set theProject to ((the first file of inFolder whose name ends with gProjectSuffix) as string)
	on error
		set theProject to ""
	end try
	
	if theProject is not "" then
		set theProjectCount to theProjectCount + 1
		
		-- save the current text delimiters
		set theDelimiters to my text item delimiters
		
		-- replace the ".mcp" extension with ".xml"
		set my text item delimiters to "."
		set theList to (every text item of theProject)
		set theList to (items 1 thru -2 of theList)
		set theExport to (theList as string) & ".xml"
		
		-- restore the text delimiters
		set my text item delimiters to theDelimiters
		
		tell application "CodeWarrior IDE 4.0.4"
			--
			-- Open the project in CodeWarrior
			--
			open theProject
			--
			-- Export the selected project
			--
			try
				export project document 1 in theExport
				set theProjectSuccessCount to theProjectSuccessCount + 1
			on error number errnum
				tell me to display dialog "Error " & errnum & " exporting " & theExport
			end try
			--
			-- Close the project
			--
			Close Project
		end tell
	end if
	
	tell application "Finder" to set theSubFolders to every folder of inFolder whose name does not end with " Data"
	repeat with theFolder in theSubFolders
		ExportProjects(theFolder)
	end repeat
	
end ExportProjects
-----------------------------------------------------------------------------
-- Name:        docs/mac/M5xml2mcp.applescript
-- Purpose:     Automatic import of CodeWarrior 5 xml files to projects
-- Author:      Gilles Depeyrot
-- Modified by:
-- Created:     30.11.2001
-- RCS-ID:      $Id: M5xml2mcp.applescript,v 1.2 2001/12/02 20:02:17 GD Exp $
-- Copyright:   (c) 2001 Gilles Depeyrot
-- Licence:     wxWindows licence
-----------------------------------------------------------------------------
--
-- This AppleScript automatically recurses through the selected folder looking for
-- and importing CodeWarrior xml files to projects
-- To use this script, simply open it with the 'Script Editor' and run it.
--

--
-- Suffix used to recognize CodeWarrior xml files
--
property gXmlSuffix : "M5.xml"

--
-- Project and build success count
--
set theXmlCount to 0
set theXmlSuccessCount to 0

--
-- Ask the user to select the wxWindows samples folder
--
set theFolder to choose folder with prompt "Select the wxWindows folder"

ImportProjects(theFolder)

tell me to display dialog "Imported " & theXmlSuccessCount & " xml files out of " & theXmlCount buttons {"OK"}

--
-- ImportProjects
--
on ImportProjects(inFolder)
	global theXmlCount, theXmlSuccessCount
	
	tell application "Finder" to update inFolder
	
	try
		tell application "Finder" to set theXml to ((the first file of inFolder whose name ends with gXmlSuffix) as string)
	on error
		set theXml to ""
	end try
	
	if theXml is not "" then
		set theXmlCount to theXmlCount + 1
		
		-- save the current text delimiters
		set theDelimiters to my text item delimiters
		
		-- replace the ".xml" extension with ".mcp"
		set my text item delimiters to "."
		set theList to (every text item of theXml)
		set theList to (items 1 thru -2 of theList)
		set theImport to (theList as string) & ".mcp"
		
		-- restore the text delimiters
		set my text item delimiters to theDelimiters
		
		tell application "CodeWarrior IDE 4.0.4"
			--
			-- Import the selected xml file
			--
			try
				make new project document as theImport with data theXml
				set theXmlSuccessCount to theXmlSuccessCount + 1
				--
				-- Close the project
				--
				Close Project
			on error number errnum
				tell me to display dialog "Error " & errnum & " importing " & theXml & " to " & theImport
			end try
		end tell
	end if
	
	tell application "Finder" to set theSubFolders to every folder of inFolder whose name does not end with " Data"
	repeat with theFolder in theSubFolders
		ImportProjects(theFolder)
	end repeat
	
end ImportProjects
-----------------------------------------------------------------------------
-- Name:        docs/mac/M8mcp2xml.applescript
-- Purpose:     Automatic export of CodeWarrior 8 projects to XML files
-- Author:      Gilles Depeyrot
-- Modified by:	Stefan Csomor for M8
-- Created:     28.11.2001
-- RCS-ID:      $Id: M8mcp2xml.applescript,v 1.1 2003/01/16 06:44:49 SC Exp $
-- Copyright:   (c) 2001 Gilles Depeyrot
-- Licence:     wxWindows licence
-----------------------------------------------------------------------------
--
-- This AppleScript automatically recurses through the selected folder looking for
-- and exporting CodeWarrior projects to xml files.
-- To use this script, simply open it with the 'Script Editor' and run it.
--

--
-- Suffix used to recognize CodeWarrior project files
--
property gProjectSuffix : "M8.mcp"

--
-- Project and build success count
--
set theProjectCount to 0
set theProjectSuccessCount to 0

--
-- Ask the user to select the wxWindows samples folder
--
set theFolder to choose folder with prompt "Select the wxWindows folder"

ExportProjects(theFolder)

tell me to display dialog "Exported " & theProjectSuccessCount & " projects out of " & theProjectCount

--
-- ExportProjects
--
on ExportProjects(inFolder)
	global theProjectCount, theProjectSuccessCount
	
	tell application "Finder" to update inFolder
	
	try
		tell application "Finder" to set theProject to ((the first file of inFolder whose name ends with gProjectSuffix) as string)
	on error
		set theProject to ""
	end try
	
	if theProject is not "" then
		set theProjectCount to theProjectCount + 1
		
		-- save the current text delimiters
		set theDelimiters to my text item delimiters
		
		-- replace the ".mcp" extension with ".xml"
		set my text item delimiters to "."
		set theList to (every text item of theProject)
		set theList to (items 1 thru -2 of theList)
		set theExport to (theList as string) & ".xml"
		
		-- restore the text delimiters
		set my text item delimiters to theDelimiters
		
		tell application "CodeWarrior IDE"
			--
			-- Open the project in CodeWarrior
			--
			open theProject
			--
			-- Export the selected project
			--
			try
				export project document 1 to theExport
				set theProjectSuccessCount to theProjectSuccessCount + 1
			on error number errnum
				tell me to display dialog "Error " & errnum & " exporting " & theExport
			end try
			--
			-- Close the project
			--
			Close Project
		end tell
	end if
	
	tell application "Finder" to set theSubFolders to every folder of inFolder whose name does not end with " Data"
	repeat with theFolder in theSubFolders
		ExportProjects(theFolder)
	end repeat
	
end ExportProjects
-----------------------------------------------------------------------------
-- Name:        docs/mac/M8xml2mcp.applescript
-- Purpose:     Automatic import of CodeWarrior 8 xml files to projects
-- Author:      Gilles Depeyrot
-- Modified by: Stefan Csomor
-- Created:     30.11.2001
-- RCS-ID:      $Id: M8xml2mcp.applescript,v 1.2 2004/04/28 22:03:15 DS Exp $
-- Copyright:   (c) 2001 Gilles Depeyrot
-- Licence:     wxWindows licence
-----------------------------------------------------------------------------
--
-- This AppleScript automatically recurses through the selected folder looking for
-- and importing CodeWarrior xml files to projects
-- To use this script, simply open it with the 'Script Editor' and run it.
--

--
-- Suffix used to recognize CodeWarrior xml files
--
property gXmlSuffix : "M8.xml"

--
-- Project and build success count
--
set theXmlCount to 0
set theXmlSuccessCount to 0

--
-- Ask the user to select the wxWindows samples folder
--
set theFolder to choose folder with prompt "Select the wxWindows folder"

ImportProjects(theFolder)

tell me to display dialog "Imported " & theXmlSuccessCount & " xml files out of " & theXmlCount buttons {"OK"}

--
-- ImportProjects
--
on ImportProjects(inFolder)
	global theXmlCount, theXmlSuccessCount
	
	tell application "Finder" to update inFolder
	
	tell application "Finder" to set theXmlList to (every file of inFolder whose name ends with gXmlSuffix)
	
	repeat with theXml in theXmlList
		set theXml to theXml as string
		set theXmlCount to theXmlCount + 1
		
		-- save the current text delimiters
		set theDelimiters to my text item delimiters
		
		-- replace the ".xml" extension with ".mcp"
		set my text item delimiters to "."
		set theList to (every text item of theXml)
		set theList to (items 1 thru -2 of theList)
		set theImport to (theList as string) & ".mcp"
		
		-- restore the text delimiters
		set my text item delimiters to theDelimiters
		
		tell application "CodeWarrior IDE"
			--
			-- Import the selected xml file
			--
			try
				make new project document as theImport with data theXml
				set theXmlSuccessCount to theXmlSuccessCount + 1
				--
				-- Close the project
				--
				Close Project
			on error number errnum
				tell me to display dialog "Error " & errnum & " importing " & theXml & " to " & theImport
			end try
		end tell
	end repeat
	
	tell application "Finder" to set theSubFolders to every folder of inFolder whose name does not end with " Data"
	repeat with theFolder in theSubFolders
		ImportProjects(theFolder)
	end repeat
	
end ImportProjects
---------------------------------------------------------------------------------
-- Name:        docs/mac/SetXMLCreator.applescript
-- Purpose:     Sets the creator types of the XML files
-- Author:      Ryan Wilcox
-- Modified by:
-- Created:     2004-03-30
-- RCS-ID:      $Id: SetXMLCreator.applescript,v 1.2 2004/03/30 10:26:17 JS Exp $
-- Copyright:   (c) 2004 Ryan Wilcox
-- Licence:     wxWindows licence
--
-- Press the run button and select the file you need (or, alternatively, save the
-- script as an application drag-and-drop the files on top of it).
---------------------------------------------------------------------------------

on run
    set myFile to choose file
    open ({myFile})
end run


on open (fileList)
    
    repeat with each in fileList
        
        tell application "Finder"
            if name of each contains "M5" or name of each contains "M7" or name of each contains "M8" then
                set creator type of each to "CWIE"
                set file type of each to "TEXT"
                
                log "set"
            end if
            
        end tell
    end repeat
end open

(* Application.applescript *)

(* This example employs many UI features in Cocoa, such as a 'drawer' and 'panels' as well as using the 'do shell script' to provide a UI frontend to the 'gnutar' shell tool to build tar archives. It also demonstrates how to design an application that is a droplet as well. You can also fine an example of how to use the 'user-defaults' class. *)

(* The structure of this script is as follows:
	Properties		Properties needed for the application.
	Event Handlers	Handlers that are called by actions in the UI.
	Handlers 		Handlers that are called within the script.
*)

(* ==== Properties ==== *)

-- Settings
property openWindowOnLaunch : true
property showProgress : true
property compressArchive : true
property preserveIDs : true
property followLinks : false
property verboseMode : false
property defaultLocation : ""

-- Others
property windowOpened : false
property progressPanel : missing value
property fileNames : {}
property filesDataSource : missing value


(* ==== Event Handlers ==== *)

-- This event handler is called as early in the process of launching an application as is possible. The handler is a good place to register our settings as well as read in the current set of settings. 
-- 
on will finish launching theObject
	set windowOpened to false
	
	registerSettings()
	readSettings()
end will finish launching

-- This event handler is the last handler called in the process of launching an application. If the handler is called and a window hasn't been shown yet (via the 'open' event handler) then we need to show the main window here (as well was opening the settings drawer).
-- 
on launched theObject
	if windowOpened is false then
		showWindow()
		showSettings()
	end if
end launched

-- This event handler is called when the object that is associated with it is loaded from its nib file. It's a good place to do any one-time initialization, which in this case is to create the data source for the table view.
--
on awake from nib theObject
	-- Create the data source for the table view
	set filesDataSource to make new data source at end of data sources with properties {name:"files"}
	
	-- Create the "files" data column
	make new data column at end of data columns of filesDataSource with properties {name:"files"}
	
	-- Assign the data source to the table view
	set data source of theObject to filesDataSource
	
	-- Register for the "file names" drag types
	tell theObject to register drag types {"file names", "color"}
end awake from nib

-- This event handler is called (in this example) when the user drags any finder items over the table view.
--
on drop theObject drag info dragInfo
	-- Get the list of data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	
	-- We are only interested in either "file names" or "color" data types
	if "file names" is in dataTypes then
		-- Initialize the list of files to an empty list
		set theFiles to {}
		
		-- We want the data as a list of file names, so set the preferred type to "file names"
		set preferred type of pasteboard of dragInfo to "file names"
		
		-- Get the list of files from the pasteboard
		set theFiles to contents of pasteboard of dragInfo
		
		-- Make sure we have at least one item
		if (count of theFiles) > 0 then
			-- Turn off the updating of the views
			set update views of filesDataSource to false
			
			-- For every item in the list, make a new data row and set it's contents
			repeat with theItem in theFiles
				set theDataRow to make new data row at end of data rows of filesDataSource
				set contents of data cell "files" of theDataRow to quoted form of theItem
				set fileNames to fileNames & {quoted form of theItem}
			end repeat
			
			-- Turn back on the updating of the views
			set update views of filesDataSource to true
		end if
	end if
	
	-- Set the preferred type back to the default
	set preferred type of pasteboard of dragInfo to ""
	
	return true
end drop

-- This event handler is called when you drag any file/folder items in the Finder onto the application icon (either in the Finder or in the Dock). It can be called as many times as the user drags items onto the application icon, therefore the main process here is to append the list of names the existing list of names. Then we conditionally open the window, make the archive (displaying a progress bar if requested) and then if a window hasn't been opened we simply quit. 
-- 
on open names
	-- Append the list of names to our current list
	repeat with i from 1 to count of names
		set fileNames to fileNames & {quoted form of (POSIX path of (item i of names))}
	end repeat
	
	-- Show the window if requested
	if openWindowOnLaunch then
		-- Of course, only show if it hasn't already been opened
		if not windowOpened then
			showWindow()
		end if
	end if
	
	-- If the main window wasn't opened then go ahead and process the list of files, making an archive with a determined name.
	if not windowOpened then
		set windowOpened to true
		
		-- Get the generated archive name
		set archiveFileName to getArchiveFileName()
		
		-- Show the progress panel if requested
		if showProgress then
			showProgressPanel(false, archiveFileName)
		end if
		
		-- Make the archive
		set theResult to makeArchive(archiveFileName)
		
		-- If we are in verbose mode, then show the results in the log window
		if verboseMode then
			set contents of text view "log" of scroll view "log" of window "log" to theResult
			show window "log"
		end if
		
		-- Hide the progress panel (if shown)
		if showProgress then
			hideProgressPanel(false)
		end if
		
		-- Go ahead and quit, as we are done. (This might need some rethinking, as it probably isn't the right thing to do if for instance the log window is shown, with the verbose mode on.
		quit
	else if openWindowOnLaunch then
		-- Turn off the updating of the views
		set update views of filesDataSource to false
		
		-- Add the files to the data source
		repeat with i from 1 to count of names
			set theDataRow to make new data row at end of data rows of filesDataSource
			set contents of data cell "files" of theDataRow to quoted form of (POSIX path of (item i of names))
		end repeat
		
		-- Turn back on the updating of the views
		set update views of filesDataSource to true
	end if
end open

-- This handler is the last handler to be called before the application quits. It's a good place to the get current settings from the setting drawer and write them out (but only if the window has been opened).
-- 
on will quit theObject
	if windowOpened then
		getSettingsFromUI()
		writeSettings()
	end if
end will quit

-- This event handler is called when a UI object is clicked (any object that is linked to this handler in Interface Builder that is...). 
-- 
on clicked theObject
	if name of theObject is "make" then
		-- Make sure that we have at least one item to make into an archive. 
		if (count of fileNames) is greater than 0 then
			-- Get the current settings in the UI from the settings drawer.
			getSettingsFromUI()
			
			-- Determine a good default name based on the first file item, and then ask for the archive name.
			set defaultName to last word of (item 1 of fileNames as string) & ".tar"
			if compressArchive then set defaultName to defaultName & ".gz"
			
			-- Setup the 'save panel'
			tell save panel
				set title to "Save Archive As"
				set prompt to "Make"
				set treat packages as directories to false
			end tell
			
			-- Display the save panel as a sheet (we will do the processing in the 'on panel ended' handler)
			display save panel in directory defaultLocation with file name defaultName attached to window of theObject
		else
			-- Alert the user that they need to have at least one file item.
			display alert "Missing Files/Folders" as critical message "You must add files or folders by dragging them on to the application icon in order to make an archive." attached to window "main"
		end if
	else if name of theObject is "settings" then
		-- This simply toggles the state of the 'settings' button, showing/hiding the settings drawer as needed.
		tell window "main"
			set currentState to state of drawer "settings"
			
			if currentState is drawer closed then
				my showSettings()
			else if currentState is drawer opened then
				my hideSettings()
			end if
			
		end tell
	else if name of theObject is "choose" then
		-- Choose the default location (folder) in which to store the archive when the application is used as a droplet (without the main window begin shown.)
		chooseDefaultLocation()
	end if
end clicked

-- This event handler is called when the save panel (which was shown as a sheet) has been concluded.
--
on panel ended theObject with result withResult
	if theObject is the open panel then
		if withResult is 1 then
			set theLocation to item 1 of (path names of open panel as list)
			set contents of text field "default location" of drawer "settings" of window "main" to theLocation as string
		end if
	else if theObject is the save panel and withResult is 1 then
		-- We need to hide the panel as we might be putting up a progress panel next
		set visible of save panel to false
		
		-- Show the progress panel (if requested).
		if showProgress then
			showProgressPanel(true, path name of save panel)
		end if
		
		-- The main point of this entire application. Make the archive (which expects everything to be a POSIX path.
		set theResult to makeArchive(path name of save panel)
		
		-- If requested, show the results of the make in the log window
		if verboseMode then
			set contents of text view "log" of scroll view "log" of window "log" to theResult
			show window "log"
		end if
		
		-- Hide the progres panel (if shown)
		if showProgress then
			hideProgressPanel(true)
		end if
	end if
end panel ended


(* ==== Handlers ==== *)

-- This is the bread and butter of the application. It simply creates the command to be issued to 'do shell script' and returns the result.
-- 
on makeArchive(archiveName)
	-- The 'gnutar' command in it's basic strucure.
	set scriptCommand to "gnutar " & getOptionsString() & " -f " & archiveName
	
	-- Add each of the file items to the command.
	repeat with fileName in fileNames
		set scriptCommand to scriptCommand & space & fileName
	end repeat
	
	-- Tell the shell to do it's thing.
	return do shell script scriptCommand
end makeArchive

-- Returns the various options chosen by the user in a simple string beginning with the required '-c' which is used to tell 'gnutar' to create a new archive. You can do a 'man gnutar' to see all of the options in a terminal window.
-- 
on getOptionsString()
	set optionsString to "-c"
	
	if compressArchive then
		set optionsString to optionsString & "z"
	end if
	if preserveIDs then
		set optionsString to optionsString & "p"
	end if
	if followLinks then
		set optionsString to optionsString & "h"
	end if
	if verboseMode then
		set optionsString to optionsString & "v"
	end if
	
	return optionsString
end getOptionsString

-- Returns a self determined archive name based on the first item in the file item list.
-- 
on getArchiveFileName()
	set archiveFileName to ""
	
	-- Prepend the file name with the default location
	if defaultLocation is not equal to "" then
		set archiveFileName to defaultLocation
		if archiveFileName does not end with "/" then
			set archiveFileName to archiveFileName & "/"
		end if
	end if
	
	-- Append the last word of the first item plus a '.tar'  or '.tar.gz' (which is the normal extension for tar files.
	set archiveFileName to archiveFileName & last word of (item 1 of fileNames as string) & ".tar"
	if compressArchive then set archiveFileName to archiveFileName & ".gz"
	
	return archiveFileName
end getArchiveFileName

-- Loads the progress panel (if needed) and then displays it.
-- 
on showProgressPanel(attachedToWindow, archiveFileName)
	-- Only load the progress panel once.
	if progressPanel is missing value then
		load nib "ProgressPanel"
		set progressPanel to window "progress"
	end if
	
	-- Set the status item in the progress panel
	set content of text field "status" of progressPanel to "Making Archive: " & (call method "lastPathComponent" of archiveFileName)
	
	-- Display the progress panel appropriately.
	if attachedToWindow then
		display panel progressPanel attached to window "main"
	else
		show progressPanel
	end if
	
	-- Start spinning the progress bar.
	tell progressPanel
		set uses threaded animation of progress indicator "progress" to true
		tell progress indicator "progress" to start
	end tell
end showProgressPanel

-- Hides the progress panel.
-- 
on hideProgressPanel(attachedToWindow)
	if attachedToWindow then
		tell progress indicator "progress" of progressPanel to stop
		close panel progressPanel
	else
		hide progressPanel
	end if
	
	-- Set the status item in the progress panel
	set content of text field "status" of progressPanel to ""
end hideProgressPanel

-- Shows the main window, doing any necessary setup of the drawer as necessary.
-- 
on showWindow()
	tell window "main"
		tell drawer "settings"
			-- Initialize some settings to appropriate values for the settings drawer. These will set the current, min and max contents size to be the same, which will have the effect of keeping the settings drawer size appropriate to it's contents. (In other words it can't grow or shrink.) 
			set leading offset to 20
			set trailing offset to 20
			set content size to {436, 136}
			set minimum content size to {436, 136}
			set maximum content size to {436, 136}
			
			-- Set the UI settings
			my setSettingsInUI()
		end tell
		
		set visible to true
	end tell
	
	set windowOpened to true
end showWindow

-- Shows the current list of file names as a list of strings in the text view of the main window.
-- 
on updateFileNamesInUI()
	tell window "main"
		set AppleScript's text item delimiters to return
		set contents of text view "files" of scroll view "files" to fileNames as string
		set AppleScript's text item delimiters to ""
	end tell
end updateFileNamesInUI

-- Prompts the user to select a default location for new archives.
-- 
on chooseDefaultLocation()
	-- Setup the open panel properties
	tell open panel
		set can choose directories to true
		set can choose files to false
		set prompt to "Choose"
	end tell
	
	display open panel attached to window "main"
end chooseDefaultLocation

-- Show's the settings drawer, also adjusting the title of the 'settings' button.
-- 
on showSettings()
	tell window "main"
		tell drawer "settings" to open drawer on bottom edge
		set title of button "settings" to "Hide Settings"
	end tell
end showSettings

-- Hide's the settings drawer, also adjusting the title of the 'settings' button.
-- 
on hideSettings()
	tell window "main"
		tell drawer "settings" to close drawer
		set title of button "settings" to "Show Settings"
	end tell
end hideSettings

-- Sets the settings properties based on the states of the various UI items in the settings drawer.
-- 
on getSettingsFromUI()
	tell drawer "settings" of window "main"
		set defaultLocation to contents of text field "default location"
		set openWindowOnLaunch to (state of button "open window") as boolean
		set showProgress to (state of button "show progress") as boolean
		set compressArchive to (state of button "compress archive") as boolean
		set preserveIDs to (state of button "preserve ids") as boolean
		set followLinks to (state of button "follow links") as boolean
		set verboseMode to (state of button "verbose mode") as boolean
	end tell
end getSettingsFromUI

-- Sets the state of the UI elements int he settings drawer based upon the settings properties.
-- 
on setSettingsInUI()
	tell drawer "settings" of window "main"
		set contents of text field "default location" to defaultLocation
		set state of button "open window" to openWindowOnLaunch
		set state of button "show progress" to showProgress
		set state of button "compress archive" to compressArchive
		set state of button "preserve ids" to preserveIDs
		set state of button "follow links" to followLinks
		set state of button "verbose mode" to verboseMode
	end tell
end setSettingsInUI

-- Registers the settings (application preferences) with the 'user defaults'. 
-- 
on registerSettings()
	tell user defaults
		-- Add all of the new defalt entries
		make new default entry at end of default entries with properties {name:"openWindowOnLaunch", contents:openWindowOnLaunch}
		make new default entry at end of default entries with properties {name:"showProgress", contents:showProgress}
		make new default entry at end of default entries with properties {name:"compressArchive", contents:compressArchive}
		make new default entry at end of default entries with properties {name:"preserveIDs", contents:preserveIDs}
		make new default entry at end of default entries with properties {name:"followLinks", contents:followLinks}
		make new default entry at end of default entries with properties {name:"verboseMode", contents:verboseMode}
		make new default entry at end of default entries with properties {name:"defaultLocation", contents:defaultLocation}
		
		-- Now we need to register the new entries in the user defaults
		register
	end tell
end registerSettings

-- Reads the settings (application preferences) from the 'user defaults'. 
-- 
on readSettings()
	tell user defaults
		set openWindowOnLaunch to contents of default entry "openWindowOnLaunch" as boolean
		set showProgress to contents of default entry "showProgress" as boolean
		set compressArchive to contents of default entry "compressArchive" as boolean
		set preserveIDs to contents of default entry "preserveIDs" as boolean
		set followLinks to contents of default entry "followLinks" as boolean
		set verboseMode to contents of default entry "verboseMode" as boolean
		set defaultLocation to contents of default entry "defaultLocation"
	end tell
end readSettings

-- Writes the settings (application preferences) to the 'user defaults'. 
-- 
on writeSettings()
	tell user defaults
		set contents of default entry "openWindowOnLaunch" to openWindowOnLaunch
		set contents of default entry "showProgress" to showProgress
		set contents of default entry "compressArchive" to compressArchive
		set contents of default entry "preserveIDs" to preserveIDs
		set contents of default entry "followLinks" to followLinks
		set contents of default entry "verboseMode" to verboseMode
		set contents of default entry "defaultLocation" to defaultLocation
	end tell
end writeSettings


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Assistant.applescript *)

(* This application is to present one possible implementation of an 'Assistant'. The strategy that is used is to use a tab view and use seperate tab view items to represent an information panel. The tab view is set without a border or visible tabs. This gives the appearance of a panel full of UI elements to being switched in and out. The design also supports the ability to easily add, remove or change the order of info panels. One thing of note is that and that is incorporated in this strategy is that UI elements of tab view items that are not the current tab view item are not accessible. The way a tab view works is by adding and removing the tab view item's view in and out of the view hierarchy. Since AppleScript needs to be able to walk that view hierarchy to get access to the UI elements in the sub views. Thus, the properties of each info panel is updated before the tab view item is switched out. *)

(* The structure of this script is as follows:
	Properties		Properties needed for the application.
	Script Objects		Model/Controller objects that are specific to each info panel.
	Event Handlers	Handlers that are called by actions in the UI.
	Handlers 			Handlers that interact with the script objects and as well as the UI.
*)


(* ==== Properties === *)

property infoPanels : {}
property currentInfoPanelIndex : 1
property statusImages : {}


(* ==== Script Objects ==== *)

-- This is the parent script object that represents an info panel. It has default implementations of all of the handlers that is used throughout this application.
-- 
script InfoPanel
	-- This handler is called when the contents of the UI elements need to be prepared
	on prepareValues(theWindow)
		-- Scripts that inherit from this script need to implement this handler
	end prepareValues
	
	-- This handler is called when the properties need to be updated from the contents of the UI elements
	on updateValues(theWindow)
		-- Scripts that inherit from this script need to implement this handler
	end updateValues
	
	-- This handler is called to allow an info panel to validate it's values, returning false if the data isn't valid (or is missing)
	on validateValues(theWindow)
		-- Scripts that inherit from this script need to implement this handler
		return true
	end validateValues
	
	-- This handler is called when a summary of the property values is needed.
	on summarizeValues()
		-- Scripts that inherit from this script need to implement this handler
	end summarizeValues
	
	-- This handler will set the focus on the UI element that has a problem and then presents an alert.
	on postValidationAlert(theMessage, theTextField, theWindow)
		-- Move to the field that is missing it's information
		set first responder of theWindow to theTextField
		
		-- Display the alert
		display alert "Missing Information" as critical message theMessage attached to theWindow
	end postValidationAlert
end script


-- This script represents the reporter info panel that contains the personal information about the person reporting the problem.
-- 
script ReporterInfoPanel
	property parent : InfoPanel
	property infoPanelName : "reporter"
	property infoPanelInstruction : "Please enter your personal information."
	
	property company : ""
	property name : ""
	property address : ""
	property city : ""
	property zip : ""
	property state : ""
	property email : ""
	
	-- This handler is called when the properties need to be updated from the contents of the UI elements
	-- 
	on updateValues(theWindow)
		tell view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow
			set my company to contents of text field "company"
			set my name to contents of text field "name"
			set my address to contents of text field "address"
			set my city to contents of text field "city"
			set my state to contents of text field "state"
			set my zip to contents of text field "zip"
			set my email to contents of text field "email"
		end tell
	end updateValues
	
	-- This handler is called to allow an info panel to validate it's values, returning false if the data isn't valid (or is missing)
	-- 
	on validateValues(theWindow)
		set isValid to true
		
		-- We need to have at least the name and email
		if name is "" then
			postValidationAlert("You must enter a name.", text field "name" of view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow, theWindow)
			set isValid to false
		else if email is "" then
			postValidationAlert("You must enter an e-mail address.", text field "email" of view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow, theWindow)
			set isValid to false
		end if
		
		return isValid
	end validateValues
	
	-- This handler is called when a summary of the property values is needed.
	-- 
	on summarizeValues()
		set theSummary to company & return
		set theSummary to theSummary & name & return
		set theSummary to theSummary & address & return
		set theSummary to theSummary & city & ", " & state & " " & zip & return
		set theSummary to theSummary & email & return
		return theSummary
	end summarizeValues
end script


-- This script represents the problem info panel that contains the information about the problem itself.
-- 
script ProblemInfoPanel
	property parent : InfoPanel
	property infoPanelName : "problem"
	property infoPanelInstruction : "Please describe your problem."
	
	property product : ""
	property version : ""
	property severity : ""
	property reproducible : ""
	property description : ""
	
	-- This handler is called when the properties need to be updated from the contents of the UI elements
	-- 
	on updateValues(theWindow)
		tell view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow
			set my product to contents of text field "product"
			set my version to contents of text field "version"
			set my severity to title of current cell of matrix "severity"
			set my reproducible to title of current menu item of popup button "reproducible"
			set my description to contents of text view "description" of scroll view "scroll"
		end tell
	end updateValues
	
	-- This handler is called to allow an info panel to validate it's values, returning false if the data isn't valid (or is missing)
	-- 
	on validateValues(theWindow)
		set isValid to true
		
		-- We need to have at the very least the product info, version info and description info
		if product is "" then
			postValidationAlert("You must enter a product name.", text field "product" of view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow, theWindow)
			set isValid to false
		else if version is "" then
			postValidationAlert("You must enter the version of the product.", text field "version" of view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow, theWindow)
			set isValid to false
		else if description is "" then
			postValidationAlert("You must enter a description of the problem.", text field "description" of view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow, theWindow)
			set isValid to false
		end if
		
		return isValid
	end validateValues
	
	-- This handler is called when a summary of the property values is needed.
	-- 
	on summarizeValues()
		set theSummary to "Product: " & tab & product & " version " & version & return
		set theSummary to theSummary & "Severity: " & tab & severity & return
		set theSummary to theSummary & "Reproducible: " & tab & reproducible & return
		set theSummary to theSummary & "Description: " & return
		set theSummary to theSummary & description & return
		return theSummary
	end summarizeValues
	
end script


-- This script represents the comments info panel that contains the comments from the reporter.
-- 
script CommentsInfoPanel
	property parent : InfoPanel
	property infoPanelName : "comments"
	property infoPanelInstruction : "Please enter any comments."
	
	property comments : ""
	
	-- This handler is called when the properties need to be updated from the contents of the UI elements
	-- 
	on updateValues(theWindow)
		tell view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow
			set my comments to contents of text view "comments" of scroll view "scroll"
		end tell
	end updateValues
	
	-- This handler is called when a summary of the property values is needed.
	-- 
	on summarizeValues()
		set theSummary to "Comments: " & return
		set theSummary to theSummary & comments & return
		return theSummary
	end summarizeValues
end script


-- This script represents the review info panel, that allows the reporter a chance to see a summary of all of the information before it will be sent.
-- 
script ReviewInfoPanel
	property parent : InfoPanel
	property infoPanelName : "review"
	property infoPanelInstruction : "Please review before sending."
	
	property reviewSummary : ""
	
	-- This handler is called when the contents of the UI elements need to be prepared
	-- 
	on prepareValues(theWindow)
		set theSummary to summarizeValues()
		tell view of tab view item "review" of tab view "info panels" of box "border" of theWindow
			set contents of text view "review" of scroll view "scroll" to theSummary
		end tell
	end prepareValues
	
	-- This handler is called when the properties need to be updated from the contents of the UI elements
	-- 
	on updateValues(theWindow)
		tell view of tab view item infoPanelName of tab view "info panels" of box "border" of theWindow
			set my reviewSummary to contents of text view "review" of scroll view "scroll"
		end tell
	end updateValues
	
	-- This handler is called when a summary of the property values is needed.
	-- 
	on summarizeValues()
		set theSummary to ""
		
		-- Since this is the review info panel, we'll get the summary from all of the other info panels and put them together
		repeat with n from 1 to ((count of infoPanels) - 1)
			set theSummary to theSummary & summarizeValues() of item n of infoPanels & return
		end repeat
		
		return theSummary
	end summarizeValues
end script


(* ==== Event Handlers ==== *)

-- This event handler is called when the application is finished launching. It's a good place to to any initialization before showing the main window.
-- 

on launched theObject
	-- Load the images
	set statusImages to {(load image "DotBlue"), (load image "DotGray")}
	
	-- Setup the info panel list. The order of the panels is established here. You can easily change the order that they are presented by changing their order here in this list. The only other thing you need to keep synchronized is the status text items in the left hand portion of the window.
	set infoPanels to {ReporterInfoPanel, ProblemInfoPanel, CommentsInfoPanel, ReviewInfoPanel}
	
	-- Switch to the first info panel
	switchToFirstInfoPanel(window "main")
	
	set visible of window "main" to true
end launched


-- This event handler is called when a button is clicked, in this case the 'go back' or 'continue' buttons.
-- 
on clicked theObject
	if name of theObject is "continue" then
		if currentInfoPanelIndex is equal to (count of infoPanels) then
			-- On the last panel, the button has changed to 'Send' so send the gathered information 
			sendInformation(window of theObject)
		else
			-- Switch to the next info panel
			switchToNextInfoPanel(window of theObject)
		end if
	else if name of theObject is "back" then
		-- Switch to the previous info panel
		switchToPreviousInfoPanel(window of theObject)
	end if
end clicked


-- This event handler is called when the tab view is about to switch tab items. You can control the result by returning 'true' to allow the selection to happen, or 'false' to cancel it. Here we will collect the information from each panel and then validate the information and make our decision based upon the validation as to whether or not we will allow the selection to change.
-- 
on should select tab view item theObject tab view item tabViewItem
	set isValid to true
	
	-- We only want to update and validate if the window is visible
	if window of theObject is visible then
		-- Update the current info panel with the contents of the UI
		updateCurrentInfoPanel(window of theObject)
		
		-- Validate the current  info panel to see if we should move on
		set isValid to validateCurrentInfoPanel(window of theObject)
	end if
	
	-- Return the validity status (true if it's ok to select the tab, false if it's not)
	return isValid
end should select tab view item


-- This event handler is called when the current tab view item has been changed. 
-- 
on selected tab view item theObject tab view item tabViewItem
	-- We will give the new info panel a chance to prepare it's data values
	prepareValues(window of theObject) of infoPanelWithName(name of tabViewItem)
end selected tab view item


(* ==== Handlers ==== *)

-- This handler will attempt to switch to the indicated info panel and change the UI to reflect that change.
-- 
on switchToInfoPanel(theIndex, theWindow)
	tell theWindow
		set theInfoPanelName to infoPanelName of item theIndex of infoPanels
		set theInfoPanelInstruction to infoPanelInstruction of item theIndex of infoPanels
		
		-- Attempt to switch to the indicated tab view item
		tell tab view "info panels" of box "border"
			set current tab view item to tab view item theInfoPanelName
			
			-- The tab may not change due to validation checking, so make sure we have changed
			if name of current tab view item is not equal to theInfoPanelName then
				return
			end if
		end tell
		
		-- Update the current index
		set currentInfoPanelIndex to theIndex
		
		-- Update the instructions
		tell box "instructions"
			set contents of text field "instructions" to theInfoPanelInstruction
		end tell
		
		-- Update the 'back' button. 
		if theIndex is 1 then
			-- Hide it on the first panel.
			set visible of button "back" to false
		else
			-- Show it on all others
			set visible of button "back" to true
		end if
		
		-- Update the 'continue' button. 
		if theIndex is (count of infoPanels) then
			-- Set the title to 'Send' if we are on the last panel.
			set title of button "continue" to "Send"
		else
			-- Otherwise set it to 'Continue'
			set title of button "continue" to "Continue"
		end if
		
		-- Update the status images
		repeat with index from 1 to count of infoPanels
			-- Get the name of the info panel
			set infoPanelName to infoPanelName of item index of infoPanels
			
			-- We will be setting the status image to blue for any info panels up to the current index, otherwise we'll set it to gray
			if index ≤ currentInfoPanelIndex then
				set image of image view infoPanelName to item 1 of statusImages
			else
				set image of image view infoPanelName to item 2 of statusImages
			end if
		end repeat
	end tell
end switchToInfoPanel


-- Switches to the the first info panel (called upon startup of the application)
-- 
on switchToFirstInfoPanel(theWindow)
	-- Switch to the first item in the info panels list
	switchToInfoPanel(1, theWindow)
end switchToFirstInfoPanel


-- Switches to the the next info panel if available
-- 
on switchToNextInfoPanel(theWindow)
	-- Make sure that we aren't already on the last panel
	if currentInfoPanelIndex is less than (count of infoPanels) then
		switchToInfoPanel(currentInfoPanelIndex + 1, theWindow)
	end if
end switchToNextInfoPanel


-- Switches to the the previous info panel if available
-- 
on switchToPreviousInfoPanel(theWindow)
	-- Make sure that we aren't already on the first panel
	if currentInfoPanelIndex is greater than 1 then
		switchToInfoPanel(currentInfoPanelIndex - 1, theWindow)
	end if
end switchToPreviousInfoPanel


-- This handler will tell the current info panel to set it's properties values from the UI objects in it's panel
-- 
on updateCurrentInfoPanel(theWindow)
	tell item currentInfoPanelIndex of infoPanels to updateValues(theWindow)
end updateCurrentInfoPanel


-- This handler will validate the current info panel, to ensure that the required data is present and valid
-- 
on validateCurrentInfoPanel(theWindow)
	return validateValues(theWindow) of item currentInfoPanelIndex of infoPanels
end validateCurrentInfoPanel


-- This event handler handles sending the gathered information to (wherever)
-- 
on sendInformation(theWindow)
	-- Get the summary information from the the Review info panel
	set theInformation to reviewSummary of ReviewInfoPanel
	
	-- Send this information
	-- *** This is left blank as it is implementation dependent and is left as an exercise ***
end sendInformation


-- This is a utility handler that is called to return the info panel with the given name
-- 
on infoPanelWithName(theName)
	set theInfoPanel to null
	
	repeat with thePanel in infoPanels
		if infoPanelName of thePanel is equal to theName then
			set theInfoPanel to thePanel
			exit repeat
		end if
	end repeat
	
	return theInfoPanel
end infoPanelWithName


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* This example demonstrates how to script a browser object. The main parts of the script are the "number of browser rows" event handler which needs to return number of rows in the browser for the given column, and the "will display browser cell" event handler that will be called for every item in the browser. *)

(* ==== Properties ==== *)

property diskNames : {}


(* ==== Event Handlers ==== *)

-- Initialize various items here
--
on launched theObject
	tell application "Finder"
		set diskNames to name of every disk as list
	end tell
	
	set path separator of browser "browser" of window "main" to ":"
	
	tell browser "browser" of window "main" to update
end launched

-- Return the number of rows for the given column
--
on number of browser rows theObject in column theColumn
	set rowCount to 0
	
	if (count of diskNames) > 0 then
		if theColumn is 1 then
			set rowCount to count of diskNames
		else
			tell browser "browser" of window "main"
				set thePath to path for column theColumn - 1
			end tell
			
			tell application "Finder"
				set rowCount to count of items of item thePath
			end tell
		end if
	end if
	
	return rowCount
end number of browser rows

-- This is called whenever a cell in the browser needs to be displayed.
--
on will display browser cell theObject row theRow browser cell theCell in column theColumn
	if theColumn > 1 then
		tell browser "browser" of window "main"
			set thePath to path for column theColumn
		end tell
	end if
	
	tell application "Finder"
		if theColumn is 1 then
			set cellContents to displayed name of disk (item theRow of diskNames as string)
			set isLeaf to false
		else
			set theItem to item theRow of item thePath
			
			if class of theItem is folder or class of theItem is disk then
				set isLeaf to false
			else
				set isLeaf to true
			end if
			
			set cellContents to (displayed name of theItem as string)
		end if
	end tell
	
	set string value of theCell to cellContents
	set leaf of theCell to isLeaf
	
end will display browser cell


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Tool Helper.applescript *)

(* This example will help to find shell commands and then provide a window containing the man page for that command. You choose how to search by choosing from several choices in a popup button: "begins with", "contains", "ends with" and "is". The strategy employed is to get a list of all of the command names at starup and then search through that list when requested, displaying the results of the ones found. *)


(* ==== Properties ==== *)

property commandsDataSource : missing value
property commandNames : {}
property manPageWindow : missing value


(* ==== Event Handlers ==== *)

-- The "will finish launching" event handler is the first event handler called in the startup sequence and is a good place to do any type of initialization work that doesn't require any UI. For this example we will get a list of all of the command names.
--
on will finish launching theObject
	-- The quickest method of getting a list of all of the command names appears to be to get the information using "ls" in a "do shell script". We want to get a list of all of the commands from the following locations: /bin, /usr/bin, /usr/sbin. We can do this by concating the commands together with the ";" character and then piping ("|") the results through the "sort" shell command passing it the "-u" option which eliminates any duplicates. We then take the result from the do shell command (which will be a string with return characters between each item) and convert it to a list of strings.
	set commandNames to every paragraph of (do shell script "ls /usr/bin ; ls /usr/sbin ; ls /bin | sort -u")
end will finish launching


-- The "awake from nib" event handler is called when the object is loaded from a nib file. It's a good place to initialize one or more items.
--
on awake from nib theObject
	if name of theObject is "main" then
		-- When the window is loaded, be sure to hide the status items
		hideStatus(theObject)
	else if name of theObject is "man page" then
		-- If the man page window is being loaded then set a reference to it
		set manPageWindow to theObject
	else if name of theObject is "commands" then
		-- Create the data source
		set commandsDataSource to make new data source at end of data sources with properties {name:"commands"}
		
		-- Create the data columns
		make new data column at end of data columns of commandsDataSource with properties {name:"command"}
		make new data column at end of data columns of commandsDataSource with properties {name:"description"}
		
		-- Assign the data source to the table view
		set data source of theObject to commandsDataSource
	end if
end awake from nib


-- The "launched" is one of the last event handlers that is called in the startup sequence. In this case we want to show our main window.
--
on launched theObject
	show window "main"
end launched


-- The "clicked" event handler is called (in this example) when the "Find" button is clicked. We then initiate our find process.
--
on clicked theObject
	if name of theObject is "find" then
		findCommands(window of theObject)
	end if
end clicked


on double clicked theObject
	if name of theObject is "commands" then
		-- Show and update the message items in the main window
		showStatus(window of theObject)
		updateStatusMessage(window of theObject, "Getting the man page...")
		
		-- Get the clicked row of the table view
		set theRow to clicked row of theObject
		set theDataRow to data row theRow of data source of theObject
		
		-- Get the name of the command
		set theCommandName to contents of data cell "command" of theDataRow
		
		-- See if the window is already open
		set theWindow to findWindowWithTitle(theCommandName)
		if theWindow is not missing value then
			-- Just bring it to the front
			show theWindow
		else
			-- Load a new instance of the man page window and show it
			load nib "ManPage"
			set title of manPageWindow to theCommandName
			
			-- Get the man page for the command, cleaning it up in the process
			set theResult to do shell script "man " & theCommandName & " | perl -pe 's/.\\x08//g'"
			
			-- Put the results into the text view of our man page window
			set contents of text view "man page" of scroll view "man page" of manPageWindow to theResult
			
			-- Show the window
			show manPageWindow
		end if
		
		-- Hide the status items
		hideStatus(window of theObject)
	end if
end double clicked


-- The "action" event handler is called (in this example) when a menu item is chosen from the popup button. We then initiate our find process.
--
on action theObject
	if name of theObject is "how" then
		findCommands(window of theObject)
	end if
end action


(* ==== Handlers ==== *)

-- This handler is called to find any commands that meet the criteria specified in the UI (how and what). It also is responsible for providing any feedback during the find, such as showing, updating and hiding the status items in the window.
--
on findCommands(theWindow)
	-- Show the the status items
	showStatus(theWindow)
	updateStatusMessage(theWindow, "Finding commands...")
	
	-- Find the commands with what coming from the text field, and how coming from the popup button
	set theCommands to commandsWithName(contents of text field "name" of theWindow, title of popup button "how" of theWindow)
	
	-- Turn off the updating of the table view while we load the data source
	set update views of commandsDataSource to false
	
	-- Delete any existing items in the data source
	delete every data row of commandsDataSource
	
	-- Make sure that we actually found at least one command
	if (count of theCommands) > 0 then
		-- Update the status message
		updateStatusMessage(theWindow, "Adding commands...")
		
		-- Add the list of commands to the data source using the "append" command
		append commandsDataSource with theCommands
	end if
	
	-- Turn back on the updating of the table view
	set update views of commandsDataSource to true
	
	-- Hide the status items
	hideStatus(theWindow)
end findCommands


-- This handler is used to look through our list of command names, returning a list of found commands, which also includes getting and returning the description of the command
--
on commandsWithName(whatToFind, howToFind)
	-- Set our result to a known good value, in this case an empty list will do just fine
	set theCommands to {}
	
	-- Make sure that we have a value to find for
	if (count of whatToFind) > 0 then
		-- Set our found names list to an empty list
		set foundCommandNames to {}
		
		-- Based on the "howToFind" repeat through each of the command names in our commandNames list finding the appropriate items and adding it to the foundCommandNames list
		if howToFind is "begins with" then
			repeat with i in commandNames
				if i begins with whatToFind then
					copy i to end of foundCommandNames
				end if
			end repeat
		else if howToFind is "contains" then
			repeat with i in commandNames
				if i contains whatToFind then
					copy i to end of foundCommandNames
				end if
			end repeat
		else if howToFind is "ends with" then
			repeat with i in commandNames
				if i ends with whatToFind then
					copy i to end of foundCommandNames
				end if
			end repeat
		else if howToFind is "is" then
			repeat with i in commandNames
				if (i as string) is equal to whatToFind then
					copy i to end of foundCommandNames
				end if
			end repeat
		end if
		
		-- Make sure that we found at least one command name
		if (count of foundCommandNames) > 0 then
			-- Iterate through each of the found names
			repeat with i in foundCommandNames
				try
					set theDescription to ""
					
					-- We will use the "whatis" shell command to get the description of 
					set theResult to do shell script ("whatis " & (i as string))
					
					-- Unfortunately, the result will look something like "more(1), page(1)         - file perusal filter for crt viewing". We only want to get portion of the text following the " - " characters. This can be done using the following bit of script.
					set dashoffset to offset of " - " in theResult
					set firstReturn to offset of return in theResult
					set theDescription to characters (dashoffset + 2) through (firstReturn - 1) of theResult as string
					
					-- Add the command name and description as a list the end of our command list
					copy {i, theDescription} to end of theCommands
				end try
			end repeat
		end if
	end if
	
	-- Return our result
	return theCommands
end commandsWithName


(* ==== Status Handlers ==== *)

-- This handler will show the various status items in the window, along with starting the animation of the progress indicator
--
on showStatus(theWindow)
	tell theWindow
		set visible of progress indicator "progress" to true
		set visible of text field "status" to true
		set uses threaded animation of progress indicator "progress" to true
		start progress indicator "progress"
	end tell
end showStatus


-- This handler will hide all of the status items in the window, including stopping the animation of the progress indicator
--
on hideStatus(theWindow)
	tell theWindow
		set visible of progress indicator "progress" to false
		set visible of text field "status" to false
		stop progress indicator "progress"
	end tell
end hideStatus


-- This handler will update the status message in the status items of the window
--
on updateStatusMessage(theWindow, theMessage)
	set contents of text field "status" of theWindow to theMessage
end updateStatusMessage


(* ==== Utility Handlers ==== *)

-- This is a utility handler that will simply find the window with the specified title.
--
on findWindowWithTitle(theTitle)
	set theWindow to missing value
	
	set theWindows to every window whose title is theTitle
	if (count of theWindows) > 0 then
		set theWindow to item 1 of theWindows
	end if
	
	return theWindow
end findWindowWithTitle

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Coordinate System.applescript *)

(* This is an example of how to use the new coordinate system support. *)

(* ===== Event Handlers ===== *)

on launched theObject
	show window "main"
end launched

-- This event handler is attached to the window and will be called when it is loaded. It is a good time to update the display in the window to show the current coordinates.
--
on awake from nib theObject
	updateDisplay(theObject)
end awake from nib

-- This event handler is called when the button in our document window is clicked. It will test the various settings of the coordinate system by moving the window and then by moving the button.
--
on clicked theObject
	set theWindow to window of theObject
	set testObject to theWindow
	
	-- Test the Cocoa coordinate system on a window. This system uses {x, y, width, height}, with the origin of a window or view in the lower left corner being 0, 0
	set coordinate system to Cocoa coordinate system
	set testBounds to bounds of testObject
	set testPosition to position of testObject
	set bounds of testObject to {50, 50, 500, 500}
	delay 1
	set position of testObject to {150, 150}
	updateDisplay(theWindow)
	delay 1
	
	-- Test the old (classic) coordinate system on a window. This system uses {left, bottom, right, top}, with the origin of a window or view in the bottom left corner being 0, 0
	set coordinate system to classic coordinate system
	set testBounds to bounds of testObject
	set testPosition to position of testObject
	set bounds of testObject to {50, 50, 500, 500}
	delay 1
	set position of testObject to {150, 150}
	updateDisplay(theWindow)
	delay 1
	
	-- Test the AppleScript coordinate system on a window. This system uses {left, top, right, bottom}, with the origin of a window or view in the top left corner being 0, 0
	set coordinate system to AppleScript coordinate system
	set testBounds to bounds of testObject
	set testPosition to position of testObject
	set bounds of testObject to {50, 50, 500, 500}
	delay 1
	set position of testObject to {150, 150}
	updateDisplay(theWindow)
	delay 1
	
	set testObject to theObject
	
	-- Test the Cocoa coordinate system on our button. This system uses {x, y, width, height}, with the origin of a window or view in the lower left corner being 0, 0
	set coordinate system to Cocoa coordinate system
	set testBounds to bounds of testObject
	set testPosition to position of testObject
	set bounds of testObject to {0, 0, 82, 30}
	delay 1
	set position of testObject to {10, 10}
	updateDisplay(theWindow)
	delay 1
	
	-- Test the old (classic) coordinate system on our button. This system uses {left, bottom, right, top}, with the origin of a window or view in the bottom left corner being 0, 0
	set coordinate system to classic coordinate system
	set testBounds to bounds of testObject
	set testPosition to position of testObject
	set bounds of testObject to {0, 0, 82, 30}
	delay 1
	set position of testObject to {10, 10}
	updateDisplay(theWindow)
	delay 1
	
	-- Test the AppleScript coordinate system on our button. This system uses {left, top, right, bottom}, with the origin of a window or view in the top left corner being 0, 0
	set coordinate system to AppleScript coordinate system
	set testBounds to bounds of testObject
	set testPosition to position of testObject
	set bounds of testObject to {0, 0, 82, 30}
	delay 1
	set position of testObject to {10, 10}
	updateDisplay(theWindow)
end clicked

-- This event handler is called when the coordinate system popup button is changed. It will change the coordinate system and update the display.
--
on action theObject
	set popupChoice to content of theObject
	
	if popupChoice is 0 then
		set coordinate system to Cocoa coordinate system
	else if popupChoice is 1 then
		set coordinate system to classic coordinate system
	else if popupChoice is 2 then
		set coordinate system to AppleScript coordinate system
	end if
	
	updateDisplay(window of theObject)
end action

-- This event handler is called when the window moves. It will update the display to show the current coordinates.
--
on moved theObject
	updateDisplay(theObject)
end moved

-- This event handler is called when the window resizes. It will update the display to show the current coordinates.
--
on resized theObject
	updateDisplay(theObject)
end resized

(* =====  Handlers ===== *)

-- This handler is used to get the coordinates of the window and button and display a description in the window.
--
on updateDisplay(theWindow)
	set theButton to button "button" of theWindow
	
	set windowBounds to bounds of theWindow
	set windowPosition to position of theWindow
	set buttonBounds to bounds of theButton
	set buttonPosition to position of theButton
	
	if coordinate system is Cocoa coordinate system then
		set coordinateSystemDescription to 0
		set windowBoundsDescription to "{x: " & item 1 of windowBounds & ", y: " & item 2 of windowBounds & ", w: " & item 3 of windowBounds & ", h: " & item 4 of windowBounds & "}"
		set windowPositionDescription to "{x: " & item 1 of windowPosition & ", y: " & item 2 of windowPosition & "}"
		set buttonBoundsDescription to "{x: " & item 1 of buttonBounds & ", y: " & item 2 of buttonBounds & ", w: " & item 3 of buttonBounds & ", h: " & item 4 of buttonBounds & "}"
		set buttonPositionDescription to "{x: " & item 1 of buttonPosition & ", y: " & item 2 of buttonPosition & "}"
	else if coordinate system is classic coordinate system then
		set coordinateSystemDescription to 1
		set windowBoundsDescription to "{l: " & item 1 of windowBounds & ", b: " & item 2 of windowBounds & ", r: " & item 3 of windowBounds & ", t: " & item 4 of windowBounds & "}"
		set windowPositionDescription to "{l: " & item 1 of windowPosition & ", b: " & item 2 of windowPosition & "}"
		set buttonBoundsDescription to "{l: " & item 1 of buttonBounds & ", b: " & item 2 of buttonBounds & ", r: " & item 3 of buttonBounds & ", t: " & item 4 of buttonBounds & "}"
		set buttonPositionDescription to "{l: " & item 1 of buttonPosition & ", b: " & item 2 of buttonPosition & "}"
	else if coordinate system is AppleScript coordinate system then
		set coordinateSystemDescription to 2
		set windowBoundsDescription to "{l: " & item 1 of windowBounds & ", t: " & item 2 of windowBounds & ", r: " & item 3 of windowBounds & ", b: " & item 4 of windowBounds & "}"
		set windowPositionDescription to "{l: " & item 1 of windowPosition & ", t: " & item 2 of windowPosition & "}"
		set buttonBoundsDescription to "{l: " & item 1 of buttonBounds & ", t: " & item 2 of buttonBounds & ", r: " & item 3 of buttonBounds & ", b: " & item 4 of buttonBounds & "}"
		set buttonPositionDescription to "{l: " & item 1 of buttonPosition & ", t: " & item 2 of buttonPosition & "}"
	end if
	
	tell theWindow
		set content of popup button "coordinate system" to coordinateSystemDescription
		set content of text field "window bounds" to windowBoundsDescription
		set content of text field "window position" to windowPositionDescription
		set content of text field "button bounds" to buttonBoundsDescription
		set content of text field "button position" to buttonPositionDescription
	end tell
end updateDisplay

(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Coundown Timer.applescript *)

(* This is a simple example the demonstrates how to idle event to do a countdown timer. When the application is launched it will display the countdown window with a sheet asking for the amount of time for the countdown, after which the countdown begins and when the specified time has elapsed, it displays an alert. *)

(* ===== Properties ===== *)

property countdown : false
property currentDate : 0
property startDate : 0
property endDate : 0


(* ===== Event Handlers ===== *)

on launched theObject
	-- Show the window
	set visible of window "main" to true
	
	-- Display an alert (as a sheet) asking for the amount of time in the HH:MM:SS format
	display dialog "Enter the amount of time for the countdown timer:" default answer "00:00:05" attached to window "main"
end launched

on dialog ended theObject with reply withReply
	-- See if the "OK" button has been clicked
	if button returned of withReply is "OK" then
		-- Save the current date for display purposes
		set currentDate to date (text returned of withReply)
		
		-- Save the start date
		set startDate to current date
		
		-- And determine the end date (start date + the countdown timer)
		set endDate to startDate + (time of currentDate)
		
		-- Update the contents of the text field
		set contents of text field "display" of window "main" to currentDate
		
		-- And let the processing in the idle event handler begin
		set countdown to true
	end if
end dialog ended

on idle theObject
	-- See if we are ready to start counting down
	if countdown then
		-- If the required amount of time has elapsed then display our dialog 
		if (current date) is greater than endDate then
			set countdown to false
			display alert "Time's Up!"
		else
			-- Otherwise determine how much time has elapsed (for display purposes)
			set elapsedTime to (current date) - startDate
			
			-- Update the display
			set contents of text field "display" of window "main" to currentDate - elapsedTime
		end if
	end if
	
	-- We want to update the idle event every second, so we return 1
	return 1
end idle


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* This is a very simple example that illustrates getting and setting the contents of text fields. It is a simple currency converter based on a '(rate * amount) = value' formula. It also uses 'formatters' for the text fields to align and set the number formatting (this is done in Interface Builder by dragging a formatter onto the text field). *)

(* ==== Event Handlers ==== *)

on clicked theObject
	tell window of theObject
		try
			set theRate to contents of text field "rate"
			set theAmount to contents of text field "amount" as number
			
			set contents of text field "total" to theRate * theAmount
		on error
			set contents of text field "total" to 0
		end try
	end tell
end clicked

on should quit after last window closed theObject
	return true
end should quit after last window closed


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Currency Converter.applescript *)

(* This is an enhanced version of Currency Converter that utilizes SOAP services to enable getting the current exchange rate. *)


(* ==== Event Handlers ==== *)

-- The "action" event handler is called when the user choosing a country from the popup button. We will call the "getRate" event handler to use a SOAP service to get the rate.
--
on action theObject
	set contents of text field "rate" of window of theObject to getRate(title of theObject as string)
end action


-- The "clicked" event handler is called when the user clicks on the "Convert" button. This will do a simple calculatin of "rate * dollars" and put the result in the "total" field.
--
on clicked theObject
	tell window of theObject
		set theRate to contents of text field "rate" as real
		set theDollars to contents of text field "dollars" as real
		set contents of text field "total" to theRate * theDollars
	end tell
end clicked


-- The "awake from nib" event handler is called the popup button is loaded form the nib. In this example we will use this opportunity to get the rate (based on the default selection of the popup button).
--
on awake from nib theObject
	set contents of text field "rate" of window of theObject to getRate(title of theObject)
end awake from nib


(* ==== Handlers ==== *)

-- This handler is called to get the current exchange rate for the given country. It does this by using the "call soap" command to communicate with a SOAP web service.
--
on getRate(forCountry)
	-- Initialize the result to a known value
	set theRate to 1.0
	
	-- We always convert from the US	
	set fromCountry to "USA"
	
	-- Talk to the soap service
	tell application "http://services.xmethods.net:80/soap"
		-- Call the "getRate" method of the soap service returning the current rate
		set theRate to call soap {method name:"getRate", method namespace uri:"urn:xmethods-CurrencyExchange", parameters:{country1:fromCountry, country2:forCountry}, SOAPAction:""}
	end tell
	
	-- Return the result
	return theRate
end getRate

-- This is a utility handler to get the given unicode text as plain text (not styled text)
--
on getPlainText(fromUnicodeString)
	set styledText to fromUnicodeString as string
	set styledRecord to styledText as record
	return «class ktxt» of styledRecord
end getPlainText

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Daily Dilbert.applescript *)

(* This is a simple example of how to load an image given a URL from a web service. It utilizes a couple of shell commands (date, curl) to accomplish this. *)


(* ==== Event Handlers ==== *)

-- The "awake from nib" event handler is called when the object is loaded from its nib file. In this case it will be the image view. The script will get the image from the web service and then set that image into the image view. Then the window will be resized appropriately.
--
on awake from nib theObject
	-- We need to have the date in the format "mm/dd/yy" which is actually easier to get from the "date" shell command.
	set theDate to do shell script "date +%m/%d/%y"
	
	-- Get the Dilbert image based on the date
	set theImage to getDilbertImageForDate(theDate)
	set image of theObject to theImage
	
	-- Resize the window
	set the size of (window of theObject) to call method "size" of object theImage
	
	-- Show the window
	show window of theObject
end awake from nib


(* ==== Handlers ==== *)

-- This handler will return the image for the given date. It does this by getting the URL for the image from a web service.
--
on getDilbertImageForDate(theDate)
	set theImage to missing value
	set theImage to loadImageAtURL(DailyDilbertImagePath(theDate))
	return theImage
end getDilbertImageForDate


-- With the given URL, this handler will download the image using the "curl" shell tool. It then will load the image using the "load image" command.
--
on loadImageAtURL(theURL)
	set theImage to missing value
	
	-- Get the last component of the URL. Here we'll use the "lastPathComponent" method of NSString.
	set theImagePath to "/tmp/" & (call method "lastPathComponent" of object theURL)
	
	-- Download the image using "curl"
	do shell script ("curl -o " & theImagePath & " " & theURL)
	
	-- Load the image
	set theImage to load image theImagePath
	
	return theImage
end loadImageAtURL


(* ==== Web Services Handlers ==== *)

-- This handler will return the URL that points to the Dilbert image for the given date.
--
on DailyDilbertImagePath(forDate)
	tell application "http://www.esynaps.com/WebServices/DailyDiblert.asmx"
		set mname to "DailyDilbertImagePath"
		set soapact to "http://tempuri.org/DailyDilbertImagePath"
		set namespace to "http://tempuri.org/"
		set params to {}
		set params to params & {|parameters|:forDate}
		return call soap {method name:mname, parameters:params, SOAPAction:soapact, method namespace uri:namespace}
	end tell
end DailyDilbertImagePath


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Debug Test.applescript *)

(* The purpose of this example is to illustrate the debugging of AppleScript. Many of the properties and values are there mainly to test the debugger in it's ability to show and set the various values. It also illustrates the ability to interact with the UI while in the processing of executing a script. *)

(* ==== Properties ==== *)

property keepRunning : true
property prop1 : "Test property 1"
property prop2 : "Test property 2"
property prop3 : 0


(* ==== Event Handlers ==== *)

-- Here we handle the click on the "Start/Stop" button, toggling between states as necessary.
--
on clicked theObject
	if title of theObject is "Start" then
		set keepRunning to true
		set title of theObject to "Stop"
		set theResult to 2
		runforever()
	else if title of theObject is "Stop" then
		set title of theObject to "Start"
		set keepRunning to false
	end if
end clicked

-- This handler is called after the window is loaded, but before it is displayed.
--
on will open theObject
	set prop3 to 10
end will open

-- This event handler is called just before the window is closed. If you want to stop the window from being closed, you can use the "should close" event handler and return false.
--
on will close theObject
	set keepRunning to false
end will close


(* ==== Handlers ==== *)

-- This is a handler that is called to do a repeat loop until the keepRunning variable gets changed to false. It also animates the barber pole and set the value of the text field.
--
on runforever()
	set numberTest to 1
	set stringTest to "testing"
	
	runonce()
	
	repeat while keepRunning
		tell progress indicator "Barber Pole" of window "Main" to animate
		set prop3 to prop3 + 1
		set numberTest to numberTest + 1
		
		set contents of text field "counter" of window "Main" to numberTest as string
	end repeat
end runforever

on runonce()
	set prop3 to prop3 + 1
	set prop3 to prop3 + 1
	set prop3 to prop3 + 1
	set prop3 to prop3 + 1
	
	runonceagain()
end runonce

on runonceagain()
	set prop3 to prop3 + 1
	set prop3 to prop3 + 1
	set prop3 to prop3 + 1
	set prop3 to prop3 + 1
	
	runlasttime()
end runonceagain

on runlasttime()
	set prop3 to prop3 + 1
end runlasttime


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Display Alert.applescript *)

(* This example demonstrates the "display alert" command. It can be used in place of "display dialog" when you need to alert the user to some condition. The icon is determined by the "as" type. *)

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Display Alert" button is clicked, which when clicked the various parameter values pulled from the text fields to be sent to "display alert". 
--
on clicked theObject
	-- Get the various parameter values
	tell window "main"
		set dialogText to contents of text field "text"
		set dialogMessage to contents of text field "message"
		set defaultButtonTitle to contents of text field "default button"
		set alternateButtonTitle to contents of text field "alternate button"
		set otherButtonTitle to contents of text field "other button"
	end tell
	
	-- Set the "as" type to be either warning, informational or critical based on the setting in the radio group.
	set dialogType to warning
	if current row of matrix "type" of window "main" is 2 then
		set dialogType to informational
	else if current row of matrix "type" of window "main" is 3 then
		set dialogType to critical
	end if
	
	-- If the "as sheet" button is checked  then use the "attached to" optional parameter, in which the "alert ended" event handler will be called when the sheet is dismissed.
	if state of button "as sheet" of window "main" is 1 then
		display alert dialogText as dialogType message dialogMessage default button defaultButtonTitle alternate button alternateButtonTitle other button otherButtonTitle attached to window "main"
	else
		-- Otherwise handle it much like "display dialog"
		set theReply to display alert dialogText as dialogType message dialogMessage default button defaultButtonTitle alternate button alternateButtonTitle other button otherButtonTitle
		set contents of text field "button returned" of window "main" to button returned of theReply
	end if
end clicked

-- This event handler is called if the "attached to" parameter is used. It is called when the dialog has been dismissed. It simply sets the text field to be the button that was pressed to dismiss the dialog.
--
on alert ended theObject with reply theReply
	set contents of text field "button returned" of window "main" to button returned of theReply
end alert ended


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Display Dialog.applescript *)

(* This example will demonstrate the various ways of using the "display dialog" command. The dialog can be displayed as a dialog, or attached to a window as sheet. *)

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Display Dialog" button is clicked. It gets the various settings from the UI elements and passes them to "display dialog" as parameters.
--
on clicked theObject
	-- Initialize all the parameter values that will be passed to display dialog
	tell window "main"
		set dialogText to contents of text field "text"
		set dialogDefaultAnswer to contents of text field "default answer"
		set dialogButton1 to contents of text field "button 1"
		
		set dialogButton2 to contents of text field "button 2"
		set dialogButton3 to contents of text field "button 3"
		set dialogDefaultButton to contents of text field "default button"
		set dialogIcon to contents of text field "icon"
		set dialogGivingUpAfter to contents of text field "giving up" as number
	end tell
	
	-- If we want to have the display dialog presented as a sheet, then we need add the optional parameter "attached to" passing it a window object
	if state of button "as sheet" of window "main" is equal to 1 then
		if dialogDefaultAnswer is "" then
			display dialog dialogText buttons {dialogButton1, dialogButton2, dialogButton3} default button dialogDefaultButton giving up after dialogGivingUpAfter with icon dialogIcon attached to window "main"
		else
			display dialog dialogText default answer dialogDefaultAnswer buttons {dialogButton1, dialogButton2, dialogButton3} default button dialogDefaultButton giving up after dialogGivingUpAfter with icon dialogIcon attached to window "main"
		end if
	else
		-- Otherwise we do it the standard way
		try
			if dialogDefaultAnswer is "" then
				set theReply to display dialog dialogText buttons {dialogButton1, dialogButton2, dialogButton3} default button dialogDefaultButton giving up after dialogGivingUpAfter with icon dialogIcon
			else
				set theReply to display dialog dialogText default answer dialogDefaultAnswer buttons {dialogButton1, dialogButton2, dialogButton3} default button dialogDefaultButton giving up after dialogGivingUpAfter with icon dialogIcon
			end if
			
			-- Set the values returned from the dialog reply
			set contents of text field "text returned" of window "main" to text returned of theReply
			set contents of text field "button returned" of window "main" to button returned of theReply
			set state of button "gave up" of window "main" to gave up of theReply
		on error
			-- The user pressed the "Cancel" button, so display that as the result. We can't use the "theReply" value because it wasn't returned from the "display dialog" call, because of the cancel.
			set contents of text field "button returned" of window "main" to "Cancel"
		end try
	end if
end clicked

-- This handler gets called when the display dialog dialog if finished if it was called with the "attached to" optional parameter.
on dialog ended theObject with reply theReply
	-- Set the values returned in "theReply"
	set contents of text field "text returned" of window "main" to text returned of theReply
	set contents of text field "button returned" of window "main" to button returned of theReply
	set state of button "gave up" of window "main" to gave up of theReply
end dialog ended


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Settings.applescript *)

(* ==== Event Handlers ==== *)

on clicked theObject
	if name of theObject is "cancel" then
		close panel (window of theObject)
	else if name of theObject is "change" then
		close panel (window of theObject) with result 1
	end if
end clicked


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Window.applescript *)

(* This script demonstrates the "display panel" command which allows you to create your own dialogs and have them displayed either as a dialog or attached to a window as a sheet. *)

(* ==== Properties ==== *)

property panelWIndow : missing value

(* ==== Event Handlers ==== *)

on clicked theObject
	set theName to contents of text field "name" of window "main"
	set theType to contents of text field "type" of window "main"
	
	-- Load the panel. We do this by loading the nib that contains the panel window, and then setting our property to the loaded window. Only do this once, as every time the nib is loaded, it will create new copies of all of the top level objects in the nib.
	if panelWIndow is equal to missing value then
		load nib "SettingsPanel"
		set panelWIndow to window "settings"
	end if
	
	-- Set the state of the items in the panel
	tell panelWIndow
		set contents of text field "name" to theName
		if theType is "Button" then
			set current row of matrix "type" to 1
		else if theType is "Popup Button" then
			set current row of matrix "type" to 2
		else if theType is "Radio" then
			set current row of matrix "type" to 3
		else if theType is "Switch" then
			set current row of matrix "type" to 4
		end if
	end tell
	
	-- Display the panel
	if state of button "as sheet" of window "main" is 1 then
		display panel panelWIndow attached to window "main"
	else
		if (display panel panelWIndow) is 1 then
			local theName
			local theType
			
			tell panelWIndow
				set theName to contents of text field "name"
				set selectedRow to current row of matrix "type"
				
				if selectedRow is 1 then
					set theType to "Button"
				else if selectedRow is 2 then
					set theType to "Popup Button"
				else if selectedRow is 3 then
					set theType to "Radio"
				else if selectedRow is 4 then
					set theType to "Switch"
				end if
			end tell
			
			set contents of text field "name" of window "main" to theName
			set contents of text field "type" of window "main" to theType
		end if
	end if
	
end clicked

on panel ended thePanel with result theResult
	if theResult is 1 then
		local theName
		local theType
		
		tell thePanel
			set theName to contents of text field "name"
			set selectedRow to current row of matrix "type"
			
			if selectedRow is 1 then
				set theType to "Button"
			else if selectedRow is 2 then
				set theType to "Popup Button"
			else if selectedRow is 3 then
				set theType to "Radio"
			else if selectedRow is 4 then
				set theType to "Switch"
			end if
		end tell
		
		set contents of text field "name" of window "main" to theName
		set contents of text field "type" of window "main" to theType
	end if
end panel ended


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Button.applescript *)

(* This script is used to register the appropriate drag types for the "button" object and then responds to a drop on it. *)

(* ==== Event Handlers ==== *)

-- The "awake from nib" event handler is a good place to register the drag types that this object can respond to.
--
on awake from nib theObject
	-- Enable the dropping of the appropriate types by registering them.
	tell theObject to register drag types {"string", "rich text", "file names"}
end awake from nib

-- The "drop" event handler is called when the appropriate type of data is dropped onto the object. All of the pertinent information about the drop is contained in the "dragInfo" object.
--
on drop theObject drag info dragInfo
	-- Make sure that we have the "string" data type
	if "string" is in types of pasteboard of dragInfo then
		-- Set the title of the button to the contents of the pasteboard
		set title of theObject to contents of pasteboard of dragInfo
	end if
	
	return true
end drop


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Drag and Drop.applescript *)

(* This script is the main script of the application, although in this case it does very little. It responds to the "Color Chooser" button by displaying the "color panel". *)

(* ==== Event Handlers ==== *)

-- The "clicked" event handler is called when the user clicks on the "Color Chooser" button.
--
on clicked theObject
	-- We simply want to the show the "color panel" so that the user can drag a color from it.
	show the color panel
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Image View.applescript *)

(* This script is used to register the appropriate drag types for the "image view" object and then responds to a drop on it. *)

(* ==== Event Handlers ==== *)

-- The "awake from nib" event handler is a good place to register the drag types that this object can respond to.
--
on awake from nib theObject
	-- Enable the dropping of the appropriate types by registering them.
	tell theObject to register drag types {"image", "pict image", "file names", "color"}
end awake from nib

-- The "drop" event handler is called when the appropriate type of data is dropped onto the object. All of the pertinent information about the drop is contained in the "dragInfo" object.
--
on drop theObject drag info dragInfo
	-- Get a list of the data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	
	-- Currently, we are only interested if there are "files names" on the pasteboard
	if "file names" is in dataTypes then
		-- This is a mechanism to tell the pasteboard which type of data we want when we access the "contents" of the pasteboard.
		set preferred type of pasteboard of dragInfo to "file names"
		
		-- Get the list of files dropped on the object form the pasteboard
		set thePaths to contents of pasteboard of dragInfo
		
		-- Load the image at the location of the first item
		set theImage to load image (item 1 of thePaths)
		
		-- Set the image into the image view
		set image of theObject to theImage
		
		-- Make sure to delete the image we loaded otherwise it will never be removed from memory.
		delete theImage
		
		-- Set the preferred type back to the default
		set preferred type of pasteboard of dragInfo to ""
	end if
	
	return true
end drop


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Table.applescript *)

(* This script is used to register the appropriate drag types for the "table view" object and then responds to a drop on it. *)

(* ==== Event Handlers ==== *)

-- The "awake from nib" event handler is a good place to register the drag types that this object can respond to.
--
on awake from nib theObject
	-- Create the data source for the table view
	set theDataSource to make new data source at end of data sources with properties {name:"files"}
	
	-- Create the "files" data column
	make new data column at end of data columns of theDataSource with properties {name:"files"}
	
	-- Assign the data source to the table view
	set data source of theObject to theDataSource
	
	-- Register for the "color" and "file names" drag types
	tell theObject to register drag types {"file names", "color"}
end awake from nib

-- The "drop" event handler is called when the appropriate type of data is dropped onto the object. All of the pertinent information about the drop is contained in the "dragInfo" object.
--
on drop theObject drag info dragInfo
	-- Get the list of data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	
	-- We are only interested in either "file names" or "color" data types
	if "file names" is in dataTypes then
		-- Initialize the list of files to an empty list
		set theFiles to {}
		
		-- We want the data as a list of file names, so set the preferred type to "file names"
		set preferred type of pasteboard of dragInfo to "file names"
		
		-- Get the list of files from the pasteboard
		set theFiles to contents of pasteboard of dragInfo
		
		-- Make sure we have at least one item
		if (count of theFiles) > 0 then
			--- Get the data source from the table view
			set theDataSource to data source of theObject
			
			-- Turn off the updating of the views
			set update views of theDataSource to false
			
			-- Delete all of the data rows in the data source
			delete every data row of theDataSource
			
			-- For every item in the list, make a new data row and set it's contents
			repeat with theItem in theFiles
				set theDataRow to make new data row at end of data rows of theDataSource
				set contents of data cell "files" of theDataRow to theItem
			end repeat
			
			-- Turn back on the updating of the views
			set update views of theDataSource to true
		end if
	else if "color" is in dataTypes then
		-- We want the data as a color, so set the preferred type
		set preferred type of pasteboard of dragInfo to "color"
		
		-- Set the background color of the table view to the color on the pasteboard
		set background color of theObject to contents of pasteboard of dragInfo
		
		-- We need to update the table view (redraw it).
		update theObject
	end if
	
	-- Set the preferred type back to the default
	set preferred type of pasteboard of dragInfo to ""
	
	return true
end drop


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)

(* ==== Event Handlers ==== *)

-- The "awake from nib" event handler is a good place to register the drag types that this object can respond to.
--
on awake from nib theObject
	-- We will register for the following types (altough this example only responds to the "string" type).
	tell theObject to register drag types {"string", "rich text", "file names"}
end awake from nib

on conclude drop theObject drag info dragInfo
	(* We need to have this handler do nothing to keep the text field from doing it's own drop. This is true for text view's as well. If you want to let the text field or text view do the actual drop you can remove the "conclude drop" event handler and then not do anything in the "drop" event handler. *)
end conclude drop

-- The "drop" event handler is called when the appropriate type of data is dropped onto the object. All of the pertinent information about the drop is contained in the "dragInfo" object.
--
on drop theObject drag info dragInfo
	-- We are only interested in the "string" data type
	if "string" is in types of pasteboard of dragInfo then
		-- Set the contents of the text field to the contents of the pasteboard
		set string value of theObject to contents of pasteboard of dragInfo
	end if
	
	return true
end drop


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* ==== Properties ==== *)

property endRace : false
property finishLine : 627
property betAmount : 5
property holdingsAmount : 1000

global carOneOrgbounds, carTwoOrgbounds, carThreeOrgbounds, carFourOrgbounds, carFiveOrgbounds, pickedCar, winner, raceSpeedval


(* ==== Handlers ==== *)

on resetRace()
	set the title of button "Car 1" of window "Drag Race" to "Car 1"
	set the title of button "Car 2" of window "Drag Race" to "Car 2"
	set the title of button "Car 3" of window "Drag Race" to "Car 3"
	set the title of button "Car 4" of window "Drag Race" to "Car 4"
	set the title of button "Car 5" of window "Drag Race" to "Car 5"
	set the enabled of button "Start Race" of window "Drag Race" to false
	set the bounds of button "Car 1" of window "Drag Race" to carOneOrgbounds
	set the bounds of button "Car 2" of window "Drag Race" to carTwoOrgbounds
	set the bounds of button "Car 3" of window "Drag Race" to carThreeOrgbounds
	set the bounds of button "Car 4" of window "Drag Race" to carFourOrgbounds
	set the bounds of button "Car 5" of window "Drag Race" to carFiveOrgbounds
end resetRace


on moveCar1()
	tell window "Drag Race"
		set carOneOrgPos to the bounds of button "Car 1"
		set stepVal to random number from 1 to raceSpeedval
		set bounds of button "Car 1" to {((item 1 of carOneOrgPos) + stepVal), item 2 of carOneOrgbounds, ((item 3 of carOneOrgPos) + stepVal), item 4 of carOneOrgbounds}
		
		set carOneOrgPos to the bounds of button "Car 1"
		if item 3 of carOneOrgPos > 630 then
			set winner to "Car 1"
			set endRace to true
			set the enabled of button "Start Race" to false
			if pickedCar = "Car 1" then
				set the contents of text field "results" to "Car 1, you won!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (betAmount + holdingsAmount)
			else
				set the contents of text field "results" to winner & " won, you lost!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (holdingsAmount - betAmount)
			end if
		end if
	end tell
end moveCar1

on moveCar2()
	tell window "Drag Race"
		set cartwoOrgPos to the bounds of button "Car 2"
		set stepVal to random number from 1 to raceSpeedval
		set bounds of button "Car 2" to {((item 1 of cartwoOrgPos) + stepVal), item 2 of carTwoOrgbounds, ((item 3 of cartwoOrgPos) + stepVal), item 4 of carTwoOrgbounds}
		
		set cartwoOrgPos to the bounds of button "Car 2"
		if item 3 of cartwoOrgPos > finishLine then
			set winner to "Car 2"
			set endRace to true
			set the enabled of button "Start Race" to false
			if pickedCar = "Car 2" then
				set the contents of text field "results" to "Car 2, you won!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (betAmount + holdingsAmount)
			else
				set the contents of text field "results" to winner & " won, you lost!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (holdingsAmount - betAmount)
			end if
		end if
	end tell
end moveCar2

on moveCar3()
	tell window "Drag Race"
		set carThreeOrgPos to the bounds of button "Car 3"
		set stepVal to random number from 1 to raceSpeedval
		set bounds of button "Car 3" to {((item 1 of carThreeOrgPos) + stepVal), item 2 of carThreeOrgbounds, ((item 3 of carThreeOrgPos) + stepVal), item 4 of carThreeOrgbounds}
		set carThreeOrgPos to the bounds of button "Car 3"
		if item 3 of carThreeOrgPos > finishLine then
			set winner to "Car 3"
			set endRace to true
			set the enabled of button "Start Race" to false
			if pickedCar = "Car 3" then
				set the contents of text field "results" to "Car 3, you won!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (betAmount + holdingsAmount)
			else
				set the contents of text field "results" to winner & " won, you lost!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (holdingsAmount - betAmount)
			end if
		end if
	end tell
end moveCar3

on moveCar4()
	tell window "Drag Race"
		set carFourOrgPos to the bounds of button "Car 4"
		set stepVal to random number from 1 to raceSpeedval
		set bounds of button "Car 4" to {((item 1 of carFourOrgPos) + stepVal), item 2 of carFourOrgbounds, ((item 3 of carFourOrgPos) + stepVal), item 4 of carFourOrgbounds}
		set carFourOrgPos to the bounds of button "Car 4"
		if item 3 of carFourOrgPos > finishLine then
			set winner to "Car 4"
			set endRace to true
			set the enabled of button "Start Race" to false
			if pickedCar = "Car 4" then
				set the contents of text field "results" to "Car 4, you won!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (betAmount + holdingsAmount)
			else
				set the contents of text field "results" to winner & " won, you lost!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (holdingsAmount - betAmount)
			end if
		end if
	end tell
end moveCar4

on moveCar5()
	tell window "Drag Race"
		set carFiveOrgPos to the bounds of button "Car 5"
		set stepVal to random number from 1 to raceSpeedval
		set bounds of button "Car 5" to {((item 1 of carFiveOrgPos) + stepVal), item 2 of carFiveOrgbounds, ((item 3 of carFiveOrgPos) + stepVal), item 4 of carFiveOrgbounds}
		set carFiveOrgPos to the bounds of button "Car 5"
		if item 3 of carFiveOrgPos > finishLine then
			set winner to "Car 5"
			set endRace to true
			set the enabled of button "Start Race" to false
			if pickedCar = "Car 5" then
				set the contents of text field "results" to "Car 5, you won!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (betAmount + holdingsAmount)
			else
				set the contents of text field "results" to winner & " won, you lost!"
				tell progress indicator "ProgressBar" to stop
				set visible of progress indicator "ProgressBar" to false
				set contents of text field "holdings" to (holdingsAmount - betAmount)
			end if
		end if
	end tell
end moveCar5


(* ==== Event Handlers ==== *)

on will open theObject
	set visible of progress indicator "ProgressBar" of window "Drag Race" to false
	set betAmount to contents of text field "bet" of window "Drag Race"
	set holdingsAmount to contents of text field "holdings" of window "Drag Race"
	set raceSpeedval to contents of slider "RaceSpeed" of window "Drag Race" as integer
	set carOneOrgbounds to the bounds of button "Car 1" of window "Drag Race"
	set carTwoOrgbounds to the bounds of button "Car 2" of window "Drag Race"
	set carThreeOrgbounds to the bounds of button "Car 3" of window "Drag Race"
	set carFourOrgbounds to the bounds of button "Car 4" of window "Drag Race"
	set carFiveOrgbounds to the bounds of button "Car 5" of window "Drag Race"
	set the contents of text field "results" of window "Drag Race" to "Pick a car!"
	set the enabled of button "Start Race" of window "Drag Race" to false
	set the enabled of button "Reset" of window "Drag Race" to false
end will open


on clicked theObject
	
	if title of theObject = "Car 1" then
		resetRace()
		set the title of button "Car 1" of window "Drag Race" to "Car 1 •"
		set contents of text field "results" of window "Drag Race" to "You picked car 1"
		set pickedCar to "Car 1"
		set the enabled of button "Start Race" of window "Drag Race" to true
		set the enabled of button "Reset" of window "Drag Race" to true
	else if title of theObject = "Car 2" then
		resetRace()
		set the title of button "Car 2" of window "Drag Race" to "Car 2 •"
		set contents of text field "results" of window "Drag Race" to "You picked car 2"
		set pickedCar to "Car 2"
		set the enabled of button "Start Race" of window "Drag Race" to true
		set the enabled of button "Reset" of window "Drag Race" to true
	else if title of theObject = "Car 3" then
		resetRace()
		set the title of button "Car 3" of window "Drag Race" to "Car 3 •"
		set contents of text field "results" of window "Drag Race" to "You picked car 3"
		set pickedCar to "Car 3"
		set the enabled of button "Start Race" of window "Drag Race" to true
		set the enabled of button "Reset" of window "Drag Race" to true
	else if title of theObject = "Car 4" then
		resetRace()
		set the title of button "Car 4" of window "Drag Race" to "Car 4 •"
		set contents of text field "results" of window "Drag Race" to "You picked car 4"
		set pickedCar to "Car 4"
		set the enabled of button "Start Race" of window "Drag Race" to true
		set the enabled of button "Reset" of window "Drag Race" to true
	else if title of theObject = "Car 5" then
		resetRace()
		set the title of button "Car 5" of window "Drag Race" to "Car 5 •"
		set contents of text field "results" of window "Drag Race" to "You picked car 5"
		set pickedCar to "Car 5"
		set the enabled of button "Start Race" of window "Drag Race" to true
		set the enabled of button "Reset" of window "Drag Race" to true
	else if title of theObject = "Reset" then
		set endRace to true
		tell progress indicator "ProgressBar" of window "Drag Race" to stop
		resetRace()
		set the contents of text field "results" of window "Drag Race" to "Pick a car!"
	end if
	
	if contents of text field "results" of window "Drag Race" ≠ "Pick a car!" then
		if title of theObject = "Start Race" then
			set endRace to false
			set betAmount to contents of text field "bet" of window "Drag Race"
			set holdingsAmount to contents of text field "holdings" of window "Drag Race"
			set visible of progress indicator "ProgressBar" of window "Drag Race" to true
			tell progress indicator "ProgressBar" of window "Drag Race" to start
			repeat while endRace = false
				moveCar1()
				moveCar2()
				moveCar3()
				moveCar4()
				moveCar5()
			end repeat
		end if
	end if
end clicked

on action theObject
	set raceSpeedval to contents of slider "RaceSpeed" of window "Drag Race" as integer
end action

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* This is an example that demonstrates how to show and hide a drawer, as well as change all of the various settings of a drawer, including the leading/trailing offsets and the various content sizes. *)

(* ==== Event Handlers ==== *)

-- This event handler is called when any of the attached UI elements are clicked. One thing of note in the handling of clicking on stepper objects: you need to update the value of the text fields based on the value of the stepper in order to keep them in sync.
--
on clicked theObject
	tell window "main"
		if theObject is equal to button "drawer" then
			set currentState to state of drawer "drawer"
			set openOnSide to current row of matrix "open on"
			
			-- Show/Hide the drawer as appropriate as well as updating the state text fields.
			if currentState is equal to drawer closed or currentState is equal to drawer closing then
				if openOnSide is equal to 1 then
					tell drawer "drawer" to open drawer on left edge
				else if openOnSide is equal to 2 then
					tell drawer "drawer" to open drawer on top edge
				else if openOnSide is equal to 3 then
					tell drawer "drawer" to open drawer on right edge
				else if openOnSide is equal to 4 then
					tell drawer "drawer" to open drawer on bottom edge
				end if
				set title of button "drawer" to "Close Drawer"
				set contents of text field "drawer state" to "Opened"
			else if currentState is equal to drawer opened or currentState is equal to drawer opening then
				tell drawer "drawer" to close drawer
				set title of button "drawer" to "Open Drawer"
				set contents of text field "drawer state" to "Closed"
			end if
		else if theObject is equal to stepper "leading offset" then
			set theValue to (contents of stepper "leading offset") as integer
			set leading offset of drawer "drawer" to theValue
			set contents of text field "leading offset" to theValue
		else if theObject is equal to stepper "trailing offset" then
			set theValue to (contents of stepper "trailing offset") as integer
			set trailing offset of drawer "drawer" to theValue
			set contents of text field "trailing offset" to theValue
		else if theObject is equal to stepper "content width" then
			set theValue to (contents of stepper "content width") as integer
			set contentSize to content size of drawer "drawer"
			set item 1 of contentSize to theValue
			set content size of drawer "drawer" to contentSize
			set contents of text field "content width" to theValue
		else if theObject is equal to stepper "content height" then
			set theValue to (contents of stepper "content height") as integer
			set contentSize to content size of drawer "drawer"
			set item 2 of contentSize to theValue
			set content size of drawer "drawer" to contentSize
			set contents of text field "content height" to theValue
		else if theObject is equal to stepper "minimum width" then
			set theValue to (contents of stepper "minimum width") as integer
			set minimumSize to minimum content size of drawer "drawer"
			set item 1 of minimumSize to theValue
			set minimum content size of drawer "drawer" to minimumSize
			set contents of text field "minimum width" to theValue
		else if theObject is equal to stepper "minimum height" then
			set theValue to (contents of stepper "minimum height") as integer
			set minimumSize to minimum content size of drawer "drawer"
			set item 2 of minimumSize to theValue
			set minimum content size of drawer "drawer" to minimumSize
			set contents of text field "minimum height" to theValue
		else if theObject is equal to stepper "maximum width" then
			set theValue to (contents of stepper "maximum width") as integer
			set maximumSize to maximum content size of drawer "drawer"
			set item 1 of maximumSize to theValue
			set maximum content size of drawer "drawer" to maximumSize
			set contents of text field "maximum width" to theValue
		else if theObject is equal to stepper "maximum height" then
			set theValue to (contents of stepper "maximum height") as integer
			set maximumSize to maximum content size of drawer "drawer"
			set item 2 of maximumSize to theValue
			set maximum content size of drawer "drawer" to maximumSize
			set contents of text field "maximum height" to theValue
		end if
	end tell
end clicked

-- This event handler is called when the text value of the attached text fields are changed. One thing of note in the handling of text fields with stepper objects: you need to update the value of the stepper based on the value of the text field in order to keep them in sync.
--
on action theObject
	set textValue to contents of theObject
	
	tell window "main"
		if theObject is equal to text field "leading offset" then
			set leading offset of drawer "drawer" to textValue
			set contents of stepper "leading offset" to textValue
		else if theObject is equal to text field "trailing offset" then
			set trailing offset of drawer "drawer" to textValue
			set contents of stepper "trailing offset" to textValue
		else if theObject is equal to text field "content width" then
			set theValue to (contents of text field "content width") as integer
			set contentSize to content size of drawer "drawer"
			set item 1 of contentSize to theValue
			set content size of drawer "drawer" to contentSize
			set contents of stepper "content width" to theValue
		else if theObject is equal to text field "content height" then
			set theValue to (contents of text field "content height") as integer
			set contentSize to content size of drawer "drawer"
			set item 2 of contentSize to theValue
			set content size of drawer "drawer" to contentSize
			set contents of stepper "content height" to theValue
		else if theObject is equal to text field "minimum width" then
			set theValue to (contents of text field "minimum width") as integer
			set minimumSize to minimum content size of drawer "drawer"
			set item 1 of minimumSize to theValue
			set minimum content size of drawer "drawer" to minimumSize
			set contents of stepper "minimum width" to theValue
		else if theObject is equal to text field "minimum height" then
			set theValue to (contents of text field "minimum height") as integer
			set minimumSize to minimum content size of drawer "drawer"
			set item 2 of minimumSize to theValue
			set minimum content size of drawer "drawer" to minimumSize
			set contents of stepper "minimum height" to theValue
		else if theObject is equal to text field "maximum width" then
			set theValue to (contents of text field "maximum width") as integer
			set maximumSize to maximum content size of drawer "drawer"
			set item 1 of maximumSize to theValue
			set maximum content size of drawer "drawer" to maximumSize
			set contents of stepper "maximum width" to theValue
		else if theObject is equal to text field "maximum height" then
			set theValue to (contents of text field "maximum height") as integer
			set maximumSize to maximum content size of drawer "drawer"
			set item 2 of maximumSize to theValue
			set maximum content size of drawer "drawer" to maximumSize
			set contents of stepper "maximum height" to theValue
		end if
	end tell
end action

-- This event handler is called when the attached window is loaded from the nib file. It's a good place to set up the values of all of the UI elements based on the current drawer settings.
--
on awake from nib theObject
	tell theObject
		set openOnEdge to edge of drawer "drawer"
		set preferredEdge to preferred edge of drawer "drawer"
		
		-- Set the drawer up with some initial values.
		set leading offset of drawer "drawer" to 20
		set trailing offset of drawer "drawer" to 20
		
		-- Update the UI to match the settings of the drawer.
		if state of drawer "drawer" is drawer closed then
			set contents of text field "drawer state" to "Closed"
		else if state of drawer "drawer" is drawer opened then
			set contents of text field "drawer state" to "Opened"
		end if
		
		if openOnEdge is left edge then
			set current row of matrix "open on" to 1
		else if openOnEdge is top edge then
			set current row of matrix "open on" to 2
		else if openOnEdge is right edge then
			set current row of matrix "open on" to 3
		else if openOnEdge is bottom edge then
			set current row of matrix "open on" to 4
		end if
		
		if preferredEdge is left edge then
			set current row of matrix "prefer on" to 1
		else if preferredEdge is top edge then
			set current row of matrix "prefer on" to 2
		else if preferredEdge is right edge then
			set current row of matrix "prefer on" to 3
		else if preferredEdge is bottom edge then
			set current row of matrix "prefer on" to 4
		end if
		
		set leadingValue to leading offset of drawer "drawer"
		set trailingValue to trailing offset of drawer "drawer"
		set contentSize to content size of drawer "drawer"
		set minimumContentSize to minimum content size of drawer "drawer"
		set maximumContentSize to maximum content size of drawer "drawer"
		
		set contents of text field "leading offset" to leadingValue
		set contents of stepper "leading offset" to leadingValue
		set contents of text field "trailing offset" to trailingValue
		set contents of stepper "trailing offset" to trailingValue
		set contents of text field "content width" to item 1 of contentSize
		set contents of stepper "content width" to item 1 of contentSize
		set contents of text field "content height" to item 2 of contentSize
		set contents of stepper "content height" to item 2 of contentSize
		set contents of text field "minimum width" to item 1 of minimumContentSize
		set contents of stepper "minimum width" to item 1 of minimumContentSize
		set contents of text field "minimum height" to item 2 of minimumContentSize
		set contents of stepper "minimum height" to item 2 of minimumContentSize
		set contents of text field "maximum width" to item 1 of maximumContentSize
		set contents of stepper "maximum width" to item 1 of maximumContentSize
		set contents of text field "maximum height" to item 2 of maximumContentSize
		set contents of stepper "maximum height" to item 2 of maximumContentSize
	end tell
end awake from nib

on launched theObject
	show window "main"
end launched


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Content Controller.applescript *)

(* ==== Event Handlers ==== *)

on clicked theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to (current date) as text
end clicked

on should open theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "should open"
	return false
end should open

on should close theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "should close"
	return true
end should close

on will open theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "will open"
end will open

on will resize theObject proposed size proposedSize
	log proposedSize as string
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "will resize"
end will resize

on will close theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "will close"
end will close

on opened theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "opened"
end opened

on closed theObject
	set contents of text field "Date Field" of drawer "Drawer" of window "Main" to "closed"
end closed


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* This example simply loads an image with a given name that is contained in the project and set's it as the image of the image view. *)

(* ==== Event Handlers ==== *)

on awake from nib theObject
	set image of image view "image" of window "main" to load image "AboutBox"
end awake from nib


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Mail Search.applescript *)

(* ==== Globals ==== *)

global controllers


(* ==== Properties ==== *)

property windowCount : 0
property statusPanelNibLoaded : false


(* ==== Event Handlers ==== *)

on clicked theObject
	set theController to controllerForWindow(window of theObject)
	if theController is not equal to null then
		tell theController to find()
	end if
end clicked

on double clicked theObject
	set theController to controllerForWindow(window of theObject)
	if theController is not equal to null then
		tell theController to openMessages()
	end if
end double clicked

on action theObject
	set theController to controllerForWindow(window of theObject)
	if theController is not equal to null then
		tell theController to find()
	end if
end action

on will open theObject
	set theController to makeController(theObject)
	if theController is not equal to null then
		addController(theController)
		tell theController to initialize()
	end if
end will open

on opened theObject
	set theController to controllerForWindow(theObject)
	if theController is not equal to null then
		tell theController to loadMailboxes()
	end if
end opened

on will finish launching theObject
	set controllers to {}
end will finish launching


(* ==== Controller Handlers ==== *)

on makeController(forWindow)
	script
		property theWindow : forWindow
		property theStatusPanel : null
		property foundMessages : {}
		property mailboxesLoaded : false
		
		-- Handlers
		
		on initialize()
			-- Add a column to the mailboxes data source
			tell scroll view "mailboxes" of split view 1 of theWindow
				make new data column at the end of the data columns of data source of outline view "mailboxes" with properties {name:"mailboxes"}
			end tell
			
			-- Add the columns to the messages data source
			tell scroll view "messages" of split view 1 of theWindow
				make new data column at the end of the data columns of data source of table view "messages" with properties {name:"from"}
				make new data column at the end of the data columns of data source of table view "messages" with properties {name:"subject"}
				make new data column at the end of the data columns of data source of table view "messages" with properties {name:"mailbox"}
			end tell
			
			set windowCount to windowCount + 1
		end initialize
		
		on loadMailboxes()
			if not mailboxesLoaded then
				-- Open the status panel
				set theStatusPanel to makeStatusPanel(theWindow)
				tell theStatusPanel to openPanel("Looking for Mailboxes...")
				
				-- Add the mailboxes
				addMailboxes()
				
				-- Close the status panel
				tell theStatusPanel to closePanel()
				
				set mailboxesLoaded to true
			end if
		end loadMailboxes
		
		on find()
			-- Get what and where to find
			set whatToFind to contents of text field "what" of theWindow
			set whereToFind to title of current menu item of popup button "where" of theWindow
			
			-- Make sure that we have something to find
			if (count of whatToFind) is greater than 0 then
				-- Clear any previously found messages
				clearMessages()
				
				-- Setup a status panel
				set theStatusPanel to makeStatusPanel(theWindow)
				tell theStatusPanel to openPanel("Determining the number of messages...")
				
				try
					-- Determine the mailboxes to search
					set mailboxesToSearch to selectedMailboxes()
					
					-- Determine the total number of messages to search
					set totalCount of theStatusPanel to countMessages(mailboxesToSearch)
					
					-- Adjust the status panel
					tell theStatusPanel to adjustPanel()
					
					-- Find the messages
					set foundMessages to findMessages(mailboxesToSearch, whereToFind, whatToFind)
					
					-- Change the status panel
					tell theStatusPanel to changePanel("Adding found messages...")
					
					-- Add the found messages to the result table
					addMessages(foundMessages)
					
					-- Close the status panel
					tell theStatusPanel to closePanel()
				on error errorText
					tell theStatusPanel to closePanel()
					display alert "AppleScript Error" as critical attached to theWindow message errorText
				end try
			else
				display alert "Missing Value" as critical attached to theWindow message "You need to enter a value to search for."
			end if
		end find
		
		on addMailbox(accountItem, accountName, mailboxIndex, mailboxName)
			-- Add a new item
			set mailboxItem to make new data item at the end of the data items of accountItem
			set name of data cell 1 of mailboxItem to "mailboxes"
			set contents of data cell 1 of mailboxItem to mailboxName
			set associated object of mailboxItem to mailboxIndex
		end addMailbox
		
		on addAccount(a, accountIndex, accountName)
			-- Add a new item
			set accountItem to make new data item at the end of the data items of data source of outline view "mailboxes" of scroll view "mailboxes" of split view 1 of theWindow
			set name of data cell 1 of accountItem to "mailboxes"
			set contents of data cell 1 of accountItem to accountName
			set associated object of accountItem to accountIndex
			
			-- Add the mail boxes
			tell application "Mail"
				set mailboxIndex to 0
				repeat with m in (get mailboxes of a)
					try
						set mailboxIndex to mailboxIndex + 1
						my addMailbox(accountItem, accountName, mailboxIndex, name of m)
					end try
				end repeat
			end tell
		end addAccount
		
		on addMailboxes()
			tell application "Mail"
				set accountIndex to 0
				repeat with a in (get accounts whose enabled is not equal to false)
					try
						set accountIndex to accountIndex + 1
						my addAccount(a, accountIndex, name of a)
					end try
				end repeat
			end tell
		end addMailboxes
		
		on mailboxesForIndex(mailboxIndex)
			-- Initiialize the result
			set theMailboxes to {}
			
			set theIndex to 0
			set theAccountIndex to 0
			
			-- Determine if the selected item is an account or a mailbox
			tell outline view "mailboxes" of scroll view "mailboxes" of split view 1 of theWindow
				set theItem to item for row mailboxIndex
				set theName to contents of data cell 1 of theItem
				set theIndex to associated object of theItem
				if has parent data item of theItem then
					set theAccountIndex to the associated object of the parent data item of theItem
				end if
			end tell
			
			tell application "Mail"
				if theAccountIndex > 0 then
					set theMailboxes to {mailbox theIndex of account theAccountIndex}
				else
					set theMailboxes to theMailboxes & every mailbox of account theIndex
				end if
			end tell
			
			-- Return the result
			return theMailboxes
		end mailboxesForIndex
		
		on selectedMailboxes()
			-- Initialize the result
			set mailboxesSelected to {}
			
			-- Get the currently selected mailboxes in the outline view
			set mailboxIndicies to selected rows of outline view "mailboxes" of scroll view "mailboxes" of split view 1 of theWindow
			
			-- Get the actual mailboxes from Mail
			tell application "Mail"
				if (count of mailboxIndicies) is equal to 0 then
					repeat with a in (get accounts)
						set mailboxesSelected to mailboxesSelected & every mailbox of a
					end repeat
				else
					repeat with i in mailboxIndicies
						set mailboxesSelected to mailboxesSelected & my mailboxesForIndex(i)
					end repeat
				end if
			end tell
			
			-- Return the result
			return mailboxesSelected
		end selectedMailboxes
		
		on addMessage(messageFrom, messageSubject, messageMailbox)
			-- Add a new row
			set theRow to make new data row at the end of the data rows of data source of table view "messages" of scroll view "messages" of split view 1 of theWindow
			
			-- Add "From" cell
			set name of data cell 1 of theRow to "from"
			set contents of data cell 1 of theRow to messageFrom
			
			-- Add "Subject" cell
			set name of data cell 2 of theRow to "subject"
			set contents of data cell 2 of theRow to messageSubject
			
			-- Add "Mailbox" cell
			set name of data cell 3 of theRow to "mailbox"
			set contents of data cell 3 of theRow to messageMailbox
			
			-- set the associated object of theRow to m
		end addMessage
		
		on addMessages(foundMessages)
			set update views of data source of table view "messages" of scroll view "messages" of split view 1 of theWindow to false
			
			tell application "Mail"
				repeat with m in foundMessages
					try
						set messageMailbox to name of account 1 of mailbox of m & "/" & name of mailbox of m
						my addMessage(sender of m, subject of m, messageMailbox)
					end try
				end repeat
			end tell
			
			set update views of data source of table view "messages" of scroll view "messages" of split view 1 of theWindow to true
		end addMessages
		
		on findMessages(mailboxesToSearch, whereToFind, whatToFind)
			-- Initialize the result
			set messagesFound to {}
			
			tell application "Mail"
				-- Search through each of the mail boxes 
				repeat with b in (get mailboxesToSearch)
					try
						-- Search through each of the messages of the mail box
						repeat with m in (get messages of b)
							try
								if whereToFind is equal to "Subject" then
									if whatToFind is in the subject of m then
										copy m to end of messagesFound
									end if
								else if whereToFind is equal to "From" then
									if whatToFind is in sender of m then
										copy m to end of messagesFound
									end if
								else if whereToFind is equal to "To" then
									set foundRecipient to false
									
									-- Recipients
									repeat with r in (get recipients of m)
										if whatToFind is in address of r or whatToFind is in name of r then
											set foundRecipient to true
										end if
									end repeat
									
									-- To Recipients
									if not foundRecipient then
										repeat with r in (get to recipients of m)
											if whatToFind is in address of r or whatToFind is in name of r then
												set foundRecipient to true
											end if
										end repeat
									end if
									
									-- cc Recipients
									if not foundRecipient then
										repeat with r in (get cc recipients of m)
											if whatToFind is in address of r or whatToFind is in name of r then
												set foundRecipient to true
											end if
										end repeat
									end if
									
									-- bcc Recipients
									if not foundRecipient then
										repeat with r in (get bcc recipients of m)
											if whatToFind is in address of r or whatToFind is in name of r then
												set foundRecipient to true
											end if
										end repeat
									end if
									
									if foundRecipient then
										copy m to end of messagesFound
									end if
								else if whereToFind is equal to "Contents" then
									if whatToFind is in the content of m then
										copy m to end of messagesFound
									end if
								end if
								
								-- Update the status panel
								tell theStatusPanel to incrementPanel()
							end try
						end repeat
					end try
				end repeat
			end tell
			
			-- Return the result
			return messagesFound
		end findMessages
		
		on clearMessages()
			tell scroll view "messages" of split view 1 of theWindow
				tell data source of table view "messages" to delete every data row
			end tell
		end clearMessages
		
		on countMessages(mailboxesToSearch)
			set messageCount to 0
			
			tell application "Mail"
				repeat with b in (get mailboxesToSearch)
					try
						set messageCount to messageCount + (count of every message of b)
					end try
				end repeat
			end tell
			
			return messageCount
		end countMessages
		
		on openMessages()
			-- Since Mail.app currently can't open a selected message then we will just open it in our own window
			openMessageWindow()
		end openMessages
		
		on openMessageWindow()
			set clickedRow to clicked row of table view "messages" of scroll view "messages" of split view 1 of theWindow
			if clickedRow is greater than or equal to 0 then
				set theAccount to ""
				set theMailbox to ""
				set theSubject to ""
				set theDateReceived to ""
				set theContents to ""
				set theSender to ""
				set theRecipients to ""
				set theCCRecipients to ""
				set theReplyTo to ""
				
				tell application "Mail"
					set theMessage to item clickedRow of foundMessages
					
					set theAccount to name of account of mailbox of theMessage
					set theMailbox to name of mailbox of theMessage
					set theSubject to subject of theMessage
					-- set theDateReceived to date received of theMessage
					set theContents to content of theMessage
					set theSender to sender of theMessage
					set theRecipients to address of every recipient of theMessage
					set theCCRecipients to address of every cc recipient of theMessage
					set theReplyTo to reply to of theMessage
				end tell
				
				set messageWindow to makeMessageWindow()
				tell messageWindow
					set messageContents to "Account: " & theAccount & return
					set messageContents to messageContents & "Mailbox: " & theMailbox & return
					if length of theSender > 0 then
						set messageContents to messageContents & "From: " & theSender & return
					end if
					if length of theDateReceived as string > 0 then
						set messageContents to messageContents & "Date: " & (theDateReceived as string) & return
					end if
					if length of theRecipients > 0 then
						set messageContents to messageContents & "To: " & theRecipients & return
					end if
					if length of theCCRecipients > 0 then
						set messageContents to messageContents & "Cc: " & theCCRecipients & return
					end if
					if length of theSubject > 0 then
						set messageContents to messageContents & "Subject: " & theSubject & return
					end if
					if length of theReplyTo > 0 then
						set messageContents to messageContents & "Reply-To: " & theReplyTo & return & return
					end if
					set messageContents to messageContents & theContents
					set contents of text view "message" of scroll view "message" to messageContents
					set title to theSubject
					set visible to true
				end tell
			end if
		end openMessageWindow
	end script
end makeController

on addController(theController)
	set controllers to controllers & {theController}
end addController


on controllerForWindow(aWindow)
	repeat with c in controllers
		if theWindow of c is equal to aWindow then
			set theController to c
		end if
	end repeat
	return theController
end controllerForWindow


(* ==== Message Window Handlers ==== *)

on makeMessageWindow()
	load nib "Message"
	set windowCount to windowCount + 1
	set windowName to "message " & windowCount
	set name of window "message" to windowName
	return window windowName
end makeMessageWindow


(* ==== Status Panel Handlers ==== *)

on makeStatusPanel(forWindow)
	script
		property theWindow : forWindow
		property initialized : false
		property totalCount : 0
		property currentCount : 0
		
		-- Handlers
		on openPanel(statusMessage)
			if initialized is false then
				if not statusPanelNibLoaded then
					load nib "StatusPanel"
					set statusPanelNibLoaded to true
				end if
				tell window "status"
					set indeterminate of progress indicator "progress" to true
					tell progress indicator "progress" to start
					set contents of text field "statusMessage" to statusMessage
				end tell
				set initialized to true
			end if
			display panel window "status" attached to theWindow
		end openPanel
		
		on changePanel(statusMessage)
			tell window "status"
				set indeterminate of progress indicator "progress" to true
				tell progress indicator "progress" to start
				set contents of text field "statusMessage" to statusMessage
			end tell
		end changePanel
		
		on adjustPanel()
			tell progress indicator "progress" of window "status"
				set indeterminate to false
				set minimum value to currentCount
				set maximum value to totalCount
				set contents to 0
			end tell
			incrementPanel()
		end adjustPanel
		
		on incrementPanel()
			set currentCount to currentCount + 1
			if currentCount ≤ totalCount then
				tell window "status"
					tell progress indicator "progress" to increment by 1
					set contents of text field "statusMessage" to "Message " & currentCount & " of " & totalCount
				end tell
			end if
		end incrementPanel
		
		on closePanel()
			close panel window "status"
		end closePanel
	end script
end makeStatusPanel


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- AppleScript.applescript

(* ==== Event Handlers ==== *)

-- This event handler is called when the "AppleScript" button is clicked.
--
on clicked theObject
	tell window of theObject
		-- Simply put "AppleScript" into the text field
		set the contents of the text field "applescript" to "AppleScript"
	end tell
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- C++.applescript

(* ==== Event Handlers ==== *)

-- This event handler is called when the "C++" button is clicked.
--
on clicked theObject
	tell window of theObject
		-- Call the Objective-C method "nameForCPlusPlusLanguage" defined in "Multi-Language.h"
		-- It will in turn call a method of the CPlusPlusLanguage class defined in "C++.h"
		set contents of text field "c++" to call method "nameForCPlusPlusLanguage"
	end tell
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- C.applescript

(* ==== Event Handlers ==== *)

-- This event handler is called when the "C" button is clicked.
--
on clicked theObject
	tell window of theObject
		-- Call the Objective-C method "nameForCLanguage" defined in "Multi-Language.h"
		-- It in turn, will call a function defined in "C.h"
		set contents of text field "c" to call method "nameForCLanguage"
	end tell
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- Java.applescript

(* ==== Event Handlers ==== *)

-- This event handler is called when either the "Java" or "Direct Java" button is clicked. If the "Java" button is clicked it will call into the Objective-C method and use the Java Bridging mechanism to call a Java method of a Java class. If the "Direct Java" button is clicked it will use 'call method''s ability to call a static method of a Java class directly.
--
on clicked theObject
	tell window of theObject
		if name of theObject is "java" then
			-- Call the Objective-C method "nameForJavaLanguage" defined in "Multi-Language.h"
			-- It will in turn call a method of the JavaLanguage class defined in "JavaLanguage.java"
			set contents of text field "java" to call method "nameForJavaLanguage"
		else if name of theObject is "direct java" then
			-- Call the static "languageName" method of the "JavaLanguage" class which is defined in "JavaLanguage.java"
			set contents of text field "direct java" to call method "languageName" of class "JavaLanguage"
		end if
	end tell
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- Application.applescript

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Use All" button is clicked.
--
on clicked theObject
	tell window of theObject
		-- Execute the 'nameOfAllLanguages' Objective-C method in "Multi-Language.mm" and then append "AppleScript" to the result and put it in the text field
		set contents of text field "use all" to ((call method "nameOfAllLanguages") & ", AppleScript")
	end tell
end clicked

-- This event handler is called when the "Clear All" menu item in the edit menu is chosen. It will set the contents of all of the text fields to empty strings.
--
on choose menu item theObject
	tell window "main"
		set contents of text field "applescript" to ""
		set contents of text field "objective-c" to ""
		set contents of text field "c" to ""
		set contents of text field "c++" to ""
		set contents of text field "java" to ""
		set contents of text field "direct java" to ""
		set contents of text field "use all" to ""
	end tell
end choose menu item

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- Objective-C.applescript

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Objective-C" button is clicked.
--
on clicked theObject
	tell window of theObject
		-- Call the Objective-C method "nameForObjCLanguage" defined in "Multi-Language.h"
		-- It will in turn call a method of the ObjCLanugage class defined in "Objective-C.h"
		set contents of text field "objective-c" to call method "nameForObjCLanguage"
	end tell
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(*Open Panel.applescript *)

(* This example demonstrates how to use the 'open-panel' class, either as a modal panel or as a panel attached to a window. The 'open panel' is a property of the application object. *)

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Display Open Panel" button is clicked, which when clicked the various parameter values pulled from the text fields to be sent to "display". 
--
on clicked theObject
	-- Get the values from the UI
	tell window of theObject
		set theTitle to contents of text field "title"
		set thePrompt to contents of text field "prompt"
		set theFileTypes to contents of text field "file types"
		set theDirectory to contents of text field "directory"
		set theFileName to contents of text field "file name"
		set treatPackages to contents of button "treat packages" as boolean
		set canChooseDirectories to contents of button "choose directories" as boolean
		set canChooseFiles to contents of button "choose files" as boolean
		set allowsMultiple to contents of button "multiple selection" as boolean
		set asSheet to contents of button "sheet" as boolean
		
		-- Convert the comma separated list of file type to an actual list
		set AppleScript's text item delimiters to ", "
		set theFileTypes to text items of theFileTypes
		set AppleScript's text item delimiters to ""
	end tell
	
	-- Setup the properties in the 'open panel'
	tell open panel
		set title to theTitle
		set prompt to thePrompt
		set treat packages as directories to treatPackages
		set can choose directories to canChooseDirectories
		set can choose files to canChooseFiles
		set allows multiple selection to allowsMultiple
	end tell
	
	-- Determine which way to display the panel
	if asSheet then
		-- Display the panel as sheet (in which case the result will happen in 'on panel ended').
		-- One thing to note is that the script will not stop processing until the panel is presented but continues on. You must use the 'on panel ended' event handler to get notified when the panel has finished.
		-- The 'in directory' and 'with file name' parameters are optional.
		if (count of theFileTypes) is 0 then
			display open panel in directory theDirectory with file name theFileName attached to window of theObject
		else
			display open panel in directory theDirectory with file name theFileName for file types theFileTypes attached to window of theObject
		end if
	else
		-- Display the panel.
		-- Unlike the 'attached to' variant, the script does stop processing until the panel is finished.
		-- The 'in directory' and 'with file name' parameters are optional
		if (count of theFileTypes) is 0 then
			set theResult to display open panel in directory theDirectory with file name theFileName for file types theFileTypes
		else
			set theResult to display open panel in directory theDirectory with file name theFileName
		end if
		
		if theResult is 1 then
			-- Convert the list into a list of strings separated by return characters that we can put in the 'path names' text view
			-- For some unknown (as of yet) you must coerce the 'path names' to a list (even though it is defined as list).
			set the pathNames to (path names of open panel as list)
			set AppleScript's text item delimiters to return
			set the pathNames to pathNames as string
			set AppleScript's text item delimiters to ""
			
			set contents of text view "path names" of scroll view "path names" of window "main" to pathNames
		else
			set contents of text view "path names" of scroll view "path names" of window "main" to ""
		end if
	end if
end clicked

-- This event handler is called when the panel presented with the 'display attached to' command is finished.
--
on panel ended theObject with result withResult
	if withResult is 1 then
		-- Convert the list into a list of strings separated by return characters that we can put in the 'path names' text view
		-- For some unknown (as of yet) you must coerce the 'path names' to a list (even though it is defined as list).
		set the pathNames to (path names of open panel as list)
		set AppleScript's text item delimiters to return
		set the pathNames to pathNames as string
		set AppleScript's text item delimiters to ""
		
		set contents of text view "path names" of scroll view "path names" of window "main" to pathNames
	else
		set contents of text view "path names" of scroll view "path names" of window "main" to ""
	end if
end panel ended

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* This example illustrates how to script an outline view. *)

(* ==== Properties ==== *)

property diskNames : {}


(* ==== Event Handlers ==== *)

on launched theObject
	try
		tell application "Finder"
			set diskNames to name of every disk
		end tell
	end try
	tell outline view "outline" of scroll view "scroll" of window "main" to update
end launched

on number of items theObject outline item theItem
	set itemCount to 0
	try
		tell application "Finder"
			if (count of diskNames) > 0 then
				if theItem is 0 then
					set itemCount to count of diskNames
				else
					set itemCount to count of items of (get item theItem)
				end if
			end if
		end tell
	end try
	return itemCount
end number of items

on child of item theObject outline item theItem child theChild
	set childItem to ""
	try
		tell application "Finder"
			if theItem is 0 then
				set childItem to disk (get item theChild of diskNames as string) as string
			else
				set childItem to item theChild of (get item theItem) as string
			end if
		end tell
	end try
	return childItem
end child of item

on item expandable theObject outline item theItem
	set isExpandable to false
	try
		if theItem is 0 then
			if (count of diskNames) is greater than 1 then
				set isExpandable to true
			end if
		else
			tell application "Finder"
				if (count of items of (get item theItem)) is greater than 1 then
					set isExpandable to true
				end if
			end tell
		end if
	end try
	return isExpandable
end item expandable

on item value theObject outline item theItem table column theColumn
	set itemValue to ""
	try
		if the identifier of theColumn is "name" then
			tell application "Finder"
				set itemValue to displayed name of (get item theItem) as string
			end tell
		else if the identifier of theColumn is "date" then
			tell application "Finder"
				set itemValue to modification date of (get item theItem) as string
			end tell
		else if the identifier of theColumn is "kind" then
			tell application "Finder"
				set itemValue to kind of (get item theItem) as string
			end tell
		end if
	end try
	return itemValue
end item value

on will open theObject
	try
		tell application "Finder"
			set diskNames to name of every disk
		end tell
	end try
	tell outline view "outline" of scroll view "scroll" of window "main" to update
end will open


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Outline Reorder.applescript *)

(* This example populates an outline view using the "content" property and then uses the "allows reordering" property of the table and outline views to enable the automatic support of drag and drop to roerder items.
*)


(* ===== Event Handlers ===== *)

-- This event handler is attached to the table view and is a good place to setup our data source.
--
on awake from nib theObject
	-- Setup the data source, data items and data cells simply by setting the "content" property of the table view.
	set content of theObject to {{completed:false, task:"Things to do", |items|:{{completed:true, task:"Work on outline example", |items|:{{completed:true, task:"Make it plain and simple"}, {completed:true, task:"Put it all in an \"on launched'\" event handler"}}}, {completed:true, task:"Put it in my iDisk when done"}}}}
end awake from nib

-- This event handler is called when the user clicks on the check box.
--
on clicked theObject
	set allows reordering of outline view "outline" of scroll view "scroll" of window of theObject to state of theObject
end clicked


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Document.applescript *)

(* This is a very simple example of how to write a document based plain text editor. It takes advantage of the lower level handlers for document handling, namely "read from file" and "write to file". It does this so that it can read text documents created by other applications. The two higher level handlers "data representation" and "load data representation" allow you to return and set any type of data, but then it will only be readable by your application, as it utilizes Cocoa's NSData object to store and retrieve your data. *)

(* ==== Event Handlers ==== *)

-- The "read from file" handler is called when the document needs to the data to be read from disk. "theObject" is the document object, "pathName" contains the POSIX style path of the file to read and "ofType" contains the type of document to read (which by default this value will be "DocumentType" as set up in the documents section of the target editor for document based Studio applications).
--
on read from file theObject path name pathName of type ofType
	-- Open the file so that we can read it in
	set theFile to open for access (pathName as POSIX file)
	
	-- Read the data in
	set theData to read theFile as string
	
	-- Close the file
	close access theFile
	
	-- Put the data that we read into the text view of our document
	set contents of text view "editor" of scroll view "editor" of window of theObject to theData
	
	-- We need to return true (if everything went well) or false (if something failed). For the purposes of this example we'll signal that everything went well.
	return true
end read from file


-- The "write to file" handler is called when the document needs to be saved to disk. "theObject" is the document object, "pathName" contains the POSIX style path of the file to write and "ofType" contains the type of document to read (which by default this value will be "DocumentType" as set up in the documents section of the target editor for document based Studio applications).
--
on write to file theObject path name pathName of type ofType
	-- Get the data from the text view of the document
	set theData to contents of text view "editor" of scroll view "editor" of window of theObject
	
	-- Open the file for writing
	set theFile to open for access (pathName as POSIX file) with write permission
	
	-- Write the data
	write theData to theFile as string
	
	-- Close the file
	close access theFile
	
	-- We need to return true (if everything went well) or false (if something failed). For the purposes of this example we'll signal that everything went well.
	return true
end write to file


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(*Save Panel.applescript *)

(* This example demonstrates how to use the 'save-panel' class, either as a modal panel or as a panel attached to a window. The 'save panel' is a property of the application object. *)

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Display Save Panel" button is clicked, which when clicked the various parameter values pulled from the text fields to be sent to "display". 
--
on clicked theObject
	-- Get the values from the UI
	tell window of theObject
		set theTitle to contents of text field "title"
		set thePrompt to contents of text field "prompt"
		set theFileType to contents of text field "file type"
		set theDirectory to contents of text field "directory"
		set theFileName to contents of text field "file name"
		set treatPackages to contents of button "treat packages" as boolean
		set asSheet to contents of button "sheet" as boolean
	end tell
	
	-- Setup the properties in the 'save panel'
	tell save panel
		set title to theTitle
		set prompt to thePrompt
		set required file type to theFileType
		set treat packages as directories to treatPackages
	end tell
	
	-- Determine which way to display the panel
	if asSheet then
		-- Display the panel as sheet (in which case the result will happen in 'on panel ended').
		-- One thing to note is that the script will not stop processing until the panel is presented but continues on. You must use the 'on panel ended' event handler to get notified when the panel has finished.
		-- The 'in directory' and 'with file name' parameters are optional.
		display save panel in directory theDirectory with file name theFileName attached to window of theObject
	else
		-- Display the panel.
		-- Unlike the 'attached to' variant, the script does stop processing until the panel is finished.
		-- The 'in directory' and 'with file name' parameters are optional
		set theResult to display save panel in directory theDirectory with file name theFileName
		if theResult is 1 then
			set contents of text field "path name" of window "main" to path name of save panel
		else
			set contents of text field "path name" of window "main" to ""
		end if
	end if
end clicked

-- This event handler is called when the panel presented with the 'display attached to' command is finished.
--
on panel ended theObject with result withResult
	if withResult is 1 then
		set contents of text field "path name" of window "main" to path name of save panel
	else
		set contents of text field "path name" of window "main" to ""
	end if
end panel ended

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Simple Outline.applescript *)

(* This is a very simple example of how to populate an outline view using a data source. It will create a data source with data items representing the following outline:

	- Things to do
		- Work on outline example
			- Make it plain and simple
			- Put it all in a "on launched" event handler
		- Put it in my iDisk when done
		
	It has been enhanced to add drag and drop support and uses the new "content" property.
*)


(* ===== Event Handlers ===== *)

-- This event handler is attached to the table view in our nib. It is a good place to set the contents of the table view and to setup any drag types that we might desire.
--
on awake from nib theObject
	-- Create the data source, data items and data cells by simply setting the "content" property of the outline view
	set content of theObject to {{completed:"--", task:"Things to do", |items|:{{completed:"Yes", task:"Work on outline example", |items|:{{completed:"Yes", task:"Make it plain and simple"}, {completed:"Yes", task:"Put it all in an \"on launched'\" event handler"}}}, {completed:"Yes", task:"Put it in my iDisk when done"}}}}
	
	tell theObject to register drag types {"items", "file names"}
end awake from nib

-- The launched handler is generally the  last event handler to be called in the launch sequence. It's a good place for us to show our window.
--
on launched theObject
	show window "main"
end launched

-- This event handler is called whenever the user is done editing a cell in the outline view.
--
on change item value theObject table column tableColumn outline item outlineItem value theValue
	return "maybe"
end change item value

-- This event handler is called that the beginning of a drag operation in our outline view
--
on prepare outline drag theObject drag items dragItems pasteboard thePasteboard
	-- We are about to start a drag from within our outline view, so set the preferred type of the pasteboard to be "items" and then set the content of the pasteboard to be the items being dragged
	set preferred type of thePasteboard to "items"
	set content of thePasteboard to dragItems
	
	-- Since it isn't convenient to get items on to the pasteboard, we just save the list of dragged items to be used later
	set dragged items of theObject to dragItems
	
	return true
end prepare outline drag

-- This event handler is called while the drag and drop operation is ongoing. We can decide whether or not we want to accept the drop, or where to allow the drop.
--
on prepare outline drop theObject data item dataItem drag info dragInfo child index childIndex
	-- By default we will set the drag operation to not be a drag operation
	set dragOperation to no drag operation
	
	-- Get the list of data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	
	-- Set the type of drag operation based on the drop operation and the state of the option key
	if "items" is in dataTypes then
		if option key down of event 1 then
			set dragOperation to copy drag operation
		else
			set dragOperation to move drag operation
		end if
	else if "file names" is in dataTypes then
		set dragOperation to copy drag operation
	end if
	
	-- Return the desired drag operation
	return dragOperation
end prepare outline drop

-- This event handler is called when the drop happens. 
--
on accept outline drop theObject data item dataItem drag info dragInfo child index childIndex
	-- Get the list of data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	set dataSource to data source of theObject
	
	-- Turn off the updating of the views
	set update views of dataSource to false
	
	-- Set up the target data item (where we'll be placing the dropped items)
	if dataItem is missing value or childIndex = 0 or childIndex > (count of data items of dataItem) then
		set targetDataItem to missing value
	else
		set targetDataItem to data item childIndex of dataItem
	end if
	
	-- See if we are receiving our "items" in the drop
	if "items" is in dataTypes then
		-- We'll just use the list of dragged items we saved earlier, as it  is easier than getting them from the pasteboard
		set draggedItems to dragged items of theObject
		
		-- Now move or duplicate the data items based on the option key
		if option key down of event 1 then
			repeat with i in draggedItems
				if dataItem is not missing value then
					if childIndex = 0 or childIndex > (count of data items of dataItem) then
						duplicate i to end of data items of dataItem
					else
						duplicate i to before dataItem
					end if
				else
					duplicate i to end of data items of dataSource
				end if
			end repeat
		else
			repeat with i in draggedItems
				if dataItem is not missing value then
					if childIndex = 0 or childIndex > (count of data items of dataItem) then
						move i to end of data items of dataItem
					else
						move i to before dataItem
					end if
				else
					move i to end of data items of dataSource
				end if
			end repeat
		end if
	else if "file names" is in dataTypes then
		-- Initialize the list of files to an empty list
		set theFiles to {}
		
		-- We want the data as a list of file names, so set the preferred type to "file names"
		set preferred type of pasteboard of dragInfo to "file names"
		
		-- Get the list of files from the pasteboard
		set theFiles to contents of pasteboard of dragInfo
		
		-- Make sure we have at least one item
		if (count of theFiles) > 0 then
			repeat with theItem in theFiles
				if targetDataItem is not missing value then
					set dataItem to make new data item at before targetDataItem
				else
					set dataItem to make new data item at end of data items of dataSource
				end if
				
				set contents of data cell "task" of dataItem to theItem
			end repeat
		end if
	end if
	
	-- Turn back on the updating of the views
	set update views of dataSource to true
	
	-- Make sure to return true, otherwise the drop will be cancelled.
	return true
end accept outline drop


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* ==== Event Handlers ==== *)

on action theObject
	set theResult to do shell script (contents of text field "input" of window "main" as string)
	set the contents of text view "output" of scroll view "output" of window "main" to theResult
	set needs display of text view "output" of scroll view "output" of window "main" to true
end action


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Simple Table.applescript *)

(* This is a very simple example of how to populate a table view using the "content" property. It also demonstrates how to add drag and drop support to allow both reordering and accepting external drops.
*)


(* ===== Event Handlers ===== *)

-- This event handler is attached to the table view in our nib. It is a good place to set the contents of the table view and to setup any drag types that we might desire.
--
on awake from nib theObject
	-- Create the data source, data rows and data cells by simply setting the "content" property of the table view
	set content of theObject to {{"Work on outline example", "Yes"}, {"Make it plain and simple", "Yes"}, {"Put it all in an \"on launched\" event handler", "Yes"}, {"Put it in my iDisk when done", "Yes"}}
	
	-- Register for the "rows" and "file names" drag types
	tell theObject to register drag types {"rows", "file names"}
end awake from nib

-- The launched handler is generally the  last event handler to be called in the launch sequence. It's a good place for us to show our window.
--
on launched theObject
	show window "main"
end launched

-- This event handler is called whenever the user double clicks, edits and then leaves a cell in the table. 
--
on change cell value theObject table column tableColumn row theRow value theValue
	return theValue
end change cell value

-- This event handler is called that the beginning of a drag operation in our table view
--
on prepare table drag theObject drag rows dragRows pasteboard thePasteboard
	-- We are about to start a drag from within our table view, so set the preferred type of the pasteboard to be "rows" and then set the content of the pasteboard to be the rows being dragged
	set preferred type of thePasteboard to "rows"
	set content of thePasteboard to dragRows
	
	-- We need to return true here so that the drag will continue
	return true
end prepare table drag

-- This event handler is called while the drag and drop operation is ongoing. We can decide whether or not we want to accept the drop, or where to allow the drop.
--
on prepare table drop theObject drag info dragInfo row theRow drop operation dropOperation
	-- By default we will set the drag operation to not be a drag operation
	set dragOperation to no drag operation
	
	-- Get the list of data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	
	-- Set the type of drag operation based on the drop operation and the state of the option key
	if "rows" is in dataTypes then
		if dropOperation is 1 then
			if option key down of event 1 then
				set dragOperation to copy drag operation
			else
				set dragOperation to move drag operation
			end if
		end if
	else if "file names" is in dataTypes then
		if dropOperation is 1 then
			set dragOperation to copy drag operation
		end if
	end if
	
	-- Return the desired drag operation
	return dragOperation
end prepare table drop

-- This event handler is called when the drop happens. 
--
on accept table drop theObject drag info dragInfo row theRow drop operation dropOperation
	-- Get the list of data types on the pasteboard
	set dataTypes to types of pasteboard of dragInfo
	set dataSource to data source of theObject
	
	-- Turn off the updating of the views
	set update views of dataSource to false
	
	-- Set up the target data row (where we'll be placing the dropped items)
	if theRow ≤ (count of data rows of dataSource) then
		set targetDataRow to data row theRow of dataSource
	else
		set targetDataRow to missing value
	end if
	
	-- See if we are accepting our own "rows" (reorder)
	if "rows" is in dataTypes then
		-- Get the list of row numbers
		set preferred type of pasteboard of dragInfo to "rows"
		set rowNumbers to contents of pasteboard of dragInfo
		
		-- We'll make a temporary list of the dragged data rows
		set dataRows to {}
		repeat with i in rowNumbers
			copy data row i of dataSource to end of dataRows
		end repeat
		
		-- Now move or duplicate the data rows based on the option key
		if option key down of event 1 then
			repeat with i in dataRows
				if targetDataRow is not missing value then
					duplicate i to before targetDataRow
				else
					duplicate i to end of data rows of dataSource
				end if
			end repeat
		else
			repeat with i in dataRows
				if targetDataRow is not missing value then
					move i to before targetDataRow
				else
					move i to end of data rows of dataSource
				end if
			end repeat
		end if
	else if "file names" is in dataTypes then
		-- Initialize the list of files to an empty list
		set theFiles to {}
		
		-- We want the data as a list of file names, so set the preferred type to "file names"
		set preferred type of pasteboard of dragInfo to "file names"
		
		-- Get the list of files from the pasteboard
		set theFiles to contents of pasteboard of dragInfo
		
		-- Make sure we have at least one item
		if (count of theFiles) > 0 then
			repeat with theItem in theFiles
				if targetDataRow is not missing value then
					set dataRow to make new data row at before targetDataRow
				else
					set dataRow to make new data row at end of data rows of dataSource
				end if
				
				set contents of data cell "task" of dataRow to theItem
			end repeat
			
		end if
	end if
	
	-- Turn back on the updating of the views
	set update views of dataSource to true
	
	-- Make sure to return true, otherwise the drop will be cancelled.
	return true
end accept table drop


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Document.applescript *)

(* This is a simple example of how to add a toolbar to a window. It also demonstrates how to respond to the user clicking on a toolbar item and how to enable or disable toolbar items.
*)


(* ===== Event Handlers ===== *)

-- These two event handlers are used to save and load the data for a document. For the purposes of this example, we will not be using them.
--
on data representation theObject of type ofType
	(*Return the data that is to be stored in your document here.*)
end data representation

on load data representation theObject of type ofType with data withData
	(* The withData contains the data that was stored in your document that you provided in the "data representation" event handler. Return "true" if this was successful, or false if not.*)
	return true
end load data representation


-- This event handler is attached to the table view in our nib. It is a good place to set the contents of the table view and to setup any drag types that we might desire.
--
on awake from nib theObject
	-- Make the new toolbar, giving it a unique identifier
	set documentToolbar to make new toolbar at end with properties {name:"document toolbar", identifier:"document toolbar identifier", allows customization:true, auto sizes cells:true, display mode:default display mode, size mode:default size mode}
	
	-- Setup the allowed and default identifiers.
	set allowed identifiers of documentToolbar to {"compile item identifier", "run item identifier", "stop item identifier", "print item identifier", "customize toolbar item identifer", "flexible space item identifer", "space item identifier", "separator item identifier"}
	set default identifiers of documentToolbar to {"compile item identifier", "run item identifier", "stop item identifier"}
	
	--set selectable identifiers of documentToolbar to {}
	
	-- Create the toolbar items, adding them to the toolbar.
	make new toolbar item at end of toolbar items of documentToolbar with properties {identifier:"compile item identifier", name:"compile item", label:"Compile", palette label:"Compile", tool tip:"Compile", image name:"CompileScript"}
	make new toolbar item at end of toolbar items of documentToolbar with properties {identifier:"run item identifier", name:"run item", label:"Run", palette label:"Run", tool tip:"Run", image name:"RunScript"}
	make new toolbar item at end of toolbar items of documentToolbar with properties {identifier:"stop item identifier", name:"stop item", label:"Stop", palette label:"Stop", tool tip:"Stop", image name:"StopScript"}
	
	-- Assign our toolbar to the window
	set toolbar of theObject to documentToolbar
end awake from nib

-- This event handler is called when the user clicks on one of the toolbar items
--
on clicked toolbar item theObject
	if identifier of theObject is "compile item identifier" then
		display dialog "It's time to compile" attached to the front window
	end if
end clicked toolbar item

-- This event handler is called whenever the state of the toolbar items needs to be changed.
--
on update toolbar item theObject
	-- We return true in order to enable the toolbar item, otherwise we would return false
	return true
end update toolbar item


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Simple Toolbar.applescript *)

(* This is a simple example of how to add a toolbar to a window. It also demonstrates how to respond to the user clicking on a toolbar item and how to enable or disable toolbar items.
*)


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* ==== Properties ==== *)

global soapresult, readFile
property SOAPEndpointURLParm : ""
property SOAPActionPram : ""
property MethodNamespaceURLPram : ""
property MethodNamesPram : ""
property ParametersPram : {}
property ParametersPramRec : {}


(* ==== Event Handlers ==== *)

on clicked theObject
	set ButtonTitle to title of theObject
	if ButtonTitle = "Run" then
		set enabled of button "stop" of window "SOAPtalk" to true
		tell progress indicator "barberpole" of window "SOAPtalk" to start
		set the contents of text view "results" of scroll view 1 of window "SOAPtalk" to ""
		updateProperties()
		soapCallHandler()
	else if ButtonTitle = "Reset" then
		display dialog "Reset field?" buttons {"Cancel", "All", "Results"} default button "Results" --with icon stop --attached to window "SOAPtalk"
		set eraseresultswindbutton to text of button returned of result
		if eraseresultswindbutton = "Results" then
			set the contents of text view "results" of scroll view 1 of window "SOAPtalk" to ""
		else if eraseresultswindbutton = "All" then
			restFields()
		end if
	else if ButtonTitle = "" then
		open location "http://www.xmethods.com"
	else if ButtonTitle = "stop" then
		tell progress indicator "barberpole" of window "SOAPtalk" to stop
		set enabled of button "stop" of window "SOAPtalk" to false
	end if
end clicked

on changed theObject
	(*Add your script here.*)
end changed

on choose menu item theObject --menu item theItem
	set menuItemTitle to title of theObject as string
	if menuItemTitle = "Open..." then
		set SOAPReadFile to choose file with prompt "Please select a previously saved SOAPTalk file"
		set xRef to open for access SOAPReadFile
		set readFile to read xRef as list
		close access xRef
		updateFieldsFromFile()
	end if
	if menuItemTitle = "Save" then
		try
			updateProperties()
			set resultsfield to contents of text view "results" of scroll view 1 of window "SOAPtalk"
			set writeRecord to {SOAPEndpointURL:SOAPEndpointURLParm, SOAPAction:SOAPActionPram, MethodNamespaceURL:MethodNamespaceURLPram, MethodNames:MethodNamesPram, parameters:ParametersPram, soapresult:resultsfield}
			set saveFile to choose file name with prompt "Save File to" default name "SOAPTalk"
			
			set fileRef to open for access saveFile with write permission
			write writeRecord to fileRef as list
			close access fileRef
		on error errMsg
			try
				get fileRef
				close access fileRef
				display dialog errMsg
			end try
		end try
	end if
end choose menu item


(* ==== Handlers ==== *)

on updateProperties()
	tell window "SOAPTalk"
		set SOAPEndpointURLParm to contents of text field "SOAPEndpointURL" --as application
		set SOAPActionPram to contents of text field "SOAPAction"
		set MethodNamespaceURLPram to contents of text field "MethodNamespaceURL"
		set MethodNamesPram to contents of text field "MethodNames"
		set ParametersPram to contents of text field "Parameters"
		set ParametersPramRec to run script ParametersPram -- convert string record into list record
		set soapresult to ""
	end tell
end updateProperties

on updateFieldsFromFile()
	tell window "SOAPTalk"
		set contents of text field "SOAPEndpointURL" to SOAPEndpointURL of item 1 of readFile
		set contents of text field "SOAPAction" to SOAPAction of item 1 of readFile
		set contents of text field "MethodNamespaceURL" to MethodNamespaceURL of item 1 of readFile
		set contents of text field "MethodNames" to MethodNames of item 1 of readFile
		set contents of text field "Parameters" to parameters of item 1 of readFile
	end tell
end updateFieldsFromFile

on restFields()
	tell window "SOAPTalk"
		set contents of text field "SOAPEndpointURL" to ""
		set contents of text field "SOAPAction" to ""
		set contents of text field "MethodNamespaceURL" to ""
		set contents of text field "MethodNames" to ""
		set contents of text field "Parameters" to ""
		set the contents of text view "results" of scroll view 1 to ""
	end tell
end restFields

on soapCallHandler()
	try
		using terms from application "http://www.apple.com"
			tell application (SOAPEndpointURLParm as string)
				set soapresult to call soap {method name:my getPlainText(MethodNamesPram), method namespace uri:my getPlainText(MethodNamespaceURLPram), parameters:ParametersPramRec, SOAPAction:my getPlainText(SOAPActionPram)}
			end tell
		end using terms from
		
	on error errMsg number errNum
		set the contents of text view "results" of scroll view 1 of window "SOAPtalk" to errMsg & " " & errNum & return & "Are you connected to the Internet?"
		tell progress indicator "barberpole" of window "SOAPtalk" to stop
		set enabled of button "stop" of window "SOAPtalk" to false
	end try
	
	set the contents of text view "results" of scroll view 1 of window "SOAPtalk" to soapresult as string
	tell progress indicator "barberpole" of window "SOAPtalk" to stop
	set enabled of button "stop" of window "SOAPtalk" to false
end soapCallHandler

on getPlainText(fromUnicodeString)
	set styledText to fromUnicodeString as string
	set styledRecord to styledText as record
	return «class ktxt» of styledRecord
end getPlainText

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(*Application.applescript *)

(* This script is used to exercise two (currently) workarounds. The first is to work around  the bug in "load image" in that it won't open files outside of the project. The second is to enable "user defaults", which is Cocoa's method of reading/writing preferences for an application. *)

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Open.." menu item is chosen.
--
on choose menu item theObject
	-- Choose the image to be used in the image view
	set thePath to choose file with prompt "Select an Image"
	
	-- Call the workaround, making sure that path we pass is a posix path
	set theImage to call method "loadImage:" with parameter (POSIX path of thePath)
	
	-- Set the image of the image view to the one we loaded
	set image of image view "image" of window "main" to theImage
end choose menu item

-- This event handler is called when the application is about done launching. We initialize the preferences and 
on will finish launching theObject
	-- Initialize the user defaults (only happens if the prefs don't exist)
	call method "registerDefaultObjects:forKeys:" with parameters {{"Text", 1, 0, 1, 1, {false, true}}, {"text", "number", "popup", "slider", "radio", "switches"}}
end will finish launching


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(*Event Support.applescript *)

(* This script is used to demonstrate how to access some of the properties of the 'event' class that is missing (not implemented) from AppleScript Studio 1.0. The properties that aren't working that are demonstrate here are: characters, command key down, control key down, option key down and shift key down. *)

on keyboard up theObject event theEvent
	tell window of theObject
		-- characters
		set contents of text field "characters" to (call method "characters" of object theEvent) as string
		
		-- unmodified characters
		set contents of text field "unmodified characters" to (call method "charactersIgnoringModifiers" of object theEvent) as string
		
		-- command key down
		set state of button "command" to call method "isCommandKeyDownForEvent:" with parameter theEvent
		
		-- control key down
		set state of button "control" to call method "isControlKeyDownForEvent:" with parameter theEvent
		
		-- option key down
		set state of button "option" to call method "isOptionKeyDownForEvent:" with parameter theEvent
		
		-- shift key down
		set state of button "shift" to call method "isShiftKeyDownForEvent:" with parameter theEvent
	end tell
end keyboard up


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(*Localized String.applescript *)

(* This script is used to demonstrate a way to load a localized string from a '.strings' file. The Objective-C method that has been adde to this project is "localizedStringForKey:fromTable:" which takes two parameters. The first is the key in the .strings file (this is the string on the left hand side of the strings entry. The second is the name of the table (which is simply the name of the .strings file). Look in the "Localized.strings" file to see an example of the format for .strings file. *)

(* ==== Event Handlers ==== *)

on clicked theObject
	tell window of theObject
		if name of theObject is "open" then
			set contents of text field "output" to (call method "localizedStringForKey:fromTable:" with parameters {"OPEN_KEY", "Localized"})
		else if name of theObject is "close" then
			set contents of text field "output" to (call method "localizedStringForKey:fromTable:" with parameters {"CLOSE_KEY", "Localized"})
		end if
	end tell
end clicked

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)

(* Preferences.applescript *)

(* This script shows an example of using the workaround for reading and writing user defaults. You can use a number, string, or array for objects to be stored in the defaults.  *)

(* ==== Properties ==== *)

property preferencesWindow : null


(* ==== Event Handlers ==== *)

-- This event handler is called when the "preferences" menu item is chosen.
-- 
on choose menu item theObject
	-- Only load the preferences nib once
	if preferencesWindow is equal to null then
		load nib "Preferences"
		set preferencesWindow to window "preferences"
	end if
	
	-- Load in the preferences
	loadPreferences(preferencesWindow)
	
	-- Show the preferences window
	set visible of preferencesWindow to true
end choose menu item


-- This event handler is called when either the "cancel" or "done" buttons are clicked.
-- 
on clicked theObject
	if name of theObject is "done" then
		-- Save out the preferences
		storePreferences(preferencesWindow)
	end if
	
	-- Hide the preferences window
	set visible of preferencesWindow to false
end clicked


(* ==== Handlers ==== *)

-- This handler will read the preferences from the "Support.plist" in  the ~/Library/Preferences directory and then sets those values in the UI elements.
--
on loadPreferences(theWindow)
	-- Read in the preferences
	set theText to call method "defaultObjectForKey:" with parameter "text"
	set theNumber to call method "defaultObjectForKey:" with parameter "number"
	set thePopup to call method "defaultObjectForKey:" with parameter "popup"
	set theSlider to call method "defaultObjectForKey:" with parameter "slider"
	set theRadio to call method "defaultObjectForKey:" with parameter "radio"
	set theSwitches to call method "defaultObjectForKey:" with parameter "switches"
	
	-- Set the contents of the UI elements
	tell theWindow
		set contents of text field "text" to theText
		set contents of text field "number" to theNumber
		set contents of popup button "popup" to thePopup
		set contents of slider "slider" to theSlider
		set current row of matrix "radio" to theRadio
		set contents of button "show" to item 1 of theSwitches
		set contents of button "hide" to item 2 of theSwitches
	end tell
end loadPreferences

-- This handler will get the values from the UI elements and store those values in the  preferences file.
--
on storePreferences(theWindow)
	-- Get the contents of the UI elements
	tell theWindow
		set theText to contents of text field "text"
		set theNumber to contents of text field "number"
		set thePopup to contents of popup button "popup"
		set theSlider to contents of slider "slider"
		set theRadio to current row of matrix "radio"
		set theSwitches to {contents of button "show", contents of button "hide"}
	end tell
	
	-- Write out the preferences
	call method "setDefaultObject:forKey:" with parameters {theText, "text"}
	call method "setDefaultObject:forKey:" with parameters {theNumber, "number"}
	call method "setDefaultObject:forKey:" with parameters {thePopup, "popup"}
	call method "setDefaultObject:forKey:" with parameters {theSlider, "slider"}
	call method "setDefaultObject:forKey:" with parameters {theRadio, "radio"}
	call method "setDefaultObject:forKey:" with parameters {theSwitches, "switches"}
end storePreferences


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* WithDataSource.applescript *)

(* This script is used to demonstrate the scripting of a table view using a data source that is connected to the table view in Interface Builder. Basically the data source has columns added in the "will open" event handler, the "data rows" are added/updated/removed as need from the data source. *)

(* ==== Properties ==== *)

property contactsDataSource : null


(* ==== Event Handlers ==== *)

on clicked theObject
	if name of theObject is equal to "add" then
		-- Add a new contact
		set theRow to make new data row at the end of the data rows of contactsDataSource
		getContactInfo(window of theObject, theRow)
		
		-- Clear out the contact information
		clearContactInfo(window of theObject)
	else if name of theObject is "update" then
		set tableView to table view "contacts" of scroll view "contacts" of window of theObject
		set selectedDataRows to selected data rows of tableView
		if (count of selectedDataRows) > 0 then
			-- Update the contact
			getContactInfo(window of theObject, item 1 of selectedDataRows)
			
			-- Tell the table view to update it's values
			tell tableView to update
		end if
	else if name of theObject is "remove" then
		set tableView to table view "contacts" of scroll view "contacts" of window of theObject
		set selectedDataRows to selected data rows of tableView
		if (count of selectedDataRows) > 0 then
			tell window of theObject
				-- Remove the contact form the data source
				delete (item 1 of selectedDataRows)
				
				-- Clear out the contact information
				my clearContactInfo(window of theObject)
			end tell
		end if
	end if
end clicked

on will open theObject
	-- Set up the contactDataSource so that the rest will be simpler
	set contactsDataSource to data source of table view "contacts" of scroll view "contacts" of theObject
	
	-- Here we will add the data columns to the data source of the contacts table view
	tell contactsDataSource
		make new data column at the end of the data columns with properties {name:"name"}
		make new data column at the end of the data columns with properties {name:"address"}
		make new data column at the end of the data columns with properties {name:"city"}
		make new data column at the end of the data columns with properties {name:"state"}
		make new data column at the end of the data columns with properties {name:"zip"}
	end tell
end will open

on selection changed theObject
	if name of theObject is "contacts" then
		set theWindow to window of theObject
		
		-- Set the contact index to the current row, so that we can use it to update the right contact later
		set selectedDataRows to selected data rows of theObject
		
		if (count of selectedDataRows) = 0 then
			-- There wasn't any selected so clear the contact information
			my clearContactInfo(theWindow)
			
			-- Disable the "Update" and "Remove" buttons
			set enabled of button "update" of theWindow to false
			set enabled of button "remove" of theWindow to false
		else
			-- A contact was selected, so show the contact information
			my setContactInfo(theWindow, item 1 of selectedDataRows)
			
			-- Enable the "Update" and "Remove" buttons
			set enabled of button "update" of theWindow to true
			set enabled of button "remove" of theWindow to true
		end if
	end if
end selection changed


(* ==== Contact Handlers ==== *)

-- Empty all of the text fields
--
on clearContactInfo(theWindow)
	tell theWindow
		set contents of text field "name" to ""
		set contents of text field "address" to ""
		set contents of text field "city" to ""
		set contents of text field "state" to ""
		set contents of text field "zip" to ""
		set first responder to text field "name"
	end tell
end clearContactInfo

-- Get the values from the text fields and set the cells in the the data row
--
on getContactInfo(theWindow, theRow)
	tell theWindow
		set contents of data cell "name" of theRow to contents of text field "name"
		set contents of data cell "address" of theRow to contents of text field "address"
		set contents of data cell "city" of theRow to contents of text field "city"
		set contents of data cell "state" of theRow to contents of text field "state"
		set contents of data cell "zip" of theRow to contents of text field "zip"
	end tell
end getContactInfo

-- Set the text fields with the values from the contact
-- 
on setContactInfo(theWindow, theRow)
	tell theWindow
		set contents of text field "name" to contents of data cell "name" of theRow
		set contents of text field "address" to contents of data cell "address" of theRow
		set contents of text field "city" to contents of data cell "city" of theRow
		set contents of text field "state" to contents of data cell "state" of theRow
		set contents of text field "zip" to contents of data cell "zip" of theRow
	end tell
end setContactInfo


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* WithoutDataSource.applescript *)

(* This script is used to demonstrate the scripting of a table view without using a data source. The important part of supplying the table with information is in the "cell value" and "number of rows" event handlers. The table will query the script asking it for the number of rows, and then for every row of every column the "number of rows" event handler will be called, returning the contents of the cell for the table to display. *)

(* ==== Properties ==== *)

property contacts : {}
property contactIndex : 0


(* ==== Event Handlers ==== *)

on clicked theObject
	if name of theObject is "add" then
		-- Add a new contact
		tell window of theObject
			-- Create a contact record from the values in the text fields and add it to the list of contacts 
			set contacts to contacts & {my getContactInfo(window of theObject)}
			
			-- Tell the table view to update it's values
			tell table view "contacts" of scroll view "contacts" to update
			
			-- Clear out the contact information
			my clearContactInfo(window of theObject)
		end tell
		
	else if name of theObject is "update" then
		-- Update the contact
		tell window of theObject
			-- Update the contact information
			set item contactIndex of contacts to my getContactInfo(window of theObject)
			
			-- Tell the table view to update it's values
			tell table view "contacts" of scroll view "contacts" to update
		end tell
	else if name of theObject is "remove" then
		-- Remove the contact
		if contactIndex > 0 and contactIndex ≤ (count of contacts) then
			tell window of theObject
				-- Remove the contact form the list
				set contacts to my deleteItemInList(contactIndex, contacts)
				
				-- Tell the table view to update it's values
				tell table view "contacts" of scroll view "contacts" to update
				
				-- Clear out the contact information
				my clearContactInfo(window of theObject)
			end tell
		end if
	end if
end clicked

-- Return the value of the specified column for the given row
-- 
on cell value theObject row theRow table column theColumn
	-- Set the value to an empty string for now
	set theValue to ""
	
	-- Make sure that we aren't being asked for a row that is greater than the number of contacts
	if (count of contacts) ≥ theRow then
		set theContact to item theRow of contacts
		
		-- Get the identifier of the column so that we can determine which field of the record to return
		set theID to identifier of theColumn
		if the theID is "name" then
			set theValue to name of theContact
		else if theID is "address" then
			set theValue to address of theContact
		else if theID is "city" then
			set theValue to city of theContact
		else if theID is "state" then
			set theValue to state of theContact
		else if theID is "zip" then
			set theValue to zip of theContact
		end if
	end if
	
	-- Now return the value that we set
	return theValue
end cell value

-- Return the number of contacts
--
on number of rows theObject
	return count of contacts
end number of rows

on selection changed theObject
	if name of theObject is "contacts" then
		set theWindow to window of theObject
		
		-- Set the contact index to the current row, so that we can use it to update the right contact later
		set contactIndex to selected row of theObject
		
		if contactIndex = 0 then
			-- There wasn't any selected so clear the contact information
			my clearContactInfo(theWindow)
			
			-- Disable the "Update" and "Remove" buttons
			set enabled of button "update" of theWindow to false
			set enabled of button "remove" of theWindow to false
		else
			-- A contact was selected, so show the contact information
			my setContactInfo(theWindow, item contactIndex of contacts)
			
			-- Enable the "Update" and "Remove" buttons
			set enabled of button "update" of theWindow to true
			set enabled of button "remove" of theWindow to true
		end if
	end if
end selection changed


(* ==== Contact Handlers ==== *)

-- Empty all of the text fields
--
on clearContactInfo(theWindow)
	tell theWindow
		set contents of text field "name" to ""
		set contents of text field "address" to ""
		set contents of text field "city" to ""
		set contents of text field "state" to ""
		set contents of text field "zip" to ""
		set first responder to text field "name"
	end tell
end clearContactInfo

-- Get the values from the text fields and return a contact record
--
on getContactInfo(theWindow)
	tell theWindow
		return {name:contents of text field "name", address:contents of text field "address", city:contents of text field "city", state:contents of text field "state", zip:contents of text field "zip"}
	end tell
end getContactInfo

-- Set the text fields with the values from the contact
-- 
on setContactInfo(theWindow, theContact)
	tell theWindow
		set contents of text field "name" to name of theContact
		set contents of text field "address" to address of theContact
		set contents of text field "city" to city of theContact
		set contents of text field "state" to state of theContact
		set contents of text field "zip" to zip of theContact
	end tell
end setContactInfo

(* ==== Utilities ==== *)

on deleteItemInList(x, theList)
	set x to (x as number)
	if x < 1 then return theList
	set numItems to count of items in theList
	if numItems is 1 then return {}
	if x > numItems then return theList
	if x = 1 then
		set newList to (items 2 thru -1 of theList)
	else if x = numItems then
		set newList to (items 1 thru -2 of theList)
	else
		set newList to (items 1 thru (x - 1) of theList) & (items (x + 1) thru -1 of theList)
	end if
	return newList
end deleteItemInList


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Table Reorder.applescript *)

(* This example populates a table view using the "content" property and then uses the "allows reordering" property of the table and outline views to enable the automatic support of drag and drop to reorder data rows.
*)


(* ===== Event Handlers ===== *)

-- This event handler is attached to the table view and is a good place to setup our data source.
--
on awake from nib theObject
	-- Setup the data source, data rows and data cells simply by setting the "content" property of the table view.
	set content of theObject to {{|property|:"Zoomed", include:true}, {|property|:"Miniaturized", include:true}, {|property|:"Floating", include:false}, {|property|:"Modal", include:false}, {|property|:"Visible", include:true}, {|property|:"Closeable", include:true}, {|property|:"Resizable", include:true}, {|property|:"Zoomable", include:true}, {|property|:"Titled", include:true}}
end awake from nib

-- This event handler is called when the user clicks on the check box.
--
on clicked theObject
	set allows reordering of table view "table" of scroll view "scroll" of window of theObject to state of theObject
end clicked


(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Table Sort.applescript *)

(* This example demonstrates how easy it is to add sorting to your tables. In the example, you can click on different columns to sort on that column. Clicking more than once in the same column changes the sort order of that column. *)

(* ==== Properties ==== *)

property tableData : {{|name|:"Bart Simpson", city:"Springfield", zip:"19542", age:12}, {|name|:"Ally McBiel", city:"Chicago", zip:"91544", age:28}, {|name|:"Joan of Ark", city:"Paris", zip:"53255", age:36}, {|name|:"King Tut", city:"Egypt", zip:"00245", age:45}, {|name|:"James Taylor", city:"Atlanta", zip:"21769", age:42}}


(* ==== Event Handlers ==== *)

-- The "awake from nib" event handler is attached to the table view. It will be called when the table view is loaded from the nib. It's a good place to create our data source and set up the data columns.
--
on awake from nib theObject
	-- Create the data source
	set theDataSource to make new data source at end of data sources with properties {name:"names"}
	
	-- Create each of the data columns, including the sort information for each column
	make new data column at end of data columns of theDataSource with properties {name:"name", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
	make new data column at end of data columns of theDataSource with properties {name:"city", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
	make new data column at end of data columns of theDataSource with properties {name:"zip", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
	make new data column at end of data columns of theDataSource with properties {name:"age", sort order:ascending, sort type:numerical, sort case sensitivity:case sensitive}
	
	-- Make this a sorted data source
	set sorted of theDataSource to true
	
	-- Set the "name" data column as the sort column
	set sort column of theDataSource to data column "name" of theDataSource
	
	-- Set the data source of the table view to the new data source
	set data source of theObject to theDataSource
	
	-- Add the table data (using the new "append" command)
	append theDataSource with tableData
end awake from nib


-- The "launched" event handler is attached to the application object ("File's Owner of MainMenu.nib"). It is called towards the end of the startup sequence.
--
on launched theObject
	-- Show the main window
	show window "main"
end launched


-- The "column clicked" event handler is called when the user clicks on a table column in the table view. We will use this handler to change the sort column of the data source as well as the sort order.
--
on column clicked theObject table column tableColumn
	-- Get the data source of the table view
	set theDataSource to data source of theObject
	
	-- Get the identifier of the clicked table column
	set theColumnIdentifier to identifier of tableColumn
	
	-- Get the current sort column of the data source
	set theSortColumn to sort column of theDataSource
	
	-- If the current sort column is not the same as the clicked column then switch the sort column
	if (name of theSortColumn) is not equal to theColumnIdentifier then
		set the sort column of theDataSource to data column theColumnIdentifier of theDataSource
	else
		-- Otherwise change the sort order
		if sort order of theSortColumn is ascending then
			set sort order of theSortColumn to descending
		else
			set sort order of theSortColumn to ascending
		end if
	end if
	
	-- We need to update the table view (so it will be redrawn)
	update theObject
end column clicked


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* ==== Event Handlers ==== *)

on will open theObject
	set movie of movie view "movie" of window "main" to load movie "jumps"
end will open

on choose menu item theMenuItem
	tell window "main"
		set theCommand to tag of theMenuItem
		
		if theCommand is equal to 1001 then
			set moviePath to choose file
			set movie file of movie view "movie" to moviePath
		else if theCommand is equal to 1002 then
			tell movie view "movie" to play
		else if theCommand is equal to 1003 then
			tell movie view "movie" to stop
		else if theCommand is equal to 1004 then
			tell movie view "movie" to step forward
		else if theCommand is equal to 1005 then
			tell movie view "movie" to step back
		else if theCommand is equal to 1006 then
			tell movie view "movie" to go to beginning frame
		else if theCommand is equal to 1007 then
			tell movie view "movie" to go to end frame
		else if theCommand is equal to 1008 then
			tell movie view "movie" to go to poster frame
		else if theCommand is equal to 1009 then
			set loop mode of movie view "movie" to normal playback
		else if theCommand is equal to 1010 then
			set loop mode of movie view "movie" to looping playback
		else if theCommand is equal to 1011 then
			set loop mode of movie view "movie" to looping back and forth playback
		end if
	end tell
end choose menu item

on update menu item theMenuItem
	tell window "main"
		local enableItem
		set enableItem to 1
		
		set theCommand to tag of theMenuItem
		set thePlayBack to loop mode of movie view "movie"
		
		if theCommand is equal to 1002 then
			if playing of movie view "movie" is true then set enableItem to 0
		else if theCommand is equal to 1003 then
			if playing of movie view "movie" is false then set enableItem to 0
		else if theCommand ≥ 1009 and theCommand ≤ 1011 then
			set theState to 0
			
			if thePlayBack is equal to normal playback and theCommand is equal to 1009 then set theState to 1
			if thePlayBack is equal to looping playback and theCommand is equal to 1010 then set theState to 1
			if thePlayBack is equal to looping back and forth playback and theCommand is equal to 1011 then set theState to 1
			
			set state of theMenuItem to theState
		end if
	end tell
	
	return enableItem
end update menu item


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Document.applescript *)

(* This is a good example of several different features of AppleScript Studio. The main one is to demonstrate how to write a document bases application using the higher level handlers "data representation" and "load data representation" (as opposed to the lower level handlers "write to file" and "read from file". It also demonstrates how to work with a table view (including support for sorting). Menu Item handling is also included in this example. *)

(* ==== Event Handlers ==== *)

-- The "awake from nib" handler is called (in this example) when the table view is loaded from the "Documents.nib" nib file. This is a good place to create a new data source and data columns and set various properties of said items.
--
on awake from nib theObject
	if name of theObject is "tasks" then
		-- Create the data source for our "tasks" table view
		set theDataSource to make new data source at end of data sources with properties {name:"tasks"}
		
		-- Create the data columns, "priority", "task" and "status". We also set the sort properties of each of the data columns, including the sort order, the type of data in each column and what type of sensitivity to use.
		make new data column at end of data columns of theDataSource with properties {name:"priority", sort order:ascending, sort type:numerical, sort case sensitivity:case sensitive}
		make new data column at end of data columns of theDataSource with properties {name:"task", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
		make new data column at end of data columns of theDataSource with properties {name:"status", sort order:ascending, sort type:alphabetical, sort case sensitivity:case sensitive}
		
		-- Set the data source as sorted
		set sorted of theDataSource to true
		
		-- Set the "priority" data column as the sort column
		set sort column of theDataSource to data column "priority" of theDataSource
		
		-- Finally, assign the data source of the table view to our data source
		set data source of theObject to theDataSource
	end if
end awake from nib


-- The "action" event handler is called whenever the user chooses a menu in the popup buttons or presses (in this example) the enter key in the text field.
--
on action theObject
	-- Set some local variables to various objects in the UI
	set theWindow to window of theObject
	set theTableView to table view "tasks" of scroll view "tasks" of theWindow
	set theDataSource to data source of theTableView
	
	-- The behavior from here will be determined by whether or not an task in the table view is selected
	if (count of selected rows of theTableView) is 0 then
		-- Since nothing is selected we will create a new task (but only if the enter key is pressed in the "task" text field)
		if name of theObject is "task" then
			-- Make a new data row
			set theTask to make new data row at end of data rows of theDataSource
			
			-- Populate the task using values in the UI
			setTaskValuesWithUIValues(theTask, theWindow)
			
			-- Now set the UI to default values
			setDefaultUIValues(theWindow)
			
			-- Make the "task" text field the object with the focus so that it will be ready for typing
			set first responder of theWindow to text field "task" of theWindow
		end if
	else
		-- Get the selected task from the table view
		set theTask to selected data row of theTableView
		
		-- See which object was touched
		if name of theObject is "priority" then
			set contents of data cell "priority" of theTask to title of theObject
		else if name of theObject is "task" then
			set contents of data cell "task" of theTask to content of theObject
		else if name of theObject is "status" then
			set contents of data cell "status" of theTask to title of theObject
		end if
	end if
end action


(* ==== Document Event Handlers ==== *)

-- The "data representation" event handler is called when the document needs to be saved. It is the responsiblity of the handler to return the data that is to be saved. This can be nearly any AppleScript object, whether it be a string, a list, a record, etc. In this case we are going to return a record that contains the list of tasks, the name of the current sort column and the sort order of the current sort column. 
--
on data representation theObject of type ofType
	-- Set some local variables to various objects in the UI
	set theWindow to window 1 of theObject
	set theDataSource to data source of table view "tasks" of scroll view "tasks" of theWindow
	set theTasks to contents of every data cell of every data row of theDataSource
	set theSortColumn to sort column of theDataSource
	
	-- Create our record containing the list of tasks (just a list of lists), the name of the sort column and the sort order.
	set theData to {tasks:theTasks, sortColumnName:name of theSortColumn, sortColumnOrder:sort order of theSortColumn}
	
	return theData
end data representation


-- The "load data representation" event handler is called when the document is being loaded. The data that you provided in the "data representation" event handler is passed to you in the "theData" parameter.
--
on load data representation theObject of type ofType with data theData
	-- Set some local variables to various objects in the UI
	set theWindow to window 1 of theObject
	set theDataSource to data source of table view "tasks" of scroll view "tasks" of theWindow
	
	-- Restore the sort column and sort order of the data source based on the information saved
	set sort column of theDataSource to data column (sortColumnName of theData) of theDataSource
	set sort order of sort column of theDataSource to (sortColumnOrder of theData)
	
	-- Use the "append" verb to quickly populate the data source with the list of tasks
	append the theDataSource with (tasks of theData)
	
	-- We return true, signaling that everything worked correctly. If you return "false" then the document will fail to load and an alert will be presented.
	return true
end load data representation


(* ==== Data View Event Handlers ==== *)

-- The "selection changing" event handler is called whenever the selection in the table view is changing. We will use this to update the values in the UI based on the selection.
--
on selection changing theObject
	if name of theObject is "tasks" then
		-- If there is a selection then we'll update the UI, otherwise we set the UI to default values
		if (count of selected rows of theObject) > 0 then
			-- Get the selected data row of the table view
			set theTask to selected data row of theObject
			
			-- Update the UI using the selected task
			setUIValuesWithTaskValues(window of theObject, theTask)
		else
			-- Set the UI to default values
			setDefaultUIValues(window of theObject)
		end if
	end if
end selection changing


-- The "selection changing" event handler is called whenever the selection in the table view is changing. We will use this to update the values in the UI based on the selection.
--
on selection changed theObject
	if name of theObject is "tasks" then
		-- If there is a selection then we'll update the UI, otherwise we set the UI to default values
		if (count of selected rows of theObject) > 0 then
			-- Get the selected data row of the table view
			set theTask to selected data row of theObject
			
			-- Update the UI using the selected task
			setUIValuesWithTaskValues(window of theObject, theTask)
		else
			-- Set the UI to default values
			setDefaultUIValues(window of theObject)
		end if
	end if
end selection changed


-- The "column clicked" event handler is called whenever the user clickes on a column in the table view. We will change the sort state based on the column clicked. This event handler can be used as is in most applications when utilizing the sort support built into data sources.
--
on column clicked theObject table column tableColumn
	-- Get the data source of the table view
	set theDataSource to data source of theObject
	
	-- Get the name of the clicked table column
	set theColumnName to name of tableColumn
	
	-- Get the current sort column of the data source
	set theSortColumn to sort column of theDataSource
	
	-- If the current sort column is not the same as the clicked column then switch the sort column
	if (name of theSortColumn) is not equal to theColumnName then
		set the sort column of theDataSource to data column theColumnName of theDataSource
	else
		-- Otherwise change the sort order
		if sort order of theSortColumn is ascending then
			set sort order of theSortColumn to descending
		else
			set sort order of theSortColumn to ascending
		end if
	end if
	
	-- We need to update the table view (so it will be redrawn)
	update theObject
end column clicked


(* ==== Menu Item Event Handlers ==== *)

-- The "choose menu item" is called (in this example) whenever the user chooses one of the "New Task, Duplicate Task, and Delete Task" menu items.
--
on choose menu item theObject
	-- Set some local variables to various objects in the UI
	set theWindow to front window
	set theTableView to table view "tasks" of scroll view "tasks" of theWindow
	set theDataSource to data source of theTableView
	
	if name of theObject is "new" then
		-- New Task
		set theTask to make new data row at end of data rows of theDataSource
		
		-- Set the UI to default values
		setDefaultTaskValues(theTask)
		
		-- Select the newly added task
		set selected data row of theTableView to theTask
		
		-- Make the "task" text field the object with the focus so that it will be ready for typing
		set first responder of theWindow to text field "task" of theWindow
	else if name of theObject is "duplicate" then
		-- Duplicate Task (only if there is a task selected in the table view)
		if (count of selected data rows of theTableView) > 0 then
			-- Get the selected task
			set theTask to selected data row of theTableView
			
			-- Make a new task and copy the values from the selected one to the new one. (There is a bug in the copy of a data row such that you can't simply say "copy theTask to end of data rows of theDataSource").
			set newTask to make new data row at end of data rows of theDataSource
			set contents of data cell "priority" of newTask to contents of data cell "priority" of theTask
			set contents of data cell "task" of newTask to contents of data cell "task" of theTask
			set contents of data cell "status" of newTask to contents of data cell "status" of theTask
		end if
	else if name of theObject is "delete" then
		-- Delete Task
		if (count of selected data rows of theTableView) > 0 then
			-- Get the selected task
			set theTask to selected data row of theTableView
			
			-- Delete it
			delete theTask
		end if
	end if
end choose menu item


-- The "update menu item" is called whenever the status of any the "Task" menu items need to be updated (for instance when the user clicks on the "Edit" menu where these menu items are). 
--
on update menu item theObject
	-- By default we will enable each of these items
	if front window exists then
		set shouldEnable to true
		
		-- Set some local variables to various objects in the UI
		set theWindow to front window
		set theTableView to table view "tasks" of scroll view "tasks" of theWindow
		set theDataSource to data source of theTableView
		
		if name of theObject is "duplicate" then
			-- If there isn't a task selected disable the "Duplicate Task" menu item
			if (count of selected data rows of theTableView) is 0 then
				set shouldEnable to false
			end if
		else if name of theObject is "delete" then
			-- If there isn't a task selected disable the "Delete Task" menu item
			if (count of selected data rows of theTableView) is 0 then
				set shouldEnable to false
			end if
		end if
	else
		set shouldEnable to false
	end if
	
	-- Return out enable state
	return shouldEnable
end update menu item


(* ==== Handlers ==== *)

-- This handler will set the default values of a new task
--
on setDefaultTaskValues(theTask)
	set contents of data cell "priority" of theTask to "3"
	set contents of data cell "task" of theTask to ""
	set contents of data cell "status" of theTask to "Not Started"
end setDefaultTaskValues

-- This handler will set the default values of UI
--
on setDefaultUIValues(theWindow)
	tell theWindow
		set title of popup button "priority" to "3"
		set contents of text field "task" to ""
		set title of popup button "status" to "Not Started"
	end tell
end setDefaultUIValues

-- This handler will set the values of the given task using the values in the UI
--
on setTaskValuesWithUIValues(theTask, theWindow)
	set contents of data cell "priority" of theTask to title of popup button "priority" of theWindow
	set contents of data cell "task" of theTask to contents of text field "task" of theWindow
	set contents of data cell "status" of theTask to title of popup button "status" of theWindow
end setTaskValuesWithUIValues

-- This handler will set the values of the UI using the given task
--
on setUIValuesWithTaskValues(theWindow, theTask)
	set title of popup button "priority" of theWindow to contents of data cell "priority" of theTask
	set contents of text field "task" of theWindow to contents of data cell "task" of theTask
	set title of popup button "status" of theWindow to contents of data cell "status" of theTask
end setUIValuesWithTaskValues


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Application.applescript *)

(* ==== Globals ==== *)

global converterLib
global logLib
global LogController
global Converter
global LengthConverter
global WeightConverter
global LiquidVolumeConverter
global VolumeConverter
global AreaConverter
global TemperatureConverter


(* ==== Properties ==== *)

property currentConverter : 0
property scriptsLoaded : false


(* ==== Event Handlers ==== *)

on clicked theObject
	tell window "Main"
		if theObject is equal to button "Convert" of box 1 then
			my convert()
		else if the theObject is equal to button "Drawer" then
			if state of drawer "Log" is drawer closed then
				tell drawer "Log" to open drawer on bottom edge
			else
				tell drawer "Log" to close drawer
			end if
		else if the theObject is equal to button "Clear" of box 1 of drawer "Log" then
			tell LogController to clearLog()
		else if the theObject is equal to button "Save As" of box 1 of drawer "Log" then
			set logFile to choose file name with prompt "Save Log As" default name "Conversion Results.txt"
			tell LogController to saveLogInFile(logFile)
		end if
	end tell
end clicked

on choose menu item theObject
	tell window "Main"
		if theObject is equal to popup button "Type" of box 1 then
			set currentConverter to my getConverterForType(title of popup button "Type" of box 1)
			tell currentConverter to updateUnitTypes()
		else
			my convert()
		end if
	end tell
end choose menu item

on action theObject
	if theObject is equal to text field "Value" of box 1 of window "Main" then
		my convert()
	end if
end action

on launched theObject
	my loadScripts()
	tell LogController to initialize()
	set currentConverter to my getConverterForType(title of popup button "Type" of box 1 of window "Main")
	
	set visible of window "Main" to true
end launched


(* ==== Handlers ==== *)

on convert()
	if contents of text field "Value" of box 1 of window "Main" is equal to "" then
		display alert "You must enter a value to convert." as critical attached to window "Main"
	else
		tell currentConverter to convert()
	end if
end convert

on getConverterForType(typeName)
	if typeName is equal to "length" then
		return LengthConverter
	else if typeName is equal to "weight and mass" then
		return WeightConverter
	else if typeName is equal to "liquid volume" then
		return LiquidVolumeConverter
	else if typeName is equal to "volume" then
		return VolumeConverter
	else if typeName is equal to "area" then
		return AreaConverter
	else if typeName is equal to "temperature" then
		return TemperatureConverter
	else
		return Converter
	end if
end getConverterForType

on pathToScripts()
	set appPath to (path to me from user domain) as text
	return (appPath & "Contents:Resources:Scripts:") as text
end pathToScripts

on loadScript(scriptName)
	return load script file (my pathToScripts() & scriptName & ".scpt")
end loadScript

on loadScripts()
	set logLib to my loadScript("Log Controller")
	set converterLib to my loadScript("Converter")
	
	set LogController to LogController of logLib
	set Converter to Converter of converterLib
	set LengthConverter to LengthConverter of converterLib
	set WeightConverter to WeightConverter of converterLib
	set LiquidVolumeConverter to LiquidVolumeConverter of converterLib
	set VolumeConverter to VolumeConverter of converterLib
	set AreaConverter to AreaConverter of converterLib
	set TemperatureConverter to TemperatureConverter of converterLib
end loadScripts


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Converter.applescript *)

(* ==== Globals ==== *)

global LogController


(* ==== Scripts ==== *)

script Converter
	property measureType : ""
	property fromMeasure : ""
	property toMeasure : ""
	property fromUnits : 0
	property resultUnits : 0
	property unitTypes : {}
	
	on initializeUnitTypes()
	end initializeUnitTypes
	
	on convert()
		tell box 1 of window "Main"
			set measureType to title of popup button "Type"
			set fromMeasure to title of popup button "From"
			set toMeasure to title of popup button "To"
			set fromUnits to contents of text field "Value" as real
			set resultUnits to 0
		end tell
	end convert
	
	on updateUnitTypes()
		tell box 1 of window "Main"
			-- Delete all of the menu items from the popups
			delete every menu item of menu of popup button "From"
			delete every menu item of menu of popup button "To"
			
			-- Add each of the unit types as menu items to both of the popups
			repeat with i in my unitTypes
				make new menu item at the end of menu items of menu of popup button "From" with properties {title:i, enabled:true}
				make new menu item at the end of menu items of menu of popup button "To" with properties {title:i, enabled:true}
			end repeat
		end tell
	end updateUnitTypes
	
	on updateObject(theObject)
	end updateObject
	
	on updateResult(theResult)
		set contents of text field "Result" of box 1 of window "Main" to (theResult as text)
		tell LogController to addResultToLog((fromUnits as text) & " " & fromMeasure & " equals " & (theResult as text) & " " & toMeasure)
	end updateResult
end script

script LengthConverter
	property parent : Converter
	property unitTypes : {"kilometers", "meters", "centimeters", "miles", "yards", "feet", "inches"}
	
	on convert()
		continue convert()
		
		if my fromMeasure = "kilometers" then
			set my resultUnits to my fromUnits as kilometers
		else if my fromMeasure = "meters" then
			set my resultUnits to my fromUnits as meters
		else if my fromMeasure = "centimeters" then
			set my resultUnits to my fromUnits as centimeters
		else if my fromMeasure = "miles" then
			set my resultUnits to my fromUnits as miles
		else if my fromMeasure = "yards" then
			set my resultUnits to my fromUnits as yards
		else if my fromMeasure = "feet" then
			set my resultUnits to my fromUnits as feet
		else if my fromMeasure = "inches" then
			set my resultUnits to my fromUnits as inches
		end if
		
		if my toMeasure = "kilometers" then
			set my resultUnits to my resultUnits as kilometers
		else if my toMeasure = "meters" then
			set my resultUnits to my resultUnits as meters
		else if my toMeasure = "centimeters" then
			set my resultUnits to my resultUnits as centimeters
		else if my toMeasure = "miles" then
			set my resultUnits to my resultUnits as miles
		else if my toMeasure = "yards" then
			set my resultUnits to my resultUnits as yards
		else if my toMeasure = "feet" then
			set my resultUnits to my resultUnits as feet
		else if my toMeasure = "inches" then
			set my resultUnits to my resultUnits as inches
		end if
		
		my updateResult(my resultUnits)
	end convert
end script

script WeightConverter
	property parent : Converter
	property unitTypes : {"kilograms", "grams", "pounds", "ounces"}
	
	on convert()
		continue convert()
		
		if my fromMeasure = "kilograms" then
			set my resultUnits to my fromUnits as kilograms
		else if my fromMeasure = "grams" then
			set my resultUnits to my fromUnits as grams
		else if my fromMeasure = "pounds" then
			set my resultUnits to my fromUnits as pounds
		else if my fromMeasure = "ounces" then
			set my resultUnits to my fromUnits as ounces
		end if
		
		if my toMeasure = "kilograms" then
			set my resultUnits to my resultUnits as kilograms
		else if my toMeasure = "grams" then
			set my resultUnits to my resultUnits as grams
		else if my toMeasure = "pounds" then
			set my resultUnits to my resultUnits as pounds
		else if my toMeasure = "ounces" then
			set my resultUnits to my resultUnits as ounces
		end if
		
		my updateResult(my resultUnits)
	end convert
end script

script LiquidVolumeConverter
	property parent : Converter
	property unitTypes : {"liters", "gallons", "quarts"}
	
	on convert()
		continue convert()
		
		if my fromMeasure = "liters" then
			set my resultUnits to my fromUnits as liters
		else if my fromMeasure = "gallons" then
			set my resultUnits to my fromUnits as gallons
		else if my fromMeasure = "quarts" then
			set my resultUnits to my fromUnits as quarts
		end if
		
		if my toMeasure = "liters" then
			set my resultUnits to my resultUnits as liters
		else if my toMeasure = "gallons" then
			set my resultUnits to my resultUnits as gallons
		else if my toMeasure = "quarts" then
			set my resultUnits to my resultUnits as quarts
		end if
		
		my updateResult(my resultUnits)
	end convert
end script

script VolumeConverter
	property parent : Converter
	property unitTypes : {"cubic centimeters", "cubic meters", "cubic inches", "cubic feet", "cubic yards"}
	
	on convert()
		continue convert()
		
		if my fromMeasure = "cubic centimeters" then
			set my resultUnits to my fromUnits as cubic centimeters
		else if my fromMeasure = "cubic meters" then
			set my resultUnits to my fromUnits as cubic meters
		else if my fromMeasure = "cubic inches" then
			set my resultUnits to my fromUnits as cubic inches
		else if my fromMeasure = "cubic feet" then
			set my resultUnits to my fromUnits as cubic feet
		else if my fromMeasure = "cubic yards" then
			set my resultUnits to my fromUnits as cubic yards
		end if
		
		if my toMeasure = "cubic centimeters" then
			set my resultUnits to my resultUnits as cubic centimeters
		else if my toMeasure = "cubic meters" then
			set my resultUnits to my resultUnits as cubic meters
		else if my toMeasure = "cubic inches" then
			set my resultUnits to my resultUnits as cubic inches
		else if my toMeasure = "cubic feet" then
			set my resultUnits to my resultUnits as cubic feet
		else if my toMeasure = "cubic yards" then
			set my resultUnits to my resultUnits as cubic yards
		end if
		
		my updateResult(my resultUnits)
	end convert
end script

script AreaConverter
	property parent : Converter
	property unitTypes : {"square meters", "square kilometers", "square feet", "square yards", "square miles"}
	
	on convert()
		continue convert()
		
		if my fromMeasure = "square meters" then
			set my resultUnits to my fromUnits as square meters
		else if my fromMeasure = "square kilometers" then
			set my resultUnits to my fromUnits as square kilometers
		else if my fromMeasure = "square feet" then
			set my resultUnits to my fromUnits as square feet
		else if my fromMeasure = "square yards" then
			set my resultUnits to my fromUnits as square yards
		else if my fromMeasure = "square miles" then
			set my resultUnits to my fromUnits as square miles
		else if my fromMeasure = "feet" then
			set my resultUnits to my fromUnits as feet
		else if my fromMeasure = "inches" then
			set my resultUnits to my fromUnits as inches
		end if
		
		if my toMeasure = "square meters" then
			set my resultUnits to my resultUnits as square meters
		else if my toMeasure = "square kilometers" then
			set my resultUnits to my resultUnits as square kilometers
		else if my toMeasure = "square feet" then
			set my resultUnits to my resultUnits as square feet
		else if my toMeasure = "square yards" then
			set my resultUnits to my resultUnits as square yards
		else if my toMeasure = "square miles" then
			set my resultUnits to my resultUnits as square miles
		end if
		
		my updateResult(my resultUnits)
	end convert
end script

script TemperatureConverter
	property parent : Converter
	property unitTypes : {"degrees Fahrenheit", "degrees Celsius", "degrees Kelvin"}
	
	on convert()
		continue convert()
		
		if my fromMeasure = "degrees Fahrenheit" then
			set my resultUnits to my fromUnits as degrees Fahrenheit
		else if my fromMeasure = "degrees Celsius" then
			set my resultUnits to my fromUnits as degrees Celsius
		else if my fromMeasure = "degrees Kelvin" then
			set my resultUnits to my fromUnits as degrees Kelvin
		end if
		
		if my toMeasure = "degrees Fahrenheit" then
			set my resultUnits to my resultUnits as degrees Fahrenheit
		else if my toMeasure = "degrees Celsius" then
			set my resultUnits to my resultUnits as degrees Celsius
		else if my toMeasure = "degrees Kelvin" then
			set my resultUnits to my resultUnits as degrees Kelvin
		end if
		
		my updateResult(my resultUnits)
	end convert
end script

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Log Controller.applescript *)

(* ==== Scripts ==== *)

script LogController
	property initialized : false
	
	on initialize()
		if initialized is equal to false then
			set leading offset of drawer "Log" of window "Main" to 20
			set trailing offset of drawer "Log" of window "Main" to 20
			set initialized to true
		end if
		
		my clearLog()
	end initialize
	
	on addResultToLog(theResult)
		tell scroll view 1 of drawer "Log" of window "Main"
			set prevResult to contents of text view "Log"
			if prevResult is equal to return or prevResult is equal to "" then
				set contents of text view "Log" to theResult
			else
				set contents of text view "Log" to prevResult & return & theResult
			end if
		end tell
	end addResultToLog
	
	on clearLog()
		set contents of text view "Log" of scroll view 1 of drawer "Log" of window "Main" to ""
	end clearLog
	
	on saveLogInFile(logFile)
		open for access logFile with write permission
		set logText to contents of text view "Log" of scroll view 1 of drawer "Log" of window "Main" as string
		write logText to logFile
		close access logFile
	end saveLogInFile
	
end script


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* Service Detail.applescript *)

(* This script is used to handle events in the "Service Detail" window. *)

(* ==== Event Handlers ==== *)

-- The "clicked" event handler is called whenever the user clicks on the buttons in the detail window.
--
on clicked theObject
	if name of theObject is "mail" then
		-- Use the "open location" command to send an email
		set theServiceName to contents of text field "name" of window of theObject
		set theEmailAddress to contents of text field "email" of window of theObject
		
		open location "mailto: " & theEmailAddress
	else if name of theObject is "info site" then
		-- Open the information site for this service
		set theURL to contents of text field "info url" of window of theObject
		open location theURL
	else if name of theObject is "wsdl site" then
		-- Open the WSDL for this service
		set theURL to contents of text field "wsdl url" of window of theObject
		open location theURL
	end if
end clicked


(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
(* XMethods Service Finder.applescript *)

(* This is an example that demonstrates how to use Web Services. It utilizes a service from XMethods.org that provides information about all of the services available at their site. It also demonstrates how to create and use data sources for a table view. *)

(* The strategy used in this script is to populate the "services" list with all of the services avialable (which is also used to populate the "all services" data source. Then whenever a "find" is requested, the "found services" list is filled out the listing found in the "services" list, and then a new temporary data source is created, using the "found services" list to populate it. That data source is then set as the current data source of the table. If the user deletes the search text field, then the data rows of the "found services" data source are removed and the "all services" data source is set to be the current data source of the table view. In essence, it's just a matter of switching in and out the "all services" and "found services" data sources according to the actions of the user. *)

(* ==== Properties ==== *)

property services : {}
property foundServices : {}
property servicesTableView : missing value
property detailWindow : missing value


(* ==== Event Handlers ==== *)

-- The "launched" event handler is called near the end of the launch sequence. This is a good place to show our main window.
--
on launched theObject
	show window "main"
end launched


-- The "idle" event handler is called on a periodic basis. For our purposes, we are using it to do the initial work of getting all of the services. This is done so that the window will have already been opened and made the active window.
--
on idle theObject
	-- Only do this once (hopefully)
	if (count of services) is 0 then
		-- Show the status items in the main window with a message
		showStatus(window "main")
		updateStatusMessage(window "main", "Getting Services...")
		
		-- Get the services from the xmethods server
		set services to getServices()
		
		-- Update the status message
		updateStatusMessage(window "main", "Adding Services...")
		
		-- Add the services to our data source
		addServicesToDataSource(services, data source "all services")
		
		-- Hide the status items
		hideStatus(window "main")
	end if
	
	return 6000
end idle


-- The "awake from nib" event handler is called whenever the object attached to this handler is loaded from a nib. It's a great place to do any initialization for a particular object, as it's not necessary to locate the object within it's hierarchy.
--
on awake from nib theObject
	if name of theObject is "services" then
		-- Save a reference to the table view
		set servicesTableView to theObject
		
		-- Create a data source that will always contain all of the services, and one that will contain the currently found service
		makeDataSourceWithColumns("all services", {"publisherid", "name", "shortdescription", "id"})
		makeDataSourceWithColumns("found services", {"publisherid", "name", "shortdescription", "id"})
		
		-- Use the "all services" data source at first
		set data source of servicesTableView to data source "all services"
	else if name of theObject is "detail" then
		-- Save a reference to the new detail window
		set detailWindow to theObject
	end if
end awake from nib


-- The "double clicked" event handler is called when someone double clicks on the table view. 
--
on double clicked theObject
	if name of theObject is "services" then
		-- Show and update the message items in the main window
		showStatus(window of theObject)
		updateStatusMessage(window of theObject, "Getting Service Details...")
		
		-- Get the clicked row of the table view
		set theDataRow to clicked data row of theObject
		
		-- Get the name and id of the selected service
		set theServiceID to contents of data cell "id" of theDataRow
		set theServiceName to contents of data cell "name" of theDataRow
		
		-- See if the listing is already open
		set theWindow to findWindowWithTitle(theServiceName)
		if theWindow is not missing value then
			-- Just bring it to the front
			show theWindow
		else
			-- Load a new instance of the detail window and show it
			load nib "ServiceDetail"
			set title of detailWindow to theServiceName
			
			-- Load the service detail and update it in the window
			set theServiceDetail to getServiceDetailWithID(theServiceID as string)
			updateServiceDetailInWindow(theServiceDetail, detailWindow)
			
			-- Show the window
			show detailWindow
		end if
		
		-- Hide the status items
		hideStatus(window of theObject)
	end if
end double clicked


-- The "action" event handler is called when someone chooses a menu item from the popup button. In this case the script will just cause another "find" to happen.
--
on action theObject
	find(window of theObject)
end action

on column clicked theObject table column tableColumn
	-- Get the data source of the table view
	set theDataSource to data source of theObject
	
	-- Get the identifier of the clicked table column
	set theColumnIdentifier to identifier of tableColumn
	
	-- Get the current sort column of the data source
	try
		set theSortColumn to sort column of theDataSource
		
		-- If the current sort column is not the same as the clicked column then switch the sort column
		if (name of theSortColumn) is not equal to theColumnIdentifier then
			set the sort column of theDataSource to data column theColumnIdentifier of theDataSource
		else
			-- Otherwise change the sort order
			if sort order of theSortColumn is ascending then
				set sort order of theSortColumn to descending
			else
				set sort order of theSortColumn to ascending
			end if
		end if
	on error
		set sort column of theDataSource to data column theColumnIdentifier of theDataSource
	end try
	
	-- We need to update the table view (so it will be redrawn)
	update theObject
end column clicked


(* ==== Handlers ==== *)

-- This handler will show the status items in the main window. It also starts the animation of the progress indicator.
--
on showStatus(theWindow)
	tell theWindow
		-- Show the text field and progress indicator
		set visible of text field "status" to true
		set visible of progress indicator "progress" to true
		
		-- Make sure it's using threaded animation and start it
		set uses threaded animation of progress indicator "progress" to true
		start progress indicator "progress"
	end tell
end showStatus


-- This handler will hide the status items in the main window. It also stops the animation of the progress indicator.
--
on hideStatus(theWindow)
	tell theWindow
		-- Hide the text field and progress indicator
		set visible of text field "status" to false
		set visible of progress indicator "progress" to false
		
		-- Stop the progress indicator
		stop progress indicator "progress"
	end tell
end hideStatus


-- This handler will update the contents of the status message.
--
on updateStatusMessage(theWindow, theMessage)
	set contents of text field "status" of theWindow to theMessage
end updateStatusMessage


-- The "find" handler is used to query the data source based on the state of where, how, and what to find.
--
on find(theWindow)
	-- Show and update the status items in the window
	showStatus(theWindow)
	updateStatusMessage(theWindow, "Finding Services...")
	
	-- Get the where, how, and what to find form the UI
	tell theWindow
		set findWhere to title of popup button "where"
		set findHow to title of popup button "how"
		set findWhat to contents of text field "what"
	end tell
	
	-- If there isn't anything specified in the "what", then switch in the "all services" data source
	if findWhat is "" then
		set data source of servicesTableView to data source "all services"
		update servicesTableView
	else
		-- Otherwise, find the matching services
		set foundServices to findServices(findWhere, findHow, findWhat)
		
		-- Turn off the updating of the table view while we manipulate the data source
		set update views of data source "found services" to false
		
		-- Delete all of the data rows in the data source
		delete every data row of data source "found services"
		
		-- Make sure that we have at least one found web service and then add the services to the data source
		if (count of foundServices) > 0 then
			addServicesToDataSource(foundServices, data source "found services")
		end if
		
		-- Switch in the "found  services" data source into the table view
		set data source of servicesTableView to data source "found services"
		
		-- Turn back on the updating of the table view
		set update views of data source "found services" to true
	end if
	
	-- Hide the status items
	hideStatus(theWindow)
end find


-- This is a utility handler that will create a new data source with the given name and columns names.
--
on makeDataSourceWithColumns(theName, theColumnNames)
	-- Make the data source
	make new data source at the end of the data sources with properties {name:theName}
	
	-- Add the data columns
	repeat with columnName in theColumnNames
		make new data column at the end of the data columns of data source theName with properties {name:columnName, sort order:ascending, sort type:alphabetical, sort case sensitivity:case insensitive}
	end repeat
	
	-- Set the first column to be  the sort column
	set sort column of data source theName to data column (item 1 of theColumnNames) of data source theName
	
	-- Make the data source sorted
	set sorted of data source theName to true
	
end makeDataSourceWithColumns


-- This handler adds the records to the data source using the "append" command.
--
on addServicesToDataSource(theServices, theDataSource)
	-- Turn off updating the associated table view
	set update views of theDataSource to false
	
	-- Add the records to the data source
	append theDataSource with theServices
	
	-- Turn the updating of the table view back on
	set update views of theDataSource to true
end addServicesToDataSource


-- This is handler will do the actual searching of the "services" list based on the where, how and what parameters.
--
on findServices(findWhere, findHow, findWhat)
	-- Set the result to an empty list
	set theServices to {}
	
	-- Determine which field of the record to search based on "where"
	if findWhere is "Publisher" then
		repeat with service in services
			set theValue to publisherid of service
			if findHow is "begins with" and theValue begins with findWhat then
				copy service to the end of theServices
			else if findHow is "contains" and theValue contains findWhat then
				copy service to the end of theServices
			else if findHow is "ends with" and theValue ends with findWhat then
				copy service to the end of theServices
			else if findHow is "is" and theValue is findWhat then
				copy service to the end of theServices
			end if
		end repeat
	else if findWhere is "Service Name" then
		repeat with service in services
			set theValue to |name| of service
			if findHow is "begins with" and theValue begins with findWhat then
				copy service to the end of theServices
			else if findHow is "contains" and theValue contains findWhat then
				copy service to the end of theServices
			else if findHow is "ends with" and theValue ends with findWhat then
				copy service to the end of theServices
			else if findHow is "is" and theValue is findWhat then
				copy service to the end of theServices
			end if
		end repeat
	else if findWhere is "Description" then
		repeat with service in services
			set theValue to shortdescription of service
			if findHow is "begins with" and theValue begins with findWhat then
				copy service to the end of theServices
			else if findHow is "contains" and theValue contains findWhat then
				copy service to the end of theServices
			else if findHow is "ends with" and theValue ends with findWhat then
				copy service to the end of theServices
			else if findHow is "is" and theValue is findWhat then
				copy service to the end of theServices
			end if
		end repeat
	end if
	
	-- Return the services that were found
	return theServices
end findServices


-- This handler is called when the user has double clicked on one of the services in the table view. It will update the UI elements in the specified detail window with the given service detail record.
--
on updateServiceDetailInWindow(theServiceDetail, theWindow)
	tell theWindow
		-- Update the contents of each of the text fields with the corresponding fields from the detail record.
		set contents of text field "name" to |name| of theServiceDetail
		set contents of text field "description" to shortdescription of theServiceDetail
		set contents of text field "publisher" to publisherid of theServiceDetail
		set contents of text field "email" to email of theServiceDetail
		--set contents of text field "info url" to infourl of theServiceDetail
		set contents of text field "wsdl url" to wsdlurl of theServiceDetail
		
		-- Check to see if we actually have a "note" field.
		if notes of theServiceDetail is not "<<nil not supported>>" then
			set contents of text view "notes" of scroll view "notes" to notes of theServiceDetail
		end if
	end tell
end updateServiceDetailInWindow


(* ==== Web Services Handlers ==== *)

-- The "getServices" handler is used to get a list of records that describes all of the services available from XMethods.org.
--
on getServices()
	-- Set the result to an empty list
	set theServices to {}
	
	-- Get the list of services from the server
	try
		tell application "http://www.xmethods.net/interfaces/query"
			set theServices to call soap {method name:"getAllServiceSummaries", method namespace uri:"http://www.xmethods.net/interfaces/query", parameters:{}, SOAPAction:""}
		end tell
	end try
	
	-- Return the list of services
	return theServices
end getServices


-- The "getServiceDetailWithID" handler will return a record that contains the details about the service with the specified ID.
--
on getServiceDetailWithID(theServiceID)
	-- Set the result to a known value
	set theDetail to missing value
	
	-- We need to convert the supplied service id as plain text (as it is given as unicode text). This is a workaround for a known bug in the "call soap" command, as it can not except unicode or styled text at this time.
	set theServiceID to getPlainText(theServiceID)
	
	-- Get the detailed info from the server.
	try
		tell application "http://www.xmethods.net/interfaces/query"
			set theDetail to call soap {method name:"getServiceDetail", method namespace uri:"http://www.xmethods.net/interfaces/query", parameters:{|id|:theServiceID}, SOAPAction:""}
		end tell
	end try
	
	-- Return the requested detail information
	return theDetail
end getServiceDetailWithID


(* ==== Utility Handlers ==== *)

-- This is a utility handler that will simply find the window with the specified title.
--
on findWindowWithTitle(theTitle)
	set theWindow to missing value
	
	set theWindows to every window whose title is theTitle
	if (count of theWindows) > 0 then
		set theWindow to item 1 of theWindows
	end if
	
	return theWindow
end findWindowWithTitle

-- This is a workaround that will convert the given unicode text into plain text (not styled text)
--
on getPlainText(fromUnicodeString)
	set styledText to fromUnicodeString as string
	set styledRecord to styledText as record
	return «class ktxt» of styledRecord
end getPlainText

(* © Copyright 2004 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- main.applescript
-- Get Process Information

on run {input, parameters}
	
	if input is in {{}, {""}, ""} or |ignoresInput| of parameters is true then -- ignoresInput is the value of the type setting in the action's title bar
		-- if input is empty or being ignored then get process from popup button selection
		set processNameVal to (|processName| of parameters) as Unicode text
	else
		-- if input is not empty then use input as process name
		if class of input is list then
			set processNameVal to item 1 of input
			if processNameVal is in {{}, ""} then
				set processNameVal to (|processName| of parameters) as Unicode text
			end if
		else
			set processNameVal to input
		end if
	end if
	
	set ReturnAppleScriptRecordVal to (|ReturnAppleScriptRecord| of parameters)
	
	if ReturnAppleScriptRecordVal = 1 then
		(*
		Since this is a compiled script, we use the 'run script' command to load in System Events' AppleScript terminology. 
		Otherwise the resulting AppleScript record will appear in chevron syntax (four byte character codes) in the View Results action.
		*)
		set theScript to "tell application \"System Events\" to properties of process \"" & processNameVal & "\""
		set processInfo to run script theScript
	else
		tell application "System Events"
			set processInfo to properties of process processNameVal
		end tell
		set counter to count of processInfo
		-- Get localized strings for properties labels
		set accepts_high_level_events to localized_string("accepts high level events")
		set accepts_remote_events to localized_string("accepts remote events")
		set background_only to localized_string("background only")
		set ClassicVal to localized_string("Classic")
		set creator_type to localized_string("creator type")
		set displayed_name to localized_string("displayed name")
		set fileVal to localized_string("file")
		set file_type to localized_string("file type")
		set frontmostVal to localized_string("frontmost")
		set has_scripting_terminology to localized_string("has scripting terminology")
		set idVal to localized_string("id")
		set nameVal to localized_string("name")
		set partition_space_used to localized_string("partition space used")
		set total_partition_size to localized_string("total partition size")
		set unix_id to localized_string("unix id")
		set visibleVal to localized_string("visible")
		-- Create text report
		tell application "System Events"
			set theTextData to accepts_high_level_events & ":" & tab & accepts high level events of processInfo & return & ¬
				accepts_remote_events & ":" & tab & accepts remote events of processInfo & return & ¬
				background_only & ":" & tab & background only of processInfo & return & ¬
				ClassicVal & ":" & tab & Classic of processInfo & return & ¬
				creator_type & ":" & tab & creator type of processInfo & return & ¬
				displayed_name & ":" & tab & displayed name of processInfo & return & ¬
				fileVal & ":" & tab & file of processInfo & return & ¬
				file_type & ":" & tab & file type of processInfo & return & ¬
				frontmostVal & ":" & tab & frontmost of processInfo & return & ¬
				has_scripting_terminology & ":" & tab & has scripting terminology of processInfo & return & ¬
				idVal & ":" & tab & id of processInfo & return & ¬
				nameVal & ":" & tab & name of processInfo & return & ¬
				partition_space_used & ":" & tab & partition space used of processInfo & return & ¬
				total_partition_size & ":" & tab & total partition size of processInfo & return & ¬
				unix_id & ":" & tab & unix id of processInfo & return & ¬
				visibleVal & ":" & tab & visible of processInfo & return
		end tell
		set processInfo to theTextData
	end if
	return processInfo
end run

on localized_string(key_string)
	return localized string key_string in bundle with identifier "com.apple.AutomatorExamples.GetProcessInformation"
end localized_string

(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)

-- UI.applescript
-- Get Process Information

property actionview_reference : missing value
property contentview_reference : missing value
property action_parameters : missing value

on awake from nib theObject
	set contentview_reference to theObject
	set actionview_reference to the super view of contentview_reference
	set the action_parameters to (call method "parameters" of (call method "action" of the actionview_reference))
	getProcesses()
end awake from nib

on parameters updated theObject parameters theParameters
	set (the title of popup button "processesMenu" of contentview_reference) to |processName| of theParameters as Unicode text
	set (the state of button "backgroundProcessesButton" of contentview_reference) to |backgroundProcesses| of theParameters as integer
	set (the state of button "ReturnAppleScriptRecord" of contentview_reference) to |ReturnAppleScriptRecord| of theParameters as integer
	return theParameters
end parameters updated

on update parameters theObject parameters theParameters
	set |processName| of theParameters to (the title of popup button "processesMenu" of contentview_reference) as Unicode text
	set |backgroundProcesses| of theParameters to (the state of button "backgroundProcessesButton" of contentview_reference)
	set |ReturnAppleScriptRecord| of theParameters to (the state of button "ReturnAppleScriptRecord" of contentview_reference)
	return theParameters
end update parameters

on clicked theObject
	-- This handler is attached to the check box buttons
	if name of theObject is "backgroundProcessesButton" then
		getProcesses()
	else if name of theObject is "ReturnAppleScriptRecord" then
		-- There are problems targeting the Automator process when returning a record, so we don't present this process to user
		set CurrentProcessTitle to (title of popup button "processesMenu" of contentview_reference) --as Unicode text
		if CurrentProcessTitle contains "Automator" then
			getProcesses()
		end if
	end if
end clicked


on will pop up theObject
	-- This handler is attached to the popup button
	tell progress indicator "ProgressIndicator" of contentview_reference to start
	set CurrentProcessTitle to (title of theObject) --as Unicode text
	getProcesses()
	set (title of theObject) to CurrentProcessTitle
	tell progress indicator "ProgressIndicator" of contentview_reference to stop
end will pop up

on getProcesses()
	set |backgroundProcesses| of action_parameters to (the state of button "backgroundProcessesButton" of contentview_reference)
	set backgroundProcessVal to (|backgroundProcesses| of action_parameters)
	set ReturnAppleScriptRecordVar to (the state of button "ReturnAppleScriptRecord" of contentview_reference)
	
	delete every menu item of menu of popup button "processesMenu" of contentview_reference
	if backgroundProcessVal = 1 then
		tell application "System Events"
			set processList to name of every process
		end tell
	else
		tell application "System Events"
			set processList to name of every process whose background only is false
		end tell
	end if
	repeat with processTitle in processList
		-- There are problems targeting the Automator process when returning a record, so we don't present this process to user
		if ReturnAppleScriptRecordVar = 1 then
			if processTitle does not contain "Automator" then
				make new menu item at the end of menu items of menu of popup button "processesMenu" of contentview_reference with properties {title:processTitle, enabled:true}
			end if
		else
			make new menu item at the end of menu items of menu of popup button "processesMenu" of contentview_reference with properties {title:processTitle, enabled:true}
		end if
	end repeat
end getProcesses

(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- main.applescript
-- Quit Application

on run {input, parameters}
	set the app_path to |appPath| of parameters
	
	set the target_app to app_path as POSIX file as alias
	set the target_app to the target_app as Unicode text
	
	set saving to (saving of parameters)
	if saving is 0 then
		tell application target_app to quit saving yes
	else if saving is 1 then
		tell application target_app to quit saving no
	else
		tell application target_app to quit saving ask
	end if
	return input
end run

(* ¬© Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (‚ÄúApple‚Äù) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple‚Äôs copyrights in this original Apple software (the ‚ÄúApple Software‚Äù), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- main.applescript
-- Randomizer

on run {input_items, parameters}
	set the output_items to {}
	if input_items is not {} then
		if the class of the input_items is list then
			set the number_method to (|numberMethod| of parameters) as integer
			set the number_to_choose to (|numberToChoose| of parameters) as integer
			if number_method is 1 then
				set the number_to_choose to my convert_percentage_to_number(number_to_choose, count of the input_items)
			end if
			repeat with i from 1 to the number_to_choose
				set the end of the output_items to some item of the input_items
			end repeat
		else
			set the output_items to the input_items
		end if
	end if
	return output_items
end run

on convert_percentage_to_number(this_percentage, this_total)
	return (this_percentage * this_total) div 100
end convert_percentage_to_number

on localized_string(key_string)
	return localized string key_string in bundle with identifier "com.apple.AutomatorExamples.Randomizer"
end localized_string

(* © Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. (“Apple”) in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this Apple software constitutes acceptance of these terms.  If you do not agree with these terms, please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in this original Apple software (the “Apple Software”), to use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the Apple Software.  Neither the name, trademarks, service marks or logos of Apple Computer, Inc. may be used to endorse or promote products derived from the Apple Software without specific prior written permission from Apple.  Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. *)
-- «FILENAME»
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.

--	CodeWarrior Script Handlers
--	pbxprojectimporters
-- 	Created by Scott Tooker on Mon Mar 17 2003.
--  	Copyright ? 2003 Apple Computer. All rights reserved.

--	This file contains subroutines that are called by PBXCWProjectImporter to assist in the import of a CodeWarrior project.

-- exportCodeWarriorProjectAtPath subroutine
-- this subroutine opens the project pointed to by posixProjectPath, sets all the targets to use relative paths and then exports the project to an XML file and returns the posix path to the XML export file.
on exportCodeWarriorProjectAtPath(posixProjectPath)
	set projectAlias to (POSIX file posixProjectPath) as alias
	tell application "CodeWarrior IDE"
		set projectToExport to a reference to document (openProject(projectAlias) of me)
		-- log projectToExport
		set theProjectWindow to window of projectToExport
		select theProjectWindow
		set projectFileLocation to (location of projectToExport) as alias
		set originalTarget to current target of projectToExport
		set originalTargetName to name of originalTarget
		set listOfTargets to name of every target in projectToExport
		
		repeat with eachTargetName in listOfTargets
			Set Current Target eachTargetName
			set settings to (Get Preferences from panel "Target Settings")
			set Use Relative Paths of settings to true
			Set Preferences of panel "Target Settings" to settings
		end repeat
		
		Set Current Target originalTargetName
		
		tell application "Finder"
			set projectFolder to (the container of projectFileLocation) as alias
		end tell
		
		set xmlFileName to (name of projectToExport) & ".xml"
		set tempXMLFilePath to ((projectFolder as Unicode text) & "tempProjectAsXML.xml")
		
		set xmlFileReference to a reference to file tempXMLFilePath
		
		export projectToExport to xmlFileReference
	end tell
	
	tell application "Finder"
		set aliasToXMLFile to tempXMLFilePath as alias
		set name of aliasToXMLFile to xmlFileName
	end tell
	
	return POSIX path of aliasToXMLFile
end exportCodeWarriorProjectAtPath

-- closeCodeWarriorProjectAtPath subroutine
-- this subroutine closes the project pointed to by posixProjectPath if it is open
on closeCodeWarriorProjectAtPath(posixProjectPath)
	set projectAlias to (POSIX file posixProjectPath) as alias
	
	tell application "CodeWarrior IDE"
		set projectToClose to a reference to document (openProject(projectAlias) of me)
		set theProjectWindow to window of projectToClose
		close theProjectWindow saving yes
	end tell
end closeCodeWarriorProjectAtPath

-- generateInfoPlist subroutine
-- this subroutine generates the Info.plist from the given .plc file using the given target in the current project and returns the posix path to the Info.plist
on generateInfoPlist(posixProjectPath, targetName, posixPlcFilePath)
	set projectAlias to (POSIX file posixProjectPath) as alias
	set plcFileAlias to (POSIX file posixPlcFilePath) as alias
	
	tell application "CodeWarrior IDE"
		set projectOfInterest to a reference to document (openProject(projectAlias) of me)
		set theProjectWindow to window of projectOfInterest
		select theProjectWindow
		
		set originalTarget to current target of projectOfInterest
		set originalTargetName to name of originalTarget
		
		Set Current Target targetName
		compile {plcFileAlias}
		
		set infoPlistPath to findInfoPlistForTargetInProject(targetName, projectAlias) of me
		
		Set Current Target originalTargetName
		return infoPlistPath
	end tell
end generateInfoPlist

-- findInfoPlistForTarget subroutine
-- this subroutine finds the Info.plist for the given target in the current project and returns the posix path
on findInfoPlistForTargetInProject(cwTargetName, projectAlias)
	
	tell application "CodeWarrior IDE"
		Set Current Target cwTargetName
		-- determine which linker is being used for this target to get the project type
		set targetSettings to (Get Preferences from panel "Target Settings")
		set linkerName to Linker of targetSettings
		set projectType to missing value
		set productName to missing value
		
		if (linkerName is "MacOS PPC Linker") then
			set targetSettings to (Get Preferences from panel "PPC Project")
		else if (linkerName is "MacOS X PPC Linker") then
			set targetSettings to (Get Preferences from panel "PPC Mac OS X Project")
		else if (linkerName is "Mach-O PPC Linker") then
			set targetSettings to (Get Preferences from panel "PPC Mach-O Target")
		end if
		
		set projectType to Project Type of targetSettings
		set productName to File Name of targetSettings
		
		set projectTypesThatIgnorePlistOutputPath to {application package, shared library package, framework, kernel extension package}
		
		set targetSettings to (Get Preferences from panel "Property List")
		set plistOutputPath to Output Directory of targetSettings
		
		if projectType is in projectTypesThatIgnorePlistOutputPath then
			set targetSettings to (Get Preferences from panel "Target Settings")
			set outputRelativePath to Output Directory Location of targetSettings
			set pathName to name of outputRelativePath
			set newPathName to pathName
			
			if format of outputRelativePath is MacOS Path then
				set newPathName to (pathName & ":" & productName & ":Contents:Info.plist")
			else if format of outputRelativePath is Unix Path then
				set newPathName to (pathName & "/" & productName & "/Contents/Info.plist")
			end if
			set (name of outputRelativePath) to newPathName
			set plistOutputPath to outputRelativePath
		end if
		
		set absolutePath to absolutePathForAccessPathInTargetNamedFromProject(plistOutputPath, cwTargetName, projectAlias) of me
		
		return absolutePath
	end tell
end findInfoPlistForTargetInProject

-- absolutePathForAccessPathInTargetNamedFromProject subroutine
-- this subroutine returns an absolute posix path for the given access path
on absolutePathForAccessPathInTargetNamedFromProject(accessPath, cwTargetName, projectAlias)
	set projectPathRoot to projectAlias
	tell application "Finder"
		set compilerFolderAlias to container of (application file id "CWIE") as alias
		set compilerPathRoot to POSIX path of (compilerFolderAlias)
		set projectFolderAlias to container of (file projectAlias) as alias
		set projectPathRoot to POSIX path of projectFolderAlias
	end tell
	
	
	tell application "CodeWarrior IDE"
		set relativePath to name of accessPath
		set pathFormat to format of accessPath
		set pathRootType to origin of accessPath
		set pathRootName to missing value
		if pathRootType is root relative then
			set pathRootName to root of accessPath
		end if
		set absolutePath to missing value
		
		if pathRootType is absolute then
			set absolutePath to relativePath
		else if pathRootType is project relative then
			if pathFormat is MacOS Path then
				set macOSProjectPathRoot to projectFolderAlias as Unicode text
				set absolutePath to (macOSProjectPathRoot & relativePath)
			else if pathFormat is Unix Path then
				set absolutePath to (projectPathRoot & relativePath)
			end if
		else if pathRootType is shell relative then
			if pathFormat is MacOS Path then
				set macOSCompilerPathRoot to compilerFolderAlias as Unicode text
				set absolutePath to (macOSCompilerPathRoot & relativePath)
			else if pathFormat is Unix Path then
				set absolutePath to (compilerPathRoot & relativePath)
			end if
		else if pathRootType is root relative then
			set sourceTreeRoot to pathForSourceTreeNameUsingTargetNamedInProjectAtPath(pathRootName, cwTargetName, projectAlias) of me
			if pathFormat is MacOS Path then
				set macOSSourceTreePathRoot to (POSIX file sourceTreeRoot) as Unicode text
				set absolutePath to (macOSSourceTreePathRoot & relativePath)
			else if pathFormat is Unix Path then
				set absolutePath to (sourceTreeRoot & relativePath)
			end if
		end if
		
		if pathFormat is MacOS Path then
			return POSIX path of (absolutePath as alias)
		else
			return absolutePath
		end if
	end tell
end absolutePathForAccessPathInTargetNamedFromProject

-- pathForSourceTreeNameUsingTargetNamedInProjectAtPath subroutine
-- this subroutine returns the posix path for a given Source Tree name
-- target source trees are searched first, followed by global source trees
on pathForSourceTreeNameUsingTargetNamedInProjectAtPath(pathRootName, cwTargetName, projectAlias)
	
	tell application "CodeWarrior IDE"
		set cwProject to a reference to document (openProjectAtPath(projectAlias) of me)
		set originalTarget to current target of cwProject
		set originalTargetName to name of originalTarget
		
		Set Current Target cwTargetName
		set targetSourceTrees to Source Trees of (Get Preferences from panel "Target Source Trees")
		Set Current Target originalTargetName
		
		set sourceTreePath to missing value
		repeat with eachSourceTree in targetSourceTrees
			if name of eachSourceTree is pathRootName then
				if format of eachSourceTree is MacOS Path then
					set sourceTreePath to POSIX path of file (path of eachSourceTree)
				else
					set sourceTreePath to (path of eachSourceTree)
				end if
			end if
		end repeat
		
		if sourceTreePath is missing value then
			set globalSourceTrees to Source Trees of Global Source Trees
			
			repeat with eachSourceTree in globalSourceTrees
				if name of eachSourceTree is pathRootName then
					if format of eachSourceTree is MacOS Path then
						set sourceTreePath to POSIX path of file (path of eachSourceTree)
					else
						set sourceTreePath to (path of eachSourceTree)
					end if
				end if
			end repeat
		end if
		
		return sourceTreePath
	end tell
end pathForSourceTreeNameUsingTargetNamedInProjectAtPath

-- fixUpBrokenCodeWarriorPath subroutine
-- this is needed to get around a bug in the path value that CodeWarrior returns for a target file
on fixUpBrokenCodeWarriorPath(brokenPath)
	set slashOffset to offset of "/" in brokenPath
	set lengthOfPath to count of brokenPath
	set firstPiece to characters 1 thru (slashOffset - 1) of brokenPath
	set lastPiece to characters (slashOffset + 1) thru lengthOfPath of brokenPath
	set fixedPath to firstPiece & ":" & lastPiece as Unicode text
	
	return fixedPath
end fixUpBrokenCodeWarriorPath

-- openProject subroutine
-- this returns the name of the CodeWarrior project that is at the given path
on openProject(projectAlias)
	tell application "CodeWarrior IDE"
		-- log (open projectAlias converting yes)
		open projectAlias converting yes
		
		set desiredProjectName to missing value
		set documentList to every document
		-- log documentList
		repeat with eachDocument in documentList
			if kind of eachDocument is project then
				if ((location of eachDocument) as alias) is projectAlias then
					set desiredProjectName to name of eachDocument
					exit repeat
				end if
			end if
		end repeat
		-- log desiredProjectName
		return desiredProjectName
	end tell
end openProject

-- getGlobalSourceTrees subroutine
-- this returns the set of defined app-level source trees
on getGlobalSourceTrees()
	tell application "CodeWarrior IDE"
		get Source Trees of (Get Preferences from panel "Global Source Trees")
	end tell
end getGlobalSourceTrees

-- launchCodeWarrior subroutine
-- this launches CodeWarrior
on launchCodeWarrior()
	launch application "CodeWarrior IDE"
end launchCodeWarrior

-- quitCodeWarrior subroutine
-- this quits CodeWarrior
on quitCodeWarrior()
	quit application "CodeWarrior IDE"
end quitCodeWarrior

-- 	Created by Scott Tooker on Mon Apr 21 2003.
--  	Copyright © 2003 Apple Computer. All rights reserved.

--	This file contains subroutines that are called by PBXCWProjectImporter to assist in the import of a CodeWarrior project.

-- isCodeWarriorOpen subroutine
-- this returns if CodeWarrior is already open
on isCodeWarriorOpen()
	
	set codeWarriorOpen to false
	
	tell application "System Events"
		set codeWarriorProcesses to processes whose name contains "CodeWarrior"
	end tell
	
	if codeWarriorProcesses is not {} then
		set codeWarriorOpen to true
	end if
	
	return codeWarriorOpen
	
end isCodeWarriorOpen
-- main.applescript
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.

on run {input, parameters}
	
	return input
end run
-- «PROJECTNAME».applescript
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
-- «PROJECTNAME».applescript
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.

-- Document.applescript
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.

on data representation theObject of type ofType
	(*Return the data that is to be stored in your document here.*)
end data representation

on load data representation theObject of type ofType with data withData
	(* The withData contains the data that was stored in your document that you provided in the "data representation" event handler. Return "true" if this was successful, or false if not.*)
	return true
end load data representation
-- «PROJECTNAME».applescript
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.

on idle
	(* Add any idle time processing here. *)
end idle

on open names
	(* Add your script to process the names here. *)
	
	-- Remove the following line if you want the application to stay open.
	quit
end open

-- «PROJECTNAME».applescript
-- «PROJECTNAME»

--  Created by «FULLUSERNAME» on «DATE».
--  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.

on plugin loaded theBundle
	(* Add your script here. *)
end plugin loaded
-- Refresh Finder.applescript
-- SCPlugin

--  Created by Jonathan Paisley on 03/12/2006.
--  Copyright 2006 Jonathan Paisley. All rights reserved.

tell application "Finder"
	update every item of every window
end tell
tell application "System Preferences"
	activate
	set current pane to pane "com.apple.preferences.users"
end tell

tell application "System Events"
	if UI elements enabled then
		tell tab group 1 of window "Accounts" of process "System Preferences"
			click radio button 1
			delay 2
			get value of text field 1
		end tell
	else
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "UI element scripting is not enabled. Check \"Enable access for assistive devices\""
		end tell
	end if
end tell
tell application "TextEdit"
	activate
end tell

tell application "System Events"
	if UI elements enabled then
		tell process "TextEdit"
			set frontmost to true
		end tell
		
		key down option
		keystroke "e"
		delay 1
		key up option
		keystroke "e"
		keystroke return
		
		keystroke "e" using option down
		delay 1
		keystroke "e"
		keystroke return
		
		key down shift
		keystroke "p"
		key up shift
		keystroke return
		
		key down option
		keystroke "p"
		key up option
		keystroke return
		
		key down {shift, option}
		keystroke "p"
		key up {shift, option}
		keystroke return
		
		keystroke "p" using {shift down, option down}
		keystroke return
		
	else
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "UI element scripting is not enabled. Check \"Enable access for assistive devices\""
		end tell
	end if
end tell
tell application "System Events"
	get properties
	get every process
	if UI elements enabled then
		tell process "Finder"
			get every menu bar
			tell menu bar 1
				get every menu bar item
				get every menu of every menu bar item
				get every menu item of every menu of every menu bar item
				get every menu of every menu item of every menu of every menu bar item
				get every menu item of every menu of every menu item of every menu of every menu bar item
			end tell
		end tell
	else
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "UI element scripting is not enabled. Check \"Enable access for assistive devices\""
		end tell
	end if
end tell
tell application "Finder"
	activate
end tell

tell application "System Events"
	get properties
	if UI elements enabled then
		tell process "Finder"
			
			get every UI element
			
			tell window 1
				
				get every button
				get properties of every button
				get every UI element of every button
				
				get every static text
				get properties of every static text
				get every UI element of every static text
				
				get every scroll bar
				get properties of every scroll bar
				get every UI element of every scroll bar
				
				get every UI element ¬
					whose class is not button and class is not static text ¬
					and class is not scroll bar
				get properties of every UI element ¬
					whose class is not button and class is not static text ¬
					and class is not scroll bar
				
			end tell
			
		end tell
	else
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "UI element scripting is not enabled. Check \"Enable access for assistive devices\""
		end tell
	end if
end tell
tell application "Finder"
	activate
end tell

tell application "System Events"
	if UI elements enabled then
							click menu item "Automatic" of  menu "Location" of  menu item "Location" of  menu "Apple" of  menu bar 1 of  process "Finder"
	else
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "UI element scripting is not enabled. Check \"Enable access for assistive devices\""
		end tell
	end if
end tell
tell application "System Preferences"
	activate
	set current pane to pane "com.apple.preference.sound"
end tell

tell application "System Events"
	if UI elements enabled then
			tell slider 1 of group 1 of window 1 of process "System Preferences"
				if value is 0.5 then
					set value to 0.8
				else
					set value to 0.5
				end if
			end tell
	else
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "UI element scripting is not enabled. Check \"Enable access for assistive devices\""
		end tell
	end if
end tell
(**
  *	filename: MailFile.applescript
 *	created : Tue Feb 11 14:24:40 2003
 *	LastEditDate Was "Fri Oct 22 10:17:12 2004"
 *
 *)

on sendfileviaemail(emailer, filenames)
	(* Part that does all of the work, this works for Mail *)
	if (emailer is equal to "com.apple.mail") then
		tell application "Mail"
			-- Properties can be specified in a record when creating the message or
			-- afterwards by setting individual property values.
			set newMessage to make new outgoing message
			tell newMessage
				set visible to true
				tell content
					-- Position must be specified for attachments
					repeat with filename in filenames
						make new attachment with properties {file name:filename} at after the last paragraph
					end repeat
				end tell
			end tell
		end tell
		activate
	else
		if (emailer is equal to "com.microsoft.entourage") then
			(* lots of stuff for entourage here *)
		end if
	end if
end sendfileviaemail

-- sendfileviaemail("com.apple.mail", "array of files/tmp/foo.vcf")
