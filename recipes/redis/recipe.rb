# Adapted from the formula in brew2deb.

class Redis < FPM::Cookery::Recipe
  description 'An advanced key-value store'

  v = '2.8.13'
  name     'zalando-redis-server'
  version  "2:#{v}"
  revision 2
  homepage 'http://redis.io/'
  source   'https://github.com/antirez/redis', :with => :git, :tag => v

  section      'database'
  conflicts    'redis-server', 'redis-tools'
  config_files '/etc/redis/redis.conf'

  post_install   'postinst'

  def build
    make

    # Fix up default conf file to match our paths
    inline_replace "redis.conf" do |s|
      s.gsub! 'daemonize no', 'daemonize yes'
      s.gsub! 'logfile stdout', 'logfile /var/log/redis/redis-server.log'
      s.gsub! 'dir ./', 'dir /var/lib/redis/'
    end
  end

  def install
    %w(run lib/redis log/redis).each { |p| var(p).mkpath }

    bin.install Dir["src/redis-*"].select{ |f| f =~ /redis-[^\.]+$/ }

    etc('redis').install %w(redis.conf sentinel.conf)
    etc('init.d').install_p(workdir('redis-server.init.d'), 'zalando-redis-server')
  end
end
