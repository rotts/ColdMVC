<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "url")>
		<cfset attributes.url = coldmvc.link.to("/atom") />
	</cfif>

	<cfoutput>
	<link rel="alternate" type="application/atom+xml" href="#attributes.url#" />
	</cfoutput>

</cfif>