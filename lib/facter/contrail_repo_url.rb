
Facter.add('contrail_repo_url') do
  setcode do
    repo_file = '/etc/yum.repos.d/contrail.repo'
    if File.exist? repo_file
      res = Facter::Core::Execution.exec("grep -A 5 -i 'contrail' #{repo_file} | grep 'baseurl' | head -n 1 | sed 's/\\(baseurl=\\)\\(.*\\/\\/\\)\\(.*\\)\\(\\/.*\\)/\\2\\3\\4/'")
      if res.empty?
        res = nil
      end
    else
      res = nil
    end
    res
  end
end
