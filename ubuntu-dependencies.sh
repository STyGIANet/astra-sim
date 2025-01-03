sudo apt -y update
sudo apt -y install coreutils wget vim git
sudo apt -y install gcc-11 g++-11 make cmake 
sudo apt -y install clang-format 
sudo apt -y install libboost-dev libboost-program-options-dev
sudo apt -y install python3.10 python3-pip
sudo apt -y install libprotobuf-dev protobuf-compiler
sudo apt -y install openmpi-bin openmpi-doc libopenmpi-dev
# Python packages
pip3 install --upgrade pip
pip3 install protobuf==5.28.2
pip3 install graphviz pydot