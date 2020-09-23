
####INSTALACIÓN Y CARGA DE PAQUETES####

#En esta sección se pueden instalar los paquetes requeridos descomentando las líneas##

#install.packages("RODBC");
#install.packages("dplyr");
#install.packages("rpart");
#install.packages("rpart.plot");
#install.packages("rpart");
#install.packages("readxl");

library(RODBC);
library(readxl);
library(dplyr);
library(rpart);
library(rpart.plot);
options(scipen=999)

##########CONEXIÓN A BASE DE DATOS##############

#En esta sección puedes conectarte a una base de datos si trabajas con algun repositorio similar al de el proyecto descomentando las líneas###

#conexion_repositorio<- odbcDriverConnect('driver={SQL Server};
#                                         server=dlyserver;
#                                         database=datamart_cobranzas_sql;
#                                         trusted_connection=true');
########### CONSULTA PRIMARIA DE DATOS##############

#En esta sección se obtienen los datos primarios, puedeas hacerlo desde una base de datos descomentando el código#

#consulta_repositorio<- sqlQuery(conexion_repositorio,paste0("SELECT PAGO_ID, PAGO_FECHA, PAGO_MONTO, FACTURA_ASOCIADA, FACTURA_FECHA, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR, NOMBRE_VENDEDOR, DIAS_DE_COBRO  FROM dbo.REGISTRO_PAGOS  WHERE FACTURA_FECHA >= '01/04/2019' AND ANULADO_COBRANZA = 0 AND ANULADO_POSTEO = 0 AND REVERSADO_COBRANZA = '' AND REVERSADO_POSTEO = '' AND DIAS_DE_COBRO >0  ")) ;
#odbcClose(conexion_repositorio);
#View(consulta_repositorio);#


#También puedes obtener los datos desde la hoja de excel que te dejo en el repositorio del proyecto##
consulta_repositorio <- read_excel("C:/Users/user/Desktop/pagos mantis.xlsx");
View(consulta_repositorio);




########### PRIMERA CLASIFICACIÓN GENERAL DE PAGOS###########

agrupamiento<- group_by_all(consulta_repositorio[,c(6:10)]);
clasificacion<- agrupamiento;
clasificacion$GRUPO <- ifelse(clasificacion$DIAS_DE_COBRO <= 5, "5 dias"
                              , ifelse(clasificacion$DIAS_DE_COBRO > 5 & clasificacion$DIAS_DE_COBRO <=9, "de 6 a 9 dias"
                                       , ifelse(clasificacion$DIAS_DE_COBRO >9 & clasificacion$DIAS_DE_COBRO <=11, "de 10 a 11 dias"
                                                , ifelse(clasificacion$DIAS_DE_COBRO >11 & clasificacion$DIAS_DE_COBRO <=15, "de 12 a 15 dias"
                                                         , ifelse(clasificacion$DIAS_DE_COBRO >15 &  clasificacion$DIAS_DE_COBRO <=18, "de 16 a 18 dias" ,"mas de 18 dias")))));
View(clasificacion);

##########SEGUNDA CLASIFICACIÓN GENERAL DE PAGOS###########
clasificacion$CINCO_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=5, 1,0);
clasificacion$NUEVE_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=9,1,0);
clasificacion$ONCE_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=11,1,0);
clasificacion$QUINCE_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=15, 1,0);
clasificacion$DIECIOCHO_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO <=18, 1,0);
clasificacion$MAS_DIECIOCHO_DIAS <- ifelse(clasificacion$DIAS_DE_COBRO !=0,1,0);


clasificacion2<-clasificacion[,-c(5,6)];
select_datos<- clasificacion2[,-c(5:10)];
View(clasificacion2);

##########AGRUPAMIENTO Y TOTALIZACIÓN#############

clasificacion_5dias<- clasificacion2[clasificacion2$CINCO_DIAS==1,-c(6:10)];
agrupamiento_5dias<-group_by(clasificacion_5dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, CINCO_DIAS);
pagos_5dias<- summarise(agrupamiento_5dias, N_PAGOS_5DIAS = n());
pagos_5dias<- pagos_5dias[,-5];

clasificacion_9dias<- clasificacion2[clasificacion2$NUEVE_DIAS==1,c(1:4,6)];
agrupamiento_9dias<-group_by(clasificacion_9dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, NUEVE_DIAS);
pagos_9dias<- summarise(agrupamiento_9dias, N_PAGOS_9DIAS = n());
pagos_9dias<- pagos_9dias[,-5];

clasificacion_11dias<- clasificacion2[clasificacion2$ONCE_DIAS==1,c(1:4,7)];
agrupamiento_11dias<-group_by(clasificacion_11dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, ONCE_DIAS);
pagos_11dias<- summarise(agrupamiento_11dias, N_PAGOS_11DIAS = n());
pagos_11dias<- pagos_11dias[,-5]

clasificacion_15dias<- clasificacion2[clasificacion2$QUINCE_DIAS==1,c(1:4,8)];
agrupamiento_15dias<-group_by(clasificacion_15dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, QUINCE_DIAS);
pagos_15dias<- summarise(agrupamiento_15dias, N_PAGOS_15DIAS = n());
pagos_15dias<- pagos_15dias[,-5]

clasificacion_18dias<- clasificacion2[clasificacion2$DIECIOCHO_DIAS==1,c(1:4,9)];
agrupamiento_18dias<-group_by(clasificacion_18dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, DIECIOCHO_DIAS);
pagos_18dias<- summarise(agrupamiento_18dias, N_PAGOS_18DIAS = n());
pagos_18dias<- pagos_18dias[,-5]

clasificacion_mas18dias<- clasificacion2[clasificacion2$MAS_DIECIOCHO_DIAS==1,c(1:4,10)];
agrupamiento_mas18dias<-group_by(clasificacion_mas18dias, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR, MAS_DIECIOCHO_DIAS);
pagos_mas18dias<- summarise(agrupamiento_mas18dias, N_PAGOS_MAS18DIAS = n());
pagos_mas18dias<- pagos_mas18dias[,-5]

agrupamiento_totales<-group_by(clasificacion2, CODIGO_CLIENTE, NOMBRE_CLIENTE, CODIGO_VENDEDOR,  NOMBRE_VENDEDOR);

totales<- summarise(agrupamiento_totales, TOTAL_PAGOS = n());
View(totales);

##########DETERMINACIÓN DE LA FRECUENCIA RELATIVA DE LOS GRUPOS DE PAGOS POR CLIENTE###########
select_datos2<-totales[,-5];
clasificacion_final<- merge(x = select_datos2, y =  pagos_5dias,  all.x = TRUE );
clasificacion_final<- merge(x = clasificacion_final, y = pagos_9dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_11dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_15dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_18dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = pagos_mas18dias, all.x = TRUE);
clasificacion_final<- merge(x = clasificacion_final, y = totales, all.x = TRUE);

clasificacion_final$N_PAGOS_5DIAS[is.na(clasificacion_final$N_PAGOS_5DIAS)] <- 0;
clasificacion_final$N_PAGOS_9DIAS[is.na(clasificacion_final$N_PAGOS_9DIAS)] <- 0;
clasificacion_final$N_PAGOS_11DIAS[is.na(clasificacion_final$N_PAGOS_11DIAS)] <- 0;
clasificacion_final$N_PAGOS_15DIAS[is.na(clasificacion_final$N_PAGOS_15DIAS)] <- 0;
clasificacion_final$N_PAGOS_18DIAS[is.na(clasificacion_final$N_PAGOS_18DIAS)] <- 0;
clasificacion_final$N_PAGOS_MAS18DIAS[is.na(clasificacion_final$N_PAGOS_MAS18DIAS)] <- 0;

clasificacion_final$PROPORCIONpagos_5dias <- clasificacion_final$N_PAGOS_5DIAS/ clasificacion_final$TOTAL_PAGOS;
clasificacion_final$PROPORCIONpagos_9dias <- clasificacion_final$N_PAGOS_9DIAS/ clasificacion_final$TOTAL_PAGOS;
clasificacion_final$PROPORCIONpagos_11dias <- clasificacion_final$N_PAGOS_11DIAS/ clasificacion_final$TOTAL_PAGOS;
clasificacion_final$PROPORCIONpagos_15dias <- clasificacion_final$N_PAGOS_15DIAS/ clasificacion_final$TOTAL_PAGOS;
clasificacion_final$PROPORCIONpagos_18dias <- clasificacion_final$N_PAGOS_18DIAS/ clasificacion_final$TOTAL_PAGOS;
clasificacion_final$PROPORCIONpagos_mas18dias <-clasificacion_final$N_PAGOS_MAS18DIAS/ clasificacion_final$TOTAL_PAGOS;

#CLASIFICACIÓN FINAL DE CLIENTES DE ACUERDO AL 95% DE SUS PAGOS#
clasificacion_final$TIPO_CLIENTE <- ifelse(clasificacion_final$PROPORCIONpagos_5dias >= 0.95, "Cliente A: a 5 dias"
                                           , ifelse(clasificacion_final$PROPORCIONpagos_5dias < 0.95 & clasificacion_final$PROPORCIONpagos_9dias >=0.95, "Cliente B: a 9 dias"
                                                    , ifelse(clasificacion_final$PROPORCIONpagos_9dias < 0.95 & clasificacion_final$PROPORCIONpagos_11dias >=0.95, "Cliente C: a 11 dias"
                                                             , ifelse(clasificacion_final$PROPORCIONpagos_11dias < 0.95 & clasificacion_final$PROPORCIONpagos_15dias >=0.95, "Cliente D: a 15 dias"
                                                                      , ifelse(clasificacion_final$PROPORCIONpagos_15dias < 0.95 & clasificacion_final$PROPORCIONpagos_18dias >=0.95, "Cliente E: a 18 dias","Cliente F: mas de 18 dias")))));

View(clasificacion_final);


####### MODELO DE ÁRBOL DE CLASIFICACIÓN PARA PRUEBAS#########
data_arbol<- clasificacion_final[,c(12:18)];
str(data_arbol);
View(data_arbol);
summary(data_arbol);
vector_datos<- sample(2,nrow(data_arbol), replace=TRUE, prob=c(0.6,0.4)); ###60% de entrnamiento y 40% de prueba###
data_entrenamiento<-data_arbol[vector_datos==1,];
data_prueba<-data_arbol[vector_datos==2,];
View(data_entrenamiento);
View(data_prueba);
modelo_entrenamiento<- rpart(TIPO_CLIENTE~.,method = "class", data = data_entrenamiento)
print(modelo_entrenamiento)

rpart.plot(modelo_entrenamiento);


####VERIFICACIÓN DE CALIDAD DEL MODELO, DETERMINACION DEL ERROR####
printcp(modelo_entrenamiento);
plotcp(modelo_entrenamiento);
######PREDICCION DE LAS CLASIFICACIONES EN LA DATA DE PRUEBA#######
prueba_modelo<- predict(modelo_entrenamiento, newdata = data_prueba, type = "class");
table(prueba_modelo, data_prueba$TIPO_CLIENTE);

######ESTADÍSTICA DEL MODELO######
(sum(prueba_modelo==data_prueba$TIPO_CLIENTE)/length(data_prueba$TIPO_CLIENTE))*100

