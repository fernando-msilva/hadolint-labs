# DL3020
##  Use COPY ao invés de ADD para copiar arquivos e pastas

[Documenação do lint](https://github.com/hadolint/hadolint/wiki/DL3020)

#### Problemas:
- Aumentar o tamanho da imagem final ao baixar arquivos por URL
- ADD possui funcionalidades desnecessárias para cópia de arquivos e pastas

O melhor cenário para utilização do `ADD` é quando existem arquivos locais compactados, pois ele possúi a funcionalidade de descompactação de arquivos de compressão `gzip`, `bzip2` ou `xz` para dentro da imagem. Arquivos com tipos de compressão não suportadas serão copiados na sua forma original.

As funcionalidades do `ADD` não fornecem vantagens para cópia de arquivos normais e diretórios, logo faz mais sentido a utilização do `COPY`.

> Outro ponto de atenção em relação ao uso do `ADD` é que quando é passado uma url o arquivo baixado não é descompactado automaticamente, sendo necessário uma instrução `RUN` para extrair os arquivos logo após. A instrução `ADD` gera uma `layer` com o arquivo baixado na imagem, e isso contribui com o aumento do tamanho final. Para esses casso é recomendado qeu o arquivo sexa baixado via `wget`, `curl` ou afins, pois dessa forma é possível remover os arquivos desnecessários após a descompactação.


#### Laboratório

Dentro da pasta DL3020 execute os comandos abaixo para criar três imagens, uma com o `ADD` utilizando um `arquivo remoto`, uma com o mesmo arquivo remoto sendo baixado via `wget` e outra com `arquivos locais`.

```sh
$ docker image build -t hadolint-lab:add-remote --target add -f Dockerfile.remote .
```

```sh
$ docker image build -t hadolint-lab:wget-remote --target wget -f Dockerfile.remote .
```

```sh
$ docker image build -t hadolint-lab:add-local -f Dockerfile.local .
```

Execute um container utilizando a imagem `hadolint-lab:add-local`. Observe que foram criadas 3 pastas: `/zip`, `/tar` e `/file`.

Observe que na pasta `/file`, apesar de não ser o recomendado, a instrução `ADD` copiou corretamente o arquivo. Na pasta `/tar` o arquivo foi copiado e extraído automaticamente. E por fim na pastra `/zip` o arquivo foi apenas copiado, por não estar compactado com uma das compressões suportadas.

```sh
$ docker container run -it hadolint-lab:add-local
/file # ls
example-file.txt
/file # cd ../tar
/tar # ls
example-file.txt
/tar # cd ../zip
/zip # ls
example.zip
/zip # 
```

Agora para visualizar melhor como a utilização do `ADD` para baixar arquivos remotes influencia no tamanho final da imagem vamos comparar as imagens `hadolint-lab:wget-remote` e `hadolint-lab:add-remote`

```sh
$ docker images --filter label="DL=3020"
REPOSITORY     TAG           IMAGE ID       CREATED       SIZE
hadolint-lab   wget-remote   47094e9f2de2   2 hours ago   182MB
hadolint-lab   add-remote    9f0aebb51b04   2 hours ago   205MB
```

É possível também identificar a layer que é criada com o `ADD` ao baixar o arquivo remoto e é a responsável pela diferença de tamanho entre as imagens.

```sh
$ docker history hadolint-lab:add-remote
IMAGE          CREATED       CREATED BY                                      SIZE      COMMENT
9f0aebb51b04   2 hours ago   RUN /bin/sh -c tar -xf wine-1.9.19.tar.bz2 &…   175MB     buildkit.dockerfile.v0
<missing>      2 hours ago   ADD https://dl.winehq.org/wine/source/1.9/wi…   23.5MB    buildkit.dockerfile.v0
<missing>      2 hours ago   LABEL DL=3020                                   0B        buildkit.dockerfile.v0
<missing>      10 days ago   /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
<missing>      10 days ago   /bin/sh -c #(nop) ADD file:40887ab7c06977737…   7.04MB
```


```sh
$ docker history hadolint-lab:wget-remote
IMAGE          CREATED       CREATED BY                                      SIZE      COMMENT
47094e9f2de2   2 hours ago   RUN /bin/sh -c wget https://dl.winehq.org/wi…   175MB     buildkit.dockerfile.v0
<missing>      2 hours ago   LABEL DL=3020                                   0B        buildkit.dockerfile.v0
<missing>      10 days ago   /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
<missing>      10 days ago   /bin/sh -c #(nop) ADD file:40887ab7c06977737…   7.04MB
```