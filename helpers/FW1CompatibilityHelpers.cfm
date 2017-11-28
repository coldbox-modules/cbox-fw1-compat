<cfscript>

// variables.body = renderView();

variables.fw = {
    renderData = function( string type = "", any data = "", numeric statusCode = 200, string jsonpCallback = "" ) {
        if ( type == "rawjson" ) { type = "text"; }
        return getRequestContext().renderData( type = type, data = data, statusCode = statusCode, jsonCallback = jsonpCallback );
    },
    populate = function( any cfc, string keys = "", boolean trustKeys = false, boolean trim = false, boolean deep = false, any properties = "" ) {
        // `trim` would be a good addition to our core as well.
        var props = isSimpleValue( properties ) ? getRequestContext().getCollection() : properties;
        props = structMap( props, function( key, value ) {
            return trim && isSimpleValue( value ) ?
                trim( value ) :
                value;
        } );
        populateModel(
            model = cfc,
            memento = props,
            trustedSetter = trustKeys,
            include = keys,
            composeRelationships = deep
        );
    },
    frameworkTrace = function( message, extraInfo ) {
        getLog().debug( message, extraInfo );
    },
    redirect = variables.redirect
};

function redirect(
    string action,
    string preserve = "none",
    string append = "none",
    string path = "",
    any queryString = "",
    string statusCode = "302",
    string header = ""
) {
    // custom headers could be added to setNextEvent
    // needs append implmented still
    setNextEvent(
        event = action,
        persist = preserve != "none" ? preserve : "",
        baseURL = path,
        queryString = queryString,
        statusCode = statusCode
    );
}

function buildURL( string action = ".", string path = "", any queryString = "" ) {
    return getRequestContext().buildLink( linkTo = action, baseURL = path, queryString = queryString );
}

</cfscript>
