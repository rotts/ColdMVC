/**
 * @accessors true
 */
component {
 
 	property modelPrefix;
	property suffixes;
	property development;
 
	public any function init() {
		cache = {};		
		var appSettings = application.getApplicationSettings();		
		if (structKeyExists(appSettings, "ormEnabled") and appSettings.ormEnabled) {
			models = ormGetSessionFactory().getAllClassMetaData();
		}
		else {
			models = {};
		}
		return this;
  
	}
	
	public void function injectModels(required string event) {
		
		if (!development) {
	
			var beanName = "";
			var factory = $.factory.get();
			
			var beanDefinitions = factory.getBeanDefinitionList();
			
			for (beanName in beanDefinitions) {				
				inject(beanName);
			}
		
		}
		
	}
	
	public void function inject(required string beanName, any bean) {
		
		var i = "";
		
		for (i=1; i <= arrayLen(suffixes); i++) {
		
			var suffix = suffixes[i];
				
			if (right(beanName, len(suffix)) == suffix) {
			 	
				if (!structKeyExists(arguments, "bean")) {
					bean = $.factory.get(beanName);
				}
				
				var metaData = getMetaData(bean);
					
				if (structKeyExists(metaData, "model")) {						
					var model = metaData.model;
				}					
				else {						
					var model = left(beanName, len(beanName)-len(suffix));						
				}
				
				if ($.model.exists(model)) {
					
					var object = getModel(model);					
					var singular = $.string.camelize(model);
					var plural = $.string.camelize($.string.pluralize(model));
					
					var arg = {
						"#modelPrefix##singular#" = object,
						"__Model" = object,
						"__singular" = singular,
						"__plural" = plural
					};
					
					bean.set__Model(arg);
					
				}
				
				for (model in models) {
					if (structKeyExists(bean, "set#modelPrefix##model#")) {					
						evaluate("bean.set#modelPrefix##model#(getModel(model))");
					}
				}
			 
			}

		}
	
	}
	 
	public void function postProcessAfterInitialization(required any bean, required string beanName) {	
		if (development) {			
			inject(beanName, bean);		
		}	
	} 
	
	private any function getModel(string model) {
	
		if (!structKeyExists(cache, model)) {								
			var entity = entityNew(model);
			$.factory.autowire(entity);
			cache[model] = entity;		
		}
		
		return cache[model];
	
	}
 
}