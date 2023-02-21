# DL3025
##  Use a notação JSON (exec form) no CMD e ENTRYPOINT

[Documenação do lint](https://github.com/hadolint/hadolint/wiki/DL3025)

#### Problemas:
- Comando principal passa a ser um sub processo
- Impossibilita o envio de SIGTERM ao container
- Maior espera no desligamento do container

Quando as instruções CMD ou ENTRYPOINT são definidas em shell form o comando definido passa a ser um subprocesso de `/bin/sh -c`. Isso significa que o container não consegue receber os sinais Unix, e por consequência passa a não receber o sinal de `SIGTERM` enviado pelo comando `docker stop`. Após o envio do sinal pelo docker o mesmo aguarda por 10 segundos até que seja enviado um sinal de `SIGKILL`, e a depender de onde o container esteja executando o tempo de espera pode ser maiso ( como no ECS por exemplo, que possúi um timeout de 30 segundos até o envio do SIGKILL).


#### Laboratório

Dentro da pasta DL3025 execute os comandos abaixo para criar duas imagens, uma com o CMD definido em `shell form` e outro em `exec form`.

```sh
$ docker image build -t hadolint-lab:exec-form -f Dockerfile.exec.form .
```

```sh
$ docker image build -t hadolint-lab:shell-form -f Dockerfile.shell.form .
```

Execute um container utilizando a imagem `hadolint-lab:shell-form`. A saída do container será um texto com a quantidade de loops executados, similar aoexemplo abaixo:

```sh
$ docker container run hadolint-lab:shell-form
“running the loop 1 times”
“running the loop 2 times”
“running the loop 3 times”
“running the loop 4 times”
“running the loop 5 times”
“running the loop 6 times”
```

Tente finalizar o container com um `ctrl+c`, que é equivalente ao comando `docker stop <container>` quando o terminal está anexado ao container.

O container continuará sua execução. Abra um novo terminal e execute o comando `docker stop <container>`, levará 10 segundos até que o Docker envie um `SIGKILL` e interrompa o container.

Agora inicie um container com a imagem `hadolint-lab:exec-form`. Após iniciar o container tente parar novamente a execução com um `ctrl+c`. Desta vez o container irá encerrar com a seguinte mensagem: `script terminated with signal 2`.

```sh
$ docker container run hadolint-lab:exec-form
“running the loop 1 times”
“running the loop 2 times”
“running the loop 3 times”
“running the loop 4 times”
^Cscript terminated with signal 2
```

Teste tambem parar o container com o `docker stop`,  a mesma mensagem irá aparecer e mais uma vez o container será encerrado.