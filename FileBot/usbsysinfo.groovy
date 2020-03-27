#!/usr/bin/env filebot -script
// Custom script to lessen the onslaught of information output during installation

println Settings.getApplicationIdentifier()

println 'Groovy: ' + groovy.lang.GroovySystem.getVersion()

println 'JRE: ' + Settings.getJavaRuntimeIdentifier()

println 'DATA: ' + ApplicationFolder.AppData.get()

try {
	print 'License: '
	println Settings.LICENSE.check()
} catch(Throwable error) {
	println error.message
}