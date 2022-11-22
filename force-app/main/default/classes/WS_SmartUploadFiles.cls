/*
* ===================================================================================
* @className        HTTPCalloutServiceTest
* @description      http callout util
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/04/20
* ==============================================================================================================================
*/ 
public class WS_SmartUploadFiles  implements Queueable, Database.AllowsCallouts{
    public static String CUSTOM_METADATA_NAME = 'WS_SMART_SENDFILE';
    //public Static Integer MAX_FILES_UPLOAD = 1;
    
    Case caso;
    String content_version_id;
    String codigo_queja;
    String TIPO_FILE;
    public WS_SmartUploadFiles(Case caso, String content_version_id, String codigo_queja, String TIPO_FILE){
        this.caso = caso;
        this.content_version_id = content_version_id;
        this.codigo_queja = codigo_queja;
        this.TIPO_FILE = TIPO_FILE;
    }
    
    public void execute(QueueableContext context) {
        makePostCallout(this.caso, this.content_version_id, this.codigo_queja, this.TIPO_FILE);
    }
    
    public static void makePostCallout(Case caso, String content_version_id, String codigo_queja, String TIPO_FILE){
        system.debug('=== WS_SmartUploadFiles queable ===');
        system.debug('=== WS_SmartUploadFiles content_version_id:' + content_version_id);
        try{
            List<case> listCaseUpdate = new List<case>();
            List<case> listCaseUpdate2 = new List<case>();
            List<case> listCaseOtos = new List<case>();
            List<ContentVersion> listContentVersionUpdate = new List<ContentVersion>();
            List<ContentVersion> listContentVersion = [SELECT Id,Title,FileType,FileExtension,VersionData,Es_Archivo_Final__c,ContentBodyId,ContentUrl,PathOnClient,ContentDocumentId,VersionNumber,estado_documento__c FROM ContentVersion WHERE Id =: content_version_id  LIMIT 1];
            
            
            for(ContentVersion content_version : listContentVersion){
                    String metadataString = '{\"type\": \"'+content_version.FileExtension+'\", \"codigo_queja\": \"'+codigo_queja+'\"}';
                    system.debug('metadataString:' + metadataString);
                    Blob file = content_version.VersionData;
                    
                    //build body request
                    String BOUNDARY = 'wL36Yn8afVp8Ag7AmP8qZ0SA4n1v9T';
                    String DELIMITER = '\r\n--' + BOUNDARY + '\r\n';
                    String CLOSE_DELIMITER = '\r\n--' + BOUNDARY + '--';
                    String fileType = content_version.FileExtension;
                    String fileName = content_version.Title;
                    String otroName = 'Prueba';
                    
                    // ==== build formdata body ====
                    String metadataBodyHeader = DELIMITER + 'Content-Disposition: form-data; name="type";\r\n\r\n'
                        + fileType +''+ DELIMITER
                        + 'Content-Disposition: form-data; name="codigo_queja";\r\n\r\n'
                        + codigo_queja;
                    
                    
                    // =============== build file body ===============
                    String header_file = metadataBodyHeader + '\r\n' + '--' + BOUNDARY
                        +'\nContent-Disposition: form-data; name="file"; filename="'+fileName+'.'+fileType
                        + '";\nContent-Type: application/octet-stream';
                    
                    String footer = '--'+BOUNDARY+'--';             
                    String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header_file+'\r\n\r\n'));
                    while(headerEncoded.endsWith('='))
                    {
                        header_file+=' ';
                        headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header_file+'\r\n\r\n'));
                    }
                    
                    String bodyEncoded = EncodingUtil.base64Encode(file);
                    Blob bodyBlob = null;
                    String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
                    if(last4Bytes.endsWith('==')) {
                        last4Bytes = last4Bytes.substring(0,2) + '0K';
                        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
                    } else if(last4Bytes.endsWith('=')) {
                        last4Bytes = last4Bytes.substring(0,3) + 'N';
                        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                        footer = '\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
                    } else {
                        footer = '\r\n' + footer;
                        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
                    }
                    // =============== END build file body ===============
                    
                    //==========  INIT REQUEST ========
                    HTTPCalloutService service = new HTTPCalloutService(CUSTOM_METADATA_NAME);
                    service.setHeaderParameter('Authorization', 'Bearer ' + WS_SmartLogin.getToken(Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName()));
                    service.setHeaderParameter('X-SFC-Signature', HTTPCalloutService.createSignature(metadataString));
                    service.setRequestBodyAsBlob(BodyBlob);
                    service.setHeaderParameter('Content-length', String.valueOf(BodyBlob.size()));
                    //service.getRequest().setBodyAsBlob(BodyBlob);
                    service.formHTTPRequest();
                    system.debug(service.getRequest().toString());
                    system.debug(service.getRequest().getBody());
                    
                    //======== SEND REQUEST =========
                    HttpResponse response = service.sendRequest();
                    system.debug('@@@ 5');
                    if(response.getStatusCode()>199 && response.getStatusCode()<300 ){
                        system.debug('@@@ 6');
                        List<ContentVersion> listContentVersion2;
                        listContentVersion2 = [SELECT Id,Title,FileType,FileExtension,VersionData,Es_Archivo_Final__c,ContentBodyId,ContentUrl,PathOnClient,ContentDocumentId,VersionNumber,estado_documento__c FROM ContentVersion WHERE id =: content_version.id AND IsLatest = True];
                        listContentVersion2[0].Id=null;
                        listContentVersion2[0].ContentBodyId=null;
                        //listContentVersion2[0].IsMajorVersion=true;
                        listContentVersion2[0].estado_documento__c=listContentVersion2[0].estado_documento__c+'enviado';
                        listContentVersion2[0].Enviado_a_la_Super__c=true; 
                        insert listContentVersion2[0];
                        caso.tiene_respuesta_final__c=true;
                        caso.CS_Enviar_A_La_Super__c = '';
                        listCaseUpdate2.add(caso);
                        
                    }
                    system.debug(' :: getStatus::: '+ response.getStatus());
                    system.debug(' :: getStatusCode::: '+ response.getStatusCode());
                    system.debug(' :: getBody::: '+ response.getBody());   
                    
                    // Parse the JSON response
                    String status = '';
                    String caseEN = '';
                    String status_msj = '';
                	ResponseError resp;
                    if (response.getStatusCode() < 200 || response.getStatusCode() > 299) {
                        System.debug(response.getBody());   
                        String json = response.getBody();
                        resp = null;
                        try{
                            resp =  (ResponseError) System.JSON.deserialize(response.getBody(), ResponseError.class);
                        }catch(Exception ex){
                            System.debug('Error Parsing json resp: ' + ex.getMessage());
                        }
                        
                        if(TIPO_FILE == 'FINAL'){//Only get the last document
                            status = 'SendFinalDocument-Error';
                        }else{
                            status = 'SendDocument-Error';
                        }
                        status_msj = String.valueOf(response.getBody());
                    } else {
                        String json = response.getBody();
                        status_msj = 'Operación realizada correctamente.';
                        if(TIPO_FILE == 'FINAL'){//Only get the last document
                            status = 'SendFinalDocument-OK';
                        }else{
                            status = 'SendDocument-OK';
                        }
                    }
                    
                    //Adding content version status
                    //content_version.Status_SmartSupervision__c = status;
                    //listContentVersionUpdate.add(content_version);
                    
                    //Adding case statuss
                    if(TIPO_FILE == 'FINAL'){
                        caso.Smart_Status__c = status;
                        caso.Smart_Status_Detail__c = status_msj;
                        caso.CS_Enviar_A_La_Super__c = '';
                        listCaseUpdate.add(caso);
                        
                    }else{
                        caso.CS_Enviar_A_La_Super__c = '';
                        listCaseUpdate.add(caso); 
                    }
                    if(listCaseUpdate.size() > 0){
                        try{
                            update listCaseUpdate;
                        }catch(Exception ex){
                            system.debug('Error updating case status :' + ex.getMessage());
                        }
                    }
            }
            
            //updating contentversion status
            if(listContentVersionUpdate.size() > 0){
                try{
                    update listContentVersionUpdate;
                }catch(Exception ex){
                    system.debug('Error updating content version :' + ex.getMessage());
                }
            }
            
            //updating case status
            if(listCaseUpdate2.size() > 0){
                try{
                    update listCaseUpdate2;
                }catch(Exception ex){
                    system.debug('Error updating case status :' + ex.getMessage());
                }
            }
            
        }catch(Exception ex){
            System.debug('Error - '+ ex.getMessage());
        }
    }
    
    
    //=============================================================================================
    //==================================     WRAPPER CLASS       =================================
    //=============================================================================================
    //================ response wrapper class ============
    public class Message {
        public List<String> codigo_queja;
    }
    
    public class ResponseError {
        public Integer status_code;
        public Message message;
        public String detail;
    }
    @InvocableMethod(label='CS_GPrueba' description='Este metodo lprueba ' category='Case')
    public static void prueba(){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'my error msg');
        
    }
}