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
El sistema consiste en una unidad aritmética combinacional de 4 bits capaz de realizar operaciones de adición y sustracción entre dos operandos binarios ($A$ y $B$). El circuito entrega la magnitud absoluta del resultado en un bus de 4 bits ($S[3:0]$) y el estado de acarreo/signo mediante una salida de 1 bit ($C_o$).

El diseño se estructura de forma modular en tres etapas jerárquicas:

1. **Sumador completo de 1 bit (`Sumador.v`):** Celda básica a nivel de compuertas lógicas (*Gate-Level*) que resuelve la suma de dos bits y un acarreo entrante:
   $$S = A \oplus B \oplus C_i$$
   $$C_o = (A \cdot B) + (C_i \cdot (A \oplus B))$$

2. **Sumador de 4 bits en cascada (`Sumador4.v`):** Estructura *Ripple Carry Adder* (RCA) que interconecta cuatro instancias del sumador elemental, propagando los acarreos intermedios ($c_1, c_2, c_3$) de la etapa menos significativa a la más significativa.

3. **Sumador / Restador con corrección de signo (`sumador_r.v`):**
   * **Inversión condicional:** El selector $C_i$ ($0 = \text{Suma}$, $1 = \text{Resta}$) conmuta compuertas XOR para generar el complemento a 1 de $B$, introduciendo a la vez $C_i = 1$ como acarreo inicial para formar el complemento a 2 ($A + \overline{B} + 1$).
   * **Detección de signo:** Se evalúa la condición de resta negativa mediante la compuerta combinacional:
     $$\text{cable\_es\_negativo} = C_i \cdot \overline{C_{o\_\text{intermedio}}}$$
   * **Ajuste de magnitud:** Si el resultado de una resta es negativo, el valor intermedio queda en complemento a 2. Una segunda etapa de cuatro compuertas XOR y cuatro sumadores de 1 bit invierte los bits y suma '1' automáticamente cuando `cable_es_negativo` está activo, entregando la magnitud corregida en $S[3:0]$ y marcando $C_o = 0$ como indicador de resultado negativo.

#### 1.2 Diagramas

![Fig-1. Diagrama circuital del sumador de 1 bit](/lab01/Diagramas/simulaciones/sumador_1bD.jpeg)  
*Fig-1. Diagrama lógico a nivel de compuertas del sumador completo de 1 bit.*

![Fig-2. Diagrama del sumador de 4 bits](/lab01/Diagramas/simulaciones/Sumador_4bD.jpeg)  
*Fig-2. Conexión en cascada (Ripple Carry Adder) de 4 bits.*

![Fig-3. Diagrama del sumador/restador de 4 bits](/lab01/Diagramas/simulaciones/sumador-r_4bD.jpeg)  
*Fig-3. Arquitectura del sumador/restador con bloque detector y corrector de complemento a 2.*

---

## Simulaciones 

### 1. Simulación del sumador/restador

#### 1.1 Descripción
El banco de pruebas exhaustivo (`sumador_r_tb.v`) valida todas las combinaciones posibles de entrada para $A$ y $B$ con retardos de $5\text{ ns}$ para asegurar la estabilidad de las señales:

* **Prueba de Suma ($C_i = 0$):** Comprueba adiciones estándar dentro del rango de 4 bits y transiciones con desbordamiento ($C_o = 1$).
* **Prueba de Resta Positiva ($C_i = 1, A \ge B$):** Valida sustracciones donde el resultado es mayor o igual a cero, entregando la resta directa en $S$ con $C_o = 1$ (indicador positivo).
* **Prueba de Resta Negativa ($C_i = 1, A < B$):** Comprueba operaciones donde el sustraendo es mayor al minuendo. Se verifica la activación de la etapa de corrección para entregar la magnitud positiva en $S$ y la bandera $C_o = 0$ (indicador negativo).

#### 1.2 Diagrama

![Fig-4. Simulación del Sumador de 1 bit](/lab01/Diagramas/simulaciones/Sim_1b.jpeg)  
*Fig-4. Formas de onda del sumador elemental de 1 bit para las 8 combinaciones de la tabla de verdad.*

![Fig-5. Simulación del Sumador de 4 bits](/lab01/Diagramas/simulaciones/Sim_4b.jpeg)  
*Fig-5. Simulación en GTKWave del sumador de 4 bits evaluando propagación de acarreos.*

![Fig-6. Simulación del Sumador/Restador de 4 bits](/lab01/Diagramas/simulaciones/Sim_r_4b.jpeg)  
*Fig-6. Formas de onda del sumador/restador verificando la detección de signo y corrección de magnitud.*

---

## Evidencias de implementación

* **Asignación de Pines en Tarjeta FPGA:**
  * Operando $A[3:0]$: Switches deslizantes `SW[3:0]`
  * Operando $B[3:0]$: Switches deslizantes `SW[7:4]`
  * Selector de Operación $C_i$: Switch deslizante `SW[8]`
  * Salida Magnitud $S[3:0]$: LEDs `LEDR[3:0]`
  * Salida Signo / Acarreo $C_o$: LED `LEDR[4]`

* **Video de Funcionamiento:** 


<video src="Video/Evidencia_lab1.mp4" controls width="100%">
  Tu navegador no admite la reproducción de este video.
</video>

---

## Preguntas

**1. ¿Cuál es la ventaja de utilizar un diseño jerárquico en Verilog frente a un solo archivo monolítico?**  
Permite validar y depurar individualmente cada bloque elemental (como el sumador de 1 bit) antes de su integración, garantizando la reutilización estructurada de hardware y facilitando la síntesis lógica.

**2. ¿Por qué es necesaria la segunda etapa de sumadores en el módulo `sumador_r.v`?**  
Porque al restar $A - B$ cuando $A < B$, el resultado se obtiene en formato complemento a 2. Para visualizar la magnitud absoluta en las salidas $S$, se requiere una etapa que reinvierta los bits y sume $+1$ de forma condicional.

---

## Conclusiones

* Se diseñó y verificó un sumador/restador combinacional de 4 bits en Verilog, resolviendo el manejo de magnitudes y signos en hardware sin recurrir a elementos secuenciales o de reloj.
* El uso de herramientas de código abierto (Icarus Verilog y GTKWave) facilitó el análisis temporal exhaustivo de los 512 casos de prueba antes de su implementación física en la tarjeta de desarrollo.
* La modularidad en HDL demostró ser fundamental para organizar proyectos escalables, facilitando la conexión en cascada y la incorporación de etapas de corrección aritmética.

---

## Referencias

* Harris, D. M., & Harris, S. L. (2012). *Digital Design and Computer Architecture*. Morgan Kaufmann.
* Brown, S., & Vranesic, Z. (2013). *Fundamentals of Digital Logic with Verilog Design*. McGraw-Hill.



