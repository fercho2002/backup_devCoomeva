/*
* ==============================================================================================================================
* @className        WS_SmartUploadFileQueueable
* @description      queable para ejecutar batch
* @author           vasslatam.com
* @version          V0.1 
* @testClass        
* @dateCreated      2022/05/06
* ==============================================================================================================================
*/ 
public class WS_SmartUploadFileQueueable implements Queueable{
    public String casoId;
    public String fileType;
    
    public WS_SmartUploadFileQueueable(String casoId, String file_type){
        this.casoId = casoId;
        this.fileType = file_type;
    }
    
	public  void execute(QueueableContext qc){
        system.debug('=== WS_SmartUploadFileQueueable Util execute ===');
        DataBase.executeBatch(new WS_SmartUploadFileBatch(this.casoId, this.fileType), 1);
    }
}