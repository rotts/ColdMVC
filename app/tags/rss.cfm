<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "url")>
		<cfset attributes.url = coldmvc.link.to("/rss") />
	</cfif>

	<cfoutput>
	<link rel="alternate" type="application/rss+xml" href="#attributes.url#" />
	</cfoutput>

</cfif>