component extends="coldmvc.validation.Validator" {

	public boolean function isValid(required any value) {

		return coldmvc.valid.string(arguments.value);

	}

	public string function getMessage() {

		return "The value for ${name} must be a string.";

	}

}