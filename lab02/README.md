# Lab02 - Decodificador BCD a 7 segmentos y algoritmo Double Dabble

# Integrantes

* [Daniel Penagos Castro](...)
* [Danilo Forero Rodriguez](...)
* [Brayan Extidt Torres Gaona](...)

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
El BCD es un esquema de representacion numerica para que cada digito decimal se pueda codificar utilizando cuatro digitos binarios.Se utiliza en sistemas digitales donde se requieren operaciones aritmeticas decimales.

#### 1.1 Descripción
Diseñar un cotrolador para display 7 segmentos segun el tipo de display con su respectiva tabla de verdad  para una representacion hezadecimal en la cuales se debera convertir numeros binarios de 2 digitos BCD(unidades y decenas) y 1 bit de signo (0=positivo, 1= negativo) para asi visualizar el resultado del sumador restador de 4 bits en los display 7 segmentosque viene incluido en la FPGA

#### 1.2 Tabla de verdad
En BCD es un sistema de numeracion en el cual odemos representar cada numero decimal utilizando 4 bits de numeros binarios pero como solo hay 10 digitos en el sistema decimal para representarlos podemos hacer la combinacion de 4 bits binarios es decir:

![Tabla de verdad](Imagenes/Combinaciones4b-10.png)<br>
*Figura 1: Tabla de verdad de las combinaciones del decodificador BCD hasta 10.*

Para representar de forma binaria los numeros decimales del 10 al 15 pero con su respectiva representacion en el sistema hezadecima es de la siguiente forma:
![Tabla de verdad](Imagenes/Combinaciones4b-15.png)<br>
*Figura 2: Tabla de verdad de las combinaciones del decodificador BCD de 10 hasta 15.*


#### 1.3 Diseño en Verilog

...

#### 1.4 Diagramas

...

### 2. Conversión de binario a BCD mediante Double Dabble

#### 2.1 Descripción

...

#### 2.2 Funcionamiento del algoritmo

...

#### 2.3 Ejemplo de conversión

...

#### 2.4 Implementación en Verilog

...

### 3. Integración del sistema

#### 3.1 Descripción

...

#### 3.2 Funcionamiento

...

#### 3.3 Diagrama general

...

---

## Simulaciones

### 1. Simulación del decodificador BCD a 7 segmentos

#### 1.1 Descripción

...

#### 1.2 Diagrama

...

### 2. Simulación del algoritmo Double Dabble

...

### 3. Simulación del sistema completo

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

...

**2. ¿Cuál es la diferencia entre un display de ánodo común y uno de cátodo común?**

...

**3. ¿Por qué es necesario utilizar Double Dabble?**

...

**4. ¿Por qué el algoritmo suma 3 cuando un nibble es mayor o igual a 5?**

...

**5. ¿Qué ventaja tiene realizar esta conversión mediante hardware?**

...

---

## Conclusiones

* ...
* ...
* ...

---

## Referencias

* Harris, D. M., & Harris, S. L. ...
* Brown, S., & Vranesic, Z. ...
* Guía de laboratorio Lab02 ...