module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-groc"
  grunt.loadNpmTasks "grunt-open"

  grunt.initConfig
    path:
      source:
        client: "app/client"
        spec: "spec/coffee"
        jasmine_helpers: "spec/helpers"
      dest:
        client: "public/js/"
        spec: "spec/js/"
        jasmine_helpers: "spec/helpers/js/"

    # Just Copy files (библиотеки в чистом виде, или что еще)
    copy: 
      app:
        files: [
          expand: true
          cwd: "<%= path.source.client %>"
          src: ["**/*.js"]
          dest: "<%= path.dest.client %>"
        ]

    # Coffee-script 
    coffee:
      app:
        files: [
          expand: true
          cwd: "<%= path.source.client %>"
          src: ["**/*.coffee"]
          dest: "<%= path.dest.client %>"
          ext: ".js"
        ]
        options:
          bare: false
          sourceMap: true

      specs:
        files: [
          expand: true
          cwd: "<%= path.source.spec %>"
          src: ["**/*coffee"]
          dest: "<%= path.dest.spec %>"
          ext: ".js"
        ]
        options:
          bare: false
          sourceMap: true

      jasmine_helpers:
        files: [
          expand: true
          cwd: "<%= path.source.jasmine_helpers %>"
          src: ["**/*coffee"]
          dest: "<%= path.dest.jasmine_helpers %>"
          ext: ".js"
        ]
        options:
          bare: false
          sourceMap: true

    connect: 
      phantom:
        options:
          port: 8889
          base: "."
      browser:
        options:
          port: 8888
          base: "."
          keepalive: true

    open:
      specs:
        path: "http://localhost:<%= connect.browser.options.port %>/_SpecRunner.html" 

    # GROC
    groc:
      app:
        src: ["<%= path.source.client %>/**/*.coffee"]

    
    # Require.js 
    requirejs:
      compile:
        options:
          baseUrl: "public/js/"
          name: "app"
          include: ["loader", "events"]
          out: "public/js/app-require-optimized.js"
          optimize: "none"
          paths:
            # Хитрый ход (официальный), чтобы not include этот файл в сборку
            underscore: "empty:"
          shim:
            underscore:
              exports: "_"

    
    # Jasmine tests 
    jasmine:
      # affix needs jquery (for jasmine fixtures)
      src: ["public/js/app.js"]
      options: 
        vendor: ["public/js/lib/require.js", "public/js/lib/underscore-min.js", "public/js/lib/jquery-1.9.1.min.js"]
        specs: "spec/js/**/*_spec.js"
        helpers: "spec/helpers/**/*.js"
        #host: "http://localhost:<%= connect.phantom.options.port %>/"
        junit:
          path: "reports/.junit-output/"
        template: require('grunt-template-jasmine-istanbul')
        templateOptions:
          coverage: 'reports/coverage.json'
          report: 'reports/coverage'
          #template: require('grunt-template-jasmine-requirejs'),
          #templateOptions:
          #  requireConfig:
          #    baseUrl: '.grunt/grunt-contrib-jasmine/src/main/js/'
      timeout: 10000
    
    # CoffeeLint
    coffeelint:
      app:
        files:
          src: ["app/client/*.coffee","app/client/**/*.coffee"]
        options: grunt.file.readJSON('configs/coffeelint.json')
      specs:
        files:
          src: ["spec/coffee/*.coffee","spec/coffee/**/*.coffee"]
        options: grunt.file.readJSON('configs/coffeelint.json')
      jasmine_helpers:
        files:
          src: ["spec/coffee/*.coffee","spec/coffee/**/*.coffee"]
        options: grunt.file.readJSON('configs/coffeelint.json')
    
    # Concatenation & clean 
    concat:
      app:
        src: ["public/js/app-require-config.js", "public/js/app-require-optimized.js"]
        dest: "public/js/app.js"

    clean:
      file: "public/js/app-require-optimized.js"

    
    # Watch tasks 
    #watch:
    #  tests:
    #    files: ["<config:jasmine.specs>", "src/**/*js"]
    #    tasks: "jasmine"

  grunt.registerTask "lint", ["coffeelint"]
  grunt.registerTask "require", ["coffee","requirejs","concat","clean"]
  grunt.registerTask "spec", ["require","jasmine"]
  grunt.registerTask "livetest", ["open","connect:browser"]

  grunt.registerTask "default", ["lint","copy","require"]
  grunt.registerTask "full", ["default","jasmine","groc"]