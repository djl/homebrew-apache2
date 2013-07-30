require 'formula'

class Apache24 < Formula
  homepage 'https://httpd.apache.org/'
  url 'http://apache.mirrors.pair.com/httpd/httpd-2.4.6.tar.bz2'
  sha1 '16d8ec72535ded65d035122b0d944b0e64eaa2a2'
  version '2.4.6'

  skip_clean ['bin', 'sbin', 'logs']

  depends_on 'pcre'
  depends_on 'lua' => :optional

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

    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-mpm=prefork",
      "--with-included-apr",
      "--enable-mods-shared=all",
      "--with-pcre=#{Formula.factory('pcre').prefix}",
    ]
    args << "--enable-lua" if build.with? 'lua'

    system './configure', *args
    system "make"
    system "make install"

    # create logs directory
    Dir.mkdir "#{prefix}/logs" unless File.directory? "#{prefix}/logs"
  end
end
