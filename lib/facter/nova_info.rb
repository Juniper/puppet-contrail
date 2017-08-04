require 'facter'
require 'puppet'

Facter.add(:nova_path) do
  setcode "python -c 'import nova; import os; path = os.path.dirname(nova.__file__); print(path)' 2>/dev/null"
end

Facter.add(:nova_version) do
  setcode do
    pkg = Puppet::Type.type(:package).new(:name => "python-nova")
    version = pkg.retrieve[pkg.property(:ensure)].to_s
    if version =~ /:/ then
      version = version.split(':')[1]
    end
    version
  end
end
