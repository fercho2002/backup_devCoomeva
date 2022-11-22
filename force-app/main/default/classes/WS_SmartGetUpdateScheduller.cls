/*
* ===================================================================================
* @className        WS_SmartGetUpdateScheduller
* @description      clase programada para obtener las Actualizaciones desde la super.
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/11/20
* ==============================================================================================================================
*/ 
global class WS_SmartGetUpdateScheduller implements Schedulable{
    global void execute(SchedulableContext SC) {
        DataBase.executeBatch(new WS_SmartGetUpdateBatch('CMV_TipoRegistroBancoomeva'), 1) ;
        DataBase.executeBatch(new WS_SmartGetUpdateBatch('CMV_TipoRegistroFiducoomeva'), 1);
        DataBase.executeBatch(new WS_SmartGetUpdateBatch('CMV_TipoRegistroCorredoresSeguros'), 1);
    }
    
}