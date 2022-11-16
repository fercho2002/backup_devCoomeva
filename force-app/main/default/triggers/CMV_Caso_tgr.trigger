/************************************************************************************************
Desarrollado por:  Avanxo
Autor:             Andrés Garrido (AG)
Proyecto:          Coomeva CRM
Descripción:       Trigger para el objeto Casos

Cambios (Versiones)
-------------------------------------------------------------------------------------------------
No.     Fecha                  Autor                                 Descripción
----------  -------------   ----------------------  ---------------------------------------------
1.0     22/01/2020         Andrés Garrido (AG)         Creación Clase.
2.0     05/02/2020         Daniel Murcia Suarez (DMS)  Actualización de la clase para el PDF de Respuesta final  
3.0     21/01/2021         Nancy Huitrón               Envío de trigger.oldMap en el call a completarANSNivel1y2()
************************************************************************************************/
trigger CMV_Caso_tgr on Case (before insert, after insert, before update, after update, after delete) {
    if(trigger.isBefore){
        if(trigger.isUpdate){
            CMV_CasoHandler_cls.actualizarCampoEmpresa(trigger.new, trigger.old);
            //CMV_CasoHandler_cls.completarANSNivel1y2(trigger.oldMap, trigger.new, false);
            CMV_CasoHandler_cls.completarANSNivel1y2(trigger.old, trigger.new, false);
            if (trigger.new[0].Status=='1' && trigger.new[0].Status != trigger.old[0].Status){
                //CMV_CasoHandler_cls.setDataResponse(trigger.new);
            }
        }
        if(trigger.isInsert) {
            CMV_CasoHandler_cls.actualizarCampoEmpresa(trigger.new, trigger.old);
        }
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
        if(Trigger.isDelete){
            CMV_AlertasCasos_cls.validarYEnviarAlertas(Trigger.old);
        }else{
            CMV_AlertasCasos_cls.validarYEnviarAlertas(Trigger.new);
            
            //============== INTEGRACION SMARTSUPERVISION ===========
            CMV_CasoHandler_cls.SmartSupervisionHandler(Trigger.new, Trigger.oldMap);
        }
        
    }
}
//la cubre la clase CMV_testClassProjectPDF testmethod1 a un 100%