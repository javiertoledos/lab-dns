# Laboratorio 3 - DNS

El laboratorio consiste en utilizar dig como herramienta para realizar consultas
de DNS y utilizar bind9 como servidor DNS para configurarlo para resolver
consultas y responder a un dominio configurado localmente.


## Prerequisitos

* docker 19 o superior
* docker-compose 1.3 o superior
* Mac OS/Linux/Windows con WSL2
* Terminal bash o zsh

## Práctica

### Dig como cliente DNS

Dig (Domain Information Groper) es una herramienta de línea de comandos para 
realizar consultas a servidores DNS. En ubuntu, `dig` puede instalarse
utilizando:

```
sudo apt-get install -y dnsutils

# Corre dig -v para validar la instalación
dig -v
```

Una vez configurado `dig`. Se pueden hacer consultas para resolver dominios. 
Prueba correr el ejemplo:

```
# dig @<dns-server> <domain> <resource-record-type>
dig @1.1.1.1 protocolos.app
```

La respuesta debe ser similar a esta:

```
; <<>> DiG 9.11.3-1ubuntu1.11-Ubuntu <<>> @1.1.1.1 protocolos.app
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17442
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;protocolos.app.                        IN      A

;; ANSWER SECTION:
protocolos.app.         3255    IN      A       127.0.0.1

;; Query time: 17 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Fri Jul 24 07:44:02 CST 2020
;; MSG SIZE  rcvd: 73
```

La líneas con doble punto y coma `;;` son líneas de comentarios y proveen 
información adicional de la petición y la respuesta. Estos comentarios se pueden
eliminar con el parámetro `+nocomments`

Analizando los comentarios podemos notar algunos de interes como los flags:

```
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
```

Estos flags corresponden a los definidos en el [RFC 1035 de DNS](https://tools.ietf.org/html/rfc1035)
y en el ejemplo se pueden observar los flags:
* Query (qr), 
* Recursion desired (rd),
* Recursion availabe (ra),
* Authentic data (ad)
  
  El servidor recursivo pudo determinar la autenticidad del dominio. Ver 
  [RFC 4035 DNSSEC](https://tools.ietf.org/html/rfc4035) para más detalles.

Luego la sección de `;; OPT PSEUDOSECTION` indica si se estan haciendo uso de 
las extensiones de DNS (útiles por ejemplo para DNSSEC)

La secciones de pregunta y respuesta contiene la consulta que fue realizada y
todos los registros con los que el servidor responde. En el ejemplo tenemos:

```
;; QUESTION SECTION:
;protocolos.app.                        IN      A

;; ANSWER SECTION:
protocolos.app.         3255    IN      A       127.0.0.1
```

Esto significa que el comando preguntó por el dominio `protocolos.app.` de la 
clase de registros `IN` (Internet) y un registro de tipo `A`. La respuesta nos
devuelve dominio, el tiempo de cache `3255` segundos, la clase `IN`, el tipo de
registro `A` y la dirección IP asociada, en este caso `127.0.0.1`.

Por último el comando devuelve información del tiempo de respuesta, el servidor
que se utilizó, la fecha y el tamaño de la respuesta.

Para obtener una respuesta sin ningun tipo de comentarios se puede ejecutar el
comando con los flags `+noall +answer` que significa quita todo display, y luego
solo agrega la respuesta.

```
dig +noall +answer @1.1.1.1 protocolos.app
```
Resultado:
```
protocolos.app.         1056    IN      A       127.0.0.1
```

### Levantando un servidor DNS con Bind9

El [contenido del laboratorio](https://github.com/javiertoledos/lab3-dns/archive/master.zip)
consiste en una configuración con docker-compose para levantar un servidor de 
bind9 utilizando Docker. Para levantar el laboratorio solo basta con ejecutar:

```
docker-compose up
```

El laboratorio incluye la definición de la imagen para instalar bind9 y expone
el puerto 53 tanto en TCP como UDP para recibir queries. Si se ejecuta docker 
como usuario no `root` o hay problemas de firewall para usar el puerto 53 se 
puede cambiar el mapeo en el archivo docker compose para usar un puerto no 
estandar:

```
    ports:
      # HOST-PORT:CONTAINER-PORT/PROTOCOL
      - "5300:53/udp"
      - "5300:53/tcp"
```

El laboratorio tiene configurada una zona de ejemplo `lab3-dns.example.com`. 
Para verificar que el servidor está arriba y funcionando se puede comprobar con
dig corriendo:

```
dig +noall +answer @localhost lab3-dns.example.com
```
```
lab3-dns.example.com.   604800  IN      A       10.0.0.1
```

Los archivos de configuración se pueden encontrar en la carpeta `./config`. Para
este laboratorio los archivos relevantes son:
* `named.conf.options` Lugar para configurar los servidores para recursión
* `named.conf.local` Lugar donde se define las zonas locales para configurar
* `db.lab3-dns.example.com` Archivo de ejemplo para zona local
* `db.<numero-de-carné>.intra` Debes crear este archivo para completar tu 
  laboratorio y referenciarlo desde `named.conf.local`.

## Ejercicio

Debes configurar el domino `<número-de-carné>.intra` en el servidor de forma que
responda queries a este domino. El dominio debe tener las siguientes
configuraciones:
* El dominio raíz debe tener un registro A que apunte a una dirección IPv4. Para
  el laboratorio escoge una dirección al azar en el segmento 10.0.0.0/8.
* Debe existir un registro de tipo CNAME para `www.<número-de-carné>.intra` que
  apunte al directorio raíz
* Debe existir otro registro CNAME para `app.<número-de-carné>.intra` que apunte
  al dominio `protocolos.app`.
* Configura el dominio `<numero-de-carné>.intra` con los siguientes servidores
  de correo (registros MX). Asegurate de escoger una prioridad adecuada según el
  tipo de servidor:
  * `main-smtp.protocolos.app.` como servidor MX principal
  * `replica1-smtp.protocolos.app.` como servidor secundario 
  * `replica2-smtp.protocolos.app.` como otro servidor secundario
* Configura el registro SPF para el dominio principal con la siguiente 
  información:
  ```
  "v=spf1 ip4:10.0.0.0/29 ~all"
  ```

Por último, configura el servidor de bind9 para que utilice los servidores DNS
de Google (8.8.8.8 y 8.8.4.4) para responder las consultas recursivas que se le 
hagan.

**TIP:** Cuando modifiques un archivo de zona recuerda incrementar el número
serial dentro del archivo `db.<número-de-carné>.intra` para que bind9 aplique
los cambios. Tambien recuerda reiniciar el servicio cada vez que modifiques la
configuración.

## Entrega

1. Crea un archivo llamado lab3.txt en la carpeta raíz del laboratorio con el
  siguiente contenido:
    - Listado de los comandos (`dig`) necesarios para validar que está
      correctamente configurado el dominio del ejercicio
    - Explica que es DNS cache poisoning y como esto puede afectar la seguridad
      de los usuarios de tu servidor DNS.
    - Coloca 3 empresas o sitios web en donde puedes comprar y configurar 
      dominios .com y cual es el precio que ofrecen para un dominio cómun.
2. Crea un archivo zip con el nombre `lab3-<numero de carne>.zip`. Este archivo 
  debe contener los archivos agregados y modificados durante la  práctica. Es 
  requerido respetar este nombre ya que se evaluará con una herramienta
  automática el laboratorio y en caso de no seguir instrucciones, no se evaluará
  la respuesta.
3. En el archivo zip se debe colocar el contenido modificado que se descargó al
  inicio de la práctica. Nuevamente, es importante que el archivo .zip tenga la
  misma estructura de directorios:
    **Correcto:**
    ```
    lab3-20072089.zip
    ├── README.md
    ├── config
    │   └── ... archivos de configuracion
    ├── images/bind9
    │       └── Dockerfile
    └── docker-compose.yml
    ```
    **Incorrecto:**
    ```
    laboratorio.zip
    └──lab3-dns
        ├── README.md
        ├── config
        │   └── ... archivos de configuracion
        └── docker-compose.yml
    ```