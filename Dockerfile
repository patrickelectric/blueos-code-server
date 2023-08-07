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
RUN apt-get install -y gcc-12 g++-12
RUN apt-get install -y --no-install-recommends cmake make

# Get Python
RUN sudo apt-get update
RUN sudo apt-get -y install python3.11
RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
RUN sudo update-alternatives --config python3
COPY get-pip.py /get-pip.py
RUN python3 /get-pip.py && rm /get-pip.py

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> /home/workspace/.bashrc

# This need to be the last step
RUN echo "zsh" >> /home/workspace/.bashrc
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/gcc-12 /usr/bin/gcc
RUN ln -s /usr/bin/g++-12 /usr/bin/g++

RUN mkdir -p /service
COPY tmux.conf /etc/tmux.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY register_service /service/register_service

COPY start.sh start.sh

LABEL version="1.1.0"
LABEL permissions='{\
  "ExposedPorts": {\
    "80/tcp": {}\
  },\
  "HostConfig": {\
    "Privileged": true,\
    "Binds": [\
      "/usr/blueos/userdata:/home/workspace/userdata:rw",\
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
ENTRYPOINT ["/home/workspace/start.sh"]