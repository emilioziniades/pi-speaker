
BLUE='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_colour()
{
    printf "$(tput setaf $1)$2$(tput sgr 0)\n"
}

print_blue()
{
    print_colour 6 "$1"
}

print_red()
{
    print_colour 1 "$1"
}
