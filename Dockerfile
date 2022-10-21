FROM gitpod/openvscode-server:1.72.2

USER root

RUN apt update && apt install -y wget tar nano nginx

RUN mkdir -p /service
COPY nginx.conf /etc/nginx/nginx.conf
COPY register_service /service/register_service

COPY start.sh start.sh

USER openvscode-server

LABEL version="1.0.0"
LABEL permissions='{\
  "ExposedPorts": {\
    "80/tcp": {}\
  },\
  "HostConfig": {\
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
  "c++",\
]'

ENTRYPOINT ["/home/workspace/start.sh"]