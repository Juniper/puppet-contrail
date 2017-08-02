
define contrail::container::run (
  $cloud_orchestrator = hiera('contrail_cloud_orchestrator', 'openstack'),
  $container_name     = $title,
  $container_image    = undef,
) {

    $docker_net_opts = '--net=host'
    $docker_vol_opts = '--volume=/etc/contrailctl:/etc/contrailctl'
    $docker_env_opts = "--env='CLOUD_ORCHESTRATOR=${cloud_orchestrator}'"
    $docker_common_opts = '--restart=always --cap-add=AUDIT_WRITE --privileged'
    $docker_opts = "$docker_common_opts $docker_net_opts $docker_env_opts $docker_vol_opts"
    $check_cmd = "docker ps --all | grep -q '${container_name}'"
    exec { "create ${container_name} container" :
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "docker create --name='${container_name}' ${docker_opts} ${container_image}",
      unless  => $check_cmd,
    } ->
    exec { "start ${container_name} container" :
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "docker start $(docker ps --all | awk '/${container_name}/{print(\$1)}')",
      onlyif  => $check_cmd,
    }
}
