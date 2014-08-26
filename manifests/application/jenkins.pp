#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'rtyler/jenkins'
#   mod 'puppetlabs/java'
#   mod 'puppetlabs/apt'
#   mod 'darin/zypprepo'
#
class profile::application::jenkins (
  $install_jjb   = false,
  $jenkins_home  = '/var/lib/jenkins',
  $branch        = 'war-stable',
  $version       = 'latest',
  $catalina_base = '/usr/share/tomcat',
  $proxy         = false,
  $proxy_vhost   = {},
) {

  include profile::base
  include profile::webserver::tomcat

  $war_source = "http://mirrors.jenkins-ci.org/${branch}/${version}/jenkins.war"

  $config_file = $::osfamily ? {
    'Debian' => '/etc/default/tomcat',
    default  => '/etc/sysconfig/tomcat',
  }

  file { $jenkins_home :
    ensure  => directory,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0755',
    require => Group['tomcat'],
  }
    
  tomcat::setenv::entry { 'JENKINS_HOME' :
    value       => $jenkins_home,
    config_file => $config_file,
  }

  tomcat::war { 'jenkins.war' :
    war_source    => $war_source,
    catalina_base => $catalina_base,
  }

  if $install_jjb {
    include ::jenkins_job_builder
  }

  if $proxy {
    include ::apache
    create_resource('apache::vhost', $proxy_vhost)
  }

}
