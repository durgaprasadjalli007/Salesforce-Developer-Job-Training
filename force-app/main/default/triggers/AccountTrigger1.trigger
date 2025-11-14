trigger AccountTrigger1 on Account (before insert, before update,after insert, after update) {
     if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        ApeXTrigger1Handler.setDefaultValues(Trigger.new);
        ApeXTrigger1Handler.setShippingAddress(Trigger.new);
          ApeXTrigger1Handler.setShippingAddressNotNullCheck(Trigger.new);
         
         
    }
    if (Trigger.isUpdate) {
        ApeXTrigger1Handler.updateActiveOnContactsAndOpps(Trigger.new, Trigger.oldMap);
    }
    
}