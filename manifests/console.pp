# == Class: openshift_origin::console
#
# Manage the OpenShift Origin console.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::console
#
# === Copyright
#
# Copyright 2013 Mojo Lingo LLC.
# Copyright 2013 Red Hat, Inc.
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class openshift_origin::console {
  ensure_resource('package', 'rubygem-openshift-origin-console', {
      ensure  => present,
    }
  )

  ensure_resource('package', 'gcc', {
      ensure  => present,
    }
  )

  ensure_resource('package', 'make', {
      ensure  => present,
    }
  )

  ensure_resource('package', 'openshift-origin-console', {
      ensure  => present,
    }
  )

  case $::openshift_origin::broker_auth_plugin {
    'basic-auth'      : {

      file { 'Console htpasswd config':
      path    => '/var/www/openshift/console/httpd/conf.d/openshift-origin-auth-remote-user-basic.conf',
      content => template('openshift_origin/console/openshift-origin-auth-remote-user-basic.conf.erb'),
      owner   => 'apache',
      group   => 'apache',
      mode    => '0640',
      require => [
        Package['rubygem-openshift-origin-auth-remote-user'],
        File['openshift htpasswd'],
      ],
      notify  => Service["openshift-console"],
      }
    }
  }

  file { 'openshift console.conf':
    path    => '/etc/openshift/console.conf',
    content => template('openshift_origin/console/console.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-console'],
  }

  file { 'openshift console-dev.conf':
    path    => '/etc/openshift/console-dev.conf',
    content => template('openshift_origin/console/console.conf.erb'),
    owner   => 'apache',
    group   => 'apache',
    mode    => '0644',
    require => Package['openshift-origin-console'],
  }

  $console_asset_rake_cmd = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rake assets:precompile',
    default  => '/usr/bin/scl enable ruby193 "rake assets:precompile"',
  }

  $console_bundle_show    = $::operatingsystem ? {
    'Fedora' => '/usr/bin/bundle show',
    default  => '/usr/bin/scl enable ruby193 "bundle show"',
  }

  if $::operatingsystem == 'Fedora' {

    ensure_resource('package', 'rubygem-mocha', {
        ensure   => 'latest',
        alias    => 'mocha',
      }
    )

    ensure_resource('package', 'rubygem-minitest', {
        ensure   => 'latest',
        alias    => 'minitest',
      }
    )

    ensure_resource('package', 'rubygem-sass-rails', {
        ensure   => 'latest',
        alias    => 'sass-rails',
      }
    )

    ensure_resource('package', 'rubygem-jquery-rails', {
        ensure   => 'latest',
        alias    => 'jquery-rails',
      }
    )

    ensure_resource('package', 'rubygem-coffee-rails', {
        ensure   => 'latest',
        alias    => 'coffee-rails',
      }
    )

    ensure_resource('package', 'rubygem-compass-rails', {
        ensure   => 'latest',
        alias    => 'compass-rails',
      }
    )

    ensure_resource('package', 'rubygem-uglifier', {
        ensure   => 'latest',
        alias    => 'uglifier',
      }
    )

    ensure_resource('package', 'rubygem-therubyracer', {
        ensure   => 'latest',
        alias    => 'therubyracer',
      }
    )

    ensure_resource('package', 'rubygem-rdiscount', {
        ensure   => 'latest',
        alias    => 'rdiscount',
      }
    )

    ensure_resource('package', 'rubygem-formtastic', {
        ensure   => 'latest',
        alias    => 'formtastic',
      }
    )

    ensure_resource('package', 'rubygem-net-http-persistent', {
        ensure   => 'latest',
        alias    => 'net-http-persistent',
      }
    )

    ensure_resource('package', 'rubygem-haml', {
        ensure   => 'latest',
        alias    => 'haml',
      }
    )
  }

  if ($::operatingsystem == "RedHat" or $::operatingsystem == "CentOS") {

    ensure_resource('package', 'ruby193-rubygem-sass-rails', {
        ensure   => 'latest',
        alias    => 'sass-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-jquery-rails', {
        ensure   => 'latest',
        alias    => 'jquery-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-coffee-rails', {
        ensure   => 'latest',
        alias    => 'coffee-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-compass-rails', {
        ensure   => 'latest',
        alias    => 'compass-rails',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-uglifier', {
        ensure   => 'latest',
        alias    => 'uglifier',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-therubyracer', {
        ensure   => 'latest',
        alias    => 'therubyracer',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-rdiscount', {
        ensure   => 'latest',
        alias    => 'rdiscount',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-net-http-persistent', {
        ensure   => 'latest',
        alias    => 'net-http-persistent',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-haml', {
        ensure   => 'latest',
        alias    => 'haml',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-formtastic', {
        ensure   => 'latest',
        alias    => 'formtastic',
      }
    )

    ensure_resource('package', 'ruby193-rubygem-minitest', {
        ensure => 'latest',
        alias  => 'minitest',
      }
    )

  }

  # This File resource is to guarantee that the Gemfile.lock created
  # by the following Exec has the appropriate permissions (otherwise
  # it is created as owned by root:root)  
  file { '/var/www/openshift/console/Gemfile.lock':
    ensure    => 'present',
    owner     => 'apache',
    group     => 'apache',
    mode      => '0644',
    subscribe => Exec ['Console gem dependencies'],
    require   => Exec ['Console gem dependencies'],
  }

  exec { 'Console gem dependencies':
    cwd         => '/var/www/openshift/console/',
    command     => "${::openshift_origin::rm} -f Gemfile.lock && \
    ${console_bundle_show} && \
    ${::openshift_origin::chown} apache:apache Gemfile.lock && \
    ${::openshift_origin::rm} -rf tmp/cache/* && \
    ${console_asset_rake_cmd} && \
    ${::openshift_origin::chown} -R apache:apache /var/www/openshift/console",
    subscribe   => [
      Package['openshift-origin-console'],
      Package['rubygem-openshift-origin-console'],
      Package['sass-rails'],
      Package['jquery-rails'],
      Package['uglifier'],
      Package['coffee-rails'],
      Package['compass-rails'],
      Package['therubyracer'],
      Package['rdiscount'],
      Package['net-http-persistent'],
      Package['haml'],
      Package['formtastic'],
      Package['minitest'],
      Package['mocha'],
      File['openshift console.conf'],
    ],
    refreshonly => true,
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'openshift-console':
      require => Package['openshift-origin-console'],
      enable  => true,
    }
  } else {
    warning 'Please ensure that openshift-console service is enable on console machines'
  }

  file { 'openshift console production log':
    ensure  => 'present',
    path    => '/var/log/openshift/console/production.log',
    owner   => 'apache',
    group   => 'apache',
    mode    => '0666'
  }
}
