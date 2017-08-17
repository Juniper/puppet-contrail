
define contrail::container::install (
  $container_file  = undef,
  $container_image = undef,
  $container_name  = $title,
  $container_url   = undef,
) {

  include ::contrail::container::install_tools

  $local_file = $container_file ? {
    undef   => "/tmp/${container_name}.tar.gz",
    default => $container_file,
  }
  $check_docker_image_cmd="docker images | awk '{print(\$1\":\"\$2)}' | grep -q '${container_image}'"
  $repo_url = $::contrail_repo_url ? {
    undef   => undef,
    ''      => undef,
    default => $::contrail_repo_url,
  }
  if ($container_url and $container_url != '') or $repo_url {
    $url = $container_url ? {
      undef   => "${repo_url}/${container_name}.tar.gz",
      ''      => "${repo_url}/${container_name}.tar.gz",
      default => "${container_url}/${container_name}.tar.gz",
    }
    exec { "Dowload ${url}":
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "wget --tries 5 --waitretry=2 --retry-connrefused -O ${local_file} ${url}",
      onlyif  => "[ ! -f ${local_file} ]",
      unless  => $check_docker_image_cmd,
      require => Service['docker'],
      before  => Exec["pull ${container_name} container to docker"],
    }
  }
  exec { "pull ${container_name} container to docker" :
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "docker load -i ${local_file}",
    unless  => $check_docker_image_cmd,
    require => Service['docker'],
  }
}

