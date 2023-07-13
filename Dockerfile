FROM gitpod/openvscode-server:1.72.2

USER root

RUN apt update && apt install -y wget tar nano nginx tmux

RUN touch /home/workspace/.bashrc
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
  -t agnoster \
  -p colored-man-pages \
  -p git \
  -p man

RUN echo "zsh" > /home/workspace/.bashrc
RUN mkdir -p /service
COPY tmux.conf /etc/tmux.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY register_service /service/register_service

COPY start.sh start.sh

LABEL version="1.0.6"
LABEL permissions='{\
  "ExposedPorts": {\
    "80/tcp": {}\
  },\
  "HostConfig": {\
    "Privileged": true,\
    "Binds": [\
      "/usr/blueos/userdata:/home/workspace/userdata:rw",\
      "/usr/blueos/openvscode:/openvscode:rw",\
      "/etc/hostname:/etc/hostname:ro",\
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