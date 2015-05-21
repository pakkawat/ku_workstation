var textarea = $('#file_data');

var editor = ace.edit("editor");
editor.setTheme("ace/theme/twilight");
editor.getSession().setMode("ace/mode/javascript");
editor.getSession().setUseWorker(false);
editor.setOptions({
    maxLines: Infinity
});
editor.getSession().on('change', function () {
    textarea.val(editor.getSession().getValue());
});

textarea.val(editor.getSession().getValue());

