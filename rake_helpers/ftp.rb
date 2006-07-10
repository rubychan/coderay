FTP_YAML = File.expand_path(File.join(File.dirname(__FILE__), '..', 'ftp.yaml'))
FTP_DOMAIN = 'cycnus.de'
FTP_CODERAY_DIR = 'public_html/raindark/coderay'

def prepare_ftp
  require 'net/ftp'
  require 'yaml'
  $username = File.exist?(FTP_YAML) ? YAML.load_file(FTP_YAML)[:username] : 'anonymous'
  g "ftp login, password for #$username needed: "
  $password = $stdin.gets.chomp
end

def cYcnus_ftp
  prepare_ftp unless $password
  Net::FTP.open(FTP_DOMAIN) do |ftp|
    g "login for #$username..."
    ftp.login $username, $password
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
