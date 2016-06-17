require 'formula'

class Apache22 < Formula
  homepage 'https://httpd.apache.org/'
  url 'https://www.apache.org/dist/httpd/httpd-2.2.31.tar.gz'
  sha256 '77afdd50ca2624f7d78832b1e92f34e4df293328ec59fd0e3f6cdedf67ac0c7f'

  skip_clean ['bin', 'sbin', 'logs']

  conflicts_with 'apache24',
    :because => "apache22 and apache24 install the same binaries."

  def install
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
      "--enable-proxy",
      "--enable-ssl",
      "--enable-layout=Homebrew",
    ]
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
          runtimedir:    #{var}/log/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
      EOS
  end
end
