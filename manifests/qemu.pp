# == Class: contrail::qemu
#
# Update qemu settings
#
# === Parameters:
#
# [*qemu_user*]
#   (optional) username for qemu
#
# [*qemu_group*]
#   (optional) group for qemu
#
# [*qemu_clear_emulator_capabilities*]
#   (optional) clear_emulator_capabilities setting for qemu
#
# [*qemu_cgroup_device_acl*]
#   (optional) cgroup_device_acl setting for qemu
#
class contrail::qemu (
  $qemu_user = '"root"',
  $qemu_group = '"root"',
  $qemu_clear_emulator_capabilities = '0',
  $qemu_cgroup_device_acl_values = [ '/dev/null', '/dev/full', '/dev/zero',
    '/dev/random', '/dev/urandom', '/dev/ptmx', '/dev/kvm', '/dev/kqemu',
    '/dev/rtc', '/dev/hpet', '/dev/net/tun',],
) {
  augeas { 'qemu-conf-user_group':
    context => '/files/etc/libvirt/qemu.conf',
    changes => [
      "set user ${qemu_user}",
      "set group ${qemu_group}",
    ],
  }
  augeas { 'qemu-conf-clear_emulator_capabilities':
    context => '/files/etc/libvirt/qemu.conf',
    changes => [
      "set clear_emulator_capabilities ${qemu_clear_emulator_capabilities}",
    ],
  }

  $cgroup_changes = split(inline_template("rm cgroup_device_acl
<%- if @qemu_cgroup_device_acl_values and not @qemu_cgroup_device_acl_values.empty? -%>
  <%- @qemu_cgroup_device_acl_values.each_with_index do |val,idx| -%>
set cgroup_device_acl/<%= sprintf(\"%03d\", idx+1) -%> <%= val %>
  <%- end -%>
<%- end -%>"), '\n')


  augeas { 'qemu-conf-cgroup_device_acl':
    context => '/files/etc/libvirt/qemu.conf',
    changes => $cgroup_changes,
  }
}
