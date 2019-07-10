################################################################################
##  File:  Update-DockerImages.ps1
##  Team:  ReleaseManagement
##  Desc:  Pull some standard docker images.
##         Must be run after docker is installed.
################################################################################

function DockerPull {
    Param ([string]$image)

    Write-Host Installing $image ...
    docker pull $image

    if (!$?) {
      echo "Docker pull failed with a non-zero exit code"
      exit 1
    }
}

DockerPull mcr.microsoft.com/windows/servercore:1903
DockerPull mcr.microsoft.com/windows/nanoserver:1903
DockerPull mcr.microsoft.com/dotnet/core/aspnet:2.2.6-nanoserver-1903
DockerPull mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-1903
DockerPull mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-1903

# Adding description of the software to Markdown

$SoftwareName = "Docker images"

$Description = @"
The following container images have been cached:
"@

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description

Add-ContentToMarkdown -Content $(docker images --digests --format "* {{.Repository}}:{{.Tag}} (Digest: {{.Digest}})")