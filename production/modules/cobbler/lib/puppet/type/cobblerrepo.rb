Puppet::Type.newtype(:cobblerrepo) do
@doc = "Manages the Cobbler repositories

A typical rule will look like this:

cobblerrepo {'PuppetLabs-5-x86_64-deps':
  ensure         => present,
  arch           => 'x86_64',
  priority       => 99,
  mirror         => 'http://yum.puppetlabs.com/el/5/dependencies/x86_64',
  mirror_locally => true,
  keep_updated   => false,
  comment        => 'some random comment',
}

This rule would add repository 'PuppetLabs-5-x86_64-deps' for architecture
x86_64 to cobbler, set it's priority to 99 and mirror it locally."

  desc 'The cobbler repo type'

  ensurable

  newparam(:name) do
    isnamevar
    desc 'The name of the repo, will be seen in cobbler repo list'
  end

  newproperty(:arch) do
    desc 'The architecture of repository (x86_64 or i386).'
    newvalues(:x86_64, :i386)
    defaultto :x86_64
  end

  newproperty(:priority) do
    desc 'Priority of the repository'
    validate do |value|
      raise ArgumentError, "%s only accepts values between 0 and 99." % value unless Integer(value) >= 0 or Integer(value) <= 99
    end
  end

  newproperty(:mirror) do
    desc 'The link of the repo'
    validate do |value|
      raise ArgumentError, "%s is not a valid link to online repository." % value unless value =~ /^http(s)?:/
    end
  end

  newproperty(:mirror_locally) do
    desc 'Keep local mirror or not.'
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:keep_updated) do
    desc 'Keep local mirrors updated.'
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:comment) do
    desc 'Human readable description of repository.'
  end

end
