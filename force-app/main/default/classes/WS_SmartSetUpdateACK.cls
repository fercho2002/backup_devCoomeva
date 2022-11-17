/*
* ==============================================================================================================================
* @className        WS_SmartSetUpdateACK
* @description      Procesar gestiones y marcarlas como recibido en smartsupervision
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/04/20
* ==============================================================================================================================
*/ 
global class WS_SmartSetUpdateACK implements Queueable, Database.AllowsCallouts{
    public static String CUSTOM_METADATA_NAME = 'WS_SMART_GET_UPDATE_ACK';

    list<String> Acc;
    list<Case> Cas;
    String TIPO_EMPRESA;

    global WS_SmartSetUpdateACK(list<String> Acc,list<Case> Cas,String TIPO_EMPRESA){
        this.Acc = Acc;
        this.Cas = cas;
        this.TIPO_EMPRESA = TIPO_EMPRESA;
    }

    global void execute(QueueableContext context) {
        initCallout(Acc,Cas,TIPO_EMPRESA);
    }
    
    public static void initCallout(list<String> Cuenta,list<Case> Caso,String EMPRESA){
        system.debug('=====  WS_SmartSetUpdateACK Callout====');
        List<String> listUsers = new List<String>();
        List<Case> caseUpdate = new List<Case>();
        
        
        for(String acc: Cuenta){
            listUsers.add('\"' + acc+ '\"');
        }
        

        String PersonToReport;
        if(listUsers.size() > 0){
            PersonToReport = '[' + String.join(listUsers, ', ') + ']';
        }
        String bodyString = '{"numero_id_CF": '+PersonToReport+'}';

        System.debug('@@@ este es el body del ack : '+bodyString);

        //==========  INIT REQUEST ========
        HTTPCalloutService service = new HTTPCalloutService(CUSTOM_METADATA_NAME);
        service.setHeaderParameter('Authorization', 'Bearer ' + WS_SmartLogin.getToken(EMPRESA));
        service.setHeaderParameter('X-SFC-Signature', HTTPCalloutService.createSignature(bodyString));
        service.setRequestBody(bodyString);
        service.formHTTPRequest();
        system.debug(service.getRequest().getBody());
        
        //======== SEND REQUEST =========
        HttpResponse response;
        try{
            response = service.sendRequest();
        }catch(Exception ex){
            system.debug('Error - send request :' + ex.getMessage());
        }
        
        //Parse the JSON response
        if (response.getStatusCode() != 200) {
            system.debug(' :: getStatus::: '+ response.getStatus());system.debug(' :: getStatusCode::: '+ response.getStatusCode());system.debug(' :: getBody::: '+ response.getBody());
            for(Case ca: Caso){
                ca.Smart_Status__c='reportACKUPDATE-ERROR';
                ca.Smart_Status_Detail__c=response.getBody();
                caseUpdate.add(ca);
            }
        }
        else{
            system.debug(' :: getStatus::: '+ response.getStatus());system.debug(' :: getStatusCode::: '+ response.getStatusCode());system.debug(' :: getBody::: '+ response.getBody());
            for(Case ca: Caso){
                ca.Smart_Status__c='reportACKUPDATE-OK';
                ca.Smart_Status_Detail__c='Actualizacion de datos de usuario correctamente';
                caseUpdate.add(ca);
            }
        }
        
        //update case status
        if(caseUpdate.size() > 0){
            update caseUpdate;
        }
    }
}
