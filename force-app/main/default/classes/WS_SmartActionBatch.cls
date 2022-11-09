/*
* ==============================================================================================================================
* @className        WS_SmartSetClaimsBatch
* @description      batch para procesar gestiones con error al envio de las quejas a smartsupervision
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/04/20
* ==============================================================================================================================
*/ 
global class WS_SmartActionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    global List<String> smart_status_process{get;set;}
    
    global WS_SmartActionBatch(){ 
        smart_status_process = new List<String>();
        //smart_status_process.add('sendToSmart-Error');
        //smart_status_process.add('SendUpdateSmart-Error');
        smart_status_process.add('FinalDocumentUpload-Error');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('=====  start WS_SmartActionBatch ====');
        Date currentDate = date.today();
        String query = 'Select Id, CaseNumber,CreatedDate, Smart_Status__c, Smart_Status_Detail__c, Status FROM Case WHERE Smart_Status__c IN: smart_status_process' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
        system.debug('=====  execute WS_SmartActionBatch ====');
        system.debug('scope:' + scope);
        for(Case caso: scope){
            switch on caso.Smart_Status__c {
                when 'sendToSmart-Error' {
                    WS_SmartSetClaim.createdRequest(caso.Id);
                }	
                
                when 'SendUpdateSmart-Error'{
                     WS_SmartUpdateClaim.createdRequest(caso.Id);
                }
                
                when 'FinalDocumentUpload-Error' {		
                	System.enqueueJob(new WS_SmartUploadFileQueueable(caso.Id, 'FINAL'));
                }
                when else {
                    
                }
            }   
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('=== finish WS_SmartActionBatch ===');
    }
}