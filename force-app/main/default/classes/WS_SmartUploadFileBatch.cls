/*
* ==============================================================================================================================
* @className        WS_SmartUploadFileBatch
* @description      Batch class to upload files
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/05/20
* ==============================================================================================================================
*/ 
global class WS_SmartUploadFileBatch implements Database.Batchable<WClassFiles>, Database.AllowsCallouts, Database.Stateful{
    public String caseId;
    public String file_type;
    public WS_SmartUploadFileBatch(String caseId){
        this.caseId = caseId;
    }
    
    global WS_SmartUploadFileBatch(String caseId, String file_type){
        this.caseId = caseId;
        this.file_type = file_type;
    }
    
    
    global Iterable<WClassFiles> start(Database.BatchableContext BC){
        String TIPO_FILE;
        if(file_type == null){
            TIPO_FILE = 'FINAL';
            //WS_SmartUploadFiles.createdRequestFuture(caseId, 'FINAL');
        }else{
            TIPO_FILE = file_type;
            //WS_SmartUploadFiles.createdRequestFuture(caseId, file_type);
        }
        
        //GET CASE DATA
        Case caso = [SELECT Id,Smart_code__c, CaseNumber, Status, RecordTypeId,Smart_Status__c FROM Case where id =: caseId limit 1 ];
        
        //Obtener codigo entidad y tipo entidad segun empresa
        String COD_ENTIDAD = WS_SmartSetClaim.getCodigoEntidad(Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName());
        String TIPO_ENTIDAD = WS_SmartSetClaim.getTipoEntidad(Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName());
        
        //get contentdocumentLinks
        List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId =: caso.Id];
        
        //get ContentDocumentId's
        set<Id> listContentDocuments = new set<Id>();
        for(ContentDocumentLink item: contentDocLinkList){
            listContentDocuments.add(item.ContentDocumentId);
        }
        
        //build key smartsupervision
        String codigo_queja = caso.Smart_code__c != null && caso.Smart_code__c != '' ? caso.Smart_code__c : TIPO_ENTIDAD + COD_ENTIDAD + caso.CaseNumber ;
        //makePostCallout(listContentDocuments, codigo_queja, caso, TIPO_FILE);
        
        List<ContentVersion> listContentVersion;
        List<ContentVersion> listContentVersion2;
        List<ContentVersion> listContentVersionUpdate = new List<ContentVersion>();
        List<Case> listCaseUpdate = new List<Case>();
        //get file blob
        if(TIPO_FILE == 'FINAL'){//Only get the last document
            listContentVersion = [SELECT Id,Title,FileType,FileExtension,VersionData,Es_Archivo_Final__c,ContentBodyId,ContentUrl,PathOnClient,ContentDocumentId,VersionNumber,estado_documento__c FROM ContentVersion WHERE ContentDocumentId IN:listContentDocuments AND IsLatest = True /*AND Es_Archivo_Final__c = True*/ ];
        	
            if(listContentVersion.size() == 0){
                caso.Smart_Status__c = 'FinalDocumentUpload-Error';
                update caso;
            }
        }else{
            listContentVersion = [SELECT Id,Title,FileType,FileExtension,VersionData,Es_Archivo_Final__c,ContentBodyId,ContentUrl,PathOnClient,ContentDocumentId,VersionNumber,estado_documento__c FROM ContentVersion WHERE ContentDocumentId IN:listContentDocuments AND IsLatest = True ];
        }
        system.debug('@@@ 4');
        System.debug('@@@ esto es r '+listContentVersion);
		List<WClassFiles> listaFilesW = new List<WClassFiles> ();
        for(ContentVersion content_version: listContentVersion){
            System.debug('@@@ titulo : '+content_version.Title);
            
            System.debug('@@@ antes del if');
            
            if(content_version.Es_Archivo_Final__c  && !content_version.Title.contains('RESP_FINAL_SFC')){
                System.debug('@@@ entro del if');
                content_version.Title = content_version.Title+'RESP_FINAL_SFC';
                content_version.Id=null;
                content_version.ContentBodyId=null;
                //content_version.IsMajorVersion=true;
                content_version.estado_documento__c='final-'; 
                insert content_version;
                listContentVersion2 = [SELECT Id,Title,FileType,FileExtension,VersionData,Es_Archivo_Final__c,ContentBodyId,ContentUrl,PathOnClient,ContentDocumentId,VersionNumber,estado_documento__c FROM ContentVersion WHERE ContentDocumentId IN:listContentDocuments AND IsLatest = True AND Es_Archivo_Final__c = True AND Title=:content_version.Title];
                if(!listContentVersion2[0].estado_documento__c.contains('enviado')){
                    listaFilesW.add(new WClassFiles(caso, listContentVersion2[0].Id, codigo_queja, TIPO_FILE ));     
                }
                
            }else{
                
                System.debug('@@@ otraaa '+content_version.estado_documento__c);
                try{
                    System.debug('@@@ hhhh ');
                    if(!content_version.estado_documento__c.contains('enviado')){
                        System.debug('@@@ ggg ');
                        listaFilesW.add(new WClassFiles(caso, content_version.Id, codigo_queja, TIPO_FILE ));
                    }
                }catch(Exception e ){
                    System.debug('@@@ lll ');
                    listaFilesW.add(new WClassFiles(caso, content_version.Id, codigo_queja, TIPO_FILE ));
                }
                
            }
        }
        
        return listaFilesW;
    }
    
    global void execute(Database.BatchableContext BC, List<Object> scope){
        system.debug('=====  WS_SmartUploadFileBatch execute ====');
        List<WClassFiles> lstWrap = (List<WClassFiles>)scope;
        system.debug('scope:' + scope);
        for(WClassFiles file: lstWrap){
        	System.enqueueJob(new WS_SmartUploadFiles(file.caso, file.content_version_id, file.codigo_queja, file.TIPO_FILE));
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('=== WS_SmartUploadFileBatch Finish ===');
    }
    
    
    //========== WRAPER ======
    public class WClassFiles {
        public Case caso;
        public String content_version_id;
        public String codigo_queja;
        public String TIPO_FILE;
        
        public WClassFiles(Case caso, String content, String queja, String file){
            this.caso = caso;
            this.content_version_id = content;
            this.codigo_queja = queja;
            this.TIPO_FILE = file;
        }
    }
}