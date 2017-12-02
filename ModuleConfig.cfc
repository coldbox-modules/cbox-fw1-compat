component {

    this.title              = "fw1-compat";
    this.author             = "Ortus Solutions";
    this.webURL             = "http://www.ortussolutions.com";
    this.description        = "FW/1 Compatibility Module";
    this.version            = "0.1.0";

    function configure() {
    	var appMappingDots = '';
    	var appMappingSlash = '';
    	
    	if( len( appMapping ) ) {
	    	appMappingDots = appMapping & '.';
	    	appMappingSlash = replace( appMapping, '.', '/', 'all' ) & '/';
    	}
    	
        var config = controller.getSettingStructure( false );
        var configuredColdBoxSettings = config.coldBoxConfig.getPropertyMixin( "coldbox", "variables", {} );
        var configuredLayoutSettings = config.coldBoxConfig.getPropertyMixin( "layoutSettings", "variables", {} );

        // this is a helper for people who have never had to deal with reinits
        defaultIfNotSpecified( "reinitPassword", "", configuredColdBoxSettings, config );

		// If services folder exists, map it.
		if( directoryExists( '/#appMappingSlash#controllers' ) ) {
	        defaultIfNotSpecified( "handlersConvention", "controllers", configuredColdBoxSettings, config );
	        defaultIfNotSpecified( "HandlersInvocationPath", "#appMappingSlash#controllers", configuredColdBoxSettings, config );
	        defaultIfNotSpecified( "HandlersPath", expandPath( "/#appMappingSlash#" ) & "controllers", configuredColdBoxSettings, config );
	      }
     //   defaultIfNotSpecified( "eventName", "action", configuredColdBoxSettings, config );
        defaultIfNotSpecified( "defaultLayout", "default", configuredLayoutSettings, config );
        defaultIfNotSpecified( "defaultEvent", "main.default", configuredColdBoxSettings, config );

        // reprocess handlers now that the convention might have changed
        controller.getHandlerService().onConfigurationLoad();
        controller.getRequestService().onConfigurationLoad();

        binder.map( "DI1Adapter" ).to( "#moduleMapping#.models.DI1Adapter" );

		// If services folder exists, map it.
		if( directoryExists( '/#appMappingSlash#model/services' ) ) {		
	        binder.mapDirectory(
	            packagePath = "#appMappingDots#model.services",
	            namespace = "Service",
	            influence = function( binder, path ) {
	                var mapping = binder.map( listLast( path, "." ) & "Service" )
	                    .to( path )
	                    .initArg( name = "beanFactory", ref = "DI1Adapter" );
	
	                var md = getComponentMetadata( path );
	                for ( var prop in md.properties ) {
	                    if ( reFindNoCase( "service$", prop.name ) > 0 ) {
	                        mapping.initArg( prop.name, prop.name );
	                    }
	                }
	            }
	        );	
		}
		
		// If beans folder exists, map it.
		if( directoryExists( '/#appMappingSlash#model/beans' ) ) {	
        	binder.mapDirectory( packagePath = "#appMappingDots#model.beans", namespace = "Bean" );
        }
        
        // Override ColdBox renderer mapping.
		binder.map( alias="Renderer@coldbox", force=true )
			.toDSL( 'renderer@fw1-compat' );
    }

    function onLoad() {
        var helpers = controller.getSetting( "applicationHelper" );
        if ( ! isArray( helpers ) ) {
            helpers = listToArray( helpers );
        }
        arrayAppend(
            helpers,
            "#moduleMapping#/helpers/FW1CompatibilityHelpers.cfm"
        );
        controller.setSetting( "applicationHelper", helpers );
    }

    function onUnload() {
        controller.setSetting(
            "applicationHelper",
            arrayFilter( controller.getSetting( "applicationHelper" ), function( helper ) {
                return helper != "#moduleMapping#/helpers/FW1CompatibilityHelpers.cfm";
            } )
        );
    }

    function preProcess( event, interceptData, buffer, rc, prc ) {
        // how are we sure we always want to override the event?
        if ( event.valueExists( "action" ) ) {
            rc.event = rc.action;
        }
    }

    function preLayoutRender( event, interceptData, buffer, rc, prc ) {
        interceptData.instance.injectPropertyMixin( "body", controller.getRenderer().renderView(), "variables" );
    }

    function afterInstanceInspection( event, interceptData, buffer, rc, prc ) {
		var md = interceptData.mapping.getObjectMetadata();
		
		// TODO: Figure out when DI/1 autowires. I assume it's more than just for controllers
        if( interceptData.mapping.getType() == 'CFC' && md.fullname contains 'controllers' ) {
	    	for( var prop in md.properties ?: [] ) {
	    		prop.inject = prop.inject ?: prop.name;
	    	}
	    	// This is kind of messy, but the easiest way to reprocess DImetadata
	    	interceptData.mapping.$secret = $secret;
	    	interceptData.mapping.$secret();
	    	interceptData.mapping.processDIMetadata( interceptData.binder, md );
	    }
    }

 	function $secret() {
		this.processDIMetadata = variables.processDIMetadata;
	}

    private function defaultIfNotSpecified( name, defaultValue, configuredSettings, systemSettings ) {
        if ( ! structKeyExists( configuredSettings, name ) ) {
            systemSettings[ name ] = defaultValue;
        }
    }

}
