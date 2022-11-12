/*
* ===================================================================================
* @className        HTTPCalloutService
* @description      http callout util
* @author           vasslatam.com
* @version          V0.1 
* @testClass        WS_Smart_Test
* @dateCreated      2022/04/20
* ==============================================================================================================================
*/ 
global class WS_SmartUpdateClaim {
    public static String CUSTOM_METADATA_NAME = 'WS_SMART_UPDATE_CLAIM';
    
    
    @future (callout = true) 
    public Static void createdRequestFuture(String casoId){
        system.debug('==== WS_SmartUpdateClaim future=====');
        makePostCallout(casoId);
    }
    
    
    public Static void createdRequest(String casoId){
        system.debug('==== WS_SmartUpdateClaim =====');
        makePostCallout(casoId);
    } 
    
    
	public Static void makePostCallout(Id casoId){
        
        String result = '';
         List<Case> listCase = [SELECT Id, 
                               CaseNumber,
                               contactid,                               
                               condicion_especial__c,
                               canal_cod__c,
                               Status,
                               LastModifiedDate,
                               Producto_Digital__c,
                               CMV_RespuestaFavorDe__c,
                               Aceptacion__c,
                               CMV_MatrizTipificacion__c,
                               smart_producto__c,smart_motivo__c,
                                CMV_MatrizTipificacion__r.CMV_NombreAsignacion__c,
                               CMV_MatrizTipificacion__r.Smart_Motivo__c, 
                               CMV_MatrizTipificacion__r.SmartProductCode__c,
                               Rectificacion__c,
                               Desistimiento_queja__c,
                               Prorroga_Queja__c, 
                               Admision__c,
                               ClosedDate,
                               tutela__c,
                               CMV_QuienOriginoCaso__c,
                               Marcacion__c,
                               Queja_Express__c,
                               Smart_code__c,
                               Smart_Status__c,
                               Smart_Status_Detail__c,
                               RecordTypeId, CMV_ProductoSeguros__c
                               FROM CASE WHERE Id =: casoId limit 1];
        
        //Obtener codigo entidad y tipo entidad segun empresa 
        String COD_ENTIDAD = getCodigoEntidad(Schema.SObjectType.Case.getRecordTypeInfosById().get(listCase[0].RecordTypeId).getDeveloperName());
        String TIPO_ENTIDAD = getTipoEntidad(Schema.SObjectType.Case.getRecordTypeInfosById().get(listCase[0].RecordTypeId).getDeveloperName());
        Contact contact = getContact(listCase[0].contactid);
        String estado = WS_SmartSetClaim.getEquivalentValues('Estado',listCase[0].Status);
        String favor = WS_SmartSetClaim.getEquivalentValues('A_Favor',listCase[0].CMV_RespuestaFavorDe__c);
        String enteControl = WS_SmartSetClaim.getEquivalentValues('ente_control', String.valueOf(listCase[0].CMV_QuienOriginoCaso__c));
        //test body
        Body body =  new Body(); 
        body.codigo_queja =listCase[0].Smart_code__c != null && listCase[0].Smart_code__c != '' ? listCase[0].Smart_code__c :  TIPO_ENTIDAD + COD_ENTIDAD + listCase[0].CaseNumber;
       	body.sexo = !String.isblank(contact.Genero__c) ? Integer.valueof(contact.Genero__c)  : 10;
        body.lgbtiq = contact.LGBTIQ__c == True ? 1 : 2;
        body.condicion_especial = !String.isblank(listCase[0].condicion_especial__c) ? Integer.valueOF(listCase[0].condicion_especial__c) : 98;
        body.canal_cod = !String.isblank(listCase[0].canal_cod__c) ? Integer.valueOF(listCase[0].canal_cod__c) : 14; //Validar que valor deberia enviar si esta vacio
        
        /*if(listCase[0].CMV_MatrizTipificacion__c != null && listCase[0].CMV_MatrizTipificacion__r.CMV_NombreAsignacion__c == 'Default Smart Supervision'){
            body.producto_cod = Integer.valueOf(listCase[0].smart_producto__c);
        	body.Macro_motivo_cod = 907;//Integer.valueOf(listCase[0].smart_motivo__c);
        }else{*/
        //}
        if(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroCorredoresSeguros').getRecordTypeId() == listCase[0].RecordTypeId){
            body.producto_cod = listCase[0].CMV_ProductoSeguros__c != null ? WS_SmartSetClaim.getEquivalentValues('producto_cod', listCase[0].CMV_ProductoSeguros__c) != '00' ?  Integer.ValueOf(WS_SmartSetClaim.getEquivalentValues('producto_cod', listCase[0].CMV_ProductoSeguros__c)) : 198 : 198;
            system.debug('### producto corredor seguros: ' + body.producto_cod);
        }else{
            body.producto_cod = listCase[0].CMV_MatrizTipificacion__c != null ? Integer.valueOf(listCase[0].CMV_MatrizTipificacion__r.SmartProductCode__c) : null;//101; // Falta realizar las homologaciones 
            system.debug('### producto NO corredor seguros: ' + body.producto_cod);
        } 
        body.Macro_motivo_cod = listCase[0].CMV_MatrizTipificacion__c != null ? Integer.valueOf(listCase[0].CMV_MatrizTipificacion__r.Smart_Motivo__c) : null;//306; // Falta realizar las homologaciones
        
        body.Estado_cod = !String.isBlank(estado) ? Integer.valueof(estado) : 2; 
        body.fecha_actualizacion = listCase[0].LastModifiedDate.addHours(-24).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss'); //'2022-01-07T17:34:7';
        body.producto_digital = listCase[0].Producto_Digital__c == True ? 1 : 2;
        body.A_favor_de = !String.isBlank(favor) ? Integer.valueof(favor) : 3;
        body.aceptacion_queja = !String.isBlank(listCase[0].Aceptacion__c) ? Integer.valueof(listCase[0].Aceptacion__c) : null;
        body.rectificacion_queja = !String.isBlank(listCase[0].Rectificacion__c) ? Integer.valueof(listCase[0].Rectificacion__c) : null;
        body.desistimiento_queja = !String.isBlank(listCase[0].Desistimiento_queja__c) ? Integer.valueof(listCase[0].Desistimiento_queja__c) : null;
        body.prorroga_queja =String.isBlank(listCase[0].Prorroga_Queja__c)  ? null : Integer.valueOf(listCase[0].Prorroga_Queja__c);
        body.admision = !String.isBlank(listCase[0].Admision__c) ? Integer.valueof(listCase[0].Admision__c) : 9;
		//body.documentacion_rta_final = string.valueOf(True); 
		body.anexo_queja = string.valueOf(False);
        
        //Check if status is final
        if(listCase[0].Status == '1'){
            system.debug('=== final ===' + favor + listCase[0].ClosedDate);
            body.documentacion_rta_final = 'True';//String.ValueOf(getCountAnexosFinal(listCase[0].Id));
            body.fecha_cierre = !String.isBlank(String.valueof(listCase[0].ClosedDate)) ? listCase[0].ClosedDate.addHours(-24).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') : Null;//'2021-01-05T08:01:58';
            body.a_favor_de = !String.isBlank(favor) ? Integer.valueof(favor) : 3;
            body.anexo_queja = 'True';
            system.debug('=== valores Enviados ===' +  body.documentacion_rta_final + body.fecha_cierre + body.A_favor_de  + body.anexo_queja);
        }
        
        
        //body.fecha_cierre = !String.isBlank(String.valueof(listCase[0].ClosedDate)) ? listCase[0].ClosedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') : Null;//'2021-01-05T08:01:58';
        body.tutela = listCase[0].tutela__c == True ? 1 : 2;
        body.ente_control = !String.isBlank(enteControl) ? integer.valueof(enteControl) : 99;
        body.marcacion = !String.isBlank(listCase[0].Marcacion__c) ? integer.valueof(listCase[0].Marcacion__c) : NULL;
        body.queja_expres = listCase[0].Queja_Express__c == TRUE ? 1 : 2;
        
        //format json string
        String reqStr = JSON.serialize(body).replaceALL('":','": ').replaceALL(',',', ').replaceAll('"','\"');  
        makePostCallout(reqStr, body.codigo_queja, listCase[0]);
	}
 
    public static Void makePostCallout(String nRequest, String codigo_queja, Case caso) {
        //==========  INIT REQUEST ========
        HTTPCalloutService service = new HTTPCalloutService(CUSTOM_METADATA_NAME);
        service.setHeaderParameter('Authorization', 'Bearer ' + WS_SmartLogin.getToken(Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName()));
        service.setHeaderParameter('X-SFC-Signature', HTTPCalloutService.createSignature(nRequest));
        service.formHTTPRequest();
         //add header parameter
        service.setEndpointURL(service.getEndpointURL() + codigo_queja + '/');
        service.setRequestBody(nRequest);
        system.debug('=== REQUEST ===');
        system.debug('Endpoint:' + service.getEndpointURL());
        system.debug(service.getRequest().getBody());
        
        //======== SEND REQUEST =========
        try{
            HttpResponse response = service.sendRequest();
            
            system.debug('response status:' + response.getStatusCode());
            system.debug('response body:' + response.getBody());
            
            // Parse the JSON response
            String status = '';
            String status_msj = '';
            if (response.getStatusCode() < 200 || response.getStatusCode() > 299) {
                System.debug(response.getBody()); 
                ResponseError resp = null;
                 try{
                    resp =  (ResponseError) System.JSON.deserialize(response.getBody(), ResponseError.class);
                }catch(Exception ex){
                    System.debug('Error Parsing json resp: ' + ex.getMessage());
                }
                status = 'SendUpdateSmart-Error';
                status_msj = String.valueOf(response.getBody());
            } else {
                String json = response.getBody();
                status_msj = 'Operación realizada correctamente.';
                status = 'SendUpdateSmart-OK';
            }
            
            //update case status
            caso.Smart_Status__c = status;
            caso.Smart_Status_Detail__c = status_msj;
            try{
                update caso;
            }catch(Exception ex){
                system.debug('Error updating case :' + ex.getMessage());
            }
            system.debug('Estado' + Status);
            system.debug('Estado' + Caso.Smart_Status__c);
            if(status == 'SendUpdateSmart-OK' && caso.Status == '1'){
                //DataBase.executeBatch(new WS_SmartUploadFileBatch(caso.Id), 1);
                //System.enqueueJob(new WS_SmartUploadFileQueueable(caso.Id, 'FINAL'));
            }
        }catch(Exception ex){
            system.debug('Error - WS_SmartSetClaim: ');
            
        }
    }
    
    public static String getTipoEntidad(String tipoRegistro){
        Map<String, String> MAP_CUSTOM_METADATA_NAME = new Map<String, String>();
        MAP_CUSTOM_METADATA_NAME.put('CMV_TipoRegistroBancoomeva', 'WS_SMART_LOGIN_Bancoomeva');
        MAP_CUSTOM_METADATA_NAME.put('CMV_TipoRegistroFiducoomeva', 'WS_SMART_LOGIN_Fiducoomeva');
        MAP_CUSTOM_METADATA_NAME.put('CMV_TipoRegistroCorredoresSeguros', 'WS_SMART_LOGIN_Seguros');
        String TIPO_ENTIDAD = '';
        switch on tipoRegistro {
            when 'CMV_TipoRegistroBancoomeva' {	
                TIPO_ENTIDAD = HTTPCalloutConfiguration__mdt.getInstance('WS_SMART_LOGIN_Bancoomeva').TIPO_ENTIDAD__c;
            }	
            when 'CMV_TipoRegistroFiducoomeva' {
                TIPO_ENTIDAD = HTTPCalloutConfiguration__mdt.getInstance('WS_SMART_LOGIN_Fiducoomeva').TIPO_ENTIDAD__c;
            }
            when 'CMV_TipoRegistroCorredoresSeguros' {
                TIPO_ENTIDAD = HTTPCalloutConfiguration__mdt.getInstance('WS_SMART_LOGIN_Seguros').TIPO_ENTIDAD__c;
            }
        }
        return TIPO_ENTIDAD;
    }
    
    public static String getCodigoEntidad(String tipoRegistro){
        Map<String, String> MAP_CUSTOM_METADATA_NAME = new Map<String, String>();
        MAP_CUSTOM_METADATA_NAME.put('CMV_TipoRegistroBancoomeva', 'WS_SMART_LOGIN_Bancoomeva');
        MAP_CUSTOM_METADATA_NAME.put('CMV_TipoRegistroFiducoomeva', 'WS_SMART_LOGIN_Fiducoomeva');
        MAP_CUSTOM_METADATA_NAME.put('CMV_TipoRegistroCorredoresSeguros', 'WS_SMART_LOGIN_Seguros');
        String COD_ENTIDAD = '';
        switch on tipoRegistro {
            when 'CMV_TipoRegistroBancoomeva' {	
                COD_ENTIDAD = HTTPCalloutConfiguration__mdt.getInstance('WS_SMART_LOGIN_Bancoomeva').COD_ENTIDAD__c;
            }	
            when 'CMV_TipoRegistroFiducoomeva' {
                COD_ENTIDAD = HTTPCalloutConfiguration__mdt.getInstance('WS_SMART_LOGIN_Fiducoomeva').COD_ENTIDAD__c;
            }
            when 'CMV_TipoRegistroCorredoresSeguros' {
                COD_ENTIDAD = HTTPCalloutConfiguration__mdt.getInstance('WS_SMART_LOGIN_Seguros').COD_ENTIDAD__c;
            }
        }
        return COD_ENTIDAD;
    }
    public static Contact getContact(id contactId){
        
        Contact contacto = [SELECT id,Name,CMV_TipoDocumento__c,CMV_NumeroIdentificacion__c,Contact.Tipo_de_Persona__c,Genero__c,LGBTIQ__c,Email,Phone
                            FROM Contact WHERE id =: contactID];
        return contacto;
            
    }
    
    public static Boolean getCountAnexosFinal(String casoId){
        List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId =: casoId];
        
        //Se guardan los ContentDocumentId anteriores en una lista.
        set<Id> listContentDocuments = new set<Id>();
        for(ContentDocumentLink item: contentDocLinkList){
            listContentDocuments.add(item.ContentDocumentId);
        }
        
        List<ContentVersion> listaVersionsFinal = new List<ContentVersion>();
        listaVersionsFinal = [SELECT VersionData, Title FROM ContentVersion WHERE ContentDocumentId IN: listContentDocuments AND IsLatest = True AND Es_Archivo_Final__c = True  LIMIT 1 ];
        
        if(listaVersionsFinal.size() > 0){
            return True;
        }else{
            return False;
        }
    }
    
       
    global class Body {
        public String codigo_queja              {get;set;}
        public Integer sexo						{get;set;}
        public Integer lgbtiq					{get;set;}
        public Integer condicion_especial 		{get;set;}
        public Integer canal_cod				{get;set;}
        public Integer producto_cod				{get;set;}
        public Integer macro_motivo_cod			{get;set;}
        public Integer estado_cod				{get;set;}
        public String fecha_actualizacion		{get;set;}
        public Integer producto_digital 		{get;set;}
        public Integer a_favor_de				{get;set;}
        public Integer aceptacion_queja			{get;set;}
        public Integer rectificacion_queja		{get;set;}
        public Integer desistimiento_queja		{get;set;}
        public Integer prorroga_queja			{get;set;}
        public Integer admision					{get;set;}
        public String documentacion_rta_final	{get;set;}
        public String anexo_queja				{get;set;}
        public String fecha_cierre				{get;set;}
        public Integer tutela					{get;set;}
        public Integer ente_control				{get;set;}
        public Integer marcacion				{get;set;}
        public Integer queja_expres				{get;set;}
    }    
    
    //================ response wrapper class ============
    public class Message {
        public List<String> codigo_queja;
    }
    
    public class ResponseError {
        public Integer status_code;
        public Message message;
        public String detail;
    }
}