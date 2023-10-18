ARG RUST_VERSION

# Use a imagem Rust especificada pelo argumento
FROM rust:${RUST_VERSION}

ARG UID
ARG GID
ARG USER
ARG PASSWORD
ARG SHELL


# atualização do sistema, instalação de ferramentas e criação do usuário não root
RUN apt -y update && apt -y upgrade && apt install -y nano vim curl && \
    addgroup --gid $GID $USER && \
    adduser --uid $UID --gid $GID --shell $SHELL --home /home/$USER $USER && \
    # define uma senha para o usuário criado
    echo "$USER:$PASSWORD" | chpasswd
    

# muda para o usuário não root
USER $USER

WORKDIR /app