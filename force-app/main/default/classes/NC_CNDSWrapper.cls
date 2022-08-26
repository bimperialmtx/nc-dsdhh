/**
 * Created by ashishpandey on 07/05/21.
 */

public class NC_CNDSWrapper {

    //****Persona Search Request******
    public class PersonaSearchRequest {

        public String LAST_NAME;
        public String FIRST_NAME;
        public String DATE_OF_BIRTH;
        public String SEX_CODE;
    }

    //****Persona Create Request******
    public class PersonCreateRequest {

        public String LAST_NAME;
        public String FIRST_NAME;
        public String MIDDLE_INITIAL;
        public String NAME_SUFFIX;
        public String DATE_OF_BIRTH;
        public String SEX_CODE;
        public String ETHNICITY;
        public String LANGUAGE_PREFRENCE;
        public String USER_ID;
        public String RACE_CODE1;
        public String RACE_CODE2;
        public String RACE_CODE3;
        public String RACE_CODE4;
        public String RACE_CODE5;


    }
    //****Persona Update Request******
    public class PersonUpdateRequest {

        public String CNDS_NUMBER;
        public String CHECK_DIGIT;
        public String LAST_NAME;
        public String FIRST_NAME;
        public String MIDDLE_INITIAL;
        public String NAME_SUFFIX;
        public String DATE_OF_BIRTH;
        public String SEX_CODE;
        public String ETHNICITY;
        public String LANGUAGE_PREFRENCE;
        public String USER_ID;
        public String RACE_CODE1;
        public String RACE_CODE2;
        public String RACE_CODE3;
        public String RACE_CODE4;
        public String RACE_CODE5;

    }

    //****Personal Lookup Response******
    public class PearsonSearchWrapper {
        public String STATUS;
        public String ERROR_DESCRIPTION;
        public List<PersonaSearchResponse> CCIPR82I_Person_Search_Response;
    }
    public class PersonaSearchResponse {
        public String IDENTIFIER;
        public String CHECK_DIGIT;
        public String CURRENT_STATUS_CODE;
        public String SOUNDEX_ID;
        public String LAST_NAME;
        public String FIRST_NAME;
        public String MIDDLE_INITIAL;
        public String NAME_SUFFIX;
        public String PRIMARY_SSN;
        public String DATE_OF_BIRTH;
        public String SEX_CODE;
        public String ETHNICITY;
        public String LANGUAGE_PREFRENCE;
        public String RACE_CODE1;
        public String RACE_CODE2;
        public String RACE_CODE3;
        public String RACE_CODE4;
        public String RACE_CODE5;

    }

    //****Personal Create Response******
    public class PersonCreateResponse {

        public String STATUS;
        public String ERROR_DESCRIPTION;
        public String IDENTIFIER;
        public String CHECK_DIGIT;
    }
    //****Personal Update Response******
    public class PersonUpdateResponse {

        public String STATUS;
        public String ERROR_DESCRIPTION;
        public String IDENTIFIER;
        public String CHECK_DIGIT;
    }

}