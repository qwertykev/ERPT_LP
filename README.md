# Estimación ERPT con Local Projections en R
## Autor: Kevin Corfield
### Repositorio creado para el curso intensivo de invierno 
#### Fecha de realización: Julio 2024

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

## ¿Qué es el Exchange-rate pass-through (ERPT)?

El ERPT es una medida macroeconómica que nos permite conocer en qué grado, una depreciación/devaluación se traslada como un aumento del nivel general de precios de una econommía.    

## ¿Cómo se estima el ERPT?

El ERPT se puede estimar de dos formas: Econometría o modelo teórico. Desde la econometría, se puede realizar la estimación con una regresión de series de tiempo, con un modelo SVAR/VEC o LP.
Sin embargo, hay que tener en cuenta las limitaciones de cada estrategia. Probablemente, la depreciación del tipo de cambio este precedida por un aumento de la tasa de inflación. 
En este sentido, hay razones para creer que hay simultaneidad entre tasa de inflación y variación del tipo de cambio nominal. 
Además, es posible que haya otros factores que influyan en la relación entre esas dos variables, por ejemplo mayor actividad económica podría promover una mayor intensidad en la actualización de precios frente a una depreciación del tipo de cambio
nominal. Para aislar el efecto debemos introducir controles en el modelo.

## Estrategia econométrica 

La especificación que utlizamos es la siguiente:

$$
p_{t+h}-p_{t-1} = a_h + \beta_h\Delta e_t + \sum_{j=1}^q \rho_{j,h} \Delta p_{t-j} + \sum_{j=1}^q \theta_{j,h} \Delta e_{t-j} + \mathbf{x}'\mu_h+ \epsilon_{i,t+h}
$$

donde $p_{t}$ es el logaritmo natural del índice de precios al consumidor construído a partir de un empalme entre el IPC INDEC e IPC San Luis, $\Delta e_t$ es la primera diferencia del
logaritmo del tipo de cambio nominal mayorista cuya fuente de información es BCRA. Finalmente, incluímos un único control, la brecha de producto (Output Gap) a partir de la serie EMAE
de INDEC desestacionalizada.

$ERPT_{t,t+h} = \frac{p_{t+h}-p_{t-1}}{\Delta e_t} = \beta_h$

![ERPT]([https://github.com/tu_usuario/tu_repositorio/blob/main/imagenes/ejemplo.png](https://github.com/qwertykev/ERPT_LP/blob/main/ERPT.svg))

