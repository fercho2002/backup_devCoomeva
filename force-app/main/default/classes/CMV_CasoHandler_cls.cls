/************************************************************************************************
Desarrollado por:  Avanxo
Autor:             Andrés Garrido (AG)
Proyecto:          Coomeva CRM
Descripción:       Clase para controlar los métodos que se ejecutan en el trigger de Casos

Cambios (Versiones)
-------------------------------------------------------------------------------------------------
    No.     Fecha                  Autor                                 Descripción
----------  -------------   ----------------------  ---------------------------------------------
    1.0     22/1/20             Andrés Garrido (AG)                     Creación Clase.
    2.0     07/02/20            Daniel Murcia Suarez (DMS)              Se agrega la lógica para
                                                                        la creacioón del PDF de
                                                                        Respuesta.
************************************************************************************************/
public class CMV_CasoHandler_cls {
    string recordTypeSP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GAM_SectorProteccion').getRecordTypeId();
    string recordTypeRTC = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('GAM_Retenciones').getRecordTypeId();
    String var1Dev = '';
    String var2Dev = '';
    List<Case> casDev = new List<Case>();
    public CMV_CasoHandler_cls() {
	
    }
    
    public static void completarANSNivel1y2(list<Case> lstOldCase, list<Case> lstNewCase, Boolean blnTipificado){
        String strANSNombre = '';
        String strANSNombre1 = '';
        String oldCas = '';
        CMV_infoPdfCloseCase__mdt pdfErr = new CMV_infoPdfCloseCase__mdt();
        List<Case> newCases =  new List<Case>();
        DateTime dteCompletedDate;
        Integer contadorNuevos = 0;
        set<String> setNombresANS = new set<String>();
        //Cuando el caso se tipifica
        System.debug('lstNewCase[0].Status: ' + lstNewCase[0].Status);
        if(!lstOldCase[0].CMV_Tipificado__c && lstNewCase[0].CMV_Tipificado__c || blnTipificado){
            strANSNombre = Label.CMV_EtiquetaANSN1;
            setNombresANS.add(Label.CMV_EtiquetaANSN1);
            dteCompletedDate = Datetime.now();
        }
        //Cuando el caso pasa a estado Cerrado
        else if(lstOldCase[0].Status != '1' && lstNewCase[0].Status == '1'){
            strANSNombre = Label.CMV_EtiquetaANSN2;
            strANSNombre1 = Label.CMV_EtiquetaANSN4;
            setNombresANS.add(Label.CMV_EtiquetaANSN2);
            setNombresANS.add(Label.CMV_EtiquetaANSN3);
            setNombresANS.add(Label.CMV_EtiquetaANSN4);
            list<BusinessHours> lstBussinesHour = [Select Id From BusinessHours Where Name = 'Default'];
            
            lstNewCase[0].CMV_DiasLaboralesSolicitudGestion__c = CMV_Utils_ctr.calcularDiasHabiles(lstNewCase[0].CMV_FechaSolicitudGestion__c, lstNewCase[0].ClosedDate, lstBussinesHour[0].Id);
            lstNewCase[0].CMV_DiasLaboralesRespuesta__c = CMV_Utils_ctr.calcularDiasHabiles(lstNewCase[0].CreatedDate, lstNewCase[0].ClosedDate, lstBussinesHour[0].Id);
            dteCompletedDate = Datetime.now();
            actualizarSolicitudes(lstNewCase[0].Id);
        }
        //Cuando el caso pasa a estado En Gestión
        else if(lstOldCase[0].Status != '16' && lstNewCase[0].Status == '16'){
            setNombresANS.add(Label.CMV_EtiquetaANSN3);
            dteCompletedDate = Datetime.now();
        }
        //Cuando el caso pasa a estado Anulado
        else if(lstOldCase[0].Status != '0' && lstNewCase[0].Status == '0'){
            setNombresANS.add(Label.CMV_EtiquetaANSN2);
            setNombresANS.add(Label.CMV_EtiquetaANSN3);
            setNombresANS.add(Label.CMV_EtiquetaANSN4);
            dteCompletedDate = Datetime.now();
        }
        //Cuando el caso pasa a estado Aprobación de Ampliación        
        else if(/*lstOldCase[0].Status != '14' && */lstNewCase[0].Status == '14' && !System.IsBatch() && !System.isFuture()){
            //lstNewCase[0].CMV_AmpliacionAprobada__c = true; 
            actualizarAmpliacion(lstNewCase[0].Id);
        }
        if(!setNombresANS.isEmpty()){
            list<CaseMilestone> lstCM = [
                Select  Id, CompletionDate 
                From    CaseMilestone 
                Where   CaseId = :lstNewCase[0].Id And CompletionDate = null And
                //(MilestoneType.Name = :strANSNombre Or MilestoneType.Name = :strANSNombre1)
                MilestoneType.Name = :setNombresANS
            ];
            if(!lstCM.isEmpty()){
                for(CaseMilestone objCaseMileStone : lstCM)
                    objCaseMileStone.CompletionDate = dteCompletedDate;
                
                update lstCM;
            }
        }
    	
    }
    //DMS Se crea el siguiente metodo el cual se encarga de la creación del PDF ademas
    //de marcar el Caso como completado y relacionar el PDF al caso.
    @InvocableMethod(label='CS_GenerarDocumento' description='Este metodo lo oy a llamar desde el flujo generar documento' category='Case')
    public static void setDataResponse(list<Case> caseObj){
        map<string,string> mRT = new map<string,string>();
        map<string,string> mRsDev = new map<string,string>();
        CMV_infoPdfCloseCase__mdt pdfAn = new CMV_infoPdfCloseCase__mdt();
        string recordTypeSP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GAM_SectorProteccion').getRecordTypeId();
    	string recordTypeRTC = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('GAM_Retenciones').getRecordTypeId();
        string firstValueCase = '';
        //---        if(lstNewCase[0].recordTypeId!=recordTypeSP && lstNewCase[0].recordTypeId!=recordTypeRTC){

        caseObj[0].CMV_closedBy__c=UserInfo.getUserId();
        if(caseObj[0].recordTypeId!=recordTypeSP && caseObj[0].recordTypeId!=recordTypeRTC){
            if (caseObj[0].CMV_NmeroIdentificacion__c!= null){
                system.debug('Ingreso a crear pdf con numero de identificacion');
                createPdfResponse( caseObj[0].Id, caseObj[0].caseNumber,caseObj[0].CMV_NmeroIdentificacion__c);
            }
            else{
                system.debug('Ingreso a crear pdf sin numero de identificacion');
                Contact idContact =[select Id , CMV_NumeroIdentificacion__c from Contact where Id =:caseObj[0].ContactId limit 1];
                createPdfResponse( caseObj[0].Id, caseObj[0].caseNumber,idContact.CMV_NumeroIdentificacion__c);
            }
        }
    }
    @Future(callout=true) 
    public static void createPdfResponse(Id idCase, String caseNum, String docNum){
          system.debug('*****Entra en createPdfResponse...');
            CMV_infoPdfCloseCase__mdt pdfInfo = new CMV_infoPdfCloseCase__mdt();
            CMV_infoPdfCloseCase__mdt pdfNew = new CMV_infoPdfCloseCase__mdt();
            contentVersion conVer = new ContentVersion();
            List<Case> oldCasDev = new List<Case>();
            String addValuesDev = '';
          
          //Feb2022 - Se requiere que si es respuesta parcial el formato del PDF sea distinto, se debe consultar el estado del caso en este metodo.
          Case casoRecibido = [Select Status , CMV_TipoRespuesta__c FROM CASE WHERE ID=:idCase];
          
            Pagereference vfpPdfClCase;                  
        
            if(casoRecibido.Status=='1'){
                system.debug('Se envia el formato de respuesta FINAL');
                //El formato es de respuesta final
                vfpPdfClCase = page.cmvPdfRespCloseCase;//new Pagereference('/apex/cmvPdfRespCloseCase?id='+idCase);
                pdfInfo =[SELECT Id, CMV_PDFName__c FROM CMV_infoPdfCloseCase__mdt WHERE CMV_TipoRespuesta__c='Definitiva' LIMIT 1];
            }else{
                system.debug('Se envia el formato de respuesta PARCIAL');
                //El formato es de respuesta parcial
                vfpPdfClCase = page.cmvPdfRespPartialCloseCase;//new Pagereference('/apex/cmvPdfRespCloseCase?id='+idCase);
                pdfInfo =[SELECT Id, CMV_PDFName__c FROM CMV_infoPdfCloseCase__mdt WHERE CMV_TipoRespuesta__c='Parcial' LIMIT 1];
            }
        
            vfpPdfClCase.getParameters().put('id', idCase);
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = pdfInfo.CMV_PDFName__c+caseNum+'.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title =  pdfInfo.CMV_PDFName__c+caseNum; // Display name of the files
            if(Test.isRunningTest()) { 
                blob pdfBody = blob.valueOf('Unit.Test');
                conVer.VersionData = pdfBody; 
              } else {
                conVer.VersionData = vfpPdfClCase.getContent(); //vfpPdfClCase.getContentAsPdf(); 
              }
             // converting your binary string to Blog
            conVer.FirstPublishLocationId = idCase; 
            if (conVer!= null){
                insert conVer;
                ContentDistribution objContentDist = new ContentDistribution();
                objContentDist.Name = pdfInfo.CMV_PDFName__c+caseNum;
                objContentDist.ContentVersionId = conVer.Id;
                objContentDist.PreferencesAllowViewInBrowser= true;
                objContentDist.PreferencesAllowViewInBrowser= true;
                objContentDist.PreferencesLinkLatestVersion=true;
                objContentDist.PreferencesNotifyOnVisit=false;
                objContentDist.PreferencesPasswordRequired=false;
                objContentDist.PreferencesAllowOriginalDownload= true;
                insert objContentDist;
                if (objContentDist!= null){
                    ContentDistribution cdUrl = [SELECT ContentVersionId, Name,DistributionPublicUrl FROM ContentDistribution where Id=:objContentDist.Id];
                    CMV_respuestaPdf__c respPdf =new CMV_respuestaPdf__c();
                    respPdf.CMV_casoRelacionado__c=idCase;
                    respPdf.CMV_urlPdf__c=cdUrl.DistributionPublicUrl;
                    respPdf.Name='RespuestaCaso'+caseNum;
                    respPdf.CMV_numeroDocumento__c=docNum;
                    insert respPdf;
                    //DGM (23/06/2020) se descomentariza parte de codigo.
                    if (respPdf!=null){
                        Case putCaseFlag =[SELECT Id,CMV_Envio_Respuesta_Final__c,Status, CMV_TipoRespuesta__c FROM Case where Id=:idCase];
                        if (putCaseFlag.Status != '1' && putCaseFlag.CMV_TipoRespuesta__c!='Parcial') {
                            putCaseFlag.CMV_Envio_Respuesta_Final__c=true;
                            Update putCaseFlag;
                            System.debug('respPdf******'+respPdf); 
                        }                       
                    }
            }
        }
        system.debug('*****Sale de createPdfResponse...');
    }
    
    @future
    public static void actualizarAmpliacion(String idCase){
        System.debug('idCase...............'+ idCase );
        String inEnv = '';
        list<Case> objCase = [Select Id,CMV_AmpliacionAprobada__c,CMV_MatrizTipificacion__r.CMV_ANSNivel2__c,CreatedDate, recordTypeId, CMV_QuienOriginoCaso__c, CMV_FechaMaximaAmpliacion__c, CMV_FechaMaximaRespuesta__c From Case Where Id = :idCase];
        String firstErr = '';
        List<Case> oldMapCaseDev = new List<Case>();
        Integer countValDev = 0;
        System.debug('objCase...............'+ objCase );
        if(!objCase.isEmpty()){
            objCase[0].CMV_AmpliacionAprobada__c = true;
            String rtCaseName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(objCase[0].recordTypeId).getDeveloperName();
            if (rtCaseName == 'CMV_TipoRegistroBancoomeva' && (objCase[0].CMV_QuienOriginoCaso__c == 'Defensoría' || objCase[0].CMV_QuienOriginoCaso__c == 'Superfinanciera')){
                objCase[0].CMV_FechaMaximaAmpliacion__c = CMV_Utils_ctr.calcularFechaANS(objCase[0].CMV_FechaMaximaAmpliacion__c, Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                objCase[0].CMV_FechaMaximaRespuesta__c = CMV_Utils_ctr.calcularFechaANS(objCase[0].CMV_FechaMaximaRespuesta__c, Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                System.debug('objCase[0].CMV_FechaMaximaAmpliacion__c...............'+ objCase[0].CMV_FechaMaximaAmpliacion__c );
                System.debug('objCase[0].CMV_FechaMaximaRespuesta__c...............'+ objCase[0].CMV_FechaMaximaRespuesta__c );                 
                 
            } Else If (objCase[0]!=null && objCase[0].CMV_MatrizTipificacion__r.CMV_ANSNivel2__c!=null) {
                Integer IntfchAns=objCase[0].CMV_MatrizTipificacion__r.CMV_ANSNivel2__c.intValue();
                System.debug('IntfchAns...............'+ IntfchAns );
                objCase[0].CMV_FechaMaximaAmpliacion__c = CMV_Utils_ctr.calcularFechaANS(objCase[0].CreatedDate,(Integer)IntfchAns*2);
                objCase[0].CMV_FechaMaximaRespuesta__c = CMV_Utils_ctr.calcularFechaANS(objCase[0].CreatedDate,(Integer)IntfchAns*2);
                System.debug('objCase[0].CMV_FechaMaximaAmpliacion__c...............'+ objCase[0].CMV_FechaMaximaAmpliacion__c );
                System.debug('objCase[0].CMV_FechaMaximaRespuesta__c...............'+ objCase[0].CMV_FechaMaximaRespuesta__c );                 
                 
            }            
            update objCase;
        }
    }
    
    //[AG:2020-13-08 Método para actualizar la fecha de respuesta de la soliciud cuando se cierra el caso]
    public static void actualizarSolicitudes(String idCase){
        Integer valueAccCont = 0;
      List<Case> listNewCasesMa = new List<Case>();  
      list<CMV_SolicitudGestion__c> lstSolicitudes = [
            Select   Id, CMV_Caso__c, CMV_FechaRespuesta__c
            From  CMV_SolicitudGestion__c
            Where  CMV_Caso__c = :idCase And CMV_FechaRespuesta__c = null
        ];    
        if(!lstSolicitudes.isEmpty()){
            for(CMV_SolicitudGestion__c objSol : lstSolicitudes)
                objSol.CMV_FechaRespuesta__c = DateTime.now();
            update lstSolicitudes;
        }
    }
    
    //[AG:2020-09-07 Método para asignar el campo empresa al caso dependiendo del tipo de registro]
    public static void actualizarCampoEmpresa(list<Case> lstNewCase, list<Case> lstOldCase){
        set<Id> setRTCasos = new set<Id>();
        map<String, String> mapRTXEmpresa = new map<String, String>();
        map<String, String> mapRTXDev = new map<String, String>();
        map<String, String> mapRTXValues = new map<String, String>();
        Integer contAcc = 0;
        
        for(Integer i=0; i<lstNewCase.size(); i++){
            if((lstNewCase[i].CMV_NombreEmpresa__c == null && lstNewCase[i].RecordTypeId != null) || (lstOldCase != null && lstOldCase[i].RecordTypeId != lstNewCase[i].RecordTypeId))
                setRTCasos.add(lstNewCase[i].RecordTypeId);  
        }
        if(!setRTCasos.isEmpty()){
            list<CMV_CasosTipoRegistroXEmpresa__mdt> lstConf = [
                Select   Id, CMV_IdTipoRegistroCaso__c, CMV_NitEmpresa__c, CMV_EsPersuasion__c  
                From  CMV_CasosTipoRegistroXEmpresa__mdt
                Where  CMV_IdTipoRegistroCaso__c = :setRTCasos
            ];
            for(CMV_CasosTipoRegistroXEmpresa__mdt objConf : lstConf)
                mapRTXEmpresa.put(objConf.CMV_IdTipoRegistroCaso__c, objConf.CMV_NitEmpresa__c);
            
            for(Integer i=0; i<lstNewCase.size(); i++){
                if((lstNewCase[i].CMV_NombreEmpresa__c == null && lstNewCase[i].RecordTypeId != null) || (lstOldCase != null && lstOldCase[i].RecordTypeId != lstNewCase[i].RecordTypeId) && mapRTXEmpresa.containsKey(lstNewCase[i].RecordTypeId))
                    lstNewCase[i].CMV_NombreEmpresa__c = mapRTXEmpresa.get(lstNewCase[i].RecordTypeId);
            }
        }
    }
    
    //20220201 Este método revisa si alguno de los casos tiene el campo “Quién originó el caso” con el valor de Defensoría o Superfinanciera, si es así sets caso.CMV_FechaMaximaRespuesta__c a 8 dias laborales después
    //En la configuración del entitlement está establecido los valores el tipo de registro de bancoomeva y el campo quien originó el caso
    //TODO: crear etiqueta para el record type y para los minutos
    public static void checkOriginoCaso(list<Case> lstNewCase, map<Id, Case> mapOldCases){
        system.debug('entrando a checkOriginoCaso');
        for (Case caso: lstNewCase){
            String rtCaseName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caso.recordTypeId).getDeveloperName();
            system.debug('rtCaseName: ' + rtCaseName);
            system.debug('CMV_FechaMaximaRespuesta__c: ' + caso.CMV_FechaMaximaRespuesta__c);
            system.debug('CMV_QuienOriginoCaso__c: ' + caso.CMV_QuienOriginoCaso__c);
            system.debug('caso.Status: ' + caso.Status);
            if (rtCaseName == 'CMV_TipoRegistroBancoomeva' /*&& caso.CMV_FechaMaximaRespuesta__c==null*/ && (caso.CMV_QuienOriginoCaso__c == 'Defensoría' || caso.CMV_QuienOriginoCaso__c == 'Superfinanciera')){
                if(caso.Status == '14'){
                    //caso.CMV_FechaMaximaRespuesta__c = CMV_Utils_ctr.calcularFechaANS(caso.CMV_FechaMaximaRespuesta__c, Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                    //caso.CMV_FechaMaximaAmpliacion__c = CMV_Utils_ctr.calcularFechaANS(caso.CMV_FechaMaximaAmpliacion__c, Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                } Else {                
                    if (caso.CreatedDate!=null){
                        caso.CMV_FechaMaximaRespuesta__c = CMV_Utils_ctr.calcularFechaANS(caso.CreatedDate, Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                        caso.CMV_FechaMaximaAmpliacion__c = CMV_Utils_ctr.calcularFechaANS(caso.CreatedDate, Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                    } else {
                        caso.CMV_FechaMaximaRespuesta__c = CMV_Utils_ctr.calcularFechaANS(Datetime.now(), Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp)); //11520 minutos a 8 horas x día son 8 días laborales
                        caso.CMV_FechaMaximaAmpliacion__c = CMV_Utils_ctr.calcularFechaANS(Datetime.now(), Integer.valueof(System.Label.CaseMinsDespuesCreacionFechaMaxResp));
                    }
                }
                system.debug('caso.CMV_FechaMaximaRespuesta__c: ' + caso.CMV_FechaMaximaRespuesta__c);
            }
        }
    }

    //=========================================================================================================
    //====================================   INTEGRACION SMART SUPERVISION ====================================
    //=========================================================================================================
    public static Boolean FIRSTRUN_AFTERUPDATE = true;
    public static void SmartSupervisionHandler(list<Case> updatedObjects,  Map<Id, Case> oldObjectMap){
        
        if (Trigger.isUpdate){
            id smartBanc = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
            id smartFidu = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroFiducoomeva').getRecordTypeId();
            id smartCorr = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroCorredoresSeguros').getRecordTypeId();
                       
            if (!System.isBatch() && !System.isFuture() && FIRSTRUN_AFTERUPDATE && !System.isQueueable()){

                system.debug('===1');
                for (Case item : updatedObjects){
                    //====== SmartSupervision ====== 
                    //====== Valida si pertene alguno de los tipos de registros que envia a smartSupervision ====== //
                    if (item.recordtypeid == smartBanc || item.recordtypeid == smartFidu || item.recordtypeid == smartCorr){
                        
                        system.debug('@@@ 1');
                        try{
                            if((oldObjectMap.get(item.Id).CS_Enviar_A_La_Super__c=='' || oldObjectMap.get(item.Id).CS_Enviar_A_La_Super__c==null ) && item.CS_Enviar_A_La_Super__c.contains('inicioenvio')){
                                system.debug('@@@ 2');
                                DataBase.executeBatch(new WS_SmartUploadFileBatch(item.Id, 'FINAL'), 1);
                            
                            }
                        }catch(Exception e ){
                            System.debug('esta nulo el campo ... ');
                        }
                        system.debug('==== SmartSupervision ====');
                        if ((item.Smart_Status__c == null || item.Smart_Status__c == '') && (item.CMV_Categoria__c == 'Queja' || item.CMV_Categoria__c == 'Reclamo')){
                            system.debug('==== SmartSupervision Created ===');
                            system.debug('===2');
                            IF(item.recordtypeid == smartCorr && (item.CMV_Linea__c == 'Seguros - Corredor' || item.CMV_Linea__c == 'Seguros Corredor-EC')){
                                WS_SmartSetClaim.createdRequestFuture(item.Id);
                            }else if(item.recordtypeid == smartBanc || item.recordtypeid == smartFidu){
                                WS_SmartSetClaim.createdRequestFuture(item.Id);
                            }                            
                            FIRSTRUN_AFTERUPDATE = false;
                        } else if (item.Status != oldObjectMap.get(item.Id).Status){
                            system.debug('===3');
                            if (item.Smart_Status__c != 'sendToSmart-Error' && (item.Smart_Status__c == 'sendToSmart-OK' || item.Smart_Status__c == 'SendUpdateSmart-OK' || item.Smart_Status__c == 'SendUpdateSmart-ERROR' || item.Smart_Status__c == 'reportACK-OK'  || item.Smart_Status__c == 'SendFinalDocument-OK' || item.Smart_Status__c == 'reportACKUPDATE-OK')){
                                if (item.Status == '1'){
                                    system.debug('===4');
                                    WS_SmartUpdateClaim.createdRequestFuture(item.Id);
                                    //DataBase.executeBatch(new WS_SmartUploadFileBatch(item.Id, 'ALL'), 1);
                                    FIRSTRUN_AFTERUPDATE = false;
                                } else{
                                    system.debug('===5');
                                    WS_SmartUpdateClaim.createdRequestFuture(item.Id);
                                    FIRSTRUN_AFTERUPDATE = false;
                                }
                            }
                        } else{
                            if (item.Smart_Status__c == 'sendToSmart-Error'){
                                system.debug('===6');
                                WS_SmartSetClaim.createdRequestFuture(item.Id);
                                FIRSTRUN_AFTERUPDATE = false;
                            } else{
                                system.debug('===7');
                                if (item.Smart_Status__c == 'SendUpdateSmart-Error' || item.Smart_Status__c == 'sendToSmart-OK'){
                                    system.debug('===8');
                                    WS_SmartUpdateClaim.createdRequestFuture(item.Id);
                                    FIRSTRUN_AFTERUPDATE = false;
                                } else{
                                    system.debug('===9');
                                    if (item.Status == '1' || item.Smart_Status__c == 'SendFinalDocument-Error'){
                                        system.debug('===10');
                                        system.debug('@@@ 3');
                                        DataBase.executeBatch(new WS_SmartUploadFileBatch(item.Id, 'FINAL'), 1);
                                        FIRSTRUN_AFTERUPDATE = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
//la cubre la clase CMV_testClassProjectPDF testmethod1 a un 81%