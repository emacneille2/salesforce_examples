trigger contactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete) {
    ContactService contactService = new ContactService();
    contactService.newContacts = Trigger.new;
    contactService.oldContacts = null;

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            contactService.beforeInsert();
        } else if (Trigger.isAfter) {
            contactService.afterInsert();
        }        
    }
    else {
        contactService.oldContacts = new Map<Id, Contact>(Trigger.old);
        if (Trigger.isUpdate) {
        
            if (Trigger.isBefore) {
                contactService.beforeUpdate();
            } else if (Trigger.isAfter) {
                contactService.afterUpdate();
            } 
        }
        else if (Trigger.isDelete) {
            if (Trigger.isBefore) {
                contactService.beforeDelete();
            } else if (Trigger.isAfter) {
                contactService.afterDelete();
            } 
        }
    }
}