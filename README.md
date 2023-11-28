
# sidx
Sidx is a personalized Debian system I made from my own desktop, turned into an easy-to-install ISO image.

# Build the iso with live-build

1. Clone the repository

      ```git clone https://github.com/aattilam/sidx.git```
 
2. Install required packages live-build and live-config

      ```$ apt-get install -y live-build live-config```

3. Navigate to the Sidx directory and make the script.sh executable

      ```cd sidx; chmod +x script.sh```
 
4. Run the script.sh to create the live-build configuration directory structure

      ```./script.sh```
 
5. Build the ISO with lb-build

      ```$ lb-build```
