FROM gitpod/workspace-full
                    
USER gitpod

RUN sudo apt-get -q update && sudo apt-get install -yq mingw-w64
ENV CHOOSENIM_NO_ANALYTICS 1
RUN curl https://nim-lang.org/choosenim/init.sh -sSf | sh -s -- -y
ENV PATH /home/gitpod/.nimble/bin:$PATH
RUN nimble install -y https://github.com/NimStart/nim-bearssl.git
RUN nimble install -y chronos
RUN nimble install -y fidget@#head

# Install custom tools, runtime, etc. using apt-get
# For example, the command below would install "bastet" - a command line tetris clone:
#
# RUN sudo apt-get -q update && #     sudo apt-get install -yq bastet && #     sudo rm -rf /var/lib/apt/lists/*
#
# More information: https://www.gitpod.io/docs/42_config_docker/
