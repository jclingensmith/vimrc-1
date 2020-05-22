param(
    # Where my source lives
    [string] $sourceCodePath = ''
)

if ($sourceCodePath -eq '') {
  Write-Line 'Execute script passing in source code path'
}

$vimRcRepoPath = "$Env:USERPROFILE\vimfiles\symlink-repos\vimrc"
$vimfiles = "$Env:USERPROFILE\vimfiles"
$vimInstallPath = 'C:\Program Files (x86)\vim\vim80'

# Prepare ~\vimfiles directory
ri $vimfiles -Recurse -Force -ErrorAction SilentlyContinue
md "$vimfiles\symlink-repos"
cd "$vimfiles\symlink-repos"

# Remove the junction path or else git clone doesn't work
ri "$sourceCodePath\vimrc" -Recurse -Force -ErrorAction SilentlyContinue

# Clone this repo on the same drive as ~\vimfiles because symlinks only work on the same drive
git clone https://github.com/vincpa/vimrc

# Create a junction to the place where all my other source code lives
junction "$sourceCodePath\vimrc" .\vimrc\

# Get my vimrc from GitHub and symlink it to where Vim looks for it
cd ~\
Remove-Item _vimrc -ErrorAction SilentlyContinue
Remove-Item _gvimrc -ErrorAction SilentlyContinue
cmd /c mklink /H _vimrc "$vimRcRepoPath\windows\_vimrc"
cmd /c mklink /H _gvimrc "$vimRcRepoPath\_gvimrc"


Write-Host 'Installing and configuring Vim...' -ForegroundColor Green
if ((Test-Path $vimInstallPath)) {
    Write-Host 'Vim already installed. Skipped.' -ForegroundColor Magenta
} else {
    choco install vim --limit-output --force -y
}

md "$vimfiles\autoload"
(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',  "$vimfiles\autoload\plug.vim")
c:
cd 'C:\Program Files (x86)\vim\vim80'
.\gvim.exe +PlugInstall +qa

Write-Host "Installing fonts for vim and powerline..." -NoNewLine
$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
$objFolder.CopyHere("$vimRcRepoPath\resources\PragmataPro.ttf")
$objFolder.CopyHere("$vimRcRepoPath\resources\Inconsolata for Powerline.otf")
$objFolder.CopyHere("$vimRcRepoPath\resources\PragmataPro for Powerline.ttf")
Write-Host "done."

Write-Host 'Installing powerline for vim...' -ForegroundColor Green
c:
cd \python27\scripts
pip install powerline-status

$uri = 'https://raw.githubusercontent.com/powerline/powerline/master/powerline/bindings/vim/plugin/powerline.vim'
(New-Object Net.WebClient).DownloadFile($uri, 'C:\Program Files (x86)\vim\vim80\plugin\powerline.vim')

# npm packages for vim syntastic javascript checker
npm install -g eslint
npm install -g eslint-plugin-react
npm install -g babel-eslint
npm install -g eslint-config-defaults

# Fuzzy file finder, can be used within Vim
choco install fzf