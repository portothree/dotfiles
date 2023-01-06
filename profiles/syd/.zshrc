# Arch swtich
alias mzsh="arch -arm64 zsh"
alias izsh="arch -x86_64 zsh"

# M1 and Rosetta
if [ "$(uname -p)" = "i386" ]; then
  eval "$(/usr/local/homebrew/bin/brew shellenv)"
  alias brew="/usr/local/homebrew/bin/brew"
  export PATH="/usr/local/homebrew/opt/python@3.10/libexec/bin:${PATH}"

  # Oracle installation https://www.oracle.com/database/technologies/instant-client/macos-intel-x86-downloads.html
  export PATH="/opt/oracle_x86_64/instantclient_19_8:${PATH}"
  export LD_LIBRARY_PATH="/opt/oracle_x86_64/instantclient_19_8"
  export ORACLE_HOME="/opt/oracle_x86_64/instantclient_19_8"
  export DYLD_LIBRARY_PATH="/opt/oracle_x86_64/instantclient_19_8"
  #Run below command after install oracle client on mac
  #ln -s /opt/oracle_x86_64/instantclient_19_8/libclntsh.dylib   /usr/local/lib

  export NVM_DIR="$HOME/.nvm_x86"
  [ -s "/usr/local/homebrew/opt/nvm/nvm.sh" ] && \. "/usr/local/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

  echo "Running in i386 mode (Rosetta)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
  alias brew="/opt/homebrew/bin/brew"
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  echo "Running in ARM mode (M1)"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh
