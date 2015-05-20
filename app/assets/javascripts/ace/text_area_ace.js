var textarea = $('#content');

var editor = ace.edit("editor");
editor.setTheme("ace/theme/twilight");
editor.getSession().setMode("ace/mode/javascript");
editor.setOptions({
    maxLines: Infinity
});
editor.getSession().on('change', function () {
    textarea.val(editor.getSession().getValue());
});

textarea.val(editor.getSession().getValue());

