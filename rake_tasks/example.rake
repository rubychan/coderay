namespace :example do

	desc 'Generate an example output'
	task :make do
		system 'ruby -wIlib ../hidden/highlight.rb -1 -L -I lib lib/coderay/**/'
	end

	desc 'Upload example to ' + FTP_DOMAIN
	task :upload => :make do
		gn 'Highlighting self...'
		gd
		gn 'Uploading example:'
		cYcnus_ftp do |ftp|
			ftp.chdir FTP_CODERAY_DIR
			uploader = proc do |l, r|
				g 'Uploading %s to %s...' % [l, r]
				ftp.putbinaryfile l, r
				gd
			end
			uploader.call 'highlighted/all_in_one.html', 'example.html'
		end
		gn 'Example uploaded.'
	end

end
