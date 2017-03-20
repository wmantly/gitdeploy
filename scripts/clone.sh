name="$1";
sshURL="$2";
install_dir="$3";

mkdir -p $install_dir;
cd $install_dir;

git clone $install_dir;
git fetch origin $name:$name;
exit 0;
