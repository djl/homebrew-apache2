require 'formula'

class Apache24 < Formula
  homepage 'https://httpd.apache.org/'
  url 'https://www.apache.org/dist/httpd/httpd-2.4.23.tar.gz'
  sha256 'b71a13f56b8061c6b4086fdcc9ffdddd904449735eadec0f0e2947e33eec91d7'

  skip_clean ['bin', 'sbin', 'logs']

  depends_on 'pcre'
  depends_on 'lua' => :optional
  depends_on 'openssl' if build.with? 'homebrew-openssl'

  option 'with-homebrew-openssl', 'Include OpenSSL support via Homebrew'

  conflicts_with 'apache22',
    :because => "apache24 and apache22 install the same binaries."

  # Apache 2.4 no longer bundles apr or apr-util so we have to fetch
  # it manually for each build
  def fetch_apr
    dir = "httpd-#{pkg_version}"
    tb = "#{dir}-deps.tar.gz"
    curl "-s", "-O", "https://www.apache.org/dist/httpd/#{tb}"
    system "tar -xzf #{tb}"
    ["apr", "apr-util"].each do |srcdir|
      FileUtils.mv("#{dir}/srclib/#{srcdir}", "srclib/")
    end
  end

  def install
    fetch_apr

    # install custom layout
    File.open('config.layout', 'w') { |f| f.write(apache_layout) };

    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-mpm=prefork",
      "--with-included-apr",
      "--enable-mods-shared=all",
      "--with-pcre=#{Formulary.factory('pcre').prefix}",
      "--enable-layout=Homebrew"
    ]
    if build.with? 'homebrew-openssl'
      args << "--with-ssl=" + Formula['openssl'].opt_prefix.to_s
    end
    args << "--enable-lua" if build.with? 'lua'

    system './configure', *args
    system "make"
    system "make install"

    (var+"log/apache2").mkpath
    (var+"run/apache2").mkpath
  end

  def apache_layout
    return <<-EOS.undent
      <Layout Homebrew>
          prefix:        #{prefix}
          exec_prefix:   ${prefix}
          bindir:        ${exec_prefix}/bin
          sbindir:       ${exec_prefix}/bin
          libdir:        ${exec_prefix}/lib
          libexecdir:    #{lib}/apache2/modules
          mandir:        #{man}
          sysconfdir:    #{etc}/apache2
          datadir:       ${prefix}
          installbuilddir: ${datadir}/build
          errordir:      #{var}/apache2/error
          iconsdir:      #{var}/apache2/icons
          htdocsdir:     #{var}/apache2/htdocs
          manualdir:     #{doc}/manual
          cgidir:        #{var}/apache2/cgi-bin
          includedir:    ${prefix}/include/apache2
          localstatedir: #{var}/apache2
          runtimedir:    #{var}/run/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
      EOS
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
