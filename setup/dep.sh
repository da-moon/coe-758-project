#! /bin/bash


# setting up language server
mkdir libghdl-py
cd libghdl-py
curl -fsSL https://codeload.github.com/ghdl/ghdl/tar.gz/master | tar xzf - --strip-components=2 ghdl-master/python
pip3 install .
mkdir ../ghdl-ls
cd ../ghdl-ls
curl -fsSL https://codeload.github.com/ghdl/ghdl-language-server/tar.gz/master | tar xzf - --strip-components=2 ghdl-language-server-master/ghdl-ls
pip3 install --user .
yarn global add vsce
mkdir ../ghdl-language-server
cd ../ghdl-language-server
curl -fsSL https://codeload.github.com/ghdl/ghdl-language-server/tar.gz/master | tar xzf - --strip-components=2 ghdl-language-server-master/vscode-client
yarn
vsce package --yarn
vsix_file="$(ls vhdl-lsp-*.vsix)"
vsc_exts="$HOME/.vscode-server/extensions"
mkdir -p $vsc_exts
unzip "$vsix_file"
rm [Content_Types].xml
mv extension.vsixmanifest extension/.vsixmanifest
mv extension "$vsc_exts/tgingold.${vsix_file%.*}"
cd ..  && rm -rf libghdl-py && rm -rf ghdl-ls && rm -rf ghdl-language-server  
