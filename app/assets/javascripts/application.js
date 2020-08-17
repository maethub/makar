// = require jquery/dist/jquery.min.js
// = require jquery-ujs/src/rails.js

//= require codemirror
//= require codemirror/modes/javascript

// Loads all Semantic javascripts
//= require semantic-ui

// Selectize.js
//= require selectize

// Clusterize
//= require clusterize.js/clusterize.js

//= require search

//= require_tree .


$( document ).ready(function() {

    // Semantic UI vertical toggler;
    $(".ui.toggle.button").click(function() {
        $(".mobile.only.grid .ui.vertical.menu").toggle(100);
    });

    $(".ui.dropdown").dropdown();

    $('select.dropdown').dropdown();

    // Select all functionality
    $("input[type=checkbox].select-all").click( function() {
        let val = $( this ).attr('checked');
        $("input:checkbox[name^=select_action]").each( function(index) {
            $( this ).attr('checked', !val);
        });
    });

    $("input.no-disable").click( function() {
        setTimeout(() => {
            $( this ).removeAttr('disabled');
        }, 1000)

    });
});
