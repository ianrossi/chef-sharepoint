download_url = "http://care.dlservice.microsoft.com//dl/download/3/D/7/3D713F30-C316-49B8-9CC0-E1BFC34B63A0/SharePointServer_x64_en-us.img"
download_to = "C:/Users/#{ENV['USERNAME']}/Downloads/SharePointServer_x64_en-us.img"
node.override['sharepoint']['server_role'] = "SINGLESERVER"

remote_file download_to do
  source download_url
end

# Save the drive letter to a file
powershell "mount SPS image" do
  code <<-EOH
  (Mount-DiskImage -PassThru -ImagePath "#{download_to}" | Get-Volume).DriveLetter | Out-File "#{Chef::Config[:file_cache_path]}/sp_img_driveletter.txt"
  EOH
end

# create the config file
template "C:/Windows/Temp/sharepoint-config.xml" do
  source "config.xml.erb"
  rights :read, "Everyone"
end

# run the prereq installer. not sure, but this might need to restart things.
# if it does, then obviously it'll break the connection. silly windows.
windows_package "sharepoint preparation" do
  source "E:/prerequisiteinstaller.exe"
  installer_type :custom
  action :install
  options "/unattended"
end

# install sharepoint
windows_package "sharepoint" do
  source "E:/setup.exe"
  installer_type :custom
  action :install
  options "/config C:/Windows/Temp/sharepoint-config.xml"
end

# configuration stuff would go here

