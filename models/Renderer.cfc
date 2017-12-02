component extends='coldbox.system.web.Renderer' {
	
	function renderLayout() {
	  arguments.instance = this;
	  return super.renderLayout( argumentCollection=arguments );
	}

}
