# escape=`

ARG WIN_VER="ltsc2022"

FROM mcr.microsoft.com/windows/servercore:$WIN_VER

ENV chocolateyUseWindowsCompression "true"
ENV RUST_TOOLCHAIN="1.57.0"

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
ADD https://win.rustup.rs/x86_64 C:\TEMP\rustup-init.exe
ADD https://chocolatey.org/install.ps1 C:\TEMP\choco-install.ps1

# Let's be explicit about the shell that we're going to use.
SHELL ["cmd", "/S", "/C"]

# Install Build Tools. A 3010 error signals that requested operation is
# successfull but changes will not be effective until the system is rebooted.
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --add Microsoft.VisualStudio.Workload.VCTools `
    --add Microsoft.VisualStudio.Workload.MSBuildTools `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.17763 `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

RUN powershell C:\TEMP\choco-install.ps1
RUN powershell C:\TEMP\rustup-init.exe -y --default-toolchain $env:RUST_TOOLCHAIN

RUN rustup component add rustfmt
RUN rustup component add clippy

RUN choco install git -y

RUN rmdir /s /q c:\TEMP
