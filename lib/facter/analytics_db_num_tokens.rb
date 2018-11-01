require 'facter'

Facter.add(:analytics_db_config_file) do
    setcode do
      Facter::Core::Execution.execute('find /etc/ -name "cassandra.yaml" | head -n 1')
    end
end

Facter.add(:analytics_db_num_tokens) do
  setcode do
    nt = Facter::Core::Execution.execute('find /etc/ -name "cassandra.yaml" -exec grep -v "#" {} + | grep num_tokens | sed "s/.*num_tokens.*:[ ]*//g" | head -n 1')
    if nt then
      nt = nt.strip().delete("'").delete('"')
      if nt != "" then
        nt = nt.to_i
      end
    end
    nt
  end
end

