# Lab02 - Decodificador BCD a 7 segmentos y algoritmo Double Dabble

# Integrantes
* [Daniel Penagos Castro](https://github.com/Daniel-Penagos)
* [Danilo Forero Rodriguez](https://github.com/jouseddanilo)
* [Brayan Extidt Torres Gaona](https://github.com/BrayanExtidt)

# Informe

Indice:

1. [Documentación del diseño implementado](#documentación-del-diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Evidencias de implementación](#evidencias-de-implementación)
4. [Preguntas](#preguntas)
5. [Conclusiones](#conclusiones)
6. [Referencias](#referencias)

---

## Documentación del diseño implementado

### 1. Decodificador BCD a 7 segmentos
EEl BCD es un esquema de representacion numerica para que cada digito decimal se pueda codificar utilizando cuatro bits binarios. Se utiliza en sistemas digitales donde se requieren operaciones aritmeticas y representaciones decimales.

#### 1.1 Descripción
El diseño consiste en realizar un controlador para un display de 7 segmentos segun el tipo de display, utilizando su respectiva tabla de verdad para una representacion hexadecimal. El sistema permite convertir numeros binarios de 2 digitos BCD (unidades y decenas) y 1 bit de signo (0 = positivo, 1 = negativo), con el objetivo de visualizar el resultado del sumador/restador de 4 bits en los displays de 7 segmentos incluidos en la FPGA.

![Display7](Imagenes/Display7.png)<br>
*Figura 1: Arquitectura del Display 7 Segmentos*
#### 1.2 Tabla de verdad
En BCD es un sistema de numeracion en el cual podemos representar cada numero decimal utilizando 4 bits de numeros binarios. Como solo hay 10 digitos en el sistema decimal, del 0 al 9, solamente se utilizan 10 combinaciones de las 16 posibles combinaciones de 4 bits, es decir:

![Tabla de verdad](Imagenes/Combinaciones4b-10.png)<br>
*Figura 2: Tabla de verdad de las combinaciones del decodificador BCD hasta 10.*

Para representar de forma binaria los numeros decimales del 10 al 15 pero con su respectiva representacion en el sistema hexadecimal se utilizan las combinaciones restantes de 4 bits de la siguiente forma:


![Tabla de verdad](Imagenes/Combinaciones4b-15.png)<br>
*Figura 3: Tabla de verdad de las combinaciones del decodificador BCD de 10 hasta 15.*


#### 1.3 Diseño en Verilog

...

#### 1.4 Diagramas
Bloque funcional del diseño


![BLOQUEBDC](Imagenes/BloqueBDC.png)<br>
*Figura 4: Bloque del BCD*


Este es el diseño, sintentizacion e implementacion del display de 7 segmentos para que permita visualizar los numeros en representacion hexadecimal en uno de los displays de la FPGA.

### 2. Conversión de binario a BCD mediante Double Dabble
El algoritmo Double Dabble o Shift-and-Add-3 es un metodo matematico y logico que utiliza la electronica digital para convertir numeros binarios puros a la notacion BCD (Decimal Codificado en Binario).
#### 2.1 Descripción
Su funcionamiento consta de transformar una serie de numeros binarios en grupos independientes de 4 bits para que cada grupo pueda representar directamente un digito decimal del 0 al 9.

¿Por que se necesita? RTA: Las computadoras o circuitos procesan los datos de forma binaria natural, ya que es mas eficiente. Sin embargo, los humanos leemos los numeros en base 10 (decimal). Para mostrar un numero binario grande en pantalla, ya sea en un display de 7 segmentos o LCD, no podemos conectar directamente el binario. Necesitamos aislar las unidades, las decenas y las centenas.
#### 2.2 Funcionamiento del algoritmo
El proceso se basa en un registro que se divide en las columnas BCD necesarias (Centenas, Decenas y Unidades) a la izquierda y el numero binario original a la derecha. Se siguen dos reglas basicas en un ciclo repetitivo para cada bit que tenga el numero a convertir.

Para evaluar el Double Dabble se mira cada columna BCD de 4 bits de manera independiente. Si el valor de alguna columna es igual o mayor a 5, se le suma 3. Si es menor a 5 no se realiza ninguna modificacion.
Para realizar el desplazamiento (Double) se desplazan todos los bits un espacio hacia la izquierda y se introduce el siguiente bit del numero binario. Este proceso se repite hasta procesar todos los bits del numero a convertir.

#### 2.3 Ejemplo de conversión
El número tiene 4 bits, por lo que se necesitan 4 iteraciones.
El registro BCD tiene 2 grupos: [Decenas | Unidades]

Para entender el funcionamiento del algoritmo **Double Dabble** limitado a dos dígitos decimales, convertiremos el número binario de 7 bits `1010110` (que equivale al **86** en decimal) a formato **BCD**.

 Configuración Inicial:
* **Número Binario:** `1010110` (7 bits = realizaremos exactamente 7 desplazamientos).
* **Columnas BCD necesarias:** Decenas (4 bits) y Unidades (4 bits).

### Tabla de Estados del Algoritmo:

| Paso / Operación | Decenas (BCD) | Unidades (BCD) | Binario Inicial |
| :--- | :---: | :---: | :---: |
| **0. Estado Inicial** | `0000` | `0000` | `1010110` |
| 1. Desplazamiento 1 | `0000` | `0001` | `010110_` |
| 2. Desplazamiento 2 | `0000` | `0010` | `10110__` |
| 3. Desplazamiento 3 | `0000` | `0101` | `0110___` |
| *Evaluar:* Unidades es 5 (≥ 5) → **Sumar 3** | `0000` | **`1000`** | `0110___` |
| 4. Desplazamiento 4 | `0001` | `0000` | `110____` |
| 5. Desplazamiento 5 | `0010` | `0001` | `10_____` |
| 6. Desplazamiento 6 | `0100` | `0011` | `0______` |
| 7. Desplazamiento 7 (Final) | **`1000`** | **`0110`** | `_______` |

Resultado Final:
Al completarse los 7 desplazamientos, leemos directamente los bloques BCD resultantes:
* **Decenas:** `1000` = **8**
* **Unidades:** `0110` = **6**

El resultado en BCD es `1000 0110`, lo cual representa correctamente al número **86** en decimal.


#### 2.4 Implementación en Verilog

...

### 3. Integración del sistema

#### 3.1 Descripción

El sistema completo esta compuesto por el sumador/restador de 4 bits, el algoritmo Double Dabble y los decodificadores BCD a 7 segmentos. Estos bloques se integran para permitir que el resultado de la operacion realizada pueda ser visualizado de forma decimal en los displays de la FPGA.

#### 3.2 Funcionamiento

El funcionamiento comienza con los valores de entrada de los operandos y el selector que determina si se realiza una suma o una resta. El sumador/restador procesa estos valores y genera el resultado correspondiente junto con el bit de signo.

Posteriormente, el resultado binario es enviado al modulo Double Dabble, donde se realiza la conversion de binario a BCD. El resultado de esta conversion se divide en los diferentes digitos decimales, como unidades, decenas y centenas.

Finalmente, cada grupo BCD es enviado a su respectivo decodificador de 7 segmentos. Estos decodificadores generan las señales necesarias para activar los segmentos de los displays y mostrar visualmente el resultado de la operacion.

#### 3.3 Diagrama general

...

---

## Simulacion

### 1. Simulación del sistema completo

#### 1.2 Descripcion
Se realizo la simulacion del sistema completo, integrando el sumador/restador de 4 bits, el algoritmo Double Dabble y el decodificador BCD a 7 segmentos. En esta simulacion se comprobo el funcionamiento de los diferentes bloques de manera conjunta y se verifico que el resultado de la operacion realizada fuera convertido correctamente y mostrado en los displays de 7 segmentos.
### 1.3 Diagrama

...

---

## Evidencias de implementación

* **Asignación de pines en la FPGA:**
  * ...
  * ...
  * ...

* **Funcionamiento en la tarjeta:**

...

---

## Preguntas

**1. ¿Qué es BCD y por qué se utiliza en este diseño?**

BCD significa Decimal Codificado en Binario y es una forma de representar cada digito decimal utilizando 4 bits.Se utiliza en este diseño porque permite separar el resultado en unidades, decenas y centenas, haciendo posible conectar cada digito directamente con un decodificador de 7 segmentos para su visualizacion.

**2. ¿Cuál es la diferencia entre un display de ánodo común y uno de cátodo común?**

La principal diferencia esta en la forma en que se conectan los terminales comunes de los LEDs del display. En un display de catodo comun, los catodos estan conectados entre si y el segmento se activa aplicando un nivel logico alto. En un display de anodo comun, los anodos estan conectados entre si y el segmento se activa aplicando un nivel logico bajo.Por esta razon, al realizar el diseño en Verilog es necesario tener en cuenta el tipo de display utilizado, ya que las señales de activacion seran diferentes.

**3. ¿Por qué es necesario utilizar Double Dabble?**

Es necesario utilizar Double Dabble porque el resultado del sumador/restador se encuentra representado en binario, mientras que para mostrar el resultado en los displays de 7 segmentos se necesita separar el numero en sus diferentes digitos decimales,
Double Dabble permite realizar esta conversion de binario a BCD mediante desplazamientos y sumas, obteniendo las unidades, decenas y centenas que posteriormente pueden ser enviadas a los displays.

**4. ¿Por qué el algoritmo suma 3 cuando un nibble es mayor o igual a 5?**
Se suma 3 cuando un nibble tiene un valor mayor o igual a 5 porque los valores BCD validos solamente llegan hasta 9. La suma de 3 antes del desplazamiento permite realizar correctamente el acarreo hacia el siguiente digito decimal durante el proceso de conversion, De esta manera se evita que el resultado del desplazamiento produzca una representacion incorrecta en BCD y se permite continuar formando correctamente las decenas y centenas.

**5. ¿Qué ventaja tiene realizar esta conversión mediante hardware?**

Una de las principales ventajas de realizar la conversion mediante hardware es que el proceso puede ejecutarse directamente dentro de la FPGA utilizando circuitos logicos, sin depender de operaciones de division o multiplicacion realizadas mediante software, Esto permite realizar la conversion de manera rapida y eficiente, ademas de que los diferentes bloques pueden trabajar de forma integrada para generar directamente las señales necesarias para los displays de 7 segmentos.

## Conclusiones

* Se diseño e implemento un decodificador BCD a 7 segmentos capaz de recibir una entrada de 4 bits y generar las señales necesarias para representar los diferentes valores en el display.

* Se comprendio el funcionamiento del algoritmo Double Dabble como metodo para convertir un numero binario a su correspondiente representacion BCD, utilizando desplazamientos y la suma de 3 cuando es necesario.

* Se realizo la integracion entre el sumador/restador de 4 bits, el conversor Double Dabble y los decodificadores de 7 segmentos, permitiendo visualizar el resultado de las operaciones en los displays de la FPGA.

* Las simulaciones permitieron comprobar el funcionamiento de los diferentes bloques antes de realizar la implementacion fisica en la tarjeta de desarrollo.

---

**## Referencias**

* Lenovo. *Código decimal binario (BCD).* [Lenovo - Código decimal binario](https://www.lenovo.com/co/es/glosario/codigo-decimal-binario/?utm_source=chatgpt.com)

* Guía de laboratorio Lab02 - Decodificador BCD a 7 segmentos y algoritmo Double Dabble, Arquitectura de Procesadores ECCI.
