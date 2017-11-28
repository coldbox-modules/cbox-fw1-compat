component {

    property name="wirebox" inject="wirebox";

    function getBean( mapping ) {
        return wirebox.getInstance( mapping );
    }

}
