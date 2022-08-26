/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   06-22-2021   kavya.konagonda@mtxb2b.com   Initial Version
**/
public with sharing class NC_CryptoEncryption {

    // Security key must be 32 characters string
    // Blob key = Crypto.generateAesKey(256);
    private static String key= 'kCqcuXOw/t8OVO4o6L3+jxnNvO2q89rN7HYIFs/QeWU=';
    
    /*
    *********************************************************
    @Method Name    : encodeString
    @description    : Encode input string
    @param          : String encodingString
    @return         : String
    ********************************************************
    */
    public static String encodeString(String encodingString) {
        Blob blobData = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(key), Blob.valueOf(encodingString));
        return EncodingUtil.base64Encode(blobData);
    }

    /*
    *********************************************************
    @Method Name    : decodeString
    @description    : Decode input string
    @param          : String str
    @return         : String
    ********************************************************
    */
    public static String decodeString(String str) {
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(str);		
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(key), encodedEncryptedBlob);		
        return decryptedBlob.toString();   
    }

}