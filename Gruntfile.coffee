module.exports = (grunt) ->
	# load all grunt tasks
	require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

	# load package config


	taskConfig = 
		watch:
			coffee:
				files: ['api/src/**/*.coffee']
				tasks: ['coffee:watch']
				options:
					events: 'all'
					spawn: false

		clean:
			default: 'app/assets'
			dist: [
				'dist/snackk-web-api-request.min.js'
			]

		coffee:
			options:
				sourceMap: true

			watch:
				options:
					sourceMap: true

				files:
					[
						{
							expand: true
							cwd: 'api/src'
							src: '**/*.coffee'
							dest: 'api/assets/src'
							ext: '.js'
						}
					]

		connect:
			server:
				options:
					port: 8000
					hostname: '*'
					base: 'api'

		requirejs:
			options:
				generateSourceMaps: true
				preserveLicenseComments: false
				# https://www.evernote.com/l/ACi-gWuUmp1Gr4p725DVVgCLRrVvfdzhBhk
				removeCombined: true 
				findNestedDependencies: true
				useStrict: true
				optimize: 'none'
				uglify2: 
					compress:
						global_defs:
							DEBUG: false
							LOG_THRESHOLD: 0 # 4: all, 3: info, 2: debug, 1: error, 0: none
						dead_code: true
			api:
				options:
					mainConfigFile: 'api/assets/src/request-config.js'
					baseUrl: 'api/assets/src'
					out: 'dist/snackk-web-api-request.min.js'
					onBuildRead: (moduleName, path, contents) ->
						return contents.replace /\/assets/g, '/dist'
					include: ['init']
					name: 'request-config'

	grunt.initConfig taskConfig

	grunt.registerTask 'default', ->
		grunt.task.run [
			'coffee:watch'
			'connect:server'
			'watch'    
		]

	grunt.registerTask 'build', 'build', [
		'clean:dist'

		'coffee:watch'
		'requirejs'
	]