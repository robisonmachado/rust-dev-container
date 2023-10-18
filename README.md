
# Ambiente Local de Desenvolvimento Rust com Docker e Docker-Compose com usuário não root 
**Tempo de Leitura Estimado: 3 minutos**

O Docker revolucionou a forma como desenvolvemos e implantamos aplicativos, mas às vezes enfrentamos desafios ao executar contêineres como superusuário (root). Neste artigo, exploraremos como configurar um ambiente local de desenvolvimento Rust com Docker e Docker-Compose sem a necessidade de permissões de superusuário, destacando as vantagens dessa abordagem para evitar problemas de permissão de arquivos ao utilizar volumes.


## O Docker e Sua Transformação na Indústria

Lançado em 2013, o Docker se tornou uma tecnologia essencial para o desenvolvimento de software. A capacidade de empacotar aplicativos e suas dependências em contêineres trouxe inúmeras vantagens, incluindo portabilidade e a eliminação de problemas de ambiente. No entanto, a execução de contêineres para desenvolvimento local como superusuário pode apresentar problemas com permissões de arquivos quando, ao utilizar volumes, mapeamos pastas e arquivos locais para dentro do container.

## Facilidades de Desenvolvimento Containerizado
As ferramentas de desenvolvimento containerizado simplificam a criação, o compartilhamento e a implantação de ambientes de desenvolvimento. Essas ferramentas garantem que todos, desde desenvolvedores até operadores de sistemas, usem os mesmos ambientes, eliminando diferenças entre máquinas e problemas comuns, como "funciona na minha máquina".


## Dockerfile: Configurando um Ambiente de Desenvolvimento Rust
<a name="dockerfile"></a>
Para configurar um ambiente de desenvolvimento Rust com Docker sem permissões de superusuário, criei o seguinte Dockerfile personalizado:

```Dockerfile
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

```

Neste Dockerfile, criamos um usuário normal (não superusuário) e então definimos ele como o usuário padrão. Isso evita a necessidade de executar o contêiner como superusuário e oferece uma vantagem crucial: elimina problemas de permissão de arquivos ao usar volumes. Utilizei alguns ARGUMENTOS que serão passados pelo arquivo docker-compose.yaml, neste caso preferi argumentos ao invés de variáveis de ambiente, pois, os valores passados como argumentos não são acessíveis após o build da imagem, evitando que dados sensíveis ou que sejam necessárias apenas para o tempo de build estejam disponibilizadas no ambiente do container.

## Docker-Compose: Simplificando o Ambiente de Desenvolvimento
<a name="docker-compose"></a>
O Docker-Compose é uma ferramenta poderosa que simplifica a orquestração de vários contêineres. Aqui está o nosso docker-compose.yaml configurado para ser utilizado com o nosso Dockerfile acima:

```yaml
version: "3.8"
services:
  rust-dev-service:
    container_name: rust-dev-container
    image: rust-dev-image
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - RUST_VERSION=1.73.0-bookworm
        - UID=1000
        - GID=1000
        - USER=rustdev
        - PASSWORD=rustdev
        - SHELL=/bin/bash
    volumes:
      - .:/app
    
```

Neste arquivo, definimos o serviço "rust-dev-service" para usar o Dockerfile personalizado e especificamos o UID e GID do usuário não root através de ARGS passado a etapa de build da imagem docker. Além disso especificamos outros detalhes como nome do usuário, senha e shell padrão.

## Utilização
Crie um arquivo ***Dockerfile*** com o conteúdo especificado na seção [Dockerfile: Configurando um Ambiente de Desenvolvimento Rust](#dockerfile).
Em seguida crie um arquivo ***docker-compose.yaml*** com o conteúdo especificado na seção [Docker-Compose: Simplificando o Ambiente de Desenvolvimento](#docker-compose). Feito esses dois passos, com o terminal aberto no diretório onde se encontram os dois arquivos mencionados, execute o seguinte comando:

```bash
docker compose run --rm --build rust-dev-service /bin/bash
```

dessa forma você estará dentro do container e poderá executar os comandos do rust (cargo, rustc, etc).

Para sair do container execute:
```bash
exit
```

## Conclusão
Ao configurar um ambiente local de desenvolvimento Rust com Docker e Docker-Compose sem a necessidade de permissões de superusuário, você evita problemas de permissão de arquivos ao usar volumes. Com essas ferramentas, você cria ambientes consistentes, elimina problemas de ambiente e concentra-se no que realmente importa: desenvolver softwares incríveis!