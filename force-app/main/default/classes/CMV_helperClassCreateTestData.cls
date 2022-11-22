/**
* @File Name          : CMV_helperClassCreateTestData.cls
* @Description        :
* @Author             : Daniel Murcia Suarez(DMS)   href=<daniel.murcia@globant.com>
* @Group              :
* @Last Modified By   : Humberto Montenegro href=<hmontenegro@avanxo.com>
* @Last Modified On   : 28/2/2020, 4:05:44 p. m.
* @Modification Log   :
* Ver       Date            Author                 Modification
* 1.0	 24/02/2020	 Daniel Murcia (DMS)         Initial Version
* 2.0    28/2/2020   Humberto Montenegro href=<hmontenegro@avanxo.com>     
****
**/
@isTest
public class CMV_helperClassCreateTestData {
    public static Account createTestAccount(){
        createTestPoblacion();
        Id RecordTypeIdAccnt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CMV_PersonaNatural').getRecordTypeId();
        Account testAccnt = new Account();
        testAccnt.LastName='Test Account';
        testAccnt.CMV_NumeroIdentificacion__c='1011111111';
        testAccnt.CMV_TipoDocumento__c='CC';
        testAccnt.PersonEmail='testclass@example.com';
        testAccnt.CMV_Email1__c='testclass@example.com';
        testAccnt.CMV_Email2__c='testclass@example.com';
        testAccnt.RecordTypeId=RecordTypeIdAccnt;
        insert testAccnt;
        return testAccnt;
    }
    public static Account createTestAccountOpp(){
        //createTestPoblacion();
        Id RecordTypeIdAccnt =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CMV_PersonaNatural').getRecordTypeId();
        system.debug('RecordTypeIdAccnt'+RecordTypeIdAccnt);
        Account testAccnt = new Account();
        testAccnt.LastName='Test Account Opp';
        testAccnt.CMV_AsociadoID__c =1010101010;
        testAccnt.CMV_NumeroIdentificacion__c='1011111112';
        testAccnt.CMV_TipoDocumento__c='CC';
        testAccnt.PersonEmail='testclass2@example.com';
        testAccnt.CMV_Email1__c='testclass2@example.com';
        testAccnt.CMV_Email2__c='testclass2@example.com';
        testAccnt.CMV_FechaVinculacionBancoomeva__c= Date.today();
        testAccnt.RecordTypeId=RecordTypeIdAccnt;
        system.debug('tstAccnt --> '+ testAccnt);
        insert testAccnt;
        return testAccnt;
    }
    public static Case createTestCase(Id testAccntId){
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PQRS Medicina Prepagada').getRecordTypeId();
        // CMV_Poblacion__c tPoblacion = createTestPoblacion();
        Case testCase= new Case();
        testCase.RecordTypeID=RecordTypeIdCase;
        testCase.Status ='3';
        testCase.Origin='Email';
        testCase.AccountId=testAccntId;
        //testCase.CMV_CiudadRadicacion__c=tPoblacion.Id;
        insert testCase;
        testCase.Status='2';
        update testCase;
        return testCase;
    }
     public static Case createTestCaseBancoomeva(Id testAccntId){
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PQRS Bancoomeva').getRecordTypeId();
        // CMV_Poblacion__c tPoblacion = createTestPoblacion();
        Case testCase= new Case();
        testCase.RecordTypeID=RecordTypeIdCase;
        testCase.Status ='3';
        testCase.Origin='Email';
        testCase.AccountId=testAccntId;
        //testCase.CMV_CiudadRadicacion__c=tPoblacion.Id;
        insert testCase;
        testCase.Status='2';
        update testCase;
        return testCase;
    }
    public static CMV_Poblacion__c createTestPoblacion(){
        CMV_Poblacion__c tstPoblacion= new CMV_Poblacion__c();
        tstPoblacion.Name ='BOGOTÁ';
        tstPoblacion.CMV_EsCiudad__c=true;
        tstPoblacion.CMV_Codigo__c='11001';
        insert tstPoblacion;
        return tstPoblacion;
    }
    public static CMV_Geografia__c createTestGeo(){
        CMV_Geografia__c tstGeo= new CMV_Geografia__c();
        tstGeo.CMV_strCodZona__c ='5001000';
        tstGeo.CMV_usrAsignacionOpp__c= UserInfo.getUserId() ;
        tstGeo.ownerId= UserInfo.getUserId() ;
        insert tstGeo;
        return tstGeo;
    }
    public static User createTestUsr(){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CMV_AdministratEncuestasCoomeva'];
        system.debug('PermissionSet   '+ ps);        
        Profile prf = [SELECT Id FROM Profile WHERE Name in ('System Administrator','Administrador del Sistema')];
        User usr = new User(Alias = 'standt', Email='standarduser@testcoomeva.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = prf.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testcoomeva.com');
        //insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        return usr;
    }
    public static Product2 createdProduct(){
        Pricebook2 prBook = new Pricebook2(Name='prBookTest');
        insert prBook;
        Product2 pro2 = new Product2(CMV_NitEmpresa__c='890300625',Name='Test Ptoduct',CMV_CodigoProducto__c='123321',CMV_DescripcionLineaProducto__c='testProduct', isActive=true);
        insert pro2;
        return pro2;
    }
    public static CMV_PresupuestoVentas__c createTestPresupuesto(Id prodId, Id userId){
        CMV_PresupuestoVentas__c tstPresupuesto= new CMV_PresupuestoVentas__c();
        tstPresupuesto.CMV_Presupuesto__c=200000000;
        tstPresupuesto.CMV_presupuesto_CantidadVal__c=12000;
        tstPresupuesto.CMV_Anio__c=system.today().year();
        tstPresupuesto.CMV_Mes__c=system.today().month();
        tstPresupuesto.CMV_Presupuesto_Valor__c=true;
        tstPresupuesto.CMV_Presupuesto_Cantidad__c=true;
        tstPresupuesto.CMV_Producto__c=prodId;
        tstPresupuesto.CMV_Usuario__c=userId;        
        tstPresupuesto.CMV_CodigoUsuario__c='TUSR1234';
        insert tstPresupuesto;
        return tstPresupuesto;
    }
    public static CMV_Transacciones__c createTestTranSn(Id accntId, Id prodId){
        CMV_Transacciones__c tstTran= new CMV_Transacciones__c();
        tstTran.CMV_Cuenta__c=accntId;
        tstTran.CMV_FechaTransaccion__c=system.today();
        tstTran.CMV_ValorTransaccion__c=1000000;
        tstTran.CMV_CantidadTransaccion__c=10;
        tstTran.CMV_Producto__c=prodId;
        tstTran.CMV_TipoOperacion__c='SN';        
        tstTran.CMV_CodigoUsuario__c='TUSR1234';
        insert tstTran;
        return tstTran;
    }
    public static CMV_Transacciones__c createTestTran(Id accntId, Id prodId){
        CMV_Transacciones__c tstTran= new CMV_Transacciones__c();
        tstTran.CMV_Cuenta__c=accntId;
        tstTran.CMV_FechaTransaccion__c=system.today();
        tstTran.CMV_ValorTransaccion__c=1000000;
        tstTran.CMV_CantidadTransaccion__c=10;
        tstTran.CMV_Producto__c=prodId;
        tstTran.CMV_TipoOperacion__c='AP';
        tstTran.CMV_CodigoUsuario__c='TUSR1234';
        insert tstTran;
        return tstTran;
    }
    public static Lead createTestLead(){ 
        createTestPoblacion();
        // createTestGeo();
        Lead testld = new Lead();
        testld.Firstname='Test';
        testld.LastName='Lead Globant';
        testld.Email='test@testglobant.com';
        testld.CMV_NumeroIdentificacion__c='1014243765';
        testld.CMV_TipoDocumento__c='CC';
        testld.CMV_Ciudad__c='11001';
        testld.CMV_AsociadoCoomeva__c='S';
        testld.CMV_BreveDescripcionNecesidad__c='test lead description';
        testld.CMV_GenerarTarea__c= false;
        testld.CMV_Empresa__c='900406150';
        //testld.CMV_IdCampana__c=''
        insert testld;
        return testld;
    }
    public static List<CMV_EmailCampana_cls> creatEmailAutomatedCampaignObjects(){
        CMV_GestorEmailCampana__mdt objDefaultSettings = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CMV_GestorCampanaNotifBody__c, CMV_GestorCampanaNotifSubject__c, CMV_GestorCampanaStatus__c, CMV_Email_Template_Name__c, CMV_Email_Template_Greeting__c, CMV_Email_Template_Close__c, CMV_Email_Template_HTML_Fragment__c, Email_Max_Template_Campaign_Images__c, CMV_Email_Template_Name1__c, CMV_Email_Template_HTML_Fragment_1__c                            FROM CMV_GestorEmailCampana__mdt
                                                          WHERE DeveloperName = 'Global' LIMIT 1];
        EmailTemplate emailTemplate= ([SELECT Id, Name, DeveloperName, NamespacePrefix, OwnerId, FolderId, FolderName, BrandTemplateId, TemplateStyle, IsActive, TemplateType, Encoding, Description, Subject, HtmlValue, Body, TimesUsed, LastUsedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ApiVersion, Markup, UiType, RelatedEntityType FROM EmailTemplate WHERE DeveloperName=: objDefaultSettings.CMV_Email_Template_Name__c LIMIT 1]);//, EnhancedLetterheadId
        
        CMV_GestorEmailCampanaFacade_cls gestorCampana =new CMV_GestorEmailCampanaFacade_cls(objDefaultSettings);        
        List<CampaignMember> lstCampaignMember= CMV_helperClassCreateTestData.creatEmailMandrillCampaignMembers();
        List<CMV_EmailCampana_cls> lstCMV_EmailCampana_cls= new  List<CMV_EmailCampana_cls>();
        String campaignId='';       
        
        List<CMV_TMPGestorCamapana__c> campanas= new List<CMV_TMPGestorCamapana__c>();
        campanas= gestorCampana.generarDataTMPGestorCampana(lstCampaignMember);        
        for(CMV_TMPGestorCamapana__c campana:campanas) {
            CMV_EmailCampana_cls email = new CMV_EmailCampana_cls.CMV_EmailCampanaBuilder().addRecipient(campana.CMV_Email__c)
                .setGreeting(objDefaultSettings.CMV_Email_Template_Greeting__c)
                .setMainText(emailTemplate.HtmlValue)
                .setFragmentText(String.isBlank(campaignId) ? objDefaultSettings.CMV_Email_Template_HTML_Fragment__c : objDefaultSettings.CMV_Email_Template_HTML_Fragment_1__c)
                .setCampaignsIds(campana.CampaignsIds__c.split(','))
                .setUrlImages(campana.CMV_URLImagenes__c.split(','))
                .setUrlsImgTracking(campana.CMV_URLReferencia__c.split(','))
                .setClosing(objDefaultSettings.CMV_Email_Template_Close__c)
                .setTitle('Campaña Coomeva'+System.today().format())
                .build();
            campana.CMV_MensajeHTML__c =  email.getMessage();
            lstCMV_EmailCampana_cls.add(email);
        }
        return lstCMV_EmailCampana_cls;
    }
    public static Survey getSurvey(){
        Survey objSurvey = new Survey();
        objSurvey= [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                    LastViewedDate, LastReferencedDate, TotalVersionsCount, DeveloperName, Description, ActiveVersionId, SurveyType, LatestVersionId 
                    FROM Survey Limit 1];        
        if (objSurvey!= null){ 
            system.debug('objSurvey  '+objSurvey); 
            return objSurvey;
        } else{
            system.debug('nullllllll  '); 
            return null;
        }       
    }
    public static List<Campaign> createSMSMasivianCampaigns(){
        Date dteFechaActual = Date.today();
        Date dteFechaInicio = dteFechaActual.toStartofWeek();
        String strDiaSemana = ''+dteFechaInicio.daysBetween(dteFechaActual)+'';
        List<RecordType> lstRecordTypeSMS=[select Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp  from RecordType where DeveloperName='CMV_CampanaSMS' LIMIT 1];
        RecordType objRecordTypeSMS=(lstRecordTypeSMS.get(0));
        List<Campaign> lstCampaign=new  List<Campaign>();
        Set<String>  setCampaignsIds= new Set<String> ();
        for(Integer i=0; i<5; i++) {
            Campaign objCampaign = new Campaign(Name = +generateRandomString(4), IsActive = true,CMV_Ejecutada__c=false,CMV_CampanaAprobada__c  =false,CMV_CampanaAsociados__c=false,CMV_EnvioCampana__c='Envío Único',StartDate=((system.today()-100)),EndDate=((system.today()+100)),RecordTypeId=objRecordTypeSMS.Id,
                                                CMV_APROBADODIGITAL__C=true,CMV_SMSPIEZAPUBLICITARIA__C=generateRandomString(10), Status=Label.CMV_EstadoEnvioCampanas);
            lstCampaign.add(objCampaign);
        } 
        for(Integer i=0; i<5; i++) {
            Campaign objCampaign = new Campaign(Name = +generateRandomString(4), IsActive = true,CMV_Ejecutada__c=false,CMV_CampanaAprobada__c  =false,CMV_CampanaAsociados__c=false,CMV_EnvioCampana__c='Envío Único',StartDate=((system.today()-100)),EndDate=((system.today()+100)),RecordTypeId=objRecordTypeSMS.Id,
                                                CMV_APROBADODIGITAL__C=true,CMV_SMSPIEZAPUBLICITARIA__C=generateRandomString(10), Status=Label.CMV_EstadoEnvioCampanas);
            lstCampaign.add(objCampaign);
        } 
        insert lstCampaign;
        for(Campaign objCampaign:lstCampaign){setCampaignsIds.add(objCampaign.Id);}
        return [select Id, IsDeleted, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, ExpectedRevenue, BudgetedCost, ActualCost, ExpectedResponse, NumberSent, IsActive, Description, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, AmountAllOpportunities, AmountWonOpportunities, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CampaignMemberRecordTypeId, CMV_SMSPiezaPublicitaria__c, CMV_TipoEncuestaCampana__c, CMV_Link_masivo_invitacion_encuesta__c, CMV_FechaEjecucion__c, CMV_UrlPiezaPublicitaria__c, CMV_ReferenciaPiezaPublicitaria__c, CMV_CampanaRecurrente__c, CMV_CampanaAsociados__c, CMV_Vigencia__c, CMV_Ejecutada__c, CMV_CampanaAprobada__c, CMV_Categoria__c, Miembros__c, CMV_EnvioCampana__c, CMV_AprobadoDigital__c, CMV_TipoEncuesta__c, CMV_CampanaEncuestaAprobada__c, CMV_TamaPieza_Publicitaria__c  from campaign where Id IN :setCampaignsIds];
        
    }
    public static List<Campaign> creatEmailMandrillCampaigns(){
        Date dteFechaActual = Date.today();
        Date dteFechaInicio = dteFechaActual.toStartofWeek();
        String strDiaSemana = ''+dteFechaInicio.daysBetween(dteFechaActual)+'';
        List<RecordType> lstRecordTypeEmail=[select Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp  from RecordType where DeveloperName='CMV_CampanaEmail' LIMIT 1];
        RecordType objRecordTypeEmail=(lstRecordTypeEmail.get(0));
        List<Campaign> lstCampaign=new  List<Campaign>();
        Set<String>  setCampaignsIds= new Set<String> ();
        for(Integer i=0; i<5; i++) {
            Campaign objCampaign = new Campaign(Name = +generateRandomString(4), IsActive = true,CMV_Ejecutada__c=false,CMV_CampanaAprobada__c  =true,CMV_CampanaAsociados__c=true,CMV_EnvioCampana__c='Automática',StartDate=((system.today()-100)),EndDate=((system.today()+100)),RecordTypeId=objRecordTypeEmail.Id,
                                                CMV_ReferenciaPiezaPublicitaria__c='https://login.salesforce.com/img'+(i+1)+'/logo214.jpg',CMV_UrlPiezaPublicitaria__c='https://login.salesforce.com/img'+(i+1)+'/logo214.jpg;', Status=Label.CMV_EstadoEnvioCampanas, CMV_DiasEjecucion__c=strDiaSemana);
            lstCampaign.add(objCampaign);
        }
        for(Integer i=0; i<6; i++) {
            Campaign objCampaign = new Campaign(Name = +generateRandomString(4), IsActive = true,CMV_Ejecutada__c=false,CMV_AprobadoDigital__c =true,CMV_Asunto__c='test subject',CMV_EnvioCampana__c='Envío Único',StartDate=((system.today()-100)),EndDate=((system.today()+100)),
                                                CMV_ReferenciaPiezaPublicitaria__c='https://login.salesforce.com/img'+(i+1)+'/logo214.jpg',CMV_UrlPiezaPublicitaria__c='https://login.salesforce.com/img'+(i+1)+'/logo214.jpg;',CMV_Categoria__c='Comunicados',Status=Label.CMV_EstadoEnvioCampanas);
            lstCampaign.add(objCampaign);
        }
        insert lstCampaign;
        for(Campaign objCampaign:lstCampaign){setCampaignsIds.add(objCampaign.Id);}
        return [select Id, IsDeleted, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, ExpectedRevenue, BudgetedCost, ActualCost, ExpectedResponse, NumberSent, IsActive, Description, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, AmountAllOpportunities, AmountWonOpportunities, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CampaignMemberRecordTypeId, CMV_SMSPiezaPublicitaria__c, CMV_TipoEncuestaCampana__c, CMV_Link_masivo_invitacion_encuesta__c, CMV_FechaEjecucion__c, CMV_UrlPiezaPublicitaria__c, CMV_ReferenciaPiezaPublicitaria__c, CMV_CampanaRecurrente__c, CMV_CampanaAsociados__c, CMV_Vigencia__c, CMV_Ejecutada__c, CMV_CampanaAprobada__c, CMV_Categoria__c, Miembros__c, CMV_EnvioCampana__c, CMV_AprobadoDigital__c, CMV_TipoEncuesta__c, CMV_CampanaEncuestaAprobada__c, CMV_TamaPieza_Publicitaria__c  from campaign where Id IN :setCampaignsIds];
    }
    public static List<Contact> creatEmailMandrillContacts(){
        List<Contact> lstContact=new List<Contact> ();
        Set<String>  setContactsIds= new Set<String> ();
        RecordType objContactRecordType = [SELECT Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp from RecordType WHERE DeveloperName ='CMV_TipoRegistroContactoCaso' LIMIT 1];
        for (Integer i = 0; i < 11; i++) {
            Contact objContact= new Contact(FirstName =+generateRandomString(10),LastName =generateRandomString(10)+i,Email=+generateRandomString(1)+generateRandomString(10)+i+'@gmail.com',RecordTypeId=objContactRecordType.Id);
            lstContact.add(objContact);            
        }
        insert lstContact; 
        for(Contact objContact:lstContact){setContactsIds.add(objContact.Id);}
        return [select Id, IsDeleted, MasterRecordId, AccountId, IsPersonAccount, LastName, FirstName, Salutation, MiddleName, Name, RecordTypeId, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, ReportsToId, Email, Title, Department, AssistantName, LeadSource, Birthdate, Description, OwnerId, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastCURequestDate, LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason, EmailBouncedDate, IsEmailBounced, PhotoUrl, Jigsaw, JigsawContactId, CMV_NumeroIdentificacion__c, CMV_TipoDocumento__c, CMV_LlaveContacto__c, CMV_LoginRed__c, CMV_Ciudad__c, CMV_JefeContacto__c, CMV_Oficina__c, CMV_Regional__c, CMV_JefeJefeResponsable__c, CMV_NombreUsuario__c, CMV_SegundoApellido__c  from contact where Id IN :setContactsIds];
        
    }       
    public static List<Contact> createSMSMasivianContacts(){
        List<Contact> lstContact=new List<Contact> ();
        Set<String>  setContactsIds= new Set<String> ();
        RecordType objContactRecordType = [SELECT Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp from RecordType WHERE DeveloperName ='CMV_TipoRegistroContactoCaso' LIMIT 1];
        for (Integer i = 0; i < 5; i++) {
            Contact objContact= new Contact(FirstName =+generateRandomString(10),LastName =generateRandomString(10)+i,Email=+generateRandomString(1)+generateRandomString(10)+i+'@gmail.com',MobilePhone='311'+generateRandomInteger(7),RecordTypeId=objContactRecordType.Id);
            lstContact.add(objContact);            
        }
        insert lstContact; 
        for(Contact objContact:lstContact){setContactsIds.add(objContact.Id);}
        return [select Id, IsDeleted, MasterRecordId, AccountId, IsPersonAccount, LastName, FirstName, Salutation, MiddleName, Name, RecordTypeId, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, HomePhone, OtherPhone, AssistantPhone, ReportsToId, Email, Title, Department, AssistantName, LeadSource, Birthdate, Description, OwnerId, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastCURequestDate, LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason, EmailBouncedDate, IsEmailBounced, PhotoUrl, Jigsaw, JigsawContactId, CMV_NumeroIdentificacion__c, CMV_TipoDocumento__c, CMV_LlaveContacto__c, CMV_LoginRed__c, CMV_Ciudad__c, CMV_JefeContacto__c, CMV_Oficina__c, CMV_Regional__c, CMV_JefeJefeResponsable__c, CMV_NombreUsuario__c, CMV_SegundoApellido__c  from contact where Id IN :setContactsIds];
        
    }     
    public static List<CampaignMember>  createSMSMasivianTmpData(){
        return createSMSMasivianCampaignMembers();
    }    
    public static List<CMV_TMPGestorCamapana__c> createEmailMandrillTmpData(){
        List<CampaignMember> lstCampaignMembers= creatEmailMandrillCampaignMembers();
        List<CMV_TMPGestorCamapana__c> lstTmpGestorCampana= new List<CMV_TMPGestorCamapana__c>();
        Set<String> setCampaignIds=new Set<String>();
        Set<String> setUrlImages=new Set<String>();
        Set<String> setUrlTrackingImages=new Set<String>(); 
        Set<String> setTmpGestorCampanaIds=new Set<String>();
        
        for(CampaignMember objCampaignMember:lstCampaignMembers){
            setCampaignIds.add(objCampaignMember.CampaignId);    
        }
        List<Campaign> lstCampaign=[SELECT Id, IsDeleted, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, ExpectedRevenue, BudgetedCost, ActualCost, ExpectedResponse, NumberSent, IsActive, Description, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, AmountAllOpportunities, AmountWonOpportunities, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CampaignMemberRecordTypeId, CMV_AprobadoDigital__c, CMV_CampanaAprobada__c, CMV_CampanaAsociados__c, CMV_CampanaEncuestaAprobada__c, CMV_CampanaRecurrente__c, CMV_Categoria__c, CMV_Ejecutada__c, CMV_EnvioCampana__c, CMV_FechaEjecucion__c, CMV_Link_masivo_invitacion_encuesta__c, CMV_ReferenciaPiezaPublicitaria__c, CMV_SMSPiezaPublicitaria__c, CMV_TipoEncuestaCampana__c, CMV_TipoEncuesta__c, CMV_UrlPiezaPublicitaria__c, CMV_Vigencia__c, Miembros__c  FROM CAMPAIGN   WHERE  id IN :setCampaignIds ];
        for(Campaign objCampaign:lstCampaign){
            setUrlImages.add(objCampaign.CMV_UrlPiezaPublicitaria__c);
            setUrlTrackingImages.add(objCampaign.CMV_ReferenciaPiezaPublicitaria__c);  
        }
        Map<String,CMV_TMPGestorCamapana__c> mapTmpRecords= new Map<String,CMV_TMPGestorCamapana__c>();
        for(CampaignMember objCampaignMember:lstCampaignMembers){
            if(!mapTmpRecords.containsKey(objCampaignMember.Email)){
                mapTmpRecords.put(objCampaignMember.Email, new CMV_TMPGestorCamapana__c(CMV_Email__c= objCampaignMember.Email,
                                                                                        CMV_GrupoRequestWS__c=1,CMV_MensajeHTML__c='<p>Example HTML content</p>',
                                                                                        CMV_URLImagenes__c=String.join(new List<String> (setUrlImages), ','),
                                                                                        CMV_URLReferencia__c=String.join(new List<String> (setUrlTrackingImages),',' ),
                                                                                        CampaignsIds__c=String.join(new List<String> (setCampaignIds),',' )));
            }    
        }
        for(String key : mapTmpRecords.keySet()){
            CMV_TMPGestorCamapana__c obj_CMV_GestorCampana=mapTmpRecords.get(key);
            lstTmpGestorCampana.add(obj_CMV_GestorCampana);
            
        }
        insert lstTmpGestorCampana;
        
        for(CMV_TMPGestorCamapana__c  objGestorCampana: lstTmpGestorCampana){
            setTmpGestorCampanaIds.add(objGestorCampana.Id);
        }
        
        return [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CMV_Email__c, CMV_URLImagenes__c, CMV_URLReferencia__c, CampaignsIds__c, CMV_MensajeHTML__c, CMV_GrupoRequestWS__c, CMV_IdJobRequestWSMandrill__c, CMV_RequestWSMandrill__c, CMV_ResponsetWSMandrill__c  from CMV_TMPGestorCamapana__c where Id IN : setTmpGestorCampanaIds];        
    }  
    public static List<CampaignMember> createSMSMasivianCampaignMembers(){
        List<Campaign> lstCampaign=CMV_helperClassCreateTestData.createSMSMasivianCampaigns();           
        List<Contact> lstContact=CMV_helperClassCreateTestData.createSMSMasivianContacts();
        Set<String>  setCampaignMemberIds= new Set<String> ();
        
        List<CampaignMember> lstCampaignMember=new  List<CampaignMember>();
        for(Campaign objCampaign:lstCampaign) {
            for (Contact objContact:lstContact){              
                CampaignMember objCampaignMember = new CampaignMember(CampaignId=objCampaign.Id,ContactId=objContact.Id,Status='Sent',CMV_EjecutadoMasivian__c=false);
                lstCampaignMember.add(objCampaignMember);
            }
            
        }
        insert lstCampaignMember;
        for(CampaignMember objCampaignMember:lstCampaignMember){
            setCampaignMemberIds.add(objCampaignMember.Id);
        }
        return [select  Id, IsDeleted, CampaignId, LeadId, ContactId,  Name, FirstName, LastName, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax, MobilePhone, Description, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, LeadSource, CompanyOrAccount, Type, LeadOrContactId, LeadOrContactOwnerId, CMV_InvitacionEncuesta__c, CMV_RequestWSMandrill__c, CMV_EjecutadoMandril__c, CMV_IdJobRequestWSMandrill__c, CMV_ResponsetWSMandrill__c, CMV_EjecutadoMasivian__c, CMV_IdJobRequestWSMasivian__c, CMV_GrupoRequestWS__c  from CampaignMember where Id IN:setCampaignMemberIds   ];
        
    }
    public static List<CampaignMember> creatEmailMandrillCampaignMembers(){
        List<Campaign> lstCampaign=CMV_helperClassCreateTestData.creatEmailMandrillCampaigns();           
        List<Contact> lstContact=CMV_helperClassCreateTestData.creatEmailMandrillContacts();
        Set<String>  setCampaignMemberIds= new Set<String> ();
        
        List<CampaignMember> lstCampaignMember=new  List<CampaignMember>();
        for(Campaign objCampaign:lstCampaign) {
            for (Contact objContact:lstContact){              
                CampaignMember objCampaignMember = new CampaignMember(CampaignId=objCampaign.Id,ContactId=objContact.Id,Status='Sent',CMV_EjecutadoMandril__c=false);
                lstCampaignMember.add(objCampaignMember);
            }
            
        }
        insert lstCampaignMember;
        for(CampaignMember objCampaignMember:lstCampaignMember){
            setCampaignMemberIds.add(objCampaignMember.Id);
        }
        return [select  Id, IsDeleted, CampaignId, LeadId, ContactId,  Name, FirstName, LastName, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax, MobilePhone, Description, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, LeadSource, CompanyOrAccount, Type, LeadOrContactId, LeadOrContactOwnerId, CMV_InvitacionEncuesta__c, CMV_RequestWSMandrill__c, CMV_EjecutadoMandril__c, CMV_IdJobRequestWSMandrill__c, CMV_ResponsetWSMandrill__c, CMV_EjecutadoMasivian__c, CMV_IdJobRequestWSMasivian__c, CMV_GrupoRequestWS__c  from CampaignMember where Id IN:setCampaignMemberIds   ];
        
    }
    public static String generateRandomString(Integer strLength) {
        Blob b = Crypto.GenerateAESKey(256);
        String h = EncodingUtil.base64Encode(b);
        return h.remove(' ').remove('/').remove('+').remove('=').substring(0, strLength);
    }
    public static Integer generateRandomInteger(Integer intLength) {          
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, intLength);
        return Integer.valueOf(randomNumber);
    }
    
    public static Campaign createCampSurvey(){
        Id objRecordTypeSMS = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CMV_CampanaSMS').getRecordTypeId();        
        Survey objSurvey=CMV_helperClassCreateTestData.getSurvey();
        Set<String>  setCampaignsIds= new Set<String> ();
        Campaign objCampaign = new Campaign(Name = +generateRandomString(4), IsActive = true,CMV_Ejecutada__c=false,CMV_CampanaAprobada__c  =false,CMV_CampanaAsociados__c=false,CMV_EnvioCampana__c='Envío Único',StartDate=((system.today()-100)),EndDate=((system.today()+100)),RecordTypeId=objRecordTypeSMS,
                                            CMV_APROBADODIGITAL__C=true,CMV_SMSPIEZAPUBLICITARIA__C=generateRandomString(10),CMV_TipoEncuestaCampana__c=objSurvey.Id);
        
        insert objCampaign;
        return objCampaign;
    }   
    public static List<CampaignMember> createCampMemSurvey(){
        Campaign lstCampaign=CMV_helperClassCreateTestData.createCampSurvey();           
        List<Contact> lstContact=CMV_helperClassCreateTestData.createSMSMasivianContacts();
        Set<String>  setCampaignMemberIds= new Set<String> ();
        
        List<CampaignMember> lstCampaignMember=new  List<CampaignMember>();
        for (Contact objContact:lstContact){              
            CampaignMember objCampaignMember = new CampaignMember(CampaignId=lstCampaign.Id,ContactId=objContact.Id,Status='Sent',CMV_EjecutadoMasivian__c=false);
            lstCampaignMember.add(objCampaignMember);
        }
        insert lstCampaignMember;
        for(CampaignMember objCampaignMember:lstCampaignMember){
            setCampaignMemberIds.add(objCampaignMember.Id);
        }
        return [select  Id, IsDeleted, CampaignId, LeadId, ContactId,  Name, FirstName, LastName, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax, MobilePhone, Description, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, LeadSource, CompanyOrAccount, Type, LeadOrContactId, LeadOrContactOwnerId, CMV_InvitacionEncuesta__c, CMV_RequestWSMandrill__c, CMV_EjecutadoMandril__c, CMV_IdJobRequestWSMandrill__c, CMV_ResponsetWSMandrill__c, CMV_EjecutadoMasivian__c, CMV_IdJobRequestWSMasivian__c, CMV_GrupoRequestWS__c  from CampaignMember where Id IN:setCampaignMemberIds   ];
        
    }
    
}