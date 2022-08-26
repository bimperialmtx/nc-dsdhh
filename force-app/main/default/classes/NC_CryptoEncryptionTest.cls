/**
* @description       : Test class for NC_CryptoEncryption
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_CryptoEncryptionTest {
    
    /*
    *********************************************************
    @Method Name    : encodeStringTest
    @description    : Verify encoding to string data
    ********************************************************
    */
    @IsTest
    public static void encodeStringTest(){
         Contact con1 = new Contact();
         con1.FirstName = 'testing';
         con1.LastName = 'testing';
         con1.County__c = 'Anson';
         Insert con1;
         Test.startTest();
         String encryptedResult = NC_CryptoEncryption.encodeString(con1.Id);
         String decryptedResult = NC_CryptoEncryption.decodeString(encryptedResult);
         System.assertEquals(true, decryptedResult!=null);
         Test.stopTest();
    }
}