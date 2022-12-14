/*
* ==============================================================================================================================
* @className        WS_SmartGetUpdateBatch
* @description      batch para obtener las actualizaciones de informacion personal desde smartSupervision y  actualiza casos.
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/11/16
* ==============================================================================================================================
*/ 
global class WS_SmartGetUpdateBatch implements Database.Batchable<Claim>, Database.Stateful, Database.AllowsCallouts{
    List<String> listAccAck = new List<String>();
    global String CUSTOM_METADATA_NAME = 'WS_SMART_GET_UPDATE_CLAIMS';
    global String TIPO_EMPRESA;
    
    
    //Contructor
    global WS_SmartGetUpdateBatch(String TipoEmpresa){
        System.debug('@@@ contruc');
        this.TIPO_EMPRESA = TipoEmpresa;
    }
    
    //StartMethod
	global Iterable<Claim> start(Database.BatchableContext BC){
        system.debug('======start WS_SmartGetUpdateBatch:'+this.TIPO_EMPRESA+' =======' );   
        
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
    
    global void execute(Database.BatchableContext BC,List<object> scope){
        system.debug('======Execute WS_SmartGetUpdateBatch:'+this.TIPO_EMPRESA+' = =======' );
        
        List<Claim> lstWrap = (List<Claim>)scope;
        System.debug('@@@@@'+lstWrap.size());   
        List<Case> listCaseToUpdate = new List<Case>();
        List<Case> listCase;
        List<Case> caseO = new List<Case>();
        Map<String,Claim> mapNumber= new Map<String,Claim>();
        System.debug('@@@ este es el mapa '+mapNumber);
        
        //Claim correcto ;
        
        system.debug('@@@ este es el claim '+lstWrap);
        for(Claim claim: lstWrap){
            system.debug('=== usuario:' + claim);
            listAccAck.add(claim.numero_id_CF);
            mapNumber.put(claim.numero_id_CF,claim);
        } 
        caseO = [select id,SFC_Nombre__c,SFC_Apellido__c,SFC_Correo__c,SFC_Direccion__c,SFC_Fecha__c,SFC_Municipio__c,SFC_Razon_Social__c,SFC_Telefono__c,Smart_Status__c,Smart_Status_Detail__c,Account.CMV_NumeroIdentificacion__c from case where Account.CMV_NumeroIdentificacion__c IN: listAccAck AND RecordType.DeveloperName=:TIPO_EMPRESA AND ((Status != '1') OR (Status = '1' AND Smart_Status__c='SendUpdateSmart-Error' )) ];
        for(Case ca : caseO){
            System.debug('@@@---'+ca.id+'---'+ca.Account.CMV_NumeroIdentificacion__c);
        }
        if(caseO.size()>0){
            for(Case caseObj : caseO){
                try{
                Claim datos = mapNumber.get(caseObj.Account.CMV_NumeroIdentificacion__c);
                
                System.debug('@@ map '+datos.numero_id_CF);
                caseObj.SFC_Nombre__c=datos.nombre;
                caseObj.SFC_Apellido__c=datos.apellido;
                caseObj.SFC_Correo__c=datos.correo;
                caseObj.SFC_Direccion__c=datos.direccion;
                caseObj.SFC_Fecha__c= Date.valueOf(datos.fecha_nacimiento);
                caseObj.SFC_Municipio__c=WS_SmartGetClaimBatch.getPoblacion(datos.municipio_cod);
                caseObj.SFC_Razon_Social__c=datos.razon_social;
                caseObj.SFC_Telefono__c=datos.telefono;
                listCaseToUpdate.add(caseObj);
                }catch(Exception e){
                    System.debug('es null ');
                }
            }
        }        

        if(listCaseToUpdate.size()>0){
            try{
                update listCaseToUpdate;
            }catch(Exception e){
                System.debug('No se pudo actualizar los datos');
            }
            System.enqueueJob(new WS_SmartSetUpdateACK(listAccAck,listCaseToUpdate,TIPO_EMPRESA));
            
        }
        

       
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('======Finish WS_SmartGetUpdateBatch:'+this.TIPO_EMPRESA+' = =======' );   
        //Start dowload files batch
        if(!listAccAck.isEmpty()){
            try{
                senEmail(listAccAck);
            }catch(Exception e ){
                System.debug('No se pudo enviar el correo electronico');
            }    
        }

        system.debug('@@@ este es el final ');
        
    }
    
    public static void senEmail(List<String> num){
        if(num.size()>0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {'fernando.torres@vasslatam.com'};
            String myLabel = System.Label.AdminEmail;
            String[] toAddresses = new String[]{};
            toAddresses = myLabel.split(';');
            mail.setToAddresses(toAddresses);
            mail.setSubject('Usuarios actualizaron datos en SmartSuperVision');
            
            String messageBody = '<html><body><i><b>Usuarios</b></i><br/>'
                + '<p><i>'     
                + 'Se han identificado [' + num.size() + '] usuarios que actualizaron informacion  ';
                messageBody += '<br/> Acontinuacion los numero de identificacion de los usuarios que actualizaron informacion ';
            
            messageBody += '<table style="width:100%; border: 1px solid black; border-spacing: 0px;">';
            
            
            
            for (String str1 : num){
                
                
                messageBody += '<tr style="border: 1px solid black;  border-collapse: collapse;">';
                messageBody += '<td width="20%" style="border: 1px solid black;  border-collapse: collapse;">'+str1+'</td>';
                
            }

            messageBody += '</table>';
            messageBody += '<br/> NO RESPONDA Este mensaje. Es parte de un proceso de autom??tico';
            
            mail.setHtmlBody(messageBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }
    //=========================================================================
    //========================= WRAPPER RESPONSE CLASS ========================
    //=========================================================================
    public class Claim {
        public String numero_id_CF;
        public Integer tipo_id_CF;
        public String nombre;
        public String apellido;
        public String fecha_nacimiento;
        public String correo;
        public String telefono;
        public String razon_social;
        public String direccion;
        public String departamento_cod;
        public String municipio_cod;
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