/*
* ==============================================================================================================================
* @className        WS_SmartGetClaimBatch
* @description      batch para obtener quejas desde smartSupervision y  crear casos.
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/05/06
* ==============================================================================================================================
*/ 
global class WS_SmartGetClaimBatch implements Database.Batchable<Claim>, Database.Stateful, Database.AllowsCallouts{
    global String CUSTOM_METADATA_NAME = 'WS_SMART_GET_CLAIMS';
    global String TIPO_EMPRESA;
    
    //Contructor
    global WS_SmartGetClaimBatch(String TipoEmpresa){
        this.TIPO_EMPRESA = TipoEmpresa;
    }
    
    //StartMethod
	global Iterable<Claim> start(Database.BatchableContext BC){
        system.debug('======start WS_SmartGetClaimBatch:'+this.TIPO_EMPRESA+' =======' );   
        
        List<Claim> claims = new List<Claim>();
        //======== Start REQUEST =========
        HTTPCalloutService service = new HTTPCalloutService(CUSTOM_METADATA_NAME);
        service.setHeaderParameter('Authorization', 'Bearer ' + WS_SmartLogin.getToken(TIPO_EMPRESA));
        String metadataString = service.getEndpointURL();
        service.setHeaderParameter('X-SFC-Signature', HTTPCalloutService.createSignature(metadataString));
        service.formHTTPRequest();
        system.debug(service.getRequest().getBody());
        
        //======== SEND REQUEST =========
        HttpResponse response;
        try{
            response = service.sendRequest();
        
        
            //Parse the JSON response
            Response resp = null;
            
            if (response.getStatusCode() != 200) {
                system.debug(' :: getStatus::: '+ response.getStatus());system.debug(' :: getStatusCode::: '+ response.getStatusCode());system.debug(' :: getBody::: '+ response.getBody());
            } else{
                system.debug(' :: getStatus::: '+ response.getStatus());system.debug(' :: getStatusCode::: '+ response.getStatusCode());system.debug(' :: getBody::: '+ response.getBody());
                try{
                    resp =  (Response) System.JSON.deserialize(response.getBody(), Response.class);
                    claims = resp.results;
                }catch(Exception ex){
                    System.debug('ERROR parser json response: ' + ex.getMessage());
                }
            } 
        }catch(Exception ex){
            system.debug('Error - send request :' + ex.getMessage());
        }    
        
        return claims;
    }
    
    global void execute(Database.BatchableContext BC, List<object> scope){
        system.debug('======Execute WS_SmartGetClaimBatch:'+this.TIPO_EMPRESA+' = =======' );   
        List<Claim> lstWrap = (List<Claim>)scope;
        List<Case> listCaseToInsert = new List<Case>();
        for(Claim claim: lstWrap){
            system.debug('=== Queja:' + claim);
            Case caso = new Case();
            
            //MOMENTO I: Casos Ya Existentes se obtienen adjuntos adicionales
            List<Case> listaCasosExistentes = new List<Case>();
            Boolean existeCaso = false;
            String keySearch ='';
            try{
                keySearch ='%'+claim.codigo_queja.right(8)+'%';
            }catch(Exception ex){}
            
            if(keySearch != ''){
                listaCasosExistentes = [SELECT Id, CaseNumber,Smart_code__c,Smart_Status__c,Status FROM Case WHERE Smart_code__c =: claim.codigo_queja OR CaseNumber LIKE:keySearch order by createdDate desc limit 1 ];
                existeCaso =  listaCasosExistentes.size() > 0 ? true : false;                
            }
            
            if(existeCaso && ((listaCasosExistentes[0].Status != '1') || (listaCasosExistentes[0].Status == '1' && listaCasosExistentes[0].Smart_Status__c=='SendUpdateSmart-Error' ))){//Si el caso ya existe obtiene adjuntos.
                system.debug('========= existequeja============' + listaCasosExistentes[0].Smart_code__c);
                WS_SmartGetFiles.createdRequest(listaCasosExistentes[0].Id);
            }else{
                system.debug('========= Ingresa a crear caso ============');
                caso.Smart_code__c = claim.codigo_queja;
                caso.Smart_status__c = 'Created';
                caso.entidad_cod__c = String.valueOf(claim.entidad_cod); //metadata
                caso.tipo_entidad__c = String.valueOf(claim.tipo_entidad);  //metadata
                system.debug('===1');
                try{
                    Datetime dt = Datetime.valueOf(claim.fecha_creacion.replace('T',' '));
                    caso.fecha_creacion__c = dt;
                }catch(Exception ex){
                    caso.fecha_creacion__c = datetime.now();
                }
                system.debug('===2');
                //account fields
                Account cuenta = getAccount(claim, TIPO_EMPRESA);
                caso.AccountId = cuenta.Id;
                system.debug('===3');
                Contact contact = getContact(claim, cuenta); 
                caso.ContactId = contact.Id; 
                system.debug('===4');
                //campos no mapeado
                //caso.Pais__c = getEquivalentValues('codigo_pais', claim.codigo_pais);
                //caso.Departamento__c = getEquivalentValues('departamento_cod', claim.departamento_cod);
                caso.CMV_CiudadRadicacion__c = getPoblacion(claim.municipio_cod);
                //caso.sexo = claim.sexo;
                //caso.lgbtiq = claim.lgbtiq;
                system.debug('===5');
                caso.canal_cod__c = String.valueOf(claim.canal_cod);
                caso.DireccionComplementariaSmartS__c = claim.direccion;
                system.debug('===6');
                caso.condicion_especial__c = String.valueOf(claim.condicion_especial);
                system.debug('===7');
                caso.smart_motivo__c = String.valueOf(claim.macro_motivo_cod);
                caso.smart_producto__c = String.valueOf(claim.producto_cod);                
                caso.CMV_DetalleCaso__c = claim.texto_queja;
                caso.anexo_queja__c = claim.anexo_queja;
                caso.Tutela__c = claim.tutela == 1 ? True : False;
                caso.CMV_QuienOriginoCaso__c = getEquivalentValues('ente_control', String.valueOf(claim.ente_control));
                caso.escalamiento_DCF__c = claim.escalamiento_DCF != null && claim.escalamiento_DCF == 1 ? True:False;
                caso.Replica__c =  claim.replica != null && claim.replica == 1 ? True:False;
                caso.argumento_replica__c = claim.argumento_replica;
                caso.desistimiento_queja__c = String.valueOf(claim.desistimiento_queja);
                caso.Queja_Express__c = claim.queja_expres != null && claim.queja_expres == 1 ? True:False;
                caso.Instancia_de_Recepcion__c = '1';
                
                //RecordType
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TIPO_EMPRESA).getRecordTypeId();
                caso.RecordTypeId = recordTypeId;
                
                //status smart
                if(claim.anexo_queja == False){
                    caso.Smart_Status__c = 'Created';
                    //caso.Smart_Status__c = 'FileDownload-OK';
                }else{
                    caso.Smart_Status__c = 'Created';
                }
                if(claim.replica == 1 && listaCasosExistentes.size() > 0){
					caso.ParentId = listaCasosExistentes[0].Id;    
                    caso.Smart_Status__c = 'Created';
                }
                listCaseToInsert.add(caso);
            }
                
        }
        
        system.debug('listCaseToInsert:' + listCaseToInsert);
        
        if(listCaseToInsert.size() > 0){
            system.debug(listCaseToInsert);
            Database.SaveResult[] srList = Database.insert(listCaseToInsert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList){
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('ERROR insert Case - Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('======Finish WS_SmartGetClaimBatch:'+this.TIPO_EMPRESA+' = =======' );   
        //Start dowload files batch
        if(!test.isRunningTest()){  DataBase.executeBatch(new WS_SmartGetFilesBatch(), 1); }
    }
    
    //=============================================================================================
    //==================================     UTILS       ==========================================
    //=============================================================================================
    
    public static String getEquivalentValues(String fieldName, String targetValue){
        //Create Locations Map
        Map<String, String> mapDeptosNameToCode = new Map<String, String>();
        Map<String, String> mapDeptosCodeToName = new Map<String, String>();
        Map<String, String> mapMuniNameToCode = new Map<String, String>();
        Map<String, String> mapMuniCodeToName = new Map<String, String>();
        for(Schema.Location item : [SELECT Id, Name, /*CodDepartment__c,*/ LocationType,ExternalReference FROM Location WHERE LocationType IN ('MUN','DEP')]){
            if(item.LocationType == 'DEP'){
                mapDeptosNameToCode.put(item.Name, item.ExternalReference );
                mapDeptosCodeToName.put(item.ExternalReference, item.Name);
            }
            if(item.LocationType == 'MUN'){
                mapMuniNameToCode.put(item.Name, item.ExternalReference);
                mapMuniCodeToName.put(item.ExternalReference, item.Name);
            }
        }
        
        List<SmartSupervisionMapValues__mdt> ListMetadata = new List<SmartSupervisionMapValues__mdt>();
        SmartSupervisionMapValues__mdt metadata = null;
        String defaultValue = 'NA';
        ListMetadata = [
            SELECT FieldName__c,OriginValue__c,TargetValue__c
            FROM SmartSupervisionMapValues__mdt
            WHERE FieldName__c =: fieldName AND TargetValue__c =: targetValue LIMIT 1];
        
        if( ListMetadata.size() > 0 ){
             metadata = ListMetadata[0];
        }
       
        
        if((fieldName != 'codigo_pais' || fieldName != 'departamento_cod' || fieldName != 'producto_cod' || fieldName != 'municipio_cod') & metadata != null){
            return metadata.OriginValue__c;
        }else{
            switch on fieldName { //DEFAULT VALUES
                when 'codigo_pais' {
                    //return mapDeptosNameToCode.get(targetValue) != null ? mapDeptosNameToCode.get(targetValue) : '';
                    return '170';
                }	
                when 'departamento_cod' {
					return mapDeptosCodeToName.get(targetValue) != null ? mapDeptosCodeToName.get(targetValue) : '00';
                } 
                when 'municipio_cod' {
                    //Id = [select id from CMV_Poblacion__c limit 1 ].id;
					return 'a0J74000000Bz6YEAS';
                }
                when 'producto_cod' {
                    return 'Otro';
                }
                when 'ente_control' {
                    return 'Sin definir';
                }
                when else {		  
                    return '00';
                }
            }
        }
    }
    
    public static Account getAccount(Claim claim, String tipoEmpresa){
        Account relatedAccount;
        List<Account> defaultAccount;
        defaultAccount = [SELECT Id, Name FROM Account WHERE CMV_NumeroIdentificacion__c =: claim.numero_id_CF limit 1];
        IF(defaultAccount.size() > 0){
            System.debug('Encontro cuenta' + defaultAccount);
            relatedAccount = defaultAccount[0];
                
        }else{
            System.debug('No encontro cuenta' + claim);
            relatedAccount = new Account();
            relatedAccount.LastName = claim.nombres;
            relatedAccount.CMV_NumeroIdentificacion__c = claim.numero_id_CF;
        	relatedAccount.CMV_TipoDocumento__c = getEquivalentValues('tipo_id_CF', String.valueOf(claim.tipo_id_CF));
            relatedAccount.Phone = claim.telefono;
            relatedAccount.PersonEmail = claim.correo;
        }
        try{
             upsert relatedAccount;
        }catch(Exception ex){
            system.debug('Error al actualizar cuenta - ' + ex.getMessage());
        }
        
        return relatedAccount;
    }
    
    public static Contact getContact(Claim claim, Account cuenta){
        Contact relatedContac;
		List<Contact> ExistingContact = new List<Contact>();
        
        //Search for existing contact
		ExistingContact = [Select Id,FirstName,LastName,Email,Phone,MobilePhone,CMV_TipoDocumento__c,CMV_NumeroIdentificacion__c,Name from Contact where CMV_NumeroIdentificacion__c =: claim.numero_id_CF AND recordtype.DeveloperName != 'Tipo_Registro_Contacto_de_Gesti_n'];    
        
        //---
        if(ExistingContact.size() > 0){
            relatedContac = ExistingContact[0];
        }else{
            relatedContac = new Contact();
            relatedContac.LastName = claim.nombres;
            relatedContac.CMV_TipoDocumento__c = getEquivalentValues('tipo_id_CF', String.valueOf(claim.tipo_id_CF));
            relatedContac.CMV_NumeroIdentificacion__c = claim.numero_id_CF;
            relatedContac.Email = claim.correo;
            relatedContac.Phone = claim.telefono;
            relatedContac.AccountId = cuenta.Id;
        }
        
        try{
             upsert relatedContac;
        }catch(Exception ex){
            system.debug('Error al actualizar contacto - ' + ex.getMessage());
        }
        
        return relatedContac;
    }
    /* ------------- GETLOCATION ---------------------------*/
    public static id getPoblacion(string ciudad){
        id ciudadSistema;
        List<CMV_Poblacion__c> listPoblacion = [Select id,Name from CMV_Poblacion__c WHERE CMV_EsCiudad__c = true AND CMV_EsPoblado__c = false AND SmartCode__c =:ciudad];
        
        IF(listPoblacion.size() >0){
            System.debug('SE LE ASIGNO UN VALOR DEL SISTEMA, VALOR RECIBIDO: ' + ciudad);
            ciudadSistema = listPoblacion[0].id;
        }ELSE{
            System.debug('SE ASIGNO BOGOTÁ AL NO EXISTIR EN EL SISTEMA LO RECIBIDO, VALOR RECIBIDO: ' + ciudad);
            ciudadSistema= [Select id,Name from CMV_Poblacion__c WHERE CMV_EsCiudad__c = true AND CMV_EsPoblado__c = false AND SmartCode__c = '11001'].id;
        }
        return ciudadSistema;
    }
    
    
    public static CMV_MatrizTipificacion__c getProduct(Claim claim){
        List<CMV_MatrizTipificacion__c> listMatriz = new List<CMV_MatrizTipificacion__c>();
        listMatriz = [select Id, Smart_Motivo__c, SmartProductCode__c FROM CMV_MatrizTipificacion__c WHERE Smart_Motivo__c =:claim.macro_motivo_cod AND SmartProductCode__c =: claim.producto_cod LIMIT 1];
        if(listMatriz.isEmpty()){
            //Set default matriz
            return null;
        }else{
            return listMatriz[0];
        }
    }
    
    public static CMV_MatrizTipificacion__c getProductDefault(Claim claim){
        List<CMV_MatrizTipificacion__c> listMatriz = new List<CMV_MatrizTipificacion__c>();
        listMatriz = [select Id, Smart_Motivo__c, SmartProductCode__c FROM CMV_MatrizTipificacion__c WHERE CMV_NombreAsignacion__c = 'Default Smart Supervision' LIMIT 1];
        return listMatriz[0];
    }
    
    public static String getMothNameByNumber(Integer month){
        Integer newMonth = 0;
        if(month > 12){
            if(Math.Mod(month,12) == 0){
                newMonth = 12; 
            }else{
                newMonth= Math.Mod(month,12);
            }
        }else{
            newMonth = month;
        }
        String[] months = new String[] {'January','February','March','April','May','June','July','August','September','October','November','December'}; 
        return months[newMonth-1];
    }
    
    //=========================================================================
    //========================= WRAPPER RESPONSE CLASS ========================
    //=========================================================================
    public class Claim {
        public Integer tipo_entidad;
        public Integer entidad_cod;
        public String fecha_creacion;
        public String codigo_queja;
        public String codigo_pais;
        public String departamento_cod;
        public String municipio_cod;
        public String nombres;
        public Integer tipo_id_CF;
        public String numero_id_CF;
        public String telefono;
        public String correo;
        public String direccion;
        public Integer tipo_persona;
        public Integer sexo;
        public Integer lgbtiq;
        public Integer canal_cod;
        public Integer condicion_especial;
        public Integer producto_cod;
        public String producto_nombre;
        public Integer macro_motivo_cod;
        public String texto_queja;
        public Boolean anexo_queja;
        public Integer tutela;
        public Integer ente_control;
        public Integer escalamiento_DCF;
        public Integer replica;
        public String argumento_replica;
        public String desistimiento_queja;
        public Integer queja_expres;
    }
    
    public class Response {
        public Integer count;
        public Integer pages;
        public Integer current_page;
        public Object next;
        public Object previous;
        public List<Claim> results;
    }
}