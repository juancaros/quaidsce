# quaidsce
Censored QUAIDS for Stata
version Octubre 2020  
Grace Melo, JC Salgado, JC Caro, J. Alberto Molina

Descripcion de los archivos en la carpeta **old quaidsce**:  

*quaids_ce.ado*: comando que empaqueta la funcion que estima el modelo de demanda via nlsur y luego calcula elasticidades (como objetos para bootstrap).  
*nlsurquaidsNN9c.ado*: comando que describe la funcion que nlsur toma para estimar.  
*elasticities_bootstrap.do*: ejemplo que corre la funcion **quaidsce** de una vez y via bootstrap (500 reps).  
*elasticities_delta.do*: ejemplo que corre la funcion **quaidsce** y estima las elasticidades via metodo delta (genera errores al usar nlcom con expresiones muy grandes).  

Descripcion de los archivos en la carpeta **quaids** (Poi, 2012):  

*quiads.ado*: comando que empaqueta  la funcion que estima el modelo de demanda via nlsur y usando mata recupera parametros y calcula postestimation results.  
*_quaids__utils.mata*: rutinas de mata para quiads, incluyendo aquella que escribe las funciones del sistema de demanda (equivalente a lo que se requiere para nlsurquaidsNN9c.ado).  
*nlsur_quaids.ado*: equivalente a nlsurquaidsNN9c.ado.  
*quaids_estat.ado*: elasticidades.  
*quaids_p.ado*: predicciones.  
*quaids.hlp*: ayuda.  
