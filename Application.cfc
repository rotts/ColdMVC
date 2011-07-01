component {

	setupApplication();

	public any function onApplicationStart() {

		lock name="coldmvc.Application" type="exclusive" timeout="5" throwontimeout="true" {

			structDelete(application, "coldmvc");

			setupSettings();

			var pluginManager = createPluginManager();

			// add a mapping for each plugin
			structAppend(this.mappings, pluginManager.getMappings(), false);

			application.coldmvc.mappings = structCopy(this.mappings);

			var beanFactory = createBeanFactory(pluginManager);
			setBeanFactory(beanFactory);
			beanFactory.getBean("config").setSettings(getSettings());

			dispatchEvent("preApplication");
			dispatchEvent("applicationStart");

		}

	}

	public any function onSessionStart() {

		dispatchEvent("sessionStart");

	}

	public any function onSessionEnd() {

		dispatchEvent("sessionEnd");

	}

	public any function onRequestStart() {

		var reloadKey = getSetting("reloadKey");

		if (structKeyExists(url, reloadKey)) {

			var reloadPassword = getSetting("reloadPassword");

			if (reloadPassword == "" || url[reloadKey] == reloadPassword) {
				reload();
			}

		} else if (getSetting("autoReload")) {
			reload();
		}

		// add a mapping for each plugin
		structAppend(this.mappings, application.coldmvc.pluginManager.getMappings(), false);

		dispatchEvent("preRequest");
		dispatchEvent("requestStart");

	}

	private void function reload() {

		ormReload();
		onApplicationStart();
		dispatchEvent("postReload");
		coldmvc.debug.set("reloaded", true);

	}

	public any function onRequestEnd() {

		try {
			dispatchEvent("requestEnd");
			dispatchEvent("postRequest");
		}
		catch(any e) {

		}

	}

	public any function createPluginManager() {

		var pluginManager = new coldmvc.app.util.PluginManager();
		pluginManager.setDirectory(this.directory);
		pluginManager.setConfigPath("/config/plugins.cfm");
		pluginManager.loadPlugins();

		application.coldmvc.pluginManager = pluginManager;

		return application.coldmvc.pluginManager;

	}

	private any function createBeanFactory(required any pluginManager) {

		var beans = xmlNew();
		beans.xmlRoot = xmlElemNew(beans, "beans");
		beans.xmlRoot.xmlAttributes["default-autowire"] = "byName";

		// add the beans defined in our application
		addBeans(beans, "/config/coldspring.xml");

		// now loop over all the plugins and add their beans
		var plugins = pluginManager.getPlugins();
		var i = "";
		for (i = 1; i <= arrayLen(plugins); i++) {
			addBeans(beans, plugins[i].path & "/config/coldspring.xml");
		}

		// finally load all the beans from ColdMVC
		addBeans(beans, "/coldmvc/config/coldspring.xml");

		var xml = toString(beans);
		xml = replace(xml, "<!---->", "", "all");

		// get the base settings
		var settings = getSettings();

		if (!structKeyExists(settings, "datasource")) {
			settings["datasource"] = this.datasource;
		}

		var beanFactory = new coldmvc.app.util.BeanFactory(xml, settings, {
			"pluginManager" = pluginManager
		});

		return beanFactory;

	}

	private any function addBeans(required xml beans, required string configPath) {

		if (!_fileExists(configPath)) {
			configPath = expandPath(configPath);
		}

		if (_fileExists(configPath)) {

			var content = fileRead(configPath);

			if (isXML(content)) {

				var xml = xmlParse(content);
				var i = "";
				var j = "";

				var beanDefs = xmlSearch(xml, "/beans/bean");

				for (i = 1; i <= arrayLen(beanDefs); i++) {

					var bean = beanDefs[i];
					var exists = xmlSearch(beans, "beans/bean[@id='#bean.xmlAttributes.id#']");

					if (arrayLen(exists) == 0) {

						var imported = xmlImport(beans, bean);

						for (j = 1; j <= arrayLen(imported); j++) {
							arrayAppend(beans.xmlRoot.xmlChildren, imported[j]);
						}

					}

				}

				var imports = xmlSearch(xml, "/beans/import");

				for (i = 1; i <= arrayLen(imports); i++) {
					addBeans(beans, imports[i].xmlAttributes.resource);
				}

			}

		}

	}

	private any function xmlImport(required any destination, required any source) {

		var node = xmlElemNew(destination, source.xmlName);
		var i = "";

		structAppend(node.xmlAttributes, source.xmlAttributes);

		node.xmlText = source.xmlText;
		node.xmlComment = source.xmlComment;

		for (i = 1; i <= arrayLen(source.xmlChildren); i++) {
			arrayAppend(node.xmlChildren, xmlImport(destination, source.xmlChildren[i]));
		}

		return node;

	}

	private void function setBeanFactory(required any beanFactory) {

		application.coldmvc.beanFactory = arguments.beanFactory;

	}

	private any function getBeanFactory() {

		return application.coldmvc.beanFactory;

	}

	private void function dispatchEvent(required string event) {

		getBeanFactory().getBean("eventDispatcher").dispatchEvent(event);

	}

	private void function setupApplication() {

		this.sessionManagement = true;
		this.serverSideFormValidation = false;

		var defaults = {
			rootPath = sanitizePath(getDirectoryFromPath(expandPath("../"))),
			ormEnabled = true,
			ormSettings = {},
			sessionTimeout = createTimeSpan(0, 2, 0, 0),
			mappings = {}
		};

		structAppend(this, defaults, false);

		this.directory = listLast(this.rootPath, "/");

		if (!structKeyExists(this, "name")) {
			this.name = this.directory & "_" & hash(this.rootPath);
		}

		defaults = {};
		defaults["/config"] = this.rootPath & "config/";
		defaults["/public"] = this.rootPath & "public/";
		defaults["/app"] = this.rootPath & "app/";
		defaults["/generated"] = this.rootPath & ".generated/";
		defaults["/views"] = this.rootPath & ".generated/views/";
		defaults["/layouts"] = this.rootPath & ".generated/layouts/";
		defaults["/tags"] = this.rootPath & ".generated/tags/";

		// check for a local plugins directory
		if (_directoryExists(this.rootPath & "plugins/")) {
			defaults["/plugins"] = this.rootPath & "plugins/";
		} else if (_directoryExists(expandPath("/plugins/"))) {
			defaults["/plugins"] = sanitizePath(expandPath("/plugins/"));
		}

		// check for a local coldmvc directory first
		if (_directoryExists(this.rootPath & "coldmvc/")) {
			defaults["/coldmvc"] = this.rootPath & "coldmvc/";
		} else if (_directoryExists(expandPath("/coldmvc/"))) {
			defaults["/coldmvc"] = sanitizePath(expandPath("/coldmvc/"));
		}

		structAppend(this.mappings, defaults, false);

		var settings = getSettings();

		if (structKeyExists(settings, "datasource")) {
			if (settings.datasource != "") {
				this.datasource = settings.datasource;
			} else {
				this.ormEnabled = false;
			}
		} else {
			this.datasource = this.directory;
		}

		if (structKeyExists(settings, "ormEnabled")) {
			this.ormEnabled = settings.ormEnabled;
		}

		defaults = {
			cfclocation = [ getDirectoryFromPath(expandPath("../")) ],
			dbcreate = "update",
			eventHandler = "coldmvc.app.util.EventHandler",
			eventHandling = true,
			namingStrategy = "coldmvc.app.util.NamingStrategy",
			flushAtRequestEnd = false
		};

		if (structKeyExists(settings, "ormDialect")) {
			this.ormSettings.dialect = settings.ormDialect;
		}

		if (structKeyExists(settings, "ormDBCreate")) {
			this.ormSettings.dbcreate = settings.ormDBCreate;
		}

		if (structKeyExists(settings, "ormLogSQL")) {
			this.ormSettings.logSQL = settings.ormLogSQL;
		}

		if (structKeyExists(settings, "ormSaveMapping")) {
			this.ormSettings.saveMapping = settings.ormSaveMapping;
		}

		structAppend(this.ormSettings, defaults, false);

		// check to see if a hibernate mapping file exists
		if (_fileExists(this.rootPath & "/config/hibernate.hbmxml")) {

			// if autoGenMap hasn't been explicitly set already
			if (!structKeyExists(this.ormSettings, "autoGenMap")) {

				// don't generate the mapping files if they have one
				this.ormSettings.autoGenMap = false;

			}

			// if saveMapping hasn't been set already
			if (!structKeyExists(this.ormSettings, "saveMapping")) {

				// don't generate the mapping files if they have one
				this.ormSettings.saveMapping = true;

			}

		} else {

			// if saveMapping hasn't been set already
			if (!structKeyExists(this.ormSettings, "saveMapping")) {

				// don't generate the mapping files if they have one
				this.ormSettings.saveMapping = false;

			}

		}

	}

	private struct function setupSettings() {

		if (!structKeyExists(variables, "settings")) {

			variables.settings = {};
			variables.environment = "";

			var configPath = this.rootPath & "config/config.ini";

			// check to see if there's a config file
			if (_fileExists(configPath)) {

				// make sure the mapping works
				if (_fileExists(expandPath("/coldmvc/app/util/Ini.cfc"))) {
					var ini = new coldmvc.app.util.Ini(configPath);
				} else {
					var ini = new app.util.Ini(configPath);
				}

				// load the default section first
				var section = ini.getSection("default");

				// append the section to the settings
				structAppend(variables.settings, section);

				// check to see if there's an environment file
				var environmentPath = this.rootPath & "config/environment.txt";

				if (_fileExists(environmentPath)) {

					// read the environment
					variables.environment = fileRead(environmentPath);

					// get the config settings
					section = ini.getSection(environment);

					// adding the environments settings, overriding any default settings
					structAppend(variables.settings, section, true);

				}

			}

		}

		var defaults = {
			"autoReload" = false,
			"controller" = "index",
			"debug" = true,
			"development" = false,
			"environment" = variables.environment,
			"https" = "auto",
			"layout" = "index",
			"reloadKey" = "init",
			"reloadPassword" = "",
			"rootPath" = this.rootPath,
			"sesURLs" = false
		};

		// override any default variables
		structAppend(variables.settings, defaults, false);

		if (!structKeyExists(variables.settings, "urlPath")) {

			if (variables.settings["sesURLs"]) {
				variables.settings["urlPath"] = replaceNoCase(cgi.script_name, "/index.cfm", "");
			} else {
				variables.settings["urlPath"] = cgi.script_name;
			}

		}

		if (!structKeyExists(variables.settings, "assetPath")) {

			var assetPath = replaceNoCase(variables.settings["urlPath"], "index.cfm", "");

			if (assetPath == "/") {
				assetPath = "";
			} else if (right(assetPath, 1) == "/") {
				assetPath = left(assetPath, len(assetPath) - 1);
			}

			variables.settings["assetPath"] = assetPath;

		}

		application["coldmvc"] = {};
		application["coldmvc"].settings = variables.settings;

		return variables.settings;

	}

	private struct function getSettings() {

		if (!isDefined("application") || !structKeyExists(application, "coldmvc") || !structKeyExists(application.coldmvc, "settings")) {
			return setupSettings();
		}

		return application.coldmvc.settings;

	}

	private any function getSetting(required string key) {

		var settings = getSettings();

		if (structKeyExists(settings, key)) {
			return settings[key];
		}

		return "";

	}

	private string function sanitizePath(required string filePath) {

		var path = replace(arguments.filePath, "\", "/", "all");

		if (right(path, 1) != "/") {
			path = path & "/";
		}

		return path;

	}

	private boolean function _fileExists(required string filePath) {

		var result = false;

		try {
			result = fileExists(filePath);
		}
		catch (any e) {
		}

		return result;

	}

	private boolean function _directoryExists(required string directoryPath) {

		var result = false;

		try {
			result = directoryExists(directoryPath);
		}
		catch (any e) {}

		return result;

	}

}