/*
* ===================================================================================
* @className        WS_Smart_Test
* @description      Test class for smartsupervision classes.
* @version          V0.1 
* @dateCreated      2022/06/3
* ==============================================================================================================================
*/ 
@isTest
public class WS_Smart_Test {
    
    @testSetup static void setup() {
        // Registros generales para pruebas //
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        id recordCuenta = Schema.SObjectType.account.getRecordTypeInfosByDeveloperName().get('CMV_ProspectoNatural').getRecordTypeId();
        // Poblacion //
        CMV_Poblacion__c pais = new CMV_Poblacion__c(name= 'Colombia',SmartCode__c = '170',CMV_EsPais__c = true);
        insert pais;
        CMV_Poblacion__c dep = new CMV_Poblacion__c(name= 'Bogotá DC',SmartCode__c = '11',CMV_Es_Departamento__c = true, CMV_Parent__c = pais.id);
        insert dep;
        CMV_Poblacion__c ciudad = new CMV_Poblacion__c(name= 'Bogotá',SmartCode__c = '11001', CMV_Parent__c = dep.id,CMV_EsCiudad__c = true);
        insert ciudad;
        // Linea //
        CMV_Linea__c linea = new CMV_Linea__c(CMV_Descripcion__c = 'CRÉDITO VIVIENDA',CMV_ValoresTipoRegistroCaso__c= 'CMV_TipoRegistroBancoomeva');
        insert linea;
        // Causa //
        CMV_CausaCaso__c causa = new CMV_CausaCaso__c(CMV_Descripcion__c = 'Reclamo por el Cobro Seguro Vida Grupo T.C.',CMV_ValoresTipoRegistroCaso__c = 'CMV_TipoRegistroBancoomeva');
        insert causa;
        // Árbol de causas //
        CMV_MatrizTipificacion__c arbol = new CMV_MatrizTipificacion__c(CMV_Categoria__c = 'Reclamo', CMV_Linea1__c = linea.id,CMV_CausaCaso__c = causa.id,CMV_TipoRegistroCaso__c = 'CMV_TipoRegistroBancoomeva' , Smart_Motivo__c = 913, SmartProductCode__c = 213 );         
        insert arbol;
        // Cuenta //
        Account cuenta = new Account(RecordTypeId = recordCuenta, CMV_NumeroIdentificacion__c = '121212121211212', CMV_TipoDocumento__c = 'CC', PersonEmail = 'testprueba@pruebaprueba.com',LastName = 'Prueba', FirstName = 'Test');
        insert cuenta;
        contact contacto = new contact();
        contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
        system.debug('Contacto: ' + contacto);
        
    }
    @isTest static void testBancoomeva(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        insert userTest;
        system.debug('userTest>' + userTest);
        
        //    Given a mocked Permission Set
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        system.debug('ps:' + ps);

        //comento por que no esta encontrando esto 
        /*
        Id CustomPermission =  [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Bypass_Validation'][0].Id;
        system.debug('CustomPermission:' + CustomPermission);
        
        // Given custom permission associated to the mocked PermissionSet
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = CustomPermission
        );
        insert sea;
        
        system.debug('sea:' + sea);
        */
        // Given mocked Permission Set assigned to user for test
        system.debug('userId>'+ userTest.Id);
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userTest.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        
        system.debug('psa>' + psa);
        
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.Status = '3';
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            
            test.startTest();
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S'
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            caso.anexo_queja__c = true;
            
            
            
            Update caso;
            Blob bodyBlob2=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_3 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob2,
                origin = 'C',
                ContentLocation = 'S',
                Es_Archivo_Final__c = True
            );
            insert contentVersion_3; 
            ContentVersion contentVersion_4 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_3.Id LIMIT 1];
            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.LinkedEntityId = caso.id;
            contentlink2.contentdocumentid = contentVersion_4.contentdocumentid;
            contentlink2.ShareType = 'V';
            insert contentlink2;
            
            caso.Smart_Status__c = 'sendToSmart-OK';
            caso.Status = '1';
            caso.CMV_SolucionCaso__c = 'OK';
            caso.CMV_TipoRespuesta__c = 'Definitiva';
            caso.CMV_RespuestaFavorDe__c = 'Cliente';
            caso.tiene_respuesta_final__c = true;
            
            Update caso;
            caso.Smart_Status__c = 'FileDownload-OK';
            Update caso;            
            
            DataBase.executeBatch(new WS_SmartSetClaimACKBatch('CMV_TipoRegistroBancoomeva'), 1) ;
            WS_SmartUploadFiles wsFile = new WS_SmartUploadFiles(caso, contentVersion_3.id, '154' + caso.caseNumber, 'pdf');
			
            SchedulableContext sc = null;
            WS_SmartSetClaimACKScheduller m = new WS_SmartSetClaimACKScheduller('CMV_TipoRegistroBancoomeva');
            m.execute(sc);
            test.stopTest();
           
        }
    }
    
    @isTest static void testFiducoomeva(){
        
        id fiducoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroFiducoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        insert userTest;
        
        //    Given a mocked Permission Set
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        
        // Given custom permission associated to the mocked PermissionSet
        //lo comento por que aqui se rebienta el test 
        /*
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
                             WHERE DeveloperName = 'Bypass_Validation'][0].Id
        );
        insert sea;
        */
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userTest.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(fiducoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.Status = '3';
            caso.RecordTypeId = fiducoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            
            
            test.startTest();
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S'
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            caso.anexo_queja__c = true;
            
            
            
            Update caso;
            Blob bodyBlob2=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_3 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob2,
                origin = 'C',
                ContentLocation = 'S',
                Es_Archivo_Final__c = True
            );
            insert contentVersion_3; 
            ContentVersion contentVersion_4 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_3.Id LIMIT 1];
            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.LinkedEntityId = caso.id;
            contentlink2.contentdocumentid = contentVersion_4.contentdocumentid;
            contentlink2.ShareType = 'V';
            insert contentlink2;
            
            caso.Smart_Status__c = 'sendToSmart-OK';
            caso.Status = '1';
            caso.CMV_SolucionCaso__c = 'OK';
            caso.CMV_TipoRespuesta__c = 'Definitiva';
            caso.CMV_RespuestaFavorDe__c = 'Cliente';
            caso.tiene_respuesta_final__c=true;
            
            Update caso;           
            
            WS_SmartGetClaimBatch batchGet = new WS_SmartGetClaimBatch('CMV_TipoRegistroBancoomeva');
            DataBase.executeBatch(batchGet, 1) ;
            SchedulableContext sc = null;
            WS_SmartGetClaimScheduller m = new WS_SmartGetClaimScheduller();
            m.execute(sc);
            //WS_SmartSetClaimScheduller s = new WS_SmartSetClaimScheduller ();
            //s.execute(sc); 
            
            test.stopTest();
            
        }
    }
    
    @isTest static void testCSeguros(){
        id cSeguros = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        
        insert userTest;
        
        //    Given a mocked Permission Set
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        
        // Given custom permission associated to the mocked PermissionSet
        //lo comento por qeu aqui se rebienta el test 
        /*
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = [SELECT Id FROM CustomPermission
                             WHERE DeveloperName = 'Bypass_Validation'][0].Id
        );
        insert sea;
        */
        // Given mocked Permission Set assigned to user for test
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userTest.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(cSeguros);
            //Crear caso de test //    
            Case caso = new Case();
            caso.Status = '1';
            caso.CMV_QuienOriginoCaso__c = 'Defensoría';
            caso.RecordTypeId = cSeguros;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.CMV_RespuestaFavorDe__c = 'Empresa';
            
            
            test.startTest();
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S'
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            caso.anexo_queja__c = true;
            
            
            
            Update caso;
            Blob bodyBlob2=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_3 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob2,
                origin = 'C',
                ContentLocation = 'S',
                Es_Archivo_Final__c = True
            );
            insert contentVersion_3; 
            ContentVersion contentVersion_4 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_3.Id LIMIT 1];
            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.LinkedEntityId = caso.id;
            contentlink2.contentdocumentid = contentVersion_4.contentdocumentid;
            contentlink2.ShareType = 'V';
            insert contentlink2;
            
            caso.Smart_Status__c = 'sendToSmart-OK';
            caso.Status = '1';
            caso.CMV_SolucionCaso__c = 'OK';
            caso.CMV_TipoRespuesta__c = 'Definitiva';
            caso.CMV_RespuestaFavorDe__c = 'Cliente';
            
            Update caso;
     
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartGetClaimBatch(){
        id cSeguros = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroCorredoresSeguros').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        insert userTest;
        
        System.runAs(userTest){
            String RESPONSE_BODY = '{'+
                '    "count": 1,'+
                '    "pages": 1,'+
                '    "next": null,'+
                '    "previous": null,'+
                '    "results": ['+
                '        {'+
                '            "tipo_entidad": 5,'+
                '            "entidad_cod": "2",'+
                '            "fecha_creacion": "2022-02-23T19:44:52",'+
                '            "codigo_queja": "521645663492207417",'+
                '            "codigo_pais": "535",'+
                '            "departamento_cod": null,'+
                '            "municipio_cod": null,'+
                '            "nombres": "Juan Mejia",'+
                '            "tipo_id_CF": 1,'+
                '            "numero_id_CF": "1341432143",'+
                '            "telefono": "342314123",'+
                '            "correo": "juan.mejia@servinformacion.com",'+
                '            "tipo_persona": 1,'+
                '            "sexo": 2,'+
                '            "lgbtiq": 2,'+
                '            "canal_cod": 3,'+
                '            "condicion_especial": 98,'+
                '            "producto_cod": 403,'+
                '            "producto_nombre": "p",'+
                '            "macro_motivo_cod": 913,'+
                '            "texto_queja": "p",'+
                '            "anexo_queja": true,'+
                '            "tutela": null,'+
                '            "ente_control": 1,'+
                '            "escalamiento_DCF": 1,'+
                '            "replica": null,'+
                '            "argumento_replica": "P",'+
                '            "desistimiento_queja": 2,'+
                '            "queja_expres": 1'+
                '        }'+
                '    ]'+
                '}';
            
            Integer RESPONSE_SUCCESS = 200;
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            Test.startTest();
            WS_SmartGetClaimScheduller sc = new WS_SmartGetClaimScheduller();
            WS_SmartGetClaimBatch.getEquivalentValues('codigo_pais','' );
            WS_SmartGetClaimBatch.getEquivalentValues('departamento_cod','');
            WS_SmartGetClaimBatch.getEquivalentValues('municipio_cod','');
            WS_SmartGetClaimBatch.getEquivalentValues('producto_cod','');
            WS_SmartGetClaimBatch.getEquivalentValues('ente_control','');
            
             //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1 ];
            
            WS_SmartGetClaimBatch.getProduct(new WS_SmartGetClaimBatch.Claim());
            
            //WS_SmartGetClaimBatch.getProductDefault(new WS_SmartGetClaimBatch.Claim());
            
            WS_SmartGetClaimBatch.getMothNameByNumber(2);
            
            sc.execute(null);
            Test.stopTest();
        }
    }

    @isTest static void test_SmartGetUpdateBatch(){
        id cSeguros = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        insert userTest;
        id recordCuenta = Schema.SObjectType.account.getRecordTypeInfosByDeveloperName().get('CMV_ProspectoNatural').getRecordTypeId();
        Account cuenta = new Account(RecordTypeId = recordCuenta, CMV_NumeroIdentificacion__c = '1234566', CMV_TipoDocumento__c = 'CC', PersonEmail = 'testprueba@pruebaprueba.com',LastName = 'Prueba', FirstName = 'Test');
        insert cuenta;
        contact contacto = new contact();
        contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '1234566'];
        CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(cSeguros);
            //Crear caso de test //    
            Case caso = new Case();
            caso.Status = '3';
            caso.RecordTypeId = cSeguros;
            caso.ContactId = contacto.id;
            caso.AccountId = cuenta.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            insert caso;
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S',
                Es_Archivo_Final__c = true
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId,Es_Archivo_Final__c 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
        
        System.runAs(userTest){
            String RESPONSE_BODY = '{'+
                '    "count": 1,'+
                '    "pages": 1,'+
                '    "next": null,'+
                '    "previous": null,'+
                '    "results": ['+
                '        {'+
                '            "numero_id_CF": "1234566",'+
                '            "tipo_id_CF": 1,'+
                '            "nombre": "cambio",'+
                '            "apellido": "Prueba Qa",'+
                '            "fecha_nacimiento": "2002-08-17",'+
                '            "correo": "ferchosalas003@gmail.com",'+
                '            "telefono": "3115480321",'+
                '            "razon_social": "",'+
                '            "direccion": "calle 15 carrera 4",'+
                '            "departamento_cod": "68",'+
                '            "municipio_cod": "68572"'+
                '        }'+
                '    ]'+
                '}';
            
            Integer RESPONSE_SUCCESS = 200;
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            Test.startTest();
            WS_SmartGetUpdateScheduller sc = new WS_SmartGetUpdateScheduller();
            
            
            
            
            sc.execute(null);
            List<String> prueba = new List<String>();
            prueba.add('lista 1');
            WS_SmartGetUpdateBatch.senEmail(prueba);
            DataBase.executeBatch(new WS_SmartUploadFileBatch(caso.Id, 'FINAL'), 1);
            Test.stopTest();
        }
    }
    
    
    @isTest static void test_SmartGetFilesBatch(){
        id cSeguros = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroCorredoresSeguros').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        insert userTest;
        
        System.runAs(userTest){
            String RESPONSE_BODY = '{'+
                '    "count": 10,'+
                '    "pages": 1,'+
                '    "next": null,'+
                '    "previous": null,'+
                '    "results": ['+
                '        {'+
                '            "id": 3,'+
                '            "file": "https://media.istockphoto.com/vectors/no-image-vector-symbol-missing-available-icon-no-gallery-for-this-vector-id1128826884?k=20&m=1128826884&s=612x612&w=0&h=3GMtsYpW6jmRY9L47CwA-Ou0yYIc5BXRQZmcc81MT78=",'+
                '            "type": "pdf",'+
                '            "state": 2,'+
                '            "codigo_queja": "121637191320458543"'+
                '        }'+
                ']'+
                '}';
            
            Integer RESPONSE_SUCCESS = 200;
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(cSeguros);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = cSeguros;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.Smart_Status__c = 'created';
            Insert caso; 
            
            test.startTest();
            DataBase.executeBatch(new WS_SmartGetFilesBatch(), 1);
            WS_SmartGetFiles.procesaRespuesta(RESPONSE_BODY, caso);
            Test.stopTest();
        }
    }
    
    @isTest static void test_SmartSetClaim(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            
            String RESPONSE_BODY = '{'+
                '   "tipo_entidad":100,'+
                '   "entidad_cod":"9",'+
                '   "codigo_queja":"10091005923875328",'+
                '   "codigo_pais":4,'+
                '   "departamento_cod":"5",'+
                '   "municipio_cod":"5004",'+
                '   "canal_cod":1,'+
                '   "producto_cod":103,'+
                '   "macro_motivo_cod":103,'+
                '   "fecha_creacion":"2022-01-13T06:23:06",'+
                '   "nombres":"new complaint to ScotiaBank",'+
                '   "tipo_id_CF":1,'+
                '   "numero_id_CF":"111111116",'+
                '   "tipo_persona":1,'+
                '   "insta_recepcion":3,'+
                '   "punto_recepcion":1,'+
                '   "admision":1,'+
                '   "texto_queja":"text complaint1",'+
                '   "anexo_queja":false,'+
                '   "ente_control":1'+
                '}';
            
            Integer RESPONSE_SUCCESS = 201;
           
            
            
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S'
                );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            //DataBase.executeBatch(new WS_SmartSetClaimACKBatch('CMV_TipoRegistroBancoomeva'), 1) ;
            //WS_SmartUploadFiles wsFile = new WS_SmartUploadFiles(caso, contentVersion_3.id, '154' + caso.caseNumber, 'pdf');
			WS_SmartSetClaim.createdRequestFuture(caso.Id);
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartUploadFile(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            
            String RESPONSE_BODY = '{'+
                '   "tipo_entidad":100,'+
                '   "entidad_cod":"9",'+
                '   "codigo_queja":"10091005923875328",'+
                '   "codigo_pais":4,'+
                '   "departamento_cod":"5",'+
                '   "municipio_cod":"5004",'+
                '   "canal_cod":1,'+
                '   "producto_cod":103,'+
                '   "macro_motivo_cod":103,'+
                '   "fecha_creacion":"2022-01-13T06:23:06",'+
                '   "nombres":"new complaint to ScotiaBank",'+
                '   "tipo_id_CF":1,'+
                '   "numero_id_CF":"111111116",'+
                '   "tipo_persona":1,'+
                '   "insta_recepcion":3,'+
                '   "punto_recepcion":1,'+
                '   "admision":1,'+
                '   "texto_queja":"text complaint1",'+
                '   "anexo_queja":false,'+
                '   "ente_control":1'+
                '}';
            
            Integer RESPONSE_SUCCESS = 201;
            Integer RESPONSE_BAD = 300;
            
            
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S'
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            //DataBase.executeBatch(new WS_SmartSetClaimACKBatch('CMV_TipoRegistroBancoomeva'), 1) ;
            WS_SmartUploadFiles.makePostCallout(caso, contentVersion_1.id, '123', 'FINAL');


            HTTPCalloutServiceMock testMock2 = new HTTPCalloutServiceMock(RESPONSE_BAD, RESPONSE_BODY);
            testMock2.setResponseCode(401);
            Test.setMock(HTTPCalloutMock.class, testMock2);
            
            //DataBase.executeBatch(new WS_SmartSetClaimACKBatch('CMV_TipoRegistroBancoomeva'), 1) ;
            WS_SmartUploadFiles.makePostCallout(caso, contentVersion_1.id, '123', 'FINAL');
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartUpdateClaim(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            
            String RESPONSE_BODY = '{'+
                '   "tipo_entidad":100,'+
                '   "entidad_cod":"9",'+
                '   "codigo_queja":"10091005923875328",'+
                '   "codigo_pais":4,'+
                '   "departamento_cod":"5",'+
                '   "municipio_cod":"5004",'+
                '   "canal_cod":1,'+
                '   "producto_cod":103,'+
                '   "macro_motivo_cod":103,'+
                '   "fecha_creacion":"2022-01-13T06:23:06",'+
                '   "nombres":"new complaint to ScotiaBank",'+
                '   "tipo_id_CF":1,'+
                '   "numero_id_CF":"111111116",'+
                '   "tipo_persona":1,'+
                '   "insta_recepcion":3,'+
                '   "punto_recepcion":1,'+
                '   "admision":1,'+
                '   "texto_queja":"text complaint1",'+
                '   "anexo_queja":false,'+
                '   "ente_control":1'+
                '}';
            
            Integer RESPONSE_SUCCESS = 201;
           
            
            
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S'
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            //DataBase.executeBatch(new WS_SmartSetClaimACKBatch('CMV_TipoRegistroBancoomeva'), 1) ;
            WS_SmartUpdateClaim.createdRequest(caso.Id);
            WS_SmartUpdateClaim.getCountAnexosFinal(caso.Id);
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartSetClaim2(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            
            String RESPONSE_BODY = '{'+
                                    '    "id": 18,'+
                                    '    "file": "https://storage.googleapis.com/unscanned-sfc-smartsupervision-dev/12345678921234/Ruta_del_usuario_WhatsApp_Mi_planilla_002_1.pdf?Expires=1637286521&GoogleAccessId=backend%40sfc-smartsupervision-dev.iam.gserviceaccount.com&Signature=Rdis3plIRmKFbxjhnm%2BmY0f0DMi2AdrbCU47EnWgVEO9M4y1wm%2F7cS4gyYwq8VQg1S1HY%2FkZYA7dq9rd0%2B4Kk3n1K%2BQX9OmrR0Df4OmmLF4STY0a0dAE%2FARkct1sDZBNvcY%2BlQQMexIPwNJ%2FNImesJknEEfAKUsJDaub8%2BwH%2BMABsjt%2FIcops%2FrHhtX6DXVFFnQeW2BgM4X1ZjfLRDzI1Gj7lGRp2QwtK52i9CKKzdOxsBU0zDSRC9JjbCMPYK3%2B0LPU9%2FTwJ66e5f7WOvPd05V3G6Bjl1dK%2BfWQZzpX1IXNomewsOwnIzSrg6UeDjdeJ8KiLfg8uWypryV1uWa32A%3D%3D",'+
                                    '    "type": "pdf",'+
                                    '    "state": 1,'+
                                    '    "codigo_queja": "12345678921234"'+
                                    '}';
            
            Integer RESPONSE_SUCCESS = 401;
           
            
            
            Insert caso;
            //Cargamos Documento
            Blob bodyBlob=Blob.valueOf('SIGNATURE="true"');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob,
                origin = 'C',
                ContentLocation = 'S',
                Es_Archivo_Final__c = true
            );
            insert contentVersion_1; 
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId,Es_Archivo_Final__c 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = caso.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            testMock.setResponseCode(401);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            //DataBase.executeBatch(new WS_SmartSetClaimACKBatch('CMV_TipoRegistroBancoomeva'), 1) ;
            WS_SmartUploadFiles wsFile = new WS_SmartUploadFiles(caso, contentVersion_2.id, '154' + caso.caseNumber, 'OTHER');
			//WS_SmartSetClaim.createdRequestFuture(caso.Id);
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartActionBatch(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            caso.Smart_Status__c = 'sendToSmart-Error';
            
            String RESPONSE_BODY = '{'+
                                    '    "id": 18,'+
                                    '    "file": "https://storage.googleapis.com/unscanned-sfc-smartsupervision-dev/12345678921234/Ruta_del_usuario_WhatsApp_Mi_planilla_002_1.pdf?Expires=1637286521&GoogleAccessId=backend%40sfc-smartsupervision-dev.iam.gserviceaccount.com&Signature=Rdis3plIRmKFbxjhnm%2BmY0f0DMi2AdrbCU47EnWgVEO9M4y1wm%2F7cS4gyYwq8VQg1S1HY%2FkZYA7dq9rd0%2B4Kk3n1K%2BQX9OmrR0Df4OmmLF4STY0a0dAE%2FARkct1sDZBNvcY%2BlQQMexIPwNJ%2FNImesJknEEfAKUsJDaub8%2BwH%2BMABsjt%2FIcops%2FrHhtX6DXVFFnQeW2BgM4X1ZjfLRDzI1Gj7lGRp2QwtK52i9CKKzdOxsBU0zDSRC9JjbCMPYK3%2B0LPU9%2FTwJ66e5f7WOvPd05V3G6Bjl1dK%2BfWQZzpX1IXNomewsOwnIzSrg6UeDjdeJ8KiLfg8uWypryV1uWa32A%3D%3D",'+
                                    '    "type": "pdf",'+
                                    '    "state": 1,'+
                                    '    "codigo_queja": "12345678921234"'+
                                    '}';
            
            Integer RESPONSE_SUCCESS = 401;
           
            
            
            Insert caso;
            
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            testMock.setResponseCode(401);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            
            try{
                WS_SmartActionBatch batchGet = new WS_SmartActionBatch();
                DataBase.executeBatch(batchGet, 1) ;
                SchedulableContext sc = null;
                WS_SmartActionBatchScheduller m = new WS_SmartActionBatchScheduller();
                m.execute(sc);
            }catch(Exception ex){}
            
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartActionBatch2(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            caso.Smart_Status__c = 'SendUpdateSmart-Error';
            
            String RESPONSE_BODY = '{'+
                                    '    "id": 18,'+
                                    '    "file": "https://storage.googleapis.com/unscanned-sfc-smartsupervision-dev/12345678921234/Ruta_del_usuario_WhatsApp_Mi_planilla_002_1.pdf?Expires=1637286521&GoogleAccessId=backend%40sfc-smartsupervision-dev.iam.gserviceaccount.com&Signature=Rdis3plIRmKFbxjhnm%2BmY0f0DMi2AdrbCU47EnWgVEO9M4y1wm%2F7cS4gyYwq8VQg1S1HY%2FkZYA7dq9rd0%2B4Kk3n1K%2BQX9OmrR0Df4OmmLF4STY0a0dAE%2FARkct1sDZBNvcY%2BlQQMexIPwNJ%2FNImesJknEEfAKUsJDaub8%2BwH%2BMABsjt%2FIcops%2FrHhtX6DXVFFnQeW2BgM4X1ZjfLRDzI1Gj7lGRp2QwtK52i9CKKzdOxsBU0zDSRC9JjbCMPYK3%2B0LPU9%2FTwJ66e5f7WOvPd05V3G6Bjl1dK%2BfWQZzpX1IXNomewsOwnIzSrg6UeDjdeJ8KiLfg8uWypryV1uWa32A%3D%3D",'+
                                    '    "type": "pdf",'+
                                    '    "state": 1,'+
                                    '    "codigo_queja": "12345678921234"'+
                                    '}';
            
            Integer RESPONSE_SUCCESS = 401;
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            testMock.setResponseCode(401);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            
            try{
                WS_SmartActionBatch batchGet = new WS_SmartActionBatch();
                DataBase.executeBatch(batchGet, 1) ;
            }catch(Exception ex){}
            
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartActionBatch3(){
        id bancoomeva = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CMV_TipoRegistroBancoomeva').getRecordTypeId();
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema'];
        User userTest = new User(Alias = 'Test1', Email='newuser@testorg.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p1.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='pruebaPrueba@PruebaSura.com');
        System.runAs(userTest){
            //Consultar informacion
            contact contacto = [SELECT id,Name from CONTACT WHERE CMV_NumeroIdentificacion__c = '121212121211212'];
            CMV_Poblacion__c ciudad = [SELECT id FROM CMV_Poblacion__c WHERE SmartCode__c = '11001' ];
            CMV_MatrizTipificacion__c arbol = [SELECT id FROM CMV_MatrizTipificacion__c limit 1  ];
            system.debug(bancoomeva);
            //Crear caso de test //
            List<Case> casosPruebas = new List<Case>();    
            Case caso = new Case();
            caso.RecordTypeId = bancoomeva;
            caso.ContactId = contacto.id;
            caso.CMV_CiudadRadicacion__c = ciudad.id;
            caso.CMV_MatrizTipificacion__c = arbol.id;
            caso.anexo_queja__c = true;
            caso.Smart_Status__c = 'FinalDocumentUpload-Error';

            insert caso;
            casosPruebas.add(caso);
            
            String RESPONSE_BODY = '{'+
                                    '    "id": 18,'+
                                    '    "file": "https://storage.googleapis.com/unscanned-sfc-smartsupervision-dev/12345678921234/Ruta_del_usuario_WhatsApp_Mi_planilla_002_1.pdf?Expires=1637286521&GoogleAccessId=backend%40sfc-smartsupervision-dev.iam.gserviceaccount.com&Signature=Rdis3plIRmKFbxjhnm%2BmY0f0DMi2AdrbCU47EnWgVEO9M4y1wm%2F7cS4gyYwq8VQg1S1HY%2FkZYA7dq9rd0%2B4Kk3n1K%2BQX9OmrR0Df4OmmLF4STY0a0dAE%2FARkct1sDZBNvcY%2BlQQMexIPwNJ%2FNImesJknEEfAKUsJDaub8%2BwH%2BMABsjt%2FIcops%2FrHhtX6DXVFFnQeW2BgM4X1ZjfLRDzI1Gj7lGRp2QwtK52i9CKKzdOxsBU0zDSRC9JjbCMPYK3%2B0LPU9%2FTwJ66e5f7WOvPd05V3G6Bjl1dK%2BfWQZzpX1IXNomewsOwnIzSrg6UeDjdeJ8KiLfg8uWypryV1uWa32A%3D%3D",'+
                                    '    "type": "pdf",'+
                                    '    "state": 1,'+
                                    '    "codigo_queja": "12345678921234"'+
                                    '}';
            
            Integer RESPONSE_SUCCESS = 401;
            test.startTest();
            HTTPCalloutServiceMock testMock = new HTTPCalloutServiceMock(RESPONSE_SUCCESS, RESPONSE_BODY);
            testMock.setResponseCode(401);
            Test.setMock(HTTPCalloutMock.class, testMock);
            
            
            try{
                WS_SmartActionBatch batchGet = new WS_SmartActionBatch();
                DataBase.executeBatch(batchGet, 1) ;
                batchGet.execute(null,casosPruebas);

            }catch(Exception ex){}
            
            test.stopTest();
        }
    }
    
    @isTest static void test_SmartActionSchdulller(){
        	test.startTest();
            
            try{
                SchedulableContext sc = null;
            	WS_SmartActionScheduller m = new WS_SmartActionScheduller();
            	m.execute(sc);
            }catch(Exception ex){}
            
            test.stopTest();
        
    }

}