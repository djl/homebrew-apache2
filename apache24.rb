require 'fileutils'
require 'formula'

class Apache24 < Formula
  homepage 'https://httpd.apache.org/'
  url 'http://apache.mirrors.pair.com/httpd/httpd-2.4.6.tar.bz2'
  sha1 '16d8ec72535ded65d035122b0d944b0e64eaa2a2'

  skip_clean ['bin', 'sbin', 'logs']

  depends_on 'pcre'
  depends_on 'lua' => :optional

  conflicts_with 'apache22',
    :because => "apache24 and apache22 install the same binaries."

  # Apache 2.4 no longer bundles apr or apr-util so we have to fetch
  # it manually for each build
  def fetch_apr
    ["apr-1.4.8", "apr-util-1.5.2"].each do |tb|
      curl "-s", "-o", "#{tb}.tar.gz", "https://www.apache.org/dist/apr/#{tb}.tar.gz"
      system "tar -xzf #{tb}.tar.gz"
      dir = tb.rpartition('-')[0]
      FileUtils.mv(tb, "srclib/#{dir}")
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
      "--with-pcre=#{Formula.factory('pcre').prefix}",
      "--enable-layout=Homebrew"
    ]
    args << "--enable-lua" if build.with? 'lua'

    system './configure', *args
    system "make"
    system "make install"

    # create logs directory
    FileUtils.mkdir_p "#{var}/log/apache2"
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
          includedir:    ${prefix}/include
          localstatedir: #{var}/apache2
          runtimedir:    #{var}/log/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
      EOS
  end
end
