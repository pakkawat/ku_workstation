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

$("#toggletextarea-btn").on('click', function () {
    textarea.toggle();
    $(this).text(function (i, text) {
        return text === "Show Content" ? "Hide Content" : "Show Content";
    });
});

$("#alertcontent-btn").on('click', function () {
    alert(textarea.val());
});