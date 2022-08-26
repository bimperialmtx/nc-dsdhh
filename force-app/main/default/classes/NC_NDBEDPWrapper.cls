/**
 * Created by ashishpandey on 30/06/21.
 */

public class NC_NDBEDPWrapper {

    public Integer STATUS;
    public String ERROR_DESCRIPTION;
    public Integer count;
    public String restartToken;
    public Boolean hasMoreResults;
    public List<Patrons> patrons;

    public class PatronContacts {
        public String ContactType;
        public String ContactValue;
        public String ContactSubType;
        public String Address;
        public String City;
        public String PostalCode;
        public String CountyCode;
        public String CountryCode;
        public String StateCode;
        public String AltContactEmail;
        public String AltContactPhone;
        public String ContactMode;
        public String PatronContactObj;
        public String AddressLinkObj;
    }

    public class Patrons {
        public String PatronObj;
        public String PatronID;
        public String BirthDate;
        public String FirstName;
        public String LastName;
        public String MI;
        public String RegExpDate;
        public String StatusCode;
        public String SuffixCode;
        public String Ethnicity;
        public String PatronType;
        public String GenderCode;
        public String PatronUserID;
        public String LanguageCode;
        public String LibraryId;
        public List<PatronContacts> PatronContacts;
    }
}