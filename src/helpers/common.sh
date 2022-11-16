# Stuff defined in here is available in the shortcuts files

blue=$(tput setaf 4)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

if (locale | grep -e 'utf8' -e 'UTF-8') >/dev/null 2>&1; then 
    logo="📖  "; 
else 
    logo=""; 
fi

function sourceEnvFile {
    ENV_FILE="$HOME/.morrish.env"

    source $ENV_FILE
}

function mask {
   local r="${1?needs an argument}"
   if ((${#r} > 4)); then
      r="${r:0: -4}"
      echo "${r//?/*}${1: -4}"
   else
      echo "$r"
   fi
}
