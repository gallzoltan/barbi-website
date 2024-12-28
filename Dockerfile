#podman build -t vnode18 .
#podman run --rm -it --name "dev-js" -v $PWD:/home/app -e RUN_PORT=8080 -p 8080:8080 vnode18

FROM node:18
WORKDIR /home/app
ENV RUN_PORT=8080
EXPOSE ${RUN_PORT}

ENTRYPOINT ["/bin/bash"]
