require 'xmlrpc/client'
require 'fileutils'

Puppet::Type.type(:cobblerdistro).provide(:distro) do
  desc 'Support for managing the Cobbler distros'

  commands :wget    => '/usr/bin/wget',
           :mount   => '/bin/mount',
           :umount  => '/bin/umount',
           :cp      => '/bin/cp',
           :cobbler => '/usr/bin/cobbler'

  mk_resource_methods

  def self.instances
    keys = []
    # connect to cobbler server on localhost
    cobblerserver = XMLRPC::Client.new2('http://127.0.0.1/cobbler_api')
    # workaround for https://bugs.ruby-lang.org/issues/8182
    cobblerserver.http_header_extra = { "accept-encoding" => "identity" }
    # make the query (get all systems)
    xmlrpcresult = cobblerserver.call('get_distros')

    # get properties of current system to @property_hash
    xmlrpcresult.each do |member|
      keys << new(
        :name           => member['name'],
        :ensure         => :present,
        :arch           => member['arch'],
        :kernel         => member['kernel'],
        :initrd         => member['initrd'],
        :ks_meta        => member['ks_meta'],
        :comment        => member['comment'],
        :breed          => member['breed'],
        :os_version     => member['os_version'],
        :kopts          => member['kopts'],
        :kopts_post     => member['kopts_post']
      )
    end
    keys
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  # sets architecture
  def arch=(value)
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--arch=' + value.to_s)
    @property_hash[:arch]=(value.to_s)
  end

  # sets the path to kernel
  def kernel=(value)
    raise ArgumentError, 'correct kernel path must be specified!' unless File.exists?(value) 
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--kernel=' + value)
    @property_hash[:kernel]=(value)
  end

  # sets the path to initrd
  def initrd=(value)
    raise ArgumentError, 'correct initrd path must be specified!' unless File.exists?(value) 
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--initrd=' + value)
    @property_hash[:initrd]=(value)
  end

  # sets the kickstart metadata
  def ks_meta=(value)
    # name argument for cobbler
    namearg='--name=' + @resource[:name]

    # construct commandline from value hash
    cobblerargs='distro edit --name=' + @resource[:name]
    cobblerargs=cobblerargs.split(' ')
    # set up kernel options
    ksmeta_value = []
    # if value is ~, that means key is standalone option
    value.each do |key,val|
      if val=="~"
        ksmeta_value << "#{key}"
      else
        ksmeta_value << "#{key}=#{val}" unless val=="~"
      end
    end
    cobblerargs << ('--ksmeta=' + ksmeta_value * ' ')
    # finally run command to set value
    cobbler(cobblerargs)
    # update property_hash
    @property_hash[:ks_meta]=(value)
  end

  # Support cobbler's --breed
  def breed=(value)
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--breed=' + value)
    @property_hash[:breed]=(value)
  end
 
  # Support cobbler's --os-version
  def os_version=(value)
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--os-version=' + value)
    @property_hash[:os_version]=(value)
  end

  # Support cobbler's --kopts
  def kopts=(value)
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--kopts=' + value)
    @property_hash[:kopts]=(value)
  end

  # Support cobbler's --kopts-post
  def kopts_post=(value)
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--kopts-post=' + value)
    @property_hash[:kopts_post]=(value)
  end

  # comment
  def comment=(value)
    cobbler('distro', 'edit', '--name=' + @resource[:name], '--comment=' + value)
    @property_hash[:comment]=(value)
  end

  def create
    # check wether we are importing path via 'cobbler import'
    if @resource[:isolink] or @resource[:isopath]
      # This is block that does:
      #  'cobbler import'

      if @resource[:isolink]
        # get ISO image
        wget(@resource[:isolink],'--continue','--directory-prefix=/tmp').strip

        # get ISO name
        isoname = @resource[:isolink].sub(/^.*\/(.*).iso/, '\1')
      else
        isoname = @resource[:isopath].sub(/^.*\/(.*).iso/, '\1')
      end

      # create mount destination
      isodir = '/mnt/' + isoname
      if ! File.directory? isodir
        Dir.mkdir(isodir, 755)
      end

      mount( '-o', 'loop', '/distro/' + isoname + '.iso', isodir) unless mount( '-l', '-t', 'iso9660') =~ /#{isodir}/

      cobblerargs = 'import --name=' + @resource[:name] + ' --path=' + isodir
      cobbler(cobblerargs.split(' '))

      # clean garbage
      umount('-f', isodir)
      Dir.delete(isodir)

      # remove the profile generated by 'cobbler import'
      cobblerserver = XMLRPC::Client.new2('http://127.0.0.1/cobbler_api')
      cobblerserver.http_header_extra = { "accept-encoding" => "identity" }
      unless cobblerserver.call('find_profile', { 'name' => @resource[:name] }).empty?
        cobbler('profile', 'remove', '--name=' + @resource[:name]) 
      end
    else
      # This is block that does:
      #  'cobbler distro add'

      # create destination directory for distro
      distrodestdir = @resource[:destdir] + '/' + @resource[:name]
      if ! File.directory? distrodestdir
        Dir.mkdir(distrodestdir, 0755)
      end

      # get kernel and initrd
      kernel = @resource[:imagelink] + '/' + @resource[:kernel].sub(/^.*\/(.*)/, '\1')
      wget(kernel,'--continue','--directory-prefix='+distrodestdir).strip
      initrd = @resource[:imagelink] + '/' + @resource[:initrd].sub(/^.*\/(.*)/, '\1')
      wget(initrd,'--continue','--directory-prefix='+distrodestdir).strip

      # after downloading check for kernel and initrd
      raise ArgumentError, 'correct kernel path must be specified!' unless File.exists?(@resource[:kernel]) 
      raise ArgumentError, 'correct initrd path must be specified!' unless File.exists?(@resource[:initrd]) 

      # create profileargs variable
      cobblerargs = 'distro add --name=' + @resource[:name].to_s + ' --kernel=' + @resource[:kernel].to_s + ' --initrd=' + @resource[:initrd].to_s + ' --arch=' + @resource[:arch].to_s
      cobbler(cobblerargs.split(' '))
    end


    # add properties
    self.arch       = @resource.should(:arch)       unless @resource[:arch].nil?       or self.arch       == @resource.should(:arch)
    self.comment    = @resource.should(:comment)    unless @resource[:comment].nil?    or self.comment    == @resource.should(:comment)
    self.breed      = @resource.should(:breed)      unless @resource[:breed].nil?      or self.breed      == @resource.should(:breed)
    self.os_version = @resource.should(:os_version) unless @resource[:os_version].nil? or self.os_version == @resource.should(:os_version)
    self.kopts      = @resource.should(:kopts)      unless @resource[:kopts].nil?      or self.kopts      == @resource.should(:kopts)
    self.kopts_post = @resource.should(:kopts_post) unless @resource[:kopts_post].nil? or self.kopts_post == @resource.should(:kopts_post)
    self.ks_meta    = @resource.should(:ks_meta)    unless @resource[:ks_meta].nil?    or self.ks_meta    == @resource.should(:ks_meta)

    # final sync
    cobbler('sync')
    @property_hash[:ensure] = :present
  end

  def destroy
    # remove distrodestdir with sanity checks
    if @resource[:destdir]
      distrodestdir = @resource[:destdir] + '/' + @resource[:name]
      FileUtils.rm_rf distrodestdir unless distrodestdir =~ /^\/(bin|boot|dev|etc|lib|lib64|opt|sbin|sys|tmp|usr|var)?$/
    end
    cobbler('distro','remove','--name=' + @resource[:name])
    cobbler('sync')
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
