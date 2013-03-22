require 'formula'

class Apache22 < Formula
  homepage 'https://httpd.apache.org/'
  url 'http://apache.mirror.anlx.net/httpd/httpd-2.2.24.tar.gz'
  sha1 'fc8a99946b1fab936a05c77abad050590a4deb82'
  version '2.2.24'

  skip_clean ['bin', 'sbin', 'logs']

  def install
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-mpm=prefork",
      "--with-included-apr",
      "--enable-mods-shared=all",
      "--enable-proxy",
      "--enable-ssl",
    ]
    system './configure', *args
    system "make"
    system "make install"

    # create logs directory
    Dir.mkdir "#{prefix}/logs" unless File.directory? "#{prefix}/logs"
  end

  plist_options :manual => "sudo apachectl start"

  def plist_startup
    true
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/bin/httpd</string>
        <string>-D</string>
        <string>FORGROUND</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>SHAuthorizationRight</key>
      <string>system.preferences</string>
    </dict>
    </plist>
    EOS
  end
end
