require 'formula'

class Apache22 < Formula
  homepage 'https://httpd.apache.org/'
  url 'http://apache.mirrors.pair.com/httpd/httpd-2.2.25.tar.gz'
  sha1 '1e793eb477c65dfa58cdf47f7bf78d8cdff58091'

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
end
