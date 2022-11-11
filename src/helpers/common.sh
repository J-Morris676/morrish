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