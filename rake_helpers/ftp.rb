def prepare_ftp
	require 'net/ftp'
	require 'yaml'
	$username = File.exist?(FTP_YAML) ? YAML.load_file(FTP_YAML)[:username] : 'anonymous'
end

FTP_YAML = 'ftp.yaml'
FTP_DOMAIN = 'cycnus.de'
FTP_CODERAY_DIR = 'public_html/raindark/coderay'

def cYcnus_ftp
	prepare_ftp
	Net::FTP.open(FTP_DOMAIN) do |ftp|
		g 'ftp login, password needed: '
		ftp.login $username, $stdin.gets
		gn 'logged in.'
		yield ftp
	end
end

def uploader_for ftp
	proc do |l, *r|
		r = r.first || l
		raise 'File %s not found!' % l unless File.exist? l
		if l == r
			g 'Uploading %s...' % [l]
		else
			g 'Uploading %s to %s...' % [l, r]
		end
		ftp.putbinaryfile l, r
		gd
	end
end

def g msg
	$stderr.print msg
end

def gn msg = ''
	$stderr.puts msg
end

def gd
	gn 'done.'
end
