/**
 * Created by ashishpandey on 30/06/21.
 */

public class NC_NDBEDPResponseWrapper {

    public Integer STATUS;
    public String ERROR_DESCRIPTION;
    public Patron patron;

    public class PatronContacts {
        public Integer STATUS;
        public String ERROR_DESCRIPTION;
        public String AddressLinkObj;
        public String PatronContactObj;
        public String ContactType;
        public String ContactSubType;
    }

    public class Patron {
        public String PatronObj;
        public String PatronID;
        public String AddressLinkObj;
        public List<PatronContacts> PatronContacts;
    }

}