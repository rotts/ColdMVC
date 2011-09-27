/**
 * @extends coldmvc.Scope
 */
component {

	public any function init() {

		super.init();

		variables.statusCodes = {
			100 = "Continue",
			101 = "Switching Protocols",
			200 = "OK",
			201 = "Created",
			202 = "Accepted",
			203 = "Non-Authoritative Information",
			204 = "No Content",
			205 = "Reset Content",
			206 = "Partial Content",
			300 = "Multiple Choices",
			301 = "Moved Permanently",
			302 = "Found",
			303 = "See Other",
			304 = "Not Modified",
			305 = "Use Proxy",
			306 = "(Unused)",
			307 = "Temporary Redirect",
			400 = "Bad Request",
			401 = "Unauthorized",
			402 = "Payment Required",
			403 = "Forbidden",
			404 = "Not Found",
			405 = "Method Not Allowed",
			406 = "Not Acceptable",
			407 = "Proxy Authentication Required",
			408 = "Request Timeout",
			409 = "Conflict",
			410 = "Gone",
			411 = "Length Required",
			412 = "Precondition Failed",
			413 = "Request Entity Too Large",
			414 = "Request-URI Too Long",
			415 = "Unsupported Media Type",
			416 = "Requested Range Not Satisfiable",
			417 = "Expectation Failed",
			500 = "Internal Server Error",
			501 = "Not Implemented",
			502 = "Bad Gateway",
			503 = "Service Unavailable",
			504 = "Gateway Timeout",
			505 = "HTTP Version Not Supported"
		};

		return this;

	}

	private struct function getScope() {

		return request;

	}

	public struct function getHeaders() {

		var httpRequestData = getHTTPRequestData();

		return httpRequestData.headers;

	}

	/**
	 * @actionHelper isAjax
	 */
	public boolean function isAjax() {

		var headers = getHeaders();

		if (structKeyExists(headers, "X-Requested-With") && headers["X-Requested-With"] == "XMLHttpRequest") {
			return true;
		}

		return false;

	}

	/**
	 * @hint http://detectmobilebrowser.com/
	 * @actionHelper isMobile
	 * @viewHelper isMobile
	 */
	 public boolean function isMobile() {

		var userAgent = coldmvc.cgi.get("http_user_agent");

		return reFindNoCase("android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino", userAgent) || reFindNoCase("1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|e\-|e\/|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\-|2|g)|yas\-|your|zeto|zte\-", left(userAgent, 4));

	 }
	 
	 /**
	  * @actionHelper isDevelopment
	  * @viewHelper isDevelopment
	  */
	 public boolean function isDevelopment() {
	 	
	 	return coldmvc.config.get("development");
	 	 
	 }

	/**
	 * @actionHelper isPost
	 */
	public boolean function isPost() {

		return getMethod() == "post";

	}

	/**
	 * @actionHelper isGet
	 */
	public boolean function isGet() {

		return getMethod() == "get";

	}

	public string function getMethod() {

		return coldmvc.cgi.get("request_method");

	}

	public void function setStatus(required numeric statusCode, string statusText="") {

		if (arguments.statusText == "") {
			arguments.statusText = getStatusText(arguments.statusCode);
		}

		getPageContext().getResponse().getResponse().setStatus(arguments.statusCode, arguments.statusText);

	}

	public string function getStatus() {

		return getPageContext().getResponse().getResponse().getStatus();

	}

	public string function getStatusText(any statusCode="") {

		if (arguments.statusCode == "") {
			arguments.statusCode = getStatus();
		}

		if (structKeyExists(variables.statusCodes, arguments.statusCode)) {
			return variables.statusCodes[arguments.statusCode];
		} else {
			return "";
		}

	}

}