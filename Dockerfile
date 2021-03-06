FROM ubuntu:16.04

########################## RUN AS ROOT ###########################

# Pull base image and install updates
RUN apt-get update && apt-get -y upgrade

# Make sure some basic packages are installed
RUN apt-get install -y \
      software-properties-common build-essential curl git htop man unzip \
      vim wget pkg-config

# Install gcc toolchain and dependencies for spack
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install -y \
    cmake python gcc-7 gfortran-7 g++-7 make bzip2 xz-utils

# Delete files that are no longer needed
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user hpc and use as default
RUN groupadd -r hpc && useradd -r -m -d /home/hpc -g hpc hpc
USER hpc
WORKDIR /home/hpc

########################## RUN AS HPC ###########################

# Copy files
COPY hpc/.bashrc /home/hpc/.bashrc

# Download Spack
RUN cd $HOME && git clone https://www.github.com/llnl/spack.git .spack
RUN cd $HOME/.spack && git checkout develop
RUN $HOME/.spack/bin/spack compiler find

# Overwrite compiler configs
RUN rm $HOME/.spack/linux/compilers.yaml
COPY hpc/compilers.yaml /home/hpc/.spack/linux/compilers.yaml

# Environment Modules
RUN $HOME/.spack/bin/spack install environment-modules%gcc@7
RUN $HOME/.spack/bin/spack module refresh -y

# Show some configs of spack
RUN cat $HOME/.spack/linux/compilers.yaml

# Remove all stage/temp directories
RUN $HOME/.spack/bin/spack clean

# Define default command.
CMD ["bash"]
