window.enableEditor = () ->
    editor = window.ed = ace.edit("editor")
    editor.container.style.display = "block"
    editor.setTheme("ace/theme/monokai")
    editor.getSession().setMode("ace/mode/coffee")
    editor.commands.addCommand {
        name: 'execute'
        bindKey: {win: 'Ctrl-Enter'}
        exec: (editor) ->
            source = editor.getValue()
            CoffeeScript.run source
    }
    return editor

#unless window.localStorage?
#    records = {}
#    window.localStorage = {
#        getItem: (key) ->
#            return records[key]
#        setItem: (key, value) ->
#            records[key] = "#{value}"
#    }
#
