trigger Project_Payment_Trigger on Project_Payment__c (after insert, after update, after delete, after undelete) {

    if(trigger.isBefore){
        
    }
    else if(trigger.isAfter){
        if(trigger.isInsert){
            Project_Payment_Trigger_Handler.aInsert(trigger.newMap);
        }
        else if(trigger.isUpdate){
            Project_Payment_Trigger_Handler.aUpdate(trigger.newMap, trigger.oldMap);            
        }
        else if(trigger.isDelete){
            Project_Payment_Trigger_Handler.aDelete(trigger.oldMap);            
        }        
        else if(trigger.isUndelete){
            Project_Payment_Trigger_Handler.aUndelete(trigger.newMap);            
        }        
    }
    
}