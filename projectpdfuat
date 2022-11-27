/************************************************************************************************
Desarrollado por:  Globant
Autor:             Daniel Murcia Surez (DMS) 
Proyecto:          Coomeva CRM
Descripción:      test Class para proyecto PDF y leadConver

Cambios (Versiones)
-------------------------------------------------------------------------------------------------
No.         Fecha                  Autor                                 Descripción
----------  -------------   -------------------------------     -------------------------------
1.0         04/03/20        Daniel Murcia Suarez (DMS)          Creación de la clase
2.0         27/01/21        Steven Moque Quintero (SMQ)         Anexo del 'testMethod7' y 'testMethod8'
3.0         24/02/21        Steven Moque Quintero (SMQ)         Anexo 'testMethod9'.
4.0         12/08/21        Víctor Moya (VM)                    Mejora 'testMethod7' para alcanzar cobertura
************************************************************************************************/
@isTest
public class CMV_testClassProjectPDF_tst {
    @testSetup
    static void setup(){
        Account objAccnt = new Account();
        objAccnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CMV_PersonaNatural').getRecordTypeId();
        objAccnt.FirstName = 'Test1';
        objAccnt.LastName = 'Test1';
        objAccnt.CMV_TipoDocumento__c = 'CC';
        objAccnt.CMV_NumeroIdentificacion__c = '123456789';
        insert objAccnt;
        RecordType objContactRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName ='CMV_TipoRegistroContactoCaso' LIMIT 1];
        Contact objContact	=	new Contact();
		objContact.FirstName 	= 'Test Contact';
		objContact.Email		= 'Test_Contact@gmail.com';
		objContact.LastName 	= 'Test Contact1';
		objContact.MobilePhone	= '311 8440789';
        objContact.CMV_NumeroIdentificacion__c = '7896789'; 
		objContact.RecordTypeId	= objContactRecordType.Id;
		insert objContact;
        CMV_Linea__c objLinea = new CMV_Linea__c(); 
        //objLinea.name = 'Test Línea';        
        objLinea.CMV_ValoresTipoRegistroCaso__c = 'CMV_TipoRegistroBancoomeva';
        insert objLinea;
        CMV_Proceso__c objProceso = new CMV_Proceso__c(); 
        //objProceso.name = 'Test Proceso';        
        objProceso.CMV_ValoresTipoRegistroCaso__c = 'CMV_TipoRegistroBancoomeva';
        insert objProceso;
        CMV_CausaCaso__c objCausa = new CMV_CausaCaso__c(); 
        //objCausa.name = 'Test Causa';        
        objCausa.CMV_ValoresTipoRegistroCaso__c = 'CMV_TipoRegistroBancoomeva';
        insert objCausa;
        CMV_MatrizTipificacion__c objMatriz = new CMV_MatrizTipificacion__c();
        objMatriz.CMV_NombreAsignacion__c = 'Test Matriz';
        objMatriz.CMV_Activo__c     = true;
        objMatriz.Tipo_de_Registro_Caso1__c = 'CMV_TipoRegistroBancoomeva';
        objMatriz.CMV_Linea1__c     = objLinea.Id;
        objMatriz.CMV_Proceso1__c   = objProceso.Id;
        objMatriz.CMV_CausaCaso__c  = objCausa.Id;
        objMatriz.CMV_ANSNivel1__c  = 1440;
        objMatriz.CMV_ANSNivel2__c  = 2880;
        objMatriz.CMV_ANSNivel3__c  = 1440;
        objMatriz.CMV_NombreAsignacion__c = 'Asignación 1';
        insert objMatriz;
        String strIdProceso = null;
        
        list<Entitlement> lstProcesos = [
            Select	Id 
            From	Entitlement
            Where	Name = :objMatriz.CMV_NombreAsignacion__c And Status = 'Active'
        ];
        System.debug('>>>>>>lstProcesos: '+lstProcesos);
        // if(!lstProcesos.isEmpty())
        //     strIdProceso = lstProcesos[0].Id;
            
         
        Case objCase = new Case();
        objCase.AccountId   = objAccnt.Id;
        objcase.ContactId   = objContact.Id;
        objCase.Subject     = 'Test';
        objCase.Status      = 'Radicado';
        //objCase.Tiempo_Categorizacion__c = true;
        objCase.CMV_MatrizTipificacion__c = objMatriz.id;
        objCase.EntitlementId = strIdProceso;
        insert objCase;
        
        Account AccPA = new Account();
		AccPA.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CMV_PersonaNatural').getRecordTypeId();
		AccPA.FirstName = 'Test1';
        AccPA.LastName = 'Test1';
        AccPA.CMV_TipoDocumento__c = 'CC';
        AccPA.CMV_NumeroIdentificacion__c = '123456783444349';
        AccPA.CMV_FechaVinculacionBancoomeva__c= Date.today();
        AccPA.CMV_FechaVinculacionBancoomeva__c= null;
        AccPA.CMV_FechaVinculacionCem__c= Date.today();
        AccPA.CMV_FechaVinculacionCoomeva__c= Date.today()+1;
        AccPA.CMV_FechaVinculacionCorredores__c= Date.today()+2;
        AccPA.CMV_FechaVinculacionFiducoomeva__c= Date.today()+3;
        AccPA.CMV_FechaVinculacionFundacion__c= Date.today()+4;
        AccPA.CMV_FechaVinculacionMP__c= Date.today()+5;
        insert AccPA;
        
        Campaign objCampaign = new Campaign();
        objCampaign.name = 'Tezt';
       	insert objCampaign;
            
            
            
        Opportunity objOpp = new Opportunity();  
        objOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CMV_OportunidadMedicinaPrepagada').getRecordTypeId();
        objOpp.Name = 'TEST';
        objOpp.AccountId = AccPA.id;
        objOpp.CampaignId = null;
        objOpp.StageName = 'En Consideración';
        objOpp.CloseDate = Date.Today();
        insert objOpp;
        
        CMV_getRelatesOpp_cls.getEmpName(String.valueOf(AccPA.Id));
    }



    static testMethod void testMethod1(){        
        Account tstAccnt= CMV_helperClassCreateTestData.createTestAccount();
        Case tstCase= CMV_helperClassCreateTestData.createTestCase(tstAccnt.Id);
        Test.StartTest();        
        tstCase.Status='1';
        tstCase.CMV_SolucionCaso__c ='solucion test class';
        tstCase.CMV_RespuestaFavorDe__c='Cliente';
        tstCase.tiene_respuesta_final__c=true;
        update tstCase; 
        Case csTst=[Select Id, CMV_Envio_Respuesta_Final__c from Case where Id =:tstCase.Id limit 1];
        ApexPages.StandardController sc = new ApexPages.standardController(csTst);
        CMV_pdfCaseController x= new CMV_pdfCaseController(sc);  
        Test.StopTest();        
        case prCase=[select id, CMV_Envio_Respuesta_Final__c,CMV_Documento__c from case where Id=:csTst.Id]; 
        system.debug('prCase'+prCase);
        CMV_respuestaPdf__c[] cdUrl = [SELECT Id,CMV_casoRelacionado__c, CMV_urlPdf__c,CMV_numeroDocumento__c FROM CMV_respuestaPdf__c where CMV_casoRelacionado__c=:prCase.Id limit 1];
        
        if (cdUrl.size()>0){
            PageReference pageRef = new PageReference('https://salesforce.com/viewpdf/?id='+prCase.Id);
            Test.setCurrentPage(pageRef);
            CMV_accessPDFpage r= new CMV_accessPDFpage();
            r.password='1011111111';
            r.openPDF();
        }
        case fnlCase=[select id, CMV_Envio_Respuesta_Final__c,CMV_Documento__c,Status from case where Id=:csTst.Id]; 
       // system.assertEquals(true, fnlCase.CMV_Envio_Respuesta_Final__c);
        
        fnlCase.Status = '0';
        update fnlCase;
        
        fnlCase.Status = '14';
        update fnlCase;
    }
    static testMethod void testMethod2(){
        Account tstAccnt= CMV_helperClassCreateTestData.createTestAccount();
        User tstUser= CMV_helperClassCreateTestData.createTestUsr();
        Product2 tstProd= CMV_helperClassCreateTestData.createdProduct();
        System.runAs(tstUser) {
            CMV_PresupuestoVentas__c tstPre = CMV_helperClassCreateTestData.createTestPresupuesto(tstProd.Id,tstUser.Id);
            Test.StartTest();  
            CMV_Transacciones__c tstTran=CMV_helperClassCreateTestData.createTestTran(tstAccnt.Id,tstProd.Id );
            CMV_Transacciones__c tstTranSN=CMV_helperClassCreateTestData.createTestTranSn(tstAccnt.Id,tstProd.Id );
            Test.stopTest();
        }
    }
    static testMethod void testMethod3(){
        Test.StartTest();  
        Lead tstLead= CMV_helperClassCreateTestData.createTestLead();
        Account acnt=[Select id,CMV_NumeroIdentificacion__c From Account Where CMV_NumeroIdentificacion__c =: tstLead.CMV_NumeroIdentificacion__c limit 1];
        //task task=[select id From Task Where Whoid =: acnt.id];
        system.assertEquals(tstLead.CMV_NumeroIdentificacion__c, acnt.CMV_NumeroIdentificacion__c);
        Test.stopTest();
    }
    static testMethod void testMethod4(){ 
        Lead tstLead= CMV_helperClassCreateTestData.createTestLead();
        Account tstAccntProspect=[Select id,CMV_NumeroIdentificacion__c From Account Where CMV_NumeroIdentificacion__c =: tstLead.CMV_NumeroIdentificacion__c limit 1];
        //Account tstAccntProspect= CMV_helperClassCreateTestData.createTestAccount();
        Account tstAccnt= CMV_helperClassCreateTestData.createTestAccountOpp();     
        Test.StartTest();  
        List<Opportunity> lstOppTst=CMV_getRelatesOpp_cls.getOpptyRel(tstAccnt.Id);  
        Map<Decimal, datetime> mapgetTimeIncProspect=CMV_getRelatesOpp_cls.getTimeInc(tstAccntProspect.Id);    
        Map<Decimal, datetime> mapgetTimeInc=CMV_getRelatesOpp_cls.getTimeInc(tstAccnt.Id);
        Integer intgetTimePer=CMV_getRelatesOpp_cls.getTimePer(tstAccnt.Id);
        Integer intgetTimePerPr=CMV_getRelatesOpp_cls.getTimePer(tstAccntProspect.Id);        
        String strgetEmpName=CMV_getRelatesOpp_cls.getEmpName(tstAccnt.Id);
        String strgetEmpNamePer=CMV_getRelatesOpp_cls.getEmpName(tstAccntProspect.Id);
        Test.stopTest();
    }
    
    static testMethod void testMethod6(){ 
        Lead tstLead= CMV_helperClassCreateTestData.createTestLead();
        Account tstAccntProspect=[Select id,CMV_NumeroIdentificacion__c From Account Where CMV_NumeroIdentificacion__c =: tstLead.CMV_NumeroIdentificacion__c limit 1];
        //Account tstAccntProspect= CMV_helperClassCreateTestData.createTestAccount();
        Account tstAccnt= CMV_helperClassCreateTestData.createTestAccountOpp();     
        Test.StartTest();  
        List<Opportunity> lstOppTst=CMV_getRelatesOpp_cls.getOpptyRel(tstAccnt.Id);  
        Map<Decimal, datetime> mapgetTimeIncProspect=CMV_getRelatesOpp_cls.getTimeInc(tstAccntProspect.Id);    
        Map<Decimal, datetime> mapgetTimeInc=CMV_getRelatesOpp_cls.getTimeInc(tstAccnt.Id);
        Integer intgetTimePer=CMV_getRelatesOpp_cls.getTimePer(tstAccnt.Id);
        Integer intgetTimePerPr=CMV_getRelatesOpp_cls.getTimePer(tstAccntProspect.Id);        
        String strgetEmpName=CMV_getRelatesOpp_cls.getEmpName(tstAccnt.Id);
        String strgetEmpNamePer=CMV_getRelatesOpp_cls.getEmpName(tstAccntProspect.Id);
        Test.stopTest();
    }
	
    static testMethod void testMethod7(){ 
        Account objAccnt = CMV_helperClassCreateTestData.createTestAccount();
        objAccnt.OwnerId = label.CMV_UsuarioIntegraciones;
        update objAccnt;
        String strAcctId = objAccnt.Id;
        RecordType objRectype = [SELECT Id FROM RecordType WHERE DeveloperName =: 'CMV_TipoRegistroTareasCaja'];
        String strRectypeId = objRectype.Id;

        map<String, wrpData> mapTagCampos = new map<String, wrpData>();
        wrpData objWrapperData = new wrpData();
        objWrapperData.recTypeTask = strRectypeId;
        objWrapperData.ownerTsk = objAccnt.OwnerId;
        objWrapperData.Accnt = objAccnt;
        mapTagCampos.put(strAcctId, objWrapperData);
        System.debug('<<mapTagCampos>>'+mapTagCampos);

        CMV_createProspectData.createTask(mapTagCampos);
        //Inicio 4.0
        CMV_getRelatesOpp_cls.getTimeInc(objAccnt.id);
        CMV_getRelatesOpp_cls.getOpptyRel(objAccnt.id);
        CMV_getRelatesOpp_cls.getTimePer(objAccnt.id);
        CMV_getRelatesOpp_cls.getEmpName(objAccnt.id);
        
        //Account objAccnt2 = CMV_helperClassCreateTestData.createAccountPersona();
        //objAccnt2.OwnerId = label.CMV_UsuarioIntegraciones;
        //update objAccnt2;
        //CMV_getRelatesOpp_cls.getEmpName(objAccnt2.id);
        //Fin 4.0
    }

    static testMethod void testMethod8(){ 
       
        Id RecordTypeIdAccnt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CMV_PersonaJuridica').getRecordTypeId();
        system.debug('RecordTypeIdAccnt'+RecordTypeIdAccnt);
        Account testAccnt = new Account();
        testAccnt.Name='Test Juridica';
        testAccnt.CMV_NumeroIdentificacion__c='1011111112';
        testAccnt.CMV_TipoDocumento__c='NI';
        testAccnt.CMV_FechaVinculacionBancoomeva__c= Date.today();
        testAccnt.CMV_FechaVinculacionBancoomeva__c= null;
        testAccnt.CMV_FechaVinculacionCem__c= Date.today();
        testAccnt.CMV_FechaVinculacionCoomeva__c= Date.today()+1;
        testAccnt.CMV_FechaVinculacionCorredores__c= Date.today()+2;
        testAccnt.CMV_FechaVinculacionFiducoomeva__c= Date.today()+3;
        testAccnt.CMV_FechaVinculacionFundacion__c= Date.today()+4;
        testAccnt.CMV_FechaVinculacionMP__c= Date.today()+5;
        testAccnt.RecordTypeId=RecordTypeIdAccnt;
        system.debug('tstAccnt --> '+ testAccnt);
        insert testAccnt;
        Map<Decimal, datetime> mapgetTimeInc=CMV_getRelatesOpp_cls.getTimeInc(testAccnt.Id);
        // testAccnt.CMV_FechaVinculacionBancoomeva__c= null;
        // update testAccnt;
        // CMV_getRelatesOpp_cls.getTimeInc(testAccnt.Id);
    }

    static testMethod void testMethod9(){ 
        Account objAccnt = [SELECT Id, CMV_NumeroIdentificacion__c 
                              FROM Account limit 1];
        objAccnt.CMV_NumeroIdentificacion__c = '';
        update objAccnt;
        Case objcase = [SELECT Id, CMV_NmeroIdentificacion__c, RecordTypeId, ContactId, CaseNumber
                          FROM Case];
        List<Case> lstCase = new List<Case>();
        lstCase.add(objCase);
        // [SELECT Id, CMV_NmeroIdentificacion__c, RecordTypeId, ContactId, CaseNumber
        //                         FROM Case];
        // System.debug('****recId++++ '+recId);
        System.debug('lstCase--> '+lstCase);
        CMV_CasoHandler_cls.setDataResponse(lstCase);
        Id recId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        objcase.RecordTypeId = recId;
        update objCase;
        lstCase.add(objCase);
        System.debug('****recId++++ '+recId);
        System.debug('lstCase--> '+lstCase);
        CMV_CasoHandler_cls.setDataResponse(lstCase);

        Datetime myDT = Datetime.now();
        BusinessHours objBussinesHour = [SELECT Id FROM BusinessHours WHERE Name = 'Default' LIMIT 1];
        // DateTime dteFecha = DateTime.newInstance(dteFechaIni.date(), objTime);
        //CMV_CasoHandler_cls.calcularFechaANS(myDT, 5, objBussinesHour);
    }
}