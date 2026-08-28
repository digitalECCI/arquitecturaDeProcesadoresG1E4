# Lab01 - Sumador/Restador de 4 bits

# Integrantes
* [Daniel Penagos Castro](https://github.com/Daniel-Penagos)
* [Danilo Forero Rodriguez](https://github.com/jouseddaniloS)
* [Brayan Extidt Torres Gaona](https://github.com/BrayanExtidt)

# Informe

Indice:

1. [Documentación](#documentación-del-diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Evidencias de implementación](#evidencias-de-implementación)
4. [Preguntas](#preguntas)
5. [Conclusiones](#conclusiones)
6. [Referencias](#referencias)

---

## Documentación del diseño implementado

### 1. Sumador/Restador

#### 1.1 Descripción
El sistema consiste en una unidad aritmética combinacional de 4 bits capaz de realizar operaciones de adición y sustracción entre dos operandos binarios ($A$ y $B$). El circuito entrega como salida la magnitud absoluta del resultado en un bus de 4 bits ($S[3:0]$) y el estado del signo/acarreo a través de un indicador de 1 bit ($C_o$).

La arquitectura implementa una jerarquía modular estructurada en tres etapas principales:

1. **Sumador completo de 1 bit (`Sumador.v`):** Celda básica a nivel de compuertas lógicas (*Gate-Level*) que resuelve la suma aritmética de dos operandos y un acarreo entrante mediante las funciones booleanas:
   $$S = A \oplus B \oplus C_i$$
   $$C_o = (A \cdot B) + (C_i \cdot (A \oplus B))$$

2. **Sumador de 4 bits en cascada (`Sumador4.v`):** Estructura *Ripple Carry Adder* (RCA) conformada por cuatro instancias del sumador elemental, propagando los acarreos intermedios ($c_1, c_2, c_3$) de la etapa menos significativa hacia la más significativa.

3. **Sumador / Restador con corrección de signo (`sumador_r.v`):**
   * **Inversión condicional de operando:** Se emplea el selector $C_i$ ($0 = \text{Suma}$, $1 = \text{Resta}$) conectado a un arreglo de cuatro compuertas XOR. Cuando $C_i = 1$, la entrada $B$ se invierte a su complemento a 1 y se le suma el propio $C_i$ como acarreo inicial del primer sumador, obteniendo el complemento a 2 ($A + \overline{B} + 1$).
   * **Detección de signo:** Se evalúa la condición de diferencia negativa mediante la compuerta combinacional:
     $$\text{cable\_es\_negativo} = C_i \cdot \overline{C_{o\_\text{intermedio}}}$$
   * **Ajuste a magnitud absoluta:** Si el resultado de una resta es negativo, el bus intermedio se encuentra codificado en complemento a 2. Para presentarlo en magnitud natural, una segunda etapa de cuatro compuertas XOR y cuatro sumadores de 1 bit realiza la inversión y suma $+1$ cuando `cable_es_negativo` está en '1'. El indicador $C_o$ se mantiene en '0' para señalizar que el valor representado es negativo.

#### 1.2 Diagramas

![Fig-1. Diagrama del Sumador de 1 bit](img/diagrama_1bit.png)  
*Fig-1. Esquema circuital a nivel de compuertas del sumador elemental de 1 bit.*

![Fig-2. Diagrama del Sumador de 4 bits](img/diagrama_4bit.png)  
*Fig-2. Conexión en cascada (Ripple Carry Adder) de 4 bits.*

![Fig-3. Diagrama del Sumador/Restador de 4 bits](img/diagrama_restador.png)  
*Fig-3. Arquitectura del sumador/restador con detección de signo y corrección de complemento a 2.*

---

## Simulaciones 

### 1. Simulación del sumador/restador

#### 1.1 Descripción
El banco de pruebas exhaustivo (`sumador_r_tb.v`) evalúa los modos de suma y resta mediante bucles iterativos para cada combinación posible de entradas ($A, B \in [0, 15]$) con un tiempo de establecimiento de $5\text{ ns}$:

* **Modo Suma ($C_i = 0$):** Valida la adición sin acarreo de salida y con desbordamiento del bus de 4 bits ($C_o = 1$).
* **Modo Resta Positiva ($C_i = 1, A \ge B$):** Verifica restas donde el minuendo es mayor o igual al sustraendo. En estos casos, $C_o = 1$ indica resultado positivo y $S[3:0]$ entrega la diferencia directa.
* **Modo Resta Negativa ($C_i = 1, A < B$):** Verifica que cuando el minuendo es menor al sustraendo, el bit $C_o$ cae a '0' (indicando signo negativo) y la segunda etapa de corrección entrega la magnitud en positivo en $S[3:0]$.

#### 1.2 Diagrama

![Fig-4. Simulación del Sumador de 1 bit](C:\Users\Daniel Penagos\Documents\Arqui_informes\arquitecturaDeProcesadoresG1E4\lab01\Diagramas\simulaciones\Sim_1b.jpeg)  
*Fig-4. Formas de onda del sumador elemental de 1 bit.*

![Fig-5. Simulación del Sumador de 4 bits](C:\Users\Daniel Penagos\Documents\Arqui_informes\arquitecturaDeProcesadoresG1E4\lab01\Diagramas\simulaciones\Sim_4b.jpeg)  
*Fig-5. Verificación de sumas de 4 bits.*

![Fig-6. Simulación Restador Positivo](img/sim_resta_pos.png)  
*Fig-6. Operación de resta con $A \ge B$ mostrando resultado positivo ($C_o = 1$).*

![Fig-7. Simulación Restador Negativo](C:\Users\Daniel Penagos\Documents\Arqui_informes\arquitecturaDeProcesadoresG1E4\lab01\Diagramas\simulaciones\Sim_r_4b.jpeg)  
*Fig-7. Operación de resta con A < B mostrando magnitud corregida en S y bandera de negativo (Co = 0).*

---

## Evidencias de implementación

* **Asignación de Pines en Hardware:**
  * Operando A[3:0]: Switches deslizantes `SW[3:0]`
  * Operando B[3:0]: Switches deslizantes `SW[7:4]`
  * Selector de Operación Ci: Switch deslizante `SW[8]`
  * Bus de Salida S[3:0]: LEDs `LEDR[3:0]`
  * Bit de Signo / Acarreo Co: LED `LEDR[4]`

* **Registro de Funcionamiento en Físico:**

[Ver video demostrativo de funcionamiento en FPGA](C:\Users\Daniel Penagos\Documents\Arqui_informes\arquitecturaDeProcesadoresG1E4\lab01\Video\Evidencia_lab1.mp4)

> *Nota:* Si el reproductor local no carga directamente en el navegador, también puede visualizarse a través del siguiente enlace externo:  
> [https://drive.google.com/file/d/1vcCmo2qZ_rfSTeHfBvPskjX8-NudlteQ/view?usp=sharing](#)

---

## Preguntas

**1. ¿Por qué se utiliza una arquitectura modular y jerárquica en Verilog?**  
Permite validar y depurar de forma aislada cada bloque funcional básico (como el sumador de 1 bit), asegurando la reutilización de código confiable y facilitando la síntesis optimizada del diseño.

**2. ¿Cuál es el propósito de la segunda etapa de sumadores en el módulo `sumador_r.v`?**  
Cuando una resta genera un resultado negativo (A < B), el valor entregado por el sumador/restador estándar queda codificado en complemento a 2. La segunda etapa realiza una reconversión a magnitud absoluta invirtiendo los bits y sumando '1' únicamente cuando el resultado es negativo.

---

## Conclusiones

* La modularidad en HDL permitió estructurar una unidad aritmética completa de 4 bits a partir de celdas lógicas básicas, facilitando la verificación mediante simulaciones orientadas por eventos en Icarus Verilog y GTKWave.
* El circuito combinacional resuelve simultáneamente operaciones de adición y sustracción, logrando el desacoplamiento del signo y la magnitud mediante compuertas XOR y complementación condicional a nivel de hardware puro.
* La verificación mediante testbenches exhaustivos garantizó la estabilidad de las señales antes de la asignación de pines y su posterior programación física en la tarjeta de desarrollo.

---

## Referencias

* Harris, D. M., & Harris, S. L. (2012). *Digital Design and Computer Architecture*. Morgan Kaufmann.
* Brown, S., & Vranesic, Z. (2013). *Fundamentals of Digital Logic with Verilog Design*. McGraw-Hill.