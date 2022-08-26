/**
 * Created by ashishpandey on 30/06/21.
 */

public class NC_NDBEDPRequestWrapper {

    public String PatronID;
    public String Gender;
    public String BirthDate;
    public String FirstName;
    public String LastName;
    public String MI;
    public String RegEndDate;
    public String StatusCode;
    public String SuffixCode;
    public String PatronType;
    public String LanguageCode;
    public String Ethnicity;
    public String LibraryID;
    public List<PatronContacts> PatronContacts;
    public List<PatronContactPrefs> PatronContactPrefs;
    public List<PatSubscriptions> PatSubscriptions;
    public List<PatSubscriptions> PatWebOpacs;
    public List<PatSubscriptions> PatronBlocks;

    public class PatronContacts {
        public String ContactSubType;
        public String ContactType;
        public String ContactValue;
        public String ContactMode;
        public String Note;
        public String PatronContactObj;
        public String AltContactEMail;
        public String Address;
        public String City;
        public String PostalCode;
        public String CountyCode;
        public String CountryCode;
        public String StateCode;
        public String AltContactPhone;
    }

    public class PatronContactPrefs {
        public Object ActiveDate;
        public String FuncCode;
        public String Order;
        public String ContactValue;
        public String ContactType;
        public String ContactSubType;
        public String PatContactPrefType;
    }

    public class PatSubscriptions { }
}