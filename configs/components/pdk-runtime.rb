component 'pdk-runtime' do |pkg, settings, platform|
  runtime_details = JSON.parse(File.read('configs/components/pdk-runtime.json'))
  tarball_name = "pdk-runtime-#{pkg.get_version}.#{platform.name}.tar.gz"

  pkg.version runtime_details['version']
  pkg.url File.join(runtime_details['location'], tarball_name)
  pkg.sha1sum File.join(runtime_details['location'], "#{tarball_name}.sha1")

  pkg.install_only true

  install_commands = ["gunzip -c #{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz | tar -C / -xf -"]

  if platform.is_windows?
    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_commands = [
      "gunzip -c #{pkg.get_name}-#{pkg.get_version}.#{platform.name}.tar.gz | tar -C /cygdrive/c/ -xf -",
      "chmod 755 #{settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    ]

    settings[:additional_rubies].each do |rubyver, local_settings|
      install_commands << "chmod 755 #{local_settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    end
  end

  pkg.install do
    install_commands
  end
end
