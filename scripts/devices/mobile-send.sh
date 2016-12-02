for file in "$@"; do
    echo "Sending $file"
    kdeconnect-cli -d b51aef6efa15f881 --share "$file"
done
