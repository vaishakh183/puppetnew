Puppet::Type.newtype(:cobblerdistro) do
@doc = "Manages the Cobbler distros.

A typical distro (added via 'cobbler distro add' will look like this:

  cobblerdistro { 'CentOS-6.3-x86_64':
    ensure    => present,
    arch      => 'x86_64',
    kernel    => '/distro/CentOS-6.3-x86_64/isolinux/vmlinuz',
    initrd    => '/distro/CentOS-6.3-x86_64/isolinux/initrd.img',
    imagelink => 'http://mi.mirror.garr.it/mirrors/CentOS/6.3/os/x86_64/isolinux',
    destdir   => '/distro',
  }

If, on the other hand, you want to use 'import', distro would look like:

  cobblerdistro { 'CentOS-6.3-x86_64':
    ensure  => present,
    arch    => 'x86_64',
    isolink => 'http://mi.mirror.garr.it/mirrors/CentOS/6.3/isos/x86_64/CentOS-6.3-x86_64-bin-DVD1.iso',
    OR
    isopath => '/root/CentOS-6.3-x86_64-bin-DVD1.iso',
    ks_meta => { tree => 'http://example.com/CentOS/6.3/x86_64/os/' },
  }

This rule would ensure that the kernel swappiness setting be set to '20'"
 
  desc 'The cobbler distro type'

  ensurable

  newparam(:name) do
    isnamevar
    desc 'The name of the distro, that will create subdir in $distro'
    validate do |value|
      if value
        raise ArgumentError, "%s is not a valid cobblerdistro name. It doesn't end with arch (x86_64|i386)." % value unless value =~ /(x86_64|i386)$/
      end
    end
  end

  newparam(:isolink) do
    desc 'The link of the distro ISO image.'
    validate do |value|
      if value
        raise ArgumentError, "%s is not a valid link to ISO image." % value unless value =~ /^https?:\/\/.*iso/
      end
    end
  end

  newparam(:isopath) do
    desc 'Local path to ISO file'
    validate do |value|
      if value
        raise ArgumentError, "%s is not a valid ISO file." % value unless File.exists? value
      end
    end
  end

  newparam(:imagelink) do
    desc 'The link to the kernel and initrd files.'
    validate do |value|
      if value
        raise ArgumentError, "%s is not a valid http link." % value unless value =~ /^https?:\/\/.*/
      end
    end
  end

  newparam(:destdir) do
    desc 'The path to the distro dir.'
  end
  autorequire(:file) do
    self[:destdir]
  end

  newproperty(:arch) do
    desc 'The architecture of distro (x86_64 or i386).'
    newvalues(:x86_64, :i386)
    defaultto :x86_64
  end

  newproperty(:kernel) do
    desc 'Kernel (Absolute path to kernel on filesystem)'
  end

  newproperty(:initrd) do
    desc 'Initrd (Absolute path to initrd on filesystem)'
  end

  newproperty(:ks_meta) do
    desc 'Kickstart metadata'
    defaultto Hash.new

    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # if members of hashes are not the same, something
      # was added or removed from manifest, so return false
      return false unless is.class == Hash and should.class == Hash and is.keys.sort == should.keys.sort
      # check if values of hash keys are equal
      is.each do |l,w|
        return false unless w == should[l]
      end
      true
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:comment) do
    desc 'Human readable description of distribution.'
  end

  newproperty(:breed) do
    desc 'Type of distribution.'
  end

  newproperty(:os_version) do
    desc 'OS Version for virtualization optimizations.'
  end

  newproperty(:kopts) do
    desc 'Install time kernel options.'
  end

  newproperty(:kopts_post) do
    desc 'Post install kernel options.'
  end

end
