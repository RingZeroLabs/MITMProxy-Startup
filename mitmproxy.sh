# Bash script to setup MITMProxy on Kali Linux

# Setup forwarding vars
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv4.conf.all.send_redirects=0

# Ensure the MITM User is added and pip is installed
sudo apt-get install pip
sudo useradd --create-home mitmproxyuser
sudo -u mitmproxyuser -H bash -c 'cd ~ && pip install --user mitmproxy'

# Setup Routing
sudo iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner mitmproxyuser --dport 80 -j REDIRECT --to-port 8080
sudo iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner mitmproxyuser --dport 443 -j REDIRECT --to-port 8080
sudo ip6tables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner mitmproxyuser --dport 80 -j REDIRECT --to-port 8080
sudo ip6tables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner mitmproxyuser --dport 443 -j REDIRECT --to-port 8080

# Install Root Certificates
openssl x509 -in ~/.mitmproxy/mitmproxy-ca-cert.cer -inform PEM -out ~/.mitmproxy/mitm.crt
sudo mkdir -p /usr/share/ca-certificates/extra
sudo cp ~/.mitmproxy/mitm.crt /usr/share/ca-certificates/extra/mitm.crt
sudo cp ~/.mitmproxy/mitm.crt /usr/local/share/ca-certificates/mitm.crt
sudo dpkg-reconfigure ca-certificates # Interactive

# Start the mitmweb service. Go to 127.0.0.1:8081 in browser
sudo -u mitmproxyuser -H bash -c 'mitmweb --mode transparent --showhost --set block_global=false' & 

# Wait a few seconds for the mitmproxy to start
sleep 5

# Open firefox to the mitmproxy browser page
`which firefox` http://127.0.0.1:8081 & 
