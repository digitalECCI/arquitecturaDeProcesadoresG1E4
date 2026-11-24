# Lab05 - Diseño e Implementación de un Procesador con ISA y Unidad de Control

# Integrantes

* [Daniel Penagos Castro](https://github.com/Daniel-Penagos)
* [Danilo Forero Rodriguez](https://github.com/jouseddaniloS)
* [Brayan Extidt Torres Gaona](https://github.com/BrayanExtidt)

# Informe

## Índice

1. [Documentación del diseño implementado](#documentación-del-diseño-implementado)
2. [Set de instrucciones ISA](#set-de-instrucciones-isa)
3. [Arquitectura del procesador](#arquitectura-del-procesador)
4. [Unidad de control](#unidad-de-control)
5. [Programa de prueba](#programa-de-prueba)
6. [Simulaciones](#simulaciones)
7. [Implementación en FPGA](#implementación-en-fpga)
8. [Preguntas](#preguntas)
9. [Conclusiones](#conclusiones)
10. [Referencias](#referencias)

---

## Documentación del diseño implementado

### 1. Descripción general

El laboratorio consiste en el diseño e implementación de un procesador sencillo de 8 bits, capaz de ejecutar un conjunto reducido de instrucciones definido mediante una arquitectura de conjunto de instrucciones (ISA, *Instruction Set Architecture*).

El propósito principal es integrar los módulos desarrollados en laboratorios anteriores, como el banco de registros, la unidad aritmético-lógica (ALU), el multiplicador, el divisor y el módulo de comunicación UART, bajo el control de una unidad de control central.

El procesador utiliza instrucciones de 16 bits y dispone de ocho registros de propósito general, identificados desde R0 hasta R7. A través de las instrucciones, el sistema puede realizar operaciones aritméticas, lógicas, transferencias de datos, comparaciones y comunicación serial.

La ejecución de las instrucciones se organiza mediante una máquina de estados finitos (FSM), que coordina las etapas de búsqueda, decodificación, ejecución y escritura de resultados.

### 1.1 Objetivos del diseño

- Comprender el funcionamiento de una arquitectura de conjunto de instrucciones (ISA) y su relación con el hardware del procesador.
- Diseñar un conjunto reducido de instrucciones para operar sobre los registros y la ALU.
- Implementar una unidad de control que coordine las operaciones del procesador.
- Integrar los módulos desarrollados previamente en una arquitectura funcional.
- Implementar un programa de prueba que permita verificar las operaciones del procesador.
- Comprobar el funcionamiento mediante simulación e implementación física en la FPGA MAX 10.

### 1.2 Características generales

| Característica | Descripción |
|---|---|
| Arquitectura | Procesador de instrucciones de ancho fijo |
| Ancho de instrucción | 16 bits |
| Ancho de datos | 8 bits |
| Registros generales | 8 (R0–R7) |
| Direccionamiento de registros | 3 bits |
| Unidad de control | Máquina de estados finitos (FSM) |
| Memoria de instrucciones | ROM |
| Unidad de procesamiento | ALU |
| Operaciones adicionales | Multiplicación y división |
| Comunicación externa | UART |
| Dispositivo de implementación | FPGA MAX 10 |

### 1.3 Fundamento teórico

#### Arquitectura de conjunto de instrucciones (ISA)

El ISA (*Instruction Set Architecture*) representa el conjunto de instrucciones que un procesador puede interpretar y ejecutar. Define las operaciones disponibles, la cantidad de registros, los formatos de las instrucciones y la manera en que el software interactúa con el hardware.

Cada instrucción está representada mediante una palabra binaria de 16 bits, dividida en diferentes campos. El campo principal es el código de operación (*opcode*), encargado de indicar qué operación debe realizar el procesador.

Los demás campos identifican los registros fuente, el registro destino o los valores inmediatos que necesita la instrucción.

#### Datapath

El datapath o camino de datos es la estructura encargada de transportar, almacenar y procesar la información dentro del procesador.

Está conformado por los módulos que realizan las operaciones sobre los datos, entre ellos:

- Banco de registros.
- Unidad aritmético-lógica (ALU).
- Multiplicador.
- Divisor.
- Multiplexores de selección de datos.
- Memoria de instrucciones.

#### Unidad de control

La unidad de control es el bloque encargado de interpretar las instrucciones y generar las señales necesarias para coordinar el funcionamiento del datapath.

Su implementación mediante una máquina de estados permite organizar la ejecución de cada instrucción en diferentes etapas, evitando que los módulos trabajen de manera descoordinada.

---

## Set de instrucciones ISA

### 2.1 Formatos de instrucción

El procesador utiliza instrucciones de ancho fijo de 16 bits y contempla dos formatos principales:

**Formato Tipo R (registro-registro)**

Se utiliza para las operaciones que necesitan uno o dos operandos almacenados en el banco de registros.

| Opcode (4 bits) | rd (3 bits) | rs (3 bits) | rt (3 bits) | Reservado (3 bits) |
|---|---|---|---|---|

- `opcode`: identifica la operación.
- `rd`: registro donde se almacena el resultado.
- `rs`: primer registro fuente.
- `rt`: segundo registro fuente.
- `Reservado`: campo disponible que no participa en la operación propuesta.

**Formato Tipo I (inmediato)**

Se utiliza para cargar constantes directamente en un registro.

| Opcode (4 bits) | rd (3 bits) | Inmediato (9 bits) |
|---|---|---|

- `opcode`: identifica la instrucción.
- `rd`: registro destino.
- `Inmediato`: valor constante incluido dentro de la instrucción.

### 2.2 Tabla de instrucciones

El conjunto de instrucciones propuesto para el procesador es el siguiente:

| Opcode | Mnemónico | Tipo | Operación |
|---|---|---|---|
| `0000` | ADD | R | rd = rs + rt |
| `0001` | SUB | R | rd = rs - rt |
| `0010` | AND | R | rd = rs & rt |
| `0011` | OR | R | rd = rs \| rt |
| `0100` | XOR | R | rd = rs ^ rt |
| `0101` | CMP | R | Compara rs y rt y actualiza banderas |
| `0110` | MUL | R | rd = rs * rt |
| `0111` | DIV | R | rd = rs / rt |
| `1000` | LI | I | rd = inmediato |
| `1001` | MOV | R | rd = rs |
| `1010` | OUT | R | Transmite rs mediante UART |
| `1111` | HALT | — | Detiene la ejecución |

### 2.3 Descripción de las instrucciones

- **ADD:** realiza la suma de dos operandos almacenados en registros y guarda el resultado en el registro destino.
- **SUB:** realiza la resta entre dos registros.
- **AND:** ejecuta una operación lógica AND bit a bit.
- **OR:** ejecuta una operación lógica OR bit a bit.
- **XOR:** realiza una operación lógica XOR bit a bit.
- **CMP:** compara los valores de dos registros y actualiza las banderas correspondientes.
- **MUL:** multiplica dos operandos utilizando el multiplicador secuencial.
- **DIV:** divide dos operandos utilizando el divisor secuencial.
- **LI:** carga un valor inmediato en el registro destino.
- **MOV:** copia el contenido de un registro fuente hacia el registro destino.
- **OUT:** transmite mediante UART el contenido de un registro.
- **HALT:** detiene el ciclo de ejecución del procesador.

---

## Arquitectura del procesador

### 3.1 Organización general

La arquitectura del procesador está compuesta por dos bloques principales: la unidad de control y el datapath.

La unidad de control interpreta las instrucciones almacenadas en la memoria de programa y genera las señales que permiten coordinar los diferentes módulos.

El datapath recibe los datos, realiza las operaciones solicitadas y entrega los resultados para su almacenamiento o transmisión.

### 3.2 Módulos principales

**1. Contador de programa (PC)**

Es un registro encargado de almacenar la dirección de la siguiente instrucción que debe ejecutarse. Durante el funcionamiento normal, se actualiza para avanzar a la siguiente posición de la memoria de instrucciones.

**2. Memoria de instrucciones (ROM)**

Almacena el programa que ejecutará el procesador. La unidad de control utiliza el valor del PC para seleccionar la instrucción correspondiente.

**3. Banco de registros**

Almacena temporalmente los datos utilizados durante la ejecución de las instrucciones. Está compuesto por ocho registros de 8 bits, direccionados mediante tres bits.

**4. Unidad aritmético-lógica (ALU)**

Realiza las operaciones aritméticas y lógicas solicitadas por la unidad de control, utilizando los operandos provenientes del banco de registros.

**5. Multiplicador y divisor**

Son módulos especializados para realizar operaciones de multiplicación y división. Debido a que sus operaciones son secuenciales, utilizan señales de inicio (`start`) y finalización (`done`).

**6. Multiplexor de escritura**

Selecciona el dato que será almacenado en el registro destino. Dependiendo de la instrucción, puede seleccionar el resultado de la ALU, un valor inmediato o el resultado de una operación de multiplicación o división.

**7. UART**

Permite transmitir información desde el procesador hacia un dispositivo externo, como un computador, utilizando comunicación serial asíncrona.

### 3.3 Diagrama de caja negra

El sistema recibe las señales necesarias para su funcionamiento y entrega información mediante sus salidas de visualización y comunicación.

**Entradas principales:**
- Señales de reloj.
- Señal de reinicio.
- Señales de configuración o control, según la implementación.

**Salidas principales:**
- Señales de visualización mediante LEDs o displays, si están implementadas.
- Señal de transmisión UART (`TX`).
- Señales de estado, según la implementación.

**Diagrama funcional general:**

```text
                 +----------------------+
                 |     PROCESADOR       |
                 |                      |
 Clock --------->|                      |
 Reset --------->|     Unidad de        |
                 |      Control         |
                 |          |           |
                 |          v           |
                 |       Datapath       |
                 |          |           |
                 |    +-----+-----+     |
                 |    |     |     |     |
                 |   ALU   MUL   DIV    |
                 |    |     |     |     |
                 |    +-----+-----+     |
                 |          |           |
                 |      Banco de        |
                 |      Registros       |
                 |          |           |
                 |         UART        |
                 +----------+-----------+
                            |
                            v
                           TX
```

---

## Unidad de control

### 4.1 Descripción

La unidad de control es responsable de dirigir la ejecución de las instrucciones mediante una máquina de estados finitos.

A partir del opcode de cada instrucción, determina qué operación debe realizarse, cuáles registros deben leerse, qué módulo debe activarse y cuándo debe almacenarse el resultado.

Su funcionamiento se divide en cuatro etapas principales:

1. **Fetch (búsqueda):** utiliza el contador de programa para leer una instrucción de la memoria ROM y actualiza la dirección de la siguiente instrucción.
2. **Decode (decodificación):** interpreta los campos de la instrucción, identifica el opcode y obtiene los operandos necesarios del banco de registros.
3. **Execute (ejecución):** activa la ALU o el módulo especializado correspondiente para realizar la operación solicitada.
4. **Writeback (escritura):** almacena el resultado obtenido en el registro destino, cuando la instrucción lo requiere.

### 4.2 Comunicación entre módulos

La unidad de control genera diferentes señales para coordinar los módulos del procesador:

| Módulo | Señales de control | Función |
|---|---|---|
| Banco de registros | Direcciones y `we` | Selecciona registros y habilita la escritura |
| ALU | `alu_sel` | Selecciona la operación aritmética o lógica |
| Multiplicador | `start`, `done` | Inicia y supervisa la multiplicación |
| Divisor | `start`, `done` | Inicia y supervisa la división |
| UART | `start`, `busy` o señal equivalente | Controla la transmisión serial |
| Multiplexor | Selector de escritura | Selecciona el dato que se almacena |

### 4.3 Handshake entre la unidad de control y los módulos secuenciales

Las operaciones de multiplicación y división necesitan más de un ciclo de reloj para completarse.

Por esta razón, la unidad de control utiliza un mecanismo de sincronización denominado *handshake*.

Su funcionamiento es el siguiente:

1. La unidad de control activa la señal `start`.
2. El módulo correspondiente comienza a ejecutar la operación.
3. La unidad de control espera mientras la señal `done` permanezca desactivada.
4. Cuando `done` se activa, la unidad de control reconoce que el resultado está disponible.
5. El procesador continúa con la siguiente etapa de ejecución.

Este mecanismo evita que el procesador intente almacenar un resultado antes de que la operación haya terminado.

### 4.4 Diagrama ASM de la unidad de control

El siguiente esquema representa el ciclo general de ejecución:

```text
             +-------------+
             |    FETCH    |
             | Leer instrucción
             | Actualizar PC
             +------+------+
                    |
                    v
             +-------------+
             |   DECODE    |
             | Interpretar |
             | la instrucción
             +------+------+
                    |
                    v
             +-------------+
             |   EXECUTE   |
             | Realizar la |
             | operación   |
             +------+------+
                    |
          +---------+----------+
          |                    |
          v                    v
   Operación normal      MUL / DIV / OUT
          |                    |
          |             Esperar finalización
          |                    |
          +---------+----------+
                    |
                    v
             +-------------+
             |  WRITEBACK  |
             | Guardar dato|
             +------+------+
                    |
                    v
                  FETCH
```

La instrucción `HALT` representa una condición especial que debe llevar al procesador a un estado de detención, evitando que continúe ejecutando instrucciones.

**Nota:** El diagrama debe ajustarse a los estados y transiciones que realmente se hayan implementado en la FSM del proyecto.

---

## Programa de prueba

### 5.1 Descripción

Para comprobar el funcionamiento integrado del procesador se utiliza un programa de prueba cuyo objetivo es calcular la expresión:

\[
(5+3)\times 5=40
\]

Posteriormente, el resultado se transmite mediante el módulo UART para verificar la comunicación serial.

### 5.2 Programa en lenguaje ensamblador

```asm
LI   R1, 5       ; R1 = 5
LI   R2, 3       ; R2 = 3
ADD  R3, R1, R2  ; R3 = 8
MUL  R4, R3, R1  ; R4 = 40
OUT  R4          ; Transmite 40 por UART
HALT             ; Detiene la ejecución
```

### 5.3 Desarrollo de las operaciones

| Instrucción | Operación | Resultado esperado |
|---|---|---|
| LI R1, 5 | Carga 5 en R1 | R1 = 5 |
| LI R2, 3 | Carga 3 en R2 | R2 = 3 |
| ADD R3, R1, R2 | 5 + 3 | R3 = 8 |
| MUL R4, R3, R1 | 8 × 5 | R4 = 40 |
| OUT R4 | Transmisión UART | Se transmite 40 |
| HALT | Detención | Procesador detenido |

### 5.4 Resultado esperado

Al finalizar la ejecución del programa, el registro R4 debe contener el valor decimal 40, equivalente a:

\[
40_{10}=00101000_2
\]

El módulo UART debe transmitir el resultado hacia el computador, permitiendo verificar que la unidad de control, el datapath y la comunicación serial funcionan de manera integrada.

---

## Simulaciones

### 6.1 Descripción

La simulación funcional permite verificar el comportamiento del procesador antes de realizar su implementación física en la FPGA.

Para ello se utiliza un banco de pruebas (*testbench*) que proporciona las señales de reloj y reinicio, y permite observar la ejecución de las instrucciones almacenadas en la memoria de programa.

Durante la simulación se deben verificar los siguientes aspectos:

- Lectura correcta de las instrucciones desde la memoria ROM.
- Actualización del contador de programa.
- Decodificación correcta de los campos de cada instrucción.
- Lectura y escritura de los registros.
- Ejecución de las operaciones aritméticas y lógicas.
- Sincronización de las operaciones de multiplicación y división mediante `start` y `done`.
- Transmisión del resultado mediante UART.
- Detención del procesador al ejecutar `HALT`.

### 6.2 Verificación del programa

La secuencia de resultados esperada durante la simulación es:

| Etapa | Registro | Valor esperado |
|---|---|---|
| Carga inicial | R1 | 5 |
| Carga inicial | R2 | 3 |
| Suma | R3 | 8 |
| Multiplicación | R4 | 40 |
| Comunicación | UART | Transmisión de 40 |
| Finalización | Control | Estado HALT |

---

### 7. Descripción

Una vez verificado el funcionamiento del procesador mediante simulación, se realiza su implementación física en la tarjeta FPGA MAX 10.

El diseño se sintetiza utilizando la herramienta de desarrollo correspondiente, verificando que los módulos estén correctamente integrados y que no existan errores de compilación o asignación de recursos.

La implementación permite comprobar el funcionamiento del procesador en hardware real y observar los resultados mediante los periféricos disponibles o a través de la comunicación serial UART.

### 7.1 Verificación física

Durante la implementación se debe comprobar:

- Funcionamiento correcto de la señal de reloj.
- Reinicio adecuado del procesador.
- Ejecución secuencial del programa almacenado en la ROM.
- Obtención del resultado esperado en los registros.
- Funcionamiento de la comunicación UART.
- Detención del procesador después de ejecutar la instrucción `HALT`.

### 7.2 Video de implementación

En el siguiente enlace se presenta el video de la implementación y funcionamiento del procesador en la FPGA:

**[Ver video de implementación del Laboratorio 05 en YouTube](https://youtu.be/c-Jq7jka6hI)**

---

## Preguntas

**1. ¿Qué es una arquitectura de conjunto de instrucciones (ISA) y cuál es su función dentro de un procesador?**

El ISA es el conjunto de instrucciones que define las operaciones que puede ejecutar un procesador, así como sus formatos, registros y códigos de operación. Funciona como una interfaz entre el software y el hardware, permitiendo que los programas indiquen qué operaciones deben realizarse sin depender directamente de los detalles internos de la implementación.

**2. ¿Cuál es la diferencia entre la unidad de control y el datapath?**

La unidad de control interpreta las instrucciones y genera las señales necesarias para coordinar el procesador. Por otra parte, el datapath contiene los módulos encargados de almacenar, transportar y procesar los datos. Ambos bloques trabajan conjuntamente para ejecutar cada instrucción.

**3. ¿Por qué se utiliza una máquina de estados finitos en la unidad de control?**

Porque permite organizar la ejecución de las instrucciones en etapas definidas, como búsqueda, decodificación, ejecución y escritura. De esta manera, las operaciones se realizan de forma ordenada y se evita que los módulos del procesador trabajen fuera de la secuencia establecida.

**4. ¿Por qué las operaciones de multiplicación y división requieren señales `start` y `done`?**

Porque estas operaciones se implementan mediante módulos secuenciales que necesitan varios ciclos de reloj para obtener el resultado. La señal `start` inicia el proceso y `done` indica que la operación terminó y que el resultado está disponible para continuar con la ejecución.

**5. ¿Cuál es la función del contador de programa (PC)?**

El PC almacena la dirección de la siguiente instrucción que debe ejecutarse. Permite que el procesador recorra secuencialmente las instrucciones almacenadas en la memoria de programa.

**6. ¿Por qué es necesario realizar primero la simulación funcional antes de implementar el diseño en la FPGA?**

Porque la simulación permite verificar el comportamiento lógico y temporal del procesador antes de trasladarlo al hardware. Esto facilita detectar errores en la unidad de control, las conexiones entre módulos y la ejecución de las instrucciones, reduciendo los problemas durante la implementación física.

---

## Conclusiones

- Se diseñó una arquitectura de procesador basada en un conjunto reducido de instrucciones de 16 bits, permitiendo comprender la relación entre el ISA, la unidad de control y el datapath.
- La implementación de una unidad de control mediante una máquina de estados permitió organizar las etapas de búsqueda, decodificación, ejecución y escritura de las instrucciones.
- La integración del banco de registros y la ALU permitió desarrollar operaciones aritméticas y lógicas sobre datos de 8 bits.
- La utilización de señales `start` y `done` permitió coordinar las operaciones secuenciales de multiplicación y división con la unidad de control.
- La incorporación del módulo UART permitió establecer una comunicación serial entre el procesador y un dispositivo externo.
- La simulación y la implementación en la FPGA permitieron verificar el funcionamiento del diseño y comprender la integración de los diferentes bloques que conforman un procesador.

---

## Referencias

- Digital ECCI. (2026). *Arquitectura de procesadores ECCI 2026-II: Laboratorio 05*. GitHub. https://github.com/digital-ECCI/Arquitetura_de_procesadores-ECCI-2026-II/tree/main/labs/05_lab05
- Harris, D. M., & Harris, S. L. (2012). *Digital Design and Computer Architecture*. Morgan Kaufmann.
- Brown, S., & Vranesic, Z. (2013). *Fundamentals of Digital Logic with Verilog Design*. McGraw-Hill.