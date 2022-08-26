/*
*   Class Name: NC_AccountDataFactory
*   Description: Used for creating account data
*
*   Date            New/Modified         User                 Identifier                Description
*   30/04/2020         New         Hiten Aggarwal(mtx)
*/


@isTest
public class NC_AccountDataFactory {
   /*
    * Method Name: createAccountRecords
    * Description: creates Account record
    * @return: List<Account> - list of accounts
    * @param  accountName - Name of account , 
    *         count - Number of records to be created , 
    *         isInsert - wheather to insert account in this method only.
    */
     public static List<Account> createAccountRecords(String accountName, Integer count, Boolean isInsert) {
        List<Account> accountList = new List<Account>();
        for(Integer i=0; i<count; i++) {
            Account accountRecord = new Account();
            accountRecord.Name = accountName + ' ' + i;
            accountList.add(accountRecord);
        }
        if(isInsert) {
            insert accountList;
        }
        return accountList; 
    }
    /*
    * Method Name: createAccountRecords
    * Description: Overwritting above method
    * @return: List<Account> - list of accounts
    * @param  reocrdTypeId, accountName, count, isInsert
    */
    
    public static List<Account> createAccountRecords(Id reocrdTypeId, String accountName, Integer count, Boolean isInsert) {
        List<Account> accountList =  createAccountRecords(accountName,count,FALSE);
        for(Account accountRecord : accountList) {
            accountRecord.RecordTypeId = reocrdTypeId ;
        }
        if(isInsert) {
            insert accountList;
        }
        return accountList; 
    }

}