component {

    this.title              = "fw1-compat";
    this.author             = "Ortus Solutions";
    this.webURL             = "http://www.ortussolutions.com";
    this.description        = "FW/1 Compatibility Module";
    this.version            = "0.1.0";

    function configure() {
        var config = controller.getSettingStructure( false );
        var configuredColdBoxSettings = config.coldBoxConfig.getPropertyMixin( "coldbox", "variables", {} )
        var configuredLayoutSettings = config.coldBoxConfig.getPropertyMixin( "layoutSettings", "variables", {} )

        // this is a helper for people who have never had to deal with reinits
        defaultIfNotSpecified( "reinitPassword", "", configuredColdBoxSettings, config );

        defaultIfNotSpecified( "handlersConvention", "controllers", configuredColdBoxSettings, config );
        defaultIfNotSpecified( "HandlersInvocationPath", "controllers", configuredColdBoxSettings, config );
        defaultIfNotSpecified( "HandlersPath", expandPath( "/" ) & "controllers", configuredColdBoxSettings, config );
        defaultIfNotSpecified( "eventName", "action", configuredColdBoxSettings, config );
        defaultIfNotSpecified( "defaultLayout", "", configuredLayoutSettings, config );
        defaultIfNotSpecified( "defaultEvent", "main.default", configuredColdBoxSettings, config );

        // reprocess handlers now that the convention might have changed
        controller.getHandlerService().onConfigurationLoad();

        binder.map( "DI1Adapter" ).to( "#moduleMapping#.models.DI1Adapter" );

        binder.mapDirectory(
            packagePath = "model.services",
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
        binder.mapDirectory( packagePath = "model.beans", namespace = "Bean" );
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

    private function defaultIfNotSpecified( name, defaultValue, configuredSettings, systemSettings ) {
        if ( ! structKeyExists( configuredSettings, name ) ) {
            systemSettings[ name ] = defaultValue;
        }
    }

}