FROM gitpod/openvscode-server:1.72.2

USER root

RUN apt update && apt install -y wget tar nano nginx tmux

RUN touch /home/workspace/.bashrc
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
  -t agnoster \
  -p colored-man-pages \
  -p git \
  -p man

# Get C++
RUN sudo apt-get update
RUN apt-get install -y gcc g++
RUN apt-get install -y --no-install-recommends cmake make

# Get Python
RUN sudo apt-get update
RUN sudo apt-get -y install python3.11 python3.11-dev
RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
RUN sudo update-alternatives --config python3
COPY get-pip.py /get-pip.py
RUN python3 /get-pip.py && rm /get-pip.py

# For pymavlink
RUN sudo apt-get -y install libxml2-dev libxslt-dev

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> /home/workspace/.bashrc
RUN echo 'export PATH="$PATH:/home/workspace/.local/bin"' >> /home/workspace/.bashrc

# This need to be the last step
RUN echo "zsh" >> /home/workspace/.bashrc
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir -p /service
COPY tmux.conf /etc/tmux.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY register_service /service/register_service

RUN mkdir -p /home/workspace/.local

COPY start.sh /start.sh

EXPOSE 100-65535/tcp
EXPOSE 100-65535/udp

LABEL version="1.1.2"
LABEL permissions='{\
  "ExposedPorts": {\
    "80/tcp": {}\
  },\
  "HostConfig": {\
    "Privileged": true,\
    "Binds": [\
      "/usr/blueos/userdata/openvscode/.cache:/home/workspace/.cache:rw",\
      "/usr/blueos/userdata/openvscode/.local:/home/workspace/.local:rw",\
      "/usr/blueos/userdata:/userdata:rw",\
      "/usr/blueos/openvscode:/openvscode:rw",\
      "/var/run/docker.sock:/var/run/docker.sock:rw",\
      "/usr/bin/docker:/usr/bin/docker:ro",\
      "/etc/hostname:/etc/hostname:ro",\
      "/dev:/dev:rw",\
      "/:/home/workspace/host:rw"\
    ],\
    "PortBindings": {\
      "80/tcp": [\
        {\
          "HostPort": ""\
        }\
      ]\
    }\
    "CpuPeriod": 100000,\
    "CpuQuota": 100000\
  }\
}'
LABEL authors='[\
    {\
        "name": "Patrick José Pereira",\
        "email": "patrickelectric@gmail.com"\
    }\
]'
LABEL readme="https://raw.githubusercontent.com/patrickelectric/blueos-code-server/master/README.md"
LABEL type="other"
LABEL tags='[\
  "code",\
  "development",\
  "ide",\
  "vscode",\
  "python",\
  "rust",\
  "c++"\
]'

SHELL ["/bin/zsh", "-c"]
ENTRYPOINT ["/start.sh"]