#/bin/bash

echo "This script will create a new systemd service."

while true; do
    read -p "Service filename (systemctl start [this-name-here])? " name

    if [ -z "$name" ]; then
        echo "Filename is required. Try again.";
    elif test -f "/lib/systemd/system/${name}.service"; then
        echo "Service of this name already exists, please choose a different name.";
    else
        break;
    fi
done

FILE="/lib/systemd/system/${name}.service"

while true; do
    read -p "User (root is not allowed)? " user

    if [ "$user" == "root" ]; then
        echo "Root is not allowed for security reasons. Try again.";
    else
        break;
    fi
done

read -p "Command to execute? " cmd
read -p "Description (may be empty)? " description
read -p "Environment variables (may be empty)? " env

echo "==================="
echo "The following file will be created: ${FILE}"
while true; do
    read -p "Do you wish to continue? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y or N.";;
    esac
done

cat > $FILE <<EOL
[Unit]
Description=${description}
After=network.target

[Service]
Environment=${env}
Type=simple
User=${user}
ExecStart=${cmd}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

read -p "Service file created, do you want to start the service right now?" yn
while true; do
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y or N.";;
    esac
    read -p "Do you want to start the service? " yn
done

sudo systemctl start ${name}
echo "Done."